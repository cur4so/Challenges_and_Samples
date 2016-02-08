#!/usr/bin/perl
#
# a script for 1 to 3 (and 3 to 1) letters conversion of amino acids     
#
my %a_aaa =(
    'A' => 'ALA',
    'R' => 'ARG',
    'N' => 'ASN',
    'D' => 'ASP',
    'C' => 'CYS',
    'Q' => 'GLN',
    'E' => 'GLU',
    'G' => 'GLY',
    'H' => 'HIS',
    'I' => 'ILE',
    'L' => 'LEU',
    'K' => 'LYS',
    'M' => 'MET',
    'F' => 'PHE',
    'P' => 'PRO',
    'S' => 'SER',
    'T' => 'THR',
    'W' => 'TRP', 
    'Y' => 'TYR',
    'V' => 'VAL',
);
 
my $aa=$ARGV[0];
unless ($aa){
    print "Enter 1 or 3 letters amino acid code:";
    $aa=<STDIN>;
    chomp $aa; 
}
if (length($aa) != 3 and length($aa) != 1){die "There should be 1 or 3 letters\n";}
$aa = uc($aa);
if (length($aa) == 1) {
    if (defined($a_aaa{$aa})) {print "$a_aaa{$aa}\n"; }
    else {print "there is no letter $aa in amino acid alphabet\n";}
}
else {
    my %aaa_a = reverse %a_aaa;
    if (defined($aaa_a{$aa})) {print "$aaa_a{$aa}\n"; }
    else {print "there is no letter $aa in amino acid alphabet\n";}
}


