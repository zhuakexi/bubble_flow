import os
hires = config["software"]["hires"]
rule rmsd:
    input:
        expand(
            rules.clean3d.output._3dg_20k, 
            sample="{sample}", 
            rep=list(range(1,6))
            )
    output:
        os.path.join(ana_home, "rmsd", "{sample}.rmsd.info")
    conda: "../envs/hires.yaml"
    resources: nodes = 1
    message: "---> rmsd : {wildcards.sample} : {resources.nodes}"
    shell:
        """
        python {hires} rmsd -o {output} {input}
        """