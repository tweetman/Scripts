#!/usr/bin/perl

use 5.10.0;
use strict;
use warnings;
use List::Util qw(sum);
use POSIX;
use List::Util 'first';
no warnings 'experimental::smartmatch';

my $score_file = "newscore.sc";
my $inputa;
my $linea;
my @dota;
my $aa=0;
my @mutants;
my $z1;
my $z2;
my $bb;
my $inputb;
my $outputa;
my @scores;
my $fs;
my $average_num = $ARGV[0];
my @average_elem;
my $c;
my $fa;
my $d;
my @sorted_mutants;
my $ab;
my @ac;
my @resid;
my $cd;
my $cc;
my $ce;
my $fb;
my $fc;
my $firsta;
my @firstb;
my $i;
my $pdbwt_file;
my @pdbfile;
my @pdbfile2;
my @dotb;
my $inputc;
my @sorted_mutants2;
my @reswt;
my $ddges;
my $dcom;
my $dsep;
my %aa31 = (ALA=>'A',TYR=>'Y',MET=>'M',LEU=>'L',CYS=>'C',GLY=>'G',
         ARG=>'R',ASN=>'N',ASP=>'D',GLN=>'Q',GLU=>'E',HIS=>'H',TRP=>'W',
         LYS=>'K',PHE=>'F',PRO=>'P',SER=>'S',THR=>'T',ILE=>'I',VAL=>'V');
my %aa13 = reverse %aa31;
my @wt_com;
my @wt_sep;
my @ba;

sub mean {
    return sum(@_)/@_;
}
sub trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

if ($average_num == 1) {
    say "The lowest energy structure are used for calculation of the summary.";
} else {
    say "The $average_num structures with the lowest energies are averaged and used for calculation of the summary.";
}

#Creates a list of all clones (all mutated residues, complex + seperated chains) 
open $inputa,'<',$score_file or die "can't open file: $!";
$z1 = readline($inputa);
$z2 = readline($inputa);
while ($linea = <$inputa>){
        @dota = split (" ",$linea);
        $aa = (substr $dota[18], 0, -5);
        if ("$aa" ~~ @mutants) {
        } else {
            push @mutants, $aa;
        }
}
close $inputa;

#Sort the clones alphanumerical
@sorted_mutants = grep {s/(^|\D)0+(\d)/$1$2/g,1} sort
     grep {s/(\d+)/sprintf"%06.6d",$1/ge,1} @mutants;
$fa = $#sorted_mutants;


#Creates an array with all the mutated residues (format: "B30")
$bb = 0;
while ($bb <= $fa) {
    @dota = split('_',$sorted_mutants[$bb]);
    if ("$dota[-3]" ~~ @resid) {
    } else {
         push @resid, $dota[-3];
    }
    $bb = $bb+ 1;
}
$fb = $#resid;
#Creates an array with all the wildtype residues
@dota = split('_',$sorted_mutants[0]); 
@ac = splice @dota, -3, 3;
$pdbwt_file = join('_',@dota).".pdb";
open $inputc,'<',join('_',$pdbwt_file) or die "can't open file: $!";
@pdbfile = <$inputc>;
close $inputc;
$cd = 0;
$bb = 0;
while ($cd <= $#pdbfile) {
      $cc = substr $pdbfile[$cd], 0, 4;
      if ($cc eq 'ATOM') {
         $dotb[0] = trim(substr $pdbfile[$cd], 17, 3);
         $dotb[1] = trim(substr $pdbfile[$cd], 21, 1);
         $dotb[2] = trim(substr $pdbfile[$cd], 22, 4);
         $pdbfile2[$bb] = join(" ",@dotb);
         $bb = $bb + 1; 
      }
      $cd = $cd + 1;
}

$cd = 0;
while ($cd <= $fb) {
      $fc = (substr $resid[$cd], 0, 1)." ".(substr $resid[$cd], 1);
      $firsta = first { /$fc/ } @pdbfile2;
      @firstb = split (" ",$firsta);
      push @reswt, $firstb[0];
      $cd = $cd + 1;
}
foreach $i (@reswt) {
      $cc = $aa31{$i};
      $i = $cc;
      #print "<$i>\n";
}
$cc = 0;
$cd = 0;
#print join (',',@reswt);
#print "\n";
while ($cd <= $fa) {
      @dota = split('_',$sorted_mutants[$cd]);
      if ($dota[-2] =~ /wt$/) {
          $dota[-2] = "mut".$reswt[$cc];
          $sorted_mutants[$cd] = join('_',@dota);
          $cd = $cd + 1;
          @dota = split('_',$sorted_mutants[$cd]);
          $dota[-2] = "mut".$reswt[$cc];
          $sorted_mutants[$cd] = join('_',@dota);
          $cc = $cc + 1;
      }
      $cd = $cd + 1;
}

