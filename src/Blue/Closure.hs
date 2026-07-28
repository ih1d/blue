module Blue.Closure where

import Blue.Core
import Control.Monad.Trans.State

data CLam = CLam Name Name CExpr
    deriving (Eq, Show)

data CExpr
    = CVar Name
    | CLit Int
    | CPrim PrimOp CExpr CExpr
    | CLet Name CExpr CExpr
    | CSel Int CExpr
    | CCLos CLam [CExpr]
    | CApp CExpr CExpr
    deriving (Eq, Show)

convert :: Name -> [Name] -> Expr -> State Int CExpr
convert _ _ (Var _) = error "todo"
convert _ _ (Lam _ _) = error "todo"
convert param layout (App f a) = do
    f' <- convert param layout f
    a' <- convert param layout a
    pure (CApp f' a')
convert _ _ (Lit i) = pure (CLit i)
convert param layout (Prim op e0 e1) = do
    e0' <- convert param layout e0
    e1' <- convert param layout e1
    pure (CPrim op e0' e1')
convert param layout (Let n e0 e1) = do
    e0' <- convert param layout e0
    e1' <- convert param [x | x <- layout, x /= n] e1
    pure (CLet n e0' e1')

freeVarsC :: CExpr -> [Name]
freeVarsC = undefined

closed :: CExpr -> [Name]
closed = undefined
