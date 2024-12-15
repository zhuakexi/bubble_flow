# bubble_flow
用Snakemake编写的HIRES/Dip-C工作流程。

## 安装

### 1. 设置Snakemake环境

推荐使用Conda。

```
conda create -n $CHOOSE_A_NAME
conda activate $CHOOSE_A_NAME
conda install snakemake
```

### 2. 克隆此git仓库

```
git clone https://github.com/zhuakexi/bubble_flow
```

### 3. 获取hickit

下载Li和Tan的[hickit发布版](https://github.com/lh3/hickit/releases/download/v0.1.1/hickit-0.1.1_x64-linux.tar.bz2)

解压文件并设置config.yaml中的"software"部分。

### 4. 获取hires

从我的仓库克隆。
```
git clone https://github.com/zhuakexi/hires-utils.git
```
设置config.yaml中的"software"部分。

## 使用

### 1. 更改设置

    config在config/config.yaml和config/sample_table.csv两个文件中指定。一般地，前者存储全局设置和简写定义（比如ref label包含哪些文件，这样可以在直接在sample_table.csv里引用）。后者包含逐个样品的设置。

#### 1.1 输出目录 (analysis home).

    在config/config.yaml的ana_home中指定输出目录( Need large storage space )。

#### 1.2 运行模式: 

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
            [c1i, c12i, c123i] (impute from clean1, clean12, clean123)
        build: 
            用什么pairs类结果build三维结构。影响build。除非不执行build及子任务不可以省略。
            [c1b, c12b, c123b， Ib, Icb] (build from clean1, clean12, clean123, imputated pairs, imputated and cleaned pairs)

#### 1.3 样品列表

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

### 2. 检查Snakefile

In snakemake environment, execute snakemake in root dir of bubble_flow

```
cd bubble_flow
snakemake -np All
```

### 3. 运行snakemake

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

A complete example：
```
snakemake --use-conda --conda-prefix /shareb/ychi/ana/envs/ --cluster "sbatch --cpus-per-task={threads}  --job-name=em --partition={resources.partition} --mem-per-cpu={resources.mem_per_cpu}G  --output=slurm/%j.out --time={resources.runtime}" --cluster-cancel scancel --default-resources runtime=600 mem_per_cpu=2 partition=comp --rerun-incomplete --rerun-triggers mtime --latency-wait 400 --jobs=256 --keep-going All > 1215.log 2>&1
```
## 输出介绍
所有输出都放在输出目录analysis home中，这个目录使用config.yaml的ana_home指定。包含以下子目录或者文件：   
  - 样品统计信息：contacts_info.csv   
  - 没有dedup的pairs文件，和dedup但是没有经过任何clean的pairs文件：pairs_0  
  - 清除promiscuous bin/leg的pairs文件:pairs_c1  
  - 先后清除promiscuous bin/leg和isolated contacts的pairs文件:pairs_c12 （Dip-C下游分析可以使用这个文件）  
  - 先后清除promiscuous bin/leg、isolated contacts和可能由splicing造成的contacts的pairs文件:pairs_c123（HiRES下游分析可以使用这个文件）  
  - （如果使用了phase imputation）经过Dip-C imputation且分开maternal paternal allele的pairs文件: dip  
  - 所有样品的三维结构：3dg_c   
  - RNA count matrix: count_matrix_{ref} ，ref在config.yaml的global_ref字段指定。  

可以使用:
```
from hic_basic.wet.afbb import task_stat
meta = task_stat(ana_home) # ana_home即analysis home
```
获取样品详细信息。
### 注意
1. conditional rules:  
    sam2seg, using checkpoint sample_check to deduction ploidy and sex
    build, using checkpoint sample_check to deduction ploidy  
    当然理论上如果指定ploidy和sex就不需要deduction也不需要执行sample-check，但是为了实现deduction这种结构是必须的。
