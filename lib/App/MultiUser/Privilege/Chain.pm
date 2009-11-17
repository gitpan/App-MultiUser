package App::MultiUser::Rights::Privilege::Chain;
use strict;
use warnings;

use App::MultiUser;
use Fey::ORM::Table;

has_table( schema()->table( 'privilege_chain' ));

1;
