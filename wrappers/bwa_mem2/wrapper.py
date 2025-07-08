""" Snakemake wrapper for bwa-mem """
__author__ = "Y Chi"
__copyright__ = "Copyright 2020, Y Chi"
__email__ = "zhuakexi@126.com"
__license__ = "MIT"
from pathlib import Path
from snakemake.shell import shell
import os
extra = snakemake.params.get("extra")
threads = snakemake.threads
#index = snakemake.params.index
sample_name = snakemake.wildcards.sample
index = snakemake.input.index
input = snakemake.input
log = snakemake.log
output = snakemake.output
bwa_threads = snakemake.config["cpu"]["bwa"]
samsort_threads = snakemake.config["cpu"]["samsort"]
tmp_dir = Path(snakemake.config["ana_home"]) / "tmp"
# Check if tmp_dir exists, if not create it
Path(tmp_dir).mkdir(parents=True, exist_ok=True)

shell(
    " bwa-mem2 mem "
    " -5SP "
    " {extra} "
    " -t {bwa_threads} "
    " {index} "
    " {input.R1} {input.R2} " 
    " | samtools sort -@{samsort_threads} -o {output} -T {tmp_dir}/{sample_name}_bwa -O BAM - ; "
    " samtools index -@ {threads} {output} "
)