rule pre_seg:
    # get snp annoted, chronly, par filtered
    # .seg file for all input, even haploid
    input: 
        rules.bwa_mem.output
    output:
        os.path.join(
            ana_home, 
            "pre_seg",
            "{sample}.seg.gz")
    log:
        log_path("snp.log")
    shell:
        """
        {k8} {js} sam2seg -v {snp} {input} 2> {log} \
         | {k8} {js} chronly - \
         | {k8} {js} bedflt {PAR} - \
         | gzip > {output}
        """
checkpoint sex_assignment:
    pass