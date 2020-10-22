localrules: merge_rna
rule merge_rna:
    input:
        expand("/share/Data/ychi/repo/RNA_all/umi.{sample}.rna.R1.fq", sample=SAMPLES)
    output:
        "/share/Data/ychi/repo/RNA_all/rnaAll.fq",
    message: "rna_merging: {SAMPLES}"
    shell:
        """
        cat {input} > {output}
        """
