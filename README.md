# NAME

DBIx::CSVDumper - dumping database (DBI) data into a CSV.

# SYNOPSIS

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

# DESCRIPTION

DBIx::CSVDumper is a module for dumping database (DBI) data into a CSV.

# CONSTRUCTOR

- `new`

        my $dumper = DBIx::CSVDumper->new(%args);

    Create new dumper object. _%args_ is a hash with object parameters.
    Currently recognized keys are:

    - _csv\_class_

            csv_class => 'Text::CSV_XS',
            (default: automaticaly used Text::CSV_XS or Text::CSV)
    - _csv\_args_

            csv_args => {
              binary          => 1,
              always_quote    => 1,
              eol             => "\r\n",
            },
            (default: same as above)
    - _encoding_

            encoding => 'cp932',
            (default: utf-8)

# METHOD

- `dump`

        $dumper->dump(%args);

    Dump csv file. _%args_ is a hash with parameters. Currently recognized
    keys are:

    - _sth_

            sth => $sth
            (required)

        the value is a DBI::st object. `execute` method should be called beforehand or
        automatically called with DBI 1.41 or newer and no bind params.



    - _file_

            file => $file

        string of file name.

    - _fh_

            fh => $fh

        file handle. args `file` or `fh` is required.

    - _encoding_

            enocding => 'euc-jp',
            (default: $dumper->encoding)

        encoding.



- `csv_class`
- `csv_obj`
- `encoding`

# AUTHOR

Masayuki Matsuki <y.songmu@gmail.com>

# SEE ALSO

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
