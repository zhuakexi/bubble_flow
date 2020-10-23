rule count:
    input:
        os.path.join(config["dirs"]["star_mapped"], "Aligned.sortedByCoord.out.bam")
    output:
        gene_assigned = "/share/Data/ychi/repo/feature_gene/gene_assigned",
        exon_assigned = "/share/Data/ychi/repo/feature_exon/exon_assigned",
        gene_sam_sort = "/share/Data/ychi/repo/feature_gene/samsort.bam",
        exon_sam_sort = "/share/Data/ychi/repo/feature_exon/samsort.bam",
        gene_count_matrix = "/share/Data/ychi/repo/counts/counts.gene.tsv.gz",
        exon_count_matrix = "/share/Data/ychi/repo/counts/counts.exon.tsv.gz"
    params:
        r"--per-gene --per-cell --gene-tag=XT --wide-format-cell-counts --assigned-status-tag=XS"
    conda: "../envs/rna_tools.yaml"
    shell:
        """         
        #featureCounts by gene
        featureCounts -a {annotations} -o {output.gene_assigned} -R BAM {rules.star_mapping.output} -T 4 -Q 30 -t gene -g gene_name
        #featureCounts by exon
        featureCounts -a {annotations} -o {output.exon_assigned} -R BAM {rules.star_mapping.output} -T 4 -Q 30 -g gene_name
        
        #OUTPUT count_matix by gene
        samtools sort /share/Data/ychi/repo/feature_gene/Aligned.sortedByCoord.out.bam.featureCounts.bam -o {output.gene_sam_sort}
        samtools index {output.gene_sam_sort}
        umi_tools count {params} -I {output.gene_sam_sort} -S {output.gene_count_matrix}

        #OUTPUT count_matix by exon
        samtools sort /share/Data/ychi/repo/feature_exon/Aligned.sortedByCoord.out.bam.featureCounts.bam -o {output.exon_sam_sort}
        samtools index {output.exon_sam_sort}
        umi_tools count {params} -I {output.exon_sam_sort} -S {output.exon_count_matrix} 
        """