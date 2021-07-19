""" Snakemake wrapper for count_reads """
__author__ = "Y Chi"
__copyright__ = "Copyright 2021, Y Chi"
__email__ = "zhuakexi@126.com"
__license__ = "MIT"
from snakemake.shell import shell
import os
extra = snakemake.params.get("extra")
input = snakemake.input
log = snakemake.log
output = snakemake.output

shell(
    " echo `zgrep -c $ {input.R1}` / 4 | bc 1> {output} "
)