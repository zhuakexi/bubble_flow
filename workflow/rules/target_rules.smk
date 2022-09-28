rule target_bwa_mem:
    input:
        expand(rules.bwa_mem.output, sample = sample_table.index)
rule target_sam2seg:
    input:
        expand(rules.sam2seg.output, sample = sample_table.index)
rule target_seg_stat:
    input:
        expand(rules.sample_check.output, sample= sample_table.index)
rule target_seg2pairs:
    input:
        expand(rules.seg2pairs.output, sample=sample_table.index)
rule target_sep_clean:
    input:
        expand(rules.sep_clean.output, sample = sample_table.index)
rule target_build:
    input:
        expand(rules.build.output, sample = sample_table.index, rep=list(range(1,6)))
rule target_clean3d:
    input:
        expand(rules.clean3d.output, sample = sample_table.index, rep=list(range(1,6)), reso=["4m","1m","200k","50k","20k"])
rule target_rmsd:
    input:
        expand(rules.rmsd.output, sample = sample_table.index, reso = ["4m","1m","200k","50k","20k"])
rule target_cif:
    input:
        expand(rules.cif.output, sample = sample_table.index, rep=list(range(1,6)), reso=["4m","1m","200k","50k","20k"])
rule target_collect_info:
    input:
        rules.collect_info.output
rule target_star_mapping:
    input:
        expand(rules.star_mapping.output, ref = sample_table["ref"].unique() if "ref" in sample_table.columns else config["global_ref"])