package Error::Base;
#=========# MODULE USAGE
#~ use Error::Base;               # Simple structured errors with full backtrace
#~ 

use 5.008008;
use strict;
use warnings;
use version 0.94; our $VERSION = qv('0.0.0');

# Core modules
use overload                    # Overload Perl operations
    '""'    => \&_stringify,
    ;


#~ use File::Spec;                 # Portably perform operations on file names
#~ use Scalar::Util;               # General-utility scalar subroutines
#~ use ExtUtils::Installed;        # Inventory management of installed modules

# CPAN modules
#~ use Data::Lock qw( dlock );     # Declare locked scalars
#~ use File::HomeDir;              # Find your home... on any platform


#~ use Scalar::Util::Reftype;      # Alternate reftype() interface


## use

# Alternate uses
#~ use Devel::Comments '#####', ({ -file => 'debug.log' });

#============================================================================#

# Pseudo-globals

# Compiled regexes
our $QRFALSE      = qr/\A0?\z/            ;
our $QRTRUE       = qr/\A(?!$QRFALSE)/    ;

#----------------------------------------------------------------------------#

#=========# OPERATOR OVERLOADING
#
#   _stringify();     # short
#       
# Purpose   : Overloads stringification.
# Parms     : ____
# Reads     : ____
# Returns   : ____
# Writes    : ____
# Throws    : ____
# See also  : ____
# 
# ____
# 
sub _stringify {
#   my ($self, $other, $swap) = @_;
    my ($self, undef,  undef) = @_;
    
#~     no warnings 'uninitialized';
    return join qq{\n}, @{ $self->{-lines} }, q{};
}; ## _stringify

#=========# INTERNAL ROUTINE
#
#    @lines      = _trace(               # dump full backtrace
#                    -top      => 2,     # starting stack frame
#                );
#       
# Purpose   : Full backtrace dump.
# Parms     : ____
# Returns   : ____
# Throws    : ____
# See also  : ____
# 
# ____
# 
sub _trace {
    my %args        = _paired(@_);
    my $i           = $args{-top}       || 1;
    
    my $bottomed    ;
    my @maxlen      = ( 1, 1, 1 );  # starting length of each field
    
    my @f           = (             # order in which keys will be dumped
        '-sub',
        '-line',
        '-file',
    );
    my $pad         = q{ };         # padding for better formatting
    my $in          ;               # usually 'in '
    
    my @frames      ;               # unformatted AoA
    my @lines       ;               # formatted ary of strings
    
    # Get each stack frame.
    while ( not $bottomed ) {
        my $frame           ;
        
        # Get info for current frame.
        ( 
            $frame->{-package}, 
            $frame->{-file}, 
            $frame->{-line}, 
            undef, 
            undef, 
            undef, 
            $frame->{-eval} 
        )                   = caller( $i );
        
        # caller returns this from the "wrong" viewpoint
        ( 
            undef, 
            undef, 
            undef, 
            $frame->{-sub}, 
            undef, 
            undef, 
            undef, 
        )                   = caller( $i + 1 );
        
        # Normal exit from while loop.
        if ( not $frame->{-package} ) {
            $bottomed++;
            last;
        };
        
        # Clean up bottom frame.
        if ( not $frame->{-sub} ) {
            $frame->{-sub}      = q{};
            $frame->{-bottom}   = 1;
        };
        
        # Get maximum length of each field.
        for my $fc ( 0..$#f ) {
            $maxlen[$fc]    = $maxlen[$fc] > length $frame->{$f[$fc]}
                            ? $maxlen[$fc]
                            : length $frame->{$f[$fc]}
                            ;
        };
        
        # Clean up any eval text.
        if ($frame->{-eval}) {
            # fake newlines for hard newlines
            $frame->{-eval}     =~ s/\n/\\n/g;
        };
        push @frames, $frame;
        
        # Safety exit from while loop.
        $i++;
        die 'Error::Base internal error: excessive backtrace', $!
            if $i > 99;
#~ last if $i > 9;                                                 # DEBUG ONLY
        
    }; ## while not bottomed
    
    # Format each stack frame. 
    for my $frame (@frames) {
        
        # Pad each field to maximum length (found in while)
        for my $fc ( 0..$#f ) {
            my $diff            = $maxlen[$fc] - length $frame->{$f[$fc]};
            $frame->{$f[$fc]}   = $frame->{$f[$fc]} . ($pad x $diff);
        };
        
        # Fix up bottom.
        if ( $frame->{-bottom} ) {
            $frame->{-sub} =~ s/ /_/g;      # all underbars
            $in         = q{___};           # *THREE* underbars
        }
        else {
            $in         = q{in };           # a three-char string
        };
        
        # Format printable line.
        my $line    = qq*$in$frame->{-sub} at line $frame->{-line}*
                    . qq*    [$frame->{-file}]*
                    ;
        
        # Append any eval text.
        if ($frame->{-eval}) {
            # hard newlines so number of frames doesn't change
            $line           = $line
                            . qq{\n}
                            . qq*    string eval: "$frame->{-eval}"*
                            . qq{\n}
                            ;
        };
        
        push @lines, $line;
    }; ## for each frame
    
    return @lines;
}; ## _trace

#=========# INTERNAL METHOD
#
#   $self->_merge(@_);     # short
#       
# Purpose   : Merge new args with current contents.
# Parms     : ____
# Reads     : ____
# Returns   : ____
# Writes    : ____
# Throws    : ____
# See also  : ____
# 
# ____
# 
sub _merge {
    my $self        = shift;
    %{$self}        = ( %{$self}, @_ );
    
    return $self;
}; ## _merge

