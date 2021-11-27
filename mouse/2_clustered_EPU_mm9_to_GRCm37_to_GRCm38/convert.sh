#! /bin/sh
### source activate numba_gpu
python CrossMap.py bed CrossMap_chain_files/NCBIM37_to_GRCm38.chain.gz ../1_EPU_clustering/epu_1500.bed epu_1500.mm9ToGRCm38.bed
