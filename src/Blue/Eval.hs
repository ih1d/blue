module Blue.Eval where

import Blue.Core
import Control.Monad.Trans.State
import Data.List (nub)

freeVars :: Expr -> [Name]
freeVars (Var n) = [n]
freeVars (Lit _) = []
freeVars (Lam n expr) = [x | x <- freeVars expr, n /= x]
freeVars (App e0 e1) = nub (freeVars e0 ++ freeVars e1)
freeVars (Let n e0 e1) = nub (freeVars e0 ++ [x | x <- freeVars e1, n /= x])
freeVars (Prim _ e0 e1) = nub (freeVars e0 ++ freeVars e1)

eval :: Expr -> Env -> Either Error Value
eval (Var n) env =
    case lookup n env of
        Just v -> Right v
        Nothing -> Left (Unbound n)
eval (Lit i) _ = Right (VInt i)
eval (Lam n expr) env = Right (VClos env n expr)
eval (Let n e0 e1) env =
    case eval e0 env of
        Right v -> eval e1 ((n, v) : env)
        l -> l
eval (App f v) env =
    let f' = eval f env
     in case f' of
            Right (VClos env' n expr) ->
                let v' = eval v env
                 in case v' of
                        Right val -> eval expr ((n, val) : env')
                        l -> l
            Right fval -> Left (NotAFunc fval)
            l -> l
eval (Prim op e0 e1) env =
    let x = eval e0 env
     in case x of
            Right (VInt x') ->
                let y = eval e1 env
                 in case y of
                        Right (VInt y') ->
                            case op of
                                Add -> Right (VInt (x' + y'))
                                Sub -> Right (VInt (x' - y'))
                                Mul -> Right (VInt (x' * y'))
                        Right v -> Left (NotAnInt v)
                        l -> l
            Right v -> Left (NotAnInt v)
            l -> l
