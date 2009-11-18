package App::MultiUser::Permission;
use strict;
use warnings;

use App::MultiUser;
use Fey::ORM::Table;

has_table( schema()->table( 'permission' ));

1;
