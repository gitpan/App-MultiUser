package App::MultiUser::Version;
use strict;
use warnings;

use App::MultiUser;
use Fey::ORM::Table;

with 'App::MultiUser::Base';

has_table( schema()->table( 'unit_version' ));

1;
