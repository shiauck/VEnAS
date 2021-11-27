#! /usr/bin/perl -w

use strict;

my @as_list    = `cat as_list.txt`;
chomp(@as_list);

for(my $i = 0; $i <= $#as_list; $i++) {
   my $con_cmd = "sbatch -c 1 --wrap \"dreme -oc " . $as_list[$i] . "_concordant -p enhancer_list." . $as_list[$i] . ".concordant.fasta -n enhancer_list." . $as_list[$i] . ".no_significant.fasta -dna\"";
   print "Execute command: $con_cmd\n";
   system($con_cmd);

   my $dis_cmd = "sbatch -c 1 --wrap \"dreme -oc " . $as_list[$i] . "_discordant -p enhancer_list." . $as_list[$i] . ".discordant.fasta -n enhancer_list." . $as_list[$i] . ".no_significant.fasta -dna\"";
   print "Execute command: $dis_cmd\n";
   system($dis_cmd);

}
