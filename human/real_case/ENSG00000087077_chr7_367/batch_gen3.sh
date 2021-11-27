#! /bin/sh

cat list.txt | awk '// {print "tar -xzvf ~/miso_result/"$1"/"$2"/"$3"/"$3".tgz miso_result/"$1"/"$2"/"$3"/SE/chr7/ENSG00000087077.SE.0.miso"}' >> batch.sh 
