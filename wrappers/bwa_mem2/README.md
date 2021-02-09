# Wrapper for bwa-mem2

Customed for dip-c. Change on your demand.
## Example:
Add an entry in your Snakefile like below.

"--use-conda" will take care of the environment.
```
rule bwa_mem:
    input: 
        # PE or SE mode, order is not important.
        "FASTQ1 FASTQ2 .fa" or
        "FASTQ .fa" 
    output:
        "ALIGMENT .sam"
    log:
        "LOG DIR" # required 
    params:
        index = "PATH TO BWA INDEX .fa" # required,
        extra = "CUSTOME ARGUMENTS FOR BWA" # required
    threads: 
        int # 12 or larger is meaningless
    wrapper:
      "file://wrappers/zhuakexi/bwa_mem2" 
```