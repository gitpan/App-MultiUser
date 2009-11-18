#!/usr/bin/perl
use strict;
use warnings;

use Test::More;
use Test::Exception;
use Fey;
use Fey::Loader;
use Test::Database;

my $hcount = Test::Database->handles(
    { dbd => 'SQLite' },
    { dbd => 'mysql' },
    { dbd => 'Pg' },
);
plan tests => 7 + $hcount * 10;

my $CLASS = 'App::MultiUser::Test';

use_ok( $CLASS );

ok( my $one = $CLASS->new(), "Create new instance of $CLASS");
isa_ok( $one, $CLASS );
ok( keys %{ $one->handles }, "At least one DB handle" );
ok(( grep { $_ eq $one->source_id } qw/SQLite Pg mysql/), "Default source_id" );
ok( $one->source, "Got source" );
isa_ok( $one->source, "Test::Database::Handle", "Source is correct" );
is( $one->source->dbd, $one->source_id, "Source_id and source match" );

SKIP: {
    my $source_id = $one->source_id;
    my @other = grep { $_->dbd ne $one->source_id } values %{ $one->handles };
    skip "Only one source available", ( 4 * @other ) + 1 unless ( @other > 1 );

    for my $source ( @other ) {
        ok( $one->set_source( $source ), "set_source()" );
        is( $one->source_id, $source->dbd, "Correct source set" );
        is( $one->source, $source, "Got correct source object" );
        is( $CLASS->new( source_id => $source->dbd )->source, $source, "Build with source" );
    }

    $one->source_id( $source_id );
    is( $one->source_id, $source_id, "Restored source_id" );
}

{
    local *Test::More::import = sub {
        die( $_[2] );
    };
    dies_ok { $CLASS->new( source_id => 'fake' ) } "Cannot build w/ bad source_id";
    like( $@, qr/Unable to find handle for fake/, "Correct error" );
}

for my $source ( values %{ $CLASS->handles }) {
    diag $source->dbd . "\n";
    my $two = $CLASS->new( source_id => $source->dbd );
    $two->clear_db;
    my $schema = Fey::Loader->new( dbh => $source->dbh() )->make_schema();
    ok( !($schema->tables), "No tables yet" );
    ok( $two->dbinit( 1 ), "initdb" );
    ok( !($schema->tables), "No tables yet" );
    ok( $two->dbinit, "initdb" );
    $schema = Fey::Loader->new( dbh => $source->dbh() )->make_schema();
    ok( ($schema->tables), "Tables now" );
    $two->clear_db;
    $schema = Fey::Loader->new( dbh => $source->dbh() )->make_schema();
    ok( !($schema->tables), "No tables now" );
}
