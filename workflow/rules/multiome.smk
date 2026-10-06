# ==================================================
# MULTIOME PIPELINE
# ==================================================

CELLRANGER_ARC_CONTAINER = "containers/cellranger-arc-2.1.0.sif"


# --------------------------------------------------
# GEX mkfastq
# --------------------------------------------------
if config["pipeline"] == "multiome":
    rule mkfastq_multiome_gex:
        input:
            raw_dir=config["samples"]["gex_raw_dir"],
            csv=config["samples"]["gex_csv"]

        output:
            directory("mkfastq_multiome_gex")

        container:
            CELLRANGER_ARC_CONTAINER

        shell:
            """
            cellranger-arc mkfastq \
                --id=mkfastq_multiome_gex \
                --run={input.raw_dir} \
                --csv={input.csv} \
                --output-dir=mkfastq_multiome_gex
            """


    # --------------------------------------------------
    # ATAC mkfastq
    # --------------------------------------------------

    rule mkfastq_multiome_atac:
        input:
            raw_dir=config["samples"]["atac_raw_dir"],
            csv=config["samples"]["atac_csv"]

        output:
            directory("mkfastq_multiome_atac")

        container:
            CELLRANGER_ARC_CONTAINER

        shell:
            """
            cellranger-arc mkfastq \
                --id=mkfastq_multiome_atac \
                --run={input.raw_dir} \
                --csv={input.csv} \
                --output-dir=mkfastq_multiome_atac
            """


    # --------------------------------------------------
    # Create sample-specific ARC libraries CSV
    # --------------------------------------------------

    rule get_fastq_paths_multiome:
        input:
            gex="mkfastq_multiome_gex",
            atac="mkfastq_multiome_atac"

        output:
            libraries="mkfastq_multiome_paths/{sample}_libraries.csv"

        run:
            sample = wildcards.sample

            gex_path = find_fastq_path(
                "mkfastq_multiome_gex",
                sample=None
            )

            atac_path = find_fastq_path(
                "mkfastq_multiome_atac",
                sample=sample
            )

            df = pd.DataFrame(
                {
                    "fastqs": [
                        gex_path,
                        atac_path
                    ],
                    "sample": [
                        sample,
                        sample
                    ],
                    "library_type": [
                        "Gene Expression",
                        "Chromatin Accessibility"
                    ]
                }
            )

            df.to_csv(
                output.libraries,
                index=False
            )


    # --------------------------------------------------
    # Cell Ranger ARC count
    # --------------------------------------------------

    rule count_multiome:
        input:
            library="mkfastq_multiome_paths/{sample}_libraries.csv",
            refdata=config["refdata"]

        output:
            directory("{sample}_count_multiome")

        container:
            CELLRANGER_ARC_CONTAINER

        shell:
            """
            cellranger-arc count \
                --id={wildcards.sample}_count_multiome \
                --libraries={input.library} \
                --create-bam=true \
                --reference={input.refdata} \
                --localcores=16 \
                --localmem=200
            """
