rule cut_round2:
    input: rules.split.output.RNA_R1, rules.split.output.RNA_R2
    output:
        RNA_R1 = os.path.join(config["dirs"]["rna_c"], "{sample}.rna.clean.R1.fq.gz"),
        RNA_R2 = os.path.join(config["dirs"]["rna_c"], "{sample}.rna.clean.R2.fq.gz")    
    threads: 12
    resources: nodes = 12
    params: adapter=r"XNNNNNNNNTTTTTTTTTTTTTTT;o=18"
    log: os.path.join(config["logs"], "{sample}", "cut_round2")
    conda: "../envs/rna_tools.yaml"
    shell: "cutadapt --action=none --discard-untrimmed -G '{params.adapter}' -j {threads} -o {output.RNA_R1} -p {output.RNA_R2} {input} 1>> {log}"