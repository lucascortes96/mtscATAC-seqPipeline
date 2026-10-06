#!/bin/sh
#SBATCH --account=rockhpc_spnmmd
#SBATCH --partition=long_paid
#SBATCH --time=80:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=200G
#SBATCH --job-name=2026_049_atac
#SBATCH --output=/nobackup/proj/rockhpc_spnmmd/LucasCortes/mtscATACseqPipeline/logs/%x_%j.out
#SBATCH --error=/nobackup/proj/rockhpc_spnmmd/LucasCortes/mtscATACseqPipeline/logs/%x_%j.err
module load snakemake 

snakemake --snakefile workflow/Snakefile all --printshellcmds --rerun-incomplete
