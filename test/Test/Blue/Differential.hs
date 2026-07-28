-- | interpret p == run (compile p), for generated p.
module Test.Blue.Differential (tests) where

import Test.Tasty (TestTree, testGroup)

tests :: TestTree
tests = testGroup "differential: Build 2 vs Build 1 . Build 3" []
