package DBIx::CSVDumper;
use strict;
use warnings;
use utf8;
use Encode;
our $VERSION = '0.01';

our %DEFAULT_CSV_ARGS = (
    binary          => 1,
    always_quote    => 1,
    eol             => "\r\n",
);

sub new {
    my ($kls, %args) = @_;
    my $self = bless {}, $kls;

    my $csv_class   = $args{csv_class};
    my $csv_args    = $args{csv_args};
    my $encoding    = $args{encoding};

    $self->csv_class($csv_class) if $csv_class;
    $self->csv_obj($self->csv_class->new({
        %DEFAULT_CSV_ARGS,
        %$csv_args,
    })) if $csv_args;

    $self->encoding($encoding) if $encoding;

    $self;
}

sub csv_class {
    my ($self, $mod) = shift;
    $self->{_csv_class} = $mod if $mod;
    $self->{_csv_class} ||= sub {
        for my $module (qw/Text::CSV_XS Text::CSV/) {
            if (eval "use $module; 1") { ## no critic
                return $module;
            }
        }
        die 'module Text::CSV(_XS)? is required.';
    }->();
}

sub csv_obj {
    my ($self, $obj) = @_;
    $self->{_csv_obj} = $obj if $obj;
    $self->{_csv_obj} ||= $self->csv_class->new({
        %DEFAULT_CSV_ARGS,
    });
}

sub encoding {
    my ($self, $enc) = @_;
    if ($enc) {
        $self->{_encoding} = Encode::find_encoding($enc);
    }
    $self->{_encoding} ||= Encode::find_encoding('utf-8');
}

sub dump {
    my ($self, %args) = @_;
    my $sth      = $args{sth};
    my $file     = $args{file};
    my $fh       = $args{fh};
    my $encoding = $args{encoding} || $self->encoding;

    $sth->execute if $DBI::VERSION >= 1.41 && !$sth->{Executed};

    unless ($fh) {
        open $fh, '>', $file or die $!;
    }

    my $csv = $self->csv_obj;
    my $cols = $sth->{NAME};
    $csv->print($fh, $cols);
    while (my @data = $sth->fetchrow_array) {
        @data = map {encode($encoding => $_)} @data;
        $csv->print($fh, [@data]);
    }
}


1;
__END__

=head1 NAME

DBIx::CSVDumper - dumping database (DBI) data into a CSV.

=head1 SYNOPSIS

  use DBIx::CSVDumper;
  my $dbh = DBI->connect(...);
  my $dumper = DBIx::CSVDumper->new(
    csv_class => 'Text::CSV_XS',
    csv_args  => {
      binary          => 1,
      always_quote    => 1,
      eol             => "\r\n",
    },
    encoding    => 'utf-8',
  );
  
  my $sth = $dbh->prepare('SELECT * FROM item');
  $sth->execute;
  $dumper->dump(
    sth     => $sth,
    file    => 'tmp/hoge.csv',
  );

=head1 DESCRIPTION

DBIx::CSVDumper is a module for dumping database (DBI) data into a CSV.

=head1 CONSTRUCTOR

=over

=item C<new>

  my $dumper = DBIx::CSVDumper->new(%args);

Create new dumper object. I<%args> is a hash with object parameters.
Currently recognized keys are:

=over

=item I<csv_class>

  csv_class => 'Text::CSV_XS',
  (default: automaticaly used Text::CSV_XS or Text::CSV)

=item I<csv_args>

  csv_args => {
    binary          => 1,
    always_quote    => 1,
    eol             => "\r\n",
  },
  (default: same as above)

=item I<encoding>

  encoding => 'cp932',
  (default: utf-8)

=back

=back

=head1 METHOD

=over

=item C<dump>

  $dumper->dump(%args);

Dump csv file. I<%args> is a hash with parameters. Currently recognized
keys are:

=over

=item I<sth>

  sth => $sth
  (required)

the value is a DBI::st object. C<execute> method should be called beforehand or
automatically called with DBI 1.41 or newer and no bind params.


=item I<file>

  file => $file

string of file name.

=item I<fh>

  fh => $fh

file handle. args C<file> or C<fh> is required.

=item I<encoding>

  enocding => 'euc-jp',
  (default: $dumper->encoding)

encoding.


=back

=item C<csv_class>

=item C<csv_obj>

=item C<encoding>

=back

=head1 AUTHOR

Masayuki Matsuki E<lt>y.songmu@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
