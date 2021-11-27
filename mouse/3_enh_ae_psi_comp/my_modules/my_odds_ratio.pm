package my_odds_ratio;

use strict;

sub calc_or($$$$){
   my($n11, $n1p, $np1, $npp) = @_;

   use Text::NSP::Measures::2D::odds;

   my $odds_value = calculateStatistic(
                       n11=>$n11,
                       n1p=>$n1p,
                       np1=>$np1,
                       npp=>$npp);

      $odds_value = getErrorMessage() if(getErrorCode());

   return $odds_value;
}

1;
