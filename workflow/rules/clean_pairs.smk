# 5th step
# clean poor mapping, DNA duplication, RNA containment in pairs file
hires = config["software"]["hires"]
rule clean1:
    input: rules.seg2pairs.output,
    output: os.path.join(config["dirs"]["pairs_c1"], "{sample}.c1.pairs.gz")
    log: 
        result = config["logs"].format("clean1.result"),
        log = config["logs"].format("clean1.log")
    threads: config["cpu"]["clean1"]
    resources: nodes = config["cpu"]["clean1"]
    conda: "../envs/hires.yaml"
    message: "clean_pairs_stage1 : {wildcards.sample} : {threads} cores."
    shell: "python {hires} clean_leg -t {threads} -o {output} {input}  1> {log.result} 2> {log.log}"

rule clean12:
    input: rules.clean1.output
    output: os.path.join(config["dirs"]["pairs_c12"], "{sample}.c12.pairs.gz")
    log: 
        result = config["logs"].format("clean12.result"),
        log = config["logs"].format("clean12.log")
    threads: config["cpu"]["clean2"]
    resources: nodes = config["cpu"]["clean2"]
    conda: "../envs/hires.yaml"
    message: "clean_pairs_stage2 : {wildcards.sample} : {threads} cores."
    shell: "python {hires} clean_isolated -t {threads} -o {output} {input} 1> {log.result} 2> {log.log}"

rule clean123:
    input: 
        sequence = rules.clean12.output,
        exon_index = config["software"]["hires_index"]
    output: os.path.join(config["dirs"]["pairs_c123"], "{sample}.c123.pairs.gz")
    log: 
        result = config["logs"].format("clean123.result"),
        log = config["logs"].format("clean123.log")
    threads: config["cpu"]["clean3"]
    resources: nodes = config["cpu"]["clean3"]
    conda: "../envs/hires.yaml"
    message: "clean_pairs_stage3 : {wildcards.sample} : {threads} cores."
    shell: "python {hires} clean_splicing -r {input.exon_index} -o {output} {input.sequence} 1> {log.result} 2> {log.log}"
