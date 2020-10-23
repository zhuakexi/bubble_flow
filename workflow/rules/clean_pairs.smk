hires = config["software"]["hires"]
rule clean1:
    input: rules.seg2pairs.output,
    output: os.path.join(config["dirs"]["pairs_c1"], "{sample}.c1.pairs.gz")
    log: rules.seg2pairs.log
    threads: 8
    resources: nodes = 8
    conda: "workflow/envs/hires.yaml"
    message: "clean_pairs_stage1 : {wildcards.sample} : {resources} cores."
    shell: "python {hires} clean_leg -t {threads} -o {output} {input}  >> {log}"

rule clean12:
    input: rules.clean1.output
    output: os.path.join(config["dirs"]["pairs_c12"], "{sample}.c12.pairs.gz")
    log: rules.clean1.log
    threads: 8
    resources: nodes = 8
    conda: "workflow/envs/hires.yaml"
    message: "clean_pairs_stage2 : {wildcards.sample} : {resources} cores."
    shell: "python {hires} clean_isolated -t {threads} -o {output} {input} >> {log}"

rule clean123:
    input: 
        sequence = rules.clean12.output,
        exon_index = config["reference"]["hires_index"]
    output: os.path.join(config["dirs"]["pairs_c123"], "{sample}.c123.pairs.gz")
    log: rules.clean12.log
    threads: 8
    resources: nodes = 8
    conda: "workflow/envs/hires.yaml"
    message: "clean_pairs_stage3 : {wildcards.sample} : {resources} cores."
    shell: "python {hires} clean_splicing -r {input.exon_index} -o {output} {input.sequence} >> {log}"
