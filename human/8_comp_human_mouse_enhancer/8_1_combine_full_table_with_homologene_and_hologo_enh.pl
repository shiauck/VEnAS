#! /usr/bin/perl -w

my @as_type = qw/A5SS A3SS SE RI MSE MXE AFE ALE ATSS ATTS/;

my $f_pre = "../7_comp_bt_human_mouse_on_spleen/full_table.";
my $f_suf = ".txt";
my $o_pre = "full_table.homolo_gene_enh.";
my $o_suf = ".txt";

my $fisher_pre = "../3_enh_ae_psi_comp/res_2tailed/";
my $fisher_suf = ".stat.txt";
# 0               1            2      3                            4                        5                         6                     7              8          9
# Ensembl.Gene.ID Enhancer.grp AE_nth Non.spliced.without.enhancer Spliced.without.enhancer Non.spliced.with.enhancer Spliced.with.enhancer Fisher.P.value Odds.ratio q_fdr

my $homologene_f = "~/MGI_homology/human_mouse_homologenes_in_Ensembl_ID.txt";
# "HGNC_id"\t"human_gid"\t"MGI_id"\t"mouse_gid"
# HGNC:462    ENSG00000099721    MGI:88005    ENSMUSG00000031354

my $homolo_enh_f = "human_enh_ovlap_mouse_enh.reduced.sorted.txt";
# "human_enh_id";"mouse_enh_id"

print "Loading homologene table...";
my $homologene_h;
open(FILE, $homologene_f);
while(my $line = <FILE>) {
   chomp($line);
   my @line_arr = split('\t', $line);
   next if($line_arr[1] eq '' || $line_arr[1] eq 'null');
   next if(!defined $line_arr[3] || $line_arr[3] eq '' || $line_arr[3] eq 'null');

   $homologene_h->{$line_arr[1]} = 1;
}
close(FILE);
print "Done\n\n";

print "Loading homolo enhancer data...";
my $homolo_enh_h;
open(FILE, $homolo_enh_f);
while(my $line = <FILE>) {
   chomp($line);
   my @line_arr = split(';', $line);

   $homolo_enh_h->{$line_arr[0]} = 1;
}
close(FILE);
print "Done\n\n";

for(my $i = 0; $i <= $#as_type; $i++) {
   print "Processing $as_type[$i]...\n";

   print "\tLoading fisher result table...";
   my $fisher_h;
   open(FILE, "$fisher_pre$as_type[$i]$fisher_suf");
   <FILE>;
   while(my $line = <FILE>) {
      chomp($line);
      my @line_arr = split("\t", $line);

      $fisher_h->{$line_arr[0]}->{$line_arr[1]}->{$line_arr[2]} = $line_arr[9];
   }
   close(FILE);
   print "Done\n";

   print "\tCombining data...";
   open(FILE, "$f_pre$as_type[$i]$f_suf");
   open(OUT, ">$o_pre$as_type[$i]$o_suf");
   my $def_line = <FILE>;
   chomp($def_line);
   print OUT $def_line, "\tq_fdr\thomologene\thomolo_enhancer\n";
   while(my $line = <FILE>) {
      chomp($line);
      my @line_arr = split("\t", $line);

      print OUT $line, "\t";

      (defined $fisher_h->{$line_arr[0]}->{$line_arr[1]}->{$line_arr[2]})?
         (print OUT $fisher_h->{$line_arr[0]}->{$line_arr[1]}->{$line_arr[2]}, "\t"):
         (print OUT "NA\t");

      (defined $homologene_h->{$line_arr[0]})?(print OUT "1\t"):(print OUT "0\t");

      (defined $homolo_enh_h->{$line_arr[1]})?(print OUT "1\n"):(print OUT "0\n");
   }
   close(OUT);
   close(FILE);
   print "Done\n\n";
}
