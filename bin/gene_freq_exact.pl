#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Std;
my $PROGRAM = basename $0;
my $USAGE=
"Usage: $PROGRAM [bioconcepts2pubtatorcentral]
";

my %OPT;
getopts('', \%OPT);

STDOUT->autoflush;

my %HUMAN = ();
my %HASH = ();
!@ARGV && -t and die $USAGE;
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
                if ($taxid eq "9606") {
                    $HUMAN{$pmid} = 1;
                }            
            } else {
                # print STDERR "$taxid\n";
            }
        }
    }
    if ($type eq "Gene") {
        my $genes = $value;
        my @gene = split(";", $genes);
        for my $gene (@gene) {
            if ($gene =~ /^(\d+)$/) {
                $HASH{$gene}{$pmid} = 1;
            } elsif ($gene eq "None") {
                # Skip
            } else {
                print STDERR "$gene\n";
            }
        }
    }
}

my %COUNT = ();
for my $gene (keys %HASH) {
    my @pmid = keys %{$HASH{$gene}};
    my $count = 0;
    for my $pmid (@pmid) {
        if ($HUMAN{$pmid}) {
            $count++;
        }
    }
    if ($count) {
        $COUNT{$gene} = $count;
    }
}

for my $gene (sort { $COUNT{$b} <=> $COUNT{$a} } keys(%COUNT)) {
    print "$gene\t$COUNT{$gene}\n";
}
