# count gene and exons on merged RNA and generate count matrix
# using three rules because conda version of samtools has conflict

# upstream rule star_mapping use dummy as flag file, here gives the real output as featureCount's real input
count_real_input = os.path.join(config["dirs"]["star_mapped"], "Aligned.sortedByCoord.out.bam")
annotation = config["reference"]["annotation"]

#featureCount generates 3 output file, shell only show 1 of them, the rest are:
fC_bam_gene = os.path.join(config["dirs"]["count_gene"], "Aligned.sortedByCoord.out.bam.featureCounts.bam")
fC_bam_summary_gene = os.path.join(config["dirs"]["count_gene"], "gene_assigned.summary")
fC_bam_exon = os.path.join(config["dirs"]["count_exon"], "Aligned.sortedByCoord.out.bam.featureCounts.bam")
fC_bam_summary_exon = os.path.join(config["dirs"]["count_exon"], "exon_assigned.summary")
rule count:
    input: rules.star_mapping.output # using flag file to keep in line
    output:
        gene_assigned = os.path.join(config["dirs"]["count_gene"], "gene_assigned"), 
        exon_assigned = os.path.join(config["dirs"]["count_exon"], "exon_assigned")
    log:
        # not for all cell, can't use normal format
        result = os.path.join(config["log_dir"], "count.result"),
        log = os.path.join(config["log_dir"], "count.log")
    conda: "../envs/rna_tools.yaml"
    shell:
        """
        featureCounts -a {annotation} -o {output.gene_assigned} -R BAM {count_real_input} -T 4 -Q 30 -t gene -g gene_name 2>{log.log} 1>{log.result}
        featureCounts -a {annotation} -o {output.exon_assigned} -R BAM {count_real_input} -T 4 -Q 30 -g gene_name
        """
rule sort_count:
    input: rules.count.output # this only for dependency keeping. use fC_bam_gene in fact 
    output:
        gene_sam_sort = os.path.join(config["dirs"]["count_gene"], "samsort.bam"),
        exon_sam_sort = os.path.join(config["dirs"]["count_exon"], "samsort.bam")
    conda: "../envs/samtools.yaml"
    shell:
        '''
        samtools sort {fC_bam_gene} -o {output.gene_sam_sort}
        samtools index {output.gene_sam_sort}
        samtools sort {fC_bam_exon} -o {output.exon_sam_sort}
        samtools index {output.exon_sam_sort}
        '''
rule matrix_count:
    input:
        for_gene = rules.sort_count.output.gene_sam_sort,
        for_exon = rules.sort_count.output.exon_sam_sort
    output:
        gene_count_matrix = os.path.join(config["dirs"]["count_matrix"], "counts.gene.tsv.gz"),
        exon_count_matrix = os.path.join(config["dirs"]["count_matrix"], "counts.exon.tsv.gz")
    params:
        r"--per-gene --per-cell --gene-tag=XT --wide-format-cell-counts --assigned-status-tag=XS"
    conda: "../envs/rna_tools.yaml"
    shell:
        '''
        umi_tools count {params} -I {input.for_gene} -S {output.gene_count_matrix}
        umi_tools count {params} -I {input.for_exon} -S {output.exon_count_matrix}
        '''

        