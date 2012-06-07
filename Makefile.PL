use inc::Module::Install;
name 'DBIx-Dumper';
all_from 'lib/DBIx/Dumper.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
