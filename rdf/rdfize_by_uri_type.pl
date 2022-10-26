#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: cat TABLE | $PROGRAM TYPE
";

my %OPT;
getopts('', \%OPT);

STDOUT->autoflush;

-t and die $USAGE;
if (!@ARGV) {
    print STDERR $USAGE;
    exit 1;
}
my ($TYPE) = @ARGV;

print "\@prefix ex: <http://example.org/> .\n";
print "\@prefix pmid: <http://identifiers.org/pubmed/> .\n";
print "\@prefix taxid: <http://identifiers.org/taxonomy/> .\n";
print "\@prefix ncbigene: <http://identifiers.org/ncbigene/> .\n";
print "\n";
while (<STDIN>) {
    chomp;
    my @f = split(/\t/, $_);
    my $pmid = $f[0];
    my $type = $f[1];
    my $value = $f[2];
    if ($type ne $TYPE) {
        next;
    }
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
                # print STDERR "$gene\n";
            }
        }
    } else {
        $value =~ s/"/\\"/g;
        print "pmid:$pmid ex:has$type \"$value\" .\n";
    }
}
