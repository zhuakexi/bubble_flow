star_out_prefix = os.path.join(ana_home, "star_mapped", "")
def star_files_manifest_input(wildcards):
    per_ref_samples = sample_table.loc[sample_table["ref"] == wildcards.ref].index if "ref" in sample_table.columns else sample_table.index # global ref means all samples
    return expand(rules.mend_umi.output, sample=per_ref_samples)
def star_files_manifest_params(wildcards):
    per_ref_samples = sample_table.loc[sample_table["ref"] == wildcards.ref].index if "ref" in sample_table.columns else sample_table.index # global ref means all samples
    return per_ref_samples
rule star_files_manifest:
    input:
        unpack(star_files_manifest_input)
    params:
        # can't use unpack in params
        star_files_manifest_params
    output:
        os.path.join(ana_home, "star_mapped_{ref}", "files_manifest.tsv")
    run:
        with open(output[0], "wt") as f:
            text = "\n".join(
                ["{sequence}\t-\tID:{sample}\n".format(sample=sample, sequence=sequence) for sample, sequence in zip(params[0], input)]
            )
            f.write(text)
def star_mapping_input(wildcards):
    """
    TODO: make a real group/aggregate mode
    """
    return {
        "readFilesManifest" : expand(rules.star_files_manifest.output, ref=wildcards.ref)[0],
        "index" : config["reference"]["star"][wildcards.ref] if wildcards.ref in config["reference"]["star"] else "NoSTARIndexFile.txt"
    }
def star_mapping_params(wildcards):
    star_out_prefix = os.path.join(ana_home, "star_mapped_{ref}".format(ref = wildcards.ref), "")
    return {
        "star_out_prefix" : star_out_prefix
    }
rule star_mapping:
    input:
        #RNAprep = expand(rules.mend_umi.output, sample=sample_table.index),
        #index = config["reference"]["star"]["mm10_B6"]
        unpack(star_mapping_input)
    output:
        temp(os.path.join(ana_home, "star_mapped_{ref}", "Aligned.out.bam"))
    params:
        # can't use unpack in params
        star_mapping_params
    threads: config["cpu"]["star"]
    resources:
        mem_per_cpu = config["mem_G"]["star"],
        partition = config["partition"]["star"]
    message: "---> star mapping on {threads} cores."
    conda: "../../envs/rna_tools.yaml"
    shell:
        # file name prefix need "/"
        # "params[0]" to solve bug https://github.com/snakemake/snakemake/issues/1171
        """
        STAR --runThreadN {threads} --genomeDir {input.index} \
         --readFilesManifest {input.readFilesManifest} --readFilesType SAM SE \
         --readFilesCommand samtools view  \
         --outSAMattributes NH HI AS nM RG --readFilesSAMattrKeep UB \
         --outFileNamePrefix {params[0][star_out_prefix]} \
         --outSAMtype BAM Unsorted --outReadsUnmapped Fastx
        """
rule star_mapping_sort:
    input:
        os.path.join(ana_home, "star_mapped_{ref}", "Aligned.out.bam")
    output:
        os.path.join(ana_home, "star_mapped_{ref}", "Aligned.out.sorted.bam")
    params:
        sort_tmp_prefix = os.path.join(ana_home, "star_mapped_{ref}", "samsort.tmp")
    threads: config["cpu"]["sortBAM"]
    resources:
        mem_per_cpu = config["mem_G"]["sortBAM"],
        partition = config["partition"]["star_mapping_sort"]
    conda: "../../envs/rna_tools.yaml"
    shell:
        """
        samtools sort -@ {threads} -m {resources.mem_per_cpu}G -T {params.sort_tmp_prefix} \
        -O BAM --write-index -o {output} {input}
        """