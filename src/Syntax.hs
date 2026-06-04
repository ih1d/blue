-- |
-- Module      :  Syntax
-- Copyright   :  (c) Isaac Hiram Lopez Diaz 2026
-- License     :  BSD-3-Clause (see the file LICENSE)
--
-- Maintainer  :  isaac.lopez@upr.edu
-- Stability   :  experimental
-- Portability :  portable
--
-- Abstract syntax for the Blue language.
module Syntax where

-- | A variable name in Blue
type Id = String

-- | Types in Blue
data Type
    = IntT
    | BoolT
    | StringT
    deriving (Eq, Show)

-- | Values in Blue
data Value
    = IntV Integer
    | BoolV Bool
    | StrV String
    deriving (Eq, Show)

-- | Binary Operators
data Op
    = Add
    | Sub
    | Mul
    | Pow
    | Eq
    | NotEq
    | Lt
    | Gt
    | LtEq
    | GtEq
    | And
    | Or
    | Not
    deriving (Eq, Show)

-- | Pure Blue expressions. Produce a Value when evaluated
data Expr
    = Const Value
    | Var Id
    | BinOp Op Expr Expr
    | If Expr Expr Expr
    | Let Id Expr Expr
    deriving (Eq, Show)
