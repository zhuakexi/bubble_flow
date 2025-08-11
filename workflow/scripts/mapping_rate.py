import json

import pysam
def mapping_rate(bam,threads=1):
    if bam is None:
        return {"primary mapped":0, "mapped":0}
    bamstat = json.loads(pysam.flagstat(str(bam), "-O","json","-@",str(threads)))
    #print(bamstat)
    return {"primary mapped":bamstat["QC-passed reads"]["primary mapped"]/bamstat["QC-passed reads"]["total"],
            "mapped":bamstat["QC-passed reads"]["mapped"]/bamstat["QC-passed reads"]["total"]}
def store_mapping_rate(bam, sample_name, outfile):
    """
    Store mapping rate in a file.
    """
    rate = {
        sample_name : mapping_rate(bam)
    }
    with open(outfile, "w") as f:
        f.write(json.dumps(rate, indent=4))
store_mapping_rate(
    snakemake.input.get("bam"),
    snakemake.wildcards["sample"],
    snakemake.output.get("json")
)