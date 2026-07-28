-- | S-expression reader for the laptop side.  The board's reader is a
-- separate program, written in the dialect itself over 'Blue.Console'
-- (Build 4); this one exists so the compiler has an input.
module Blue.Reader (
    Parser,
    readSExpr,
    readProgram,
) where

import Data.Void (Void)
import Text.Megaparsec (Parsec)

import Blue.Syntax (SExpr)

type Parser = Parsec Void String

readSExpr :: String -> Either String SExpr
readSExpr = error "Blue.Reader.readSExpr: TODO (M1)"

readProgram :: String -> Either String [SExpr]
readProgram = error "Blue.Reader.readProgram: TODO (M1)"
