package App::MultiUser::Role;
use strict;
use warnings;

use App::MultiUser;
use Fey::ORM::Table;

has_table( schema()->table( 'role' ));
with 'App::MultiUser::Entity::Role';

has_one( schema()->table( 'entity' ));

sub id_field { 'role_id' }

1;
