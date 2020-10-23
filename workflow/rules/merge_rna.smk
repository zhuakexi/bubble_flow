# merge reads
# for round 1 analysis rna_cell_list = cell_list
import pandas
RNA_SAMPLES = pandas.read_tsv("config/rna_cell_list.tsv").iloc[:,0]

# io heavy 
localrules: merge_rna

rule merge_rna:
    input:
        expand(rules.extract_cell_name.output, sample=RNA_SAMPLES)
    output:
        os.path.join(config["dirs"]["merged_rna"], "all.rna.fq")
    message: "rna_merging: %d cells." % len(RNA_SAMPLES)
    shell:
        """
        cat {input} > {output}
        """
