package App::MultiUser::DB::Migration;
use strict;
use warnings;
use MooseX::ClassAttribute;
use App::MultiUser;
use Module::Pluggable require => 0, search_path => 'App::MultiUser::DB::Migration';

use base 'Exporter';
our @EXPORT = qw/add_step/;

class_has migrations => (
    is => 'ro',
    isa => 'ArrayRef',
    lazy => 1,
    default => sub {
        [
            sort { $a->version <=> $b->version }
            App::MultiUser::DB::Migration->plugins()
        ]
    },
);

class_has steps => (
    is => 'ro',
    isa => 'HashRef',
    lazy => 1,
    default => sub {{}},
);

class_has root => (
    isa => 'App::MultiUser',
    is => 'rw',
    lazy => 1,
    default => sub { App::MultiUser->primary },
);


sub add_step {
    my ( $db, @steps ) = @_;
    my ( $migration ) = caller();
    my $steps = App::MultiUser::DB::Migration->steps;
    $steps->{ $migration } ||= {};
    $steps->{ $migration }->{ $db } ||= [];
    push ( @{ $steps->{ $migration }->{ $db }}, @steps );
}

sub update {
    my $class = shift;
    my $ran = [];
    for my $migration ( @{ $class->migrations }) {
        eval "require $migration";
        die( $@ ) if $@;
        for my $step ( @{ $class->steps->{ $migration }->{ lc($class->root->dbtype) }}) {
            if ( ref $step and ref $step eq 'CODE' ) {
                $step->();
            }
            else {
                local $class->root->db->dbh->{RaiseError} = 1;
                $class->root->db->dbh->do( $step );
            }
        }
        push @$ran => $migration;
    }
    return $ran;
}

1;
