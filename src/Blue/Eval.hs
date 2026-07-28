-- | Build 2: the semantic oracle.  A direct tree-walking interpreter
-- for the dialect, deliberately the boring obvious one.  This defines
-- what programs /mean/, independently of SECD; the compiler is
-- differential-tested against it.
module Blue.Eval
    ( Env
    , emptyEnv
    , eval
    , interpret
    ) where

import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map

import Blue.Syntax (SExpr, Symbol)

type Env = Map Symbol SExpr

emptyEnv :: Env
emptyEnv = Map.empty

eval :: Env -> SExpr -> Either String SExpr
eval = error "Blue.Eval.eval: TODO (Build 2)"

-- | Evaluate a closed program in the empty environment.
interpret :: SExpr -> Either String SExpr
interpret = eval emptyEnv
