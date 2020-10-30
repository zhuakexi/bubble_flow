dip_c = config["software"]["dip-c"]
color_file = config["software"]["color_file"]
rule vis:
    input: rules.align3d.output
    output: directory(os.path.join(config["dirs"]["cif"], "{sample}.20k"))
    conda: "../envs/dip-c.yaml"
    shell:
        """
        for file in `ls {input}`
        do
            {dip_c} color -n {color_file} {input}/$file | \
            {dip_c} vis -c /dev/stdin {input}/$file > {output}/${{file}}.cif
        done
        """
        #dirty workaround for stupid snakemake input/output
        #need better vis or better out file syntax
        #goal: no loop in shell scripts