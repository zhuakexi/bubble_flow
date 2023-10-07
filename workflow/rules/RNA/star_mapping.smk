star_out_prefix = os.path.join(ana_home, "star_mapped", "")
def star_mapping_input(wildcards):
    """
    TODO: make a real group/aggregate mode
    """
    per_ref_samples = sample_table.loc[sample_table["ref"] == wildcards.ref].index if "ref" in sample_table.columns else sample_table.index # global ref means all samples
    return {
        "RNAprep" : expand(rules.mend_umi.output, sample=per_ref_samples),
        "index" : config["reference"]["star"][wildcards.ref] if wildcards.ref in config["reference"]["star"] else "NoSTARIndexFile.txt"
    }
def star_mapping_params(wildcards):
    per_ref_samples = sample_table.loc[sample_table["ref"] == wildcards.ref].index if "ref" in sample_table.columns else sample_table.index # global ref means all samples
    # string that defines the input files for STAR
    sequence = ",".join([os.path.join(ana_home, "RNA_cc", "{sample}_R2.fq.gz").format(sample=i)
        for i in per_ref_samples]),
    # string that defines the read groups for output sam
    RGline = " , ".join(["ID:{sample}".format(sample=i) for i in per_ref_samples]),
    star_out_prefix = os.path.join(ana_home, "star_mapped_{ref}".format(ref = wildcards.ref), "")
    return {
        "per_ref_samples" : per_ref_samples,
        "sequence" : sequence,
        "RGline" : RGline,
        "star_out_prefix" : star_out_prefix
    }
rule star_mapping:
# TODO: using read2, read2 has CB UB
# TODO: take care of overlapping
    input:
        #RNAprep = expand(rules.mend_umi.output, sample=sample_table.index),
        #index = config["reference"]["star"]["mm10_B6"]
        unpack(star_mapping_input)
    output:
        os.path.join(ana_home, "star_mapped_{ref}", "Aligned.sortedByCoord.out.bam")
    params:
        # can't use unpack in params
        star_mapping_params
    threads: 10
    message: "---> star mapping on {threads} cores."
    conda: "../../envs/rna_tools.yaml"
    shell:
        # file name prefix need "/"
        # "params[0]" to solve bug https://github.com/snakemake/snakemake/issues/1171
        """
        STAR --runThreadN 8 --genomeDir {input.index} \
         --readFilesIn {params[0][sequence]} --readFilesType Fastx --readFilesCommand zcat \
         --outSAMattrRGline {params[0][RGline]} --outFileNamePrefix {params[0][star_out_prefix]} \
         --outSAMtype BAM Unsorted --outReadsUnmapped Fastx \
         --soloType CB_UMI_Simple --soloCBlen 16 --soloUMIlen 8 --soloBarcodeMate 2 \
         --soloFeatures Gene Velocyto GeneFull \
         --outSAMattributes CB UB
        """
# def star_mapping_input(wildcards):
#     """
#     TODO: make a real group/aggregate mode
#     """
#     per_ref_samples = sample_table.loc[sample_table["ref"] == wildcards.ref].index if "ref" in sample_table.columns else sample_table.index # global ref means all samples
#     return {
#         "RNAprep" : expand(rules.mend_umi.output, sample=per_ref_samples),
#         "index" : config["reference"]["star"][wildcards.ref] if wildcards.ref in config["reference"]["star"] else "NoSTARIndexFile.txt"
#     }
# def star_mapping_params(wildcards):
#     per_ref_samples = sample_table.loc[sample_table["ref"] == wildcards.ref].index if "ref" in sample_table.columns else sample_table.index # global ref means all samples
#     # string that defines the input files for STAR
#     sequence = ",".join([os.path.join(ana_home, "umi_uBAM", "{sample}.bam").format(sample=i)
#         for i in per_ref_samples]),
#     # string that defines the read groups for output sam
#     RGline = " , ".join(["ID:{sample}".format(sample=i) for i in per_ref_samples]),
#     star_out_prefix = os.path.join(ana_home, "star_mapped_{ref}".format(ref = wildcards.ref), "")
#     return {
#         "per_ref_samples" : per_ref_samples,
#         "sequence" : sequence,
#         "RGline" : RGline,
#         "star_out_prefix" : star_out_prefix
#     }
# rule star_mapping:
#     input:
#         #RNAprep = expand(rules.mend_umi.output, sample=sample_table.index),
#         #index = config["reference"]["star"]["mm10_B6"]
#         unpack(star_mapping_input)
#     output:
#         os.path.join(ana_home, "star_mapped_{ref}", "Aligned.sortedByCoord.out.bam")
#     params:
#         # can't use unpack in params
#         star_mapping_params
#     threads: 10
#     message: "---> star mapping on {threads} cores."
#     conda: "../../envs/rna_tools.yaml"
#     shell:
#         # file name prefix need "/"
#         # "params[0]" to solve bug https://github.com/snakemake/snakemake/issues/1171
#         """
#         STAR --runThreadN 8 --genomeDir {input.index} \
#          --readFilesIn {params[0][sequence]} --readFilesType SAM SE \
#          --readFilesCommand samtools view --readFilesSAMattrKeep UB \
#          --outSAMattrRGline {params[0][RGline]} --outFileNamePrefix {params[0][star_out_prefix]} \
#          --outSAMtype BAM SortedByCoordinate --outReadsUnmapped Fastx
#         """