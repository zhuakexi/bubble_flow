# count gene and exons on merged RNA and generate count matrix

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
        # on gene
        gene_assigned = os.path.join(config["dirs"]["count_gene"], "gene_assigned"),
        gene_sam_sort = os.path.join(config["dirs"]["count_gene"], "samsort.bam"),
        gene_count_matrix = os.path.join(config["dirs"]["count_matrix"], "counts.gene.tsv.gz"),
        # on exon
        exon_assigned = os.path.join(config["dirs"]["count_exon"], "exon_assigned"),
        exon_sam_sort = os.path.join(config["dirs"]["count_exon"], "samsort.bam"),
        exon_count_matrix = os.path.join(config["dirs"]["count_matrix"], "counts.exon.tsv.gz")
    params:
        r"--per-gene --per-cell --gene-tag=XT --wide-format-cell-counts --assigned-status-tag=XS"
    conda: "../envs/rna_tools.yaml"
    shell:
        """         
        # featureCounts by gene
        featureCounts -a {annotation} -o {output.gene_assigned} -R BAM {count_real_input} -T 4 -Q 30 -t gene -g gene_name
        samtools sort {fC_bam_gene} -o {output.gene_sam_sort}
        samtools index {output.gene_sam_sort}
        umi_tools count {params} -I {output.gene_sam_sort} -S {output.gene_count_matrix}
        
        # featureCounts by exon
        featureCounts -a {annotation} -o {output.exon_assigned} -R BAM {count_real_input} -T 4 -Q 30 -g gene_name
        samtools sort {fC_bam_exon} -o {output.exon_sam_sort}
        samtools index {output.exon_sam_sort}
        umi_tools count {params} -I {output.exon_sam_sort} -S {output.exon_count_matrix} 
        """