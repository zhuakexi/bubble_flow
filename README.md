# bubble_flow
The HIRES/Dip-C workflow written in snakemake.

## Installation

### 1. set up snakemake environment

Conda is recommended.

```
conda create -n $CHOOSE_A_NAME
conda activate $CHOOSE_A_NAME
conda install snakemake
```

### 2. clone this git

```
git clone https://github.com/zhuakexi/bubble_flow
```

### 3. get hickit

Download Li and Tan's [hickit release](https://github.com/lh3/hickit/releases/download/v0.1.1/hickit-0.1.1_x64-linux.tar.bz2)

Extract file and set "software" section of config.yaml.

### 4. get hires

Clone from my repo.
```
git clone https://github.com/zhuakexi/hires-utils.git
```
Set "software" section of config.yaml

## Usage

### 1. Change Configurations

The configuration is specified in two files: `config.yaml` and `sample_table.csv` under the config directory. Typically, the former stores global settings and abbreviation definitions (such as which files are included in a ref label, so they can be referenced directly in `sample_table.csv`). The latter contains settings for each individual sample.

#### 1.1 Output Directories (Analysis Home)

The output directory is specified in `ana_home` within `config/config.yaml` (Requires large storage space).

#### 1.2 Running Mode:

A string that determines the workflow and parameters used for each sample.

Format: `ploidy_sex_snp_imputation_build`

This can be set globally in `global_mode` within `config/config.yaml`, or individually for each sample in the `mode` column of `config/sample_table.csv`. The latter has higher precedence.

- `ploidy`: 
    - Ploidy level. Affects `sam2seg` parameters and the build process. Can be omitted, written as `_ploidy_sex_snp_imputation_build`, with the system automatically deducing ploidy.
    - Options: `[1C, 2C]`
- `sex`:
    - Sample "sex". Affects `sam2seg` parameters related to sex chromosomes. Can be omitted, with the system automatically deducing sex.
    - Options: `[lY, hY]` (low Y, high Y).
- `snp`:
    - Whether to perform phasing. Affects the `-v` parameter of `sam2seg`. Cannot be omitted.
    - Options: `[SNP, others]` (phasing, not phasing)
- `imputation`:
    - Which pairs results to use for imputing phasing (using the dip-c imputation algorithm). Affects imputation and sep_clean. Cannot be omitted unless imputation and its subtasks are not performed.
    - Options: `[c1i, c12i, c123i]` (impute from clean1, clean12, clean123)
- `build`:
    - Which pairs results to use for building 3D structures. Affects the build process. Cannot be omitted unless build and its subtasks are not performed.
    - Options: `[c1b, c12b, c123b, Ib, Icb]` (build from clean1, clean12, clean123, imputed pairs, imputed and cleaned pairs)

#### 1.2.1 IO resources (I/O throttling)

Some rules are I/O heavy (e.g., `gcount` and `cutadapt`). The workflow assigns an `io` resource to those rules and expects a global cap from Snakemake.

In `config/config.yaml`:
- `io.heavy`: IO slots used by I/O-heavy rules (default is 4).
- `io.bwa`: IO slots used by the `bwa_mem` mapping rule (default is 2).

When running Snakemake, set a global IO cap, for example:
```
--resources io=8
```
This limits the total concurrent IO load across rules.

#### 1.3 Sample Table

Refers to `config/sample_table.csv`, specifying basic information for each sample.

It must include the following columns:
- `sample_name`: 
    - Sample name. Required.
- `R1_file`, `R2_file`:
    - R1 and R2 files for the sample. Required.

Optionally, it may include the following columns:
- `mode`:
    - Specifies the running mode for each sample.
- `ref`:
    - Specifies the reference genome for each sample. If not specified, it uses the `global_ref` defined in the config.

### 2. check Snakefile

In snakemake environment, execute snakemake in root dir of bubble_flow

```
cd bubble_flow
snakemake -np --wrapper-prefix $ABSOLUTE_PATH_TO_bubble_flow_ROOT_DIR/wrappers/ All
```

### 3. run snakemake

On local machine:
```
snakemake --cores $CHOOSE_THREADS --use_conda --wrapper-prefix $ABSOLUTE_PATH_TO_bubble_flow_ROOT_DIR/wrappers/ All
```

On cluster(slurm version):
```
snakemake --cluster "sbatch --cpus-per-task={threads}" --wrapper-prefix $ABSOLUTE_PATH_TO_bubble_flow_ROOT_DIR/wrappers/ --jobs $MAX_TASK_NUM --resources nodes=$MAX_CORE_NUM io=$IO_CAP All
```

Using "do_$RULE" to execute step by step
```
snakemake --cores $CHOOSE_THREADS --wrapper-prefix $ABSOLUTE_PATH_TO_bubble_flow_ROOT_DIR/wrappers/ --use_conda do_$RULE
```

A complete example：
```
snakemake --use-conda --conda-prefix /shareb/ychi/ana/envs/ --executor cluster-generic --cluster-generic-submit-cmd "sbatch --cpus-per-task={threads}  --job-name=em --partition={resources.partition} --mem-per-cpu={resources.mem_per_cpu}G  --output=slurm/%j.out --time={resources.runtime}" --wrapper-prefix $ABSOLUTE_PATH_TO_bubble_flow_ROOT_DIR/wrappers/ --default-resources runtime=600 'mem_per_cpu="3G"' partition=comp --resources io=8 --rerun-incomplete --rerun-triggers mtime --latency-wait 400 --jobs=256 --keep-going All > 1215.log 2>&1
```
1. Test on snakemake 9.14.3
2. Replace ABSOLUTE_PATH_TO_bubble_flow_ROOT_DIR with real path.
3. Make a `slurm` dir in your cwd, otherwise slurm won't submit tasks for missing output dir.

## Output Introduction
All outputs are placed in the analysis home directory, which is specified by `ana_home` in `config.yaml`. It includes the following subdirectories or files:

  - Sample statistics: `contacts_info.csv`
  - Pairs files without deduplication, and pairs files after deduplication but without any cleaning: `pairs_0`
  - Pairs files after removing promiscuous bin/leg: `pairs_c1`
  - Pairs files after sequentially removing promiscuous bin/leg and isolated contacts: `pairs_c12` (This file can be used for downstream Dip-C analysis)
  - Pairs files after sequentially removing promiscuous bin/leg, isolated contacts, and contacts potentially caused by splicing: `pairs_c123` (This file can be used for downstream HiRES analysis)
  - (If phase imputation was used) Pairs files after Dip-C imputation and separation of maternal and paternal alleles: `dip`
  - 3D structures of all samples: `3dg_c`
  - RNA count matrix: `count_matrix_{ref}`, where `ref` is specified by the `global_ref` field in `config.yaml`.

You can use:
```python
from hic_basic.wet.afbb import task_stat
meta = task_stat(ana_home)# ana_home refers to the analysis home directory
```
to obtain detailed sample information.

### Notes

1. Conditional rules:
    - `sam2seg`: Uses the `sample_check` checkpoint to deduce ploidy and sex.
    - `build`: Uses the `sample_check` checkpoint to deduce ploidy.
    
    In theory, if ploidy and sex are specified, deduction would not be necessary, and the `sample-check` step could be skipped. However, this structure is essential to implement the deduction functionality.
