#! /usr/bin/perl -w

use strict;
my $miso_dir = "../enhancerAtlas_v2/data_source/mouse/all/miso_result";
my $o_name   = "psi.txt";

#===read available sample list===
my $sample_h;
my $sample_list_f = "tissue_list.txt";
open(FILE, $sample_list_f);
while(my $line = <FILE>) {
   chomp($line);
   my @line_arr = split("\t", $line);

   $sample_h->{$line_arr[2]}->{tissue}  = $line_arr[0];
   $sample_h->{$line_arr[2]}->{gsm_acc} = $line_arr[1];
   $sample_h->{$line_arr[2]}->{srr_acc} = $line_arr[2];
}
close(FILE);

#===compile psi data===
open(OUT, ">$o_name");
foreach my $srr_acc(keys %$sample_h) {
   print "Parsing ", $sample_h->{$srr_acc}->{tissue},  " ",
                     $sample_h->{$srr_acc}->{gsm_acc}, " ",
                     $sample_h->{$srr_acc}->{srr_acc}, "...\n";

   my $f_name = $miso_dir . "/" .
                $sample_h->{$srr_acc}->{tissue}  . "_" .
                $sample_h->{$srr_acc}->{gsm_acc} . "_" .
                $sample_h->{$srr_acc}->{srr_acc} . ".psi.txt";

   my $cmd = "cat $f_name | sed 's/$sample_h->{$srr_acc}->{tissue}/$sample_h->{$srr_acc}->{tissue}_$sample_h->{$srr_acc}->{gsm_acc}_$sample_h->{$srr_acc}->{srr_acc}/g' >> $o_name";
#   print $cmd, "\n";
   system($cmd);
}
close(OUT);
