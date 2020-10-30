dip_c = config["software"]["dip-c"]
color_file = config["software"]["color_file"]
rule vis:
    input: rules.align3d.output
    output: directory(os.path.join(config["dirs"]["cif"], "{sample}.20k"))
    conda: "../envs/dip-c.yaml"
    log: os.path.join(config["log_dir"],"{sample}","20k.vis")
    resources: nodes=1
    message: "vis : {wildcards.sample} : {resources.nodes} cores"
    shell:
        """
        for file in `ls {input}/good`
        do
            {dip_c} color -n {color_file} {input}/good/$file 2>> {log} | \
            {dip_c} vis -c /dev/stdin {input}/good/$file > {output}/${{file}}.cif 2>> {log}
        done
        if [ "`ls {input}/good`" == "" ]
        then
            mkdir {output}
        fi
        """
        #dirty workaround for stupid snakemake input/output
        #need better vis or better out file syntax
        #goal: no loop in shell scripts, no branch either