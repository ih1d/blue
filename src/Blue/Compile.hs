-- | Build 3: the compiler.  Lisp -> SECD code.  Closures, @if@ and
-- application map nearly one-to-one onto LDF/AP/SEL, so this stays
-- small; see Henderson chapter 6 for the compilation schemes.
module Blue.Compile (compile) where

import Control.Monad.State.Strict (State)

import Blue.SECD.Code (Code)
import Blue.Syntax (SExpr)

type Compiler = State Int

compile :: SExpr -> Either String Code
compile = error "Blue.Compile.compile: TODO (Build 3)"

_unusedCompiler :: Compiler ()
_unusedCompiler = pure ()
