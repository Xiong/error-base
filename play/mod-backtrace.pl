#!/run/bin/perl
#       backtrace.pl
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
#~ use Devel::Comments '###', '####';


use lib 'lib';
use Error::Base;
sub stack {
    my @lines = Error::Base::_trace();
    say for @lines;
};

sub pushit {
    stack; 
};


package tellme;

sub tellit {
    eval{ main::pushit() };
};

package gramma;

sub watchout {
    eval ("tellme::tellit");
};


package main;

gramma::watchout;

say 'Haha';

__DATA__

Output: 


__END__
