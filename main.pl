#!/usr/bin/env perl
use v5.38.0;
use lib '.';
use Cli;
use Wow;
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

for my $char (@char) {
  say $char->introduction;
}
say "";

my ($main, @args) = @ARGV;
Cli->new_cli(main => $main // "", args => \@args)->run;

match ($ARGV[0] // "" : eq) {
  case ("add") {
    say "addin'";
    # TODO `use Ask` or something
  }

  case("dump") {
    say Dump @char;
  }

  case("perk") {
    @ARGV == 4 or die "Usage: `perk add|rm <char> <perk>`";
    my $name = $ARGV[2] // die "Usage: `perk add <char> <perk>`";
    my $perk = $ARGV[3] // die "Usage: `perk add <char> <perk>`";
    my $found = (first {$_->name eq $name} @char) // die "No char named like that";
    match ($ARGV[1] // "" : eq) {
      case ("add") {
        my $updated = $found->with_perk($perk);
        say "Character with new perk:";
        say $updated->introduction;
        exit if 1;
      }

      case ("rm") {
        my $updated = $found->without_perk($perk);
        say "Character with perk removed:";
        say $updated->introduction;
      }
    }
  }

  case ("") {
    unless (all(Wow::WOWCLASSES) eq any(map {$_->wowclass} @char)) {
      say "Missing classes!";
    }
  }
  default { "Unrecognized option" }
}
