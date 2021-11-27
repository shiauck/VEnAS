#! /usr/bin/perl -w

use strict;

my $jaspar_mapping_f = "~/JASPAR-2020-05-07/JASPAR2020_TFID_2_TFNAME.txt";
my $o_name = "7_1_EnhAS.TF_0.05.summary.txt";
my @dir_list = glob("*cordant");



my $jaspar_h;
open(FILE, $jaspar_mapping_f);
while(my $line = <FILE>) {
   chomp($line);
   my @line_arr = split("\t", $line);
   $jaspar_h->{$line_arr[0]} = $line_arr[1];
}
close(FILE);



open(OUT1, ">$o_name");
foreach my $dir_name(@dir_list) {
   my $tomtom_res = $dir_name . "/JASPAR/tomtom.tsv";
   $tomtom_res =~ /(.+)_(.+cordant)\/JASPAR/;
   my $as_type = $1;
   my $concordancy = $2;

   my $tf_h;
   if(-e $tomtom_res) {
      my $o_name = "tomtom_res_${as_type}_${concordancy}.tsv";
      open(OUT2, ">$o_name");
      open(FILE, $tomtom_res);
      my $line = <FILE>;
      chomp($line);
# 0  Query_ID
# 1  Target_ID
# 2  Optimal_offset
# 3  p-value
# 4  E-value
# 5  q-value
# 6  Overlap
# 7  Query_consensus
# 8  Target_consensus
# 9  Orientation
      print OUT2 $line, "\tTF name in JASPAR\n";
      while(my $line = <FILE>) {
         chomp($line);
         my @line_arr = split("\t", $line);

         next if $#line_arr != 9;

         print OUT2 $line;
         print OUT2 "\t", $jaspar_h->{$line_arr[1]} if $jaspar_h->{$line_arr[1]};
         print OUT2 "\n";

         if($line_arr[5] <= 0.05) {
            $tf_h->{$jaspar_h->{$line_arr[1]}} = 1;
         }
      }
      close(FILE);
      close(OUT2);
   }

   foreach my $tf_name(keys %$tf_h) {
      print OUT1 $as_type, "\t", $concordancy, "\t", $tf_name, "\n";
   }
}
close(OUT1);
