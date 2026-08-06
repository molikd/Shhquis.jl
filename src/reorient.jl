"""Return `oldnames` in the index order supplied by a clustering result."""
function ordernames(neworder::AbstractVector{<:Integer}, oldnames::AbstractVector)
    return oldnames[neworder]
end

"""
    reorient(infofile, contactsfile, orderednames)

Choose a forward (`0`) or reverse-complement (`1`) orientation for each contig.
The decision compares contacts in the first and second half of each contig with
the preceding contig in the requested output order.
"""
function reorient(
    infofile::AbstractString,
    contactsfile::AbstractString,
    orderednames::AbstractVector,
)
    original_names, lengths, _ = _read_contig_table(infofile)
    output_names = string.(orderednames)
    Set(output_names) == Set(original_names) || throw(ArgumentError("orderednames must contain every input contig exactly once"))
    length(output_names) == length(original_names) || throw(ArgumentError("orderednames contains duplicate contigs"))

    ncontigs = length(output_names)
    metadata = NamedArray(
        zeros(Int64, ncontigs, 2),
        (output_names, ["splitp", "f/r"]),
        ("contig", "measurement"),
    )

    length_by_name = Dict(name => lengths[index] for (index, name) in enumerate(original_names))
    for name in output_names
        metadata[name, "splitp"] = fld(length_by_name[name], 2)
    end

    contacts = readdlm(contactsfile, '\t')
    size(contacts, 2) >= 7 || throw(ArgumentError("the bg2 contact table must have at least seven columns"))
    original_index = Dict(name => index for (index, name) in enumerate(original_names))
    output_index = Dict(name => index for (index, name) in enumerate(output_names))
    front = zeros(Float64, ncontigs, ncontigs)
    back = zeros(Float64, ncontigs, ncontigs)

    # Resolve numeric contact identifiers against the original contig table
    # before looking up their positions in the new scaffold order.
    for row in axes(contacts, 1)
        left_name = original_names[_contact_index(contacts[row, 1], original_index, ncontigs)]
        right_name = original_names[_contact_index(contacts[row, 4], original_index, ncontigs)]
        left = output_index[left_name]
        right = output_index[right_name]
        weight = Float64(contacts[row, 7])
        isfinite(weight) && weight >= 0 || throw(ArgumentError("contact weights must be finite and non-negative"))

        left_position = Float64(contacts[row, 2])
        right_position = Float64(contacts[row, 5])
        if left_position < metadata[left_name, "splitp"] && right_position < metadata[right_name, "splitp"]
            front[left, right] += weight
            left == right || (front[right, left] += weight)
        elseif left_position > metadata[left_name, "splitp"] && right_position > metadata[right_name, "splitp"]
            back[left, right] += weight
            left == right || (back[right, left] += weight)
        end
    end

    flipped = false
    for current in 2:ncontigs
        previous = current - 1
        if back[current, previous] > front[current, previous]
            # A stronger back-to-back signal changes the orientation relative
            # to the preceding contig; front-dominant evidence keeps it.
            flipped = !flipped
        elseif back[current, previous] == front[current, previous]
            metadata[output_names[current], "f/r"] = 0
            continue
        end
        metadata[output_names[current], "f/r"] = flipped ? 1 : 0
    end

    return metadata
end

"""
    write_reorient(genomefile, genomefileout, metadata, genomefaifile)

Write contigs in metadata order, reverse-complementing rows whose `f/r` value is
`1`. FASTA descriptions are preserved in the output.
"""
function write_reorient(
    genomefile::AbstractString,
    genomefileout::AbstractString,
    metadata::AbstractMatrix,
    genomefaifile::AbstractString,
)
    genomein = open(FASTA.Reader, genomefile; index=genomefaifile)
    genomeout = open(FASTA.Writer, genomefileout)
    contig_names = collect(names(metadata, 1))

    try
        for (row, name) in enumerate(contig_names)
            record = genomein[name]
            if metadata[row, 2] == 1
                dna = LongDNA{4}(sequence(record))
                reversed = String(reverse_complement(dna))
                write(genomeout, FASTA.Record(description(record), reversed))
            else
                write(genomeout, record)
            end
        end
    finally
        close(genomeout)
        close(genomein)
    end

    return genomefileout
end
