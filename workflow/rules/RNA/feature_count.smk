annotation = config["reference"]["annotation"]
rule feature_count:
    input: rules.star_mapping.output # using flag file to keep in line
    output:
        gene_assigned = os.path.join(ana_home, "count_gene", "gene_assigned"),
        bam = os.path.join(ana_home, "count_gene", "Aligned.sortedByCoord.out.bam.featureCounts.bam")
    log:
        result = os.path.join(ana_home, "logs", "count.result"),
        log = os.path.join(ana_home, "logs", "count.log")
    conda: "../../envs/rna_tools.yaml"
    shell:
        """
        featureCounts -a {annotation} -o {output.gene_assigned} -R BAM {input} \
         -T 4 -Q 30 -t gene -g gene_id -M -O --fraction 2>{log.log} 1>{log.result}
        """
rule sort_count:
    input: rules.feature_count.output.bam # this only for dependency keeping. use fC_bam_gene in fact
    output:
        os.path.join(ana_home, "count_gene", "samsort.bam")
    threads: config["cpu"]["sortBAM"]
    conda: "../../envs/samtools.yaml"
    shell:
        '''
        samtools sort -@ {threads} {input} -o {output}
        samtools index -@ {threads} {output}
        '''
rule matrix_count:
    input:
        rules.sort_count.output
    output:
        os.path.join(ana_home, "count_matrix", "counts.gene.tsv.gz")
    params:
        r"--per-gene --per-cell --extract-umi-method=tag --umi-tag UB --cell-tag RG --gene-tag=XT --assigned-status-tag=XS --wide-format-cell-counts"
    conda: "../../envs/rna_tools.yaml"
    shell:
        '''
        umi_tools count {params} -I {input} -S {output}
        '''
