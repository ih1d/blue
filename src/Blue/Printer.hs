-- | Printing S-expressions, and disassembling SECD code back into
-- something readable for debugging Build 1 and Build 3.
module Blue.Printer
    ( pretty
    , render
    , disassemble
    ) where

import Data.Text (Text)
import Prettyprinter (Doc)

import Blue.Syntax (SExpr)

pretty :: SExpr -> Doc ann
pretty = error "Blue.Printer.pretty: TODO (M1)"

render :: SExpr -> Text
render = error "Blue.Printer.render: TODO (M1)"

-- | SECD code list -> mnemonics.
disassemble :: SExpr -> Text
disassemble = error "Blue.Printer.disassemble: TODO (M1)"
