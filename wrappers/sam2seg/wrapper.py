""" Snakemake wrapper for hickit sam2seg """
__author__ = "Y Chi"
__copyright__ = "Copyright 2020, Y Chi"
__email__ = "zhuakexi@126.com"
__license__ = "MIT"

# for hickit don't have conda package, give path to executable in params
# behave differently on sex and snp switch

from snakemake.shell import shell
input = snakemake.input # the sam file
sex = snakemake.params.sex
snp = snakemake.params.snp
snp_file = snakemake.params.snp_file
par_file = snakemake.params.par_file
k8 = snakemake.params.k8
js = snakemake.params.js
log = snakemake.log
output = snakemake.output

if snp == "using":
    if sex == "female":
        shell(
            " {k8} {js} sam2seg -v {snp_file} {input} 2> {log} "
            " | {k8} {js} chronly -y - "
            " | sed 's/-/+/g' "
            " | gzip > {output} "
            )
    elif sex == "male":
        # filt out par region
        shell(
            " {k8} {js} sam2seg -v {snp_file} {input} 2> {log} " 
            " | {k8} {js} chronly - "
            " | {k8} {js} bedflt {par_file} - "
            " | sed 's/-/+/g' "
            " |gzip > {output} "
            )
    else:
        raise ValueError("sex must be female or male and set in config.yaml")
else: # without snp, no impute either
    if sex == "female":
        shell(
            " {k8} {js} sam2seg {input} 2> {log} " 
            " | {k8} {js} chronly -y -"
            " | sed 's/-/+/g' "
            " | gzip > {output} "        
            )
    elif sex == "male":
        shell(
           " {k8} {js} sam2seg {input} 2> {log} " 
            " | {k8} {js} chronly -"
            " | {k8} {js} bedflt {par_file} - "
            " | sed 's/-/+/g' "
            " | gzip > {output} " 
        )
    else:
        raise ValueError("sex must be female or male and set in config.yaml")