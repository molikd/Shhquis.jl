#!/bin/bash
#=
exec julia --color=yes --startup-file=no -e 'include(popfirst!(ARGS))' \
    "${BASH_SOURCE[0]}" "$@"
=#

#using shhquis
using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
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
        "--hclust"
            help = "hclust algorithm"
            default = "single"
    end

    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
    println("Parsed args:")
    for (arg,val) in parsed_args
        println("  $arg  =>  $val")
    end
end

main()