#Sort the clones alphanumerical
@sorted_mutants2 = grep {s/(^|\D)0+(\d)/$1$2/g,1} sort
     grep {s/(\d+)/sprintf"%06.6d",$1/ge,1} @sorted_mutants;

#Creates an array with total scores of each clone in the same order as @sorted_mutants
$bb = 0;
@ac = ();
@ba = ();
$cc = 0;
while ($bb <= $fa) {
    #print "<$sorted_mutants2[$bb]>"."\n";
    if (-e $sorted_mutants2[$bb]) {
       open $inputb,'<',$sorted_mutants2[$bb];
    } else {
       @ba = split ("_",$sorted_mutants2[$bb]);
       $ba[-2] = "wt";
       $cc = join ("_",@ba);
       open $inputb,'<',$cc or die "can't open file: $!";
    }
    @scores = <$inputb>;
    close $inputb;
    $fs = $#scores;
    $c = 0;
    while ($c lt $average_num) {
          $d = $fs-$c;
          @dota = split (" ",$scores[$d]);
          push @ac, $dota[1];
          $c = $c + 1;
    }
    
    push @average_elem, sprintf("%.3f", mean(@ac));
    @ac = ();
    $bb = $bb + 1;
}

#Sort all the total scores of wildtypes into 2 specific arrays
$bb = 0;
$cd = 0;
$cc = 0;
$ce = 0;
while ($bb <= $fa) {    
    @dota = split('_',$sorted_mutants2[$bb]);
    $cd = 0;
    while ($cd <= $fb) {
        $cc = $resid[$cd];
        $ce = "mut".$reswt[$cd];
        #print "<$ce>\n";
        if ($dota[-3] =~ /$cc/ && $dota[-2] =~ /$ce/) {
            #print "yes 1+2\n";
            push @wt_com, $average_elem[$bb];
            $bb = $bb + 1;
            push @wt_sep, $average_elem[$bb];
        }
        $cd = $cd + 1;
    }
$bb = $bb + 1;
}
#print join (',',@wt_sep);
#print "\n";

open $outputa,'>',"results.csv" or die "can't open file: $!";
#print "RESULTS\n";
print $outputa "aa,ddG,dGsep,dGcom\n";
$bb = 0;
$cd = 0;
$cc = 0;
$ce = 0;
@ba = ();
while ($ce <= $fb) {
    while ($bb <= $fa) {
        @dota = split('_',$sorted_mutants2[$bb]);
        $cd = 0;
        while ($cd <= $fb) {
            $cc = $resid[$cd];
            if ($dota[-3] =~ /$cc/) {
                if ($resid[$cd] ~~ @ba) {
                }  else {
                    print $outputa "$resid[$cd]\n";
                    push @ba, $resid[$cd];
                }
                $dcom = $average_elem[$bb] - $wt_com[$cd];
                $bb = $bb + 1;
                $dsep = $average_elem[$bb] - $wt_sep[$cd];
                $ddges = $dcom - $dsep;
                print $outputa substr($dota[-2],3,1).",";
                print $outputa sprintf("%.3f", $ddges).",".sprintf("%.3f",$dsep).",".sprintf("%.3f",$dcom)."\n";
            }
            $cd = $cd + 1;
        }
        $bb = $bb + 1;
    }
    $ce = $ce + 1;
}
close $outputa;
#say "END";
say "The summarized results are saved in results.csv!";
#if ($sorted_mutants[$bb] =~ /com$/) {
    #add this element to the hash "com". 
#} elsif ($sorted_mutants[$bb] =~ /sep$/){
    #add this element to the hash "sep".
#}
#$bb = $bb + 2;

#( $bb ) = $sorted_mutants[0] =~ /([^_])$/;
#print join(', ',@sorted_mutants);
#print $fb;
#print "\n";
#$bb = 0;
#while ($bb <= $fa) {
#    print $sorted_mutants2[$bb].", ".$average_elem[$bb]."\n";
#    $bb = $bb + 1;
#}

#print join(', ',@wt_com);
