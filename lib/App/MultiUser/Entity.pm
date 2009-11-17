package App::MultiUser::Entity;
use strict;
use warnings;

use Fey::ORM::Table;
use App::MultiUser;

has_table( schema()->table('entity'));

our @CHILDREN = qw/account role privilege/;

has_one( schema()->table( $_ )) for @CHILDREN;

sub object {
    my $self = shift;
    for my $type ( @CHILDREN ) {
        my $child = $self->$type;
        return $child if $child;
    }
}

1;
