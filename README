# mtscATAC-seqPipeline a Snakemake pipeline for mtscATAC-seq data processing
### Mainly used for mtscATAC-seq but can also be used for Multiome

This pipeline takes sequencing data and processes it using cellRanger to produce fastqs and then counts files. 
Fastqc is run on the fastq files and reports are generated automatically. Once the final CellRanger output folder is created, mgatk (https://github.com/caleblareau/mgatk)
is run on the resulting files. 

## Config
The config contains various parameter options for running the pipeline most importantly pipeline type. 
You can either run "atac" or "multiome"

## Sample Sheet
You must also create a sample sheet in line with CellRanger's parameters. Example sample sheets can be found in /workflow

