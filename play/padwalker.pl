#!/run/bin/perl
#       padwalker.pl
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
use PadWalker qw/ peek_my peek_our var_name /;

say 'Running...';

my $_scalar     = 'mfoo';
my @_array      = qw/ m0 m1 m2 m3/;
my %_hash       = ( x => 'mx', y => 'my',  );

sub A {
    my $A_scalar    = 'Afoo';
    my @A_array     = qw/ A0 A1 A2 A3/;
    my %A_hash      = ( x => 'Ax', y => 'Ay',  );
    my $B_coderef   = \sub {
        my $B_scalar    = 'Bfoo';
        my @B_array     = qw/ B0 B1 B2 B3/;
        my %B_hash      = ( x => 'Bx', y => 'By',  );
            peek_all();
        };
};

sub peek_all {
    my $err     = Error::Base->new();
    my $trace   = $err->cuss();
    say $trace;
    
    
    
};




say '...Done.';

__DATA__

Output: 


__END__
