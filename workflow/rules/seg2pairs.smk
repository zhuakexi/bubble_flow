# generate pairs file from seg
def sex_conditional_input(wildcards):
    with checkpoints.seg_stat.get(sample = wildcards.sample).output[0].open() as f:
        for line in f:
            if line.split(":")[0] == "cell_state":
                cell_state = line.split(":")[1].strip()
        if cell_state == "dipfem":
            return os.path.join(ana_home, "seg", "dipfem","{sample}.seg.gz")
        if cell_state == "dipmal":
            return os.path.join(ana_home, "seg", "dipmal","{sample}.seg.gz")
        if cell_state == "hapfem":
            return os.path.join(ana_home, "seg", "hapfem","{sample}.seg.gz")
        if cell_state == "hapmal":
            return os.path.join(ana_home, "seg", "hapmal","{sample}.seg.gz")
        # using the simplist one 
        return os.path.join(ana_home, "seg", "hapmal","{sample}.seg.gz")
rule seg2pairs:
    input:
        sex_conditional_input
    output:
        os.path.join(ana_home, "pairs_0", "{sample}.pairs.gz")
    threads: 1
    resources: nodes=1
    log:
        log_path("seg2pairs.log") 
    message: "seg2pairs : {wildcards.sample} : {threads} cores"
    shell:
        """        
        {hickit} --dup-dist=500 -i {input} -o - 2> {log} | gzip >> {output}
        """
# generate raw pairs for static
rule raw_pairs:
    input:
        sex_conditional_input
    output:
        os.path.join(ana_home, "pairs_0", "{sample}.raw_pairs.gz")
    threads: 1
    resources: nodes=1
    log:
        log_path("rawpairs.log") 
    message: "raw_pairs : {wildcards.sample} : {threads} cores"
    shell:
        """        
        {hickit} --dup-dist=0 -i {input} -o - 2> {log} | gzip >> {output}
        """
    