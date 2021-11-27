#! /usr/bin/perl -w

# Have to activate "tools" first

use strict;

my $genome_f = "~/genome/Ensembl_Hs_94/Homo_sapiens.GRCh38.dna_sm.toplevel.fa";
my @f_list   = glob("*.bed");

foreach my $f_name(@f_list) {
   $f_name =~ /(.+).bed/;
   my $o_name = $1 . ".fasta";

   my $cmd = "bedtools getfasta -fi $genome_f -bed $f_name -fo $o_name";
   print $cmd, "\n";
   !system($cmd);
}
