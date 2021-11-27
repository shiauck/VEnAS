package my_fisher_2tail;

use strict;

sub calc_p($$$$){
   my($n11, $n1p, $np1, $npp) = @_;

   use Text::NSP::Measures::2D::Fisher::twotailed;

   my $p_val;
# https://metacpan.org/pod/Text::NSP::Measures::2D::Fisher::right
#       word2 ~word2
#  word1 n11    n12  n1p
# ~word1 n21    n22  n2p
#        np1    np2  npp
      $p_val = calculateStatistic(
                  n11 => $n11,
                  n1p => $n1p,
                  np1 => $np1,
                  npp => $npp);

      $p_val = getErrorMessage() if(getErrorCode());

   return $p_val;
}

1;
