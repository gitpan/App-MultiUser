package App::MultiUser::DB::Handle;
use strict;
use warnings;

use MooseX::ClassAttribute;
use Moose;

class_has handles => (
    isa => 'ArrayRef',
    is => 'ro',
    lazy => 1,
    default => sub {[ undef ]},
);

sub get {
    my $class = shift;
    my ( $id ) = @_;
    $class->handles->[ $id ];
}

sub add {
    my $class = shift;
    my ( $dbh ) = @_;
    my $id = $class->id_for( $dbh );
    unless( $id ) {
        push(@{ $class->handles }, $dbh);
        $id = $class->id_for( $dbh );
    }
    return $id;
}

sub id_for {
    my $class = shift;
    my ( $dbh ) = @_;
    return unless $dbh;
    my $handles = $class->handles;
    for( my $i = 1; $i < @$handles; $i++ ) {
        return $i if $handles->[$i] == $dbh;
    }
    return;
}

1;
