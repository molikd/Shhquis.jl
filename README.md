# Shhquis.jl

**S**caffolds from **H**iFi and **H**igh-**QU**al**I**ty **S**equences

[![CI](https://github.com/molikd/Shhquis.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/molikd/Shhquis.jl/actions/workflows/ci.yml)
[![DOI](https://zenodo.org/badge/386053190.svg)](https://zenodo.org/badge/latestdoi/386053190)

Shhquis uses weighted Hi-C contacts from [hicstuff](https://github.com/koszullab/hicstuff) to order and orient genome-assembly contigs. It can be used as a Julia package, from its command-line script, or as a Docker/Apptainer container.

## What the program does

1. Sums weighted contacts between each pair of contigs.
2. Converts contact strength to a clustering distance, so stronger contacts are closer.
3. Groups contigs into connected contact components.
4. Writes components from greatest to least total sequence length while retaining hierarchical-clustering order within each component.
5. Writes contigs without contact evidence from longest to shortest.
6. Uses contacts in the first and second halves of adjacent contigs to select forward or reverse-complement orientation.

This ordering keeps unrelated contigs from being interleaved solely because a clustering method must place every observation somewhere.

## Requirements

- Julia 1.10 or later (Julia 1.12 is the current tested release)
- a genome FASTA file and its `.fai` index
- hicstuff's `abs_fragments_contacts_weighted.bg2`
- hicstuff's `info_contigs.txt` (`contig`, `length`, `n_frags`, and `cumul_length`)

## Install as a Julia package

```julia
using Pkg
Pkg.add(url="https://github.com/molikd/Shhquis.jl")
```

Then run:

```julia
using shhquis

shh(
    genomeoutfile="genome.reoriented.fasta",
    genomeinfile="genome.fasta",
    genomefaifile="genome.fasta.fai",
    bg2file="abs_fragments_contacts_weighted.bg2",
    contiginfofile="info_contigs.txt",
    hclust_linkage=:single,
)
```

Supported linkage methods are `:single`, `:average`, `:complete`, `:ward`, and `:ward_presquared`.

## Command line

Download the script and place it on your `PATH`:

```bash
wget https://raw.githubusercontent.com/molikd/Shhquis.jl/main/bin/shh.jl -O shhquis
chmod +x shhquis
```

Run it against hicstuff output:

```bash
JULIA_NUM_THREADS=auto shhquis \
  --reorient genome.reoriented.fasta \
  --genome genome.fasta \
  --fai genome.fasta.fai \
  --bg2 abs_fragments_contacts_weighted.bg2 \
  --contig info_contigs.txt \
  --hclust-linkage single
```

`--threads` controls the maximum number of contact-aggregation tasks. Julia must also be started with multiple threads, using either `JULIA_NUM_THREADS` or Julia's `--threads` option, to run those tasks in parallel.

## Container

Tagged releases publish versioned images and `latest` to Docker Hub:

```bash
docker pull dmolik/shhquis:latest
docker run --rm -v "$PWD:/data" -w /data dmolik/shhquis:latest \
  --reorient genome.reoriented.fasta \
  --genome genome.fasta \
  --fai genome.fasta.fai \
  --bg2 abs_fragments_contacts_weighted.bg2 \
  --contig info_contigs.txt
```

On a cluster with Apptainer or Singularity:

```bash
apptainer pull shhquis.sif docker://dmolik/shhquis:latest
apptainer exec shhquis.sif shhquis --help
```

## Development and releases

Run the test suite with:

```julia
using Pkg
Pkg.test()
```

Pull requests and changes to `main` are tested on Julia 1.10 and 1.12, and the container is built without publishing it. To make a release, update `version` in `Project.toml` and push the matching tag (for example, `v0.2.0`). The release workflow verifies the version, runs the tests, publishes multi-architecture Docker images, and creates a GitHub release with generated notes.

## Citation and license

Use the Zenodo DOI above to cite Shhquis. The USDA-ARS-authored code is a United States Government Work; see [LICENSE](LICENSE) for the complete notice.
