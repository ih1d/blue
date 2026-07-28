-- | SECD instructions as a Haskell ADT, and assembly to the fixnum
-- lists the machine actually executes.
module Blue.SECD.Code (Code, assemble) where

import Blue.Spec.Opcode (Opcode)
import Blue.Syntax (SExpr)

type Code = [Opcode]

assemble :: Code -> SExpr
assemble = error "Blue.SECD.Code.assemble: TODO (Build 1)"
