#!/usr/bin/perl
use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    module_name => 'App::MultiUser',
    license     => 'perl',
    dist_author => 'Chad Granum <exodist7@gmail.com>',
    create_readme => 1,
    requires    => {
        'Carp' => 0,
        'Data::Dumper' => 0,
        'Fey' => 0,
        'Fey::DBIManager' => 0,
        'Fey::Loader' => 0.11,
        'Fey::ORM' => 0,
        'Module::Pluggable' => 0,
        'Moose' => 0,
        'Moose::Role' => 0,
        'MooseX::ClassAttribute' => 0,
    },
    build_requires => {
        'DBD::SQLite' => 1.00,
        'Test::Database' => 1.07,
        'Test::Exception' => 0,
        'Test::More' => 0,
    },
);

$build->create_build_script;
