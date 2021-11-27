package my_relative_risk;

use strict;

sub calc_rr($$$$){
   my($n11, $n10, $n01, $n00) = @_;

   my $rr;
   if($n01 == 0 || ($n11 + $n10) == 0) {
      $rr = "Inf";
   } else {
      $rr = ($n11 / ($n11 + $n10)) / ($n01 / ($n01 + $n00));
   }

   return $rr ;
}

1;
