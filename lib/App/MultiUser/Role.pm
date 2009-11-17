package App::MultiUser::Role;
use strict;
use warnings;

use App::MultiUser;
use Fey::ORM::Table;

has_table( schema()->table( 'role' ));

1;
