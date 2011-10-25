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


my @td  = (
    {
        -case   => 'null',
        -want   => words(qw/ undefined error eval line cuss __ line cuss /),
    },
    
    {
        -case   => 'null-deep',
        -fuzz   => words(qw/ 
                    bless 
                    frames 
                        eval undef file cuss line package main sub eval
                        bottom sub ___ 
                    lines
                        undefined error
                    error base
                /),
    },
    
#~     {
#~         -case   => 'two',
#~         -args   => [ 0, 1 ],
#~     },
#~     
#~     {
#~         -case   => 'three',
#~         -args   => [ qw/ a b c / ],
#~         -die    => words(qw/ internal error unpaired /),
#~     },
#~     
#~     {
#~         -case   => 'four',
#~         -args   => [ qw/ a b c d / ],
#~     },
    
);

#----------------------------------------------------------------------------#

my $tc          ;
my $base        = 'Error-Base: cuss(): ';
my $diag        = $base;
my @rv          ;
my $got         ;
my $want        ;

#----------------------------------------------------------------------------#

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
    @rv             = eval{ 
        Error::Base->cuss(@args); 
    };
    pass( $diag );          # test didn't blow up
    note($@);               # did code under text blow up?
    
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
        is_deeeply( $got, $want, $diag );
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
    if ($Verbose) {
        note( 'got: ', $got                 );
        note( ''                            );
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



































































