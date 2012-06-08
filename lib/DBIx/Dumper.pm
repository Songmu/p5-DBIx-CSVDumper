package DBIx::Dumper;
use strict;
use warnings;
use utf8;
use Encode;
our $VERSION = '0.01';

sub new { bless {}, shift };

sub csv_obj {
    my ($self, %opt) = @_;
    if (!$self->{_csv_obj} || %opt) {
        $self->{_csv_obj} = _csv_module()->new({
            binary          => 1,
            always_quote    => 1,
            eol             => "\r\n",
            %opt,
        });
    }
    $self->{_csv_obj};
}

sub dump_csv {
    my ($self, %args) = @_;
    my $sth    = $args{sth};
    my $output = $args{output};
    my $encoding = Encode::find_encoding($args{encoding} || 'utf-8');

    open my $fh, '>>', $output or die $!;
    my $csv = $self->csv_obj;
    my $cols = $sth->{NAME};
    $csv->print($fh, $cols);
    while (my @data = $sth->fetchrow_array) {
        @data = map {encode($encoding => $_)} @data;
        $csv->print($fh, [@data]);
    }
}

sub _csv_module {
    for my $module (qw/Text::CSV_XS Text::CSV/) {
        if (eval "use $module; 1") {
            return $module;
        }
    }
    die 'module Text::CSV(_XS)? is required.';
}


1;
__END__

=head1 NAME

DBIx::Dumper -

=head1 SYNOPSIS

  use DBIx::Dumper;

=head1 DESCRIPTION

DBIx::Dumper is

=head1 AUTHOR

Masayuki Matsuki E<lt>y.songmu@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
