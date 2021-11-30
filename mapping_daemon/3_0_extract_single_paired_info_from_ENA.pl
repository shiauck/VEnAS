#! /usr/bin/perl -w

use strict;
use Mojo::DOM;
use LWP::Simple qw(get);
use UNIVERSAL::can;
use utf8;

my $SRR_list_f = "SRR_list.txt";
my $o_name     = "conf/reads_list.txt";

open(OUT, ">$o_name");
print OUT "tissue_name\tGSM_acc\tSRR_acc\tfastq\tR1\tR2\tfastq_downloaded\tR1_downloaded\tR2_downloaded\tmapped_status\n";
my @f_cont = `cat $SRR_list_f`;
foreach my $line(@f_cont) {
   chomp($line);
   my @line_arr = split("\t", $line);

   my $srr_acc = $line_arr[0];
   my $gsm_acc = $line_arr[3];
   my $tissue_name = $line_arr[2];

   #===query ENA===
   my $ena_url = 'https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=' . $srr_acc . '&result=read_run&fields=fastq_ftp';
   my $html_text = get $ena_url;

   chomp($html_text);
   my @html_text = split("\n", $html_text);
      #===no data in ENA===
      if($#html_text == 0) {
         print OUT "$tissue_name\t$gsm_acc\t$srr_acc\tN\tN\tN\tN\tN\tN\tN\n";
         next;
      }
      #===no data in ENA===
   my @url_arr = split(";", $html_text[1]);
   #===query ENA===

   my($fq_flag, $fq1_flag, $fq2_flag) = ("0", "0", "0");
   for(my $i = 0; $i <= $#url_arr; $i++) {
      my @f_name_arr = split('/', $url_arr[$i]);
      $fq_flag  = "1" if $f_name_arr[$#f_name_arr] =~ /SRR\d+\.fastq/;
      $fq1_flag = "1" if $f_name_arr[$#f_name_arr] =~ /_1/;
      $fq2_flag = "1" if $f_name_arr[$#f_name_arr] =~ /_2/;
   }

   print OUT "$tissue_name\t$gsm_acc\t$srr_acc\t";
   ($fq_flag eq "1")?(print OUT "Y"):(print OUT "N");
   print OUT "\t";
   ($fq1_flag eq "1")?(print OUT "Y"):(print OUT "N");
   print OUT "\t";
   ($fq2_flag eq "1")?(print OUT "Y"):(print OUT "N");
   print OUT "\t";
   print OUT "N\tN\tN\tN\n";
}
close(OUT);
