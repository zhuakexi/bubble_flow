import os
hickit = config["software"]["hickit"]
rule impute:
    input: rules.clean123.output
    output:
        impute_pairs = os.path.join(config["dirs"]["impute"], "{sample}.impute.pairs.gz"),
        impute_val = os.path.join(config["dirs"]["impute"], "{sample}.impute.val")
    threads: 1
    resources: nodes = 1
    log: config["logs"].format("impute.log")
    message: "impute: {wildcards.sample} : {threads} cores"
    shell:
        """
        # impute phases
        {hickit} -i {input} -u -o - 2> {log} | gzip > {output.impute_pairs}
        # estimate imputation accuracy by holdout
        {hickit} -i {input} --out-val={output.impute_val} 2>> {log}
        """
        