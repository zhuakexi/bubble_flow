def sex_conditional_build_all_rep(wildcards):
    sample = wildcards.sample
    with checkpoints.check_after_clean.get(sample=sample).output[0].open() as f:
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
        python {hires} rmsd -o {output} -at 20k_ -rd {rd} {input}
        """
def sex_conditional_build_all_rep_50k(wildcards):
    sample = wildcards.sample
    with checkpoints.check_after_clean.get(sample=sample).output[0].open() as f:
        for line in f:
            if line.split(":")[0] == "cell_state":
                cell_state = line.split(":")[1].strip()
        if cell_state in ["dipfem", "dipmal"]:
            return [os.path.join(ana_home, "3dg_c_dip", "%s.clean.50k.%d.3dg" % (sample, i)) for i in range(1,6)]
        if cell_state in ["hapfem", "hapmal", "unassigned"]:
            return [os.path.join(ana_home, "3dg_c_hap", "%s.clean.50k.%d.3dg" % (sample, i)) for i in range(1,6)]
rule rmsd_50k:
    input:
        sex_conditional_build_all_rep_50k
    output:
        os.path.join(ana_home, "rmsd", "{sample}.rmsd.50k.info")
    conda: "../envs/hires.yaml"
    resources: nodes = 1
    message: "---> rmsd : {wildcards.sample} : {resources.nodes}"
    shell:
        """
        python {hires} rmsd -o {output} -rd {rd} -at 50k_  {input}
        """
def sex_conditional_build_all_rep_200k(wildcards):
    sample = wildcards.sample
    with checkpoints.check_after_clean.get(sample=sample).output[0].open() as f:
        for line in f:
            if line.split(":")[0] == "cell_state":
                cell_state = line.split(":")[1].strip()
        if cell_state in ["dipfem", "dipmal"]:
            return [os.path.join(ana_home, "3dg_c_dip", "%s.clean.200k.%d.3dg" % (sample, i)) for i in range(1,6)]
        if cell_state in ["hapfem", "hapmal", "unassigned"]:
            return [os.path.join(ana_home, "3dg_c_hap", "%s.clean.200k.%d.3dg" % (sample, i)) for i in range(1,6)]
rule rmsd_200k:
    input:
        sex_conditional_build_all_rep_200k
    output:
        os.path.join(ana_home, "rmsd", "{sample}.rmsd.200k.info")
    conda: "../envs/hires.yaml"
    resources: nodes = 1
    message: "---> rmsd : {wildcards.sample} : {resources.nodes}"
    shell:
        """
        python {hires} rmsd -o {output} -rd {rd} -at 200k_  {input}
        """
def sex_conditional_build_all_rep_1m(wildcards):
    sample = wildcards.sample
    with checkpoints.check_after_clean.get(sample=sample).output[0].open() as f:
        for line in f:
            if line.split(":")[0] == "cell_state":
                cell_state = line.split(":")[1].strip()
        if cell_state in ["dipfem", "dipmal"]:
            return [os.path.join(ana_home, "3dg_c_dip", "%s.clean.1m.%d.3dg" % (sample, i)) for i in range(1,6)]
        if cell_state in ["hapfem", "hapmal", "unassigned"]:
            return [os.path.join(ana_home, "3dg_c_hap", "%s.clean.1m.%d.3dg" % (sample, i)) for i in range(1,6)]
rule rmsd_1m:
    input:
        sex_conditional_build_all_rep_1m
    output:
        os.path.join(ana_home, "rmsd", "{sample}.rmsd.1m.info")
    conda: "../envs/hires.yaml"
    resources: nodes = 1
    message: "---> rmsd : {wildcards.sample} : {resources.nodes}"
    shell:
        """
        python {hires} rmsd -o {output} -rd {rd} -at 1m_  {input}
        """
