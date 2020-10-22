rule sam2seg:
    input:
        snp_file="/share/Data/ychi/genome/snp_file/gm12878/NA12878.phased_SNP.tsv",
        aln = "/share/Data/ychi/repo/sam/{sample}.aln.sam.gz",
        par_file = "/share/Data/ychi/genome/GRCh38.chrY.PAR.bed"
    output:
        seg = "/share/Data/ychi/repo/seg/{sample}.contacts.seg.gz",
        seg_log = "/share/Data/ychi/repo/seg/{sample}.contacts.seg.log"
    shell:
        """
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate hires
        set -u

        if [ "{sex}" == "female" ]
        then
        {k8} {js} sam2seg -v {input.snp_file} {input.aln} 2> {output.seg_log} | \
        {k8} {js} chronly -y - |\
        sed 's/-/+/g' | gzip > {output.seg}
        else
        {k8} {js} sam2seg -v {input.snp_file} {input.aln} 2> {output.seg_log} | \
        {k8} {js} chronly - | {k8} {js} bedflt {input.par_file} - | \
        sed 's/-/+/g' | gzip > {output.seg}
        fi
        """   