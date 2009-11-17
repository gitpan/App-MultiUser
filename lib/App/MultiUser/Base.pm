package App::MultiUser::Base;
use strict;
use warnings;

use Moose::Role;
use App::MultiUser;

has root => (
    isa => 'App::MultiUser',
    is => 'rw',
    lazy => 1,
    default => sub { App::MultiUser->primary },
);

1;
