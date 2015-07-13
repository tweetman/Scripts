#!/usr/bin/perl

use 5.10.0;
use strict;
use warnings;

my $score_file = "newscore.sc";
my $inputa;
my $inputb;
my $linea;
my @dota;
my $a=0;
my @mutants;
my $l1;
my $l2;
my $b=0;
my $output;
my $outputa;

#A way to optimize this script is to save all the lines of the newscore.sc file in an array and don't read the score file multiple times.

open $inputa,'<',$score_file or die "can't open file: $!";
$l1 = readline($inputa);
$l2 = readline($inputa);
# skips the first 2 lines in score file
while ($linea = <$inputa>){
	@dota = split (" ",$linea);
        $a = (substr $dota[18], 0, -5);
        if ("$a" ~~ @mutants) {
            } else {
            push @mutants, $a;
            }
}
until ($b > $#mutants) {
       open $outputa, '>', $mutants[$b] or die "can't open file: $!";
       print $outputa "$l1$l2";
       close $outputa;
       $b=$b+1;
}
$b=0;
seek $inputa, 0, 0;
readline($inputa);
readline($inputa);

until ($b > $#mutants) {
      open $output, '>>', $mutants[$b] or die "can't open file: $!";
      while ($linea = <$inputa>){
            @dota = split (" ",$linea);
            $a = (substr $dota[18], 0, -5);
#            print "<$a>\n";
            if ($a eq $mutants[$b]) {
                  print $output "$linea";
            }
      }
      close $output;
      $b=$b+1;
      seek $inputa, 0, 0;
      readline($inputa);
      readline($inputa);
}
        
#print join(", ", @mutants);
