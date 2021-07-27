#!/bin/sh
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
    end

    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
    println("Arguments:")
    for (arg,val) in parsed_args
        println("set  $arg  =>  $val")
    end
    
    shh(genomeoutfile=parsed_args["reorient"],
                genomeinfile=parsed_args["genome"],
                genomefaifile=parsed_args["fai"],
                bg2file=parsed_args["bg2"],
                contiginfofile=parsed_args["contig"]) 
end

main()
