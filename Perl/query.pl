#!/usr/bin/perl -w

use strict;
use Getopt::Long qw(GetOptions);
use Switch;

my ($select,$order,$filter);
my $repo_path='repo';
my $year_start=2014;
my $year_end=2015;

my %out=();
my @output=();
# 1 - order # 2 - filter # 4 -select # 5 select+order # 6 select+filter # 7 select+order+filter
my %fields = (
    'field1' => 0, 
    'field2' => 0,
    'field3' => 0,
    'field4' => 0,
    'field5' => 0,
);
GetOptions (
    "select=s" => \$select,
    "order:s"  => \$order, 
    "filter:s" => \$filter)
    or die("to run a query select argument is necessary\n");

#print "got:$select|$order|$filter\n";

my @select_fields = ($select =~ /,/ ) ? split /,/, $select : ($select);

foreach my $e (@select_fields){
    if (! defined($fields{$e})) {die "unknown field for select";}
    $fields{$e} = 4;
}
my @order_fields =();
if (defined($order)) {
    @order_fields = ($order =~ /,/) ? split /,/, $order : ($order);

    foreach my $e (@order_fields){
        if (! defined($fields{$e})) {die "unknown field for order";}
        $fields{$e} += 1;
    }
}

my @filter_fields =();
my %date_h=();

if (defined($filter)) {
    my @conjunctions = (' and ',' or ');
    my $conj_as_line = join('|',@conjunctions);
    my @elementary_operations = ('>=','<=','=','<','>');
    my $elementary_line = join('|',@elementary_operations); 
    @filter_fields = ($filter =~ /$conj_as_line/) ? split /$conj_as_line/, $filter : ($filter);

    foreach my $e (@filter_fields){

        my ($k,$v) = split /$elementary_line/, $e;
        $k =~ s/^\s+|\s+$//g;
        $v =~ s/^\s+|\s+$//g;
        if (! defined($fields{$k})) {die "unknown field for filtering";}
        $fields{$k} += 2;
        if ($k eq 'field2'){
            if (! $v =~ /^\d{4}-\d{1,2}-\d{1,2}$/) {die "wrong date format";}
            else {
                 my ($year,$month,$day) = split(/-/,$v);
                 $e =~ s/$k|$v//g;
                 my $del = $e;
                 $del =~ s/^\s+|\s+$//g;

                 switch ($del){
                     case "$elementary_operations[2]" {apply_eq($year,$month,$day);}
                     case "$elementary_operations[0]" {apply_ge($year,$month,$day);}
                     case "$elementary_operations[1]" {apply_le($year,$month,$day);}
                     case "$elementary_operations[3]" {apply_lt($year,$month,$day);}
                     case "$elementary_operations[4]" {apply_gt($year,$month,$day);}
                     else { die "not implemented as for now"; }
                 }
             }
        }
        else {print "not implemented as for now";}
    }
}

if ($fields{field2} == 2 || $fields{field2} > 5 ){
    for my $k (keys %date_h) { 
        my $path = $repo_path.'/'.$k;
        get_records($path,$k); 
    }
}
else { get_records($repo_path,0); }

use Data::Dumper;
if (scalar @order_fields > 0){
###
# sorting just by 1 field and it should be numerical
# do not fit into memory screwed 
###
    my $i;
    if ($order_fields[0] =~ /1/){$i=0;}
    elsif ($order_fields[0] =~ /2/){$i=1;}
    elsif ($order_fields[0] =~ /3/){$i=2;}
    elsif ($order_fields[0] =~ /4/){$i=3;}
    else {$i=4;}

    my @ordered_output = sort { $a->[$i] <=> $b->[$i] } @output;

    print Dumper(@ordered_output);
}
else {print Dumper(@output);}

