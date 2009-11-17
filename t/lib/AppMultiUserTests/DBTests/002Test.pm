package AppMultiUserTests::DBTests::002Test;
use strict;
use warnings;
use Test::More;
use Data::Dumper;

my $CLASS = 'App::MultiUser::Test';

sub count { 2 }

sub tests {
    use_ok( $CLASS );

    my $one = $CLASS->new();
    isa_ok( $one, $CLASS );
}

1;

__END__

