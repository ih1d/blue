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

Everything in `src/` and `spec/` is currently a stub that `error`s.

## Where we are

**M1, Build 2, assignment 1: `Blue.Syntax`.**

Write the type(s) for the dialect, the helpers actually needed, and — as
a comment at the top of the module — the grammar: concrete syntax plus
the list of special forms. That comment is the spec both the compiler
and the ROM's metacircular evaluator must honor.

Three decisions to answer first:

1. **One type or two?** The stub uses a single `SExpr` for source,
   runtime values, and compiler output — the classic Lisp move, and the
   ROM's metacircular `eval` wants homoiconicity. But `Nil | Sym | Fix |
   Cons` cannot represent a closure. Which of the three known-good
   answers, and why?
2. **Special forms.** Of `quote if lambda let letrec define`: which are
   primitive, which desugar? `SEL/JOIN` and `DUM/RAP` in the ISA are a
   strong hint about which two are unavoidable. `define` is REPL-level
   and has its own instruction pair — is it even in the expression
   language?
3. **Environments.** The `Eval` stub uses `Map Symbol SExpr`. SECD's
   `LD` takes a (frame, offset) pair into a list of frames, not a name.
   Does Build 2 model that, or stay naive and leave lexical addressing
   to the compiler? Both defensible: one makes the differential test
   more honest, the other keeps Build 2 the dumb oracle it is meant to
   be.

Design pressure to keep in mind throughout: every construct that does
not map onto an SECD instruction costs you in the compiler, and again in
the metacircular evaluator. A form added today is paid for three times.

`Blue.Eval` comes after. Don't touch it yet.
