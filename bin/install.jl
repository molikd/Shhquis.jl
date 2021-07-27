#!/bin/bash
#=
exec julia --color=yes --startup-file=no -e 'include(popfirst!(ARGS))' \
    "${BASH_SOURCE[0]}" "$@"
=#

using Pkg
pkg"add NamedArrays"
pkg"add DelimitedFiles"
pkg"add Clustering"
pkg"add FASTX"
pkg"add ArgParse"
pkg"precompile"
pkg"gc"
