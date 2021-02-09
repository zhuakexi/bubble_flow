#cut out umi sequence; write umi sequence and cell name to sequence id
rule extract_umi:
    input:
        RNA_R1 = rules.cut_round2.output.output,
        RNA_R2 = rules.cut_round2.output.paired_output
    output:
        umi1 = os.path.join(ana_home, "umi", "umi.{sample}.rna.R1.fq.gz"),
        umi2 = os.path.join(ana_home, "umi", "umi.{sample}.rna.R2.fq.gz")
    resources: nodes = 1
    params:
        # umi pattern
        pattern=r"NNNNNNNN"
    log: config["logs"].format("extract_umi.log")
    message: "---> extract_umi : {wildcards.sample} : {threads} core"
    conda: "../envs/rna_tools.yaml"
    shell: "umi_tools extract -p {params.pattern} -I {input.RNA_R2} -S {output.umi2} --read2-in={input.RNA_R1} --read2-out={output.umi1} 2> {log}"
        
rule extract_cell_name:
    input: rules.extract_umi.output.umi1
    output: os.path.join(ana_home, "umi_cell", "cell.umi.{sample}.rna.R1.fq")
    message: "extract_cell_name : {wildcards.sample} : {threads} core"
    shell: "zcat {input} | sed 's/_/_{wildcards.sample}_/' > {output}"
