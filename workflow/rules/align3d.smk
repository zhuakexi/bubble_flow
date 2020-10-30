rule align3d:
    input:
        rules.clean3d.output
    output:
        keep = rules.clean3d.output, #forward clena3d output
        this = directory(os.path.join(config["dirs"]["align3d"], "{sample}.20k"))
    log:
        result = config["logs"].format("align3d.rmsd.result"),
        log = config["logs"].format("align3d.log")
    conda: "../envs/hires.yaml"
    resources: nodes = 1
    message: "align3d : {wildcards.sample} : {resources.nodes}"
    shell:
        """
        python {hires} align -o {output.this}/ -gd {output.this}/good/ -bd {output.this}/bad/ {input} \
        > {log.result} 2> {log.log}      
        """
     