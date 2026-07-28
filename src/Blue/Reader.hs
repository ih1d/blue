-- | S-expression reader for the laptop side.  The board's reader is a
-- separate program, written in the dialect itself over 'Blue.Console'
-- (Build 4); this one exists so the compiler has an input.
module Blue.Reader
    ( Parser
    , readSExpr
    , readProgram
    ) where

import Data.Text (Text)
import Data.Void (Void)
import Text.Megaparsec (Parsec)

import Blue.Syntax (SExpr)

type Parser = Parsec Void Text

readSExpr :: Text -> Either String SExpr
readSExpr = error "Blue.Reader.readSExpr: TODO (M1)"

readProgram :: Text -> Either String [SExpr]
readProgram = error "Blue.Reader.readProgram: TODO (M1)"
