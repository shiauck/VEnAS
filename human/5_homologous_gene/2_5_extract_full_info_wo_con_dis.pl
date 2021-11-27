#! /usr/bin/perl -w

use strict;

my $human_gene_dir = "human.";
my $human_mapping  = "~/MGI_homology/HGNC_ID_2_Ensembl_Gene_ID.txt";
my $mouse_gene_dir = "mouse.";
my $mouse_mapping  = "~/MGI_homology/MGI_Gene_Model_Coord.rpt";
my $MGI_mapping_f  = "~/MGI_homology/HOM_MouseHumanSequence.rpt";
my @as_type        = `cat as_list.txt`;
chomp(@as_type);
my @orient         = qw/concordant discordant/;

#=== loading mapping data ===
my $mgi_h;
open(FILE, $MGI_mapping_f);
<FILE>;
# 0  HomoloGene ID
# 1  Common Organism Name
# 2  NCBI Taxon ID
# 3  Symbol
# 4  EntrezGene ID
# 5  Mouse MGI ID
# 6  HGNC ID
# 7  OMIM Gene ID
# 8  Genetic Location
# 9  Genomic Coordinates (mouse: , human: )
# 10 Nucleotide RefSeq IDs
# 11 Protein RefSeq IDs
# 12 SWISS_PROT IDs
while(my $line = <FILE>) {
   my @line_arr = split("\t", $line);
   $mgi_h->{$line_arr[0]}->{human} = $line_arr[6] if $line_arr[6] ne '';
   $mgi_h->{$line_arr[0]}->{mouse} = $line_arr[5] if $line_arr[5] ne '';
}
close(FILE);
#=== loading mapping data ===

#===convert mapping hash===
my $mapping_h;
foreach my $homo_id(keys %$mgi_h) {
   if(defined $mgi_h->{$homo_id}->{human} && defined $mgi_h->{$homo_id}->{mouse}) {
      $mapping_h->{$mgi_h->{$homo_id}->{human}}->{$mgi_h->{$homo_id}->{mouse}} = 1;
   }
}
#===convert mapping hash===

