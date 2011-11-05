#!/run/bin/perl
#       jackbnimble.pl
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
#~ use Error::Base;
#~ use PadWalker qw/ peek_my peek_our var_name /;

say 'Running...';

#~ my $foo     = '42';
#~ my $bar     = 'baz';
#~ my $funk    = {$foo};
#~ my $pond    = {$bar};
#~ 
#~ say $funk, $pond;
#~ exit;

my $_scalar     = 'mfoo';
my @_array      = qw/ m0 m1 m2 m3/;
my %_hash       = ( x => 'mx', y => 'my',  );

my $_scaref     = \'mrfoo';
my $_aryref     = [qw/ mr0 mr1 mr2 mr3/];
my $_hshref     = { x => 'mx', y => 'my',  };

no  strict 'vars';
#~                 $P_             = 'P_null';
    our         $P_our          = 'our_P';
#~     local       $P_local        = 'local_P';
    local our   $P_local_our    = 'local_our_P';
use strict 'vars';

sub A {
    my $A_scalar    = 'Afoo';
    my @A_array     = qw/ A0 A1 A2 A3/;
    my %A_hash      = ( x => 'Ax', y => 'Ay',  );
    
    my $B_coderef   = 
        sub {
            my $B_scalar    = 'Bfoo';
            my @B_array     = qw/ B0 B1 B2 B3/;
            my %B_hash      = ( x => 'Bx', y => 'By',  );
            
            Fake::peek_all();
        };
        
    &$B_coderef();
};

package Fake;
{
    sub peek_all {
        say $_scalar;
        
        
        
        
    };
}

package main;

A();

say '...Done.';

__DATA__

#~     my $err     = Error::Base->new( -prepend => '|--' );
#~     say $err->cuss('Backtrace in peek_all():');
#~     say q{};
    
#~     my @frames  ;
#~     my $f       = 0 ;
#~     while ( caller $f ) {
#~         my $peek_my     = peek_my($f);
#~         ### $f
#~         ### $peek_my
#~         
#~         $f++;
#~     };
    
#~     my $peek_my     = peek_my(1);
#~     ### $peek_my
#~     my $peek_our    = peek_our(1);
#~     ### $peek_our
#~     say q{};


__END__