print "Complete!\n";
# ===============================================================
sub apply_eq {
    my ($year,$month,$day)=@_;
    $date_h{$year.'/'.$month.'/'.$day} = 1;
}
# ---------------------------------------------------------------
sub apply_le { 
    my ($year,$month,$day)=@_;
    my $ymd=$year.$month.$day;
    for my $y ($year_start..$year){
        for my $m (1..12){
            for my $d (1..31){
                my $cymd=$y.$m.$d;
                if ($cymd <= $ymd and -d $repo_path."/".$y."/".$m."/".$d ){ $date_h{$y.'/'.$m.'/'.$d} = 1; }
            }
        }
    }
}
# ---------------------------------------------------------------
sub apply_ge { 

    my ($year,$month,$day)=@_;
    my $ymd=$year.$month.$day;
    for my $y ($year..$year_end){
        for my $m (1..12){
            for my $d (1..31){
                my $cymd=$y.$m.$d;
                if ($cymd >= $ymd and -d $repo_path."/".$y."/".$m."/".$d ){ $date_h{$y.'/'.$m.'/'.$d} = 1; }
            }
        }
    }
}
# ---------------------------------------------------------------
sub apply_gt { 

    my ($year,$month,$day)=@_;

    my $ymd=$year.$month.$day;
    for my $y ($year..$year_end){
        for my $m (1..12){
            for my $d (1..31){
                my $cymd=$y.$m.$d;
                if ($cymd >= $ymd and -d $repo_path."/".$y."/".$m."/".$d ){ $date_h{$y.'/'.$m.'/'.$d} = 1; }
            }
        }
    }
}
# ---------------------------------------------------------------
sub apply_lt { 

    my ($year,$month,$day)=@_;

    my $ymd=$year.$month.$day;
    for my $y ($year_start..$year){
        for my $m (1..12){
            for my $d (1..31){
                my $cymd=$y.$m.$d;
                if ($cymd < $ymd and -d $repo_path."/".$y."/".$m."/".$d ){ $date_h{$y.'/'.$m.'/'.$d} = 1; }
            }
        }
    }
}
# ---------------------------------------------------------------

sub recursion_go_in {
    my ($path,$f,$v,$date)=@_;
    if ($f =~ /^\./) {return;}
    elsif ($f =~ /^(\d+)$/ && -d $path."/".$f ) {
        my $val=$v.$1.'-'; 
        my $new_path = $path.'/'.$f; 
        opendir my $dir, $new_path or die "Cannot open directory: $!";
        my @dirs = readdir $dir;
        foreach my $f2 (@dirs){
            recursion_go_in($new_path,$f2,$val,$date);       
        }  
        closedir $dir; 
    }
    else {
        open(f1,"<".$path."/".$f);
        while (<f1>){
            my @ar=();
            my @el=split /|/, $_;
            if ($fields{'field1'} > 3){ 
                push(@ar,$el[0]);
            } 
            else {push(@ar,"");}
            if ($fields{'field2'} > 3){
                if ($fields{'field2'} > 5){
                    if ($date eq '0') {
                        $path =~ s/^$repo_path\///;
                        my @sp = split('/',$path);
                        $date = $sp[0].'-'.$sp[1].'-'.$sp[2];
                    }
                    else { $date =~ s/\//-/g; }
                    push(@ar,$date);
                }
                else {
                    $v =~ s/-$//;
                    push(@ar,$v);
                }
            }
            else {push(@ar,"");}
            if ($fields{'field3'} > 3){ push(@ar,$f); }
            else {push(@ar,"");}
            if ($fields{'field4'} > 3){ push(@ar,$el[1]); }
            else {push(@ar,"");}
            if ($fields{'field5'} > 3){ push(@ar,$el[2]); }
            else {push(@ar,"");}
            push(@output,\@ar);
        }
    }
}
# ---------------------------------------------------------------
sub get_records {
    my ($path,$date) =@_;
    opendir my $dir, $path or die "Cannot open directory: $!";
    my @files = readdir $dir;
    foreach my $f (@files){
        recursion_go_in($path,$f,'',$date);
    }
    closedir $dir; 
}