for(my $i = 0; $i <= $#as_type; $i++) {
   print "$as_type[$i]:\n";
   my($human_gene_h, $human_gene_total_h, $human_gene_noass_h);
   my($mouse_gene_h, $mouse_gene_total_h, $mouse_gene_noass_h);


   for(my $j = 0; $j <= $#orient; $j++) {
      #=== load human gene ===
      my $human_gene_f = $human_gene_dir . $as_type[$i] . '.' . $orient[$j] . '.txt';
      open(FILE, $human_gene_f);
      while(my $line = <FILE>) {
         chomp($line);
         $human_gene_h->{$line} = 1;
      }
      close(FILE);

      #=== load human gene ===
      my $human_gene_total_f = $human_gene_dir . $as_type[$i] . '.' . $orient[$j] . '.total.txt';
      open(FILE, $human_gene_total_f);
      while(my $line = <FILE>) {
         chomp($line);
         $human_gene_total_h->{$line} = 1;
      }
      close(FILE);

      #=== load mouse gene ===
      my $mouse_gene_f = $mouse_gene_dir . $as_type[$i] . '.' . $orient[$j] . '.txt';
      open(FILE, $mouse_gene_f);
      while(my $line = <FILE>) {
         chomp($line);
         $mouse_gene_h->{$line} = 1;
      }
      close(FILE);

      #=== load mouse gene ===
      my $mouse_gene_total_f = $mouse_gene_dir . $as_type[$i] . '.' . $orient[$j] . '.total.txt';
      open(FILE, $mouse_gene_total_f);
      while(my $line = <FILE>) {
         chomp($line);
         $mouse_gene_total_h->{$line} = 1;
      }
      close(FILE);
   }

   #===extract Non-associated list===
   foreach my $gid (keys %$human_gene_total_h) {
      $human_gene_noass_h->{$gid} = 1 if(!defined $human_gene_h->{$gid});
   }
   foreach my $gid (keys %$mouse_gene_total_h) {
      $mouse_gene_noass_h->{$gid} = 1 if(!defined $mouse_gene_h->{$gid});
   }


      #=== human mapping ===
      my($human_conv_h, $human_conv_noass_h);
      open(FILE, $human_mapping);
      <FILE>;
# 0      	1
# HGNC ID	Ensembl ID(supplied by Ensembl)
      while(my $line = <FILE>) {
         chomp($line);
         my @line_arr = split("\t", $line);
         next if $#line_arr != 1;
         $human_conv_h->{$line_arr[0]}       = $line_arr[1] if(defined $human_gene_h->{$line_arr[1]});
         $human_conv_noass_h->{$line_arr[0]} = $line_arr[1] if(defined $human_gene_noass_h->{$line_arr[1]});
      }
      close(FILE);

      #=== mouse mapping ===
      my($mouse_conv_h, $mouse_conv_noass_h);
      open(FILE, $mouse_mapping);
      <FILE>;
# 0.  MGI accession id
# 1.  marker type
# 2.  marker symbol
# 3.  marker name
# 4.  genome build
# 5.  Entrez gene id
# 6.  NCBI gene chromosome
# 7.  NCBI gene start
# 8.  NCBI gene end
# 9.  NCBI gene strand
# 10. Ensembl gene id
# 11. Ensembl gene chromosome
# 12. Ensembl gene start
# 13. Ensembl gene end
# 14. Ensembl gene strand
      while(my $line = <FILE>) {
         chomp($line);
         my @line_arr = split("\t", $line);
         next if $#line_arr != 14;
         $mouse_conv_h->{$line_arr[0]}       = $line_arr[10] if(defined $mouse_gene_h->{$line_arr[10]});
         $mouse_conv_noass_h->{$line_arr[0]} = $line_arr[10] if(defined $mouse_gene_noass_h->{$line_arr[10]});
      }
      close(FILE);

      #=== comparing ===
      my $counter = 0;
      foreach my $h_id(keys %$human_conv_h) {
         foreach my $m_id(keys %$mouse_conv_h) {
            if(defined $mapping_h->{$h_id}->{$m_id} && $mapping_h->{$h_id}->{$m_id} == 1) {
               ++$counter;
#               print $counter, "\t", $human_conv_h->{$h_id}, "\t", $mouse_conv_h->{$m_id}, "\n";
            }
         }
      }
      print "human       associated            genes: ", scalar(keys %$human_gene_h), "\n";
      print "human-mouse associated homologous genes: $counter\n";
      print "mouse       associated            genes: ", scalar(keys %$mouse_gene_h), "\n";

         $counter = 0;
      foreach my $h_id(keys %$human_conv_noass_h) {
         foreach my $m_id(keys %$mouse_conv_noass_h) {
            if(defined $mapping_h->{$h_id}->{$m_id} && $mapping_h->{$h_id}->{$m_id} == 1) {
               ++$counter;
#               print $counter, "\t", $human_conv_h->{$h_id}, "\t", $mouse_conv_h->{$m_id}, "\n";
            }
         }
      }
      print "human       non-associated            genes: ", scalar(keys %$human_gene_noass_h), "\n";
      print "human-mouse non-associated homologous genes: $counter\n";
      print "mouse       non-associated            genes: ", scalar(keys %$mouse_gene_noass_h), "\n";


      #=== report ===
#      print "human_gene_h: ", scalar(keys %$human_gene_h), "\n";
#      print "human_conv_h: ", scalar(keys %$human_conv_h), "\n";
#      print "mouse_gene_h: ", scalar(keys %$mouse_gene_h), "\n";
#      print "mouse_conv_h: ", scalar(keys %$mouse_conv_h), "\n";

      print "\n\n";
}
