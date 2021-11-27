#! /bin/sh

bedtools intersect -a epu_1500.hg19ToMm9.bed -b mouse_epu_1500.bed -wo > human_enh_ovlap_mouse_enh.tsv

