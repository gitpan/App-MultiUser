#!/usr/bin/perl
use strict;
use warnings;

use Test::More 'no_plan';
use App::MultiUser::Test;
my $test = App::MultiUser::Test->new( source_id => 'SQLite' )->ready();

my $CLASS = 'App::MultiUser::Entity';

use_ok( $CLASS );
require App::MultiUser::DB::EntityTable;

my $entity_table = App::MultiUser::DB::EntityTable->new(
    table_name => 'role',
);

ok(
    my $one = $CLASS->insert(
        entity_table_id => $entity_table->entity_table_id,
    ),
    "Can build an object"
);
