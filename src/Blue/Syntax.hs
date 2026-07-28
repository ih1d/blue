-- | The dialect: one S-expression type, used as source syntax, as the
-- reference evaluator's values, and as the compiler's output (SECD code
-- is just a list of fixnums and sublists).
module Blue.Syntax
    ( SExpr (..)
    , Symbol
    , list
    ) where

import Data.Text (Text)

type Symbol = Text

data SExpr
    = Nil
    | Sym Symbol
    | Fix Int
    | Cons SExpr SExpr
    deriving stock (Eq, Show)

-- | Proper list from Haskell list.
list :: [SExpr] -> SExpr
list = foldr Cons Nil
