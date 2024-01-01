#!/usr/bin/env perl
use v5.38.0;
use lib '.';
use Wow;
use Cli;
use YAML::XS;
use IO::All;

my $contents = io('chars.yml')->slurp;
my @chardata = Load($contents);
my @char = map { Wow->char_from_data(%$_) } @chardata;

my $ret = Cli->new_with_command->run(\@char);
if (Wow::is_Character($ret)) {
  my @updated = map { $_->name eq $ret->name ? $ret : $_ } @char;
  (Dump @updated) > io->file('chars.yml');
}
