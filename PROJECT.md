# Project Plan v3: A SECD Lisp Machine in Clash (Own Compiler)
 
**Goal (narrow, total):** The Basys 3 FPGA renders an interactive Lisp REPL on a VGA monitor with a keyboard. Nothing else.
 
**Method (pure Path B, own compiler):** No soft CPU. The evaluator *is* the circuit — a SECD machine written in Clash. The Lisp→SECD compiler is **your own, written in Haskell, from day one** (rewritten from the C-emitting design; SECD code is now the native ISA, so the old backend disappears entirely). Henderson's LispKit is demoted to reference material: the published spec of the machine and a worked example of a compiler targeting it.
 
**Stack:** Basys 3 (Artix-7 35T, ~225 KB BRAM, 12-bit VGA, USB-HID keyboard) · Clash · GHC for the compiler, reference machine, and testbenches. Everything is yours.
 
---
 
## 1. Architecture in Brief
 
One uniform **cons-cell heap in BRAM** is the entire memory. The machine is a Clash Mealy FSM whose architectural state is the four classic registers — **S**tack, **E**nvironment, **C**ontrol, **D**ump — each just a pointer into the heap, plus a few working registers and an allocation pointer. Each instruction executes as a few clock cycles of: fetch cell → dispatch on tag/opcode → allocate/rewire cells → update S/E/C/D. It is a microcoded processor whose microcode is a Haskell `case` expression.
 
**GC** is a second FSM mode: Cheney two-space copying — in hardware, two pointers and a scan loop.
 
**I/O** is two instructions: `GETC` (block on keyboard FIFO) and `PUTC` (emit to a terminal circuit). The terminal circuit owns the VGA character buffer and implements cursor, newline, scroll, and backspace in hardware, so the Lisp side only ever emits characters.
 
### Cell representation (M1 design spec — first thing to pin down)
- 64-bit cells (2 BRAM words): two 29–30-bit fields + tag bits per field, or one tag per cell. Draft: `| tag:4 | car:30 | cdr:30 |`.
- Tags at minimum: `CONS`, `FIXNUM` (immediate, in-field), `SYMBOL` (index into name table or interned list), `NIL/ATOM flags`. Instructions are just fixnums in the control list — pure SECD needs no code memory distinct from the heap.
- Budget: 64-bit cells → **~28K cells in 224 KB**, minus video/font/FIFO (~16 KB) → **~26K cells**, i.e. 2×13K semispaces. Small by modern standards, roomy for a REPL; LispKit's compiler famously ran in far less.
 
### Instruction set
Start with Henderson's canonical 21: `LD LDC LDF AP RTN DUM RAP SEL JOIN CAR CDR ATOM CONS EQ ADD SUB MUL DIV REM LEQ STOP`. Add: `GETC`, `PUTC`, and (for the REPL's `define`) a global-environment pair such as `GLOBAL-GET`/`GLOBAL-SET` or an E-register root convention. Resist adding more until the REPL demands it.
 
## 2. The Build Chain (own-compiler-first)
 
Four artifacts, each validating the next. Your Haskell fluency front-loads all the intellectually hard work into your home territory.
 
**Build 1 — Reference SECD machine in plain Haskell (executable spec).** Ordinary ADTs (`data Cell = Cons Ptr Ptr | Fix Int | ...`), a `step :: Machine -> Machine`, no hardware concerns. An afternoon-to-weekend job. Every later artifact is tested against this.
 
**Build 2 — Reference *evaluator* in plain Haskell (semantic oracle).** A direct tree-walking interpreter for your Lisp dialect — the boring obvious one, ~200 lines. This defines what programs *mean*, independently of SECD. It exists so the compiler can be differential-tested: for random programs, `interpret prog` must equal `run-on-Build-1 (compile prog)`. Without LispKit's self-compilation fixed-point trick, this is your compiler-correctness story, and it's a stronger one.
 
**Build 3 — The compiler rewrite (Haskell → SECD code).** Retarget your compiler: the backend now emits SECD instruction lists (S-expressions of fixnums and sublists) instead of C. This is a *smaller* compiler than before — closures, `if`, and function application map nearly one-to-one onto `LDF`/`AP`/`SEL`; there is no register allocation, no calling-convention plumbing, no runtime-in-C to interface with. Henderson's book contains a complete worked compiler for exactly this target if you want a crib sheet. Property-test against Build 2 continuously (Hedgehog generating programs).
 
**Build 4 — The ROM image: system software written in your Lisp, compiled by Build 3.** Contents: reader (S-expression parser over `GETC`), printer (over `PUTC`), REPL loop, `define` handling — **and the key structural consequence of dropping LispKit: a small metacircular evaluator, written in your Lisp**. Because your compiler is Haskell-on-the-laptop, it cannot live on the board; so the board's REPL evaluates typed forms with a Lisp-in-Lisp `eval` that you compile into the ROM. This is the standard move (and a joy to write — it's the SICP chapter 4 evaluator, ~150 lines of Lisp). Interpreted speed is entirely fine for a REPL. Self-hosting the *compiler* on-device — rewriting it in your dialect so the board compiles natively — graduates to M7+.
 
**Build 5 — The Clash machine.** Port Build 1 to a circuit: finite state, explicit BRAM port with request/response timing instead of pure data structures, tags as bit-fields instead of constructors. This translation *is* your hardware education, done on a program you already understand completely. Property-test against Build 1: same programs, both machines, identical results and (optionally) allocation traces. Divergence is debugged in GHCi, never in waveforms.
 
