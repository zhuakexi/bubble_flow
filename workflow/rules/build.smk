import os
hickit = config["software"]["hickit"]
tp = os.path.join(config["dir"]["3dg"], "{{sample}}.{}.{{rep}}.3dg")
rule build:
    input: rules.impute.impute_pairs
    output:
        _3dg_1m = tp.format("1m"),
        _3dg_200k = tp.format("200k"),
        _3dg_50k = tp.format("50k"),
        _3dg_20k = tp.format("20k")
    resources: nodes = 1
    shell: 
        """
        {hickit} -s{wildcards.rep} -M \
            -i {input} -Sr1m -c1 -r10m -c2 \
            -b4m -b1m -O {output._3dg_1m} \
            -b200k -O {output._3dg_200k} \
            -D5 -b50k -O {output._3dg_50k} \
            -D5 -b20k -O {output._3dg_20k}
        """
