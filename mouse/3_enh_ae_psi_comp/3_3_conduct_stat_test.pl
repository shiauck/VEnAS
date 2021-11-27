#! /usr/bin/perl -w

#===fix seed===
$| = 1;

use lib '.';
use strict;
use my_modules::my_func;
use my_modules::my_stat;

my $tissue_list = "tissue_list.txt";
my $f_name_pref = "1_1_enhancer_ensid_ae_psi.";
my $f_name_suf  = ".txt";
my $o_name_pref = "data_2tailed/3_enhancer_ensid_ae_psi.";
my $o_name_suf  = ".2tailed.txt";
my @lower_arr   = qw/0.025 0.05 0.1 0.16 0.2 0.25/;
my @upper_arr   = qw/0.975 0.95 0.9 0.84 0.8 0.75/;

#===load Z-transformed PSI thresholds===
my $psi_thr_f   = "z_score_thresholds.txt";
my $psi_thr_h;
my_func::get_PSI_threshold($psi_thr_f, \%$psi_thr_h);

#===fetch tissue info===
my $no_tissue   = `wc -l $tissue_list | cut -d ' ' -f1`;
chomp($no_tissue);
my $tissue_hash = my_func::get_tissue_hash($tissue_list);
my $tissue_aoh  = my_func::get_tissue_aoh($tissue_list);

#===load AE type===
my $ae_type_f   = "as_list.txt";
my @ae_type_arr = `cat as_list.txt`;
chomp(@ae_type_arr);

for(my $ae_idx = 0; $ae_idx <= $#ae_type_arr; $ae_idx++) {
   my $ae_type = $ae_type_arr[$ae_idx];
   print "Processing $ae_type...\n";

   #===generate random sample list & store in arr, then convert & store by hash===
   #===start from "0"===
   #my $sample_ind_arr = get_sample_list($tissue_hash, 3);
#   my $sample_ind_arr = fisher_exact_test::get_sample_list($tissue_hash, 1);
#   my $sample_ind_hash;
#   for(my $i = 0; $i < $no_tissue; $i++) {
#      $sample_ind_hash->{$i} = 0;
#   }
#   for(my $i = 0; $i <= $#$sample_ind_arr; $i++) {
#      $sample_ind_hash->{$sample_ind_arr->[$i]} = 1;
#   }

   #===set input output file name===
   my $f_name = $f_name_pref . $ae_type . $f_name_suf;

   #===count input line no for progress display===
   my $max_line_no = `wc -l $f_name | cut -d ' ' -f1`;
   chomp($max_line_no);
   my $line_no = 0;

   print "\tConducting Fisher exact test...\n";

   for(my $j = 0; $j <= $#lower_arr; $j++) {
      my $o_name = $o_name_pref . $ae_type . "." . $lower_arr[$j] . $o_name_suf;

      open(OUT,  ">$o_name");
      print OUT "Ensembl Gene ID\tEnhancer grp\tAE_nth\t";
      print OUT "Non-spliced without enhancer\tSpliced without enhancer\t";
      print OUT "Non-spliced with enhancer\tSpliced with enhancer\t";
      print OUT "Fisher P-value\tChi-square P-value\tOdds ratio\trelative risk\n";
   }

   open(FILE, $f_name);
   #===ignore def line===
   my $line = <FILE>;
   while($line = <FILE>) {
      my $data_h;

      printf("%.2f", ++$line_no / $max_line_no * 100);
      print "\%\r";

#      fisher_exact_test::parse_data($line, \%$data_h,
#                                    $tissue_aoh->[0]->{tissue_name},
#                                    $tissue_aoh->[0]->{srr_acc}) if $sample_ind_hash->{0} == 1;
      my_func::parse_data($line, \%$data_h,
                          $tissue_aoh->[0]->{tissue_name},
                          $tissue_aoh->[0]->{srr_acc});

      for(my $i = 1; $i < $no_tissue; $i++) {
         printf("%.2f", ++$line_no / $max_line_no * 100);
         print "\%\r";

         $line = <FILE>;
#         fisher_exact_test::parse_data($line, \%$data_h,
#                                       $tissue_aoh->[$i]->{tissue_name},
#                                       $tissue_aoh->[$i]->{srr_acc}) if $sample_ind_hash->{$i} == 1;
         my_func::parse_data($line, \%$data_h,
                             $tissue_aoh->[$i]->{tissue_name},
                             $tissue_aoh->[$i]->{srr_acc});
      }

      for(my $j = 0; $j <= $#lower_arr; $j++) {
         my $fisher_matrix;
         my $o_name = $o_name_pref . $ae_type . "." . $lower_arr[$j] . $o_name_suf;

         open(OUT,  ">>$o_name");

         my($fisher_p, $chi_p, $or, $rr) = my_stat::my_stat(\%$data_h, \%$fisher_matrix, $psi_thr_h, $ae_type, $lower_arr[$j], $upper_arr[$j]);

         #===output===
         print OUT "$data_h->{'Ensembl.Gene.ID'}\t$data_h->{'Ensembl.grp'}\t$data_h->{AE_nth}\t";
         print OUT "$fisher_matrix->{0}->{'neg'}\t$fisher_matrix->{0}->{'pos'}\t";
         print OUT "$fisher_matrix->{1}->{'neg'}\t$fisher_matrix->{1}->{'pos'}\t";
         print OUT "$fisher_p\t$chi_p\t$or\t$rr\n";
      }

      undef $data_h;
   }
   close(FILE);
   close(OUT);

   print "\nDone\n\n";
}
