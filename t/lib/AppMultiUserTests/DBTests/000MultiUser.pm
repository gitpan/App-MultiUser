package AppMultiUserTests::DBTests::000MultiUser;
use strict;
use warnings;
use Test::More;

sub count { 3 };

sub tests {
    isa_ok( App::MultiUser->primary->db, 'App::MultiUser::DB' );
    isa_ok( App::MultiUser->primary->db_schema, 'App::MultiUser::DB::Schema' );
    isa_ok( App::MultiUser->primary->schema, 'Fey::Schema' );
}

1;
