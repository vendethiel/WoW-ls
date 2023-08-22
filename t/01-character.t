use 5.38.0;
use lib '.';
use Test::More;
use Test::Exception;
use Wow;

{
  my $character = Wow->char_from_data(name => 'Vendethiel', level => 80, wowclass => 'mage');
  is($character->name, 'Vendethiel', 'Object populated with name');
  is($character->level, 80, 'Object populated with level');
  is($character->wowclass, 'mage', 'Object populated with class');
}

throws_ok { Wow->char_from_data(level => 80, wowclass => 'mage'); }
  qr/"name"/,
  'Errors when missing name key';

throws_ok { Wow->char_from_data(name => 'a', wowclass => 'mage'); }
  qr/"level"/,
  'Errors when missing level key';

throws_ok { Wow->char_from_data(name => 'a', level => 80); }
  qr/"wowclass"/,
  'Errors when missing wowclass key';

throws_ok { Wow->char_from_data(name => 'a', level => 80, wowclass => 'foobar'); }
  qr/"wowclass"/,
  'Errors when wrong wowclass key';

throws_ok { Wow->char_from_data(name => 'a', level => 0, wowclass => 'foobar'); }
  qr/"level"/,
  'Errors when wrong level key';

lives_ok {
  my $character = Wow->char_from_data(name => 'Vendethiel', level => 80, wowclass => 'mage', perks => ['mountwotlk']);
} 'Can create a character with a perk';

lives_ok {
  my $character = Wow->char_from_data(name => 'Vendethiel', level => 80, wowclass => 'mage', perks => [qw/mountwotlk mountbc mount40/]);
} 'Can create a character with multiple perks';

throws_ok {
  my $character = Wow->char_from_data(name => 'Vendethiel', level => 80, wowclass => 'mage', perks => ['mount30']);
} qr/mount30/,
  'Errors when giving a wrong perk name';

done_testing;

