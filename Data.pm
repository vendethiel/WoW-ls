use v5.38.0;
use lib '.';
package Data;
use Wow;
use YAML::XS;
use IO::All;
use Ven;
use Zydeco;

BEGIN {
  # https://github.com/tobyink/p5-zydeco/issues/15
  package Data::Types;
  use Type::Library -base, -extends => [ 'Wow::Types' ];
}

class Updater with ::MooseX::Clone {
  has filename (
    is => ro,
    type => NonEmptySimpleStr
  );
  has characters (
    is => ro,
    type => ArrayRef[Wow::Character]
  );

  factory updater_from_file(NonEmptySimpleStr $filename) {
    my $contents = io($filename)->slurp;
    my @char = map { Wow->char_from_data(%$_) } Load($contents);
    $class->new(filename => $filename, characters => \@char);
  }

  method save() {
    Dump($self->characters->@*) > io->file($self->filename);
  }

  multi method update_char(Character $char) = $self->update_char($char->name, $char);

  multi method update_char($name, Character $char) {
    my @char = map { $_->name eq $char->name ? $char : $_ } $self->characters->@*;
    $self->clone(characters => \@char);
  }

  method with_char(Character $char) {
    my @char = $self->characters->@*;
    die "Already exists" if any(@char)->name eq $char->name;
    $self->clone(characters => [@char, $char]);
  }
}

interface Operation {
  requires perform(Updater);
}

class Operation::CharacterUpdate with Operation {
  has character! ( type => Wow::Character );
  has change! ( type => NonEmptySimpleStr );

  factory new_character_update(Character $char, $change) {
    $class->new(character => $char, change => $change);
  }

  method perform(Updater $updater) {
    say "Updated character " . $self->character->name . " (" . $self->change . ")";
    say $self->character->introduction;
    $updater->update_char($self->character)->save;
  }
}

class Operation::CharacterRename with Operation {
  has old_name! ( type => NonEmptySimpleStr );
  has character! ( type => Wow::Character );

  factory new_character_rename($old_name, Character $char) {
    $class->new(old_name => $old_name, character => $char);
  }

  method perform(Updater $updater) {
    say "Renaming " . $self->old_name . " to " . $self->character->name;
    $updater->update_char($self->old_name, $self->character)->save;
  }
}

class Operation::CharacterAdd with Operation {
  has character! ( type => Wow::Character );

  factory new_character_add(Character $char) {
    $class->new(character => $char);
  }

  method perform(Updater $updater) {
    say "Adding " . $self->character->name;
    $updater->with_char($self->character)->save;
  }
}
