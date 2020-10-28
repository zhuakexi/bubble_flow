#3rd step
#extract segments from mapping results
k8 = config["software"]["k8"]
js = config["software"]["js"]
rule sam2seg:
    input:
        snp = config["reference"]["snp"],
        aln = os.path.join(config["dirs"]["sam"], "{sample}.aln.sam.gz"),
        par = os.path.join(config["reference"]["par"])
    output: os.path.join(config["dirs"]["seg"], "{sample}.seg.gz")
    resources: nodes=1
    log: config["logs"].format("sam2seg.log")
    message: "sam2seg : {wildcards.sample} : {threads} cores"
    shell:
        """
        if [ {snp} == using ]
        then
            if [ {sex} == female ]
            then
                {k8} {js} sam2seg -v {input.snp} {input.aln} 2> {log} | \
                {k8} {js} chronly -y - |\
                sed 's/-/+/g' | gzip > {output}
            else
                {k8} {js} sam2seg -v {input.snp} {input.aln} 2> {log} | \
                {k8} {js} chronly - | {k8} {js} bedflt {input.par} - | \
                sed 's/-/+/g' | gzip > {output}
            fi
        else
            if [ {sex} == female ]
            then
                {k8} {js} sam2seg {input.aln} 2> {log} |\
                {k8} {js} chronly -y -|\
                sed 's/-/+/g' | gzip > {output}
            else
                {k8} {js} sam2seg -v {input.snp} {input.aln} 2> {log} | \
                {k8} {js} chronly - | {k8} {js} bedflt {input.par} - | \
                sed 's/-/+/g' | gzip > {output}
            fi
        fi
        """