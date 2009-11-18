package App::MultiUser::Account;
use strict;
use warnings;

use App::MultiUser;
use Fey::ORM::Table;

has_table( schema()->table( 'account' ));
with 'App::MultiUser::Entity::Role';

has_one( schema()->table( 'entity' ));
has_one( schema()->table( 'role' ));

sub id_field { 'account_id' }

1;
