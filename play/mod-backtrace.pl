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
use Devel::Comments '###', '####';

#
use Perl6::Form;

        say q*package   file                    line        sub             evtext          *;
        say q*-------   ----                    ----        ---             ------          *;

sub stack {
    for my $i (0..9) {
        my @c   = caller $i;
        @c      = map { $_ or '___' } @c[0..3, 6];
        print form 
            q*{<<<<<}   {<<<<<<<<<<<<<<<<<<<<<} {<<<<<<<<<} {<<<<<<<<<<<<<} {<<<<<<<<<<<<<}      *
            , @c
            ;
        
    };
};

sub pushit {
    stack; 
};


package tellme;

sub tellit {
    eval{ main::pushit() };
};

package gramma;

eval "tellme::tellit";


die 'Haha', $!;

__DATA__

Output: 


__END__
