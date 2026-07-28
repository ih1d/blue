module Blue.Core where

import Blue.Abs qualified as S
import Data.String (IsString)

newtype Name = Name String
    deriving (Eq, Ord, Show, Read, IsString)

type Env = [(Name, Value)]

data PrimOp
    = Add
    | Sub
    | Mul
    deriving (Eq)
instance Show PrimOp where
    show Add = "+"
    show Sub = "-"
    show Mul = "*"

data Expr
    = Var Name
    | Lit Int
    | Lam Name Expr
    | App Expr Expr
    | Let Name Expr Expr
    | Prim PrimOp Expr Expr
    deriving (Eq, Show)

data Value
    = VInt Int
    | VClos Env Name Expr
    deriving (Eq)
instance Show Value where
    show (VInt i) = show i
    show (VClos _ (Name n) _) = "<closure " <> n <> ">"

data Error
    = Unbound Name
    | NotAFunc Value
    | NotAnInt Value
    deriving (Eq, Show)

desugar :: S.Expr -> Expr
desugar (S.Lit i) = Lit (fromInteger i)
desugar (S.Var (S.Ident s)) = Var (Name s)
desugar (S.App e0 e1) = App (desugar e0) (desugar e1)
desugar (S.Let (S.Ident i) e0 e1) = Let (Name i) (desugar e0) (desugar e1)
desugar (S.Abs (S.Ident i) e) = Lam (Name i) (desugar e)
desugar (S.Add e0 e1) = Prim Add (desugar e0) (desugar e1)
desugar (S.Sub e0 e1) = Prim Sub (desugar e0) (desugar e1)
desugar (S.Mul e0 e1) = Prim Mul (desugar e0) (desugar e1)
