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
    my $missing = any(Wowclass->values->@*) ne all(map {$_->wowclass} $chars->@*);
    if ($missing) {
      say "Missing classes: " . join ", ", eigenstates($missing);
    }
  }
}

class Perk::Add {
  toolkit Moose (App::Command);
  with Named(1), Perked(2);

  method run($) {
    my $updated = $self->found->with_perk($self->perk);
    Data->new_character_update($updated, 'added perk');
  }
}

class Perk::Rm {
  toolkit Moose (App::Command);
  with Named(1), Perked(2);

  method run($) {
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

  method run($) {
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

  method run($) {
    my $updated = $self->found->with_level($self->level);
    Data->new_character_update($updated, 'level');
  }
}

class Rename {
  toolkit Moose (App::Command);
  with Named(1);
  param new_name (
    type => NonEmptySimpleStr,
    traits => ['AppOption'],
    cmd_type => 'parameter',
    cmd_position => 2
  );

  method run($) {
    Data->new_character_rename($self->found->name, $self->new_name);
  }
}

class Add {
  toolkit Moose (App::Command);
  param name (
    type => NonEmptySimpleStr,
    traits => ['AppOption'],
    cmd_type => 'parameter',
    cmd_position => 1
  );
  param wowclass (
    type => Wowclass,
    traits => ['AppOption'],
    cmd_type => 'parameter',
    cmd_position => 2
  );
  param level (
    type => Int,
    traits => ['AppOption'],
    cmd_type => 'parameter',
    cmd_position => 3
  );

  method run($) {
    my $char = Wow->char_from_data(name => $self->name, wowclass => $self->wowclass, level => $self->level);
    Data->new_character_add($char);
  }
}
