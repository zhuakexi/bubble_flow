def sex_conditional_build_all_rep(wildcards):
    sample = wildcards.sample
    with checkpoints.seg_stat.get(sample=sample).output[0].open() as f:
        for line in f:
            if line.split(":")[0] == "cell_state":
                cell_state = line.split(":")[1].strip()
        if cell_state in ["dipfem", "dipmal"]:
            return [os.path.join(ana_home, "3dg_c_dip", "%s.clean.20k.%d.3dg" % (sample, i)) for i in range(1,6)]
        if cell_state in ["hapfem", "hapmal", "unassigned"]:
            return [os.path.join(ana_home, "3dg_c_hap", "%s.clean.20k.%d.3dg" % (sample, i)) for i in range(1,6)]
rule rmsd:
    input:
        sex_conditional_build_all_rep
    output:
        os.path.join(ana_home, "rmsd", "{sample}.rmsd.info")
    conda: "../envs/hires.yaml"
    resources: nodes = 1
    message: "---> rmsd : {wildcards.sample} : {resources.nodes}"
    shell:
        """
        python {hires} rmsd -o {output} -rd {rd} {input}
        """