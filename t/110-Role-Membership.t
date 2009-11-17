#!/usr/bin/perl
use strict;
use warnings;

use Test::More 'no_plan';
use App::MultiUser::Test;

my $test = App::MultiUser::Test->new()->ready();

my $CLASS = 'App::MultiUser::Role::Membership';

use_ok( $CLASS );
