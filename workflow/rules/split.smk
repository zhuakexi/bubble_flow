#1 step
#split DNA and RNA
import os
tp1 = os.path.join(config["dirs"]["dna"], "{{sample}}.{}.{}.gz")
tp2 = os.path.join(config["dirs"]["rna"], "{{sample}}.{}.{}.gz")
rule split:
    input:
        #expand( os.path.join(config["dirs"]["raw"],"{{sample}}/{{sample}}_{R}.fq.gz"), R=["R1", "R2"] )
        # order of R1 R2 is critical
        R1 = os.path.join(config["dirs"]["raw"], "{sample}/{sample}_R1.fq.gz"),
        R2 = os.path.join(config["dirs"]["raw"], "{sample}/{sample}_R2.fq.gz") 
    output:
        DNA_R1 = tp1.format("dna", "R1"),
        DNA_R2 = tp1.format("dna", "R2"),
        RNA_R1 = tp2.format("rna", "R1"),
        RNA_R2 = tp2.format("rna", "R2")
    threads: config["cpu"]["split"]
    resources: nodes = config["cpu"]["split"] 
    params:
        # rna specific adapter
        adapter=r"XGGTTGAGGTAGTATTGCGCAATG;o=20"
    #log: os.path.join(config["logs"], "{sample}", "split.log")
    log: config["logs"].format("split.log")
    message: "split : {wildcards.sample} : {threads} cores"
    conda:
        "../envs/prepare.yaml"
    shell:
        """
        cutadapt -G '{params.adapter}' -j {threads} \
        --untrimmed-output {output.DNA_R1} --untrimmed-paired-output {output.DNA_R2} \
        -o {output.RNA_R1} -p {output.RNA_R2} \
        {input.R1} {input.R2} 2>{log}
        """