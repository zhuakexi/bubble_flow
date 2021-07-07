# rescale and clean built 3d structures
hires = config["software"]["hires"]
in_tp = os.path.join(ana_home, "3dg", "{{sample}}.{}.{{rep}}.3dg")
out_tp = os.path.join(ana_home, "3dg_c", "{{sample}}.clean.{}.{{rep}}.3dg")
rule clean3d:
    input:
        _3dg_1m = in_tp.format("1m"),
        _3dg_200k = in_tp.format("200k"),
        _3dg_50k = in_tp.format("50k"),
        _3dg_20k = in_tp.format("20k"),
        pairs = rules.sep_clean.output.dip
    output:
        _3dg_1m = out_tp.format("1m"),
        _3dg_200k = out_tp.format("200k"),
        _3dg_50k = out_tp.format("50k"),
        _3dg_20k = out_tp.format("20k")
    conda: "../envs/hires.yaml"
    resources: nodes = 1
    message: "---> clean3d : {wildcards.sample}.{wildcards.rep} : {resources.nodes}"
    shell:
        """
        python {hires} clean3 \
            -i {input._3dg_1m} \
            -r {input.pairs} \
            -o {output._3dg_1m}
        
        python {hires} clean3 \
            -i {input._3dg_200k} \
            -r {input.pairs} \
            -o {output._3dg_200k}

        python {hires} clean3 \
            -i {input._3dg_50k} \
            -r {input.pairs} \
            -o {output._3dg_50k}
        
        python {hires} clean3 \
            -i {input._3dg_20k} \
            -r {input.pairs} \
            -o {output._3dg_20k}
        """