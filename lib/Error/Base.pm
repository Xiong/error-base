package Error::Base;
#=========# MODULE USAGE
#~ use Error::Base;               # Simple structured errors with full backtrace
#~ 

use 5.008008;
use strict;
use warnings;
use version 0.94; our $VERSION = qv('0.0.0');

# Core modules
#~ use File::Spec;                 # Portably perform operations on file names
#~ use Scalar::Util;               # General-utility scalar subroutines
#~ use ExtUtils::Installed;        # Inventory management of installed modules

# CPAN modules
#~ use Data::Lock qw( dlock );     # Declare locked scalars
#~ use File::HomeDir;              # Find your home... on any platform


#~ use Scalar::Util::Reftype;      # Alternate reftype() interface


## use

# Alternate uses
use Devel::Comments '#####', ({ -file => 'debug.log' });

#============================================================================#

# Pseudo-globals

# Compiled regexes
our $QRFALSE      = qr/\A0?\z/            ;
our $QRTRUE       = qr/\A(?!$QRFALSE)/    ;

#----------------------------------------------------------------------------#


#=========# OBJECT METHOD
#
#    crash( @lines );                # fatal out with @lines message
#    $err->crash( @lines );          # OO interface
#    $err->crash( $errkey );         # fatal out with value of $errkey
#    $err->crash( $errkey, @lines ); # fatal out with additional @lines
#
# Purpose   : Fatal out of internal errors
# Parms     : $errkey   : string    : must begin with '_' (underbar)
#             @lines    : strings   : free text
# Reads     : $err->{$errkey}
# Returns   : never
# Throws    : always die()-s
# See also  : paired(), crank()
# 
# The first arg is tested to see if it's a reference and if so, shifted off.
# Then the next test is to see if the second (now first) arg is an errkey.
# If not, then all args are considered @lines of text.
#   
sub crash {
    # Don't shift off the 0th parm; we don't know what it is.
    my @lines           ;
    my $text            ;
    my $unimplemented   = 'Unimplemented error.';
    ##### @_
    
    @lines              = _unfold_errors(@_);
    if ( not @lines ) { @lines = $unimplemented };
    
    # Stack backtrace.
    my $call_pkg        = 0;
    my $call_sub        = 3;
    my $call_line       = 2;
    for my $frame (1..3) {
        my @caller_ary  = caller($frame);
        push @lines,      $caller_ary[$call_pkg] . ( q{ } x 4 )
                        . $caller_ary[$call_sub] . q{() line }
                        . $caller_ary[$call_line]
                        ;
    };
    
    my $prepend     = __PACKAGE__;      # prepend to all errors
       $prepend     = join q{}, q{# }, $prepend, q{: };
    my $indent      = qq{\n} . q{ } x length $prepend;
    
    # Expand error.
    $text           = $prepend . join $indent, @lines;
    $text           = $text . $indent;      # before croak()'s trace
    
    # now croak()
    croak $text;
    return 0;                   # should never get here, though
}; ## crash

sub foobar{'foobar', 'bazbaz'};

#=========# INTERNAL ROUTINE
#
#   @lines  = _unfold_errors(@args);     # get error text
#       
# Purpose   : For each element recursively, get error text.
# Parms     : ____
# Reads     : ____
# Returns   : ____
# Writes    : ____
# Throws    : ____
# See also  : ____
# 
# ____
# 
sub _unfold_errors {
    my $self        ;       # don't just shift: check first
    my @lines       ;       # accumulate output
    ##### @_
    for (@_) {
        # Is arg in this class or a subclass of it?
        #   isa() will throw if called on an unblessed ref.
        if    ( eval{ $_->isa (__PACKAGE__) } ) {
            $self       = $_;
        } 
        elsif ( ref $_ eq 'HASH' ) {
            $self       = $_;
        } 
        elsif ( 0 ) {
            
        } 
        elsif ( 0 ) {
            
        } 
        elsif ( ref $_ eq 'ARRAY' ) {
            push @lines, _unfold_errors(@$_);
        } 
        elsif ( $_ =~ /^_/ ) {      # leading underbar: an $errkey was passed
            my $errkey      = $_;
            push @lines, $errkey;
            # find and expand error if possible
            if ( $self and ( defined $self->{$errkey} ) ) {
                push @lines, _unfold_errors( $self, $self->{$errkey} );
            };
        } 
        else {  # not a ref or errkey
            push @lines, $_;            
        };
    }; ## for @_
    
    return @lines;
}; ## _unfold_errors

#~     #=========# EXTERNAL FUNCTION
#~     #
#~     #   my %args    = paired(@_);     # check for unpaired arguments
#~     #       
#~     # Purpose   : ____
#~     # Parms     : ____
#~     # Reads     : ____
#~     # Returns   : ____
#~     # Writes    : ____
#~     # Throws    : ____
#~     # See also  : ____
#~     # 
#~     # ____
#~     #   
#~     sub paired {
#~         if ( scalar @_ % 2 ) {  # an odd number modulo 2 is one: true
#~         my $paired_error    = $err->{_unpaired};
#~         ##### $paired_error
#~             crash( $err->{_unpaired} );
#~         };
#~         return @_;
#~     }; ## paired

#=========# CLASS METHOD
#
#   my $obj     = $class->new();
#   my $obj     = $class->new({ -a  => 'x' });
#       
# Purpose   : Object constructor
# Parms     : $class    : Any subclass of this class
#             anything else will be passed to init()
# Returns   : $self
# Invokes   : init()
# 
# If invoked with $class only, blesses and returns an empty hashref. 
# If invoked with $class and a hashref, blesses and returns it. 
# Note that you can't skip passing the hashref if you mean to init() it. 
# 
sub new {
    my $class   = shift;
    my $self    = {};           # always hashref
    
    bless ($self => $class);
    $self->init(@_);            # init remaining args
    
    return $self;
}; ## new

#=========# OBJECT METHOD
#   $pf->init( '-key' => $value, '-foo' => $bar );
#
# Error::Base::init() gets all paths for later delivery. 
#
sub init {
    my $self    = shift;
    my @args    = paired(@_);
    
    $self->_get_all_paths(@args);
    
    return $self;
}; ## init



## END MODULE
1;
#============================================================================#
__END__

=head1 NAME

Error::Base - Simple structured errors with full backtrace

=head1 VERSION

This document describes Error::Base version 0.0.0

=head1 SYNOPSIS

    # in My::Module
    use Error::Base;
    my $err_foo         = Error::Base->new();
    
    __END__

=head1 DESCRIPTION

=over

I<J'avais cru plus difficile de mourir.> 
-- Louis XIV

=back

Die early, die often. Make frequent sanity checks and raise a fatal exception 
as soon as a check fails. 

=head1 INTERFACE 

=head1 INSTALLATION


=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back

=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.

Error::Base requires no configuration files or environment variables.

=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.

=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.

=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.


Please report any bugs or feature requests to
C<bug-path-finder@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

Xiong Changnian  C<< <xiong@cpan.org> >>

=head1 LICENSE

Copyright (C) 2011 Xiong Changnian C<< <xiong@cpan.org> >>

This library and its contents are released under Artistic License 2.0:

L<http://www.opensource.org/licenses/artistic-license-2.0.php>

=cut
