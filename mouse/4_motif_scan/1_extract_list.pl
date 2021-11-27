#! /usr/bin/perl -w

use strict;

my $res_path = "../3_enh_ae_psi_comp/res_2tailed/";
my $res_f_pre = "";
my $res_f_suf = ".stat.txt";
my @as_list   = `cat ../as_list.txt`;
chomp(@as_list);

for(my $i = 0; $i <= $#as_list; $i++) {
   print "Processing $as_list[$i]...";

   my $f_name = $res_path . $res_f_pre . $as_list[$i] . $res_f_suf;
# 0  Ensembl Gene ID
# 1  Enhancer grp
# 2  AE_nth
# 3  Non-spliced without enhancer
# 4  Spliced without enhancer
# 5  Non-spliced with enhancer
# 6  Spliced with enhancer
# 7  Fisher P-value
# 8  Odds ratio
# 9  q_fdr
   my $enh_list;
   open(FILE, $f_name);
   <FILE>;
   while(my $line = <FILE>) {
      chomp($line);
      my @line_arr = split("\t", $line);

      if($line_arr[9] ne "NA" && $line_arr[9] <= 0.05) {
         if($line_arr[8] eq 'Inf' || $line_arr[8] > 1) {
           $enh_list->{"concordant"}->{$line_arr[1]} = 1;
         } elsif($line_arr[8] < 1) {
           $enh_list->{"discordant"}->{$line_arr[1]} = 1;
         } else {
           die "Something wrong at: $line\n";
         }
      } else {
         $enh_list->{"no_sig"}->{$line_arr[1]} = 1;
      }
   }
   close(FILE);

   my $o_name = "enhancer_list." . $as_list[$i] . ".concordant.txt";
   open(OUT, ">$o_name");
   foreach my $ele(keys %{$enh_list->{"concordant"}}) {
      print OUT "$ele\n";
   }
   close(OUT);

      $o_name = "enhancer_list." . $as_list[$i] . ".discordant.txt";
   open(OUT, ">$o_name");
   foreach my $ele(keys %{$enh_list->{"discordant"}}) {
      print OUT "$ele\n";
   }
   close(OUT);

      $o_name = "enhancer_list." . $as_list[$i] . ".no_significant.txt";
   open(OUT, ">$o_name");
   foreach my $ele(keys %{$enh_list->{"no_sig"}}) {
      print OUT "$ele\n";
   }
   close(OUT);

   print "Done\n";
}
