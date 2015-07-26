#!/usr/bin/perl

use 5.10.0;
use strict;
use warnings;

my $score_file = "newscore.sc";
my $inputa;
my $l1;
my $l2;
my $linea;
my @dota;
my @parta;
my $output;
my @filea;

open $inputa,'<',$score_file or die "can't open file: $!";
$l1 = readline($inputa);
$l2 = readline($inputa);
# skips the first 2 lines in score file
while ($linea = <$inputa>){
	@dota = split (" ",$linea);
        @parta = split ("_",$dota[18]);
        if ($parta[-1] == 1){
            $parta[-1] = $parta[-2];
            $parta[-2] = "com";
        } elsif ($parta[-1] == 2){
            $parta[-1] = $parta[-2];
            $parta[-2] = "sep";
        } else {
        exit 0
        }
        $dota[18] = join("_",@parta);
        $linea = join(" ",@dota);
        push (@filea,$linea);
}
open $output, '>', $score_file or die "can't open file: $!";
print $output "$l1";
print $output "$l2";
foreach (@filea) {
    print $output "$_\n";
}
