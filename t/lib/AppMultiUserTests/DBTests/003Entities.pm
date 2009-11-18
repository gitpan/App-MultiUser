package AppMultiUserTests::DBTests::003Entities;
use strict;
use warnings;
use Test::More;
use Data::Dumper;

our %DEFAULTS;

sub count { 54 }

sub tests {
    require App::MultiUser::DB::EntityTable;
    my @CLASSES = grep { eval "require $_" }
        map { 'App::MultiUser::' . ucfirst($_) }
            @{ App::MultiUser::DB::EntityTable->all_entities };

    gen_defaults();

    for my $CLASS ( @CLASSES ) {
        use_ok( $CLASS );
        ok( my $one = $CLASS->insert( defaults($CLASS) ), "Insert new - $CLASS");
        ok( $one->entity_id, "insert created entity_id - $CLASS" );
        is( $one->entity->entity_id, $one->entity_id, "Got entity_id and object - $CLASS" );

        my $entity;
        ok( $entity = App::MultiUser::Entity->insert(
            entity_table_id => App::MultiUser::DB::EntityTable->new(
                table_name => $CLASS->Table->name
            )->entity_table_id,
        ), "Create entity");
        ok( $entity->entity_id, "have entity_id - $CLASS" );

        $one->delete();
        ok( $one = $CLASS->insert( defaults($CLASS), entity_id => $entity->entity_id ), "Create w/ entity - $CLASS");
        is( $one->entity_id, $entity->entity_id, "Can create with specific entity - $CLASS" );
        is( $one->entity->object_id, $one->id, "Object ID is set - $CLASS" );
        isa_ok( $one->entity->object, $CLASS, "Got object - $CLASS" );
        is( $one->entity->object->id, $one->id, "Got correct object - $CLASS" );

        ok( !$one->property( 'a' ), "no 'a' property yet - $CLASS" );
        is( $one->property( 'a', 'apple' ), 'apple', "set property a - $CLASS" );
        is( $one->property( 'a' ), 'apple', "Property is set - $CLASS" );
        is( $one->property( 'b', 'bat' ), 'bat', "set property a - $CLASS" );
        is( $one->property( 'a', 'apple II' ), 'apple II', "update property a - $CLASS" );
        is( $one->property( 'a' ), 'apple II', "Property is set - $CLASS" );
        is_deeply(
            [ sort { $a->property_id <=> $b->property_id } @{ $one->properties }],
            [
                sort { $a->property_id <=> $b->property_id }
                $one->property_obj( 'a' ),
                $one->property_obj( 'b' ),
            ],
            "get all properties"
        );
    }
}

#{{{ Supporting subs
sub gen_defaults {
    %DEFAULTS = (
        'App::MultiUser::Role' => {
            name => 'test',
        },
        'App::MultiUser::Account' => {
            role_id => App::MultiUser::Role->insert( name => 'test2' )->id,
        },
        'App::MultiUser::Privilege' => {
            name => 'test',
        },
    );
}

sub defaults {
    my $CLASS = shift;
    my $out = $DEFAULTS{ $CLASS };
    return unless $out;
    return %$out;
}
#}}}

1;

__END__

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
    return Fey::Object::Iterator::FromSelect->new(
        classes => 'App::MultiUser::Property',
        select => _select(),
        bind_params => [ $self->entity_id ],
        dbh => _dbh()
    )->all;
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
        classes => 'App::MultiUser::Property',
        select => $select,
        bind_params => [ $self->entity_id, $name ],
        dbh => _dbh()
    )->next();
}

sub property {
    my $self = shift;
    confess "No self." unless $self;
    my $name = shift;
    my $property = $self->property_obj( $name );

    return unless $property or @_;

    if ( $property and @_ ) {
        $property->update( value => '' . shift( @_ ));
    }
    elsif( @_ and not $property ) {
        $property = App::MultiUser::Property->insert(
            entity_id => $self->entity_id,
            name      => $name,
            value     => '' . shift( @_ ),
        );
    }

    return $property->value;
}

1;
