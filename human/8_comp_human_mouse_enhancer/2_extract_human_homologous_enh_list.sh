#! /bin/sh

cat epu_1500.hg19ToMm9.bed | cut -f4 | cut -d ';' -f1 | sort -u > human_homologous_enhancer.list

