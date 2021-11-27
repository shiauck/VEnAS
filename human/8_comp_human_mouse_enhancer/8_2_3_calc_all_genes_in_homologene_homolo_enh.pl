#! /usr/bin/perl -w

use strict;

my @as_type = qw/A5SS A3SS SE RI MSE MXE AFE ALE ATSS ATTS/;

my($nonsig_all_h, $nonsig_homologene_h, $nonsig_homolo_enh_h, $nonsig_homo_h);
for(my $i = 0; $i <= $#as_type; $i++) {
   my $f_name = "full_table.homolo_gene_enh.$as_type[$i].txt";
   open(FILE, $f_name);
   <FILE>;
   while(my $line = <FILE>) {
      chomp($line);
      my @line_arr = split("\t", $line);

         $nonsig_all_h->{$line_arr[0]} = 1;
         $nonsig_homologene_h->{$line_arr[0]} = 1 if($line_arr[178] == 1);
         $nonsig_homolo_enh_h->{$line_arr[0]} = 1 if($line_arr[179] == 1);
         $nonsig_homo_h->{$line_arr[0]} = 1 if($line_arr[178] == 1 && $line_arr[179] == 1);
   }
   close(FILE);

   print "$as_type[$i]:\t", scalar(keys %$nonsig_homo_h), " / ", scalar(keys %$nonsig_homologene_h), " / ", scalar(keys %$nonsig_homolo_enh_h), " / ", scalar(keys %$nonsig_all_h), "\n";
}

