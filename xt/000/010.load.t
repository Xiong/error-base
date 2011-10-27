use Test::More tests => 1;

BEGIN {
    $SIG{__DIE__}   = sub {
        warn @_;
        BAIL_OUT( q[Couldn't use module; can't continue.] );    
        
    };
}   

BEGIN {
use Error::Base;               # Find, install property-support-config files
    
}

pass( 'Load modules.' );
diag( "Testing Error::Base $Error::Base::VERSION" );
