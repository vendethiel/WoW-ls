# Sugary WoW-ls

Experimental project to toy with a few Perl projects, such as:
- `Zydeco`
- `assign::0`
- `Syntax::Keyword::Gather`
- `Syntax::Keyword::Match`
- `Quantum::Superpositions`
- `MooseX::App`
- `Exporter::Almighty`

To investigate:
- `Types::Algebraic`
/
- `Syntax::Operator::Divides`
Operator %% like Raku.
- `Future::AsyncAwait`
`async`/`await`, need to make sure it's compatible at all with `Zydeco`.
- `Syntax::Keyword::Dynamically`
`local` but also for lexicals and for sub rvalue returns
- `Syntax::Operator::Eqr` & `Syntax::Operator::Equ`
like `eq` but can also proc a regex, useful for `match` etc.
- `Syntax::Operator::Identical`
Cutesy `≡` operator, probably a bad idea.
- `Syntax::Infix::Smartmatch`
Raku-style `~~`, hopefully done right.
- `Operator::Util`
Raku-style meta-operators:
`reduce reducewith zip zipwith cross crosswith hyper hyperwith applyop reverseop`
No syntax, sadly.
- `Object::Util`
Provides functions such as:
`->$_try`, `->$_call_if_object`, `->$dump`, `->$_tap` (like `Object::Tap`).
Also these, though they shouldn't be necessary with Zydeco:
`->$_clone`, `->$_extend`, `->$_with_traits`.
- `List::Maker`
Raku-style `...` range + Raku-style `<>`.
Might conflict with other modules?
- `Perl6::Rules`
Raku-style grammars.

Discarded:
- `Perl6::Controls`
(no `gather`+`take`, broke postfix `for`/`while` etc)

Some modules from `Defaults::Modern` also might be interesting to take a look at.
