#! /usr/bin/perl -w

use strict;
use lib '.';
use conf::check_status;
use POSIX qw(strftime);

die "Usage: $0 <tissue_name> <GSM_acc> <SRR_acc> <machine_id>\n\n" if $#ARGV != 3;

my $tissue_name = $ARGV[0];
my $gsm_acc     = $ARGV[1];
my $srr_acc     = $ARGV[2];
my $machine_id  = $ARGV[3];

my $conf_dir            = "conf";
my $daemon_read_list_f  = "${conf_dir}/reads_list.txt";

my $fastq_dir = '../enhancerAtlas_v2/data_source/human/all/fastq';
my $index_f   = '~/Ensembl_Hs_94/genome_index/Homo_sapiens.GRCh38.dna_sm.toplevel';
my $o_dir     = 'mapped_result';

   #===detect single/paired reads===
   my $reads_str = "";
   my $r1_f = "${fastq_dir}/${tissue_name}/${gsm_acc}/${srr_acc}_1.fastq.gz";
   my $r2_f = "${fastq_dir}/${tissue_name}/${gsm_acc}/${srr_acc}_2.fastq.gz";
   my $single_read_f = "${fastq_dir}/${tissue_name}/${gsm_acc}/${srr_acc}.fastq.gz";
   if(-e $r1_f && -e $r2_f) {
      $reads_str = "-1 $r1_f -2 $r2_f";
   } else {
      if(-e $r1_f) {
         $reads_str = "-U $r1_f";
      } elsif(-e $r2_f) {
         $reads_str = "-U $r2_f";
      } else {
         $reads_str = "-U $single_read_f";
      }
   }

   #===prepare environment===
   system("mkdir ${o_dir}") unless(-e $o_dir && -d $o_dir);
   system("mkdir ${o_dir}/${tissue_name}")
      unless(-e "${o_dir}/${tissue_name}" && -d "${o_dir}/${tissue_name}");
   system("mkdir ${o_dir}/${tissue_name}/${gsm_acc}")
      unless(-e "${o_dir}/${tissue_name}/${gsm_acc}" && -d "${o_dir}/${tissue_name}/${gsm_acc}");

   #===mapping===
   my $sam_f = "${o_dir}/${tissue_name}/${gsm_acc}/${srr_acc}.sam";
   my $log_f = "${o_dir}/${tissue_name}/${gsm_acc}/${srr_acc}.log";
   my $cmd = "hisat2 -x $index_f $reads_str -S $sam_f --add-chrname --summary-file $log_f -p 16";
   print "Command: ", $cmd, "\n";
   system($cmd);

   #===extract unique-hit reads===
      $cmd = './extract_uniq_read.sh ' . $sam_f;
   print "Command: ", $cmd, "\n";
   system($cmd);

   #===rm original sam===
      $cmd = "rm $sam_f";
   print "Command: ", $cmd, "\n";
   system($cmd);

   #===convert uniq sam to uniq bam===
   my $uniq_sam_f = "${o_dir}/${tissue_name}/${gsm_acc}/${srr_acc}.uniq.sam";
   my $uniq_bam_f = "${o_dir}/${tissue_name}/${gsm_acc}/${srr_acc}.uniq.bam";
      $cmd = "samtools view $uniq_sam_f -b -o $uniq_bam_f";
   print "Command: ", $cmd, "\n";
   system($cmd);

   #===rm uniq sam===
      $cmd = "rm $uniq_sam_f";
   print "Command: ", $cmd, "\n";
   system($cmd);

   #===sorting uniq bam===
   my $sorted_bam_f = "${o_dir}/${tissue_name}/${gsm_acc}/${srr_acc}.uniq.sorted.bam";
      $cmd = "samtools sort $uniq_bam_f -o $sorted_bam_f";
   print "Command: ", $cmd, "\n";
   system($cmd);

   #===rm uniq.bam===
      $cmd = "rm $uniq_bam_f";
   print "Command: ", $cmd, "\n";
   system($cmd);

   #===index sorted bam===
   my $index_bam_f = "${o_dir}/${tissue_name}/${gsm_acc}/${srr_acc}.uniq.sorted.bam.bai";
      $cmd = "samtools index $sorted_bam_f $index_bam_f";
   print "Command: ", $cmd, "\n";
   system($cmd);

   #===update read list status===
   my $status_h = check_status::load_status($daemon_read_list_f);
   $status_h->{$srr_acc}->{mapped_status} = 'Y';
   check_status::write_status($daemon_read_list_f, $status_h);
   #===update read list status===

   check_status::unlock_machine("${conf_dir}/${machine_id}");

