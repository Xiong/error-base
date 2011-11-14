#!/run/bin/perl
#       head2head.pl
#       = Copyright 2011 Xiong Changnian <xiong@cpan.org> =
#       = Free Software = Artistic License 2.0 = NO WARRANTY =

use strict;
use warnings;

use lib 'lib';
use Error::Base;

#

Error::Base->crank('Foo:');     # warns
die('Bar:');

__DATA__

Output: 

Foo:
____ at line 14    [play/head2head.pl]
Bar: at play/head2head.pl line 15.

__END__
