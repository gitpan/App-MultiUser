package App::MultiUser::Cache;
use strict;
use warnings;
use Moose;
use MooseX::ClassAttribute;

use base 'Exporter';
our @EXPORT = qw/ cache clear_cache /;
our @EXPORT_OK = ( @EXPORT, qw/clear_all_cache/ );

class_has mem => (
    isa => 'HashRef',
    is => 'rw',
    lazy => 1,
    default => sub { {} },
);

sub cache {
    my ( $caller ) = caller();
    my ( $field, $data ) = @_;

    __PACKAGE__->mem->{ $caller }->{ $field } = $data
        if defined $data;

    return __PACKAGE__->mem->{ $caller }->{ $field };
}

sub clear_cache {
    my ( $caller ) = caller();
    my ( $field ) = @_;
    return $field ? delete __PACKAGE__->mem->{ $caller }->{ $field }
                  : delete __PACKAGE__->mem->{ $caller };
}

sub clear_all_cache { __PACKAGE__->mem( {} ) }

1;
