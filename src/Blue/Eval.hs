{-# LANGUAGE OverloadedStrings #-}

-- | Build 2: the semantic oracle.  A direct tree-walking interpreter
-- for the dialect, deliberately the boring obvious one.  This defines
-- what programs /mean/, independently of SECD; the compiler is
-- differential-tested against it.
module Blue.Eval (
    Env,
    eval,
    interpret,
) where

import Blue.Syntax (Env, SExpr (..), Symbol, fromList, toList)
import Control.Monad.Except
import Control.Monad.State
import Data.Maybe (fromMaybe)

type EvalM = StateT Int (Either String)

-- | primitive operators table
primops :: [Symbol]
primops =
    [ "car"
    , "cdr"
    , "cons"
    , "+"
    , "-"
    , "*"
    , "/"
    , "rem"
    , "leq"
    , "getc"
    , "putc"
    , "eq"
    ]

-- | special forms table
specialForms :: [Symbol]
specialForms = ["quote", "if", "lambda", "letrec"]

-- | Hand out next address
fresh :: EvalM Int
fresh = get >>= put . (+ 1) >> get

-- | Evaluate an expression in an environment
eval :: Env -> SExpr -> EvalM SExpr
eval env (Sym sym) =
    case lookup sym env of
        Nothing -> throwError $ "unbound name: " <> sym
        Just e -> pure e
eval env (Cons car cdr) = do
    operands <- maybe (throwError "malformed application") pure (toList cdr)
    case car of
        Sym s
            | s `elem` specialForms -> applySpecForm s operands env
            | s `elem` primops -> traverse (eval env) operands >>= applyPrimOp s
        _o -> do
            f <- eval env car
            vals <- traverse (eval env) operands
            apply f vals
eval _ sexpr = pure sexpr

-- | Apply a value to an already-evaled args. Arity is checked here; lexical
-- scope is decided here.
apply :: SExpr -> [SExpr] -> EvalM SExpr
apply Nil _ = throwError "Nil cannot be applied!"
apply (Fix _) _ = throwError "cannot apply a fixnum!"
apply (Cons _ _) _ = throwError "cannot apply a list!"
apply c@(Closure _ params body cenv) args =
    if length params == length args
        then let env' = zip params args ++ cenv in eval env' body
        else throwError $ "arity mismatch applying: " <> show c
apply (Sym f) args =
    if f `elem` primops
        then applyPrimOp f args
        else
            if f `elem` specialForms
                then applySpecForm f args env
                else eval env (Sym f)

applyPrimOp :: Symbol -> [SExpr] -> EvalM SExpr
applyPrimOp "car" [Cons a _] = pure a
applyPrimOp "car" [_] = throwError "car expects a list!"
applyPrimOp "car" _ = throwError "car expects one argument!"
applyPrimOp "cdr" [Cons _ cdr] = pure cdr
applyPrimOp "cdr" [_] = throwError "cdr expects a list!"
applyPrimOp "cdr" [] = throwError "cdr expects one argument!"
applyPrimOp "cons" [Cons car cdr] = pure (Cons car cdr)
applyPrimOp "cons" _ = throwError "cons expects two arguments!"
applyPrimOp "+" [Fix x, Fix y] = pure (Fix (x + y))
applyPrimOp "+" _ = throwError $ "+ expects two arguments!"
applyPrimOp "-" [Fix x, Fix y] = pure (Fix (x - y))
applyPrimOp "-" _ = throwError $ "- expects two arguments!"
applyPrimOp "*" [Fix x, Fix y] = pure (Fix (x * y))
applyPrimOp "*" _ = throwError $ "* expects two arguments!"
applyPrimOp "/" [Fix x, Fix y] = pure (Fix (x `div` y))
applyPrimOp "/" _ = throwError $ "/ expects two arguments!"
applyPrimOp "rem" [Fix x, Fix y] = pure (Fix (x `rem` y))
applyPrimOp "rem" _ = throwError $ "rem expects two arguments!"
applyPrimOp "leq" [Fix x, Fix y] = pure (if x <= y then Fix 1 else Nil)
applyPrimOp "leq" _ = throwError $ "leq expects two arguments!"
applyPrimOp "getc" rest = undefined
applyPrimOp "putc" rest = undefined
applyPrimOp "eq" [s1, s2] = pure (if s1 == s2 then Fix 1 else Nil)
applyPrimOp "eq" _ = throwError "eq expects two arguments!"
applyPrimOp str _ = throwError $ "primitive operator: " <> str <> " not recognized"

applySpecForm :: Symbol -> [SExpr] -> Env -> EvalM SExpr
applySpecForm "if" [c, t, e] env = do
    cond <- eval env c
    case cond of
        Nil -> eval env e
        _other -> eval env t
applySpecForm "if" _ _ = throwError "if expects a conditional, a then branch and an else branch"
applySpecForm "lambda" _ _ = undefined
applySpecForm "letrec" _ _ = undefined
applySpecForm str _ _ = throwError $ "special form: " <> str <> " not recognized"

-- | Evaluate a closed program in the empty environment.
interpret :: SExpr -> Either String SExpr
interpret e = evalStateT (eval [] e) 0
