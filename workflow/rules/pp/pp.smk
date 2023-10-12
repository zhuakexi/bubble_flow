rule count_reads:
    input:
        unpack(get_raw_fq)
    output:
        # dummy and backup information 
        os.path.join(ana_home,"info","{sample}.reads.info")
    threads: 1
    resources: 
        nodes = 1
    message:
        " ---> count_reads :{wildcards.sample} : {threads} cores"
    conda:"../../envs/hires.yaml"
    shell:
        """
        python {hires} gcount \
        -f pe_fastq -rd {rd} \
        -sa {wildcards.sample} -at raw_reads \
        {input.R1} 1> {output}
        """
rule split:
    input:
        unpack(get_raw_fq)
    output:
        untrimmed_output = os.path.join(ana_home,"DNA","{sample}_R1.fq.gz"),
        untrimmed_paired_output = os.path.join(ana_home,"DNA","{sample}_R2.fq.gz"),
        output = os.path.join(ana_home, "RNA", "{sample}_R1.fq.gz"),
        paired_output = os.path.join(ana_home, "RNA", "{sample}_R2.fq.gz")
    threads: config["cpu"]["split"]
    resources: nodes = config["cpu"]["split"] 
    params:
        # rna specific adapter
        adapter=' -G "XGGTTGAGGTAGTATTGCGCAATG;o=20" '
    log: log_path("split.log")
    message: "---> split : {wildcards.sample} : {threads} cores"
    wrapper:
        #"https://gitee.com/zhuakexi/snakemake_wrappers/raw/v0.10/cutadapt_pe_4o"
        "file:wrappers/cutadapt_pe_4o"
rule count_dna_reads:
    input:
        # DNA_R1
        rules.split.output.untrimmed_output
    output:
        os.path.join(ana_home,"info","{sample}.dna_reads.info")
    threads: 1
    resources:
        nodes = 1
    message:
        " ---> count_dna_reads : {wildcards.sample} :{threads} cores"
    conda:"../../envs/hires.yaml"
    shell:
        """
        python {hires} gcount \
        -f pe_fastq -rd {rd} -sa {wildcards.sample} -at dna_reads {input} \
        1> {output}
        """
rule count_rna_reads:
    input:
        # RNA_R1
        rules.split.output.output
    output:
        os.path.join(ana_home,"info","{sample}.rna_reads.info")
    threads: 1
    resources:
        nodes = 1
    message:
        " ---> count_rna_reads : {wildcards.sample} :{threads} cores"
    conda:"../../envs/hires.yaml"
    shell:
        """
        python {hires} gcount \
        -f pe_fastq -rd {rd} -sa {wildcards.sample} -at rna_reads {input} \
        1> {output}
        """