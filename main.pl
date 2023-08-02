#!/usr/bin/env perl
use v5.38.0;
use lib '.';
use Wow;
use assign::0;
use Syntax::Keyword::Match;
use Quantum::Superpositions;
use YAML::XS;
use IO::All;
use XXX;

my $contents = io->file('chars.yml')->slurp;
my @chardata = Load($contents);
my @char = map { Wow->char_from_data(%$_) } @chardata;

for my $char (@char) {
  say $char->introduction;
}

unless (all(Wow::WOWCLASSES) eq any(map {$_->wowclass} @char)) {
  say "Missing classes!";
}

match ($ARGV[0] // "" : eq) {
  case ("add") {
    say "addin'";
    # TODO `use Ask` or something
  }

  case("dump") {
    say Dump @char;
  }

  case ("") {}
  default { "Unrecognized option" }
}
