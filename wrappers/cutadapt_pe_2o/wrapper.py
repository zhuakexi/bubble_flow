""" Snakemake wrapper for cutadapt """
"""in paired mode, and discard untrimmed files"""
"""so you have to have 2 outputs by using this wrapper"""
__author__ = "Y Chi"
__copyright__ = "Copyright 2021, Y Chi"
__email__ = "zhuakexi@126.com"
__license__ = "MIT"

from snakemake.shell import shell
input = snakemake.input # the raw fasta file
log = snakemake.log # cutadapt log to stdout
output = snakemake.output.get("output")
paired_output = snakemake.output.get("paired_output")

adapter = snakemake.params.get("adapter")
threads = snakemake.threads

shell(
    "cutadapt"
    " --action=none --discard-untrimmed " 
    " {adapter} " # action + sequece
    " -j {threads} "
    " -o {output} "
    " -p {paired_output} "
    " {input.R1} {input.R2}"
    " 1> {log}"
)