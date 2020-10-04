# bubble_flow: the hires pipeline            
# author CY                   
# date 2020/9/22                   


#all cells from input folder
import os
#SAMPLES = os.listdir("/share/Data/ychi/repo/needdo")
with open("/share/Data/ychi/repo/cell_list") as f:
    SAMPLES = [line.strip() for line in f]
hickit = "/share/home/ychi/software/hickit/hickit"
k8 = "/share/home/ychi/software/hickit/k8"
js = "/share/home/ychi/software/hickit/hickit.js"
hires = "/share/home/ychi/software/hires-utils/hires.py"
sex = "female"


# --------- working rules ---------

#split DNA and RNA        
rule split:
    input:
        "/share/Data/ychi/raw/{sample}/{sample}_R1.fq.gz",
        "/share/Data/ychi/raw/{sample}/{sample}_R2.fq.gz"
    output: 
        DNA_R1="/share/Data/ychi/repo/dna/{sample}.dna.R1.fq.gz",
        DNA_R2="/share/Data/ychi/repo/dna/{sample}.dna.R2.fq.gz",
        RNA_R1="/share/Data/ychi/repo/rna/{sample}.rna.R1.fq.gz",
        RNA_R2="/share/Data/ychi/repo/rna/{sample}.rna.R2.fq.gz",
        
    threads: 12
    resources:
        nodes = 12
        
    params:
        adapter=r"XGGTTGAGGTAGTATTGCGCAATG;o=20"
    shell:
        """
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate hires
        set -u
        cutadapt -G '{params.adapter}' -j {threads} --untrimmed-output {output.DNA_R1} --untrimmed-paired-output {output.DNA_R2} -o {output.RNA_R1} -p {output.RNA_R2} {input}
        set +u
        conda deactivate
        set -u
        """
rule cut_round2:
    input:
        RNA_R1 = rules.split.output.RNA_R1,
        RNA_R2 = rules.split.output.RNA_R2
    output: 
        RNA_R1="/share/Data/ychi/repo/rna/{sample}.rna.clean.R1.fq.gz",
        RNA_R2="/share/Data/ychi/repo/rna/{sample}.rna.clean.R2.fq.gz"
        
    threads: 12
    resources:
        nodes = 12
        
    params:
        adapter=r"XNNNNNNNNTTTTTTTTTTTTTTT;o=18"
    shell:"""
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate hires
        set -u
        cutadapt --action=none --discard-untrimmed -G '{params.adapter}' -j {threads} -o {output.RNA_R1} -p {output.RNA_R2} {input}
        set +u
        conda deactivate
        set -u
        """
   
rule extract_umi:
    input:
        #RNA_R1="/share/Data/ychi/repo/rna/{sample}.rna.R1.fq.gz",
        #RNA_R2="/share/Data/ychi/repo/rna/{sample}.rna.R2.fq.gz"
        RNA_R1 = rules.cut_round2.output.RNA_R1,
        RNA_R2 = rules.cut_round2.output.RNA_R2
    output:
        umi1="/share/Data/ychi/repo/umi/umi.{sample}.rna.R1.fq.gz",
        umi2="/share/Data/ychi/repo/umi/umi.{sample}.rna.R2.fq.gz",
        unzip_umi1=temp("/share/Data/ychi/repo/RNA_all/umi.{sample}.rna.R1.temp.fq"),
        umi_by_cell = "/share/Data/ychi/repo/RNA_all/umi.{sample}.rna.R1.fq"
    resources:
        nodes = 1
    params:
        pattern=r"NNNNNNNN"
    shell: 
        """
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate hires
        set -u
        umi_tools extract -p {params.pattern} -I {input.RNA_R2} -S {output.umi2} --read2-in={input.RNA_R1} --read2-out={output.umi1}
        gunzip --force -c {output.umi1} > {output.unzip_umi1}
        sed 's/_/_{wildcards.sample}_/' {output.unzip_umi1} > {output.umi_by_cell}
        set +u
        conda deactivate 
        set -u
        """

rule bwa_map:
    input:
        ref_genome="/share/Data/ychi/genome/bwa_index/GRCh38/genome.fa",
        DNA1 = "/share/Data/ychi/repo/dna/{sample}.dna.R1.fq.gz",
        DNA2 = "/share/Data/ychi/repo/dna/{sample}.dna.R2.fq.gz",
    output:
        aln = protected("/share/Data/ychi/repo/sam/{sample}.aln.sam.gz")
    threads: 12
    resources:
        nodes = 12
    params:
        extra=r"-R '@RG\tID:{sample}\tPL:ILLUMINA\tSM:{sample}'",
    shell:
        """
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate hires
        set -u

        bwa mem -5SP -t{threads} {params.extra} {input.ref_genome} {input.DNA1} {input.DNA2} | gzip > {output.aln}

        set +u
        conda deactivate
        set -u
        """

