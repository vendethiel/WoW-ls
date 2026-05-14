use v5.38.0;
use lib '.';
package Data;
use Wow qw/+Wowclass/;
use Wow::Types qw/Character CharName/;
use Quantum::Superpositions;
use syntax gather => {
  gather => { -as => 'rgather' },
  take   => { -as => 'rtake' },
};
use YAML::XS;
use IO::All;
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
    type => ArrayRef[Character]
  );

  factory updater_from_file(NonEmptySimpleStr $filename) {
    my $contents = io($filename)->slurp;
    my @char = map { Wow->char_from_data(%$_) } Load($contents);
    $class->new(filename => $filename, characters => \@char);
  }

  method save() {
    Dump($self->characters->@*) > io->file($self->filename);
  }

  method update_char(Character $char) {
    my @char = map { $_->name eq $char->name ? $char : $_ } $self->characters->@*;
    $self->clone(characters => \@char);
  }

  method rename_char($old_name, $new_name) {
    my @char = $self->characters->@*;
    my @name = map {$_->name} @char;
    die "Cannot rename to itself" if $old_name eq $new_name;
    die "Does not exist" unless any(@name) eq $old_name;
    die "Already exists" if any(@name) eq $new_name;
    my @updated = map { $_->name eq $old_name ? $_->with_name($new_name) : $_ } $self->characters->@*;
    $self->clone(characters => \@updated);
  }

  method add_char(Character $char) {
    my @char = $self->characters->@*;
    my @name = map {$_->name} @char;
    die "Already exists" if any(@name) eq $char->name;
    $self->clone(characters => [@char, $char]);
  }
}

interface Operation {
  requires perform(Updater);
  requires message();
}

class Operation::CharacterUpdate with Operation {
  param character ( type => Character );
  param change ( type => NonEmptySimpleStr );

  factory new_character_update(Character $char, $change) {
    $class->new(character => $char, change => $change);
  }

  method perform(Updater $updater) {
    $updater->update_char($self->character)->save;
  }

  method message() {
    my $s = "Updated character " . $self->character->name . " (" . $self->change . ")\n";
    $s .= $self->character->introduction;
    $s
  }
}

class Operation::CharacterRename with Operation {
  param old_name, new_name ( type => CharName );

  factory new_character_rename($old_name, $new_name) {
    $class->new(old_name => $old_name, new_name => $new_name);
  }

  method perform(Updater $updater) {
    $updater->rename_char($self->old_name, $self->new_name)->save;
  }

  method message() {
    "Renaming " . $self->old_name . " to " . $self->new_name;
  }
}

class Operation::CharacterAdd with Operation {
  param character ( type => Character );

  factory new_character_add(Character $char) {
    $class->new(character => $char);
  }

  method perform(Updater $updater) {
    $updater->add_char($self->character)->save;
  }

  method message() {
    "Adding " . $self->character->name;
  }
}

# `Operation` but idempotent
interface Result {
  requires message();
}

class Result::CharList with Result {
  param chars ( type => ArrayRef[Character] );

  factory new_char_list(ArrayRef[Character] $chars) {
    $class->new(chars => $chars);
  }

  method message() {
    join "\n", rgather {
      rtake "Characters:";
      for my $char ($self->chars->@*) {
        rtake $char->introduction;
      }
    }
  }
}

class Result::CheckClasses with Result {
  param missing ( type => ArrayRef[Wowclass] );

  factory new_check_classes(ArrayRef[Wowclass] $missing) {
    $class->new(missing => $missing);
  }

  method message() {
    if ($self->missing->@*) {
      "Missing classes: " . join ", ", $self->missing->@*;
    } else {
      "All classes OK"
    }
  }
}

interface Error {
  requires message();
}

class Error::CharacterAlreadyExists with Error {
  param name ( type => CharName );

  factory new_character_already_exists_error(CharName $name) {
    $class->new(name => $name);
  }

  method message() {
    $self->name . " already exists";
  }
}

class Error::CharacterNotFound with Error {
  param name ( type => CharName );

  factory new_character_not_found_error(CharName $name) {
    $class->new(name => $name);
  }

  method message() {
    $self->name . " not found";
  }
}
