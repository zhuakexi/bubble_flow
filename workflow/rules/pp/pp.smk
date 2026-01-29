rule count_reads:
    input:
        unpack(get_raw_fq)
    output:
        # dummy and backup information 
        os.path.join(ana_home,"info","{sample}.reads.info")
    threads: 1
    resources: 
        nodes = 1,
        io = config["io"]["heavy"],
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
rule store_raw_fq_path:
    input:
        unpack(get_raw_fq)
    output:
        os.path.join(ana_home,"rd","{sample}.raw_fq.json")
    threads: 1
    resources: nodes = 1,
    message: " ---> store_raw_fq_path : {wildcards.sample} : {threads} cores"
    run:
        import json
        import os
        raw_fq = {
            "R1_file": input.R1[0],
            "R2_file": input.R2 # R2[0] give "/" here, does not know why
        }
        data = {
            wildcards.sample: raw_fq
        }
        with open(output[0], 'w') as f:
            json.dump(data, f, indent=4)
        print(f"Raw fastq paths for {wildcards.sample} stored in {output[0]}")
rule split:
    input:
        unpack(get_raw_fq)
    output:
        untrimmed_output = os.path.join(ana_home,"DNA","{sample}_R1.fq.gz"),
        untrimmed_paired_output = os.path.join(ana_home,"DNA","{sample}_R2.fq.gz"),
        output = os.path.join(ana_home, "RNA", "{sample}_R1.fq.gz"),
        paired_output = os.path.join(ana_home, "RNA", "{sample}_R2.fq.gz")
    threads: config["cpu"]["split"]
    resources:
        nodes = config["cpu"]["split"],
        io = config["io"]["heavy"],
    params:
        # rna specific adapter
        # -G: trim R2, 5’ adapters
        # "XGGTTGAGGTAGTATTGCGCAATG;o=20": Anchored 5’ adapters (must be anchored to the 5’ end of the read), tolerance 3 mismatches
        adapter=' -G "XGGTTGAGGTAGTATTGCGCAATG;o=20" '
    log: log_path("split.log")
    message: "---> split : {wildcards.sample} : {threads} cores"
    wrapper:
        #"https://gitee.com/zhuakexi/snakemake_wrappers/raw/v0.10/cutadapt_pe_4o"
        "cutadapt_pe_4o"
rule count_dna_reads:
    input:
        # DNA_R1
        rules.split.output.untrimmed_output
    output:
        os.path.join(ana_home,"info","{sample}.dna_reads.info")
    threads: 1
    resources:
        nodes = 1,
        io = config["io"]["heavy"],
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
        nodes = 1,
        io = config["io"]["heavy"],
    message:
        " ---> count_rna_reads : {wildcards.sample} :{threads} cores"
    conda:"../../envs/hires.yaml"
    shell:
        """
        python {hires} gcount \
        -f pe_fastq -rd {rd} -sa {wildcards.sample} -at rna_reads {input} \
        1> {output}
        """