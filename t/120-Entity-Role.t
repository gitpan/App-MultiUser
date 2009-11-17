#!/usr/bin/perl
use strict;
use warnings;

use Test::More 'no_plan';
use App::MultiUser::Test;

my $test = App::MultiUser::Test->new()->ready();

my $CLASS = 'App::MultiUser::Entity::Role';

use_ok( $CLASS );


__END__

package App::MultiUser::Entity::Role;
use strict;
use warnings;
use Fey::DBIManager::Source;
use App::MultiUser;
use Moose::Role;
use Carp;

requires 'entity_id';

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
        classes => App::MultiUser::property_class(),
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
        classes => App::MultiUser::property_class(),
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
        $property = App::MultiUser::property_class()->insert(
            entity_id => $self->entity_id,
            name      => $name,
            value     => '' . shift( @_ ),
        );
    }

    return $property->value;
}

1;
