#!/usr/bin/env perl
use v5.38.0;
use lib '.';
use Cli;
use Wow qw/+Wowclass/;
use assign::0;
use Syntax::Keyword::Match;
use Quantum::Superpositions;
use YAML::XS;
use IO::All;
use List::Util qw(first);
use XXX;

my $contents = io->file('chars.yml')->slurp;
my @chardata = Load($contents);
my @char = map { Wow->char_from_data(%$_) } @chardata;

Cli->new_with_command->run(\@char);
