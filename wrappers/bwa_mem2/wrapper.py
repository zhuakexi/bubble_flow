""" Snakemake wrapper for bwa-mem """
__author__ = "Y Chi"
__copyright__ = "Copyright 2020, Y Chi"
__email__ = "zhuakexi@126.com"
__license__ = "MIT"
from snakemake.shell import shell
import os
extra = snakemake.params.get("extra")
threads = snakemake.threads
index = snakemake.params.index
input = snakemake.input
log = snakemake.log
output = snakemake.output

shell(
    " bwa-mem2 mem "
    " -5SP "
    " {extra} "
    " -t {threads} "
    " {index} "
    " {input.R1} {input.R2} " 
    " | samtools sort -@{threads} -o {output} - ; "
    " samtools index -@ {threads} {output} "
)