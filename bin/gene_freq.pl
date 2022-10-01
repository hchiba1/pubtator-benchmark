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
        if ($taxids eq "9606") {
            $HUMAN{$pmid} = 1;
        }            
    }
    if ($type eq "Gene") {
        my $genes = $value;
        $HASH{$genes}{$pmid} = 1;
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
