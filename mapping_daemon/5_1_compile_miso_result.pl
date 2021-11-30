#! /usr/bin/perl -w

use strict;
use lib '.';
use conf::check_status;
use POSIX qw(strftime);

die "Usage: $0 <bits6>\n" if $#ARGV != 0;
my $machine_id   = $ARGV[0];
my $machine_load = 3;

my $conf_dir            = "conf";
my $miso_res_dir        = 'miso_result';
my $daemon_controller_f = "${conf_dir}/daemon_controller.txt";
my $daemon_read_list_f  = "${conf_dir}/reads_list.txt";

my $cont_flag = "1";
while($cont_flag eq '1') {
   if(-e "${conf_dir}/${machine_id}") {
      #===call data extract if machine is available===
      my $machine_status_text = `cat ${conf_dir}/${machine_id}`;
      chomp($machine_status_text);
      if($machine_status_text < $machine_load) {
         #===read list===
         my $status_h = check_status::load_status($daemon_read_list_f);
         #===read list===

         #===check mapped result & call mapping===
         foreach my $srr_acc(sort {$a cmp $b} keys %$status_h) {
            my $summary_f = "${miso_res_dir}/" .
                            $status_h->{$srr_acc}->{tissue_name} . '_' .
                            $status_h->{$srr_acc}->{GSM_acc} . '_' .
                            $srr_acc . ".psi.txt";
            #===if find (MISO result & no summary)===
            if($status_h->{$srr_acc}->{MISO_status} eq 'Y' &&
               !(-e $summary_f)){

               check_status::lock_machine("${conf_dir}/${machine_id}");

               #===call data extract===
               my $cmd  = "nohup perl 5_extract_psi.pl ";
                  $cmd .= "$status_h->{$srr_acc}->{tissue_name} ";
                  $cmd .= "$status_h->{$srr_acc}->{GSM_acc} ";
                  $cmd .= "$srr_acc ";
                  $cmd .= "$machine_id > ${miso_res_dir}/${srr_acc}.psi_extraction.log";
                  $cmd .= ' 2>&1 &';
               print $cmd, "\n";
               system($cmd);
               #===call data extract===

               last;
            }
         }
      }
   }

   sleep(300);

   #===examine controller signal===
   my $controller = `cat $daemon_controller_f`;
   chomp($controller);
   $cont_flag = "0" if($controller ne '1');
   #===examine controller signal===
}
