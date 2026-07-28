-- | The instruction set: Henderson's canonical 21, plus @GETC@ and
-- @PUTC@ for I/O and a global-environment pair for the REPL's @define@.
-- Instructions are ordinary fixnums in the control list, so the numeric
-- encoding here is the ISA.  Resist adding to this list.
module Blue.Spec.Opcode
    ( Opcode (..)
    , encode
    , decode
    ) where

data Opcode
    = LD | LDC | LDF | AP | RTN
    | DUM | RAP
    | SEL | JOIN
    | CAR | CDR | ATOM | CONS | EQ_
    | ADD | SUB | MUL | DIV | REM | LEQ
    | STOP
    | GETC | PUTC
    | GLOBAL_GET | GLOBAL_SET
    deriving stock (Eq, Ord, Show, Enum, Bounded)

encode :: Opcode -> Int
encode = fromEnum

decode :: Int -> Maybe Opcode
decode n
    | n >= fromEnum (minBound :: Opcode)
    , n <= fromEnum (maxBound :: Opcode) = Just (toEnum n)
    | otherwise = Nothing
