#!/usr/bin/perl -w
#
# rank words by occurency 
# (words are defined as having >1 letter)
#
# input : a text file, k - the lowest rank to display
# output: top k ranked words
# 
use strict;
my ($content,$e);
my %ranking=();
my @words=();

if ($#ARGV < 1) {die "usage: perl get-most-frequent-words.pl text-file lowes-displayed-rank\n";} 

local $/ = undef;
open FILE, "< $ARGV[0]" or die "Can't open file: $!";
$content = <FILE>;
close FILE;
@words=split /\s+|,|\./, lc($content);
foreach $e (@words){
    if ( length($e) > 1 ){
      if (defined($ranking{$e})){
          $ranking{$e} += 1;
      }
      else {
          $ranking{$e}=1; 
      }
    }
}

my $i=0;
for my $e (sort {$ranking{$b} <=> $ranking{$a}} keys %ranking) {
    print "$e, $ranking{$e}\n";   
    $i++;
    if ($i == $ARGV[1]) {last;}
}
