package my_chisq;

use strict;

sub calc_p($$$$){
   my($n11, $n10, $n01, $n00) = @_;

   use Statistics::ChisqIndep;
   use POSIX;

   my $p_val;

   my @obs = ([$n11, $n10], [$n01, $n00]);
   my $chi = new Statistics::ChisqIndep;
   $chi->load_data(\@obs);
   $p_val = $chi->{p_value};
#   $p_val = $chi->{warning} if $chi->{warning};

   return $p_val ;
}

1;
