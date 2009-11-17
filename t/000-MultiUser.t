#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 12;
use Test::Exception;
use App::MultiUser::Test;
use File::Temp qw/ tempfile /;

my $test = App::MultiUser::Test->new( source_id => 'SQLite' );
my $CLASS;

BEGIN {
    $CLASS = 'App::MultiUser';
    use_ok( $CLASS );
    my (undef, $filename) = tempfile( 'tempdb-XXXX', UNLINK => 1);
    use_ok( $CLASS, dbname => $filename );
    ok( $CLASS->primary, "primary created" );
}

{
    package Test;
    use App::MultiUser 'import';
    use Test::More;
    can_ok( 'Test', @App::MultiUser::EXPORT );

    package TestB;
    use App::MultiUser import => [qw/get class/];
    use Test::More;

    can_ok( 'TestB', qw/get class/ );
    ok( ! TestB->can( 'load' ), "load not imported" );

    package TestC;
    use App::MultiUser;
    use Test::More;
    can_ok( 'TestC', @App::MultiUser::EXPORT );
}

$CLASS->import('import');
can_ok( __PACKAGE__, @App::MultiUser::EXPORT );
$CLASS->import('import' => ['root']);
can_ok( __PACKAGE__, 'root' );

is( $CLASS->primary->dbtype, "SQLite", "Default dbtype is SQLite" );

ok( $CLASS->primary->initdb(), "initdb");

is( App::MultiUser::schema(), $CLASS->primary->schema, "Schema both as class function and object method" );

