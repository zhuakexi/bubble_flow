star_out_prefix = os.path.join(ana_home, "star_mapped")
rule star_mapping:
    input:
        sequence = ",".join([os.path.join(ana_home, "umi_uBAM", "{sample}.bam").format(sample=i) 
            for i in sample_table.index]),
        RGline = " , ".join(["ID:{sample}".format(sample=i) for i in sample_table.index]),
        index = config["reference"]["star"]
    output:
        os.path.join(ana_home, "star_mapped", "Aligned.sortedByCoord.out.bam")
    threads: 10
    message: "---> star mapping on {threads} cores."
    conda: "../../envs/rna_tools.yaml"
    shell:
        # file name prefix need "/"
        """
        STAR --runThreadN 8 --genomeDir {input.index} \
         --readFilesIn {input.sequence} --readFilesType SAM SE \
         --readFilesCommand samtools view --readFilesSAMattrKeep UB \
         --outSAMattrRGline {input.RGline} --outFileNamePrefix {star_out_prefix} \
         --outSAMtype BAM SortedByCoordinate --outReadsUnmapped Fastx
        """