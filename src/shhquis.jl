module shhquis

using NamedArrays
using DelimitedFiles
using Clustering
using BioSequences
using FASTX

export
    #rexport from Clustering
    hclust,

    #from matrices
    coltodist, builddist,

    #from reorient
    ordernames, reorient, write_reorientfai

include("matrices.jl")
include("reorient.jl")

end # module
