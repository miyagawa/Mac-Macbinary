package Mac::Macbinary;

use strict;
use vars qw($VERSION $AUTOLOAD);
$VERSION = '0.01';

use Carp;

use constant HEADER_SIZE	=> 128;

sub new {
    my ($class, $thingy) = @_;
    my $self = bless { }, $class;

    my $fh = _make_handle($thingy);
    $self->_parse_handle($fh);
    return $self;
}

sub _parse_handle {
    my $self = shift;
    my ($fh) = @_;

    read $fh, my ($header), HEADER_SIZE;
    $self->{header} = Mac::Macbinary::Header->new($header);
    read $fh, $self->{data}, $self->header->dflen;
    read $fh, $self->{resource}, $self->header->rflen;

    return $self;
}

sub _make_handle($) {
    my $thingy = shift;
    
    if (-f $thingy && ! ref($thingy)) {
	require FileHandle;
	my $fh = FileHandle->new($thingy) or Carp::croak "$thingy: $!";
	return $fh;
    } else {
	return $thingy;
    }
}	

sub AUTOLOAD {
    my $self = shift;
    $AUTOLOAD =~ s/.*://o;
    return $self->{$AUTOLOAD};
}


package Mac::Macbinary::Header;

use vars qw($AUTOLOAD);

sub new {
    my ($class, $h) = @_;
    my $self = bless { }, $class;
    $self->_parse_header($h);
    return $self;
}

sub _parse_header {
    my $self = shift;
    my ($h) = @_;

    $self->{name}	= unpack("A*", substr($h, 2, 63));
    $self->{type}	= unpack("A*", substr($h, 65, 4));
    $self->{creator}	= unpack("A*", substr($h, 69, 4));
    $self->{flags}	= unpack("C", substr($h, 73, 1));
    $self->{location}	= unpack("C", substr($h, 80, 6));
    $self->{dflen}	= unpack("N", substr($h, 83, 4));
    $self->{rflen}	= unpack("N", substr($h, 87, 4));
    $self->{cdate}	= unpack("N", substr($h, 91, 4));
    $self->{mdate}	= unpack("N", substr($h, 95, 4));

    return $self;
}


sub AUTOLOAD {
    my $self = shift;
    $AUTOLOAD =~ s/.*://o;
    return $self->{$AUTOLOAD};
}

1;
__END__

=head1 NAME

Mac::Macbinary - Macbinary Handler

=head1 SYNOPSIS

  use Mac::Macbinary;

  $mb = new Mac::Macbinary(\*FH);	# filehandle
  $mb = new Mac::Macbinary($fh);	# IO::* instance
  $mb = new Mac::Macbinary("/path/to/file");

  $header = $mb->header;		# Mac::Macbinary::Header instance
  $name = $header->name;
  

=head1 DESCRIPTION

This module provides an object-oriented way to extract various kinds
of information from Macintosh Macbinary files.

=head1 METHODS

Following methods are available.

=head2 Class method

=over 4

=item new(I<THINGY>)

Constructor of Mac::Macbinary. Accepts filhandle GLOB reference,
FileHandle instance, IO::* instance, or whatever objects that can do
C<read> methods.

If the argument belongs none of those above, C<new()> treats it as a
path to file. Any of following examples are valid constructors.

  open FH, "path/to/file";
  $mb = new Mac::Macbinary(\*FH);

  $fh = new FileHandle "path/to/file";
  $mb = new Mac::Macbinary($fh);

  $io = new IO::File "path/to/file";
  $mb = new Mac::Macbinary($io);

  $mb = new Mac::Macbinary "path/to/file";

=back

=head2 Instance Method

=over 4

=item data

returns the data range of original file.

=item header

returns the header object (instance of Mac::Macbinary::Header).

=back

Following accessors are available via Mac::Macbinary instance.

=over 4

=item name, type, creator, flags, location, dflen, rflen, cdate, mdate

returns the original entry in the header of Macbinary file.
Below is a structure of the info file, taken from MacBin.C

  char zero1;
  char nlen;
  char name[63];
  char type[4];           65      0101
  char creator[4];        69
  char flags;             73
  char zero2;             74      0112
  char location[6];       80
  char protected;         81      0121
  char zero3;             82      0122
  char dflen[4];
  char rflen[4];
  char cdate[4];
  char mdate[4];

=back

=head1 AUTHOR

Tatsuhiko Miyagawa <miyagawa@edge.co.jp>
Originally written by Dan Kogai <dankogai@dan.co.jp>

=head1 SEE ALSO

perl(1).

=cut
