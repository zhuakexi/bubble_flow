#cut out umi sequence; write umi sequence and cell name to sequence id
rule cut_round2:
    input:
        R1 = rules.split.output.output, #RNA_R1
        R2 = rules.split.output.paired_output #RNA_R2
    output:
        output = os.path.join(ana_home, "RNA_c", "{sample}_R1.fq.gz"),
        paired_output = os.path.join(ana_home, "RNA_c", "{sample}_R2.fq.gz")
    threads: config["cpu"]["cut_r2"]
    resources: nodes = config["cpu"]["cut_r2"]
    params: adapter=' -G "XNNNNNNNNTTTTTTTTTTTTTTT;o=18" '
    log: log_path("cut_round2.config")
    message: "---> cut_round2 : {wildcards.sample} : {threads} cores"
    wrapper:
        #"https://gitee.com/zhuakexi/snakemake_wrappers/raw/v0.10/cutadapt_pe_2o"
        "file:wrappers/cutadapt_pe_2o"
rule count_rna_c1_reads:
    # warning: this rule is not used in the pipeline
    # TODO: adding count_c2_reads
    input:
        # RNA_R1 after trim_cleaning
        rules.cut_round2.output.output
    output:
        os.path.join(ana_home,"info","{sample}.rna_c1_reads.info")
    threads: 1
    resources:
        nodes = 1
    message:
        " ---> count_rna_reads : {wildcards.sample} :{threads} cores"
    conda:"../../envs/hires.yaml"
    shell:
        """
        python {hires} gcount \
        -f pe_fastq -rd {rd} -sa {wildcards.sample} -at rna_c1_reads {input} \
        1> {output}
        """
rule extract_umi:
    input:
        RNA_R1 = rules.cut_round2.output.output,
        RNA_R2 = rules.cut_round2.output.paired_output
    output:
        umi1 = temp(os.path.join(ana_home, "umi", "umi.{sample}.rna.R1.fq.gz")),
        umi2 = temp(os.path.join(ana_home, "umi", "umi.{sample}.rna.R2.fq.gz"))
    resources:
        nodes = 1
    params:
        # umi pattern
        pattern = r"NNNNNNNN"
    log:
        log_path("extract_umi.log")
    message:
        "---> extract_umi : {wildcards.sample} : {threads} core"
    conda:
        "../../envs/rna_tools.yaml"
    shell:
        """
        umi_tools extract -p {params.pattern} -I {input.RNA_R2} -S {output.umi2} \
        --read2-in={input.RNA_R1} --read2-out={output.umi1} \
        $([[ {config[remove_id_suffix]} == true ]] && echo "--ignore-read-pair-suffixes") \
        2>&1 > {log}
        """
rule cut_round3:
    input:
        rules.extract_umi.output.umi1
    output:
        temp(os.path.join(ana_home, "RNA_cc", "{sample}_R1.fq.gz")),
    threads: config["cpu"]["cut_r3"]
    resources: nodes = config["cpu"]["cut_r3"]
    log: log_path("cut_round3.log")
    message: "---> cut_round3 : {wildcards.sample} : {threads} cores"
    conda: "../../envs/rna_tools.yaml"
    shell:
        """
        cutadapt -a CTGTCTCTTATA {input} -m 1 -j {threads} | sed 'N;N;N;/\\n\\n/d' | gzip > {output}
        """
rule count_rna_c2_reads:
    input:
        rules.cut_round3.output
    output:
        os.path.join(ana_home, "info", "{sample}.rna_c2_reads.info")
    threads: 1
    resources: nodes = 1
    message: "---> count_rna_c2_reads : {wildcards.sample} : {threads} cores"
    conda: "../../envs/hires.yaml"
    shell:
        """
        python {hires} gcount \
        -f pe_fastq -rd {rd} -sa {wildcards.sample} -at rna_c2_reads {input} \
        1> {output}
        """
rule fq2uBAM:
    input:
        rules.cut_round3.output
    output:
        temp(os.path.join(ana_home, "uBAM", "{sample}_R1.bam"))
    threads: 1
    resources: nodes = 1
    log: log_path("fq2uBAM.log")
    #message: "---> fq2uBAM : {wildcards.sample} : {threads} cores"
    conda: "../../envs/rna_tools.yaml"
    shell:
        # """
        # picard FastqToSam -F1 {input} -O {output} -SM {wildcards.sample} \
        #   --SORT_ORDER unsorted 2>&1 > {log}
        # """
        # transform only when not empty & not zero lines
        """
        if [[ -s {input} && $(zcat {input} | wc -c) -gt 0 ]]; then
        samtools view -b -o {output} {input}
        else
        echo -e "@HD\tVN:1.6\tSO:unknown" | samtools view -b --no-PG -o {output} -
        fi
        """
rule mend_umi:
    input:
        rules.fq2uBAM.output
    output:
        os.path.join(ana_home, "umi_uBAM", "{sample}.bam")
    threads: 5
    resources: nodes = 5
    log: log_path("mend_umi.log")
    message: "---> mend_umi : {wildcards.sample} : {threads} cores"
    conda: "../../envs/hires.yaml"
    shell:
        """
        python {hires} mend_umi -i {input} -o {output} 2>&1 > {log}
        """