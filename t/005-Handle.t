#!/usr/bin/perl
use strict;
use warnings;

use Test::More tests => 9;
use App::MultiUser::Test;

my $CLASS = 'App::MultiUser::DB::Handle';

use_ok( $CLASS );

can_ok( $CLASS, 'handles' );
is_deeply( $CLASS->handles, [ undef ], "First element is undef, all actual handles have id >0" );
my $dbh = ['a'];

is( $CLASS->add( $dbh ), 1, "First id is 1 - CLASS" );
is( $CLASS->id_for( $dbh ), 1, "Found correct ID - CLASS" );
is( $CLASS->get( 1 ), $dbh, "Retrieved by ID - CLASS" );

my $one = $CLASS->new();

$dbh = ['b'];
is( $one->add( $dbh ), 2, "Second id is 2 - OBJ" );
is( $one->id_for( $dbh ), 2, "Found correct ID - OBJ" );
is( $one->get( 2 ), $dbh, "Retrieved by ID - OBJ" );
