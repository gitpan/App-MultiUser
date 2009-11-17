#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 3;
use App::MultiUser;
use App::MultiUser::Test;

{
    package Test::Package::A;
    use Moose;
    with 'App::MultiUser::Base';
}

my $test = App::MultiUser::Test->new();
$test->dbinit;

can_ok( 'Test::Package::A', 'root' );
ok( my $one = Test::Package::A->new(), "Create instance of test package" );

is( $one->root, App::MultiUser->primary, "root() imported and returns primary App::MultiUser object" );
