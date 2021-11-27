#! /bin/sh

cat list.txt | awk '// {print "tar -xzvf ~/miso_result/"$1"/"$2"/"$3"/"$3".tgz miso_result/"$1"/"$2"/"$3"/SE/chr5/ENSG00000211445.SE.0.miso"}' >> batch.sh 
