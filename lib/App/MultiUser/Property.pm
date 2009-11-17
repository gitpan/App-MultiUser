package App::MultiUser::Property;
use strict;
use warnings;

use Fey::ORM::Table;
use App::MultiUser;

has_table( schema()->table('property'));

1;
