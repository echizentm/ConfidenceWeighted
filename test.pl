#!/usr/bin/perl
use strict;
use warnings;
use ConfidenceWeighted;

my ($confidence, $variance, $dimension) = @ARGV;

my $cw = ConfidenceWeighted->new();
die "cannot create.\n" unless ($cw);
die "cannot initialize.\n" unless ($cw->initialize(
    confidence => $confidence,
    variance   => $variance,
    dimension  => $dimension,
));

while (my $line = <STDIN>) {
    chomp($line);
    my ($label, $data_str) = split(/,/, $line);
    my @data               = split(/ /, $data_str);

    if ($label == 0) {
        $label = $cw->classify(
            data => \@data,
        );
        print "classify: $label,$data_str\n";
        next;
    }
    print "update: $label,$data_str\n";

    unless ($cw->update(
        data  => \@data,
        label => $label,
    )) {
        warn "cannot update.\n";
        next;
    }
}

