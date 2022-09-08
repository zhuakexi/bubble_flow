import os
def impute_input(wildcards):
    """
    Decide which pairs to impute on.
    """
    _, _, _, impute, _ = get_assigned_mode(wildcards).split("_")
    mapper = {
        "c1i" : rules.clean1.output[0],
        "c12i" : rules.clean12.output[0],
        "c123i" : rules.clean123.output[0]
    }
    if impute == "NO":
        print("rule.impute Warning: shouldn't execute this line, group_impute may be failed.")
    return mapper[impute].format(sample = wildcards.sample)
rule impute:
    input: impute_input
    output:
        impute_pairs = os.path.join(ana_home, "impute", "{sample}.impute.pairs.gz"),
        impute_val = os.path.join(ana_home, "impute", "{sample}.impute.val")
    threads: 1
    resources: nodes = 1
    log:
        log_path("impute.log") 
    message: "impute: {wildcards.sample} : {threads} cores"
    shell:
        """
        # impute phases
        {hickit} -i {input} -u -o - 2> {log} | gzip > {output.impute_pairs}
        # estimate imputation accuracy by holdout
        {hickit} -i {input} --out-val={output.impute_val} 2>> {log}
        """
rule sep_clean:
    input: rules.impute.output.impute_pairs
    output:
        dip = os.path.join(ana_home, "dip", "{sample}.dip.pairs.gz"),
        impute_c = os.path.join(ana_home, "impute_c", "{sample}.impute_c.pairs.gz")
    threads: config["cpu"]["clean2"]
    resources: nodes = config["cpu"]["clean2"]
    log:
        log=log_path("sep_clean.log"),
        result=log_path("sep_clean.result")
    conda: "../envs/hires.yaml" 
    message: " ------> sep_clean: {wildcards.sample} : {threads} cores"
    shell:
        """
        python3 {hires} sep_clean -n {threads} -o1 {output.dip} -o2 {output.impute_c} {input} 2> {log.log} 1>{log.result}
        """