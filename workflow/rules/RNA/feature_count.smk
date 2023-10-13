def feature_count_input(wildcards):
    return {
        "annotation" : config["reference"]["annotation"][wildcards.ref] if wildcards.ref in config["reference"]["annotation"] else "NoAnnotationIndexFile.txt",
        "bam" : rules.star_mapping_sort.output[0].format(ref=wildcards.ref)
        }
rule feature_count:
    input: 
        unpack(feature_count_input)
        #rules.star_mapping.output # using flag file to keep in line
    output:
        gene_assigned = os.path.join(ana_home, "count_gene_{ref}", "gene_assigned"),
        bam = temp(os.path.join(ana_home, "count_gene_{ref}", "Aligned.out.sorted.bam.featureCounts.bam"))
    log:
        result = os.path.join(ana_home, "logs", "count_{ref}.result"),
        log = os.path.join(ana_home, "logs", "count_{ref}.log")
    conda: "../../envs/rna_tools.yaml"
    shell:
        """
        featureCounts -a {input.annotation} -o {output.gene_assigned} -R BAM {input.bam} \
         -T 4 -Q 30 -t gene -g gene_name 2>{log.log} 1>{log.result}
        """
rule sort_count:
    input: rules.feature_count.output.bam # this only for dependency keeping. use fC_bam_gene in fact
    output:
        os.path.join(ana_home, "count_gene_{ref}", "samsort.bam")
    params:
        sort_tmp_prefix = os.path.join(ana_home, "count_gene_{ref}", "samsort.tmp")
    threads: config["cpu"]["sortBAM"]
    conda: "../../envs/rna_tools.yaml"
    resources:
        mem_per_cpu = config["mem_G"]["sortBAM"]
    shell:
        '''
        samtools sort -@ {threads} -m {resources.mem_per_cpu}G -T {params.sort_tmp_prefix} \
        -O BAM --write-index -o {output} {input}
        '''
rule matrix_count:
    input:
        rules.sort_count.output
    output:
        os.path.join(ana_home, "count_matrix_{ref}", "counts.gene.tsv.gz")
    params:
        r"--per-gene --per-cell --extract-umi-method=tag --umi-tag UB --cell-tag RG --gene-tag=XT --assigned-status-tag=XS --wide-format-cell-counts"
    conda: "../../envs/rna_tools.yaml"
    shell:
        '''
        umi_tools count {params} -I {input} -S {output}
        '''
