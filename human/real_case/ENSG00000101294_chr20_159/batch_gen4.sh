#! /bin/sh

cat list.txt | awk '// {print "tar -xzvf ~/miso_result/"$1"/"$2"/"$3"/"$3".tgz miso_result/"$1"/"$2"/"$3"/SE/chr20/ENSG00000101294.SE.1.miso"}' >> batch.sh 
