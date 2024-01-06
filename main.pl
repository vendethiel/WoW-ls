#!/usr/bin/env perl
use v5.38.0;
use lib '.';
use Wow;
use Cli;
use Data;

my $updater = Data->updater_from_file('chars.yml');
my $ret = Cli->new_with_command->run($updater->characters);
$ret->perform($updater) if Data::is_Operation $ret;
