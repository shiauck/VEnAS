#! /bin/sh

cat list.txt | awk '// {print "tar -xzvf ~/miso_result/"$1"/"$2"/"$3"/"$3".tgz miso_result/"$1"/"$2"/"$3"/SE/chr11/ENSG00000110080.SE.2.miso"}' >> batch.sh 
