module shhquis

using NamedArrays
using DelimitedFiles
using Clustering
using FASTX
using ArgParse

export
    #rexport from Clustering
    hclust,

    #from matrices
    coltodist, builddist,

    #from reorient
    ordernames, reorient, write_reorient

include("matrices.jl")
include("reorient.jl")

end # module
