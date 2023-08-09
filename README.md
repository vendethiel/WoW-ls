# Sugary WoW-ls

Experimental project to toy with a few Perl projects, such as:
- `Zydeco`
- `assign::0`
- `Syntax::Keyword::Gather`
- `Syntax::Keyword::Match`
- `Quantum::Superpositions`

To investigate:
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

Discarded:
- `Perl6::Controls`
(no `gather`+`take`, broke postfix `for`/`while` etc)
