rule bwa_map:
    input:
        ref_genome="/share/Data/ychi/genome/bwa_index/GRCh38/genome.fa",
        DNA1 = "/share/Data/ychi/repo/dna/{sample}.dna.R1.fq.gz",
        DNA2 = "/share/Data/ychi/repo/dna/{sample}.dna.R2.fq.gz",
    output:
        aln = protected("/share/Data/ychi/repo/sam/{sample}.aln.sam.gz")
    threads: 12
    resources:
        nodes = 12
    params:
        extra=r"-R '@RG\tID:{sample}\tPL:ILLUMINA\tSM:{sample}'",
    shell:
        """
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate hires
        set -u

        bwa mem -5SP -t{threads} {params.extra} {input.ref_genome} {input.DNA1} {input.DNA2} | gzip > {output.aln}

        set +u
        conda deactivate
        set -u
        """
