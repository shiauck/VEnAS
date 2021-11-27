#! /usr/bin/perl -w

use strict;

my $mapping_h;

my $f_name = "human_enh_ovlap_mouse_enh.tsv";
my $o_name = "human_enh_ovlap_mouse_enh.res";

open(FILE, $f_name);
while(my $line = <FILE>) {
   my @line_arr = split('\t', $line);
   my @human_enh_str = split(';', $line_arr[3]);
   my @mouse_enh_str = split(';', $line_arr[9]);

   $mapping_h->{$human_enh_str[0]}->{$mouse_enh_str[0]} = 1;
}
close(FILE);

open(OUT, ">$o_name");
foreach my $h_enh(keys %$mapping_h) {
   foreach my $m_enh(keys %{$mapping_h->{$h_enh}}) {
      print OUT "$h_enh\t$m_enh\n";
   }
}
close(OUT);

