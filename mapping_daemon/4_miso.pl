#! /usr/bin/perl -w

use strict;
use lib '.';
use conf::check_status;
use POSIX qw(strftime);

die "Usage: $0 <tissue_name> <GSM_acc> <SRR_acc> <bits5/bits7>\n" if $#ARGV != 3;

my $tissue_name = $ARGV[0];
my $gsm_acc     = $ARGV[1];
my $srr_acc     = $ARGV[2];
my $machine_id  = $ARGV[3];

my $conf_dir    = 'conf';
my $shm_dir     = '/dev/shm';
my $fastq_dir   = '../enhancerAtlas_v2/data_source/human/all/fastq';
my $data_path   = '../enhancerAtlas_v2/data_source/human/all/mapped_result';
my $ind_path    = '~/Ensembl_Hs_94/annotation';
my $res_path    = '../enhancerAtlas_v2/data_source/human/all/miso_result';
my $as_list_f   = 'as_list.txt';
my @as_list     = `cat $as_list_f`;
chomp(@as_list);

my $daemon_read_list_f  = "${conf_dir}/reads_list.txt";

#===examine read length===
my $fq_f = "${fastq_dir}/${tissue_name}/${gsm_acc}/${srr_acc}.fastq.gz";
my $r1_f = "${fastq_dir}/${tissue_name}/${gsm_acc}/${srr_acc}_1.fastq.gz";
#my $r2_f = "${fastq_dir}/${tissue_name}/${gsm_acc}/${srr_acc}_2.fastq.gz";

my $read_len = 0;
if(-e $fq_f) {
   my $seq_str = `gunzip -c $fq_f | head -n 2 | tail -n 1`;
   chomp($seq_str);

   $read_len = length($seq_str);
} elsif(-e $r1_f ) {
   my $seq_str = `gunzip -c $r1_f | head -n 2 | tail -n 1`;
   chomp($seq_str);

   $read_len = length($seq_str);
} else {
   print "Can't calculate read length: $tissue_name $gsm_acc $srr_acc!!\n\n";

   print "\nUnlock $machine_id\n\n";

   check::unlock_machine("${conf_dir}/${machine_id}");

   exit(0);
}
#===examine read length===

#===call MISO===
my $bam_f      = "${srr_acc}.uniq.sorted.bam";
my $full_bam_f = "${data_path}/${tissue_name}/${gsm_acc}/${bam_f}";

   #===copy bam & bai to share memory===
my $cmd   = "cp ${full_bam_f} ${shm_dir}";
print $cmd, "\n";
system($cmd);
   $cmd   = "cp ${full_bam_f}.bai ${shm_dir}";
print $cmd, "\n";
system($cmd);
   #===copy bam & bai to share memory===

foreach my $as_type(@as_list) {
   chomp($as_type);
   my $cmd = "miso --run $ind_path/indexed_${as_type}_events/ ${shm_dir}/$bam_f --output-dir $res_path/$tissue_name/${gsm_acc}/${srr_acc}/${as_type} --read-len $read_len --settings-filename=miso_settings.txt -p 16";
   print $cmd, "\n";
   system($cmd);
}

   #===remove bam & bai in share memory===
   $cmd   = "rm ${shm_dir}/${bam_f}";
print $cmd, "\n";
system($cmd);
   $cmd   = "rm ${shm_dir}/${bam_f}.bai";
print $cmd, "\n";
system($cmd);
   #===remove bam & bai in share memory===
#===call MISO===

#===update read list status===
my $status_h = check_status::load_status($daemon_read_list_f);
$status_h->{$srr_acc}->{MISO_status} = 'Y';
check_status::write_status($daemon_read_list_f, $status_h);
#===update read list status===

check_status::unlock_machine("${conf_dir}/${machine_id}");

