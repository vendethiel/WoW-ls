use v5.38.0;
use lib '.';
package Cli;
use Zydeco;
use Ven;

role Parser {
  param args (type => ArrayRef[Str]);

  requires run;
}

class Parser::Perk {
  with Parser;

  method run() {
  }
}

class Cli {
  param main (type => Str);
  param args (type => ArrayRef[Str]);

  method run() {
    my {$main, $args} = $self;
    "Cli::Parser::${\ucfirst $main}"->new(args => $args)->run();
  }
}
