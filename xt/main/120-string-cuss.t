use strict;
use warnings;

use Test::More;

use Error::Base;
my $QRTRUE       = $Error::Base::QRTRUE    ;
my $QRFALSE      = $Error::Base::QRFALSE   ;

#----------------------------------------------------------------------------#

# Extra-verbose dump optional for test script debug.
my $Verbose     = 0;
#~ my $Verbose     = 1;
#~ my $Verbose     = 2;


my @td  = (
    {
        -case   => 'null',              # stringified normal return
        -want   => words(qw/ 
                    undefined error 
                        throw line cuss 
                        eval line eval
                        __ line cuss 
                        string eval throw
                /),
    },
    
    {
        -case   => 'null-deep',         
        -fuzz   => words(qw/ 
                    bless 
                    frames 
                        sub throw 
                        eval line eval
                        bottom eval throw sub __ 
                    lines
                        undefined error
                        string eval
                    error base
                /),
    },
    
    {
        -case   => 'foo-deep',          # preserve private attribute
        -args   => [ foo => 'bar' ],
        -fuzz   => words(qw/ 
                    bless 
                        foo bar
                    error base
                /),
    },
    
    {
        -case   => 'text-deep',         # emit error text
        -args   => [ 'Foobar error', foo => 'bar' ],
        -fuzz   => words(qw/ 
                    bless 
                        lines foobar error
                    error base
                /),
    },
    
    {
        -case   => 'text-deep',         # emit error text, named arg
        -args   => [ -text => 'Foobar error ', foo => 'bar' ],
        -fuzz   => words(qw/ 
                    bless 
                        lines foobar error
                    error base
                /),
    },
    
    {
        -case   => 'text-both-deep',    # emit error text, both ways
        -args   => [ 'Bazfaz: ', -text => 'Foobar error ', foo => 'bar' ],
        -fuzz   => words(qw/ 
                    bless 
                        lines foobar error bazfaz in
                    error base
                /),
    },
    
    {
        -case   => 'text-both',         # emit error text, stringified normal
        -args   => [ 'Bazfaz: ', -text => 'Foobar error ', foo => 'bar' ],
        -want   => words(qw/ 
                    foobar error bazfaz
                    eval line eval
                    __ line cuss
                        string eval throw
                /),
    },
    
    {
        -case   => 'top-0-deep',        # mess with -top
        -args   => [ 
                    'Bazfaz: ',
                    -top    => 0, 
                    -text   => 'Foobar error ', 
                    foo     => 'bar', 
                ],
        -fuzz   => words(qw/ 
                    lines
                        foobar error bazfaz
                        error base cuss lib error base
                        throw line cuss
                        eval line eval
                        __ line cuss
                            string eval throw
                    top 0
                    foo bar
                /),
    },
    
    {
        -case   => 'quiet',             # emit error text, no backtrace
        -args   => [ 
                    'Bazfaz: ',
                    -quiet  => 1, 
                    -text   => 'Foobar error ', 
                    foo     => 'bar', 
                ],
        -want   => words(qw/
                    foobar error bazfaz
                /),
    },
    
    {
        -case   => 'quiet-deep',        # verify no backtrace
        -args   => [ 
                    'Bazfaz: ',
                    -quiet  => 1, 
                    -text   => 'Foobar error ', 
                    foo     => 'bar', 
                ],
        -fuzz   => words(qw/ 
                    lines
                        foobar error bazfaz
                    quiet
                /),
    },
    
    
);

#----------------------------------------------------------------------------#

my $tc          ;
my $base        = 'Error-Base: cuss(): ';
my $diag        = $base;
my @rv          ;
my $got         ;
my $want        ;

#----------------------------------------------------------------------------#
sub throw {
    my @args    = @_;
#~     note( explain \@args );          # TEST DEBUG ONLY
    return Error::Base->cuss(@args);
};

for (@td) {
    
    my %t           = %{ $_ };
    my $case        = $base . $t{-case} . q{|};
    my @args        = eval{ @{ $t{-args} } };
    my $die         = $t{-die};
    my $want        = $t{-want};
    my $deep        = $t{-deep};
    my $fuzz        = $t{-fuzz};
    
    $tc++;
    $diag           = $case . 'execute';
    @rv             = eval '    throw(@args);    ';     # string eval
#~     @rv             = eval "    throw(@args);    ";     # string eval
#~     @rv             = eval {    throw(@args);    };     # block eval
    pass( $diag );          # test didn't blow up
    note($@) if $@;         # did code under test blow up?
    
    $tc++;
    if    ($die) {
        $diag           = $case . 'should throw';
        $got            = $@;
        $want           = $die;
        like( $got, $want, $diag );
    }
    elsif ($want) {
        $diag           = $case . 'return-words';
        $got            = lc join qq{\n}, @rv;
        like( $got, $want, $diag );
    } 
    elsif ($deep) {
        $diag           = $case . 'return-deeply';
        $got            = \@rv;
        $want           = $deep;
        is_deeply( $got, $want, $diag );
    }
    elsif ($fuzz) {
        $diag           = $case . 'return-fuzzily';
        $got            = join qq{\n}, explain \@rv;
        $want           = $fuzz;
        like( $got, $want, $diag );
    }
    else {
        fail('Test script failure: unimplemented gimmick.');
    };
    
    # Extra-verbose dump optional for test script debug.
    if ( $Verbose >= 1 ) {
        note( 'got: ', $got                 );
        note( ''                            );
    };
    if ( $Verbose >= 2 ) {
        note( 'explain: ', explain \@rv     );
        note( ''                            );
    };
};

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



































































