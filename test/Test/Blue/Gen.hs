-- | Hedgehog generators for the dialect.  The quality of these is the
-- quality of the whole correctness story.
module Test.Blue.Gen (genProgram) where

import Hedgehog (Gen)

import Blue.Syntax (SExpr)

genProgram :: Gen SExpr
genProgram = error "Test.Blue.Gen.genProgram: TODO"
