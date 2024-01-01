use v5.38.0;
use lib '.';
package Cli;
use Wow qw/+Wowclass/;
use Zydeco;
use Ven;
use List::Util qw(first);
use MooseX::App;
app_exclude 'Cli::Types', 'Cli::Named';

role Named {
  param name (
    type => NonEmptySimpleStr,
    traits => ['AppOption'], 
    cmd_type => 'parameter',
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
  param perk (
    type => Wow::Perk,
    traits => ['AppOption'], 
    cmd_type => 'parameter',
  );
  with Named;

  method run($chars) {
    my $updated = $self->found->with_perk($self->perk);
    say "Character with new perk:";
    say $updated->introduction;
  }
}

class Perk::Rm {
  toolkit Moose (App::Command);
  param perk (
    type => Wow::Perk,
    traits => ['AppOption'], 
    cmd_type => 'parameter',
  );
  with Named;

  method run($chars) {
    my $updated = $self->found->without_perk($self->perk);
    say "Character with perk removed:";
    say $updated->introduction;
  }
}
