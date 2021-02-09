star_out_prefix = os.path.join(ana_home, "star_mapped")
rule star_mapping:
    input:
        sequence = rules.merge_rna.output,
        index = config["reference"]["star"]
    output:
        touch( os.path.join(ana_home, "star_mapped", "Aligned.sortedByCoord.out.bam.dummy") )
    threads: 10
    message: "---> star mapping on {threads} cores."
    conda: "../envs/rna_tools.yaml"
    shell:
        # file name prefix need "/"
        """
        STAR --runThreadN {threads} \
        --genomeDir {input.index} \
        --readFilesIn {input.sequence} \
        --outFileNamePrefix {star_out_prefix}/ \
        --outSAMtype BAM Unsorted SortedByCoordinate --outReadsUnmapped Fastx
        """