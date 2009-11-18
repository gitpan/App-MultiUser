package App::MultiUser::Test;
use strict;
use warnings;
use Moose;
use MooseX::ClassAttribute;
use Test::Database;
use App::MultiUser;
use App::MultiUser::DB;
use Carp;

class_has 'handles' => (
    isa => 'HashRef',
    is => 'ro',
    lazy => 1,
    default => sub {
        return {
            map { $_->dbd => $_ } Test::Database->handles(
                { dbd => 'SQLite' },
                { dbd => 'mysql' },
                { dbd => 'Pg' },
            )
        };
    },
);

has source_id => (
    isa => 'Str',
    is => 'rw',
    default => sub {
        my $self = shift;
        my $preference = [ qw/SQLite Pg mysql/];
        my $handles = $self->handles;
        for my $item ( @$preference ) {
            return $item if $handles->{ $item };
        }
    }
);

sub source {
    my $self = shift;
    return $self->handles->{ $self->source_id };
}

sub set_source {
    my $self = shift;
    my ( $handle ) = @_;
    $self->source_id( $handle->dbd )
}

sub BUILD {
    my $self = shift;
    my $params = shift;
    return unless ( $params->{ source_id });
    unless ( $self->source && $self->source->dbd eq $self->source_id ) {
        require Test::More;
        Test::More->import( skip_all => "Unable to find handle for " . $self->source_id );
    }
}

sub dbinit {
    my $self = shift;
    my ( $noschema ) = @_;
    my $dbh = $self->source->dbh;
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 0;
    $self->clear_db();
    my $db = App::MultiUser::DB->new(
        dsn => $self->source->dsn,
        dbh => $dbh,
    );
    my $root = App::MultiUser->new(
        dbtype => $self->source->dbd,
        dbname => 'fake',
        db => $db
    );
    App::MultiUser->primary( $root );
    unless ( $noschema ) {
        App::MultiUser::DB::Migration->root( $root );
        local $SIG{'__WARN__'} = sub { 1 };
        $root->db->initdb();
    }
}

sub ready {
    my $self = shift;
    $self->dbinit( @_ );
    App::MultiUser->primary->db_schema;
    return $self;
}

sub clear_db {
    my $self = shift;
    my $dbh = $self->source->dbh;
    my $type = $dbh->get_info( 17 );
    $type = lc( $type );
    my $sub = "_clear_db_$type";
    {
        local $SIG{'__WARN__'} = sub { 1 };
        return $self->$sub( $dbh );
    }
}

sub _clear_db_postgresql {
    my $self = shift;
    my $dbh = shift;
    for my $type ( qw/sequence table/ ) {
        my $items = $dbh->selectall_arrayref(
            "SELECT " . $type . "_name FROM information_schema." . $type . "s WHERE " . $type . "_schema='public'"
        );
        for my $item ( map { $_->[0] } @$items ) {
            $dbh->do("DROP $type IF EXISTS $item CASCADE");
        }
    }
}

sub _clear_db_mysql {
    my $self = shift;
    my $dbh = shift;
    my ( $dbname ) = $dbh->selectrow_array("select DATABASE()");
    my $items;
    # MySQL's table dropping with foreign keys... just loop until
    # their all gone. This can be optimised, but for now this will suffice.
    do {
        $items = $dbh->selectall_arrayref(
            "SELECT table_name FROM information_schema.tables WHERE table_schema='$dbname'"
        );
        for my $item ( map { $_->[0] } @$items ) {
            $dbh->do("DROP table IF EXISTS $item CASCADE");
        }
    } while ( @$items );
}

sub _clear_db_sqlite {
    my $self = shift;
    my $dbh = shift;
    my $data = $dbh->selectall_arrayref( 'SELECT type, name, tbl_name, sql, rootpage FROM sqlite_master WHERE type = "table"' );
    for my $item ( @$data ) {
        $dbh->do("DROP table IF EXISTS " . $item->[1]);
    }
    $data = $dbh->selectall_arrayref( 'SELECT type, name, tbl_name, sql, rootpage FROM sqlite_master WHERE type = "index"' );
    for my $item ( @$data ) {
        $dbh->do("DROP index IF EXISTS " . $item->[1]);
    }
}

sub plugin_tests {
    my $self = shift;
    my ( $plugins, $plan ) = @_;
    unshift @INC => 't/lib';
    require Test::More;
    my @tests;
    {
        use Data::Dumper;
        my $old = { %INC };
        local %INC = %INC;
        delete $INC{ 'blib.pm' };
        require Module::Pluggable;
        Module::Pluggable->import( require => 0, search_path => $plugins );
        for my $i ( $self->plugins ) {
            eval "require $i";
            die( $@ ) if $@;
            push @tests => $i;
        }
    }

    $plan ||= 0;
    for my $test ( @tests ) {
        my $add = $test->count;
        if ( $add eq 'no_plan' ) {
            $plan = $add;
            last;
        }
        $plan += $add;
    }
    Test::More::plan( !$plan || $plan eq 'no_plan' ? $plan : tests => $plan );

    for my $i ( $self->plugins ) {
        $i->tests();
    }
}

1;
