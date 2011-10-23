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
#~         'parent'                    => 0,
        'Carp'                      => 0,
#~         'Cwd'                       => 0,
#~         'Data::Dumper'              => 0,
#~         'Data::Lock'                => 0,
#~         'File::Spec'                => 0,
#~         'File::Spec::Functions'     => 0,
#~         'IO::File'                  => 0,
#~         'List::MoreUtils'           => 0,
#~         'POSIX'                     => 0,
#~         'Scalar::Util'              => 0,
#~         'Scalar::Util::Reftype'     => 0,
#~         'Test::Builder2::Tester'    => 2.00_07,
#~         'Test::Deep'                => 0,
        'Test::More'                => 0.94,
        'Test::Trap'                => 0,
#~         ''  => 0,
    },
    recommends          => {
        'Devel::Comments'           => '1.1.4',
    },
#~     build_requires      => {
#~         'Acme::Teddy'               => 1.002003,
#~     },
    add_to_cleanup      => [ 'Path-Finder-*' ],
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
