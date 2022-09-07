from sqlite3 import paramstyle
from subprocess import check_output
def sam2segW(cfg, sam, mode_deduction, params, output, log):
    """
    Input:
        cfg: softwares path
        mode_deduction: mode str deducted from sample_checking, must be [ploidy]_[sex]_[snp], eg:
            2C_lY_
        params: per sample mode assignment from config or sample_table, same as mode_deduction.
        output: output file path
        log: log file path
    Note:
        ploidy: `2C` `1C` ``
        sex: `lY` `hY` ``
        snp: `NO` `SNP`
        deduction SNP is always ``, ploidy and sex can't be ``.
    """
    # params assignment first, if missing, using deduction
    ploidy, sex, snp = [ e if e != "" else mode_deduction.split("_")[i] for i, e in enumerate(params.split("_")) ]
    code =  """{{k8}} {{js}} {sam2seg} 2> {{log}} \
            | {{k8}} {{js}} {chrfilt} - \
            {bedfilt} \
            | sed 's/-/+/g' \
            | gzip > {{output}}\
            """
    if snp == "SNP":
        # add snp col in seg and pairs
        sam2seg = "sam2seg -v {snp} {input_}"
    else:
        sam2seg = "sam2seg {input_}"
    if ploidy == "1C":
        if sex == "hY":
            # high Y
            # remove X reads, 
            # filter out pseudoautosome region (don't know why, copy from my mouse sperm code")
            # note: gamete has Y chromosome only
            #   must remove X chromosome, otherwise 3d build defects
            chrfilt = "chronly -r '^(chr)?([0-9]+|[Y])$'"
            bedfilt = "| {k8} {js} bedflt {PAR} - "
        elif sex == "lY":
            # low Y
            # remove Y reads
            chrfilt = "chronly -y"
            bedfilt = ""
    elif ploidy == "2C":
        if sex == "hY":
            # remove pseudoautosome region
            chrfilt = "chronly"
            bedfilt = "| {k8} {js} bedflt {PAR} - "
        elif sex == "lY":
            # remove Y chr reads
            chrfilt = "chronly -y"
            bedfilt = ""
    else:
        raise ValueError("sam2segW: wrong sex or ploidy in params mode or mode_deduction")
    code = code.format(
        sam2seg=sam2seg,
        chrfilt=chrfilt,
        bedfilt = bedfilt)
    print(code)
    code = code.format(
            k8 = cfg["software"]["k8"],
            js = cfg["software"]["js"],
            snp = cfg["reference"]["snp"],
            PAR = cfg["reference"]["par"],
            input_ = sam,
            output = output,
            log = log
    )
    return code
sam2segW(
    snakemake.config,
    snakemake.input.get("sam"),
    snakemake.input.get("mode_deduction"),
    snakemake.params[0],
    snakemake.output,
    snakemake.log
)