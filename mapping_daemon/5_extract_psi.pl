#! /usr/bin/perl -w

use strict;
use lib '.';
use conf::check_status;
use POSIX qw(strftime);
use List::Util qw(sum);

die "Usage: $0 <tissue_name> <GSM_acc> <SRR_acc> <bits6>\n\n" if $#ARGV != 3;

my $tissue_name = $ARGV[0];
my $gsm_acc     = $ARGV[1];
my $srr_acc     = $ARGV[2];
my $machine_id  = $ARGV[3];

my $conf_dir     = 'conf';
my @isoform_list = `cat as_list.txt`;
chomp(@isoform_list);
my $miso_o_dir   = "miso_result";
my $psi_o_name   = "${miso_o_dir}/${tissue_name}_${gsm_acc}_${srr_acc}.psi.txt";
my $psi_h;

#===to prevent daemon repeatedly call same job===
open(OUT, ">>$psi_o_name");
print OUT "";
close(OUT);

sub mean { return @_ ? sum(@_) / @_ : 0 }

print "Processing $tissue_name $gsm_acc $srr_acc...\n";

foreach my $isoform(@isoform_list) {
   print "\tProcessing $isoform...\n";

   my $psi_h;
   my $f_dir   = "${miso_o_dir}/${tissue_name}/${gsm_acc}/${srr_acc}/${isoform}";
   my @chr_f_list = glob("${f_dir}/chr*");

   foreach my $chr_f_name(@chr_f_list) {
      chomp($chr_f_name);
#      print "\t\tloading data inside: $chr_f_name...\n";
      my @f_list = glob("$chr_f_name/*.miso");
      #  @f_name = ["./output/ATSS/boneMarrow_2/chr1/ENSMUSG00000001143.ATSS.1.miso", "...", ...]

      foreach my $f_name(@f_list) {
         chomp($f_name);

         $f_name =~ /\/([^\/]+)$/;
         #f_name = ./output/ATSS/boneMarrow_2/chr1/ ( ENSMUSG00000001143.ATSS.1.miso )

         my $f_full = $1;
         my @f_full_arr = split(/\./, $f_full);
         #0: ENSMUSG00000001143
         #1: ATSS
         #2: 1
         #3: miso

         my $ens_gene_id = $f_full_arr[0];
         #  $ens_gene_id = ENSMUSG00000001143

         my @psi_arr = `awk 'NR > 2 {print \$0}' $f_name | cut -d ',' -f1 -`;
         chomp(@psi_arr);

         # calculate posterior mean psi
         my $psi_val = sprintf("%.4f", mean(@psi_arr));

         (defined $psi_h->{$ens_gene_id}->{$f_full_arr[2]}->{$tissue_name}->{$isoform})?
            ($psi_h->{$ens_gene_id}->{$f_full_arr[2]}->{$tissue_name}->{$isoform} .= ";$psi_val"):
            ($psi_h->{$ens_gene_id}->{$f_full_arr[2]}->{$tissue_name}->{$isoform}  =   $psi_val);
         # $psi_h->{ensembl_gene_id}->{nth_ae}->{tissue_name}->{ae} = psi
      }
   }

   print "\t\tOutput result...\n";
   open(OUT, ">>$psi_o_name");
   foreach my $ens_gene_id_o(sort {$a cmp $b} %$psi_h) {
      foreach my $nth_o(sort {$a <=> $b} keys %{$psi_h->{$ens_gene_id_o}}) {
         foreach my $tissue_name_o(sort {$a cmp $b} keys %{$psi_h->{$ens_gene_id_o}->{$nth_o}}) {
            foreach my $isoform_o(sort {$a cmp $b} keys %{$psi_h->{$ens_gene_id_o}->{$nth_o}->{$tissue_name_o}}) {
                  print OUT "$ens_gene_id_o\t$nth_o\t$tissue_name_o\t$isoform_o\t";
                  print OUT "$psi_h->{$ens_gene_id_o}->{$nth_o}->{$tissue_name_o}->{$isoform_o}\n";
            }
         }
      }
   }
   close(OUT);

   undef $psi_h;
}

#===tar miso result===
my $cmd  = "tar -czf ${miso_o_dir}/${tissue_name}/${gsm_acc}/${srr_acc}/${srr_acc}.tgz";
foreach my $isoform(@isoform_list) {
   $cmd .= " ${miso_o_dir}/${tissue_name}/${gsm_acc}/${srr_acc}/${isoform}";
}
print $cmd, "\n";
system($cmd);

foreach my $isoform(@isoform_list) {
   $cmd = "rm -rf ${miso_o_dir}/${tissue_name}/${gsm_acc}/${srr_acc}/${isoform}";
   print $cmd, "\n";
   system($cmd);
}
#===tar miso result===

check_status::unlock_machine("${conf_dir}/${machine_id}");

