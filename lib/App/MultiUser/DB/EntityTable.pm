package App::MultiUser::DB::EntityTable;
use strict;
use warnings;

use App::MultiUser;
use Fey::ORM::Table;

has_table( App::MultiUser->primary->schema->table( 'entity_table' ));

sub build_fks {
    my $class = shift;
    my ( $schema ) = @_;

    my $all = $class->get_all;

    $schema->add_foreign_key( Fey::FK->new(
        source_columns => $schema->table( $_ )->column( 'entity_id' ),
        target_columns => $schema->table( 'entity' )->column( 'entity_id' ),
    )) for map { $_->table_name } @$all;
}

sub iterator {
    my $class = shift;
    my $schema = App::MultiUser->primary->schema;

    my $select = $class->SchemaClass()->SQLFactoryClass()->new_select();
    $select->select( $class->Table )->from( $class->Table );

    return Fey::Object::Iterator::FromSelect->new(
        classes     => [ $class->meta()->ClassForTable( $class->Table ) ],
        bind_params => [ $select->bind_params() ],
        select      => $select,
        dbh         => $class->_dbh($select)
    );
}

sub get_all {
    return [ __PACKAGE__->iterator->all ];
}

sub all_entities {
    return [ map { $_->table_name } @{ __PACKAGE__->get_all }];
}

1;
