#!/usr/bin/perl
use strict;
use warnings;

use Test::More 'no_plan';

my $CLASS = 'App::MultiUser::Cache';
use_ok( $CLASS );

is_deeply( \@App::MultiUser::Cache::EXPORT, [qw/ cache clear_cache /], "Export list" );
is_deeply( \@App::MultiUser::Cache::EXPORT_OK, [qw/ cache clear_cache clear_all_cache/], "Export_ok list" );

$CLASS->import;

is_deeply( $CLASS->mem, {}, "Got mem store" );

ok( cache( 'a', { a => 'a' }), "Cache a" );
ok( cache( 'b', { b => 'b' }), "Cache b" );
ok( cache( 'c', { c => 'c' }), "Cache c" );

is_deeply(
    $CLASS->mem,
    {
        main => {
            a => { a => 'a' },
            b => { b => 'b' },
            c => { c => 'c' }
        }
    },
    "mem store is correct"
);

is_deeply( clear_cache( 'a' ), { a => 'a' }, "Clearing cache" );
is_deeply(
    $CLASS->mem->{ main }->{ a },
    undef,
    "fields cache cleared"
);

ok( clear_cache(), "clear cache for all fields" );
is_deeply(
    $CLASS->mem->{ main },
    undef,
    "all fields cache cleared"
);

ok( cache( 'a', { a => 'a' }), "Cache a" );
ok( cache( 'b', { b => 'b' }), "Cache b" );
ok( cache( 'c', { c => 'c' }), "Cache c" );

{
    package xxx;
    App::MultiUser::Cache->import();
    cache( 'a', { a => 'a' });
}

is_deeply(
    $CLASS->mem,
    {
        main => {
            a => { a => 'a' },
            b => { b => 'b' },
            c => { c => 'c' }
        },
        xxx => {
            a => { a => 'a' },
        },
    },
    "mem store is correct"
);

App::MultiUser::Cache::clear_all_cache();
is_deeply(
    $CLASS->mem,
    {},
    "all cache cleared"
);
