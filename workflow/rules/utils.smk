# util functions
def log_path(file):
    return os.path.join(ana_home, "logs", "{sample}", file)
def get_assigned_sam2seg_mode(wildcards):
    # Read per sample mode assignment from sample_table.csv and config file.
    #   Sample_table.csv mask config file.
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