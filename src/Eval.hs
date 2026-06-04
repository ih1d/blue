{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE FlexibleInstances #-}

module Eval where

import Syntax
import Control.Monad.State 
import Language.Haskell.Interpreter
    ( Interpreter
    , InterpreterError
    , runInterpreter
    , loadModules
    , setTopLevelModules
    , setImports
    , interpret
    , as
    )
import Control.Monad.Catch

type Env = [(Ident, Value)]

newtype Eval a = Eval { runEval :: StateT Env Interpreter a }
    deriving (Functor, Applicative, Monad, MonadState Env, MonadIO, MonadThrow, MonadCatch, MonadMask)

bindVar :: Ident -> Value -> Eval ()
bindVar v val = do
    env <- get
    case lookup v env of
        Nothing -> put ((v, val) : env)
        Just _ -> let env' = [(vr, vl) | (vr, vl) <- env, vr /= v] in put ((v, val) : env')

baseEval :: Expr -> Eval Value
baseEval (Const v) = pure v
baseEval (BinOp op e0 e1) = do
    (v0, v1) <- (,) <$> baseEval e0 <*> baseEval e1
    case (op, v0, v1) of
        (Add, NumV a, NumV b)   -> pure $ NumV (a + b)
        (Sub, NumV a, NumV b)   -> pure $ NumV (a - b)
        (Mul, NumV a, NumV b)   -> pure $ NumV (a * b)
        (Pow, NumV a, NumV b)   -> pure $ NumV (a ^ b)
        (And, BoolV a, BoolV b) -> pure $ BoolV (a && b)
        (Or, BoolV a, BoolV b)  -> pure $ BoolV (a || b)
        (Eq, a, b)              -> pure $ BoolV (a == b)
        (NotEq, a, b)           -> pure $ BoolV (a /= b)
        (Lt, NumV a, NumV b)    -> pure $ BoolV (a < b)
        (Gt, NumV a, NumV b)    -> pure $ BoolV (a > b)
        (LtEq, NumV a, NumV b)  -> pure $ BoolV (a <= b)
        (GtEq, NumV a, NumV b)  -> pure $ BoolV (a >= b)
        _                       -> error "type error"
baseEval (If cnd thn els) = do
    vc <- baseEval cnd
    case vc of
        BoolV True -> baseEval thn
        BoolV False -> baseEval els
        _ -> error "type error"
baseEval (Let v e i) = do
    val <- baseEval e
    bindVar v val
    baseEval i
baseEval (Var v) = do
    env <- get
    case lookup v env of
        Nothing -> error $ "couldn't find variable: " ++ v
        Just v' -> pure v'
baseEval (EM e) = metaEval e

metaEval :: Expr -> Eval Value
metaEval e = Eval $ lift $ interpret ("toValue (" ++ show e ++ ")") (as :: Value)


run :: Expr -> Env -> IO (Either InterpreterError (Value, Env))
run expr env = runInterpreter $ do
    loadModules ["src/Syntax.hs"]
    setTopLevelModules ["Syntax"]
    setImports ["Prelude", "Syntax"]
    runStateT (runEval (baseEval expr)) env