rule sam2seg:
    input:
        snp_file="/share/Data/ychi/genome/snp_file/gm12878/NA12878.phased_SNP.tsv",
        aln = "/share/Data/ychi/repo/sam/{sample}.aln.sam.gz",
        par_file = "/share/Data/ychi/genome/GRCh38.chrY.PAR.bed"
    output:
        seg = "/share/Data/ychi/repo/seg/{sample}.contacts.seg.gz",
        seg_log = "/share/Data/ychi/repo/seg/{sample}.contacts.seg.log"
    shell:
        """
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate hires
        set -u

        if [ "{sex}" == "female" ]
        then
        {k8} {js} sam2seg -v {input.snp_file} {input.aln} 2> {output.seg_log} | \
        {k8} {js} chronly -y - |\
        sed 's/-/+/g' | gzip > {output.seg}
        else
        {k8} {js} sam2seg -v {input.snp_file} {input.aln} 2> {output.seg_log} | \
        {k8} {js} chronly - | {k8} {js} bedflt {input.par_file} - | \
        sed 's/-/+/g' | gzip > {output.seg}
        fi
        """     
rule seg2pairs:
    input:
        seg = rules.sam2seg.output.seg
    output:
        raw_pairs = "/share/Data/ychi/repo/raw_pairs/{sample}.raw.pairs.gz",
        raw_pairs_log = "/share/Data/ychi/repo/raw_pairs/{sample}.raw.pairs.log",
        pairs = "/share/Data/ychi/repo/pairs/{sample}.pairs.gz",
        pairs_log = "/share/Data/ychi/repo/pairs/{sample}.pairs.log"
    shell:
        """        
        #generate raw pairs for statistics
        {hickit} --dup-dist=0 -i {input.seg} -o - 2> {output.raw_pairs_log} | gzip > {output.raw_pairs}
        
        #generate real pairs
        {hickit} --dup-dist=500 -i {input.seg} -o - 2> {output.pairs_log} | gzip > {output.pairs}
        """
rule clean_pairs:
    input: 
        pairs = rules.seg2pairs.output.pairs,
        exon_index = "/share/home/ychi/software/hires-utils/bin_10k_FULL_index"
    output: 
        clean1= "/share/Data/ychi/repo/clean1/{sample}.c1.pairs.gz",
        clean12 = "/share/Data/ychi/repo/clean12/{sample}.c12.pairs.gz",
        clean123 = "/share/Data/ychi/repo/clean123/{sample}.c123.pairs.gz",
        clean13 = "/share/Data/ychi/repo/clean13/{sample}.c13.pairs.gz"
    log: "/share/Data/ychi/repo/log/{sample}.clean.log"
    threads: 8
    resources:
        nodes = 8
    message: "clean_pairs : {wildcards.sample} : {resources} cores"
    shell:
        """
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate hires
        set -u

        python {hires} clean_leg -t {threads} {input.pairs} -o {output.clean1} >> {log}
        python {hires} clean_isolated -t {threads} -o {output.clean12} {output.clean1} >> {log}
        python {hires} clean_splicing -r {input.exon_index} -o {output.clean123} {output.clean12} >> {log}
        python {hires} clean_splicing -r {input.exon_index} -o {output.clean13} {output.clean1} >> {log}

        set +u
        conda deactivate
        set -u
        """

rule impute:
    input:
        clean123 = rules.clean_pairs.output.clean123,
    output:
        impute_pairs = "/share/Data/ychi/repo/impute/{sample}.impute.pairs.gz",
        impute_pairs_log = "/share/Data/ychi/repo/impute/{sample}.impute.pairs.log",
        impute_val = "/share/Data/ychi/repo/impute_val/{sample}.impute.val",
        impute_val_log = "/share/Data/ychi/repo/impute_val/{sample}.val.log",
    resources:
        nodes = 1
    shell:
        """
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate hires
        set -u

        # impute phases
        {hickit} -i {input.clean123} -u -o - 2> {output.impute_pairs_log} | gzip > {output.impute_pairs}

        # estimate imputation accuracy by holdout
        {hickit} -i {input.clean123} --out-val={output.impute_val} 2> {output.impute_val_log}

        set +u
        conda deactivate
        set -u
        """
        
rule build:
    input:
        impute_pairs = "/share/Data/ychi/repo/impute/{sample}.impute.pairs.gz",
    output:
        _3dg_1m = "/share/Data/ychi/repo/3dg/{sample}.1m.{rep}.3dg",
        _3dg_200k = "/share/Data/ychi/repo/3dg/{sample}.200k.{rep}.3dg",
        _3dg_50k = "/share/Data/ychi/repo/3dg/{sample}.50k.{rep}.3dg",
        _3dg_20k = "/share/Data/ychi/repo/3dg/{sample}.20k.{rep}.3dg"
    resources:
        nodes = 1
    shell: 
        """
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate hires
        {hickit} -s{wildcards.rep} -M \
            -i {input.impute_pairs} -Sr1m -c1 -r10m -c2 \
            -b4m -b1m -O {output._3dg_1m} \
            -b200k -O {output._3dg_200k} \
            -D5 -b50k -O {output._3dg_50k} \
            -D5 -b20k -O {output._3dg_20k}
        set +u
        conda deactivate
        set -u
        """

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

