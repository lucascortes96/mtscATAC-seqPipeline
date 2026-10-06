# -------------------------------------------------
# mgatk 
# -------------------------------------------------

if config["pipeline"] == "multiome":

    rule run_mgatk_multiome:
        input:
            count_multiome="{sample}_count_multiome",
            barcodes="{sample}_count_multiome/outs/filtered_feature_bc_matrix/barcodes.tsv"
        output:
            variant=f"{{sample}}_mgatk/final/mgatk.{base}.txt.gz",
            coverage="{sample}_mgatk/final/mgatk.coverage.txt.gz"
        shell:
            """
            bash workflow/scripts/mgatk.sh \
                {input.count_multiome}/outs/atac_possorted_bam.bam \
                {input.barcodes} \
                {wildcards.sample}_mgatk
            """


elif config["pipeline"] == "atac":

    rule run_mgatk_atac:
        input:
            count_atac="{sample}_count_atac",
            barcodes="{sample}_count_atac/outs/filtered_peak_bc_matrix/barcodes.tsv"
        output:
            variant=f"{{sample}}_mgatk/final/mgatk.{base}.txt.gz",
            coverage="{sample}_mgatk/final/mgatk.coverage.txt.gz"
        shell:
            """
            bash workflow/scripts/mgatk.sh \
                {input.count_atac}/outs/possorted_bam.bam \
                {input.barcodes} \
                {wildcards.sample}_mgatk
            """


rule variant_count:
    input:
        variant=f"{{sample}}_mgatk/final/mgatk.{base}.txt.gz",
        coverage="{sample}_mgatk/final/mgatk.coverage.txt.gz"
    output:
        "{sample}_mgatk/final/variant_fraction.txt"
    shell:
        """
        zcat {input.coverage} | awk -F',' -v pos="{position}" '
            $1 == pos {{ total += $3 }}
            END {{ print total }}
        ' > total.tmp

        zcat {input.variant} | awk -F',' -v pos="{position}" '
            $1 == pos {{ variant += $3 + $4 }}
            END {{ print variant }}
        ' > variant.tmp

        awk 'NR==FNR {{ total=$1; next }} {{ print ($1 / total) * 100 }}' \
            total.tmp variant.tmp > {output}

        rm total.tmp variant.tmp
        """
