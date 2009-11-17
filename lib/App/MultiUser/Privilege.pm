package App::MultiUser::Rights::Privilege;
use strict;
use warnings;

use App::MultiUser;
use Fey::ORM::Table;

has_table( schema()->table( 'privilege' ));

1;
