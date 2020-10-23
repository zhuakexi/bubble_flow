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

### 1. change configuration

Change output directories(Need large storage space).

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

