# shhquis
Scaffolds from Hifi and High QUalIty Sequences

A package for making your [hicstuff](https://github.com/koszullab/hicstuff) genomes look better. 

## Installation 

There are two main ways to install shhquis. The first method is to install shhquis through a general Julia package install, in this method accessing sshquis would be best done through `using shhquis` within an interactive Julia session or in a script or another package. This is generally how many other Julia packages look and behave. The other method is to utilize sshquis through it’s container. Helpfully, a bin file has been provided so that interacting with shhquis as a Singularity or Docker container is relatively painless. 

### Method One, As A Module

In the Julia shell:

```julia
using Pkg 
Pkg.add(url=https://github.com/molikd/Shhquis.jl)
```

### Method Two, As A Container

With singularity on a computational cluster this would look something like:

```bash
singularity pull shhquis.sif docker://dmolik/shhquis:latest #to build a .sif 
singularity exec shhquis.sif shh.jl
```
In docker you can use a docker pull:

```bash
docker pull dmolik/shhquis:latest
```

## Use 

There are two main ways that shhquis can be used, on the Command line and a package. The command line is done through the shh.jl file, if you are not using the containerized version of shhquis, then you can download this script at: 

https://raw.githubusercontent.com/molikd/Shhquis.jl/main/bin/shh.jl 

and put in your PATH.  Otherwise the script is bundled with the package upon installation. 

The other method of use is through the main function, ‘shh’ 

Both methods require the same files:

-	A genome file in fasta format 
-	A genome index file in fai format
-	A bg2 file (weighted contacts)
-	And a contig info file (contig	length	n_frags	cumul_length)

All of these, except the fai file are output of this packages intended underlying toolkit, HiC stuff: [hicstuff](https://github.com/koszullab/hicstuff)

### Running shh From Julia Terminal 

You can run shh from the Julia terminal in the following manner: 

```julia
shh(genomeoutfile="genome.reoriented.fasta",  genomeinfile ="genome.fasta", genomefaifile: ="genome.fasta.fai", bg2file= abs_fragments_contacts_weighted.bg2", contiginfofil ="info_contigs.txt")
```

### Running shh From bash Terminal 

 On the command line it would look like this:

```bash
shh.jl --reorient "genome.out.fasta" --genome "genome.fasta" --fai "genome.fasta.fai" --bg2 "abs_fragments_contacts_weighted.bg2" --contig "info_contigs.txt"
```



