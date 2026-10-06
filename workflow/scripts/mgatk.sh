#!/usr/bin/env bash
# $1 is bam, $2 is barcodes $3 is output folder 
set -euo pipefail

bam=$(realpath "$1")
barcodes=$(realpath "$2")
outdir=$3

module load Java
module load R
module load Python/3.12.3-GCCcore-13.3.0
module load Pysam

# Have to run mgatk from the outdir because the snakemake pipeline has 
# a lock on the project root directory and mgatk will not run, as it also
# uses snakemake 
mkdir -p "$outdir"
cd "$outdir"
mgatk tenx -i "$bam" -b "$barcodes" -bt CB -o .
# mgatk tenx -i atac_possorted_bam.bam -b  filtered_feature_bc_matrix/barcodes.tsv -bt CB -o WBC063_mgatk_resequence