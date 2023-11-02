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
        "Ib" : rules.impute.output[0], # don't do this, clean3 will give blank output
        "Icb" : rules.sep_clean.output["impute_c"] # for hickit compatibility
        # impute_c hasn't been split, but has all the prob cols, dip file is the split version of impute_c
        # let hickit do the split of homologous chromosomes here, otherwise it throws error
        # hires_utils:sep_clean hacks impute_c file to make hickit's split same as it's dip file
    }
    if build == "NO":
        print("rule.build Warning: shouldn't execute this line")
    return {
        "pairs" : mapper[build].format(sample = wildcards.sample),
        # build_params call sam2seg_params which using checkpoint, so input must also have that checkpoint file
        # by snakemake rule
        "checkpoint" : checkpoints.sample_check.get(sample = wildcards.sample).output[0]
    }
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
    input: unpack(build_input)
    params: build_params
    output:
        _3dg_4m = tp.format("4m"),
        _3dg_1m = tp.format("1m"),
        _3dg_200k = tp.format("200k"),
        _3dg_50k = tp.format("50k"),
        _3dg_20k = tp.format("20k")
    log: log_path("build.{rep}.log")
    threads: 1
    resources:
        nodes = 1,
        runtime = 300
    message: " ------> hickit build 3d : {wildcards.sample}.{wildcards.rep} : {threads} cores"
    script: "../../scripts/build.py"
# rescale and clean built 3d structures
def clean3d_input(wildcards):
    """
    Input files for rule.clean3d.
    Require:
        `mode` in sample_table.csv
    """
    _, _, _, _, build = get_assigned_mode(wildcards).split("_")
    mapper = {
        "c1b" : rules.clean1.output[0],
        "c12b" : rules.clean12.output[0],
        "c123b" : rules.clean123.output[0],
        "Ib" : rules.impute.output[0],
        "Icb" : rules.sep_clean.output["dip"] # use dip file as ref, because input 3dg at this step is split version
    }
    inputs = {
        "_3dg" : os.path.join(ana_home, "3dg", "{sample}.{reso}.{rep}.3dg"),
        # can't call build_input here because it will call sam2seg_params which using checkpoint
        # but clean3d is not conditional, it only depends on mode string.
        "pairs" : mapper[build].format(sample = wildcards.sample)
    }
    return inputs
rule clean3d:
    input:
        unpack(clean3d_input)
    output: os.path.join(ana_home, "3dg_c", "{sample}.clean.{reso}.{rep}.3dg")
    conda: "../../envs/hires.yaml"
    threads: 1
    resources: nodes = 1
    message: " ------> clean3d : {wildcards.sample}"
    shell:
        """
        python {hires} clean3 \
            -i {input._3dg} \
            -r {input.pairs} \
            -o {output}
        """
rule rmsd:
    # calculate r.m.s.d of *cleaned* 3d structures
    input:
        [os.path.join(ana_home, "3dg_c", "{{sample}}.clean.{{reso}}.{rep}.3dg").format(rep=i) for i in range(1,6)]
    output:
        os.path.join(ana_home, "rmsd", "{sample}.{reso}.rmsd.info")
    conda: "../../envs/hires.yaml"
    threads: 1
    resources: nodes = 1
    message: "---> rmsd : {wildcards.sample} : {resources.nodes}"
    shell:
        """
        python {hires} rmsd -o {output} -at {wildcards.reso}_ -rd {rd} {input}
        """
rule cif:
    input:
        rules.clean3d.output
    output:
        os.path.join(ana_home, "cif", "{sample}.{reso}.{rep}.cif")
    conda: "../../envs/hires.yaml"
    threads: 1
    resources: nodes = 1
    message: "---> vis : {wildcards.sample}.{wildcards.rep} : {resources.nodes}"
    shell:
        """
        python {hires} mmcif \
            -i {input} \
            -o {output} 
        """