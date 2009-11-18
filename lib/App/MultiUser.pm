package App::MultiUser;
use strict;
use warnings;
use Moose;
use MooseX::ClassAttribute;
use Carp;

our $VERSION = '0.0002';
our @EXPORT = qw/schema/;

#{{{ POD

=pod

=head1 NAME

App::MultiUser - Base framework for an application with users and roles.

=head1 *ALPHA WARNING*

This module is currently in the early alpha stages. For the latest please check
the github page at L<http://github.com/exodist/App-MultiUser>

This module is only on CPAN in order to reserve the namespace. Development
could take a while, and it would not be fun to rename the package halfway
through because someone else took the namespace.

=head1 DESCRIPTION

App-MultiUser is a package that contains a good base for building an
application that has users, roles, and permissions. It can be plugged in to an
existing application, or used as a base for a new one.

=head1 TERMINOLOGY

=over 4

=item Entity Table

A special table that has a list of table names, each table in the list defines
objects which are entities. When you wish to add a new object type that is an
entity you should add the table name to this table.

=item Entity

An entity is the base class for many other classes. Any object that permissions
can be granted against in any way should be an entity. All entities have an
entity_id field which is a unique identifier across object tables.

There is an entity table, This table is a complete list of all entities in the
database. Every account, role, and privelege should have an entry here.

The primary purpose of the entity table/object is to assign a unique identifier
for each entity object accross all entity tables.

=item Account or User

These terms can be used interchangably. In general 'user' will be used. However
'Account' may be more accurate. Accoutn is used in schema and class names
simply because some database engines do not let you create a 'user' or 'users'
table.

=item Role or Group

Roles can also be thought of as groups. There are 2 types of role: System Role,
and User Role.

User roles are directly associated with a single account. When an account has a
role_id that role is defined as an account role. System roles are any roles not
associated with an account.

Roles have memberships, these memberships allow one role to be a member of
another role. This relationship is a parent/child relationship. A user is
considered a member of a role when it's Account role is a member.

=item Privilege

A privilege is a specific right that can be granted. An example would be an
'Administrator' privilege. To create a new right simply add a new privilege
object to the database. Keep in mind, once a privilege is added you still need
to add logic everywhere to validate that right.

Priveleges can be chained. Chaining is a parent-member relationship. When a
parent privlege is granted to a role all chained (member) privileges will also
be granted.

=item Permission

A permission is where a specific role is granted a specific privielege.
Permissions are direct relationships between role and privilege. Some
priveleges are granted to a role in order to have special rights on a specific
entity. In this case the Permission object will have an entity_id specified.

Permissions are granted to roles only. In order to give a specific account a
permission you must grant the permission to the account's account role.
Permissions are inherited, if a parent role has a permission all direct and
indirect members will have it as well. Parents do not however inherit
permissions from their members.

=item Property

There is a property table, and property object. A Property is a key/value
associated with an entity. This is a way to add arbitrary data to any entity.
In many cases it would be better to create a table for the object you want to
build, and use a foreign key to reference the specific entity
(account/role/etc).

Properties would be useful for plugins to App-MultiUser that need to specify
data on entities, but cannot make any assumptions about the schema aside from
what App-MultiUser provides. In such cases it is probably better for all
property keys to be prefixed with the plugin name.

=back

=head1 SYNOPSYS

*Under Construction*

=head1 CONSTRUCTOR ARGUMENTS

=over 4

=item db

=back

=head1 MULTIPURPOSE SUBS

These are subs that can be imported, used as a class method, or used as an
object method.

=over 4

=item schema()

Returns the Fey::Schema for the primary App::MultiUser object. Optionally an
alternate App::MultiUser object can be passed in.

=cut

#}}}

sub schema {
    my $self = shift( @_ );
    $self = __PACKAGE__->primary unless $self;
    return $self->db_schema->Schema();
}

=back

=head1 CLASS METHODS

=over 4

=item import()

The magical import function, called when you do:

    use App::MultiUser;

Pass in constructor parameters to build the 'primary' object.

If you pass in parameters thent he exported function will not be imported
unless you also specify import => undef or import => [ ... ]. undef will bring
in all exported functions.

=cut

sub import {
    my $class = shift;
    my %params;
    {
        no warnings 'misc';
        %params = @_;
    }
    $params{ 'import' } = undef unless keys %params;

    if ( exists $params{ 'import' }) {
        my $list = delete( $params{ 'import' }) || \@EXPORT;
        my ($cpackage) = caller();
        no strict 'refs';
        for my $item ( @$list ) {
            *{ $cpackage . '::' . $item } = \&{$item}
        }
    }

    return unless keys %params;

    $class->primary(
        $class->new( \%params )
    );
    return 1;
}

=item primary()

Get/set the primary instance of App::MultiUser.

=cut

class_has primary => (
    isa => __PACKAGE__,
    is => 'rw',
);

=back

=head1 OBJECT METHODS

=over 4

=item dbtype()

Get the database type, valid options are SQLite, Pg, and mysql.

=cut

has dbtype => (
    isa => 'Str',
    is => 'ro',
    lazy => 1,
    default => 'SQLite',
);

=item dbname()

Get the name of the database to use.

=cut

has dbname => (
    required => 1,
    isa => 'Str',
    is => 'ro',
);

=item dbuser()

Get the username of the database to use.

=cut

has dbuser => (
    isa => 'Str',
    is => 'ro',
    lazy => 1,
    default => sub {''},
);

=item dbpass()

Get the password for the database to use.

=cut

has dbpass => (
    isa => 'Str',
    is => 'ro',
    lazy => 1,
    default => sub {''},
);

=item db()

Get the App::MultiUser::DB Object used to interface with the database

=cut

has db => (
    is => 'ro',
    lazy => 1,
    default => sub {
        require App::MultiUser::DB;
        App::MultiUser::DB->new()
    }
);

=item db_schema()

Get the App::MultiUser::DB::Schema object to use.

=cut

has db_schema => (
    isa => 'App::MultiUser::DB::Schema',
    is => 'ro',
    lazy => 1,
    default => sub {
        require App::MultiUser::DB::Schema;
        App::MultiUser::DB::Schema->new()
    }
);

=item initdb()

init the database, this means run all the migrations.

=cut

sub initdb {
    my $self = shift;
    $self->db->initdb();
}

1;

__END__

=back

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2009 Chad Granum

App-MultiUser is free software; Standard perl licence.

App-MultiUser is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the license for more details.
