# generate pairs file from seg
rule seg2pairs:
    input:
        rules.sam2seg.output
    output:
        os.path.join(ana_home, "pairs_0", "{sample}.pairs.gz"),
        log_path("seg2pairs.log") # need this to keep log complete
    threads: 1
    resources: nodes=1
    #message: "seg2pairs : {wildcards.sample} : {threads} cores"
    shell:
        """        
        if [[ $(zcat {input} | grep -v '^#' | wc -l) -eq 0 ]]; then
            cp {input} {output[0]}
            echo "[M::hk_map_read] read 0 segments" > {output[1]}
            echo "[M::hk_seg2pair] generated 0 pairs" >> {output[1]}
            echo "[M::hk_pair_dedup] duplicate rate: 0.00% = 0 / 0" >> {output[1]}
            echo "[M::main] Version: r291" >> {output[1]}
            echo "[M::main] CMD: {hickit} --dup-dist=500 -i {output[1]} -o -" >> {output[1]}
            echo "[M::main] CPU time: 0.0 sec" >> {output[1]}
        else
            {hickit} --dup-dist=500 -i {input} -o - 2> {output[1]} | gzip >> {output[0]}
        fi
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
        if [[ $(zcat {input} | grep -v '^#' | wc -l) -eq 0 ]]; then
            cp {input} {output[0]}
            echo "[M::hk_map_read] read 0 segments" > {output[1]}
            echo "[M::hk_seg2pair] generated 0 pairs" >> {output[1]}
            echo "[M::hk_pair_dedup] duplicate rate: 0.00% = 0 / 0" >> {output[1]}
            echo "[M::main] Version: r291" >> {output[1]}
            echo "[M::main] CMD: {hickit} --dup-dist=0 -i {output[1]} -o -" >> {output[1]}
            echo "[M::main] CPU time: 0.0 sec" >> {output[1]}
        else
            {hickit} --dup-dist=0 -i {input} -o - 2> {output[1]} | gzip >> {output[0]}
        fi
        """
    