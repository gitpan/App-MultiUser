package App::MultiUser::Role::Membership;
use strict;
use warnings;

use App::MultiUser;
use Fey::ORM::Table;

has_table( schema()->table( 'role_membership' ));

1;