#=========# CLASS OR OBJECT METHOD
#
#    Error::Base->crash( $text );    # class method; error text required
#    $err->crash;                    # object method
#    $err->crash( $text );           # object method; error text optional
#    $err->crash( -text => $text );  # named argument okay
#    $err->crash( -key  => '42'  );  # expand into -text
#    $err->crash( -foo  => 'bar' );  # set Error::Base options now
#    $err->crash( mybit => 'baz' );  # set your private stuff now
#
# Purpose   : Fatal out of internal errors
# Parms     : $text   : string    : text of error message
# Returns   : never
# Throws    : always die()-s
# See also  : _fuss(), crank(), cuss()
# 
# The first arg is tested to see if it's a class or object reference.
# Then the next test is to see if an odd number of args remain.
#   If so, then the next arg is shifted off and considered -text.
# All remaining args are considered key/value pairs and passed to new().
#   
sub crash{
    my $self    = _fuss(@_);
    
    die $self;
}; ## crash

#=========# INTERNAL FUNCTION
#
# This does all the work for crash(), crank(), and cuss().
# See crash() for more info.
#
sub _fuss {
    my $self        = shift;
    if ( Scalar::Util::blessed $self ) {        # called on existing object
        $self->_merge(@_);
    } 
    else {                                      # called as class method
        $self       = $self->new(@_);
    };
    
    # Expand one of some stored texts.
    if ( defined $self->{-key} ) {
        $self->{-text}  = $self->{-text} . $self->{ $self->{-key} };
    };
    
    # Optionally prepend some stuff.
    my $prepend     = q{};                      # prepended to first line
    my $indent      = q{};                      # prepended to all others
    
    if    ( defined $self->{-prepend} ) {
        $prepend        = $self->{-prepend};
    };
    
    if    ( defined $self->{-indent} ) {
        $indent         = $self->{-indent};
    };
    
    if    ( defined $self->{-prepend_all} ) {
        $prepend        = $self->{-prepend_all};
        $indent         = $prepend;
    }
    elsif ( $prepend and !$indent ) {           # construct $indent
        $indent         = ( substr $prepend, 0, 1           )
                        . ( q{ } x ((length $prepend) - 1)  )
                        ;
    }; 
    
    # First line is basic error text.
    my $text        = $prepend . $self->{-text};
    my @temp        = split /\n/, $text;         # in case it's multi-line
    my $infix       = qq{\n} . $indent;
    $text           = join $infix, @temp;    
    push @{ $self->{-lines} }, $text;
    
    # Stack backtrace by default.
    if ( not $self->{-quiet} ) {
        my @trace       = _trace( -top => $self->{-top} );
        push @{ $self->{-lines} }, map { $indent . $_ } @trace;
    };
    
    ##### $self
    return $self;
}; ## _fuss

#=========# CLASS OR OBJECT METHOD
#
# Just like crash() except it warn()-s and does not die().
# See crash() for more info.
sub crank{
    my $self    = _fuss(@_);
    
    warn $self;
}; ## crank

#=========# CLASS OR OBJECT METHOD
#
# Just like crash() except it just returns $self (after expansion).
# See crash() for more info.
sub cuss{
    my $self    = _fuss(@_);
    
    return $self;
}; ## crank




# TODO: REMOVE - DEBUG ONLY
sub _test_trace { main::B() };


=for scrap
    
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

=cut


#=========# INTERNAL FUNCTION
#
#   my %args    = _paired(@_);     # check for unpaired arguments
#       
# Purpose   : ____
# Parms     : ____
# Reads     : ____
# Returns   : ____
# Writes    : ____
# Throws    : ____
# See also  : ____
# 
# ____
#   
sub _paired {
    if ( scalar @_ % 2 ) {  # an odd number modulo 2 is one: true
        die 'Error::Base internal error: unpaired args', $!;
    };
    return @_;
}; ## _paired

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
#
#   $err->init(        '-key' => $value, '-foo' => $bar );
#   $err->init( $text, '-key' => $value, '-foo' => $bar );
#
#
sub init {
    my $self        = shift;
    my $xtext       ;
    if ( scalar @_ % 2 ) {          # an odd number modulo 2 is one: true
        $xtext          = shift;    # and now it's even
    }
    else {
        $xtext          = q{};      # avoid undef warning
    };
    
    %{$self}        = @_;
    
    # Set some default values.
    no warnings 'uninitialized';
    $self->{-text}  = ( $self->{-text} . $xtext ) || 'Undefined error';
    $self->{-top}   = $self->{-top} || 2;
    
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

    use Error::Base;
    Error::Base->crash('Sanity check failed');  # die() with backtrace
    
    my $err     = Error::Base->new('Foo');      # construct object first
        yourcodehere(...);          # ... do other stuff
    $err->crash;
    
    my $err     = Error::Base->new(
                    'Foo error',                # args start with text
                    -quiet    => 1,             # no backtrace
                    grink     => 'grunt',       # store somethings
                    puppy     => 'dog',         # your keys, no leading dash 
                );
    $err->crash;
    
    $err->crank;            # get cranky: warn() but don't die()
    my $err = Error::Base->crank('Me!');   # also a constructor
    
    eval{ Error::Base->crash( 'car', -foo => 'bar' ) }; 
    my $err     = $@ if $@;     # catch and examine the object
    

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

=head1 THANKS

Grateful acknowledgement deserved by AMBRUS for coherent API suggestions. 
Any failure to grasp them is mine. 

=head1 AUTHOR

Xiong Changnian  C<< <xiong@cpan.org> >>

=head1 LICENSE

Copyright (C) 2011 Xiong Changnian C<< <xiong@cpan.org> >>

This library and its contents are released under Artistic License 2.0:

L<http://www.opensource.org/licenses/artistic-license-2.0.php>

=cut
