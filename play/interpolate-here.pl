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

my $foo         = 'bar'; 
my $dog         = 'cat';
my @zork        = qw/ flood control dam three /;

my %hash        = ( 
                    '$foo'      => 'bar', 
                    '$dog'      => 'cat',
                    'internal'  => 42,
                    '@zork'     => [qw/ flood control dam three /],
                );
my $text        = q*>$foo\t$dog\n@zork<|$zork[0]=@hash{ '$foo', '$dog' }*;

$text           = q{"} . "$text" . q{"};
$text           = eval "$text";

say $text;
say $@ if $@;
say '...Done.';

__DATA__

Output: 


__END__
