package AppMultiUserTests::DBTests::001DB;
use strict;
use warnings;
use Test::More;
use Data::Dumper;

my $CLASS = 'App::MultiUser::DB';

sub count { 22 }

my $TABLES = {
    entity => {
         entity_table_id => 'entity_table_id',
         entity_id => 'entity_id',
    },
    property => {
         entity_id => 'entity_id',
    },
    role => {
         entity_id => 'entity_id',
         member_id => 'role_id',
         parent_id => 'role_id',
         role_id => 'role_id'

    },
    role_membership => {
         parent_id => 'role_id',
         member_id => 'role_id',
    },
    account => {
         entity_id => 'entity_id',
         role_id => 'role_id'
    },
    privilege => {
         entity_id => 'entity_id',
         privilege_id => 'privilege_id',
         member_id => 'privilege_id',
         parent_id => 'privilege_id'
    },
    privilege_chain => {
         parent_id => 'privilege_id',
         member_id => 'privilege_id',
    },
    permission => {
         privilege_id => 'privilege_id',
         role_id => 'role_id',
         entity_id => 'entity_id',
    }
};

sub tests {
    use_ok( $CLASS );

    my $one = $CLASS->new(
        dbh => App::MultiUser->primary->db->dbh,
        dsn => App::MultiUser->primary->db->dsn,
    );
    isa_ok( $one, $CLASS );

    ok( my $root = App::MultiUser->primary() );
    ok( $one->dsn );

    $one = $root->db;
    ok( $one->dbh, "Got DBH" );
    isa_ok( $one->dbh, 'DBI::db' );

    my $schema = App::MultiUser::DB::Schema->new->Schema;

    ok( $schema->table( $_ ), "Found table: $_" ) for keys %$TABLES;

    for my $table ( keys %$TABLES ) {
        my $want = $TABLES->{ $table };
        my $have = [ App::MultiUser->primary->schema->foreign_keys_for_table($table) ];
        $have = { map { $_->source_columns->[0]->name => $_->target_columns->[0]->name } @$have };
        $want ||= {};
        unless( is_deeply( $want, $have, "Foreign Keys for $table" )) {
            print Dumper( $have, $want );
        }
    }
}

1;
