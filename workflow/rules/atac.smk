# ==================================================
# ATAC PIPELINE

# ==================================================

CELLRANGER_ATAC_CONTAINER = "containers/cellranger-atac-2.2.0.sif"
if config["pipeline"] == "atac":

    rule mkfastq_atac:
        input:
            raw_dir=config["samples"]["atac_raw_dir"],
            csv=config["samples"]["atac_csv"]

        output:
            directory("mkfastq_atac")
        container:
            CELLRANGER_ATAC_CONTAINER

        shell:
            """
            cellranger-atac mkfastq \
                --id=mkfastq_test \
                --run={input.raw_dir} \
                --csv={input.csv} \
                --output-dir=mkfastq_atac
            """


    rule get_fastq_paths_atac:
        input:
            "mkfastq_atac"

        output:
            fastq_paths="mkfastq_atac_paths/{sample}.txt"

        run:
            base_dir = os.path.abspath("mkfastq_atac")

            directories = next(os.walk(base_dir))[1]

            fastq_directories = [
                directory
                for directory in directories
                if directory.startswith("H")
            ]

            if not fastq_directories:
                raise FileNotFoundError(
                    f"No H* FASTQ directory found in {base_dir}"
                )

            fastq_directory = fastq_directories[0]

            fastq_path = os.path.join(
                base_dir,
                fastq_directory,
                wildcards.sample
            )

            with open(output.fastq_paths, "w") as file_handle:
                file_handle.write(f"{fastq_path}\n")


    rule normalize_fastqs_atac:
        input:
            fastq_paths="mkfastq_atac_paths/{sample}.txt"

        output:
            normalized="mkfastq_atac_paths/{sample}.renamed"

        run:
            with open(input.fastq_paths) as file_handle:
                fastq_dir = file_handle.readline().strip()

            fastq_files = os.listdir(fastq_dir)
            read3_files = sorted(
                filename
                for filename in fastq_files
                if filename.endswith("_R3_001.fastq.gz")
            )

            if read3_files:
                for source_r3 in read3_files:
                    destination_r2 = source_r3.replace(
                        "_R3_001.fastq.gz", "_R2_001.fastq.gz"
                    )
                    destination_i2 = source_r3.replace(
                        "_R3_001.fastq.gz", "_I2_001.fastq.gz"
                    )
                    path_r2 = os.path.join(fastq_dir, destination_r2)
                    path_i2 = os.path.join(fastq_dir, destination_i2)

                    if os.path.exists(path_r2) and os.path.exists(path_i2):
                        raise FileExistsError(
                            f"Cannot rename {source_r3}: both R2 and I2 files exist"
                        )
                    if not os.path.exists(path_r2) and not os.path.exists(path_i2):
                        raise FileNotFoundError(
                            f"Expected paired R2 or I2 FASTQ for {source_r3}"
                        )

                for source_r3 in read3_files:
                    destination_r2 = source_r3.replace(
                        "_R3_001.fastq.gz", "_R2_001.fastq.gz"
                    )
                    destination_i2 = source_r3.replace(
                        "_R3_001.fastq.gz", "_I2_001.fastq.gz"
                    )
                    path_r2 = os.path.join(fastq_dir, destination_r2)
                    path_i2 = os.path.join(fastq_dir, destination_i2)

                    if os.path.exists(path_r2):
                        os.rename(path_r2, path_i2)

                for source_r3 in read3_files:
                    destination_r2 = source_r3.replace(
                        "_R3_001.fastq.gz", "_R2_001.fastq.gz"
                    )
                    os.rename(
                        os.path.join(fastq_dir, source_r3),
                        os.path.join(fastq_dir, destination_r2)
                    )
            elif not any(
                filename.endswith("_I2_001.fastq.gz") for filename in fastq_files
            ):
                raise FileNotFoundError(
                    f"No R3 FASTQs to rename and no normalized I2 FASTQs found in {fastq_dir}"
                )

            with open(output.normalized, "w") as file_handle:
                file_handle.write(f"{fastq_dir}\n")


    rule fastqc_atac:
        input:
            fastq_paths="mkfastq_atac_paths/{sample}.txt",
            normalized="mkfastq_atac_paths/{sample}.renamed"

        output:
            qc_done="mkfastq_atac_paths/{sample}.fastqc.done"

        threads: 4

        shell:
            """
            FASTQ_DIR=$(cat {input.fastq_paths})
            mkdir -p "$FASTQ_DIR/fastqc"

            fastqc \
                --threads {threads} \
                --force \
                --outdir "$FASTQ_DIR/fastqc" \
                "$FASTQ_DIR"/*.fastq.gz

            touch {output.qc_done}
            """


    rule count_atac:
        input:
            fastqs="mkfastq_atac_paths/{sample}.txt",
            fastqc="mkfastq_atac_paths/{sample}.fastqc.done",
            refdata=config["refdata"]

        output:
            directory("{sample}_count_atac")
            
        container:
            CELLRANGER_ATAC_CONTAINER

        shell:
            """
            FASTQ_DIR=$(cat {input.fastqs})
            FASTQ_DIR=$(realpath "$FASTQ_DIR")

            cellranger-atac count \
                --id={wildcards.sample}_count_atac \
                --fastqs="$FASTQ_DIR" \
                --sample={wildcards.sample} \
                --reference={input.refdata} \
                # --chemistry=ARC-v1
                
            """
