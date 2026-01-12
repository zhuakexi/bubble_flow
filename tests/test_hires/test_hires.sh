#!/bin/bash
# change according to your environment
BASE_DIR=/share/home/ychi/dev/bubble_flow
MODE=local # local or slurm
# usually no need to change below
SAMPLE_TABLE=$BASE_DIR/tests/test_hires/sample_table.csv
CONFIG=$BASE_DIR/config/config.yaml
SNAKE_FILE=$BASE_DIR/workflow/Snakefile
ANA_HOME=$BASE_DIR/tests/test_hires/output/test
TARGET=target_collect_info
SNAKE_PREF=hires.${TARGET}

mkdir -p $BASE_DIR/tests/test_hires/work
if [ "$MODE" == "slurm" ]; then
    mkdir -p $BASE_DIR/tests/test_hires/work/slurm
    snakemake --use-conda --conda-prefix /shareb/ychi/ana/envs \
    --executor cluster-generic \
    --cluster-generic-submit-cmd "sbatch --job-name=bb_test --partition={resources.partition} --cpus-per-task={threads} \
    --output=${BASE_DIR}/tests/test_hires/work/slurm/%j.out --mem-per-cpu={resources.mem_per_cpu}" \
    --cluster-generic-cancel-cmd 'scancel {jobid}' \
    --default-resources runtime=600 'mem_per_cpu="3G"' partition=fatcomp,comp \
    --rerun-incomplete --rerun-triggers mtime --latency-wait 120 \
    --jobs=8 \
    --configfile $CONFIG \
    --wrapper-prefix $BASE_DIR/wrappers/ \
    --config sample_table=$SAMPLE_TABLE ana_home=$ANA_HOME global_mode=2C__SNP_c123i_Icb global_ref=hg19 \
    --snakefile $SNAKE_FILE  \
    --directory $BASE_DIR/tests/test_hires/work/.cache/$SNAKE_PREF $TARGET \
    > $BASE_DIR/tests/test_hires/work/$SNAKE_PREF.log 2>&1
else

    snakemake --use-conda --conda-prefix /shareb/ychi/ana/envs \
    -c 1 \
    --keep-going --rerun-incomplete --latency-wait 120 \
    --configfile $CONFIG \
    --wrapper-prefix $BASE_DIR/wrappers/ \
    --config sample_table=$SAMPLE_TABLE ana_home=$ANA_HOME global_mode=2C__SNP_c123i_Icb global_ref=hg19 \
    --snakefile $SNAKE_FILE  --rerun-triggers input \
    --directory $BASE_DIR/tests/test_hires/work/.cache/$SNAKE_PREF $TARGET \
    > $BASE_DIR/tests/test_hires/work/$SNAKE_PREF.log 2>&1
fi