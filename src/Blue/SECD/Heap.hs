-- | The cons-cell heap: one unboxed vector standing in for BRAM, an
-- allocation pointer, and nothing else.  Modelled close to the hardware
-- on purpose, so Build 5 is a port and not a rewrite.
module Blue.SECD.Heap (Heap, Ptr, newHeap) where

import Data.Vector.Unboxed.Mutable (MVector)
import Data.Word (Word64)

type Ptr = Int
type Heap s = MVector s Word64

newHeap :: Int -> IO (Heap s)
newHeap = error "Blue.SECD.Heap.newHeap: TODO (Build 1)"
