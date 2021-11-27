package my_stat;

use lib '.';
use strict;

sub my_stat($$$$$$){
   my($data_h, $data_matrix, $psi_thr_h, $ae_type, $lower_thr, $upper_thr) = @_;

   use my_modules::my_fisher_2tail;
   use my_modules::my_chisq;
   use my_modules::my_odds_ratio;
   use my_modules::my_relative_risk;

   #===initialize matrix===
   #               enh    psi
   $data_matrix->{0}->{'neg'} = 0;
   $data_matrix->{0}->{'pos'} = 0;
   $data_matrix->{1}->{'neg'} = 0;
   $data_matrix->{1}->{'pos'} = 0;

   foreach my $tissue_id(keys %{$data_h->{'data'}}) {
      foreach my $rep_id(keys %{$data_h->{'data'}->{$tissue_id}}) {
         my $enh_s = $data_h->{'data'}->{$tissue_id}->{$rep_id}->{'Enhancer.status'};
         my $psi_s = "0";

#=== set PSI status ===
         $psi_s = "1"
            if($data_h->{'data'}->{$tissue_id}->{$rep_id}->{'z_score'} ne "NA" &&
               $data_h->{'data'}->{$tissue_id}->{$rep_id}->{'z_score'} >= $psi_thr_h->{$ae_type}->{$upper_thr});
         $psi_s = "-1"
            if($data_h->{'data'}->{$tissue_id}->{$rep_id}->{'z_score'} ne "NA" &&
               $data_h->{'data'}->{$tissue_id}->{$rep_id}->{'z_score'} <= $psi_thr_h->{$ae_type}->{$lower_thr});

         if($enh_s eq "1") {
            $data_matrix->{1}->{'pos'} += 1 if($psi_s eq "1");
            $data_matrix->{1}->{'neg'} += 1 if($psi_s eq "-1");
         } else {
            $data_matrix->{0}->{'pos'} += 1 if($psi_s eq "1");
            $data_matrix->{0}->{'neg'} += 1 if($psi_s eq "-1");
         }
      }
   }

   #===The difference between concordant group and discordant group must be larger than 10===
   if(abs(($data_matrix->{1}->{'pos'} + $data_matrix->{0}->{'neg'}) -
          ($data_matrix->{1}->{'neg'} + $data_matrix->{0}->{'pos'})) > 10) {

#      Inclusion Exclusion
#  Enh    n11       n10    n1p
# ~Enh    n01       n00    n0p
#         np1       np0    npp

      my $n11 = $data_matrix->{1}->{'pos'};
      my $n1p = $data_matrix->{1}->{'pos'} + $data_matrix->{1}->{'neg'};
      my $np1 = $data_matrix->{1}->{'pos'} + $data_matrix->{0}->{'pos'};
      my $npp = ($data_matrix->{1}->{'pos'} + $data_matrix->{1}->{'neg'} +
                 $data_matrix->{0}->{'pos'} + $data_matrix->{0}->{'neg'});

      my($fisher_p, $chi_p, $or, $rr) = ("NA", "NA", "NA", "NA");
      unless(($data_matrix->{0}->{'neg'} + $data_matrix->{0}->{'pos'}) == 0 ||
             ($data_matrix->{1}->{'neg'} + $data_matrix->{1}->{'pos'}) == 0 ||
             ($data_matrix->{0}->{'neg'} + $data_matrix->{1}->{'neg'}) == 0 ||
             ($data_matrix->{0}->{'pos'} + $data_matrix->{1}->{'pos'}) == 0) {

         $fisher_p = my_fisher_2tail::calc_p($n11, $n1p, $np1, $npp);
#      $chi_p    = my_chisq::calc_p($data_matrix->{1}->{'pos'}, $data_matrix->{1}->{'neg'},
#                                   $data_matrix->{0}->{'pos'}, $data_matrix->{0}->{'neg'});
         $or       = my_odds_ratio::calc_or($n11, $n1p, $np1, $npp);
#      $rr       = my_relative_risk::calc_rr($data_matrix->{1}->{'pos'}, $data_matrix->{1}->{'neg'},
#                                            $data_matrix->{0}->{'pos'}, $data_matrix->{0}->{'neg'});
      }
      return($fisher_p, $or);
   } else {
      return("NA", "NA");
   }
}

1;
