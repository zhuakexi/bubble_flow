def sex_conditional_build_each(wildcards):
    rep, sample = wildcards.rep, wildcards.sample
    with checkpoints.check_after_clean.get(sample = sample).output[0].open() as f:
        for line in f:
            if line.split(":")[0] == "cell_state":
                cell_state = line.split(":")[1].strip()
    if cell_state in ["dipfem", "dipmal"]:
        # all wildcards are str
        return os.path.join(ana_home, "3dg_c_dip", "%s.clean.20k.%s.3dg" % (sample, rep))
    if cell_state in ["hapfem", "hapmal", "unassigned"]:
        return os.path.join(ana_home, "3dg_c_hap", "%s.clean.20k.%s.3dg" % (sample, rep))
out_tp = os.path.join(ana_home, "cif", "{{sample}}.clean.{}.{{rep}}.cif")
rule cif:
    input:
        sex_conditional_build_each
    output:
        out_tp.format("20k")
    conda: "../envs/hires.yaml"
    resources: nodes = 1
    message: "---> vis : {wildcards.sample}.{wildcards.rep} : {resources.nodes}"
    shell:
        """
        python {hires} mmcif \
            -i {input} \
            -o {output} 
        """