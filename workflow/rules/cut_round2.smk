rule cut_round2:
    input: 
        RNA_R1 = rules.split.output.RNA_R1,
        RNA_R2 = rules.split.output.RNA_R2
    output:
        RNA_R1 = os.path.join(config["dirs"]["rna_c"], "{sample}.rna.clean.R1.fq.gz"),
        RNA_R2 = os.path.join(config["dirs"]["rna_c"], "{sample}.rna.clean.R2.fq.gz")    
    threads: config["cpu"]["cut_r2"]
    resources: nodes = config["cpu"]["cut_r2"]
    params: adapter=r"XNNNNNNNNTTTTTTTTTTTTTTT;o=18"
    log:
        result = config["result"].format("cut_round2.result") 
        log = config["logs"].format("cut_rounds2.log")
    message: "------> cut_round2 : {wildcards.sample} : {threads} cores"
    conda: "../envs/rna_tools.yaml"
    shell: 
        """
        cutadapt --action=none --discard-untrimmed \
        -G '{params.adapter}' -j {threads} -o {output.RNA_R1} -p {output.RNA_R2} \
        {input.R1} {input.R2} 1> {log.result} 2> {log.log}
        """