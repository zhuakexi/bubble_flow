rule extract_umi:
    input:
        #RNA_R1="/share/Data/ychi/repo/rna/{sample}.rna.R1.fq.gz",
        #RNA_R2="/share/Data/ychi/repo/rna/{sample}.rna.R2.fq.gz"
        RNA_R1 = rules.cut_round2.output.RNA_R1,
        RNA_R2 = rules.cut_round2.output.RNA_R2
    output:
        umi1="/share/Data/ychi/repo/umi/umi.{sample}.rna.R1.fq.gz",
        umi2="/share/Data/ychi/repo/umi/umi.{sample}.rna.R2.fq.gz",
        unzip_umi1=temp("/share/Data/ychi/repo/RNA_all/umi.{sample}.rna.R1.temp.fq"),
        umi_by_cell = "/share/Data/ychi/repo/RNA_all/umi.{sample}.rna.R1.fq"
    resources:
        nodes = 1
    params:
        pattern=r"NNNNNNNN"
    shell: 
        """
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate hires
        set -u
        umi_tools extract -p {params.pattern} -I {input.RNA_R2} -S {output.umi2} --read2-in={input.RNA_R1} --read2-out={output.umi1}
        gunzip --force -c {output.umi1} > {output.unzip_umi1}
        sed 's/_/_{wildcards.sample}_/' {output.unzip_umi1} > {output.umi_by_cell}
        set +u
        conda deactivate 
        set -u
        """
