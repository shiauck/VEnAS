#! /usr/bin/perl -w

use strict;
use lib '.';
use conf::check_status;
use POSIX qw(strftime);

die "Usage: $0 <bits5/bits7>\n" if $#ARGV != 0;
my $machine_id = $ARGV[0];
my $machine_load = 1;

my $conf_dir            = "conf";
my $miso_res_dir        = 'miso_result';
my $daemon_controller_f = "${conf_dir}/daemon_controller.txt";
my $daemon_read_list_f  = "${conf_dir}/reads_list.txt";

my $cont_flag = "1";
while($cont_flag eq '1') {
   if(-e "${conf_dir}/${machine_id}") {
      #===call MISO if machine is available===
      my $machine_status_text = `cat ${conf_dir}/${machine_id}`;
      chomp($machine_status_text);
      if($machine_status_text < $machine_load) {
         #===read list===
         my $status_h = check_status::load_status($daemon_read_list_f);
         #===read list===

         #===check mapped result & call mapping===
         foreach my $srr_acc(sort {$a cmp $b} keys %$status_h) {
            my $mapped_res_dir = "${miso_res_dir}/" .
                                  $status_h->{$srr_acc}->{tissue_name} . '/' .
                                  $status_h->{$srr_acc}->{GSM_acc} . '/' .
                                  $srr_acc;
            #===if find (mapped result & no MISO result)===
            if($status_h->{$srr_acc}->{mapped_status} eq 'Y' &&
               $status_h->{$srr_acc}->{MISO_status} eq 'N'){

               check_status::lock_machine("${conf_dir}/${machine_id}");

               #===update status===
               $status_h->{$srr_acc}->{MISO_status} = 'mapping';
               #===update status===

               #===output status file===
               check_status::write_status($daemon_read_list_f, $status_h);
               #===output status file===

               #===call MISO===
               my $cmd  = "nohup perl 4_miso.pl ";
                  $cmd .= "$status_h->{$srr_acc}->{tissue_name} ";
                  $cmd .= "$status_h->{$srr_acc}->{GSM_acc} ";
                  $cmd .= "$srr_acc ";
                  $cmd .= "$machine_id > ${miso_res_dir}/${srr_acc}.log";
                  $cmd .= ' 2>&1 &';
               print $cmd, "\n";
               system($cmd);
               #===call MISO===

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
