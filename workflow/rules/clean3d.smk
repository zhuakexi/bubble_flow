# rescale and clean built 3d structures
hires = config["software"]["hires"]
dip_in_tp = os.path.join(ana_home, "3dg_dip", "{{sample}}.{}.{{rep}}.3dg")
dip_out_tp = os.path.join(ana_home, "3dg_c_dip", "{{sample}}.clean.{}.{{rep}}.3dg")
rule dip_clean3d:
    input:
        _3dg_1m = dip_in_tp.format("1m"),
        _3dg_200k = dip_in_tp.format("200k"),
        _3dg_50k = dip_in_tp.format("50k"),
        _3dg_20k = dip_in_tp.format("20k"),
        pairs = rules.sep_clean.output.dip
    output:
        _3dg_1m = dip_out_tp.format("1m"),
        _3dg_200k = dip_out_tp.format("200k"),
        _3dg_50k = dip_out_tp.format("50k"),
        _3dg_20k = dip_out_tp.format("20k")
    conda: "../envs/hires.yaml"
    resources: nodes = 1
    message: "---> dip_clean3d : {wildcards.sample}.{wildcards.rep} : {resources.nodes}"
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
hap_in_tp = os.path.join(ana_home, "3dg_hap", "{{sample}}.{}.{{rep}}.3dg")
hap_out_tp = os.path.join(ana_home, "3dg_c_hap", "{{sample}}.clean.{}.{{rep}}.3dg")
rule hap_clean3d:
    input:
        _3dg_1m = hap_in_tp.format("1m"),
        _3dg_200k = hap_in_tp.format("200k"),
        _3dg_50k = hap_in_tp.format("50k"),
        _3dg_20k = hap_in_tp.format("20k"),
        pairs = rules.clean123.output
    output:
        _3dg_1m = hap_out_tp.format("1m"),
        _3dg_200k = hap_out_tp.format("200k"),
        _3dg_50k = hap_out_tp.format("50k"),
        _3dg_20k = hap_out_tp.format("20k")
    conda: "../envs/hires.yaml"
    resources: nodes = 1
    message: "---> hap_clean3d : {wildcards.sample}.{wildcards.rep} : {resources.nodes}"
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