#!/run/bin/perl
#       catch.pl
#       = Copyright 2011 Xiong Changnian <xiong@cpan.org> =
#       = Free Software = Artistic License 2.0 = NO WARRANTY =

use 5.014002;
use strict;
use warnings;

use Perl6::Junction qw( all any none one );
use List::Util qw(first max maxstr min minstr reduce shuffle sum);
use File::Spec;
use File::Spec::Functions qw(
    catdir
    catfile
    catpath
    splitpath
    curdir
    rootdir
    updir
    canonpath
);
use Cwd;
use Devel::Comments '###', '####';


use lib 'lib';
use Error::Base;

say 'Running...';

sub A {
    eval{ Error::Base->crash('car', -foo => 'bar') }; 
    my $err     = $@ if $@;     # catch and examine the object
    ### $err
};

sub B {
    A; 
};

sub C {
    Error::Base::_test_trace; 
};

sub D {
    C; 
};

D;


say '...Done.';

__DATA__

Output: 


__END__
