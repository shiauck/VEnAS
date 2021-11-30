#! /usr/bin/perl -w

use strict;
use Mojo::DOM;
use LWP::Simple qw(get);
use UNIVERSAL::can;
use utf8;

my $f_name = $ARGV[0];
my $o_dir  = './fastq/';

my @f_cont = `cat $f_name`;
foreach my $line(@f_cont) {
   chomp($line);
   my @line_arr = split("\t", $line);

   my $srr_acc = $line_arr[0];
   my $gsm_acc = $line_arr[3];
   my $tissue_name = $line_arr[2];

   #===create folder for download===
   print "mkdir $o_dir\n" unless -d $o_dir;
   system("mkdir $o_dir") unless -d $o_dir;

   print "mkdir $o_dir/$tissue_name\n" unless -d "$o_dir/$tissue_name";
   system("mkdir $o_dir/$tissue_name") unless -d "$o_dir/$tissue_name";

   my $folder_name = $o_dir . "$tissue_name/$gsm_acc";
   print "mkdir $folder_name\n" unless -d $folder_name;
   system("mkdir $folder_name") unless -d $folder_name;
   #===create folder for download===

   #===query ENA===
   print "Extracting URL of fastq for $tissue_name $gsm_acc $srr_acc...\n";

   my $ena_url = 'https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=' . $srr_acc . '&result=read_run&fields=fastq_ftp,fastq_md5';
   my $html_text = get $ena_url;

   chomp($html_text);
   my @html_text = split("\n", $html_text);
   my @url_arr = split("\t", $html_text[1]);
   # example (separated by semi-colon)
   # $url_arr[0]: ftp.../SRR1556217.fastq.gz;ftp.../SRR1556217_1.fastq.gz;ftp.../SRR1556217_2.fastq.gz
   # $url_arr[1]: 2d2...00d;0b3...1fa;24d...739
   #===query ENA===

   #===download fastq===
   my @fq_url_arr = split(';', $url_arr[0]);
   my @fq_md5_arr = split(';', $url_arr[1]);
   for(my $i = 0; $i <= $#fq_url_arr; $i++) {
      #===fetch===
      my $cmd = "wget -t 0 $fq_url_arr[$i] -q -P $folder_name";
      print "$cmd\n";
      system($cmd);

      my @f_name = split('/', $fq_url_arr[$i]);

      open(OUT, ">$folder_name/$f_name[$#f_name].md5");
      print OUT "$fq_md5_arr[$i]\n";
      close(OUT);
   }
   #===download fastq===

   print "Done\n\n";

}
