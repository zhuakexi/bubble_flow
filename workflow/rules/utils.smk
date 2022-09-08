# util functions
def log_path(file):
    return os.path.join(ana_home, "logs", "{sample}", file)
def get_assigned_mode(wildcards):
    """
    Read per sample mode assignment from sample_table.csv and config file.
       Sample_table.csv mask config file.
    Require:
       `global_mode` key in config
       [optional] `mode` in sample_table.csv
    Note:
        mode: ploidy_sex_snp_imputation_build
        imputation: 
        build: c1b, c12b, c123b, Ib, Icb
    """
    if "mode" in sample_table.columns:
        ## have per sample assigned mode
        params =  "_".join([ e if e != "" else config["global_mode"].split("_")[i] for i, e in enumerate(sample_table.loc[wildcards.sample,"mode"].split("_")) ])
    else:
        ## rely on global mode
        params = config["global_mode"]
    # check mode compatibility
    ref = sample_table.loc[wildcards.sample, "ref"]
    if params.split("_")[2] == "SNP":
        if ref not in config["reference"]["snp"]:
            raise ValueError("no phased snp file for {}".format(ref))
    return params
hires = config["software"]["hires"]