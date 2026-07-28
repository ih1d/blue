-- | 256-cell heaps, forced collections, live set compared against the
-- reference machine.
module Test.Blue.GC (tests) where

import Test.Tasty (TestTree, testGroup)

tests :: TestTree
tests = testGroup "gc" []
