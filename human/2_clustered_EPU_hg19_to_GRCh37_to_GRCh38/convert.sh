#! /bin/sh
### source activate numba_gpu
python CrossMap.py bed CrossMap_chain_files/hg19ToGRCh37.over.chain ../1_EPU_clustering/epu_1500.bed epu_1500.hg19ToGRCh37.bed
python CrossMap.py bed CrossMap_chain_files/GRCh37_to_GRCh38.chain epu_1500.hg19ToGRCh37.bed epu_1500.hg19ToGRCh37ToGRCh38.bed
