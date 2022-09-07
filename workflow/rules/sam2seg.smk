def sam2seg_input(wildcards):
    # Get input files for rule.sam2seg
    ## get snp file
    ## if no snp file, return some path any way since may don't need phasing in `mode`.
    ref = sample_table.loc[wildcards.sample, "ref"]
    snp_file = config["reference"]["snp"][ref] if ref in config["reference"]["snp"] else "NoSNPFile.txt"
    ## if no par file, return some path any way since may don't need par filtering in `mode`.
    par_file = config["reference"]["par"][ref] if ref in config["reference"]["par"] else "NoPARFile.txt"
    ## return
    return {
        #"sam" : rules.bwa_mem.output.get(sample = wildcards.sample).output[0],
        "sam" : rules.bwa_mem.output[0].format(sample = wildcards.sample),
        "snp_file" : snp_file,
        "par_file" : par_file
    }
def sam2seg_params(wildcards):
    # Get params for rule.sam2seg. Impose assigend and deducted mode.
    #   Read from sample_check to deduct sam2seg operation (whether using snp, etc.) 
    #   to instruct as long as mode is not assigned in config or sample_table.csv
    ## get  mode assignedin config files
    assigend_mode = get_assigned_sam2seg_mode(wildcards)
    ## deduct mode from sample feature.
    with checkpoints.sample_check.get(sample = wildcards.sample).output[0].open() as f:
        for line in f:
            if line.split(":")[0] == "cell_state":
                cell_state = line.split(":")[1].strip()
    mode_mapper = {
        "dipfem" : "2C_lY_",
        "dipmal" : "2C_hY_",
        "hapfem" : "1C_lY_",
        "hapmal" : "1C_hY_"
        }
    deducted_mode = mode_mapper[cell_state]
    ## params assignment first, if missing, using deduction
    final_mode = "_".join([ e if e != "" else deducted_mode.split("_")[i] for i, e in enumerate(assigend_mode.split("_")) ])
    return final_mode
rule sam2seg:
    input:
        unpack(sam2seg_input)
    params:
        sam2seg_params
    output:
        os.path.join(ana_home, "seg","{sample}.seg.gz")
    log: log_path("sam2seg.log")
    threads: 1
    resources: nodes = 1
    message: " ------> sam2seg : {wildcards.sample}"
    script:
        "../scripts/sam2seg.py"