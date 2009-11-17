#!/usr/bin/perl
use strict;
use warnings;

use Test::More 'no_plan';
use App::MultiUser::Test;

my $test = App::MultiUser::Test->new()->ready();

my $CLASS = 'App::MultiUser::Property';

use_ok( $CLASS );


__END__

package App::MultiUser::Property;
use strict;
use warnings;

use Fey::ORM::Table;
use App::MultiUser;

has_table( schema()->table('property'));

1;
