#! /bin/sh

cat list.txt | awk '// {print "tar -xzvf ~/miso_result/"$1"/"$2"/"$3"/"$3".tgz miso_result/"$1"/"$2"/"$3"/SE/chr22/ENSG00000186575.SE.4.miso"}' >> batch.sh 
