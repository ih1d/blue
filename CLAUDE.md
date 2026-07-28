# CLAUDE.md

## Working agreement: teacher / student

Isaac is building this to learn. **Claude does not write implementation
code for this project.**

- Claude explains the terrain, poses the design decisions, and sets one
  assignment at a time.
- Isaac writes the code.
- Claude reviews: what is wrong, what is merely bad, and why. Be direct;
  don't soften a real defect into a suggestion.
- Isaac asks questions; Claude answers, then sets the next assignment.
- Repeat until M6.

**Claude may write:** type signatures, counterexamples, failing test
cases, a two-line sketch when prose fails, build files, and scaffolding
that has been asked for. **Claude may not write:** the bodies of
`Blue.*` functions, unless Isaac explicitly asks for a specific one.

When a stub or a scaffold encodes a design decision, say so out loud —
scaffolding is not a decision, and Isaac should feel free to overrule it.

## The project

A SECD Lisp machine in Clash on a Basys 3, own compiler, no soft CPU.
Read `PROJECT.md` first — it is the spec, the milestone list, and the
reading list. Anything not on the path to M6 (a Lisp REPL on a VGA
monitor) belongs in M7+.

## Repository layout

    spec/Blue/Spec/   ISA only: cell layout + tags, opcode numbering.
                      Shared verbatim by software and hardware so the
                      two cannot disagree. base-only, compiled with
                      -fexpose-all-unfoldings (Clash inlines it).
    src/Blue/         Laptop side, Builds 1-4:
                        Syntax Reader Printer   the dialect
                        Eval                    Build 2, semantic oracle
                        SECD/{Code,Heap,Machine,GC}   Build 1
                        Compile                 Build 3
                        Image Console REPL      Build 4, M1 driver
    hw/Blue/HW/       Build 5, the circuit (Clash). basys3.xdc lives here.
    app/Main.hs       `blue` executable
    bin/              Clash.hs, Clashi.hs -- HDL generation entry points
    test/             tasty + hedgehog; the differential harness
    hw-test/          Build 5 vs Build 1
    lisp/             Build 4 ROM sources, written in the dialect

## Build

    cabal build all                  # software only
    cabal test                       # the differential suite
    cabal build -f hardware all      # + Clash (GHC 9.10.3, clash 1.10)
    cabal run blue:clash -- Blue.HW.Top --verilog

Hardware is behind a manual flag because `clash-ghc` is a large
dependency tree and is not needed before M2. `-f werror` for CI.

Everything in `src/` and `spec/` other than `Blue.Syntax` is a stub.

Design pressure to keep in mind throughout: every construct that does
not map onto an SECD instruction costs you in the compiler, and again in
the metacircular evaluator. A form added today is paid for three times.

## Decisions already settled

These were argued out and should not be relitigated without a reason.

- **One `SExpr` type** for source, values and compiler output. Closures
  are a constructor no source text can denote — hence `read . print ==
  id` is a property of *source*, not of `SExpr`.
- **Closures carry an allocation address** (`Closure Int [Symbol] SExpr
  Env`). `Eq` compares that address, never structure: two separately
  created closures are different objects, which is what `LDF` does on
  the board. Structural comparison would also diverge on the cyclic
  environments `letrec` builds.
- **`Show` is hand-written**, closures print as `#<closure n>`. Deriving
  it hangs once environments become cyclic.
- **Primitive: `quote if lambda letrec`.** `let` desugars to a lambda
  application. `define` is REPL-level, not an expression. Rule of thumb:
  if the ISA has an instruction for it, it is primitive — `SEL/JOIN` is
  the tell for `if`, `DUM/RAP` for `letrec`.
- **`letrec` right-hand sides are restricted to lambdas.** `RAP` applies
  what it finds in the frame; a non-lambda binding makes the lazy knot
  diverge (`(letrec ((x x)) x)` hangs, it does not error).
- **nil is false, everything else is true.** `eq`, `atom` and `leq`
  return the fixnum `1` for true. The test is on the tag alone, which is
  the cheapest branch condition in hardware.
- **Environments are naive assoc lists** — `[(Symbol, SExpr)]`, defined
  in `Blue.Syntax`. Build 2's job is to be obviously correct, not to
  prefigure SECD's (frame, offset) addressing. Build 2 and Build 1 are
  *supposed* to share nothing; the differential test compares final
  answers, and its value comes entirely from that independence.
- **Call-by-value, lexical scope.** A closure's body runs in the
  environment stored *in the closure*, extended with the parameters
  bound to *evaluated* arguments. Arity mismatch is an error — no
  currying, because `AP` takes one complete argument frame.
- **Build 2 stays pure.** `StateT Int (Either String)`, no `IO`. The M1
  REPL runs Build 1, not the tree-walker, so `getc`/`putc` are not
  available in the reference evaluator.

## Open questions

- What does division/remainder by zero do? Both machines must agree.
- `eq` on non-atoms: Haskell's `==` recurses structurally, the board
  compares addresses. Restrict `eq` to atoms, or it will disagree with
  Build 1 on the primitive most likely to show up in generated tests.
- Fixnum width: the grammar states −2²⁹ … 2²⁹−1 but the type is `Int32`
  and arithmetic does not wrap. Wants a `mkFix` that computes at `Int64`
  and wraps into 30-bit two's complement, with `Fix` hidden from the
  export list.
- Is failure part of the observable contract? If `interpret p == run
  (compile p)` must agree on *errors*, Build 1 needs arity checks it may
  not want. If not, `Test.Blue.Gen` must never generate a failing
  program. Recommended: compare successful results only, never compare
  error strings.

## Where we are

**M1, Build 2: `Blue.Eval`.** `Blue.Syntax` is done and reviewed.

The build is currently broken mid-migration: `text` was dropped from
`build-depends` while `Blue.Syntax` and `Blue.Printer` still import
`Data.Text`. Finish it — `type Symbol = String`.

Outstanding in `Blue.Eval`, in order:

1. **The dispatch order.** What gets evaluated depends on what the head
   is, so the head must be inspected *syntactically* before anything is
   evaluated. Special forms get their operands raw; primitives and
   applications get them evaluated (`traverse (eval env)`); only the
   application case evaluates the head.
2. Drop `Env` from `apply` and `applyPrimOp` — with values arriving,
   neither needs it, and `apply` without it *cannot* implement dynamic
   scope. Let the type enforce the decision.
3. `lambda` (convert the parameter `SExpr` to `[Symbol]`, reject
   non-symbols) and `letrec` (draw all addresses first, then tie one
   lazy knot binding the whole group; comment that the machine does this
   by mutation via `DUM`/`RAP`).
4. `cons` must match two arguments, not one pair. Arithmetic must wrap.
   Division by zero must not crash. `getc`/`putc` should be explicit
   "not available in Build 2" errors.

After `Blue.Eval`: `Blue.Reader`, then the differential harness, then
Build 1.
