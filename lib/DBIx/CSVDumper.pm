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
            if (eval "use $module; 1") {
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

DBIx::CSVDumper -

=head1 SYNOPSIS

  use DBIx::CSVDumper;

=head1 DESCRIPTION

DBIx::CSVDumper is

=head1 AUTHOR

Masayuki Matsuki E<lt>y.songmu@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
