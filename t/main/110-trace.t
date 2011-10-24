use strict;
use warnings;

use Test::More;

use Error::Base;
my $QRTRUE       = $Error::Base::QRTRUE    ;
my $QRFALSE      = $Error::Base::QRFALSE   ;

#----------------------------------------------------------------------------#

my @td  = (
    {
        -case   => 'null',
        -want   => words(qw/ line /),
    },
    
#~     {
#~         -case   => 'one',
#~         -args   => [ 0 ],
#~         -die    => words(qw/ internal error unpaired /),
#~     },
#~     
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
my $base        = 'Error-Base: _trace(): ';
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
    
    $tc++;
    $diag           = $case . 'execute';
    @rv             = eval{ Error::Base::_trace(@args) };
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
        $diag           = $case . 'return';
        $got            = join qq{\n}, @rv;
        like( $got, $want, $diag );
    } 
    else {
        $diag           = $case . 'return';
        $got            = join qq{\n}, @rv;
        $want           = join qq{\n}, @args;
        is( $got, $want, $diag );
    };
    note($got);
    note('');
    
};

#----------------------------------------------------------------------------#

done_testing($tc);
exit 0;

#============================================================================#

sub words {                         # sloppy match these strings
    my @words   = @_;
    my $regex   = q{};
    
    for (@words) {
        $regex  = $regex . $_ . '.*';
    };
    
    return qr/$regex/is;
};



































































