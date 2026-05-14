#!/usr/bin/env perl
use v5.38.0;
use lib '.';
use Wow;
use Cli;
use Data;
use Switch::Right;

my $updater = Data->updater_from_file('chars.yml');
my $ret = Cli->new_with_command->run($updater->characters);
given ($ret) {
  when (\&Data::is_Operation) {
    $ret->perform($updater);
    my $message = $ret->message;
    say $message if $message;
  }
  when (\&Data::is_Result) {
    my $message = $ret->message;
    say $message if $message;
  }
  when (\&Data::is_Error) {
    say STDERR "Error: " . $ret->message;
    exit 1;
  }
}
