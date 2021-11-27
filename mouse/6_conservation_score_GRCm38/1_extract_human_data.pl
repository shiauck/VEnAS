#! /usr/bin/perl -w

use strict;
#~/tools/bigWigSummary -type=mean ~/Ensembl_v94_compara_32_amniotes/gerp_conservation_scores.homo_sapiens.bw X 48930310 48931460 1

my $prog_name = "~/tools/bigWigSummary -type=mean";
my $bw_f      = "~/Ensembl_v94_compara_32_amniotes/gerp_conservation_scores.mus_musculus.bw";
my $f_dir     = "../4_motif_scan_GRCm38/";
my $f_pre     = "enhancer_list.";
my $f_suf     = ".bed";
my @as_type   = `cat as_list.txt`;
chomp(@as_type);
my @orient    = qw/concordant discordant no_significant/;

for(my $i = 0; $i <= $#as_type; $i++) {
   for(my $j = 0; $j <= $#orient; $j++) {
      my $f_name = $f_dir . $f_pre . $as_type[$i] . '.' . $orient[$j] . $f_suf;
      my $o_name = $as_type[$i] . '.' . $orient[$j] . '.conservation_score.txt';
      open(OUT, ">$o_name");
      open(FILE, $f_name);
      while(my $line = <FILE>) {
         chomp($line);
         my @line_arr = split("\t", $line);

         my $res = `$prog_name $bw_f $line_arr[0] $line_arr[1] $line_arr[2] 1`;
         chomp($res);

         if($res eq "") {
            print OUT "NA\n";
         } else {
            print OUT "$res\n";
         }
      }
      close(FILE);
      close(OUT);
   }
}
