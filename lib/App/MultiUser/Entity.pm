package App::MultiUser::Entity;
use strict;
use warnings;

use Fey::ORM::Table;
use App::MultiUser;
use Moose;

has_table( schema()->table('entity'));

has_one( schema()->table( 'entity_table' ));

has object => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        my $table_name = $self->entity_table->table_name;
        my $table = schema()->table($table_name);
        my $class = Fey::Meta::Class::Table->ClassForTable( $table );
        return $class->new( $class->id_field => $self->object_id );
    }
);

1;
