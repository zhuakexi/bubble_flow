hires = config["software"]["hires"]
in_tp = os.path.join(ana_home, "3dg_c", "{{sample}}.clean.{}.{{rep}}.3dg")
out_tp = os.path.join(ana_home, "cif", "{{sample}}.clean.{}.{{rep}}.cif")

rule cif:
    input:
        in_tp.format("20k")
    output:
        out_tp.format("20k")
    conda: "../envs/hires.yaml"
    resources: nodes = 1
    message: "---> vis : {wildcards.sample}.{wildcards.rep} : {resources.nodes}"
    shell:
        """
        python {hires} mmcif \
            -i {input} \
            -o {output} 
        """