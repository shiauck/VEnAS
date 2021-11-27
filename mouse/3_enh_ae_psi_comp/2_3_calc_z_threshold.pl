#! /usr/bin/perl -w

use strict;
use POSIX;

my @ae_type = qw/A5SS A3SS SE RI MSE MXE ATSS ATTS AFE ALE/;
my @thr_arr = qw/0.025 0.05 0.1 0.16 0.2 0.25 0.75 0.8 0.84 0.9 0.95 0.975/;
my $o_name = "z_score_thresholds.txt";

open(OUT, ">$o_name");
print OUT "\t", join("\t", @thr_arr), "\n";
for(my $ae_idx = 0; $ae_idx <= $#ae_type; $ae_idx++) {
   print "Extracting and sorting $ae_type[$ae_idx]...";
   my $f_name = "1_1_enhancer_ensid_ae_psi." . $ae_type[$ae_idx] . ".txt";
   my $cmd = "cut -f6 $f_name | awk 'NR>1 {if(\$0 != \"NA\") {print \$0}}' | sort -n > tmp.txt";
   system($cmd);
   print "Done\n";

   print "Calculating file line no...";
   my $f_line_no = `wc -l tmp.txt | cut -d ' ' -f1`;
   chomp($f_line_no);
   print "Done\n";

   print OUT $ae_type[$ae_idx];
   for(my $thr_idx = 0; $thr_idx <= $#thr_arr; $thr_idx++) {
      print "\tcalculating $thr_arr[$thr_idx]...";
      my $this_line_no = $f_line_no * $thr_arr[$thr_idx];

      if(($this_line_no - floor($this_line_no)) > 0) {
         #===odd line===
         $this_line_no = floor($this_line_no) + 1;
         my @res_arr = `head -n $this_line_no tmp.txt | tail -n 2`;
         chomp(@res_arr);
         print OUT "\t", ($res_arr[0] + $res_arr[1]) / 2;
      } else {
         #===even line===
         my $res_line = `head -n $this_line_no tmp.txt | tail -n 1`;
         chomp($res_line);
         print OUT "\t", $res_line;
      }
      print "Done\n";
   }
   print OUT "\n";
   print "Finalizing...";
   system("rm tmp.txt");
   print "Done\n\n";
}
close(OUT);
