#! /usr/bin/perl -w

use strict;

my $ref_f      = "../2_clustered_EPU_hg19_to_GRCh37_to_GRCh38/epu_1500.hg19ToGRCh37ToGRCh38.bed";
my $list_f_pre = "enhancer_list.";
my $list_f_suf = ".txt";
my @as_list    = `cat as_list.txt`;
chomp(@as_list);
my @list_type  = qw/concordant discordant no_significant/;

print "Loading enhancer data...";
my $mapping_h;
open(FILE, $ref_f);
<FILE>;
while(my $line = <FILE>) {
   chomp($line);
   my @line_arr = split("\t", $line);

#0 1       2       3                             4 5
#1 1114240 1116050 chr1_1;MCF10A;ENSG00000008130 . .

   my @attr_arr = split(';', $line_arr[3]);

   $mapping_h->{$attr_arr[0]}->{"ec"} = $line_arr[0];
   $mapping_h->{$attr_arr[0]}->{"es"} = $line_arr[1];
   $mapping_h->{$attr_arr[0]}->{"ee"} = $line_arr[2];
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

         if(defined $mapping_h->{$line}){
            print OUT $mapping_h->{$line}->{"ec"}, "\t";
            print OUT $mapping_h->{$line}->{"es"}, "\t";
            print OUT $mapping_h->{$line}->{"ee"}, "\t";
            print OUT "$line\t0\t";
            print OUT ".\n";
         }
      }
      close(FILE);
      close(OUT);
   }
   print "Done\n";
}

