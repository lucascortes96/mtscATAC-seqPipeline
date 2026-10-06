

# $1 is bam, $2 is barcodes $3 is output folder 
set -e
pwd
find . -maxdepth 3 -type f | sort
module load Java
module load R
module load Python/3.12.3-GCCcore-13.3.0
#pip install --user mgatk pysam
module load Pysam
mgatk tenx -i $1 -b $2 -bt CB -o $3
# mgatk tenx -i atac_possorted_bam.bam -b  filtered_feature_bc_matrix/barcodes.tsv -bt CB -o WBC063_mgatk_resequence