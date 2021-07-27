module shhquis

using NamedArrays
using DelimitedFiles
using Clustering
using FASTX
using ArgParse

include("matrices.jl")
include("reorient.jl")

function shh(;genomeoutfile::AbstractString="genome.reoriented.fasta",
                    genomeinfile::AbstractString="genome.fasta",
                    genomefaifile::AbstractString="genome.fasta.fai",
                    bg2file::AbstractString="abs_fragments_contacts_weighted.bg2",
                    contiginfofile::AbstractString="info_contigs.txt")

   contiginfo = readdlm(contiginfofile, '\t', header=true)
   names = @view contiginfo[1,][:,1]

   dist = builddist(contiginfofile,bg2file)
   clustres = hclust(dist)
   neworder = ordernames(clustres.order,names)
   frinfo = reorient(contiginfofile,bg2file,neworder)
   write_reorient(genomeinfile,genomeoutfile,frinfo,genomefaifile)  

end

export
    #rexport from Clustering
    hclust,
    #from matrices
    coltodist, builddist,
    #from reorient
    ordernames, reorient, write_reorient,
    #from shhquis
    shh

end # module
