#!/usr/bin/perl

use warnings;
use strict;
use AnyEvent::I3 qw(:all);

unless ( @ARGV == 1 ) {
    die usage();
}

my $arg = $ARGV[0];
if ( 
    ( $arg ne "new" ) and 
    ( $arg ne "prev" ) and
    ( $arg ne "next" ) ) {
    die usage();
}

my $i3 = i3();
my $workspaces = $i3->get_workspaces->recv;

my $prev;
my $next;
my $last;
my $focused;
my $empty;
my $wcount = 0;
foreach my $wsp ( @$workspaces ) {
    $wcount++;
    unless ( defined($empty) ) {
        if ( $$wsp{"num"} > $wcount ) {
            $empty = $wcount;
        }
    }
    if ( ( defined($focused) ) and ( ! defined($next) ) ) {
        $next = $$wsp{"num"};
    }
    if ( $$wsp{"focused"} ) {
        $prev = $last;
        $focused = $$wsp{"num"};
    }
    $last = $$wsp{"num"};
}
$prev = $focused unless ( defined($prev) );
$next = $focused unless ( defined($next) );
$empty = ( @$workspaces + 1 ) unless ( defined($empty) );

$i3->command("workspace $prev")->recv if ( $arg eq "prev" );
$i3->command("workspace $next")->recv if ( $arg eq "next" );
$i3->command("workspace $empty")->recv if ( $arg eq "new" );

exit;

#########
# subs
#########
sub usage {
    return "Usage: $0 <prev|next>\n";
}
