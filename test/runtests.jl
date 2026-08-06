using FASTX
using NamedArrays
using Test
using shhquis

@testset "contact matrices" begin
    triples = Any["a" "b" 2.0; "b" "a" 3.0; "a" "c" 1.0]
    converted = coltodist(triples)
    @test converted["a", "b"] == 2.0
    @test converted["b", "a"] == 3.0
    @test converted["a", "c"] == 1.0

    mktempdir() do directory
        infofile = joinpath(directory, "info_contigs.txt")
        contactsfile = joinpath(directory, "contacts.bg2")
        write(infofile, "contig\tlength\tn_frags\tcumul_length\nA\t100\t1\t0\nB\t200\t1\t100\nC\t300\t1\t300\n")
        write(contactsfile, "1\t10\t0\t2\t20\t0\t4.5\nA\t10\t0\tC\t20\t0\t2.0\n")

        contacts = builddist(infofile, contactsfile, 2)
        @test contacts[1, 2] == contacts[2, 1] == 4.5
        @test contacts[1, 3] == contacts[3, 1] == 2.0
        @test contacts[2, 3] == 0.0

        distances = contactdistances(contacts)
        @test distances[1, 1] == 0.0
        @test distances[1, 2] < distances[1, 3] < distances[2, 3]
        @test distances == transpose(distances)
    end
end

@testset "component and orphan ordering" begin
    names = ["A", "B", "C", "D", "E"]
    lengths = [100, 500, 300, 50, 200]
    contacts = zeros(5, 5)
    contacts[1, 3] = contacts[3, 1] = 10
    contacts[4, 5] = contacts[5, 4] = 5

    # B is the largest singleton component; A/C and D/E retain their relative
    # positions from the clustering order.
    @test order_contigs(contacts, [3, 1, 4, 5, 2], names, lengths) ==
        ["B", "C", "A", "D", "E"]

    no_links = zeros(3, 3)
    @test order_contigs(no_links, [1, 2, 3], names[1:3], lengths[1:3]) ==
        ["B", "C", "A"]
    @test_throws ArgumentError order_contigs(no_links, [1, 1, 3], names[1:3], lengths[1:3])
    @test ordernames([3, 1], ["A", "B", "C"]) == ["C", "A"]
end

@testset "FASTA output" begin
    mktempdir() do directory
        input = joinpath(directory, "genome.fasta")
        index = joinpath(directory, "genome.fasta.fai")
        output = joinpath(directory, "reoriented.fasta")
        write(input, ">a alpha\nACGT\n>b beta\nAAGC\n")
        write(index, "a\t4\t9\t4\t5\nb\t4\t22\t4\t5\n")

        metadata = NamedArray(
            [0 0; 0 1],
            (["a", "b"], ["splitp", "f/r"]),
            ("contig", "measurement"),
        )
        @test write_reorient(input, output, metadata, index) == output

        reader = open(FASTA.Reader, output)
        records = try
            collect(reader)
        finally
            close(reader)
        end
        @test description.(records) == ["a alpha", "b beta"]
        @test sequence.(records) == ["ACGT", "GCTT"]
    end
end

@testset "end-to-end scaffolding" begin
    mktempdir() do directory
        input = joinpath(directory, "genome.fasta")
        index = joinpath(directory, "genome.fasta.fai")
        infofile = joinpath(directory, "info_contigs.txt")
        contactsfile = joinpath(directory, "contacts.bg2")
        output = joinpath(directory, "reoriented.fasta")

        write(input, ">A\nAAAA\n>B\nCCCCCC\n>C\nAAGC\n")
        write(index, "A\t4\t3\t4\t5\nB\t6\t11\t6\t7\nC\t4\t21\t4\t5\n")
        write(infofile, "contig\tlength\tn_frags\tcumul_length\nA\t4\t1\t0\nB\t6\t1\t4\nC\t4\t1\t10\n")
        write(contactsfile, "1\t1\t0\t3\t1\t0\t10\n")

        @test shh(
            genomeoutfile=output,
            genomeinfile=input,
            genomefaifile=index,
            bg2file=contactsfile,
            contiginfofile=infofile,
            hclust_linkage=:single,
            nthreads=2,
        ) == output

        reader = open(FASTA.Reader, output)
        identifiers = try
            identifier.(collect(reader))
        finally
            close(reader)
        end

        # A and C form the largest contact component; the unlinked contig B
        # must not be interleaved with them by the global clustering order.
        @test Set(identifiers[1:2]) == Set(["A", "C"])
        @test identifiers[3] == "B"
    end
end
