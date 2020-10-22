rule impute:
    input:
        clean123 = rules.clean_pairs.output.clean123,
    output:
        impute_pairs = "/share/Data/ychi/repo/impute/{sample}.impute.pairs.gz",
        impute_pairs_log = "/share/Data/ychi/repo/impute/{sample}.impute.pairs.log",
        impute_val = "/share/Data/ychi/repo/impute_val/{sample}.impute.val",
        impute_val_log = "/share/Data/ychi/repo/impute_val/{sample}.val.log",
    resources:
        nodes = 1
    shell:
        """
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate hires
        set -u

        # impute phases
        {hickit} -i {input.clean123} -u -o - 2> {output.impute_pairs_log} | gzip > {output.impute_pairs}

        # estimate imputation accuracy by holdout
        {hickit} -i {input.clean123} --out-val={output.impute_val} 2> {output.impute_val_log}

        set +u
        conda deactivate
        set -u
        """
        