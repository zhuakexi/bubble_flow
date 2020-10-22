rule seg2pairs:
    input:
        seg = rules.sam2seg.output.seg
    output:
        raw_pairs = "/share/Data/ychi/repo/raw_pairs/{sample}.raw.pairs.gz",
        raw_pairs_log = "/share/Data/ychi/repo/raw_pairs/{sample}.raw.pairs.log",
        pairs = "/share/Data/ychi/repo/pairs/{sample}.pairs.gz",
        pairs_log = "/share/Data/ychi/repo/pairs/{sample}.pairs.log"
    shell:
        """        
        #generate raw pairs for statistics
        {hickit} --dup-dist=0 -i {input.seg} -o - 2> {output.raw_pairs_log} | gzip > {output.raw_pairs}
        
        #generate real pairs
        {hickit} --dup-dist=500 -i {input.seg} -o - 2> {output.pairs_log} | gzip > {output.pairs}
        """