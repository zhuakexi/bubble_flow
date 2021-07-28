import os
rule collect_info:
    input: expand(rules.pairs_info.output, sample=sample_table.index)
    output:
        os.path.join(ana_home, "contacts_info.csv")
    threads: 1
    resources: nodes = 1
    message: "------> collect info..."
    shell: 
        """
        echo "name,raw_contacts,raw_intra,dup_rate,contacts,intra,phased_ratio" > {output}
        cat {input} >> {output}
        """