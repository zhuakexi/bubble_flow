import os
hickit = config["software"]["hickit"]
tp = os.path.join(ana_home, "3dg", "{{sample}}.{}.{{rep}}.3dg")
rule build:
    # using hires sep_clean
    # don't need hickit -Sr1m xx
    input: rules.sep_clean.output.impute_c
    output:
        _3dg_1m = tp.format("1m"),
        _3dg_200k = tp.format("200k"),
        _3dg_50k = tp.format("50k"),
        _3dg_20k = tp.format("20k")
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
