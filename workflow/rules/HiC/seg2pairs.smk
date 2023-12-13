# generate pairs file from seg
rule seg2pairs:
    input:
        rules.sam2seg.output
    output:
        os.path.join(ana_home, "pairs_0", "{sample}.pairs.gz"),
        log_path("seg2pairs.log") # need this to keep log complete
    threads: 1
    resources: nodes=1
    message: "seg2pairs : {wildcards.sample} : {threads} cores"
    shell:
        """        
        {hickit} --dup-dist=500 -i {input} -o - 2> {output[1]} | gzip >> {output[0]}
        """
# generate raw pairs for static
rule raw_pairs:
    input:
        rules.sam2seg.output
    output:
        os.path.join(ana_home, "pairs_0", "{sample}.raw_pairs.gz"),
        log_path("rawpairs.log") # need this to keep log complete
    threads: 1
    resources: nodes=1
    message: "raw_pairs : {wildcards.sample} : {threads} cores"
    shell:
        """        
        {hickit} --dup-dist=0 -i {input} -o - 2> {output[1]} | gzip >> {output[0]}
        """
    