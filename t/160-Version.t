#!/usr/bin/perl
use strict;
use warnings;

use Test::More 'no_plan';
use App::MultiUser::Test;

my $test = App::MultiUser::Test->new()->ready();

my $CLASS = 'App::MultiUser::Version';

use_ok( $CLASS );


__END__

package App::MultiUser::Version;
use strict;
use warnings;

use App::MultiUser;
use Fey::ORM::Table;
use Data::Dumper;

with class( 'Base' );

has_table( schema()->table( 'unit_version' ));

1;
