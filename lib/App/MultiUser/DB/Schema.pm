package App::MultiUser::DB::Schema;
use strict;
use warnings;

use Fey;
use Fey::Loader;
use Fey::ORM::Schema;
use Fey::DBIManager;
use Fey::DBIManager::Source;

my $db = App::MultiUser->primary->db;
my $source = Fey::DBIManager::Source->new( dbh => $db->dbh, dsn => $db->dsn );
__PACKAGE__->DBIManager()->add_source($source);

my $schema = Fey::Loader->new( dbh => $source->dbh() )->make_schema();
has_schema $schema;

#SQLite <1.26 does not have fk's
build_fks( $schema ) if App::MultiUser->primary->dbtype eq 'SQLite'
                    and $DBD::SQLite::VERSION < 1.26;

sub build_fks {
    my $schema = shift;

    my @fks = (
        [[qw/entity entity_table_id/], [qw/entity_table entity_table_id/]],
        [[qw/property entity_id/], [qw/entity entity_id/]],
        [[qw/permission entity_id/], [qw/entity entity_id/]],
        [[qw/role_membership parent_id/], [qw/role role_id/]],
        [[qw/role_membership member_id/], [qw/role role_id/]],
        [[qw/account role_id/], [qw/role role_id/]],
        [[qw/privilege_chain parent_id/], [qw/privilege privilege_id/]],
        [[qw/privilege_chain member_id/], [qw/privilege privilege_id/]],
        [[qw/permission privilege_id/], [qw/privilege privilege_id/]],
        [[qw/permission role_id/], [qw/role role_id/]],
    );

    $schema->add_foreign_key( Fey::FK->new(
        source_columns => $schema->table( $_->[0][0] )->column( $_->[0][1] ),
        target_columns => $schema->table( $_->[1][0] )->column( $_->[1][1] ),
    )) for @fks;

    require App::MultiUser::DB::EntityTable;
    App::MultiUser::DB::EntityTable->build_fks( $schema );
}

1;
