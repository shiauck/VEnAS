#! /usr/bin/perl -w

use strict;

my $res_dir   = "../3_enh_ae_psi_comp/res_2tailed/";
my $res_f_suf = ".stat.txt";
my @as_type   = `cat as_list.txt`;
chomp(@as_type);

my $o_f_pre   = "human.";
my $o_f_suf   = ".txt";

for(my $i = 0; $i <= $#as_type; $i++) {
   my $res_f = $res_dir . $as_type[$i] . $res_f_suf;
   my $o_c_f = $o_f_pre . $as_type[$i] . '.concordant.total' . $o_f_suf;
   my $o_d_f = $o_f_pre . $as_type[$i] . '.discordant.total' . $o_f_suf;

   my $gene_h;
   open(FILE, $res_f);
   <FILE>;
# 0  Ensembl.Gene.ID
# 1  Enhancer.grp
# 2  AE_nth
# 3  Non.spliced.without.enhancer
# 4  Spliced.without.enhancer
# 5  Non.spliced.with.enhancer
# 6  Spliced.with.enhancer
# 7  Fisher.P.value
# 8  Odds.ratio
# 9  q_fdr

   while(my $line = <FILE>) {
      my @line_arr = split("\t", $line);
      next if $#line_arr != 9;

      $gene_h->{con}->{$line_arr[0]} = 1 if($line_arr[8] > 1);
      $gene_h->{dis}->{$line_arr[0]} = 1 if($line_arr[8] < 1);
   }
   close(FILE);

   open(OUT, ">$o_c_f");
   foreach my $gid(keys %{$gene_h->{con}}) {
      print OUT $gid, "\n";
   }
   close(OUT);

   open(OUT, ">$o_d_f");
   foreach my $gid(keys %{$gene_h->{dis}}) {
      print OUT $gid, "\n";
   }
   close(OUT);
}
