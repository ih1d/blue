module Eval where

import Syntax

type Env = [(Id, Value)]

eval :: Expr -> Value
eval (Const v) = v
eval _ = undefined
