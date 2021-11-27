#! /usr/bin/perl -w

use strict;

my @as_list    = `cat as_list.txt`;
chomp(@as_list);

my $motif_f = "~/JASPAR-2020-05-07/JASPAR2020_CORE_vertebrates_non-redundant_pfms_meme.txt";

for(my $i = 0; $i <= $#as_list; $i++) {

   my $con_cmd = "sbatch -c 1 --wrap \"tomtom " . $as_list[$i] . "_concordant/dreme.txt $motif_f -oc " . $as_list[$i] . "_concordant/JASPAR\"";
   print "Execute command: $con_cmd\n";
   system($con_cmd);

   my $dis_cmd = "sbatch -c 1 --wrap \"tomtom " . $as_list[$i] . "_discordant/dreme.txt $motif_f -oc " . $as_list[$i] . "_discordant/JASPAR\"";
   print "Execute command: $dis_cmd\n";
   system($dis_cmd);
}
