import os
# qualitive statistic of experiments 
rule pairs_info:
    input:
        pairs_log = rules.seg2pairs.output[1],
        pairs = rules.seg2pairs.output[0],
        raw_pairs_log = rules.raw_pairs.output[1],
        raw_pairs = rules.raw_pairs.output[0]
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
        if [[ $(zcat {input.pairs} | grep -v {params.comment} | wc -l) -eq 0 ]];then
            intra=0
        else
            intra=$(zcat {input.pairs} | grep -v {params.comment} | awk '{params.intra}') # percent intra
        fi
        if [[ $(zcat {input.raw_pairs} | grep -v {params.comment} | wc -l) -eq 0 ]];then
            raw_intra=0
        else
            raw_intra=$(zcat {input.raw_pairs} | grep -v {params.comment} | awk '{params.intra}') # percent intra before dedup
        fi
        if [[ $(zcat {input.pairs} | grep -v {params.comment} | wc -l) -eq 0 ]];then
            phased=0
        else
            phased=$(zcat {input.pairs} | grep -v {params.comment} | awk '{params.phased}') # percent leg phased
        fi
        echo {wildcards.sample},$raw_con,$raw_intra,$dup_rate,$con,$intra,$phased > {output}
        """
rule collect_info:
    # collect hic pairs info and reads info
    # TODO: write a modern version
    # TODO: separate reads info and pairs info(maybe)
    input: 
        pairs_info = expand(rules.pairs_info.output, sample=sample_table.index), # this is the string content
        # results from rules below are stored in rd directory in json format. collect them with task_stat
        reads = expand(rules.count_reads.output, sample=sample_table.index),
        dna_reads = expand(rules.count_dna_reads.output, sample=sample_table.index),
        rna_reads = expand(rules.count_rna_reads.output, sample=sample_table.index),
        rna_c1_reads = expand(rules.count_rna_c1_reads.output, sample=sample_table.index),
        rna_c2_reads = expand(rules.count_rna_c2_reads.output, sample=sample_table.index),
        raw_fq_path = expand(rules.store_raw_fq_path.output, sample=sample_table.index),
        mapping_rate = expand(rules.add_mapping_rate.output.json, sample=sample_table.index)
    output:
        os.path.join(ana_home, "contacts_info.csv")
    threads: 1
    resources: nodes = 1
    message: "------> collect info..."
    shell: 
        """
        echo "name,raw_contacts,raw_intra,dup_rate,contacts,intra,phased_ratio" > {output}
        cat {input.pairs_info} >> {output}
        """