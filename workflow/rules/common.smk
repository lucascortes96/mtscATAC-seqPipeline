import os
import pandas as pd


# --------------------------------------------------
# Samples
# --------------------------------------------------
if config["pipeline"] == "multiome":
    SAMPLESHEET = pd.read_csv(config["samples"]["gex_csv"])
else:
    SAMPLESHEET = pd.read_csv(config["samples"]["atac_csv"])


# Remove accidental whitespace from sample names
SAMPLESHEET["Sample"] = (
    SAMPLESHEET["Sample"]
    .astype(str)
    .str.strip()
)

SAMPLES = SAMPLESHEET["Sample"].unique().tolist()
print("DEBUG SAMPLES:", SAMPLES)

#---------------------------------------------------
# Variant 
#---------------------------------------------------
position = config['variant']['position']
base = config['variant']['base']


# --------------------------------------------------
# Helper functions
# --------------------------------------------------

def find_fastq_path(base_dir, sample=None):
    base_dir = os.path.abspath(base_dir)

    if not os.path.isdir(base_dir):
        raise FileNotFoundError(
            f"Directory does not exist: {base_dir}"
        )

    # Find H* directory
    directories = next(os.walk(base_dir))[1]

    fastq_directories = [
        directory
        for directory in directories
        if directory.startswith("H")
    ]

    if not fastq_directories:
        raise FileNotFoundError(
            f"No H* directory found in {base_dir}"
        )

    if len(fastq_directories) > 1:
        raise ValueError(
            f"Found multiple H* directories in {base_dir}: "
            f"{fastq_directories}"
        )

    flowcell_dir = os.path.join(
        base_dir,
        fastq_directories[0]
    )

    # If sample is provided, look inside H*/sample
    if sample is not None:
        sample_dir = os.path.join(
            flowcell_dir,
            sample
        )

        if os.path.isdir(sample_dir):
            return sample_dir

    # Otherwise, use the H* directory itself
    return flowcell_dir
