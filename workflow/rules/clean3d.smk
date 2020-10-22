rule clean3d:
    input:
        cons = rules.pairs2cons.output.cons,
        impute_cons = rules.pairs2cons.output.cons,
        _3dg_20k = rules.build.output._3dg_20k,
        dip_c = "/share/home/ychi/software/dip-c/dip-c",
        hickit_3dg_to_3dg_rescale_unit = "/share/home/ychi/software/dip-c/scripts/hickit_3dg_to_3dg_rescale_unit.sh"
    output:
        _3dg_20k_clean = "/share/Data/ychi/repo/clean3d/{sample}.clean3d.20k.{rep}.3dg" 
    resources:
        nodes = 1
    shell: 
        """
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate py2_env
        set -u

        {input.hickit_3dg_to_3dg_rescale_unit} {input._3dg_20k}
        {input.dip_c} clean3 -c {input.impute_cons} /share/Data/ychi/repo/3dg/{wildcards.sample}.20k.{wildcards.rep}.dip-c.3dg > {output._3dg_20k_clean}
        
        set +u
        conda deactivate
        set -u
        """
