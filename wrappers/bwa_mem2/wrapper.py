""" Snakemake wrapper for bwa-mem """
__author__ = "Y Chi"
__copyright__ = "Copyright 2020, Y Chi"
__email__ = "zhuakexi@126.com"
__license__ = "MIT"
from snakemake.shell import shell
import os
extra = snakemake.params.get("extra")
threads = snakemake.threads
#index = snakemake.params.index
index = snakemake.input.index
input = snakemake.input
log = snakemake.log
output = snakemake.output
bwa_threads = snakemake.config["cpu"]["bwa"]
samsort_threads = snakemake.config["cpu"]["samsort"]

shell(
    " bwa-mem2 mem "
    " -5SP "
    " {extra} "
    " -t {bwa_threads} "
    " {index} "
    " {input.R1} {input.R2} " 
    " | samtools sort -@{samsort_threads} -o {output} -O BAM - ; "
    " samtools index -@ {threads} {output} "
)