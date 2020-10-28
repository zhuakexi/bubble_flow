#2 step
#map DNA reads to reference genome
import os
rule bwa_map:
    input:
        ref_genome = os.path.join(config["reference"]["bwa"], "genome.fa"),
        DNA_R1 = rules.split.output.DNA_R1,
        DNA_R2 = rules.split.output.DNA_R2
    output:
        protected( os.path.join(config["dirs"]["sam"], "{sample}.aln.sam.gz"))
    threads: config["cpu"]["bwa"]
    resources: nodes = config["cpu"]["bwa"]
    params: extra=r"-R '@RG\tID:{sample}\tPL:ILLUMINA\tSM:{sample}'"
    log: config["logs"].format("bwa.log")
    message: "bwa : {wildcards.sample} : {threads} cores"
    conda: "../envs/dna_tools.yaml"
    shell:
        """
        bwa mem -5SP -t{threads} {params.extra} {input.ref_genome} {input.DNA_R1} {input.DNA_R2} 2> {log} | gzip > {output}
        """
