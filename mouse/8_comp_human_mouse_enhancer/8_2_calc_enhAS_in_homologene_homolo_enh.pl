#! /usr/bin/perl -w

use strict;

my @as_type = qw/A5SS A3SS SE RI MSE MXE AFE ALE ATSS ATTS/;

my($sig_all_h, $sig_homo_h);
for(my $i = 0; $i <= $#as_type; $i++) {
   my $f_name = "full_table.homolo_gene_enh.$as_type[$i].txt";
   open(FILE, $f_name);
   <FILE>;
   while(my $line = <FILE>) {
      chomp($line);
      my @line_arr = split("\t", $line);

      if($line_arr[153] ne 'NA' && $line_arr[153] < 0.05) {
         $sig_all_h->{$line_arr[0]} = 1;
         $sig_homo_h->{$line_arr[0]} = 1 if($line_arr[154] == 1 && $line_arr[155] == 1);
      }
   }
   close(FILE);

   print "$as_type[$i]:\t", scalar(keys %$sig_homo_h), " / ", scalar(keys %$sig_all_h), "\n";
}

