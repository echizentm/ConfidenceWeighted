#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok('ConfidenceWeighted') };

test_01();
test_02();
test_03();

sub test_01 {
    note('check initialize()');

    my $cw = ConfidenceWeighted->new();
    ok($cw, 'new()');

    is($cw->initialize(), undef, 'initialize() with no params');

    is($cw->initialize(
        confidence => -1,
        variance   =>  1,
        dimension  =>  1,
    ), undef, 'initialize() with confidence < 0');
    ok($cw->initialize(
        confidence => 0,
        variance   => 1,
        dimension  => 1,
    ), 'initialize() with confidence == 0');
    ok($cw->initialize(
        confidence => 1,
        variance   => 1,
        dimension  => 1,
    ), 'initialize() with confidence == 1');
    is($cw->initialize(
        confidence => 2,
        variance   => 1,
        dimension  => 1,
    ), undef, 'initialize() with confidence > 1');

    is($cw->initialize(
        confidence => 0.7,
        variance   => 0,
        dimension  => 1,
    ), undef, 'initialize() with variance <= 0');
    ok($cw->initialize(
        confidence => 0.7,
        variance   => 1,
        dimension  => 1,
    ), 'initialize() with variance > 0');

    is($cw->initialize(
        confidence => 0.7,
        variance   => 1,
        dimension  => 0,
    ), undef, 'initialize() with dimension <= 0');
    ok($cw->initialize(
        confidence => 0.7,
        variance   => 1,
        dimension  => 1,
    ), 'initialize() with dimension > 0');
}

sub test_02 {
    note('check update()');

    my $cw = ConfidenceWeighted->new();
    $cw->initialize(
        confidence => 0.7,
        variance   => 1,
        dimension  => 1,
    );

    is($cw->update(), undef, 'update() with no params');

    is($cw->update(
        data  => [1, 1],
        label => 1,
    ), undef, 'update() with @$data != dimension');
    is($cw->update(
        data  => [1],
        label => 0,
    ), undef, 'update() with label is not in {1, -1}');

    ok($cw->update(
        data  => [1],
        label => 1,
    ), 'update() with positive data');

    ok($cw->update(
        data  => [1],
        label => -1,
    ), 'update() with negative data');
}

sub test_03 {
    note('check classify()');

    my $cw = ConfidenceWeighted->new();
    $cw->initialize(
        confidence => 0.7,
        variance   => 1,
        dimension  => 1,
    );
    $cw->update(
        data  => [1],
        label => 1,
    );

    is($cw->classify(), undef, 'classify() with no params');

    is($cw->classify(
        data  => [1, 1],
    ), undef, 'classify() with @$data != dimension');

    is($cw->classify(
        data  => [1],
    ), 1, 'classify() with positive data');
}

done_testing();

