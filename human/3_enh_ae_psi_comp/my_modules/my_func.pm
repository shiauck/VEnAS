package my_func;

use strict;

sub get_tissue_hash($) {
   my $tissue_list = shift @_;
   my $tissue_hash;

   #===start from 0===
   my $line_no = -1;
   open(FILE, $tissue_list);
   while(my $line = <FILE>) {
      ++$line_no;
      chomp($line);
      my @line_arr = split("\t", $line);

      $tissue_hash->{$line_arr[0]}->{$line_arr[1]}->{$line_arr[2]} = $line_no;
   }
   close(FILE);

   return $tissue_hash;
}

sub get_tissue_aoh($) {
   my $tissue_list = shift @_;
   my $tissue_aoh;

   my $line_no = -1;
   open(FILE, $tissue_list);
   while(my $line = <FILE>) {
      ++$line_no;
      chomp($line);
      my @line_arr = split("\t", $line);

      $tissue_aoh->[$line_no]->{tissue_name} = $line_arr[0];
      $tissue_aoh->[$line_no]->{gsm_acc}     = $line_arr[1];
      $tissue_aoh->[$line_no]->{srr_acc}     = $line_arr[2];
   }
   close(FILE);

   return $tissue_aoh;
}

sub get_sample_list($$) {
   my($tissue_hash, $no_sampling) = shift @_;
   my $sample_ind_arr;

   #===generate tissue sampling list===
   foreach my $tissue_name(keys %$tissue_hash) {
      my @gsm_arr = keys %{$tissue_hash->{$tissue_name}};
      my $no_gsm = scalar(@gsm_arr);
#      die "\nError: $tissue_name has only $no_gsm samples !\n\n" if $no_gsm < 3;

#      my $gsm_list = non_repetitive_sampling(\@gsm_arr, 3);
#===test==
      my $gsm_list = non_repetitive_sampling(\@gsm_arr, 1);
#===test==

      foreach my $gsm_acc(@$gsm_list) {
         my @srr_arr = keys %{$tissue_hash->{$tissue_name}->{$gsm_acc}};
         my $srr_acc = non_repetitive_sampling(\@srr_arr, 1);
         push(@$sample_ind_arr, $tissue_hash->{$tissue_name}->{$gsm_acc}->{$srr_acc->[0]});
      }
   }

   return $sample_ind_arr;
}

sub non_repetitive_sampling($$) {
   my($sample_arr, $no_sampling) = @_;
   my $sample_list;

   die "\nNo. of sampling is larger than no. of input arr!\n\n" if $no_sampling > scalar(@$sample_arr);

   push(@$sample_list, splice(@$sample_arr, int(rand @$sample_arr), 1)) for 1 .. $no_sampling;

   return $sample_list;
}

sub parse_data($$$$) {
   my($line, $data_h, $tissue_name, $srr_acc) = @_;

   chomp($line);

   my @line_arr = split("\t", $line);

   $data_h->{'Ensembl.grp'}     = $line_arr[0];
   $data_h->{'Ensembl.Gene.ID'} = $line_arr[2];
   $data_h->{'AE_nth'}          = $line_arr[3];
   $data_h->{'data'}->{$tissue_name}->{$srr_acc}->{'Enhancer.status'} = $line_arr[1];
   $data_h->{'data'}->{$tissue_name}->{$srr_acc}->{'PSI'}             = $line_arr[4];
   $data_h->{'data'}->{$tissue_name}->{$srr_acc}->{'z_score'}         = $line_arr[5];

   #===for guarantee range of PSI===
   if($line_arr[4] ne 'NA') {
      if(!defined $data_h->{'max_psi'}) {
         $data_h->{'max_psi'} = $line_arr[4];
      }
      if(!defined $data_h->{'min_psi'}) {
         $data_h->{'min_psi'} = $line_arr[4];
      }

      $data_h->{'max_psi'} = $line_arr[4] if($data_h->{'max_psi'} < $line_arr[4]);
      $data_h->{'min_psi'} = $line_arr[4] if($data_h->{'min_psi'} > $line_arr[4]);
   }
   #===for guarantee range of PSI===

   return 1;
}

sub get_PSI_threshold($$) {
   my($threshold_f, $psi_thr_h) = @_;

   open(FILE, $threshold_f);
   #===def line===
   my $def_line = <FILE>;
   chomp($def_line);
   my @def_arr  = split("\t", $def_line);
   shift(@def_arr);

   #===z-transformed PSI===
   while(my $line = <FILE>) {
      chomp($line);
      my @line_arr = split("\t", $line);
      my $ae_type = shift @line_arr;
      foreach my $ele(@def_arr) {
         $psi_thr_h->{$ae_type}->{$ele} = shift @line_arr;
      }
   }
   close(FILE);

   return 1;
}

1;
