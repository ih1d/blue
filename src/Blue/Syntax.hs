-- | Description: This module gives the core syntax between the three systems
-- <top-level> ::= <expr> | "(" "define" symbol <expr> ")"
-- <expr> ::= <atom> | <special> | <primapp> | <app>
-- <s-expr> ::= <atom> | <list>
-- <list> ::= "(" <s-expr>* ")"
--          | "(" <s-expr>+ "." <s-expr> ")"
-- <atom> ::= <fixnum> | symbol | nil
-- <fixnum> ::= -2^29 ... 2^29 - 1
-- <special> ::= "(" "if" <expr> <expr> <expr> ")"
--          | "(" "quote" <s-expr>  ")"
--          | "(" "lambda" "(" <symbol>* ")" <expr> ")"
--          | "(" "letrec" "(" <pairs> ")" <expr> ")"
--          **NOTE**: letrec is restricted to lambdas only
-- <pairs> ::= "(" symbol <expr> ")"+
-- For primitive operators they match against the <primapp> rule:
-- <primapp> ::= "(" <primop> <expr>* ")"
-- <primop> ::= car     takes one argument
--            | cdr     takes one argument
--            | cons    takes two arguments
--            | +       takes two arguments
--            | eq      takes two arguments
--            | -       takes two arguments
--            | *       takes two arguments
--            | /       takes two arguments
--            | rem     takes two arguments
--            | leq     takes two arguments
--            | getc    takes zero arguments
--            | putc    takes one arguments
-- <app> ::= "(" <expr> <expr>* ")"
-- Truthy & Falsy: Nil is False, everything else is True
-- atom, eq, and leq return 1 representing truth
-- Values are everything the reader produces plus closures, which no source text
-- can denote,  therefore: read . print == id is a property of source
-- expressions only, and the test must generate source rather than arbitrary
-- SExpr.
module Blue.Syntax (
    SExpr (..),
    Symbol,
    fromList,
    toList,
    Env,
) where

import Data.Int (Int32)

type Symbol = String

type Env = [(Symbol, SExpr)]

data SExpr
    = Nil
    | Sym Symbol
    | -- | A SECD cells have fixnums of 30-bit fields
      Fix Int32
    | Cons SExpr SExpr
    | -- | A closure expects a heap address, the parameters, the body, and the environment
      Closure Int [Symbol] SExpr Env

instance Eq SExpr where
    Nil == Nil = True
    (Sym s1) == (Sym s2) = s1 == s2
    (Fix x) == (Fix y) = x == y
    (Cons car1 cdr1) == (Cons car2 cdr2) = car1 == car2 && cdr1 == cdr2
    (Closure a1 _ _ _) == (Closure a2 _ _ _) = a1 == a2
    _ == _ = False
instance Show SExpr where
    show Nil = "nil"
    show (Sym s) = s
    show (Fix i) = show i
    show (Cons s1 s2) = "(" <> show s1 <> " . " <> show s2 <> ")"
    show (Closure a _ _ _) = "#" <> show a <> "<closure>"

-- | Proper list from Haskell list.
fromList :: [SExpr] -> SExpr
fromList = foldr Cons Nil

toList :: SExpr -> Maybe [SExpr]
toList Nil = Just []
toList (Cons car cdr) = (car :) <$> toList cdr
toList _ = Nothing
