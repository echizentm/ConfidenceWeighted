#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok('SoftConfidenceWeighted') };

test_01();
test_02();
test_03();

sub test_01 {
    note('check initialize()');

    my $cw = SoftConfidenceWeighted->new();
    ok($cw, 'new()');

    is($cw->initialize(), undef, 'initialize() with no params');

    is($cw->initialize(
        confidence     => -1,
        aggressiveness =>  1,
        dimension      =>  1,
    ), undef, 'initialize() with confidence < 0');
    ok($cw->initialize(
        confidence     => 0,
        aggressiveness => 1,
        dimension      => 1,
    ), 'initialize() with confidence == 0');
    ok($cw->initialize(
        confidence     => 1,
        aggressiveness => 1,
        dimension      => 1,
    ), 'initialize() with confidence == 1');
    is($cw->initialize(
        confidence     => 2,
        aggressiveness => 1,
        dimension      => 1,
    ), undef, 'initialize() with confidence > 1');

    is($cw->initialize(
        confidence     => 0.7,
        aggressiveness => 0,
        dimension      => 1,
    ), undef, 'initialize() with aggressiveness <= 0');
    ok($cw->initialize (
        confidence     => 0.7,
        aggressiveness => 1,
        dimension      => 1,
    ), 'initialize() with aggressiveness > 0');

    is($cw->initialize(
        confidence     => 0.7,
        aggressiveness => 1,
        dimension      => 0,
    ), undef, 'initialize() with dimension <= 0');
    ok($cw->initialize(
        confidence     => 0.7,
        aggressiveness => 1,
        dimension      => 1,
    ), 'initialize() with dimension > 0');
}

sub test_02 {
    note('check update()');

    my $cw = SoftConfidenceWeighted->new();
    $cw->initialize(
        confidence     => 0.7,
        aggressiveness => 1,
        dimension      => 1,
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

    my $cw = SoftConfidenceWeighted->new();
    $cw->initialize(
        confidence     => 0.7,
        aggressiveness => 1,
        dimension      => 1,
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

