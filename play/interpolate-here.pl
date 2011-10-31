#!/run/bin/perl
#       interpolate-here.pl
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

say 'Running...';

my $vp          = 'P42';
my %hash        = ( 
                    '$foo'      => 'bar', 
                    '$dog'      => 'cat',
                    'internal'  => 42,
                    '@zork'     => [qw/ flood control dam three /],
#~                     '$"'        => '-',
#~                     '$"'        => '',
                );
my $text        = '>$foo<>$dog<>@zork<';

for (keys %hash) {
    my $val     = $hash{$_};
    s/^(.)//;
    my $sigil   = $1;
    my $re      = qr/$_/;
    ### $re
    ### $val
    ### $sigil
    
    if    ( $sigil eq '$' ) {
        $text       =~ s/\$$re/$val/g;            
    } 
    elsif ( $sigil eq '@' ) {
        local $"    = defined $hash{'$"'} ? $hash{'$"'} : q{ };
        $val        = join $", @$val;
        $text       =~ s/\@$re/$val/g;            
    } 
    else {
        # do nothing
    };
    
};

say $text;

say '...Done.';

#~ my @zork    = @{ $hash{'@zork'} };
#~ say @zork;

__DATA__

Output: 


__END__
