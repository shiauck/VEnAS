package check_status;

use strict;
use base 'Exporter';
use POSIX qw(strftime);

our @EXPORT_OK = ('load_status', 'write_status', 'lock_machine', 'unlock_machine');

sub load_status($) {
   my $status_h;
   my $status_file_name = shift @_;

   #===waiting for config file===
   while(1) {
      if(-e $status_file_name) {
         last;
      } else {
         my $datestring = strftime "%a %b %e %H:%M:%S %Y", localtime;
         print "waiting for config file...\n";
         print "$0: $datestring\n";
         sleep(60);
      }
   }

   #===read status title===
   my $list_title_line = `head -n 1 $status_file_name`;
   chomp($list_title_line);
   my @list_title_arr  = split("\t", $list_title_line);

   #===read status===
   my @list_arr = `cat $status_file_name`;
   chomp(@list_arr);

   #===assign value===
   for(my $i = 1; $i <= $#list_arr; $i++) {
      my @line_arr = split("\t", $list_arr[$i]);

      #===by title===
      for(my $j = 0; $j <= $#list_title_arr; $j++) {
         #             SRR_acc
         $status_h->{$line_arr[2]}->{$list_title_arr[$j]} = $line_arr[$j];
      }
   }

   return $status_h;
}

sub write_status($$) {
   my($status_file_name, $status_h) = @_;
   my $lock_f = $status_file_name . ".lock";

   #===waiting for config file===
   while(1) {
      #===lock config file===
      if(-e $status_file_name) {
         system("mv $status_file_name $lock_f");
         last;
      }

      my $datestring = strftime "%a %b %e %H:%M:%S %Y", localtime;
      print "waiting for config file...\n";
      print "$0: $datestring\n";
      sleep(30);
   }

   #===read status title===
   my $list_title_line = `head -n 1 $lock_f`;
   chomp($list_title_line);
   my @list_title_arr  = split("\t", $list_title_line);

   #===print title===
   open(OUT, ">$lock_f");
   print OUT join("\t", @list_title_arr), "\n";

   foreach my $srr_acc(sort {$status_h->{$a}->{tissue_name} cmp $status_h->{$b}->{tissue_name} ||
                             $status_h->{$a}->{GSM_acc}     cmp $status_h->{$b}->{GSM_acc}     ||
                             $status_h->{$a}->{SRR_acc}     cmp $status_h->{$b}->{SRR_acc}     }
                       keys %$status_h) {
      for(my $i = 0; $i <= $#list_title_arr; $i++) {
         print OUT "\t" if $i > 0;
         print OUT $status_h->{$srr_acc}->{$list_title_arr[$i]};
      }
      print OUT "\n";
   }
   close(OUT);

#===backup config file===
#my $datestring = strftime "%a_%b_%e_%H:%M:%S_%Y", localtime;
#my $backup_f = $status_file_name . ".$datestring.backup";
#print "\$backup_f: $backup_f\n";
#open(OUT, ">$backup_f");
#print OUT "Generating by: $0\n";
#print OUT join("\t", @list_title_arr), "\n";
#foreach my $srr_acc(sort {$status_h->{$a}->{tissue_name} cmp $status_h->{$b}->{tissue_name} ||
#                          $status_h->{$a}->{GSM_acc}     cmp $status_h->{$b}->{GSM_acc}     ||
#                          $status_h->{$a}->{SRR_acc}     cmp $status_h->{$b}->{SRR_acc}     }
#                    keys %$status_h) {
#   for(my $i = 0; $i <= $#list_title_arr; $i++) {
#      print OUT "\t" if $i > 0;
#      print OUT $status_h->{$srr_acc}->{$list_title_arr[$i]};
#   }
#   print OUT "\n";
#}
#close(OUT);

   #===unlock config file===
   print  "Unlock config file: $status_file_name...\n";
   system("mv $lock_f $status_file_name");

   return 1;
}

sub lock_machine($) {
   my $machine_f = shift @_;
   my $enc_machine_f = $machine_f;

   my @encrypt_code = ("A".."Z", "a".."z");
   $enc_machine_f .= $encrypt_code[rand @encrypt_code] for 1..8;

   while(1) {
      #===prevent I/O delay===
      if(-e "$machine_f") {
         system("mv $machine_f $enc_machine_f");

         open(FILE, "$enc_machine_f");
         my $machine_status = <FILE>;
         chomp($machine_status);
         close(FILE);

         my $new_status = $machine_status + 1;

         my $datestring = strftime "%a %b %e %H:%M:%S %Y", localtime;
         print "$datestring: $0\t$machine_f\t$machine_status to $new_status\n";

         open(OUT, ">$enc_machine_f");
         print OUT $new_status;
         close(OUT);

         system("mv $enc_machine_f $machine_f");

         last;
      }

      my $datestring = strftime "%a %b %e %H:%M:%S %Y", localtime;
      print "waiting for locking machine: $machine_f...\n";
      print "$0: $datestring\n";
      sleep(30);
   }

   return;
}

sub unlock_machine($) {
   my $machine_f = shift @_;
   my $enc_machine_f = $machine_f;

   my @encrypt_code = ("A".."Z", "a".."z");
   $enc_machine_f .= $encrypt_code[rand @encrypt_code] for 1..8;

   while(1) {
      #===prevent I/O delay===
      if(-e "$machine_f") {
         system("mv $machine_f $enc_machine_f");

         open(FILE, "$enc_machine_f");
         my $machine_status = <FILE>;
         chomp($machine_status);
         close(FILE);

         my $new_status = $machine_status - 1;

         my $datestring = strftime "%a %b %e %H:%M:%S %Y", localtime;
         print "$datestring: $0\t$machine_f\t$machine_status to $new_status\n";

         open(OUT, ">$enc_machine_f");
         print OUT $new_status;
         close(OUT);

         system("mv $enc_machine_f $machine_f");

         last;
      }

      my $datestring = strftime "%a %b %e %H:%M:%S %Y", localtime;
      print "waiting for unlocking machine: $machine_f...\n";
      print "$0: $datestring\n";
      sleep(30);
   }

   return;
}

1;
