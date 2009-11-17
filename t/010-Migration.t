#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 5;

my $CLASS = 'App::MultiUser::DB::Migration';
use_ok( $CLASS );

ok(( my $migrations = $CLASS->migrations ), "Got migrations" );
is( $migrations->[0], 'App::MultiUser::DB::Migration::000InitialSchema', "Got initial schema migration" );

for my $migration ( @{ $CLASS->migrations }) {
    eval "require $migration";
}

is_deeply(
    [ sort keys %{ $CLASS->steps }],
    [ sort @$migrations ],
    "Each migration is here"
);

is_deeply(
    [ sort keys %{ $CLASS->steps->{ $_ } }],
    [ sort qw/mysql sqlite pg/ ],
    "Each db is here"
) for @$migrations;

#Update is tested in DB tests.
