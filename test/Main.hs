module Main (main) where

import Test.Tasty (defaultMain, testGroup)

import Test.Blue.Differential qualified as Differential
import Test.Blue.GC qualified as GC
import Test.Blue.Reader qualified as Reader

main :: IO ()
main = defaultMain $ testGroup "blue"
    [ Reader.tests
    , Differential.tests
    , GC.tests
    ]
