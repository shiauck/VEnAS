package fisher_exact_test_concordant;

use strict;

sub conduct_fisher_exact_test_concordant($$$$$$){
   my($data_h, $fisher_matrix, $psi_thr_h, $ae_type, $lower_thr, $upper_thr) = @_;

   use Text::NSP::Measures::2D::Fisher::right;

   #===initialize matrix===
   #               enh    psi
   $fisher_matrix->{0}->{'neg'} = 0;
   $fisher_matrix->{0}->{'pos'} = 0;
   $fisher_matrix->{1}->{'neg'} = 0;
   $fisher_matrix->{1}->{'pos'} = 0;

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
            $fisher_matrix->{1}->{'pos'} += 1 if($psi_s eq "1");
            $fisher_matrix->{1}->{'neg'} += 1 if($psi_s eq "-1");
         } else {
            $fisher_matrix->{0}->{'pos'} += 1 if($psi_s eq "1");
            $fisher_matrix->{0}->{'neg'} += 1 if($psi_s eq "-1");
         }
      }
   }

   my $p_val;
   #===if any marginal sum is zero, then p-value is NA===
   if(($fisher_matrix->{0}->{'neg'} + $fisher_matrix->{0}->{'pos'}) == 0 ||
      ($fisher_matrix->{1}->{'neg'} + $fisher_matrix->{1}->{'pos'}) == 0 ||
      ($fisher_matrix->{0}->{'neg'} + $fisher_matrix->{1}->{'neg'}) == 0 ||
      ($fisher_matrix->{0}->{'pos'} + $fisher_matrix->{1}->{'pos'}) == 0) {

      $p_val = "NA";
   } else {
# https://metacpan.org/pod/Text::NSP::Measures::2D::Fisher::right
#       word2 ~word2
#  word1 n11    n12  n1p
# ~word1 n21    n22  n2p
#        np1    np2  npp
      $p_val = calculateStatistic(
                  n11 =>  $fisher_matrix->{0}->{'neg'},
                  n1p => ($fisher_matrix->{0}->{'neg'} + $fisher_matrix->{0}->{'pos'}),
                  np1 => ($fisher_matrix->{0}->{'neg'} + $fisher_matrix->{1}->{'neg'}),
                  npp => ($fisher_matrix->{0}->{'neg'} + $fisher_matrix->{0}->{'pos'} +
                          $fisher_matrix->{1}->{'neg'} + $fisher_matrix->{1}->{'pos'}));

      my $errorCode = getErrorCode();
      if($errorCode) {
         die $errorCode." - ".getErrorMessage();
      }
   }

   return $p_val;
}

1;
