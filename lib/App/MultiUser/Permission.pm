package App::MultiUser::Rights::Permission;
use strict;
use warnings;

use App::MultiUser;
use Fey::ORM::Table;

has_table( schema()->table( 'permission' ));

1;
