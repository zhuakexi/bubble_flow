rule cut_round2:
    input:
        RNA_R1 = rules.split.output.RNA_R1,
        RNA_R2 = rules.split.output.RNA_R2
    output: 
        RNA_R1="/share/Data/ychi/repo/rna/{sample}.rna.clean.R1.fq.gz",
        RNA_R2="/share/Data/ychi/repo/rna/{sample}.rna.clean.R2.fq.gz"
        
    threads: 12
    resources:
        nodes = 12
    params:
        adapter=r"XNNNNNNNNTTTTTTTTTTTTTTT;o=18"
    shell:"""
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate hires
        set -u
        cutadapt --action=none --discard-untrimmed -G '{params.adapter}' -j {threads} -o {output.RNA_R1} -p {output.RNA_R2} {input}
        set +u
        conda deactivate
        set -u
        """