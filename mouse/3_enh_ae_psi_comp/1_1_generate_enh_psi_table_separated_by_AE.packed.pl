#! /usr/bin/perl -w

use strict;
use Statistics::Basic qw(:all);
use List::Util qw(sum);
$| = 1;

my $o_prefix = "1_1_enhancer_ensid_ae_psi.";
my $o_suffix = ".txt";

#===load AS list===
my $as_list = "as_list.txt";
my @as_arr  = `cat $as_list`;
chomp(@as_arr);

#===load enhancer data===
print "Loading enhancer data...\n";
my $bed_f = "../1_EPU_clustering/epu_1500.bed";
my $bed_h;
open(FILE, $bed_f);
while(my $line = <FILE>) {
   my @line_arr = split("\t", $line);
   my @info_arr = split(';', $line_arr[3]);

   my $refseq = $info_arr[2];
   #           ens_gid    enhancer grp    tissue name
      $bed_h->{$refseq}->{$info_arr[0]}->{$info_arr[1]} = 1;
}
close(FILE);
print "Done\n";

#===load psi===
print "Loading PSI data...\n";
my $psi_f = "psi.txt";
my $psi_h;
my @no_line = split(' ', `wc -l $psi_f`);
my $counter;
open(FILE, $psi_f);
while(my $line = <FILE>) {
   printf("%.2f", ++$counter / $no_line[0] * 100);
   print "\%\r";

   chomp($line);
   my @line_arr = split("\t", $line);
   #          ens_gid         ae_type           n_th       tissue_gsm_srr       psi
   $psi_h->{$line_arr[0]}->{$line_arr[3]}->{$line_arr[1]}->{$line_arr[2]} = $line_arr[4];
}
close(FILE);
print "\nDone\n";

#===load tissue===
my $tissue_f   = "tissue_list.txt";
my @tissue_arr = `sed 's/\t/_/g' $tissue_f`;
chomp(@tissue_arr);

#===load psi===
print "Converting...\n";

#===initialize output files===
for(my $i = 0; $i <= $#as_arr; $i++) {
   my $o_name = $o_prefix . $as_arr[$i] . $o_suffix;
   open(OUT, ">$o_name");
   print OUT "Enhancer grp\tEnhancer status\tEnsembl Gene ID\tAE_nth\tPSI\tz_score\n";
   close(OUT);

      $o_name = $o_prefix . $as_arr[$i] . ".stat" . $o_suffix;
   open(OUT, ">$o_name");
   print OUT "Enhancer grp\tEnsembl Gene ID\tAE_nth\tmean_PSI\tSD_PSI\tmedian_PSI\n";
   close(OUT);
}
#===initialize output files===

#===for every Ensembl Gene ID===
my $ens_gid_counter = -1;
my $ens_gid_max = scalar(keys %$bed_h);
foreach my $ens_gid(keys %$bed_h) {
   ++$ens_gid_counter;

   #===for every enhancer group under RefSeq===
   my $enh_grp_counter = -1;
   my $enh_grp_max = scalar(keys %{$bed_h->{$ens_gid}});
   foreach my $enh_grp(keys %{$bed_h->{$ens_gid}}) {
      ++$enh_grp_counter;

      if(defined $psi_h->{$ens_gid} &&
         scalar(keys %{$psi_h->{$ens_gid}}) > 0) {

         #===for each AE type===
         foreach my $ae_type(keys %{$psi_h->{$ens_gid}}) {
            print "$ens_gid_counter/$ens_gid_max genes, ";
            print "$enh_grp_counter/$enh_grp_max enhancers: ";
            print $ae_type, "\r";

            #===for each AE events inside gene===
            foreach my $nth(keys %{$psi_h->{$ens_gid}->{$ae_type}}) {

               #===for all tissue types===
               my($temp_text, $temp_stat_text, $psi_arr, @calc_mean);
               #===compiling stat into temp_stat_text===
               $temp_stat_text = "$enh_grp\t$ens_gid\t$nth\t";
               #===compiling output into temp_text===
               for(my $tid = 0; $tid <= $#tissue_arr; $tid++) {
                  #   tissue name might contain "_", use split & join to separate
                  #   tissue name+GSM acc to $tissue, SRR acc into $rep
                  my @tissue_str = split('_', $tissue_arr[$tid]);
                  my $tissue = join('_', @tissue_str[0 .. ($#tissue_str - 1)]);
                  my $rep    = $tissue_str[$#tissue_str];

                  my $enh_flag = "0";
                  if(defined $bed_h->{$ens_gid}->{$enh_grp}->{$tissue_str[0]} &&
                             $bed_h->{$ens_gid}->{$enh_grp}->{$tissue_str[0]} == 1) {
                     $enh_flag = "1";
                  }

                  $temp_text->[$tid] = "$enh_grp\t$enh_flag\t$ens_gid\t$nth\t";

                  #===compile PSI into temp_text===
                  if(defined $psi_h->{$ens_gid}->{$ae_type}->{$nth}->{$tissue_arr[$tid]}) {
                     $temp_text->[$tid] .= $psi_h->{$ens_gid}->{$ae_type}->{$nth}->{$tissue_arr[$tid]} . "\t";
                     $psi_arr->[$tid]    = $psi_h->{$ens_gid}->{$ae_type}->{$nth}->{$tissue_arr[$tid]};
                     push(@calc_mean, $psi_h->{$ens_gid}->{$ae_type}->{$nth}->{$tissue_arr[$tid]})
                  } else {
                     $temp_text->[$tid] .= "NA\t";
                     $psi_arr->[$tid]    = "NA";
                  }
                  #===compile PSI into temp_text===
               }
               #===compiling output into temp_text===

               #===calc mean & stddev.s, must have at least 3 samples===
               my($mean_psi, $sd_psi, $med_psi) = ("NA", "NA", "NA");
               if($#calc_mean > 2) {
                  $mean_psi = sprintf("%.6f", mean(@calc_mean));
                  $sd_psi   = sprintf("%.6f", sqrt(variance(@calc_mean) * ($#calc_mean + 1) / $#calc_mean));
                  $med_psi  = sprintf("%.6f", median(@calc_mean));
               }
               #===compile mean sd med into temp_stat_text===
               $temp_stat_text .= "$mean_psi\t$sd_psi\t$med_psi\n";
               #===calc mean & stddev.s, must have at least 4 replicates===

               #===calc z_score & compile result===
               for(my $tid = 0; $tid <= $#tissue_arr; $tid++) {

                  ($mean_psi ne "NA" && $psi_arr->[$tid] ne "NA")?
                     #===more than 4 replicates===
                     ($temp_text->[$tid] .= sprintf("%.6f", ($psi_arr->[$tid] - $mean_psi) / $sd_psi) . "\n"):
                     #===less than 4 replicates===
                     ($temp_text->[$tid] .= "NA\n");
               }
               #===calc z_score & compile result===

               #===output temp_text===
               my $o_name = $o_prefix . $ae_type . $o_suffix;
               open(OUT, ">>$o_name");
               print OUT join("", @$temp_text);
               close(OUT);
               #===output temp_text===

               #===output temp_stat_text===
                  $o_name = $o_prefix . $ae_type . ".stat" . $o_suffix;
               open(OUT, ">>$o_name");
               print OUT $temp_stat_text;
               close(OUT);
               #===output temp_stat_text===
            }
         }
      }
   }
}

print "\nDone\n\n";
