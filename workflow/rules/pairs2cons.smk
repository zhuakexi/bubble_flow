#convert from hickit to dip-c formats
pairs2con = config["software"]["pairs2con"]
impute2con = config["software"]["impute2con"]
rule pairs2cons:
    input:
        pairs = rules.clean123.output,
        impute_pairs = rules.impute.output.impute_pairs
    resources: nodes = 1
    output:
        con = os.path.join(config["dirs"]["con"], "{sample}.con.gz"),
        impute_con = os.path.join(config["dirs"]["con"], "{sample}.impute.con.gz")
    conda: "../envs/dip-c.yaml"
    message: "------> pairs2con : {wildcards.sample} : {resources} core"
    shell:
        """
        {pairs2con} {input.pairs}
        {impute2con} {input.impute_pairs}
        
        mv {config[dirs][clean123]}/{wildcards.sample}.c123.con.gz {output.con}
        mv {config[dirs][impute]}/{wildcards.sample}.impute.con.gz {output.impute_con}
        """
