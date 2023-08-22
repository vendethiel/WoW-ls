use v5.38.0;
use lib '.';
package Wow;
use Zydeco declare => [qw(Perk Character)];
use Ven;
use constant WOWCLASSES => qw/rogue mage priest druid warrior warlock hunter deathknight paladin shaman/;

# Temporary workaround for this issue:
# https://github.com/tobyink/p5-zydeco/issues/15

BEGIN {
  package Wow::Types;
  use Type::Library -base;
}

class Perk {
  param name (
    is => ro,
    enum => [qw/mountwotlk mountbc mount60 mount40/],
  );

  coerce from Str via from_string {
    return $class->new(name => $_);
  }
}

class Character with ::MooseX::Clone {
  param name (type => Str, is => ro);
  param level (type => PositiveNum, is => ro);
  param wowclass (
    is => ro,
    enum    => [WOWCLASSES],
    handles => 1,
  );
  param perks (
    is => ro,
    isa => ArrayRef[Perk],
  );

  factory char_from_data(%data) {
    my @perks = map { Perk->new(name => $_) } ($data{'perks'} // [])->@*;
    return $class->new(%data{qw/name wowclass level/}, perks => \@perks)
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

  method with_perk(Perk $new_perk) {
    return $self if $self->has_perk($new_perk);
    my @perks = ($self->perks->@*, $new_perk);
    $self->clone(perks => \@perks);
  }

  method without_perk(Perk $perk) {
    return $self if !$self->has_perk($perk);
    my @perks = grep {$_->name ne $perk->name} $self->perks->@*;
    $self->clone(perks => \@perks);
  }

  method mount_perk() {
    state @mounts = qw/mountwotlk mountbc mount60 mount40/;
    for my $mount (@mounts) {
      return $mount if $self->has_perk($mount);
    }
  }

  method has_perk(Perk $perk) = any(map {$_->name} $self->perks->@*) eq $perk->name;

  method has_perks = +$self->perks->@*;
}
