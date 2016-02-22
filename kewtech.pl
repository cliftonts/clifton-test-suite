#!/usr/bin/perl
use strict;
use warnings;
no warnings 'uninitialized';

use Device::SerialPort;
use Text::CSV;
#Kewtech series downloader
#USB and direct from file support

#For wishlist see primetest_cts.pl

#Subroutines go here
sub help {
   print "Clifton Test Suite v1.0 - 2015 \n";
   print "Kewtech series\n\n";
   print "Correct usage:\n";
   print "kewtech --i <port or filename> --o <output file[.csv]>\n";
   print "--h = Help screen\n";
   print "--i = Input port/filename (Default /dev/ttyUSB0)\n";
   print "--o = Output filename (Default output.csv)\n\n";
   print "Downloading via USB requires root access (type sudo at the start of command - sudo kewtech_cts --i etc...\n\n";
}

sub serialdownload {
   my $port=Device::SerialPort->new($input)
      || die "Can't open $input, try using sudo or --h option for help";

   my $STALL_DEFAULT=10; # how many seconds to wait for new input
 
   my $timeout=$STALL_DEFAULT;

   $port->read_char_time(0);     # don't wait for each character
   $port->read_const_time(1000); # 1 second per unfulfilled "read" call
 
   my $chars=0;
   my $buffer="";
   print "Start your download NOW\n";
   while ($timeout>0) {
      my ($count,$saw)=$port->read(255); # will read _up to_ 255 chars
      if ($count > 0) {
                #$buffer='';
            $chars+=$count;
            $buffer.=$saw;
            print $buffer;
                #push @DataStore, $buffer;
            do {
               $match = index ($buffer, "\x0d\x0a");
               push @DataStore, substr $buffer, 0, $match+2;
               substr($buffer,0,$match+2,"");
            } while ($buffer =~ "\x0d\x0a");
                 

                # Check here to see if what we want is in the $buffer
                # say "last" if we find it
       } else {
            $timeout--;
       }
   }

   if ($timeout==0) {
        #Now we have the raw data file, output it to disk
      $tmp = '>>' . $output . '.txt';
      open (RAWOUTPUT, $tmp);
      for( $a = 0; $a < scalar(@DataStore); $a++ ){
         print RAWOUTPUT $DataStore[$a];
      }
      close RAWOUTPUT;


        #die "Waited $STALL_DEFAULT seconds and never saw what I wanted\n";
   }
}

sub fileinput {
      my $csv = Text::CSV->new();
      open (CSV, "<", $input) or die $!;
      while (<CSV>) {
        if ($csv->parse($_)) {
            my @columns = $csv->fields();
            #Add each entry from input file to array
            if (length $columns[0] > 0) {
               push(@DataStore, $columns[0]);
            }
        } else {
            my $err = $csv->error_input;
            print "Failed to parse line: $err";
        }
      }
}

 my $output = 'output';
 

    my @DataStore;
    my @Dates;

    my $Date;
    my $time;
    my $app_no;
    my $description;
    my $visual;
    my @EarthCurr;
    my $earth;
    my $earth_pass;
    my $insulation;
    my $insulation_pass;
    my $load;
    my $load_pass;
    my $leakage;
    my $leakage_pass;
    my $location;
    my $cont;
    my $site;
    my $comment1;
    my $comment2;
    my $comment3;
    my $tmp=''; #Used for substr statements
    my $match='';
    my $final=''; #Used for storing the completed CSV line before writing to file
    my $input="/dev/ttyUSB0"; #Used to get chosen input port or file from user;
    my $NumArgs=''; #For storing command line arguments

    #Take additional settings from command line
    $NumArgs = $#ARGV + 1;
    if ($NumArgs > 0) {
          $input = $ARGV[0];
          $output = $ARGV[1];
      
    }
    my $find = ' ';
    my $replace = "\ ";
    $input =~ s/\Q$find\E/$replace/g;
    $output =~ s/\Q$find\E/$replace/g;

    #Now we have any custom input, open the file for writing
    $tmp = '>>' . $output . '.csv';
    open (OUTPUT, $tmp);

    #Check input file/port setting and run appropriate code
    $tmp = substr $input,0,5;

    if ($tmp eq "/dev/") {
       &serialdownload;
    }

   $tmp = substr $input,0,5;
   if ($tmp ne '/dev/') {
      &fileinput;
   }
  

