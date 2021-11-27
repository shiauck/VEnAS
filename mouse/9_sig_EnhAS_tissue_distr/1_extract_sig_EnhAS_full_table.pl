#! /usr/bin/perl -w

use strict;

$| = 1;

my @as_type_arr = qw/A5SS A3SS SE RI MSE MXE AFE ALE ATSS ATTS/;

foreach my $as_type(@as_type_arr) {
   print "Processing ${as_type} ...\n";

   my $sig_EnhAS_f_name = "../3_enh_ae_psi_comp/res_2tailed/${as_type}.stat.txt";

   my $sig_EnhAS_h;
   open(FILE, $sig_EnhAS_f_name);
   <FILE>;
   while(my $line = <FILE>) {
      chomp($line);
      my @line_arr = split("\t", $line);
      $sig_EnhAS_h->{$line_arr[0]}->{$line_arr[1]}->{$line_arr[2]} = $line_arr[9] if($line_arr[9] < 0.05);
   }
   close(FILE);

   my $full_table_f_name = "../7_comp_bt_human_mouse_on_spleen/full_table.${as_type}.txt";
   my $line_no = `wc -l $full_table_f_name | cut -d ' ' -f1`;
   chomp($line_no);
   my $o_name = "sig_EnhAS_full_table.${as_type}.txt";
   open(OUT, ">$o_name");
   open(FILE, $full_table_f_name);
   my $def_line = <FILE>;
   chomp($def_line);
   print OUT $def_line, "\tq_fdr\n";
   my $counter = 0;
   while(my $line = <FILE>) {
      print ++$counter, " of ", $line_no, ': ';
      printf("%.2f", $counter / $line_no * 100);
      print "%\r";
      chomp($line);
      my @line_arr = split("\t", $line);

      print OUT $line, "\t$sig_EnhAS_h->{$line_arr[0]}->{$line_arr[1]}->{$line_arr[2]}\n" if(defined $sig_EnhAS_h->{$line_arr[0]}->{$line_arr[1]}->{$line_arr[2]} && $sig_EnhAS_h->{$line_arr[0]}->{$line_arr[1]}->{$line_arr[2]} < 0.05);
   }
   print "        Done...                              \n";
   close(FILE);
   close(OUT);
}
