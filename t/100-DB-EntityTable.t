#!/usr/bin/perl
use strict;
use warnings;

use Test::More 'no_plan';
use App::MultiUser::Test;

my $test = App::MultiUser::Test->new( source_id => 'SQLite' )->ready();

my $CLASS = 'App::MultiUser::DB::EntityTable';

use_ok( $CLASS );

is_deeply(
    [ sort map { $_->table_name } $CLASS->iterator->all ],
    [
        sort qw/ role privilege account/
    ],
    "Found all entity_tables"
);

is_deeply(
    [ $CLASS->iterator->all ],
    $CLASS->get_all,
    "Got all"
);

for my $table ( map { $_->table_name } @{ $CLASS->get_all }) {
    my @fks = App::MultiUser->primary->schema->foreign_keys_between_tables($table, 'entity');
    App::MultiUser->primary->schema->remove_foreign_key( $_ ) for @fks;
}
for my $table ( map { $_->table_name } @{ $CLASS->get_all }) {
    is(
        App::MultiUser->primary->schema->foreign_keys_between_tables($table, 'entity'),
        0,
        "No fk's for $table and 'entity'"
    );
}
$CLASS->build_fks( App::MultiUser->primary->schema );
for my $table ( map { $_->table_name } @{ $CLASS->get_all }) {
    is(
        App::MultiUser->primary->schema->foreign_keys_between_tables($table, 'entity'),
        1,
        "fk for $table and 'entity' generated"
    );
}



__END__

sub build_fks {
    my $class = shift;
    my ( $schema ) = @_;

    my $all = $class->get_all;

    $schema->add_foreign_key( Fey::FK->new(
        source_columns => $schema->table( $_ )->column( 'entity_id' ),
        target_columns => $schema->table( 'entity' )->column( 'entity_id' ),
    )) for map { $_->table_name } @$all;
}
