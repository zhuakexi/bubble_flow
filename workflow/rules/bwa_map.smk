import os
rule bwa_map:
    input:
        ref_genome = os.path.join(config["reference"]["bwa"], "genome.fa"),
        DNA_R1 = rules.split.output.DNA_R1,
        DNA_R2 = rules.split.output.DNA_R2
    output:
        protected( os.path.join(config["dirs"]["sam"], "{sample}.aln.sam.gz"))
    threads: 8
    resources: nodes = 8
    params: extra=r"-R '@RG\tID:{sample}\tPL:ILLUMINA\tSM:{sample}'"
    conda: "../envs/dna_tools.yaml"
    shell:
        """
        bwa mem -5SP -t{threads} {params.extra} {input.ref_genome} {input.DNA_R1} {input.DNA_R2} | gzip > {output}
        """
