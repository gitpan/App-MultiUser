#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;
use App::MultiUser::Test;

my $test = App::MultiUser::Test->new( source_id => 'SQLite' );
$test->dbinit;
$test->plugin_tests( 'AppMultiUserTests::DBTests', 0 );
