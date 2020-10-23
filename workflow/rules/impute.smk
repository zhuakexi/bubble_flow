import os
hickit = config["software"]["hickit"]
rule impute:
    input: rules.clean_123.output
    output:
        impute_pairs = os.path.join(config["dirs"]["impute"], "{sample}.impute.pairs.gz"),
        impute_val = os.path.join(config["dirs"]["impute"], "{sample}.impute.val")
    resources: nodes = 1
    log: rules.clean_123.log
    message: "impute: {sample}"
    shell:
        """
        # impute phases
        {hickit} -i {input} -u -o - 2>> {log} | gzip > {output.impute_pairs}
        # estimate imputation accuracy by holdout
        {hickit} -i {input} --out-val={output.impute_val} 2>> {log}
        """
        