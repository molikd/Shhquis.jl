#!/bin/bash
#=
exec julia --color=yes --startup-file=no -e 'include(popfirst!(ARGS))' \
    "${BASH_SOURCE[0]}" "$@"
=#

using ArgParse
using Base.Threads
using shhquis

function parse_commandline()
    settings = ArgParseSettings(
        description="Scaffold and orient a FASTA assembly from hicstuff contact data.",
    )

    @add_arg_table settings begin
        "--reorient"
            help = "output path for the reoriented FASTA"
            arg_type = String
            required = true
        "--genome"
            help = "input genome FASTA"
            arg_type = String
            required = true
        "--fai"
            help = "FAI index for the input genome"
            arg_type = String
            required = true
        "--bg2"
            help = "hicstuff weighted-contact bg2 file"
            arg_type = String
            required = true
        "--contig"
            help = "hicstuff info_contigs.txt file"
            arg_type = String
            required = true
        "--hclust-linkage"
            help = "single, average, complete, ward, or ward_presquared"
            arg_type = String
            default = "single"
        "--threads"
            help = "maximum worker tasks (start Julia with --threads or JULIA_NUM_THREADS)"
            arg_type = Int
            default = Threads.nthreads()
    end

    return parse_args(settings)
end

function main()
    arguments = parse_commandline()
    linkage = Symbol(arguments["hclust-linkage"])

    shh(
        genomeoutfile=arguments["reorient"],
        genomeinfile=arguments["genome"],
        genomefaifile=arguments["fai"],
        bg2file=arguments["bg2"],
        contiginfofile=arguments["contig"],
        hclust_linkage=linkage,
        nthreads=arguments["threads"],
    )
end

main()
