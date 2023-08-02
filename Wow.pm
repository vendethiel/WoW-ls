use v5.38.0;
use lib '.';
package Wow;
use Ven;
use constant WOWCLASSES => qw/rogue mage priest druid warrior warlock hunter deathknight paladin shaman/;

class Perk {
  param name (
    is => ro,
    enum => [qw/mountwotlk mountbc mount60 mount40/],
  );

  #coerce from Str via from_string {
  #  return $class->new(name => $_);
  #}
}

class Character {
  param name (type => Str, is => ro);
  param level (type => Int, is => ro);
  param wowclass (
    is => ro,
    enum    => [WOWCLASSES],
    handles => 1,
  );
  param perks (
    is => ro,
    isa => ArrayRef, # TODO this breaks everything
  ); # TODO handles => add_perk => push etc

  factory char_from_data(%data) {
    my @perks = map { Perk->new(name => $_) } ($data{'perks'} // [])->@*;
    return $class->new(%data{qw/name wowclass level perks/}, perks => \@perks)
  }

  method introduction() {
    my {$name, $wowclass, $level} = $self;
    join "\n", rgather {
      rtake "$name ($wowclass) lvl $level";

      if (my $mount_perk = $self->mount_perk) {
        rtake " - $mount_perk";
      }
    }
  }

  method mount_perk() {
    state @mounts = qw/mountwotlk mountbc mount60 mount30/;
    for my $mount (@mounts) {
      return $mount if $self->has_perk($mount);
    }
  }

  method has_perk($perk) = any(map {$_->name} $self->perks->@*) eq $perk;
  method has_perks = +$self->perks->@*;
}
