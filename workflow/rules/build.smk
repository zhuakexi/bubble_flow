import os
dip_tp = os.path.join(ana_home, "3dg_dip", "{{sample}}.{}.{{rep}}.3dg")
rule dip_build:
    # using hires sep_clean
    # don't need hickit -Sr1m xx
    input: rules.sep_clean.output.impute_c
    output:
        _3dg_1m = dip_tp.format("1m"),
        _3dg_200k = dip_tp.format("200k"),
        _3dg_50k = dip_tp.format("50k"),
        _3dg_20k = dip_tp.format("20k")
    log:
        log_path("build.{rep}.log")
    threads: 1
    resources: nodes = 1
    message: "------> hickit build 3d : {wildcards.sample}.{wildcards.rep} : {threads} cores"
    shell: 
        """
        {hickit} -s{wildcards.rep} -M \
            -i {input} -S \
            -b4m -b1m -O {output._3dg_1m} \
            -b200k -O {output._3dg_200k} \
            -D5 -b50k -O {output._3dg_50k} \
            -D5 -b20k -O {output._3dg_20k} \
            2> {log}
        """
hap_tp = os.path.join(ana_home, "3dg_hap", "{{sample}}.{}.{{rep}}.3dg")
rule hap_build:
    # using output of pairs_c123
    # no impute
    # don't need hickit -Sr1m xx
    input: rules.clean123.output
    output:
        _3dg_1m = hap_tp.format("1m"),
        _3dg_200k = hap_tp.format("200k"),
        _3dg_50k = hap_tp.format("50k"),
        _3dg_20k = hap_tp.format("20k")
    log:
        log_path("build.{rep}.log")
    threads: 1
    resources: nodes = 1
    message: "------> hickit build 3d : {wildcards.sample}.{wildcards.rep} : {threads} cores"
    shell: 
        """
        {hickit} -s{wildcards.rep} -M \
            -i {input} \
            -b4m -b1m -O {output._3dg_1m} \
            -b200k -O {output._3dg_200k} \
            -D5 -b50k -O {output._3dg_50k} \
            -D5 -b20k -O {output._3dg_20k} \
            2> {log}
        """