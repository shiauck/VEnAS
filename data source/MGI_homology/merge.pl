#! /usr/bin/perl -w

use strict;

sub extract_gid($@);

# ==> HGNC_ID_2_Ensembl_Gene_ID.txt <==
# HGNC ID Ensembl ID(supplied by Ensembl)
# HGNC:5  ENSG00000121410

# ==> HOM_MouseHumanSequence.rpt <==
# HomoloGene ID   Common Organism Name    NCBI Taxon ID   Symbol  EntrezGene ID   Mouse MGI ID    HGNC ID OMIM Gene ID    Genetic Location        Genomic Coordinates (mouse: , human: ) Nucleotide RefSeq IDs   Protein RefSeq IDs      SWISS_PROT IDs
# 3       mouse, laboratory       10090   Acadm   11364   MGI:87867                       Chr3 78.77 cM   Chr3:153922357-153944632(-)     NM_007382     NP_031408        P45952

# ==> MGI_Gene_Model_Coord.rpt <==
# 1. MGI accession id     2. marker type  3. marker symbol        4. marker name  5. genome build 6. Entrez gene id       7. NCBI gene chromosome 8. NCBI gene start     9. NCBI gene end        10. NCBI gene strand    11. Ensembl gene id     12. Ensembl gene chromosome     13. Ensembl gene start  14. Ensembl gene end   15. Ensembl gene strand
# MGI:87853       Gene    a       nonagouti       GRCm38  50518   2       154950599       155051012       +       ENSMUSG00000027596      2       154791402      155051012       +

my $HGNC_f_name = "HGNC_ID_2_Ensembl_Gene_ID.txt";
my $mapping_f   = "HOM_MouseHumanSequence.rpt";
my $MGI_f_name  = "MGI_Gene_Model_Coord.rpt";

my $o1_name = "human_mouse_homologenes_in_Ensembl_ID.txt";
my $o2_name = "human_mouse_homologenes_in_Ensembl_ID.multi2multi.txt";

my $HGNC_h;
open(FILE, $HGNC_f_name);
<FILE>;
while(my $line = <FILE>) {
# ==> HGNC_ID_2_Ensembl_Gene_ID.txt <==
# HGNC ID Ensembl ID(supplied by Ensembl)
# HGNC:5  ENSG00000121410
   chomp($line);
   my @line_arr = split("\t", $line);

   next if(!defined $line_arr[1]);


   $HGNC_h->{$line_arr[0]}->{$line_arr[1]} = 1;
}
close(FILE);

my $MGI_h;
open(FILE, $MGI_f_name);
<FILE>;
while(my $line = <FILE>) {
# ==> MGI_Gene_Model_Coord.rpt <==
# 1. MGI accession id     2. marker type  3. marker symbol        4. marker name  5. genome build 6. Entrez gene id       7. NCBI gene chromosome 8. NCBI gene start     9. NCBI gene end        10. NCBI gene strand    11. Ensembl gene id     12. Ensembl gene chromosome     13. Ensembl gene start  14. Ensembl gene end   15. Ensembl gene strand
# MGI:87853       Gene    a       nonagouti       GRCm38  50518   2       154950599       155051012       +       ENSMUSG00000027596      2       154791402      155051012       +
   chomp($line);
   my @line_arr = split("\t", $line);

   $MGI_h->{$line_arr[0]}->{$line_arr[10]} = 1;
}
close(FILE);

my $mapping_h;
open(FILE, $mapping_f);
<FILE>;
while(my $line = <FILE>) {
# ==> HOM_MouseHumanSequence.rpt <==
# HomoloGene ID   Common Organism Name    NCBI Taxon ID   Symbol  EntrezGene ID   Mouse MGI ID    HGNC ID OMIM Gene ID    Genetic Location        Genomic Coordinates (mouse: , human: ) Nucleotide RefSeq IDs   Protein RefSeq IDs      SWISS_PROT IDs
# 3       mouse, laboratory       10090   Acadm   11364   MGI:87867                       Chr3 78.77 cM   Chr3:153922357-153944632(-)     NM_007382     NP_031408        P45952
   chomp($line);

   my @line_arr = split("\t", $line);

   $mapping_h->{$line_arr[0]}->{mouse}->{$line_arr[5]} = 1 if($line_arr[5] ne '');
   $mapping_h->{$line_arr[0]}->{human}->{$line_arr[6]} = 1 if($line_arr[6] ne '');
}
close(FILE);

#=== remove human or mouse only ===
foreach my $ele(keys %$mapping_h) {
   if(scalar(keys %{$mapping_h->{$ele}->{human}}) == 0 ||
      scalar(keys %{$mapping_h->{$ele}->{mouse}}) == 0) {
      delete($mapping_h->{$ele});
   }
}

open(OUT1, ">$o1_name");
open(OUT2, ">$o2_name");
#=== check multi 2 multi ===
my($counter_singular, $counter_multiple, $counter_unknown) = (0, 0, 0);
foreach my $ele(keys %$mapping_h) {
   if(scalar(keys %{$mapping_h->{$ele}->{human}}) == 1 &&
      scalar(keys %{$mapping_h->{$ele}->{mouse}}) == 1) {
      ++$counter_singular;

      print OUT1 join(',', keys %{$mapping_h->{$ele}->{human}}), "\t";
      print OUT1 join(',', extract_gid(\%$HGNC_h, keys %{$mapping_h->{$ele}->{human}})), "\t";

      print OUT1 join(',', keys %{$mapping_h->{$ele}->{mouse}}), "\t";
      print OUT1 join(',', extract_gid(\%$MGI_h, keys %{$mapping_h->{$ele}->{mouse}})), "\n";

   } elsif(scalar(keys %{$mapping_h->{$ele}->{human}}) > 1 ||
           scalar(keys %{$mapping_h->{$ele}->{mouse}}) > 1) {
      ++$counter_multiple;

      print OUT2 join(',', keys %{$mapping_h->{$ele}->{human}}), "\t";
      print OUT2 join(',', extract_gid(\%$HGNC_h, keys %{$mapping_h->{$ele}->{human}})), "\t";

      print OUT2 join(',', keys %{$mapping_h->{$ele}->{mouse}}), "\t";
      print OUT2 join(',', extract_gid(\%$MGI_h, keys %{$mapping_h->{$ele}->{mouse}})), "\n";

   } else {
      ++$counter_unknown;
   }
}
close(OUT1);
close(OUT2);

print "Singular: $counter_singular\n";
print "Multiple: $counter_multiple\n";
print "Unknown:  $counter_unknown\n";

sub extract_gid($@) {
   my($data_h, @key_arr) = @_;
   my @g_id;

   foreach my $key_id(@key_arr) {
      push @g_id, keys %{$data_h->{$key_id}};
   }

   return @g_id;
}
