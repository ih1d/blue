# Blue

A small reflective language for exploring dataflow semantics.

Blue is an expression-based language with numbers, booleans, strings,
arithmetic, comparison, `if`/`then`/`else`, and `let`/`in`. Its distinguishing
feature is `em`, a reflection operator that lifts a Blue expression into the
host language (Haskell) and evaluates it through a runtime interpreter, then
brings the value back into Blue.

## Build

Requires GHC 9.6 and `cabal`.

```sh
cabal build
```

## Run

Launches an interactive REPL:

```sh
cabal run blue
```

The interpreter loads `src/Syntax.hs` at startup to support reflection via
`em`, so run `cabal run` from the project root.

## REPL examples

```
BLUE> 1 + 2 * 3
7
BLUE> 2 ^ 10
1024
BLUE> true and false
false
BLUE> if 3 > 2 then "yes" else "no"
yes
BLUE> let x = 10 in x + 5
15
```

Reflection with `em` — the expression is compiled to Haskell and evaluated by
the host:

```
BLUE> em 2 + 3
5
BLUE> em if true then 100 else 0
100
```

## Syntax reference

- Literals: integers (`42`), booleans (`true`, `false`), strings (`"hello"`)
- Arithmetic: `+`, `-`, `*`, `^`
- Comparison: `==`, `!=`, `<`, `>`, `<=`, `>=`
- Logical: `and`, `or`
- Conditionals: `if c then a else b`
- Bindings: `let x = e1 in e2`
- Reflection: `em e`
- Comments: `# line comment`
