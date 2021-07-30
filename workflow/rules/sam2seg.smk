rule dipfem_sam2seg:
    # for diploid, female 
    # remove all y reads
    # essential for hickit
    input:
        rules.bwa_mem.output
    output:
        os.path.join(ana_home, "seg", "dipfem_seg", "{sample}.seg.gz")
    shell:
        """
        {k8} {js} sam2seg -v {snp} {input} 2> /dev/null \
         | {k8} {js} chronly -y - \
         | sed 's/-/+/g' \
         | gzip > {output}
        """
rule dipmal_sam2seg:
    # for diploid male, 
    # filt out PAR region
    input:
        rules.bwa_mem.output
    output:
        os.path.join(ana_home, "seg","dipmal_seg", "{sample}.seg.gz")
    shell:
        """
        {k8} {js} sam2seg -v {snp} {input} 2> /dev/null \
         | {k8} {js} chronly - \
         | {k8} {js} bedflt {PAR} - \
         | sed 's/-/+/g' \
         | gzip > {output}
        """
rule hapfem_sam2seg:
    # for haploid female(oocyte)
    # doesn't use snp
    # remove all y reads
    input:
        rules.bwa_mem.output
    output:
        os.path.join(ana_home, "seg", "hapfem_seg", "{sample}.seg.gz")
    shell:
        """
        {k8} {js} sam2seg {input} 2> /dev/null \
         | {k8} {js} chronly -y - \
         | sed 's/-/+/g' \
         | gzip > {output}
        """
rule hapmal_sam2seg:
    # for haploid male(germ)
    # dosen't use snp
    # filt out PAR region
    input:
        rules.bwa_mem.output
    output:
        os.path.join(ana_home, "seg","hapmal_seg", "{sample}.seg.gz")
    shell:
        """
        {k8} {js} sam2seg {input} 2> /dev/null \
         | {k8} {js} chronly - \
         | {k8} {js} bedflt {PAR} - \
         | sed 's/-/+/g' \
         | gzip > {output}
        """