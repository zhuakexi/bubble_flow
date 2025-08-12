# need k8, js, hires, rd, snp
def pre_seg_input(wildcards):
    ref = sample_table.loc[wildcards.sample, "ref"] if "ref" in sample_table.columns else config["global_ref"]
    return {
        #"sam" : rules.bwa_mem.output.get(sample = wildcards.sample).output[0],
        "sam" : rules.bwa_mem.output[0].format(sample = wildcards.sample),
        "snp_file" : config["reference"]["snp"][ref] if ref in config["reference"]["snp"] else "NoSNPFile.txt",
        "par_file" : config["reference"]["par"][ref] if ref in config["reference"]["par"] else "NoPARFile.txt"}
rule pre_seg:
    # get snp annoted, chronly, par filtered
    # .seg file for all input, even haploid
    input: 
        unpack(pre_seg_input)
    output:
        os.path.join(
            ana_home, 
            "pre_seg",
            "{sample}.seg.gz")
    params:
        tmp_dir = os.path.join(ana_home, "tmp")
    log:
        log_path("snp.log")
    conda: "../../envs/samtools.yaml"
    threads: 5
    shell:
        """ samtools sort -T {params.tmp_dir}/{wildcards.sample}_preseg -n -@4 -O SAM {input.sam} \
         | {k8} {js} sam2seg -v {input.snp_file} - 2> {log} \
         | {k8} {js} chronly - \
         | {k8} {js} bedflt {input.par_file} - \
         | sed 's/-/+/g' \
         | gzip > {output}
        """
checkpoint sample_check:
    input:
        rules.pre_seg.output
    output:
        os.path.join(ana_home, "info","{sample}.seg_stat.info")
    conda:
        "../../envs/hires.yaml"
    shell:
        """
        python {hires} seg_stat \
            -o {output} \
            -rd {rd} \
            {input}
        """