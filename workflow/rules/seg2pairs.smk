hickit = config["software"]["hickit"]
rule seg2pairs:
    input:
        rules.sam2seg.output
    output:
        os.path.join(config["dirs"]["pairs_0"], "{sample}.pairs.gz")
    log: rules.sam2seg.log
    shell:
        """        
        {hickit} --dup-dist=500 -i {input} -o - 2> {log} | gzip >> {output}
        """