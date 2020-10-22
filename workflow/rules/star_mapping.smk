rule star_mapping:
    input:
        rules.merge_rna.output
    output:
        "/share/Data/ychi/repo/star/Aligned.sortedByCoord.out.bam"
    threads: 10
    message: "star mapping on {threads} cores."
    shell:
        """
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate hires
        set -u
        STAR --runThreadN {threads} \
        --genomeDir {star_index} \
        --readFilesIn {input} \
        --outFileNamePrefix /share/Data/ychi/repo/star/ \
        --outSAMtype BAM Unsorted SortedByCoordinate --outReadsUnmapped Fastx
        set +u
        conda deactivate
        set =u
        """