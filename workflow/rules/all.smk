# --------------------------------------------------
# Rule all
# --------------------------------------------------

if config["pipeline"] == "atac":

    rule all:
        input:
            expand(
                "{sample}_mgatk/final/variant_fraction.txt",
                sample=SAMPLES
            )
        default_target: True


elif config["pipeline"] == "multiome":

    rule all:
        input:
            expand(
                "{sample}_mgatk/final/variant_fraction.txt",
                sample=SAMPLES
            )
        default_target: True
