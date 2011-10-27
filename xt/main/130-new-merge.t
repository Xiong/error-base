use strict;
use warnings;

use Test::More;

use Error::Base;
my $QRTRUE       = $Error::Base::QRTRUE    ;
my $QRFALSE      = $Error::Base::QRFALSE   ;

#----------------------------------------------------------------------------#

my @td  = (
    {
        -case   => 'merge-only',         # stringified normal return
        -merge  => [ zig => 'zag' ],
        -want   => words(qw/ 
                    undefined error 
                    eval line new 
                    ____ line new 
                /),
    },
    
    {
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
        -case   => 'text-fuzz',         # emit error text
        -args   => [ 'Foobar error', foo => 'bar' ],
        -merge  => [ zig => 'zag' ],
        -fuzz   => words(qw/ 
                    bless 
                        lines foobar error
                    zig zag
                    error base
                /),
    },
    
    {
        -case   => 'text-named-fuzz',         # emit error text, named arg
        -args   => [ -text => 'Foobar error ', foo => 'bar' ],
        -merge  => [ zig => 'zag' ],
        -fuzz   => words(qw/ 
                    bless 
                        lines foobar error
                    zig zag
                    error base
                /),
    },
    
    {
        -case   => 'text-both-fuzz',    # emit error text, both ways
        -args   => [ 'Bazfaz: ', -text => 'Foobar error ', foo => 'bar' ],
        -merge  => [ zig => 'zag' ],
        -fuzz   => words(qw/ 
                    bless 
                        lines foobar error bazfaz in
                    zig zag
                    error base
                /),
    },
    
    {
        -case   => 'text-both',         # emit error text, stringified normal
        -args   => [ 'Bazfaz: ', -text => 'Foobar error ', foo => 'bar' ],
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
                    'Bazfaz: ',
                    -text   => 'Foobar error ', 
                    foo     => 'bar', 
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
        -case   => 'quiet',             # emit error text, no backtrace
        -args   => [ 
                    'Bazfaz: ',
                    -quiet  => 1, 
                    -text   => 'Foobar error ', 
                    foo     => 'bar', 
                ],
        -merge  => [                     
                    -quiet  => 1, 
                    zig => 'zag', 
                ],
        -want   => words(qw/
                    foobar error bazfaz
                /),
    },
    
    {
        -case   => 'quiet-fuzz',        # verify no backtrace
        -args   => [ 
                    'Bazfaz: ',
                    -text   => 'Foobar error ', 
                    foo     => 'bar', 
                ],
        -merge  => [                     
                    -quiet  => 1, 
                    zig => 'zag', 
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
my $base        = 'Error-Base: new-merge: ';
my $diag        = $base;
my @rv          ;
my $got         ;
my $want        ;

#----------------------------------------------------------------------------#

# Extra-verbose dump optional for test script debug.
my $Verbose     = 0;
#~    $Verbose++;

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
        my $self        = Error::Base->new(@args);
        $self->cuss(@merge);
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



































































