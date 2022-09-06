from sqlite3 import paramstyle
from subprocess import check_output
def sam2segW(cfg, input_, params, output, log):
    """
    Input:
        input_: must have
            sam: sam file path, str
            sex: `X`,`Y`,`XY`,`XX`, str
            snp: `using` for using, str
    """
    segstr = params.split("_")
    #if params["sex"] == "X" and params["snp"]=="using":
    if ("X" in segstr) and ("SNP" in segstr):
        # haploid and X, using snp
        # add snp phase col, remove chrY reads
        check_output(
            """{k8} {js} sam2seg -v {snp} {input_} 2> {log} \
            | {k8} {js} chronly -y - \
            | sed 's/-/+/g' \
            | gzip > {output}\
            """.format(
                k8 = cfg["software"]["k8"],
                js = cfg["software"]["js"],
                snp = cfg["reference"]["snp"],
                input_ = input_,
                output = output,
                log = log
            ),
            shell=True)
    #elif params["sex"] == "Y" and params["snp"]=="using":

    elif ("Y" in segstr) and ("SNP" in segstr):
        # haploid and Y, using snp
        # add snp phase col, remove chrX reads
        # note: gamete has Y chromosome only
        #   must remove X chromosome, otherwise 3d build defects
        check_output(
            """{k8} {js} sam2seg -v {snp} {input_} 2> {log} \
            | {k8} {js} chronly -r '^(chr)?([0-9]+|[Y])$' - \
            | {k8} {js} bedflt {PAR} - \
            | sed 's/-/+/g' \
            | gzip > {output}\
            """.format(
                k8 = cfg["software"]["k8"],
                js = cfg["software"]["js"],
                snp = cfg["reference"]["snp"],
                PAR = cfg["reference"]["par"],
                input_ = input_,
                output = output,
                log = log
            ),
            shell=True)
    #elif params["sex"] == "X" and params["snp"]!="using":
    elif ( ("X" in segstr) or ("XX" in segstr) ) and ("SNP" not in segstr):
        # 1. haploid and X, using snp
        # 2. diploid and XX, using snp
        # add snp phase col, remove chrY reads
        check_output(
            """{k8} {js} sam2seg {input_} 2> {log} \
            | {k8} {js} chronly -y - \
            | sed 's/-/+/g' \
            | gzip > {output}\
            """.format(
                k8 = cfg["software"]["k8"],
                js = cfg["software"]["js"],
                input_ = input_,
                output = output,
                log = log
            ),
            shell=True)
    #elif params["sex"] == "Y" and params["snp"]!="using":
    elif ("Y" in segstr) and ("SNP" not in segstr):
        # haploid and Y, using snp
        # add snp phase col, remove chrX reads
        # note: gamete has Y chromosome only
        #   must remove X chromosome, otherwise 3d build defects
        check_output(
            """{k8} {js} sam2seg {input_} 2> {log} \
            | {k8} {js} chronly -r '^(chr)?([0-9]+|[Y])$' - \
            | {k8} {js} bedflt {PAR} - \
            | sed 's/-/+/g' \
            | gzip > {output}\
            """.format(
                k8 = cfg["software"]["k8"],
                js = cfg["software"]["js"],
                PAR = cfg["reference"]["par"],
                input_ = input_,
                output = output,
                log = log
            ),
            shell=True)
    elif ("XY" in segstr) and ("SNP" in segstr):
        # diploid and XY, using snp
        # add snp phase col, remove XY pseudoautosome reads
        check_output(
            """{k8} {js} sam2seg {input_} 2> {log} \
            | {k8} {js} chronly - \
            | {k8} {js} bedflt {PAR} - \
            | sed 's/-/+/g' \
            | gzip > {output}\
            """.format(
                k8 = cfg["software"]["k8"],
                js = cfg["software"]["js"],
                PAR = cfg["reference"]["par"],
                input_ = input_,
                output = output,
                log = log
            ),
            shell=True)
    else:
        raise ValueError("sam2segW: wrong value in sex or snp col in sample_table.csv")
sam2segW(
    snakemake.config,
    snakemake.input,
    snakemake.params[0],
    snakemake.output,
    snakemake.log
)