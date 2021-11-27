#! /bin/sh
cut -f4 epu_1500.bed | cut -d ';' -f3 | sort -u | wc -l > gene_no.txt
