rule align3d:
    input:
        expand("/share/Data/ychi/repo/clean3d/{{sample}}.clean3d.20k.{rep}.3dg", rep = list(range(1,6)))
    output:
        aligned_3dg = directory("/share/Data/ychi/repo/aligned/{sample}.20k/"),
        #good = directory("/share/Data/ychi/repo/aligned/{sample}.20k/good/"),
        #bad = directory("/share/Data/ychi/repo/aligned/{sample}.20k/bad/"),
        #rmsdInfo = "/share/Data/ychi/repo/aligned/{sample}.20k/{sample}.20k.rmsd.info"
    resources:
        nodes = 1
    shell:
        """
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate hires
        set -u
        
        python {hires} align -o {output.aligned_3dg} -gd {output.aligned_3dg}good/ -bd {output.aligned_3dg}bad {input} > {output.aligned_3dg}{wildcards.sample}.20k.rmsd.info
        
        #need align to do the real clean or create 3dg_good

        set +u
        conda deactivate
        set -u
        """
     