rule clean3d:
    input:
        cons = rules.pairs2cons.output.cons,
        impute_cons = rules.pairs2cons.output.cons,
        _3dg_20k = rules.build.output._3dg_20k,
        dip_c = "/share/home/ychi/software/dip-c/dip-c",
        hickit_3dg_to_3dg_rescale_unit = "/share/home/ychi/software/dip-c/scripts/hickit_3dg_to_3dg_rescale_unit.sh"
    output:
        _3dg_20k_clean = "/share/Data/ychi/repo/clean3d/{sample}.clean3d.20k.{rep}.3dg" 
    resources:
        nodes = 1
    shell: 
        """
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate py2_env
        set -u

        {input.hickit_3dg_to_3dg_rescale_unit} {input._3dg_20k}
        {input.dip_c} clean3 -c {input.impute_cons} /share/Data/ychi/repo/3dg/{wildcards.sample}.20k.{wildcards.rep}.dip-c.3dg > {output._3dg_20k_clean}
        
        set +u
        conda deactivate
        set -u
        """

rule align3d:
    input:
        expand("/share/Data/ychi/repo/clean3d/{{sample}}.clean3d.20k.{rep}.3dg", rep = list(range(1,6)))
    output:
        aligned_3dg = directory("/share/Data/ychi/repo/aligned/{sample}.20k/"),
        #good = directory("/share/Data/ychi/repo/aligned/{sample}.20k/good/"),
        #bad = directory("/share/Data/ychi/repo/aligned/{sample}.20k/bad/"),
        #rmsdInfo = "/share/Data/ychi/repo/aligned/{sample}.20k/{sample}.20k.rmsd.info"
    resources:
        nodes = 1
    shell:
        """
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate hires
        set -u
        
        python {hires} align -o {output.aligned_3dg} -gd {output.aligned_3dg}good/ -bd {output.aligned_3dg}bad {input} > {output.aligned_3dg}{wildcards.sample}.20k.rmsd.info
        
        #need align to do the real clean or create 3dg_good

        set +u
        conda deactivate
        set -u
        """
       
rule vis:
    input:
        dip_c = "/share/home/ychi/software/dip-c/dip-c",
        color = "/share/Data/ychi/genome/GRCh38.chr.fem.txt",
        _3dg = "/share/Data/ychi/repo/aligned/{sample}.20k/good/"
    output:
        cif_dir = directory("/share/Data/ychi/repo/cif/{sample}/")
    shell:
        """
        set +u
        source /share/home/ychi/miniconda3/bin/activate
        conda activate py2_env
        set -u

        for file in `ls {input._3dg}`
        do
            {input.dip_c} color -n {input.color} {input._3dg}${{file}} | \
            {input.dip_c} vis -c /dev/stdin {input._3dg}${{file}} > {output}${{file}}.cif
        done
        """
        #dirty workaround for stupid snakemake input/output
        #need better vis or better out file syntax
        #goal: no loop in shell scripts


# --------- pseudo rules to ease command line using---------

rule all:
    input:
        #do RNA branch
        expand(rules.extract_umi.output, sample=SAMPLES),
        #do DNA branch, till impute
        expand(rules.impute.output, sample=SAMPLES),
        #do DNA branch, till 3d
        expand(rules.vis.output, sample=SAMPLES)

rule do_split:
    input:
        expand("/share/Data/ychi/repo/dna/{sample}.dna.{file}.fq.gz", sample=SAMPLES, file=["R1","R2"]),
        expand("/share/Data/ychi/repo/rna/{sample}.rna.{file}.fq.gz", sample=SAMPLES, file=["R1","R2"])
rule do_cut_round2:
    input:
        expand(rules.cut_round2.output, sample=SAMPLES)
rule do_extract_umi:
    input:
        #expand(rules.extract_umi.output, sample=SAMPLES) #expand accept iterate and replace them all.
        expand("/share/Data/ychi/repo/umi/umi.{sample}.rna.R1.fq.gz", sample=SAMPLES),
        expand("/share/Data/ychi/repo/umi/umi.{sample}.rna.R2.fq.gz", sample=SAMPLES),
        expand("/share/Data/ychi/repo/RNA_all/umi.{sample}.rna.R1.fq", sample=SAMPLES)

rule do_bwa:
    input:
        expand("/share/Data/ychi/repo/sam/{sample}.aln.sam.gz", sample=SAMPLES) 
rule do_sam2seg:
    input:
        expand(rules.sam2seg.output, sample=SAMPLES)
rule do_seg2pairs:
    input:
        expand(rules.seg2pairs.output, sample=SAMPLES)
rule do_clean_pairs:
    input:
        expand(rules.clean_pairs.output, sample=SAMPLES)
rule do_impute:
    input:
        expand(rules.impute.output, sample=SAMPLES)
rule do_build:
    input:
        expand(rules.build.output, sample=SAMPLES, rep=list(range(1,6)))
rule do_clean3d:
    input:
        expand(rules.clean3d.output, sample=SAMPLES, rep=list(range(1,6)))
rule do_align3d:
    input:
        expand(rules.align3d.output, sample=SAMPLES)
rule do_vis:
    input:
        expand(rules.vis.output, sample=SAMPLES)
