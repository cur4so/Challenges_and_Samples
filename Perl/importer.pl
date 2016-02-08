#!/usr/bin/perl -w

use strict;
use File::Copy qw(move);
use Scalar::Util qw(looks_like_number);

my $delimiter = ",";
my $header_identifier="header";
my $die =0;

my ($year,$month,$day);
my @records=();

open (file1,"<$ARGV[0]") or die "please provide a file to process";

my $glob_prefix = $ARGV[1];

while (<file1>) {
    my @record=();
###
# potentially the file may have data to be imported and some extra info
# the extra info needs to be filtered out 
###
    if (skip_header_if_exists($_)) {<file1>;}
    my @fields = split(/$delimiter/, $_ , -1) ;
###
# get the key
###
    $record[0] = shift @fields;
    if (! looks_like_number($record[0])) {die_or_skip("the 1st field should be a number, got $record[0]\n");}
    $record[1] = shift @fields;
    if (! is_a_date($record[1])) {die_or_skip("the 2d field should be a date!");}
    $record[1] =~ tr/0-9//cd;
    $record[2] = shift @fields;
    $record[2] =~ s/^\s+|\s+$//g;
    $record[2] =~ s/' '/\\' '/g;
    if ($record[2] eq '') {die_or_skip("the 3d field should be set!");}
    $record[3] = shift @fields;
    $record[4] = shift @fields;
    $record[4] =~ s/^\s+|\s+$//g;
    push(@records,\@record);
} 

close(file1);
my @sorted = sort_file_set(\@records);

my $last_year = '';
my $last_month = '';
my $last_day = '';
my $last_index = '';
for (my $i=0; $i < scalar @sorted; $i++){
    my $record = $sorted[$i];
    if (($year  = substr($record->[1],0,4)) ne $last_year) {
        create_dir_if_not_exists($glob_prefix."/".$year);
        $last_year = $year;
    }
    if (($month = substr($record->[1],4,2)) ne $last_month) {
        create_dir_if_not_exists($glob_prefix."/".$year."/".$month);
        $last_month = $month;
    }
    if (($day = substr($record->[1],6,2)) ne $last_day) {
        create_dir_if_not_exists($glob_prefix."/".$year."/".$month."/".$day);
        $last_day=$day;
    }
    if ($record->[0] ne $last_index){
        create_dir_if_not_exists($glob_prefix."/".$year."/".$month."/".$day."/".$record->[0]);
        $last_index = $record->[0];
    }

    my $j=$i+1;
    my @ff = ($record->[3],$record->[4]);
    my @fields=(\@ff);
    while ($j < scalar @sorted && $sorted[$j]->[0] == $record->[0] && $sorted[$j]->[1] == $record->[1] && $sorted[$j]->[2] eq $record->[2]){
        my @ff2 = ($sorted[$j]->[3],$sorted[$j]->[4]);
        push(@fields,\@ff2);
        $j++;
    }
###
# check whether there is already something for a given key 
###
    my $file_name_with_path = $glob_prefix."/".$year."/".$month."/".$day."/".$record->[0]."/".$record->[2];
    my $new=check_file_exists($file_name_with_path);
    if ($new) { new_file($file_name_with_path, \@fields);}
    else {add_replace($file_name_with_path, \@fields)}
    $i=$j-1;
}

print "Complete!\n";
# ==========================================
sub sort_file_set {
    my ($recs)=@_;
    my @sorted = sort {
        $a->[1] <=> $b->[1] || 
        $a->[0] <=> $b->[0] || 
        $a->[2] cmp $b->[2] || 
        $a->[3] <=> $b->[3] || 
        $a->[4] cmp $b->[4]  
    } @{$recs};

    return @sorted;
}
# ------------------------------------------

sub create_dir_if_not_exists {
    my ($dir) =@_;
    mkdir $dir unless ( -d $dir );
}
# ------------------------------------------
sub check_file_exists {
    my ($file_path) = @_;
    if ( -e $file_path ) { return 0;}
    else {return 1;}
}

# ------------------------------------------
sub new_file {
    my ($file_path,$fields) = @_;
    open (f1,">$file_path");
    foreach my $f (@{$fields}){
        print f1 join("|",@{$f});
    }
    close(f1); 
}

# ------------------------------------------
###
# here a wealth of optimization opportunities 
# already depending on selected data structure
# record existence check may be much faster
# rewriting the whole file may be not the best way either
###
sub add_replace{

    my ($file_path,$fields) = @_;
    my $tmp_file = $file_path.".xxx";
    my ($i,$line);
    open (f1,"<$file_path");
    open (f2,">$tmp_file");

    $line=<f1>;
    if ($line =~ /^(\d+)/){$i=$1;}
    else {die "error in the file";}
    while ( $i < $fields->[0]->[0] && !eof(f1)){
        print f2 $line;
        $line=<f1>;
        if ($line =~ /^(\d+)/){$i=$1;}
        else {die "error in the file";}
    }
    if ($i < $fields->[0]->[0]) { print f2 $line; }

    foreach my $f (@{$fields}){
        print f2 join("|",@{$f});
    }
    if ($i > $fields->[0]->[0]) { print f2 $line; }

    while (<f1>){ print f2 $_; }

    close(f1); 
    close(f2); 

    move $tmp_file, $file_path;
}

# ------------------------------------------
sub skip_header_if_exists{
    my ($header) = @_;
    if ($header =~ /$header_identifier/) {return 1;}
    else {return 0;}
}

# ------------------------------------------
sub is_a_date {
    my ($date) = @_;
    if (! $date =~ /^\d{4}-\d{1,2}-\d{1,2}$/) {return 0;}
    else {
        ($year,$month,$day) = split(/-/,$date);
        return 1;
    }
}

# ------------------------------------------
sub die_or_skip {
    my ($msg)=@_;
    if ($die) {die $msg;}
    else {<file1>;}
}
# ------------------------------------------

