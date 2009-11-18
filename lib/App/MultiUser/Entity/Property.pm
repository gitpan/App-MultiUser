package App::MultiUser::Entity::Property;
use strict;
use warnings;

use App::MultiUser;
use Fey::ORM::Table;

has_table( schema()->table( 'property' ));

has_one( schema()->table( 'entity' ));

1;
