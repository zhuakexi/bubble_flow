# bubble_flow
the HIRES/Dip-C workflow written in snakemake.

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

### 1. change configurations

    config在config/config.yaml和config/sample_table.csv两个文件中指定。一般地，前者存储全局设置和简写定义（比如ref label包含哪些文件，这样可以在直接在sample_table.csv里引用）。后者包含逐个样品的设置。

#### 1.1 output directories (analysis home).

    在config/config.yaml的ana_home中指定输出目录( Need large storage space )。

#### 1.2 running mode: 

    一个string，决定每个样品按照什么样的流程和参数运行。

    format: ploidy_sex_snp_imputation_build  

    可以在config/config.yaml的global_mode里指定。也可以在config/sample_table.csv的mode列里指定。后者优先级更高。

        ploidy: 
            倍性。影响sam2seg参数,影响build。可以省略，写成 _ploidy_sex_snp_imputation_build，系统自动deduct ploidy。
            [1C, 2C, ]
        sex：
            样品“性别”。影响sam2seg性染色体相关参数。可以省略，系统自动deduct sex。
            [lY, hY] (low Y, high Y)。
        snp: 
            是否phasing。影响sam2seg -v参数。不可以省略。
            [SNP, `others`] (phasing, not phasing)
        imputation: 
            用什么pairs结果impute phasing(dip-c imputation算法)。影响imputation, sep_clean。除非不执行imputation及子任务不可以省略。
            [c1i, c12i, c123i] (impute from clean1, clean12, clean123, don't impute)
        build: 
            用什么pairs类结果build三维结构。影响build。除非不执行build及子任务不可以省略。
            [c1b, c12b, c123b， Ib, Icb] (build from clean1, clean12, clean123, imputated pairs, imputated and cleaned pairs)

#### 1.3 sample_table

    指config/sample_table.csv，指定每个样品的基本信息。

    必须包含以下列：
        sample_name: 
            样品名。必须。
        R1_file, R2_file:
            样品的R1和R2文件。必须。
    可选包含以下列：
        mode:
            逐个指定running mode。
        ref：
            逐个指定参考基因组。不指定则使用config里的global_ref。

### 2. check Snakefile

In snakemake environment, execute snakemake in root dir of bubble_flow

```
cd bubble_flow
snakemake -np All
```

### 3. run snakemake

On local machine:
```
snakemake --cores $CHOOSE_THREADS --use_conda All
```

On cluster(slurm version):
```
snakemake --cluster "sbatch --cpus-per-task={threads}" --jobs $MAX_TASK_NUM --resources nodes=$MAX_CORE_NUM All
```

Using "do_$RULE" to execute step by step
```
snakemake --cores $CHOOSE_THREADS --use_conda do_$RULE
```
### notes
1. conditional rules:  
    sam2seg, using checkpoint sample_check to deduction ploidy and sex
    build, using checkpoint sample_check to deduction ploidy  
    当然理论上如果指定ploidy和sex就不需要deduction也不需要执行sample-check，但是为了实现deduction这种结构是必须的。
