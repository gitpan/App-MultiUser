#!/usr/bin/perl
use strict;
use warnings;

use Test::More 'no_plan';
use App::MultiUser::Test;

my $test = App::MultiUser::Test->new()->ready();

my $CLASS = 'App::MultiUser::Role';

use_ok( $CLASS );


__END__

package App::MultiUser::Role;
use strict;
use warnings;

use App::MultiUser;
use Fey::ORM::Table;

has_table( schema()->table( 'role' ));

1;