#Set variables etc
    

    #Determine how many entries are in the array
    #Loop through each entry of the array and prepare them for writing
    #to the output file
#do {
    
    #print $Arry[0][1];
    #Check results file is a valid format
    $tmp = substr $DataStore[0], 0, 11;
    if ($tmp ne 'TEST NUMBER') {
       &help;
       die ('This is not a valid Kewtech ASCII file');
    }

    my $Count = 1; #Current position in the data file
    for( $a = 0; $a < scalar(@DataStore); $a++ ){
       $tmp = substr $DataStore[$a],0,4;
       #print $tmp . "\n";
       if ($tmp eq 'DATE') {
          $Date = substr $DataStore[$a],7,11
          #print substr $DataStore[$a],7,11 . "\n";
       }
       $tmp = substr $DataStore[$a],0,6;
       if ($tmp eq 'APP NO') {
          #$Date[$Count] = substr $DataStore[$a],7,11;
          substr($DataStore[$a],0,7,"");
          $app_no = $DataStore[$a];
          $app_no =~ s/^\s+//;
          $app_no =~ s/\s+$//;
          
       }
       $tmp = substr $DataStore[$a],0,11;
       if ($tmp eq 'DESCRIPTION') {
          substr($DataStore[$a],0,11,"");
          $description = $DataStore[$a];
          $description =~ s/^\s+//;
          $description =~ s/\s+$//;
       }
       $tmp = substr $DataStore[$a],0,4;
       if ($tmp eq 'LOCN') {
          substr($DataStore[$a],0,4,"");
          $location = $DataStore[$a];
          $location =~ s/^\s+//;
          $location =~ s/\s+$//;
       }
       $tmp = substr $DataStore[$a],0,12;
       if ($tmp eq 'VISUAL CHECK') {
          $visual=substr $DataStore[$a],17,1;
          if ($visual eq "P") {
             $visual = "Pass";
          }
          if ($visual eq "S") {
             $visual = "Skip";
          }
          if ($visual eq "F") {
             $visual = "Fail";
          }
       }
       $tmp = substr $DataStore[$a],0,7;
       if ($tmp eq 'EARTH  ') {
          $earth = substr $DataStore[$a],7,5;
          #splice(@Earth, $Count, 1, $tmp);
          $earth_pass=substr $DataStore[$a],17,1;
          if ($earth_pass eq "P") {
             $earth_pass = "Pass";
          }
          if ($earth_pass eq "S") {
             $earth_pass = "Skip";
          }
          if ($earth_pass eq "F") {
             $earth_pass = "Fail";
          } 
       }         
       $tmp = substr $DataStore[$a],0,3;
       if ($tmp eq 'INS') {
          $insulation = substr $DataStore[$a],7,5;
          #splice(@Earth, $Count, 1, $tmp);
          $insulation_pass=substr $DataStore[$a],17,1;
          if ($insulation_pass eq "P") {
             $insulation_pass = "Pass";
          }
          if ($insulation_pass eq "S") {
             $insulation_pass = "Skip";
          }
          if ($insulation_pass eq "F") {
             $insulation_pass = "Fail";
          }                    
          
       }
       $tmp = substr $DataStore[$a],0,4;
       if ($tmp eq 'LOAD') {
          $load = substr $DataStore[$a],7,5;
          #splice(@Earth, $Count, 1, $tmp);
          $load_pass=substr $DataStore[$a],17,1;
          if ($load_pass eq "P") {
             $load_pass = "Pass";
          }
          if ($load_pass eq "S") {
             $load_pass = "Skip";
          }
          if ($load_pass eq "F") {
             $load_pass = "Fail";
          }                    
          
       }
       $tmp = substr $DataStore[$a],0,4;
       if ($tmp eq 'LKGE') {
          $leakage = substr $DataStore[$a],7,5;
          #splice(@Earth, $Count, 1, $tmp);
          $leakage_pass=substr $DataStore[$a],17,1;
          if ($leakage_pass eq "P") {
             $leakage_pass = "Pass";
          }
          if ($leakage_pass eq "S") {
             $leakage_pass = "Skip";
          }
          if ($leakage_pass eq "F") {
             $leakage_pass = "Fail";
          }                    
          
       }
       $tmp = substr $DataStore[$a],0,15;
       if ($tmp eq 'LEAD CONTINUITY') {
          $cont = substr $DataStore[$a],17,1;
          if ($cont eq "P") {
             $cont = 'Pass';
          }
          if ($cont eq "S") {
             $cont = 'Skip';
          }
          if ($cont eq "F") {
             $cont = 'Fail';
          }
       }
       $tmp = substr $DataStore[$a],0,4;
       if ($tmp eq 'SITE') {
          #$Date[$Count] = substr $DataStore[$a],7,11;
          substr($DataStore[$a],0,5,"");
          $site = $DataStore[$a];
          $site =~ s/^\s+//;
          $site =~ s/\s+$//;
          
       }
       $tmp = substr $DataStore[$a],0,4;
       if ($tmp eq 'TEXT') {
             if ($comment1 eq '') {
   
                substr($DataStore[$a],0,5,"");
                $comment1 = $DataStore[$a];
                $comment1 =~ s/^\s+//;
                $comment1 =~ s/\s+$//;
             } elsif ($comment2 eq '') {
         
                substr($DataStore[$a],0,5,"");
                $comment2 = $DataStore[$a];
                $comment2 =~ s/^\s+//;
                $comment2 =~ s/\s+$//;
             } elsif ($comment3 eq '') {
         
                substr($DataStore[$a],0,5,"");
                $comment3 = $DataStore[$a];
                $comment3 =~ s/^\s+//;
                $comment3 =~ s/\s+$//;
             }
       }
       $tmp=substr($DataStore[$a],0,11);
       if ($tmp eq 'TEST NUMBER' or $tmp eq 'END OF DATA') {
          #Capitalise first letters of string
          $location =~ s/([\w']+)/\u\L$1/g;
          $site =~ s/([\w']+)/\u\L$1/g;
          $description =~ s/([\w']+)/\u\L$1/g;
          $comment1 =~ s/([\w']+)/\u\L$1/g;
          $comment2 =~ s/([\w']+)/\u\L$1/g; 
          $comment3 =~ s/([\w']+)/\u\L$1/g;
          
          #print $final . "\n";
          if ($app_no ne '') {
             $final = $app_no . "," . $Date . "," . $location . "," . $description . "," . $visual . "," . $earth . "," . $earth_pass . "," . $insulation . "," . $insulation_pass . "," . $load . "," . $load_pass . "," . $leakage . "," . $leakage_pass . "," . $cont . "," . $site . "," . $comment1 . "," . $comment2 . "," . $comment3;
             print OUTPUT $final . "\x0d\x0a";
          } else {
             print OUTPUT "ID,Date,Location,Description,Visual,Earth,Earth Pass,Insulation,Insulation Pass,Load,Load Pass,Leakage,Leakage Pass,Load,Load Pass,Continuity,Site,Comment 1,Comment 2,Comment 3\x0d\x0a";
          }
          $Count++;
          $Date = '';
          $time = '';
          $app_no = '';
          $visual = '';
          $earth = '';
          $earth_pass = '';
          $insulation = '';
          $insulation_pass = '';
          $load = '';
          $load_pass = '';
          $leakage = '';
          $leakage_pass = '';
          $cont = '';
          $site = '';
          $description = '';
          $comment1 = '';
          $comment2 = '';
          $comment3 = '';
       }
       
    }
    print "Clifton Test Suite v1.0 - 2015 \n";
    print "Kewtech series\n";
    print "You data has been saved to: " . $output . "\n";
    $tmp = substr $input,0,5;
    if ($tmp eq "/dev/") {
       print "You raw input has been saved to: " . $output . ".txt\n\n";
    }
    print 'Bug reports/feature requests to sales@cliftonts.co.uk' . "\n";
    close OUTPUT;
