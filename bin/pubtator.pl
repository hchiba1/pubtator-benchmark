#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: $PROGRAM
";

my %OPT;
getopts('', \%OPT);

STDOUT->autoflush;

print "\@prefix ex: <http://example.org/> .\n";
print "\@prefix pmid: <http://www.ncbi.nlm.nih.gov/pubmed/> .\n";
print "\n";

!@ARGV && -t and die $USAGE;
while (<>) {
    chomp;
    my @f = split(/\t/, $_);
    my $pmid = $f[0];
    my $type = $f[1];
    my $value = $f[2];
    $value =~ s/"/\\"/g;
    print "pmid:$pmid ex:has$type \"$value\" .\n";
}
