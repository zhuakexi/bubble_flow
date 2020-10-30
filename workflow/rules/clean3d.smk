dip_c = config["software"]["dip-c"]
rescale = config["software"]["rescale"]
rule clean3d:
    input:
        con = rules.pairs2cons.output.con,
        impute_cons = rules.pairs2cons.output.impute_con,
        _3dg_20k = rules.build.output._3dg_20k
    output:
        os.path.join(config["dirs"]["3dg_c"], "{sample}.clean.20k.{rep}.3dg")
    log: config["logs"].format("clean3d.{rep}.log")
    conda: "../envs/dip-c.yaml"
    resources: nodes = 1
    message: "------> clean3d : {wildcards.sample}.{wildcards.rep} : {resources.nodes} cores"
    
    shell: 
        """
        {rescale} {input._3dg_20k}
        {dip_c} clean3 -c {input.impute_cons} {config[dirs][clean3d]}/{wildcards.sample}.20k.{wildcards.rep}.dip-c.3dg > {output}
        rm {config[dirs][clean3d]}/{wildcards.sample}.20k.{wildcards.rep}.dip-c.3dg
        """
