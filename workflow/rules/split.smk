#split DNA and RNA
rule split:
    input:
        expand( os.path.join(config["dirs"]["raw"],"{{sample}}/{{sample}}_{R}.fq.gz"), R=["R1", "R2"] ) 
    output:
        DNA_R1 = os.path.join(config["dirs"]["dna"], "{sample}.dna.R1.gz"),
        DNA_R2 = os.path.join(config["dirs"]["dna"], "{sample}.dna.R2.gz"),
        RNA_R1 = os.path.join(config["dirs"]["dna"], "{sample}.rna.R1.gz"),
        RNA_R2 = os.path.join(config["dirs"]["dna"], "{sample}.rna.R2.gz")
    threads: 8
    resources:
        nodes = 8 
    params:
        adapter=r"XGGTTGAGGTAGTATTGCGCAATG;o=20"
    conda:
        "workflow/envs/cutadapt.yaml"
    shell:
        """
        cutadapt -G '{params.adapter}' -j {threads} \
        --untrimmed-output {output.DNA_R1} --untrimmed-paired-output {output.DNA_R2} \
        -o {output.RNA_R1} -p {output.RNA_R2} \
        {input}
        """