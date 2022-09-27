# for Hi-C
def bwa_mem_input(wildcards):
    R1 = rules.split.output.untrimmed_output
    R2 = rules.split.output.untrimmed_paired_output
    index = config["reference"]["bwa"][sample_table.loc[wildcards.sample,"ref"]]
    return {"R1":R1, "R2":R2, "index": index}
rule bwa_mem:
    input:
        unpack(bwa_mem_input)
        #R1 = rules.split.output.untrimmed_output,
        #R2 = rules.split.output.untrimmed_paired_output
    output:
        protected( os.path.join(ana_home,"sam","{sample}.aln.sam.gz"))
    params:
        #index = config["reference"]["bwa"][sample_table.loc[snakemake.wildcards.sample,"ref"]],
        extra = r"-R '@RG\tID:{sample}\tPL:ILLUMINA\tSM:{sample}'"
    threads: 
        config["cpu"]["bwa"]
    resources:
        nodes = config["cpu"]["bwa"]
    log:
        log_path("bwa.log")
    message:
        " ---> bwa : {wildcards.sample} : {threads} cores"
    wrapper:
        # wrapper shipped with conda yaml
        #"https://gitee.com/zhuakexi/snakemake_wrappers/raw/v0.10/bwa_mem2"
        "file:./wrappers/bwa_mem2"