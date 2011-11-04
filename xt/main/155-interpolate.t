use strict;
use warnings;

use Test::More;

use Error::Base;
my $QRTRUE       = $Error::Base::QRTRUE    ;
my $QRFALSE      = $Error::Base::QRFALSE   ;

#----------------------------------------------------------------------------#

my $err     = Error::Base->new(
                '$foo'      => 'bar',
            );
my $out     = $err->_late('-->$foo<--');

say STDERR '>', $out, '<';

exit;

my @td  = (
    {
        -case   => 'null',                      # stringified normal return
        -want   => words(qw/ 
                    undefined error 
                    eval line 
                    ____ line 
                /),
    },
    
    {
        -case   => 'null-fuzz',                 # explain whole object
        -fuzz   => words(qw/ 
                    bless
                    lines
                        undefined error 
                        eval line 
                        ____ line 
                    error base
                /),
    },
    
    {
        -case   => 'q-fuzz',                    # no backtrace
        -args   => [
                    -quiet          => 1,
                ],
        -fuzz   => words(qw/ 
                    bless
                    lines
                        undefined error 
                    quiet
                    error base
                /),
    },
    
    {
        -case   => 'no-terp',                    # almost interpolate
        -args   => [
                        'My $dog has fleas.',
                    -quiet          => 1,
                ],
        -merge  => [
                        '$mom said: ',
                    -quiet          => 1,
                ],
        -fuzz   => words(qw/ 
                    bless
                    lines
                        undefined error 
                    quiet
                    error base
                /),
    },
    
);

#----------------------------------------------------------------------------#

my $tc          ;
my $base        = 'Error-Base: interpolate: ';
my $diag        = $base;
my @rv          ;
my $got         ;
my $want        ;

#----------------------------------------------------------------------------#

# Extra-verbose dump optional for test script debug.
my $Verbose     = 0;
   $Verbose++;

for (@td) {
    $tc++;
    my $case        = $base . $_->{-case};
    
    note( "---- $case" );
    subtest $case => sub { exck($_) };
}; ## for
    
sub exck {
    my $t           = shift;
    my @args        = eval{ @{ $t->{-args} } };
    my @merge       = eval{ @{ $t->{-merge} } };
    my $die         = $t->{-die};
    my $want        = $t->{-want};
    my $deep        = $t->{-deep};
    my $fuzz        = $t->{-fuzz};
    
    $diag           = 'execute';
    @rv             = eval{ 
        my $err = Error::Base->new(@args); 
           $err->cuss(@merge); 
    };
    pass( $diag );          # test didn't blow up
    note($@) if $@;         # did code under test blow up?
    
    if    ($die) {
        $diag           = 'should throw';
        $got            = $@;
        $want           = $die;
        like( $got, $want, $diag );
    }
    elsif ($want) {
        $diag           = 'return-words';
        $got            = lc join qq{\n}, @rv;
        like( $got, $want, $diag );
    } 
    elsif ($deep) {
        $diag           = 'return-deeply';
        $got            = \@rv;
        $want           = $deep;
        is_deeply( $got, $want, $diag );
    }
    elsif ($fuzz) {
        $diag           = 'return-fuzzily';
        $got            = join qq{\n}, explain \@rv;
        $want           = $fuzz;
        like( $got, $want, $diag );
    }
    else {
        fail('Test script failure: unimplemented gimmick.');
    };

    # Extra-verbose dump optional for test script debug.
    if ( $Verbose >= 1 ) {
        note( 'explain: ', explain \@rv     );
        note( ''                            );
    };
#~     if ( $Verbose >= 1 ) {
#~         note( 'rv: ', join qq{\n}, @rv      );
#~         note( ''                            );
#~     };
    
}; ## subtest

#----------------------------------------------------------------------------#

done_testing($tc);
exit 0;

#============================================================================#

sub words {                         # sloppy match these strings
    my @words   = @_;
    my $regex   = q{};
    
    for (@words) {
        $_      = lc $_;
        $regex  = $regex . $_ . '.*';
    };
    
    return qr/$regex/is;
};



































































