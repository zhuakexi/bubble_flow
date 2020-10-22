rule pairs2cons:
    input:
        hickit_pairs_to_con = "/share/home/ychi/software/dip-c/scripts/hickit_pairs_to_con.sh",
        hickit_impute_pairs_to_con = "/share/home/ychi/software/dip-c/scripts/hickit_impute_pairs_to_con.sh",
        pairs = rules.clean_pairs.output.clean123,
        impute_pairs = rules.impute.output.impute_pairs
    resources:
        nodes = 1
    output:
        cons = "/share/Data/ychi/repo/con/{sample}.con.gz",
        impute_cons = "/share/Data/ychi/repo/con/{sample}.impute.con.gz"
    shell:
        """
        #convert from hickit to dip-c formats
        {input.hickit_pairs_to_con} {input.pairs}
        {input.hickit_impute_pairs_to_con} {input.impute_pairs}
        
        #move to right place, {output} not give to shell.
        #snakemake do it?
        mv /share/Data/ychi/repo/clean123/{wildcards.sample}.c123.con.gz {output.cons}
        mv /share/Data/ychi/repo/impute/{wildcards.sample}.impute.con.gz {output.impute_cons}
        """
