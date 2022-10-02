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
print "\@prefix taxid: <http://www.ncbi.nlm.nih.gov/taxonomy/> .\n";
print "\@prefix ncbigene: <http://www.ncbi.nlm.nih.gov/ncbigene/> .\n";
print "\n";

!@ARGV && -t and die $USAGE;
STDOUT->autoflush;
while (<>) {
    chomp;
    my @f = split(/\t/, $_);
    my $pmid = $f[0];
    my $type = $f[1];
    my $value = $f[2];
    if ($type eq "Species") {
        my $taxids = $value;
        my @taxid = split(";", $taxids);
        for my $taxid (@taxid) {
            if ($taxid =~ /^\d+$/) {
                print "pmid:$pmid ex:has$type taxid:$taxid .\n";
            } else {
                # print STDERR "$taxid\n";
            }
        }
    } elsif ($type eq "Gene") {
        my $genes = $value;
        my @gene = split(";", $genes);
        for my $gene (@gene) {
            if ($gene =~ /^\d+$/) {
                print "pmid:$pmid ex:has$type ncbigene:$gene .\n";
            } else {
                print STDERR "$gene\n";
            }
        }
    } else {
        $value =~ s/"/\\"/g;
        print "pmid:$pmid ex:has$type \"$value\" .\n";
    }
}
