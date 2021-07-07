import os
hires = config["software"]["hires"]
rule sep_clean:
    input: rules.impute.output.impute_pairs
    output:
        dip = os.path.join(ana_home, "dip", "{sample}.dip.pairs.gz"),
        impute_c = os.path.join(ana_home, "impute_c", "{sample}.impute_c.pairs.gz")
    threads: config["cpu"]["clean2"]
    resources: nodes = config["cpu"]["clean2"]
    log:
        log=log_path("sep_clean.log"),
        result=log_path("sep_clean.result")
    conda: "../envs/hires.yaml" 
    message: " ------> sep_clean: {wildcards.sample} : {threads} cores"
    shell:
        """
        python3 {hires} sep_clean -n {threads} -o1 {output.dip} -o2 {output.impute_c} {input} 2> {log.log} 1>{log.result}
        """