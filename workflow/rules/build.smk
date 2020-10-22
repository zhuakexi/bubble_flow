rule build:
    input:
        impute_pairs = "/share/Data/ychi/repo/impute/{sample}.impute.pairs.gz",
    output:
        _3dg_1m = "/share/Data/ychi/repo/3dg/{sample}.1m.{rep}.3dg",
        _3dg_200k = "/share/Data/ychi/repo/3dg/{sample}.200k.{rep}.3dg",
        _3dg_50k = "/share/Data/ychi/repo/3dg/{sample}.50k.{rep}.3dg",
        _3dg_20k = "/share/Data/ychi/repo/3dg/{sample}.20k.{rep}.3dg"
    resources:
        nodes = 1
    shell: 
        """
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate hires
        {hickit} -s{wildcards.rep} -M \
            -i {input.impute_pairs} -Sr1m -c1 -r10m -c2 \
            -b4m -b1m -O {output._3dg_1m} \
            -b200k -O {output._3dg_200k} \
            -D5 -b50k -O {output._3dg_50k} \
            -D5 -b20k -O {output._3dg_20k}
        set +u
        conda deactivate
        set -u
        """
