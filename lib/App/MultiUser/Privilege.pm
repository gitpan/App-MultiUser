package App::MultiUser::Privilege;
use strict;
use warnings;

use App::MultiUser;
use Fey::ORM::Table;

has_table( schema()->table( 'privilege' ));
with 'App::MultiUser::Entity::Role';
has_one( schema()->table( 'entity' ));

sub id_field { 'privilege_id' }

1;
