rule clean_pairs:
    input: 
        pairs = rules.seg2pairs.output.pairs,
        exon_index = "/share/home/ychi/software/hires-utils/bin_10k_FULL_index"
    output: 
        clean1= "/share/Data/ychi/repo/clean1/{sample}.c1.pairs.gz",
        clean12 = "/share/Data/ychi/repo/clean12/{sample}.c12.pairs.gz",
        clean123 = "/share/Data/ychi/repo/clean123/{sample}.c123.pairs.gz",
        clean13 = "/share/Data/ychi/repo/clean13/{sample}.c13.pairs.gz"
    log: "/share/Data/ychi/repo/log/{sample}.clean.log"
    threads: 8
    resources:
        nodes = 8
    message: "clean_pairs : {wildcards.sample} : {resources} cores"
    shell:
        """
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate hires
        set -u

        python {hires} clean_leg -t {threads} {input.pairs} -o {output.clean1} >> {log}
        python {hires} clean_isolated -t {threads} -o {output.clean12} {output.clean1} >> {log}
        python {hires} clean_splicing -r {input.exon_index} -o {output.clean123} {output.clean12} >> {log}
        python {hires} clean_splicing -r {input.exon_index} -o {output.clean13} {output.clean1} >> {log}

        set +u
        conda deactivate
        set -u
        """
