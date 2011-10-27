use 5.008008;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Error::Base',
    license             => 'artistic_2',
    dist_author         => 'Xiong Changnian <xiong@cpan.org>',
    dist_version_from   => 'lib/Error/Base.pm',
    requires            => {
        'perl'                      => 5.008008,
        'version'                   => 0.94,
        'Scalar::Util'              => 0,
        'overload'                  => 0,
#~         ''  => 0,
    },
    recommends          => {
        'Devel::Comments'           => '1.1.4',
    },
    build_requires      => {
        'Test::More'                => 0.94,
    },
    add_to_cleanup      => [ 'Error-Base-*' ],
    meta_merge          => {
        resources           => {
            repository          => 'http://github.com/Xiong/error-base',
        },
        keywords            => [ qw(
            devel       development 
            
            error       errors
            exception   exceptions
            
            OO  object-oriented class object method
            
            carp    croak 
            
        ) ],
    },
);

$builder->create_build_script();
