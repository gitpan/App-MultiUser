package App::MultiUser::Entity::Role;
use strict;
use warnings;
use Fey::DBIManager::Source;
use App::MultiUser;
use App::MultiUser::Entity;
use App::MultiUser::Entity::Property;
use Moose::Role;
use Carp;

requires 'entity_id';
requires 'insert';
requires 'id_field';


sub id {
    my $self = shift;
    my $field = $self->id_field;
    return $self->$field;
}

around 'insert' => sub {
    my $orig = shift;
    my $self = shift;
    my %params = @_;
    my $entity;

    if ( my $eid = $params{ 'entity_id' }) {
        $entity = App::MultiUser::Entity->new( entity_id => $eid );
    }
    else {
        my $entitytable = App::MultiUser::DB::EntityTable->new(
            table_name => $self->Table->name
        );
        $entity = App::MultiUser::Entity->insert(
            entity_table_id => $entitytable->entity_table_id
        );
        $params{ 'entity_id' } = $entity->entity_id;
    }

    my $new = $self->$orig( %params );

    $entity->update( object_id => $new->id );

    return $new;
};

sub _select {
    my $table = schema()->table( 'property' );
    return App::MultiUser::DB::Schema->SQLFactoryClass()->new_select()
           ->select( $table )
           ->from( $table )
           ->where(
              $table->column( 'entity_id' ),
              '=',
              Fey::Placeholder->new()
           );
}

sub _dbh {
    App::MultiUser::DB::Schema->DBIManager()->default_source()->dbh;
}

sub properties {
    my $self = shift;
    return [ Fey::Object::Iterator::FromSelect->new(
        classes => 'App::MultiUser::Entity::Property',
        select => _select(),
        bind_params => [ $self->entity_id ],
        dbh => _dbh()
    )->all ];
}

sub property_obj {
    my $self = shift;
    my ( $name ) = @_;

    my $select = _select()->and(
        schema()->table( 'property' )->column( 'name' ),
        '=',
        Fey::Placeholder->new()
    );

    return Fey::Object::Iterator::FromSelect->new(
        classes => [ 'App::MultiUser::Entity::Property' ],
        select => $select,
        bind_params => [ $self->entity_id, $name ],
        dbh => _dbh()
    )->next();
}

sub property {
    my $self = shift;
    my $name = shift;
    my $property = $self->property_obj( $name );

    return unless $property or @_;

    if ( $property and @_ ) {
        $property->update( value => '' . shift( @_ ));
    }
    elsif( @_ ) {
        $property = App::MultiUser::Entity::Property->insert(
            entity_id => $self->entity_id,
            name      => $name,
            value     => '' . shift( @_ ),
        );
    }

    return $property->value;
}

1;
