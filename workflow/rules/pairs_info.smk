# qualitive statistic of experiments 
rule pairs_info:
    input:
        pairs_log = rules.seg2pairs.log,
        pairs = rules.seg2pairs.output,
        raw_pairs_log = rules.raw_pairs.log,
        raw_pairs = rules.raw_pairs.output
    output:
        #log_path("contacts.info")
        os.path.join(ana_home, "info","{sample}.basic.info")
    params:
        dedup = r'dedup',
        comment = r'^#',
        intra = r'{sum++;if($2==$4){intra++}}END{print intra*100/sum}',
        phased = r'{sum+=2;if($8!="."){phased++};if($9!="."){phased++}}END{print phased*100/sum}'
    threads: 1
    resources: nodes=1
    message: "pairs_info : {wildcards.sample} : {threads} cores"
    shell:
        """
        dup_line=$(grep {params.dedup} {input.pairs_log}) # extract critic line in log
        dup_rate=${{dup_line%%\%*}};dup_rate=${{dup_rate##* }} # extract dup_rate
        dup_num=${{dup_line%% /*}};dup_num=${{dup_num##* }} #dup_num
        raw_con=${{dup_line##* }} # all contacts
        con=$((raw_con-dup_num)) # non-dup contacts
        intra=$(zcat {input.pairs} | grep -v {params.comment} | awk '{params.intra}') # percent intra
        raw_intra=$(zcat {input.raw_pairs} | grep -v {params.comment} | awk '{params.intra}') # percent intra before dedup
        phased=$(zcat {input.pairs} | grep -v {params.comment} | awk '{params.phased}') # percent leg phased
        echo {wildcards.sample},$raw_con,$raw_intra,$dup_rate,$con,$intra,$phased > {output}
        """