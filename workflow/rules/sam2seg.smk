k8 = config["software"]["k8"]
js = config["software"]["js"]
rule sam2seg:
    input:
        snp = os.path.join(config["reference"]["snp"], "NA12878.phased_SNP.tsv"),
        aln = os.path.join(config["dirs"]["sam"], "{sample}.aln.sam.gz"),
        par = os.path.join(config["reference"]["par"])
    output: os.path.join(config["dirs"]["seg"], "{sample}.seg.gz")
    log: os.path.join(config["logs"], "{sample}.log")
    shell:
        """
        if [ "{sex}" == "female" ]
        then
        {k8} {js} sam2seg -v {input.snp} {input.aln} 2>> {log} | \
        {k8} {js} chronly -y - |\
        sed 's/-/+/g' | gzip > {output}
        else
        {k8} {js} sam2seg -v {input.snp} {input.aln} 2>> {log} | \
        {k8} {js} chronly - | {k8} {js} bedflt {input.par} - | \
        sed 's/-/+/g' | gzip > {output}
        fi
        """   