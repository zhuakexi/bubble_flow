# for Hi-C
def bwa_mem_input(wildcards):
    R1 = rules.split.output.untrimmed_output
    R2 = rules.split.output.untrimmed_paired_output
    ref = sample_table.loc[wildcards.sample, "ref"] if "ref" in sample_table.columns else config["global_ref"]
    index = config["reference"]["bwa"][ref]
    return {"R1":R1, "R2":R2, "index": index}
rule bwa_mem:
    input:
        unpack(bwa_mem_input)
        #R1 = rules.split.output.untrimmed_output,
        #R2 = rules.split.output.untrimmed_paired_output
    output:
        os.path.join(ana_home,"hic_mapped","{sample}.sorted.bam")
    params:
        #index = config["reference"]["bwa"][sample_table.loc[snakemake.wildcards.sample,"ref"]],
        extra = r"-R '@RG\tID:{sample}\tPL:ILLUMINA\tSM:{sample}'"
    threads: 
        config["cpu"]["bwa_samsort"]
    resources:
        nodes = config["cpu"]["bwa_samsort"],
        partition = config["partition"]["bwa_samsort"],
        mem_per_cpu = config["mem_G"]["bwa_samsort"]
    log:
        log_path("bwa.log")
    message:
        " ---> bwa : {wildcards.sample} : {threads} cores"
    wrapper:
        # wrapper shipped with conda yaml
        #"https://gitee.com/zhuakexi/snakemake_wrappers/raw/v0.10/bwa_mem2"
        "file:wrappers/bwa_mem2"
rule add_mapping_rate:
    input:
        bam = rules.bwa_mem.output
    output:
        json = os.path.join(ana_home, f"{rd}", "{sample}.mapping_rate.json")
    conda:
        "../../envs/hires.yaml"
    threads: 1
    message: " ---> add_mapping_rate : {wildcards.sample}"
    script:
        "../../scripts/mapping_rate.py"
