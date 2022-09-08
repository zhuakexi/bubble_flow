from cmath import log
from subprocess import check_output
def buildW(cfg, input_, ploidy, rep,  _4m, _1m, _200k, _50k, _20k, log):
    code ="""
        {{hickit}} -s{{rep}} -M \
            -i {{input}} {split} \
            -b4m -O {{_3dg_4m}} -b1m -O {{_3dg_1m}} \
            -b200k -O {{_3dg_200k}} \
            -D5 -b50k -O {{_3dg_50k}} \
            -D5 -b20k -O {{_3dg_20k}} 1> {{log}} 2>&1
        """
    if ploidy == "2C":
        code = code.format(split = "")
    elif ploidy == "1C":
        code = code.format(split = "-S")
    else:
        raise ValueError("buildW: wrong ploidy.")
    code = code.format(
        hickit = cfg["software"]["hickit"],
        rep = rep,
        input = input_,
        _3dg_4m = _4m,
        _3dg_1m = _1m,
        _3dg_200k = _200k,
        _3dg_50k = _50k,
        _3dg_20k = _20k,
        log = log)
    print(code)
    check_output(
        code,
        shell = True
    )
    return 0
buildW(
    snakemake.config,
    snakemake.input.get("pairs"),
    snakemake.params[0],
    snakemake.wildcards["rep"],
    snakemake.output.get("_3dg_4m"),
    snakemake.output.get("_3dg_1m"),
    snakemake.output.get("_3dg_200k"),
    snakemake.output.get("_3dg_50k"),
    snakemake.output.get("_3dg_20k"),
    snakemake.log
    )