def sam2seg_params(wildcards):
    return sample_table.loc[wildcards.sample, "mode"]
rule sam2seg:
    input:
        rules.bwa_mem.output
    params:
        sam2seg_params
    output:
        os.path.join(ana_home, "seg","{sample}.seg.gz")
    log: log_path("sam2seg.log")
    threads: 1
    resources: nodes = 1
    message: " ------> sam2seg : {wildcards.sample}"
    script:
        "scripts/sam2seg.py"