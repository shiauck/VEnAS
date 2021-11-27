#! /usr/bin/perl -w

use strict;

my $ref_f      = "../1_EPU_clustering/EPU_all_tissue_enh_grouped_by_hc_limit_1500.txt";
my $list_f_pre = "enhancer_list.";
my $list_f_suf = ".txt";
my @as_list    = `cat ../as_list.txt`;
chomp(@as_list);
my @list_type  = qw/concordant discordant no_significant/;

print "Loading enhancer data...";
my $mapping_h;
open(FILE, $ref_f);
<FILE>;
while(my $line = <FILE>) {
   chomp($line);
   my @line_arr = split("\t", $line);

# 0        1       2         3       4               5         6    7     8      9        10     11
# enhancer enh_chr enh_start enh_end ens_id          gene_name chr  tss   strand score    tissue grp
# 28390    chr1    27460     29320   ENSG00000227232 WASH7P    chr1 29806 -      1.544125 MCF10A chr1_5122

   $line_arr[1] =~ /chr(.+)/;
   my $chr_name = $1;

   $mapping_h->{$line_arr[11]}->{"ec"} = $chr_name;
   $mapping_h->{$line_arr[11]}->{"es"} = $line_arr[2];
   $mapping_h->{$line_arr[11]}->{"ee"} = $line_arr[3];
   $mapping_h->{$line_arr[11]}->{"st"} = $line_arr[8];
}
close(FILE);
print "Done\n";

for(my $i = 0; $i <= $#as_list; $i++) {
   print "Converting $as_list[$i]...";

   for(my $j = 0; $j <= $#list_type; $j++) {

      my $f_name = $list_f_pre . $as_list[$i] . '.' . $list_type[$j] . $list_f_suf;
      my $o_name = $list_f_pre . $as_list[$i] . '.' . $list_type[$j] . '.bed';

      open(OUT, ">$o_name");
      open(FILE, $f_name);
      while(my $line = <FILE>) {
         chomp($line);
         print OUT $mapping_h->{$line}->{"ec"}, "\t";
         print OUT $mapping_h->{$line}->{"es"}, "\t";
         print OUT $mapping_h->{$line}->{"ee"}, "\t";
         print OUT "$line\t0\t";
         print OUT $mapping_h->{$line}->{"st"}, "\n";
      }
      close(FILE);
      close(OUT);
   }
   print "Done\n";
}

