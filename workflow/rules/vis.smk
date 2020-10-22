rule vis:
    input:
        dip_c = "/share/home/ychi/software/dip-c/dip-c",
        color = "/share/Data/ychi/genome/GRCh38.chr.fem.txt",
        _3dg = "/share/Data/ychi/repo/aligned/{sample}.20k/good/"
    output:
        cif_dir = directory("/share/Data/ychi/repo/cif/{sample}/")
    shell:
        """
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate py2_env
        set -u

        for file in `ls {input._3dg}`
        do
            {input.dip_c} color -n {input.color} {input._3dg}${{file}} | \
            {input.dip_c} vis -c /dev/stdin {input._3dg}${{file}} > {output}${{file}}.cif
        done
        """
        #dirty workaround for stupid snakemake input/output
        #need better vis or better out file syntax
        #goal: no loop in shell scripts