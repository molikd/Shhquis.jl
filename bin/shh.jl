#!/bin/bash
#=
exec julia --color=yes --startup-file=no -e 'include(popfirst!(ARGS))' \
    "${BASH_SOURCE[0]}" "$@"
=#

using shhquis
using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--reorient"
            help = "where to put the reoriented genome"
            arg_type = String
            required = true
        "--genome"
            help = "the genome fasta file"
            arg_type = String
            required = true
        "--fai"
            help = "the genome fai file"
            arg_type = String
            required = true
        "--bg2"
            help = "the bg2 file"
            arg_type = String
            required = true
        "--contig"
            help = "the info_contigs.txt file"
            arg_type = String
            required = true
        "--hclust-linkage"
            help = "linkage is one of single, average, complete, ward, ward_presquared"
            arg_type = String
            required = false
    end

    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
    println("Arguments:")
    for (arg,val) in parsed_args
        println("set  $arg  =>  $val")
    end

    reorient = parsed_args["reorient"]
    genome = parsed_args["genome"]
    fai = parsed_args["fai"]
    bg2 = parsed_args["bg2"]
    contig = parsed_args["contig"]


    if parsed_args["hclust-linkage"] != nothing
        hclust_algo = parsed_args["hclust-linkage"]

        if hclust_algo == "single"
            hclust_sym = :single
        elseif hclust_algo == "average"
            hclust_sym = :average
        elseif hclust_algo == "complete"
            hclust_sym = :complete
        elseif hclust_linkage == "ward"
            hclust_sym = :ward
        elseif hclust_linkage == "ward_presquared"
            hclust_sym = :ward_presquared
        else
            error("not a real hclust linkage type")
            exit(code=1)
        end

        shh(genomeoutfile=parsed_args["reorient"],
            genomeinfile=parsed_args["genome"],
            genomefaifile=parsed_args["fai"],
            bg2file=parsed_args["bg2"],
            contiginfofile=parsed_args["contig"],
            hclust_linkage=hclust_sym)
    else
        shh(genomeoutfile=parsed_args["reorient"],
            genomeinfile=parsed_args["genome"],
            genomefaifile=parsed_args["fai"],
            bg2file=parsed_args["bg2"],
            contiginfofile=parsed_args["contig"])
    end

end

main()
