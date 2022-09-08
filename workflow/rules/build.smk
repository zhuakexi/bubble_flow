import os
def build_input(wildcards):
    """
    Input files for rule.build.
    Require:
        `mode` in sample_table.csv
    """
    _, _, _, _, build = get_assigned_mode(wildcards).split("_")
    mapper = {
        "c1b" : rules.clean1.output[0],
        "c12b" : rules.clean12.output[0],
        "c123b" : rules.clean123.output[0],
        "Ib" : rules.impute.output[0],
        "Icb" : rules.sep_clean.output["impute_c"]
    }
    if build == "NO":
        print("rule.build Warning: shouldn't execute this line")
    return mapper[build].format(sample = wildcards.sample)
def build_params(wildcards):
    """
    Input params for rule.build.
    """
    ploidy, _, _ = sam2seg_params(wildcards).split("_")
    return ploidy
tp = os.path.join(ana_home, "3dg", "{{sample}}.{}.{{rep}}.3dg")
rule build:
    # using output of pairs
    # no impute
    # don't need hickit -r1m xx, has better sep_clean
    input: build_input
    params: build_params
    output:
        _3dg_4m = tp.format("4m"),
        _3dg_1m = tp.format("1m"),
        _3dg_200k = tp.format("200k"),
        _3dg_50k = tp.format("50k"),
        _3dg_20k = tp.format("20k")
    log: log_path("build.{rep}.log")
    threads: 1
    resources: nodes = 1
    message: " ------> hickit build 3d : {wildcards.sample}.{wildcards.rep} : {threads} cores"
    script: "../scripts/sam2seg.py"