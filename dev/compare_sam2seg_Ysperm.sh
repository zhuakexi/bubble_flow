#!/bin/bash
# 为了解决Y sperm Y chrom missing的问题，需要对hapmal测试不filt sam2seg
threads=4
input_=/shareb/ychi/repo/sperm22/hic_mapped/B6J010D007.sorted.bam
tmp=dev/tmp.gz
output1=dev/B6J010D007.nofilt.pairs_0.gz
output2=dev/B6J010D007.nofilt.raw_pairs.gz
log1=dev/B6J010D007.nofilt.log
k8=/share/home/ychi/software/hickit/k8
js=/share/home/ychi/software/hickit/hickit.js
hickit=/share/home/ychi/software/hickit/hickit

# conda run --no-capture-output -n samtools samtools sort -n -@${threads} -O SAM ${input_} \
#             | ${k8} ${js} sam2seg - 2> ${log1} \
#             | ${k8} ${js} chronly - \
#             | sed 's/-/+/g' \
#             | gzip > ${tmp}
#${hickit} --dup-dist=500 -i ${tmp} -o - 2> ${log1} | gzip > ${output1}
#${hickit} --dup-dist=0 -i ${tmp} -o - 2> ${log1} | gzip > ${output2}

# output=dev/B6J010D007.q0d500.seg.gz
# conda run --no-capture-output -n samtools samtools sort -n -@${threads} -O SAM ${input_} \
#             | ${k8} ${js} sam2seg -q 0 -d 500 - 2> ${log1} \
#             | sed 's/-/+/g' \
#             | gzip > ${output}
# output=dev/B6J010D007.q0d0.seg.gz
# conda run --no-capture-output -n samtools samtools sort -n -@${threads} -O SAM ${input_} \
#             | ${k8} ${js} sam2seg -q 0 -d 0 - 2> ${log1} \
#             | sed 's/-/+/g' \
#             | gzip > ${output}
output=dev/B6J010D007.q20d500.seg.gz
conda run --no-capture-output -n samtools samtools sort -n -@${threads} -O SAM ${input_} \
            | ${k8} ${js} sam2seg -q 20 -d 500 - 2> ${log1} \
            | sed 's/-/+/g' \
            | gzip > ${output}