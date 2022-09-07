def sam2seg_input(wildcards):
    # Read from sample_check to deduct sam2seg operation (whether using snp, etc.) 
    # to instruct as long as mode is not assigned in config or sample_table.csv

    # get mode_deduction from sample_check
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
    ref = sample_table.loc[wildcards.sample, "ref"]
    # get snp file
    # if no snp file, return some path any way since may don't need phasing in `mode`.
    snp_file = config["reference"]["snp"][ref] if ref in config["reference"]["snp"] else "NoSNPFile.txt"
    # if no par file, return some path any way since may don't need par filtering in `mode`.
    par_file = config["reference"]["par"][ref] if par in config["reference"]["par"] else "NoPARFile.txt"
    # return
    return {
        "sam" : rules.bwa_mem.output.get(sample = wildcards.sample).output[0],
        "mode_deduction" : mode_mapper[cell_state],
        "snp_file" : snp_file,
        "par_file" : par_file
    }
def sam2seg_params(wildcards):
    # read per sample mode assignment from sample_table.csv and config file.
    # sample_table.csv mask config file.
    # Require:
    #   `global_mode` key in config
    #   [optional] `mode` in sample_table.csv
    if "mode" in sample_table.columns:
        ploidy, sex, snp = [ e if e != "" else config["global_mode"].split("_")[i] for i, e in enumerate(sample_table.loc[wildcards.sample,"mode"].split("_")) ] 
        params =  "_".join([ploidy, sex, snp])
    else:
        params = config["global_mode"]
    ref = sample_table.loc[wildcards.sample, "ref"]
    if params.split("_")[2] == "SNP":
        if ref not in config["reference"]["snp"]:
            raise ValueError("no phased snp file for {}".format(ref))
    return params
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
        "scripts/sam2seg.py"