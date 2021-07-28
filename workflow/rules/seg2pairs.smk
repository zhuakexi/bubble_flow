# generate pairs file from seg
hickit = config["software"]["hickit"]
rule seg2pairs:
    input:
        rules.sam2seg.output
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
        rules.sam2seg.output
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
    