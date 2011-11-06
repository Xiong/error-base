use strict;
use warnings;

use Test::More;

use Error::Base;
my $QRTRUE       = $Error::Base::QRTRUE    ;
my $QRFALSE      = $Error::Base::QRFALSE   ;

my $tc          ;
my $base        = 'Error-Base: synopsis-intro: ';
my $diag        = $base;

#----------------------------------------------------------------------------#
# SKIP OPTIONAL TEST

# Load non-core modules conditionally
BEGIN{
    eval{
        require Test::Trap;         # Block eval on steroids
        Test::Trap->import (qw/ :default /);
    };
    $::module_loaded    = !$@;          # loaded if no error
                                            #   must be package variable
                                            #       to escape BEGIN block
}; ## BEGIN

$tc++;
$diag   = $base . 'load-test-trap';
pass($diag);
if ( not $::module_loaded ) {
    note('Test::Trap (recommended) required to execute this test script.');
    exit 0;
};

#----------------------------------------------------------------------------#

my @td  = (
    {
        -case   => 'sanity',
        -code   => sub{
            Error::Base->crash('Sanity check failed');  # die() with backtrace
        },
        -lby    => 'die',
        -want   => words(qw/ 
                    sanity check failed 
                    in main at line 
                    in eval at line 
                    ____    at line
                /),
    },
    
    {
        -end    => 1,   # # # # # # # END TESTING HERE # # # # # # # # # 
        -case   => 'merge-only-fuzz',         
        -merge  => [ zig => 'zag' ],
        -fuzz   => words(qw/ 
                    bless 
                    frames 
                        eval undef file new line package main sub eval
                        bottom sub ___ 
                    lines
                        undefined error
                    zig zag
                    error base
                /),
    },
    
    {
        -case   => 'zig-zag-fuzz',      # merge at crash
        -args   => [ foo => 'bar' ],
        -merge  => [ zig => 'zag' ],
        -fuzz   => words(qw/ 
                    bless 
                        foo bar
                        zig zag
                    error base
                /),
    },
    
    {
        -case   => 'pronto-fuzz',         # emit error text pronto
        -args   => [ 'Foobar error', foo => 'bar' ],
        -merge  => [ zig => 'zag' ],
        -fuzz   => words(qw/ 
                    bless 
                    lines 
                        foobar error
                    foo bar
                    zig zag
                    error base
                /),
    },
    
    {
        -case   => 'base-fuzz',         # emit base error text
        -args   => [ -base => 'Foobar error ', foo => 'bar' ],
        -merge  => [ zig => 'zag' ],
        -fuzz   => words(qw/ 
                    bless 
                    lines 
                        foobar error
                    foo bar
                    zig zag
                    error base
                /),
    },
    
    {
        -case   => 'base-pronto-fuzz',    # emit error text, both ways
        -args   => [ 
                    'Bazfaz', 
                    -base   => 'Foobar error', 
                    foo     => 'bar' 
                ],
        -merge  => [ zig => 'zag' ],
        -fuzz   => words(qw/ 
                    bless 
                        lines foobar error bazfaz in
                    zig zag
                    error base
                /),
    },
    
    {
        -case   => 'base-pronto-stringy',   # both ways stringified
        -args   => [ 
                    'Bazfaz', 
                    -base   => 'Foobar error', 
                    foo     => 'bar' 
                ],
        -merge  => [ zig => 'zag' ],
        -want   => words(qw/ 
                    foobar error bazfaz
                    eval line new 
                    ____ line new
                /),
    },
    
    {
        -case   => 'top-0-fuzz',        # mess with -top
        -args   => [ 
                    'Bazfaz', 
                    -base   => 'Foobar error', 
                    foo     => 'bar' 
                ],
        -merge  => [ -top => 0 ],
        -fuzz   => words(qw/ 
                    lines
                        foobar error bazfaz
                        error base fuss lib error base
                        error base cuss lib error base
                    eval line new 
                    exck line new
                    top 0
                    foo bar
                /),
    },
    
    {
        -case   => 'quiet-new-stringy',   # no backtrace in new - exact
        -args   => [ 
                    'ccc', 
                    -base   => 'aaa', 
                    -quiet  => 1, 
                    foo     => 'bar' 
                ],
        -merge  => [                     
                    zig => 'zag', 
                ],
        -want   => qr/aaa ccc$/,
    },
    
    {
        -case   => 'quiet-cuss-stringy',   # no backtrace in cuss - exact
        -args   => [ 
                    'ccc', 
                    -base   => 'aaa', 
                    foo     => 'bar' 
                ],
        -merge  => [                     
                    -quiet  => 1, 
                    zig => 'zag', 
                ],
        -want   => qr/aaa ccc$/,
    },
    
    {
        -case   => 'new quiet, cuss loud',   # should backtrace
        -args   => [ 
                    'ccc', 
                    -base   => 'aaa', 
                    -quiet  => 1, 
                    foo     => 'bar' 
                ],
        -merge  => [                     
                    -quiet  => 0, 
                    zig => 'zag', 
                ],
        -want   => words(qw/ 
                    aaa ccc
                    eval line merge
                    ____ line merge
                /),
    },
    
    
);

#----------------------------------------------------------------------------#

my @rv          ;
my $got         ;
my $want        ;

#----------------------------------------------------------------------------#

# Extra-verbose dump optional for test script debug.
my $Verbose     = 0;
   $Verbose++;

for (@td) {
    last if $_->{-end};
    $tc++;
    my $case        = $base . $_->{-case};   
    note( "---- $case" );
    subtest $case => sub { exck($_) };
}; ## for
    
sub exck {
    my $t           = shift;
    my $code        = $t->{-code};
    my $leaveby     = $t->{-lby};
    my $want        = $t->{-want};
    
    $diag           = 'execute';
    @rv             = trap{ 
        &$code;
    };
    pass( $diag );          # test didn't blow up
    
    if    ( $leaveby eq 'die' ) {
        $diag           = 'should-die';
        $trap->did_die      ( $diag );
        $diag           = 'die-like';
        $trap->die_like     ( $want, $diag );       # fail if !die
        $diag           = 'die-quiet';
        $trap->quiet        ( $diag );
    }
    elsif ( $leaveby eq 'return-scalar' ) {
        $diag           = 'should-return';
        $trap->did_return   ( $diag );
        $diag           = 'return-like';
        $trap->return_like  ( 0, $want, $diag );    # always returns aryref
        $diag           = 'return-quiet';
        $trap->quiet        ( $diag );
    } 
#~     elsif ($deep) {
#~         $diag           = 'return-deeply';
#~         $got            = \@rv;
#~         $want           = $deep;
#~         is_deeply( $got, $want, $diag );
#~     }
#~     elsif ($fuzz) {
#~         $diag           = 'return-fuzzily';
#~         $got            = join qq{\n}, explain \@rv;
#~         $want           = $fuzz;
#~         like( $got, $want, $diag );
#~     }
    else {
        fail('Test script failure: unimplemented gimmick.');
    };

    # Extra-verbose dump optional for test script debug.
    if ( $Verbose >= 1 ) {
        $trap->diag_all;
        note( ''                            );
    };
    
}; ## subtest

#----------------------------------------------------------------------------#

END {
    done_testing($tc);
    exit 0;
}

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