## 3. Milestones
 
**M0 — Flow (1–2 weekends).** Vivado + Clash installed; blinky synthesized and running; UART echo at 115200. Irreducible hardware-newcomer tax; keep clocks slow (25–50 MHz) forever — SECD at 25 MHz is a supercomputer next to the 1980s machines that ran LispKit.
 
**M1 — The whole system as software.** Builds 1–4: reference machine, reference evaluator, compiler rewrite, and the ROM image (reader + printer + metacircular eval + REPL loop in your Lisp) — all running *in GHCi*, with `GETC`/`PUTC` mapped to stdin/stdout. You type Lisp at a REPL whose evaluator is your reference SECD machine executing your compiler's output. The complete system works before any hardware exists. This is the single most important milestone, and none of it needs the board.
 
**M2 — Machine as circuit, in simulation.** Build 5 in Clash; executes the M1 ROM image in Clash simulation; property-tested against Build 1. Terminal I/O stubbed by the testbench.
 
**M3 — VGA + keyboard, no evaluator.** 80×30 character buffer + 8×16 font ROM → 640×480 VGA (dual-port BRAM: scanout on one port, writes on the other — no arbitration). PS/2 decode from the USB-HID bridge → scancode-to-ASCII → FIFO. Demo: keystrokes appear on screen with *nothing* computing in the design. (Érdi's *Retrocomputing with Clash* covers nearly this exact chapter.)
 
**M4 — Marriage.** SECD core + terminal + keyboard in one design; a canned ROM program prints a banner. First visible moment of the FPGA computing Lisp.
 
**M5 — GC.** Cheney copying collector as an FSM mode; triggered on allocation failure; tested in simulation with tiny heaps to force frequent collections. Deferrable this late because small demos fit in a semispace uncollected — but the REPL churns cells, so this gates M6.
 
**M6 — The REPL. Finish line.** Full M1 ROM image on hardware. Type `(+ 1 2)` on the keyboard, see `3` on the monitor, `define` something, use it. The machine on your desk contains no C, no third-party CPU, no toolchain you didn't bootstrap: Haskell describing silicon, running Lisp.
 
**M7+ (optional forever-list).** Self-host the compiler on-device (rewrite it in your dialect, replacing the metacircular eval with true compile-at-the-REPL) · line editing & history · dialect growth (strings, vectors, macros) · dual-space GC tricks in hardware · a second, lazy machine (Reduceron-style graph reduction) on the same VGA/keyboard/heap chassis.
 
## 4. Risks
 
| Risk | Mitigation |
|---|---|
| BRAM request/response timing bugs when porting Build 1 → Build 3 | The property-test harness against the reference machine; simulate with 1-cycle and multi-cycle memory models |
| Compiler bugs with no LispKit fixed-point trick to lean on | Build 2 (reference evaluator) + Hedgehog differential testing: `interpret p == run (compile p)` for generated programs; run the suite in CI on every compiler change |
| Metacircular eval too slow for REPL feel | It won't be — even at a few cycles per SECD instruction at 25 MHz, interpreted eval of typed-in forms is instant to a human; if a hot function matters, precompile it into the ROM |
| GC bugs (worst class of bug on hardware) | Force-collect constantly in simulation with 256-cell heaps; compare live-set against reference machine |
| Symbol handling ballooning scope (interning, name storage) | LispKit's own minimal scheme (symbols as character lists / small table) is enough; resist Unicode, resist hash tables |
| Vivado friction | All logic is verified in GHC-land first; Vivado only ever sees already-correct designs |
| Scope creep | The goal is one sentence long. Anything not on the path to M6 goes to M7+. |
 
## 5. Reference Shelf
 
- **Henderson, *Functional Programming: Application and Implementation* (1980)** — no longer the engine, still the manual: the clearest published spec of the SECD instruction semantics and a complete worked compiler targeting them. Read it before Build 3; steal its compilation schemes shamelessly.
- **SICP, chapter 4** — the metacircular evaluator you'll write in your Lisp for Build 4.
- **Landin, "The Mechanical Evaluation of Expressions" (1964)** — the SECD origin paper.
- **Kogge, *The Architecture of Symbolic Computers*** — SECD and Lisp-machine hardware techniques in depth.
- **Graham, *The SECD Microprocessor: A Verification Case Study*** — an actual formally verified SECD chip; proof the machine fits in silicon.
- **Naylor & Runciman, the Reduceron papers** — the engineering role model: functional machine, FPGA, BRAM heap, written in a Haskell HDL. Lazy lineage, so inspiration not blueprint.
- **Érdi, *Retrocomputing with Clash*** — VGA text mode, PS/2, and Clash project structure.
- **Baker / Cheney** — copying GC; any standard presentation of Cheney's algorithm.
 
## 6. First Three Concrete Actions
 
1. Start Builds 1 and 2 tonight — reference machine and reference evaluator need no new tools, no board, no Vivado, and Build 2 forces you to pin down the dialect's semantics precisely before the compiler rewrite begins.
2. In parallel, install Vivado WebPACK + Clash and get blinky onto the Basys 3 (M0).
3. Get Henderson's book (or a scan/summary of its SECD chapters) — the instruction semantics and compilation schemes are your Build 1/Build 3 spec, even with LispKit itself out of the loop.
