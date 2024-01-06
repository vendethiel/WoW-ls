use v5.38.0;
use lib '.';
package Cli;
use Data;
use Wow qw/+Wowclass/;
use Zydeco;
use Ven;
use List::Util qw(first);
use MooseX::App;
app_exclude 'Cli::Types', 'Cli::Named', 'Cli::Perked';

role Named($pos) {
  param name (
    type => NonEmptySimpleStr,
    traits => ['AppOption'], 
    cmd_type => 'parameter',
    cmd_position => $pos,
  );
  has found (
    is => rw,
    type => Wow::Character
  );

  before run($chars) {
    my $found = first {$_->name eq $self->name} $chars->@*;
    die "No character named ".$self->name() unless $found;
    $self->found($found);
  }
}

role Perked($pos) {
  param perk (
    type => Wow::Perk,
    traits => ['AppOption'],
    cmd_type => 'parameter',
    cmd_position => $pos,
  );
}

class Ls {
  toolkit Moose (App::Command);

  method run($chars) {
    for my $char ($chars->@*) {
      say $char->introduction;
    }
  }
}

class Check {
  toolkit Moose (App::Command);

  method run($chars) {
    unless (all(Wowclass) eq any(map {$_->wowclass} $chars->@*)) {
      say "Missing classes!";
    }
  }
}

class Perk::Add {
  toolkit Moose (App::Command);
  with Named(1), Perked(2);

  method run($chars) {
    my $updated = $self->found->with_perk($self->perk);
    Data->new_character_update($updated, 'added perk');
  }
}

class Perk::Rm {
  toolkit Moose (App::Command);
  with Named(1), Perked(2);

  method run($chars) {
    my $updated = $self->found->without_perk($self->perk);
    Data->new_character_update($updated, 'removed perk');
  }
}

class Reclass {
  toolkit Moose (App::Command);
  with Named(1);
  param wowclass (
    type => Wowclass,
    traits => ['AppOption'],
    cmd_type => 'parameter',
    cmd_position => 2,
  );

  method run($chars) {
    my $updated = $self->found->with_class($self->wowclass);
    Data->new_character_update($updated, 'class');
  }
}

class Level {
  toolkit Moose (App::Command);
  with Named(1);
  param level (
    type => NumRange[1, 80],
    traits => ['AppOption'],
    cmd_type => 'parameter',
    cmd_position => 2,
  );

  method run($chars) {
    my $updated = $self->found->with_level($self->level);
    Data->new_character_update($updated, 'level');
  }
}
