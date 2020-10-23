#cut out umi sequence; write umi sequence and cell name to sequence id
rule extract_umi:
    input:
        RNA_R1 = rules.cut_round2.output.RNA_R1,
        RNA_R2 = rules.cut_round2.output.RNA_R2
    output:
        umi1 = os.path.join(config["dirs"]["umi"], "umi.{sample}.rna.R1.fq.gz"),
        umi2 = os.path.join(config["dirs"]["umi"], "umi.{sample}.rna.R2.fq.gz")
    resources:
        nodes = 1
    params:
        #length of umi sequence
        pattern=r"NNNNNNNN"
    conda: "../envs/rna_tools.yaml"
    shell: 
        """
        umi_tools extract -p {params.pattern} -I {input.RNA_R2} -S {output.umi2} --read2-in={input.RNA_R1} --read2-out={output.umi1}
        """
rule extract_cell_name:
    input: rules.extract_umi.output.umi1
    output: os.path.join(config["dirs"]["umi_cell"], "umi.{sample}.rna.R1.fq")
    shell: "zcat {input} | sed 's/_/_{wildcards.sample}_/' > {output}"
