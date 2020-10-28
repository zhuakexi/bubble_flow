# 4th step
# generate pairs file from seg
hickit = config["software"]["hickit"]
rule seg2pairs:
    input:
        rules.sam2seg.output
    output:
        os.path.join(config["dirs"]["pairs_0"], "{sample}.pairs.gz")
    resources: nodes=1
    log: config["logs"].format("seg2pairs.log")
    message: "seg2pairs : {wildcards.sample} : {threads} cores"
    shell:
        """        
        {hickit} --dup-dist=500 -i {input} -o - 2> {log} | gzip >> {output}
        """