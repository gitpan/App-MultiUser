#!/usr/bin/perl
use strict;
use warnings;

use Test::More 'no_plan';
use App::MultiUser::Test;

my $test = App::MultiUser::Test->new()->ready();

my $CLASS = 'App::MultiUser::Entity';

use_ok( $CLASS );


__END__

package App::MultiUser::Entity;
use strict;
use warnings;

use Fey::ORM::Table;
use App::MultiUser;

has_table( schema()->table('entity'));

our @CHILDREN = qw/config account role privilege/;

has_one( schema()->table( $_ )) for @CHILDREN;

sub object {
    my $self = shift;
    for my $type ( @CHILDREN ) {
        my $child = $self->$type;
        return $child if $child;
    }
}

1;
