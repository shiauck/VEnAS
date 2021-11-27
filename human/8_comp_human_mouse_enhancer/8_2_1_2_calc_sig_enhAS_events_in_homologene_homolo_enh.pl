#! /usr/bin/perl -w

use strict;
sub count_all($);

my @as_type = qw/A5SS A3SS SE RI MSE MXE AFE ALE ATSS ATTS/;

my($sig_all_h, $sig_homologene_h, $sig_homolo_enh_h, $sig_homo_h);
for(my $i = 0; $i <= $#as_type; $i++) {
   my $f_name = "full_table.homolo_gene_enh.$as_type[$i].txt";
   open(FILE, $f_name);
   <FILE>;
   while(my $line = <FILE>) {
      chomp($line);
      my @line_arr = split("\t", $line);

      if($line_arr[177] ne 'NA' && $line_arr[177] < 0.05) {
         $sig_all_h->{$line_arr[0]}->{$line_arr[1]}->{$line_arr[2]} = 1;
         $sig_homologene_h->{$line_arr[0]}->{$line_arr[1]}->{$line_arr[2]} = 1 if($line_arr[178] == 1);
         $sig_homolo_enh_h->{$line_arr[0]}->{$line_arr[1]}->{$line_arr[2]} = 1 if($line_arr[179] == 1);
         $sig_homo_h->{$line_arr[0]}->{$line_arr[1]}->{$line_arr[2]} = 1 if($line_arr[178] == 1 && $line_arr[179] == 1);
      }
   }
   close(FILE);

   print "$as_type[$i]:\t";
   print count_all(\%$sig_homo_h);
   print " / ";
   print count_all(\%$sig_homologene_h);
   print " / ";
   print count_all(\%$sig_homolo_enh_h);
   print " / ";
   print count_all(\%$sig_all_h);
   print "\n";
}

sub count_all($) {
   my $my_h = shift @_;
   my $counter = 0;
   foreach my $ele(keys %$my_h) {
      foreach my $sub_ele(keys %{$my_h->{$ele}}) {
         $counter += scalar(keys %{$my_h->{$ele}->{$sub_ele}})
      }
   }
   return $counter;
}

