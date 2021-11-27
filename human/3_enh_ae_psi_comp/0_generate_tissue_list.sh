#! /bin/sh
awk '//{if($11 == "Y"){print $1"\t"$2"\t"$3}}' ../conf/reads_list.txt > tissue_list.txt
