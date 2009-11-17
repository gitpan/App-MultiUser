package App::MultiUser::DB;
use strict;
use warnings;
use Moose;
use App::MultiUser;
use App::MultiUser::DB::Migration;
use App::MultiUser::DB::Handle;

with 'App::MultiUser::Base';

has dbh_id => (
    is => 'rw',
    isa => 'Int',
);

has dsn => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub {
        my $self = shift;
        return 'dbi:'
             . $self->root->dbtype
             . ':dbname=' . $self->root->dbname
    }
);

sub BUILD {
    my $self = shift;
    my ( $args ) = @_;
    my $dbh = $args->{ dbh };
    unless( $dbh ) {
        require DBI;
        $dbh = DBI->connect(
            $self->dsn,
            $self->root->dbname,
            $self->root->dbpass
        );
    }
    $self->set_dbh( $dbh )
}

sub set_dbh {
    my $self = shift;
    my ( $dbh ) = @_;
    my $id = App::MultiUser::DB::Handle->add( $dbh );
    $self->dbh_id( $id );
    return $id;
}

sub dbh {
    my $self = shift;
    my $id = $self->dbh_id;
    App::MultiUser::DB::Handle->get( $id );
}

sub initdb {
    my $self = shift;
    App::MultiUser::DB::Migration->update();
}

1;
