#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use ConfidenceWeighted;
use SoftConfidenceWeighted;

my ($confidence, $param, $dimension, $mode) = @ARGV;

my $cw;;

if ($mode eq 'cw') {
    $cw = ConfidenceWeighted->new();
    die "cannot create.\n" unless ($cw);
    die "cannot initialize.\n" unless ($cw->initialize(
        confidence => $confidence,
        variance   => $param,
        dimension  => $dimension,
    ));
} elsif ($mode eq 'scw') {
    $cw = SoftConfidenceWeighted->new();
    die "cannot create.\n" unless ($cw);
    die "cannot initialize.\n" unless ($cw->initialize(
        confidence     => $confidence,
        aggressiveness => $param,
        dimension      => $dimension,
    ));
} else {
    die "mode must be 'cw' or 'scw'.\n";
}

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
print Dumper($cw->{mu});

