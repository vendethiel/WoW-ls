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
}

class Operation::CharacterUpdate with Operation {
  param character ( type => Wow::Character );
  param change ( type => NonEmptySimpleStr );

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
  param old_name, new_name ( type => NonEmptySimpleStr );

  factory new_character_rename($old_name, $new_name) {
    $class->new(old_name => $old_name, new_name => $new_name);
  }

  method perform(Updater $updater) {
    say "Renaming " . $self->old_name . " to " . $self->new_name;
    $updater->rename_char($self->old_name, $self->new_name)->save;
  }
}

class Operation::CharacterAdd with Operation {
  param character ( type => Wow::Character );

  factory new_character_add(Character $char) {
    $class->new(character => $char);
  }

  method perform(Updater $updater) {
    say "Adding " . $self->character->name;
    $updater->add_char($self->character)->save;
  }
}
