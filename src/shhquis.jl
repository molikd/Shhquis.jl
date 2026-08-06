module shhquis

using ArgParse
using Base.Threads
using BioSequences
using Clustering
using DelimitedFiles
using FASTX
using NamedArrays

include("matrices.jl")
include("ordering.jl")
include("reorient.jl")

const VALID_LINKAGES = (:single, :average, :complete, :ward, :ward_presquared)

"""
    shh(; genomeoutfile, genomeinfile, genomefaifile, bg2file,
          contiginfofile, hclust_linkage=:single, nthreads=Threads.nthreads())

Scaffold and orient a FASTA assembly from hicstuff contact data.

Linked contigs are grouped into contact components, the components are ordered
by total sequence length, and hierarchical clustering supplies the order within
each component. Contigs without contact evidence are written longest first.
"""
function shh(;
    genomeoutfile::AbstractString="genome.reoriented.fasta",
    genomeinfile::AbstractString="genome.fasta",
    genomefaifile::AbstractString="genome.fasta.fai",
    bg2file::AbstractString="abs_fragments_contacts_weighted.bg2",
    contiginfofile::AbstractString="info_contigs.txt",
    hclust_linkage::Symbol=:single,
    nthreads::Int=Threads.nthreads(),
)
    hclust_linkage in VALID_LINKAGES || throw(ArgumentError(
        "hclust_linkage must be one of $(join(string.(VALID_LINKAGES), ", "))",
    ))
    nthreads > 0 || throw(ArgumentError("nthreads must be positive"))

    names, lengths, _ = _read_contig_table(contiginfofile)
    contacts = builddist(contiginfofile, bg2file, nthreads)

    clustering_order = if length(names) == 1
        [1]
    else
        distances = contactdistances(contacts)
        hclust(distances; linkage=hclust_linkage, branchorder=:optimal).order
    end

    neworder = order_contigs(contacts, clustering_order, names, lengths)
    metadata = reorient(contiginfofile, bg2file, neworder)
    return write_reorient(genomeinfile, genomeoutfile, metadata, genomefaifile)
end

export
    builddist,
    coltodist,
    contactdistances,
    hclust,
    order_contigs,
    ordernames,
    reorient,
    shh,
    write_reorient

end # module
