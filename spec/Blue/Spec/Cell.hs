-- | The cell format, shared verbatim by the reference machine (Build 1)
-- and the circuit (Build 5).  Draft layout, M1 pins it down:
--
-- >  63       60 59        30 29         0
-- > +-----------+------------+------------+
-- > |  tag : 4  |  car : 30  |  cdr : 30  |
-- > +-----------+------------+------------+
--
-- Two BRAM words per cell.  ~26K cells fit in the Basys 3's block RAM
-- once video, font and FIFOs are subtracted; that is 2 x 13K
-- semispaces for Cheney.
module Blue.Spec.Cell
    ( Tag (..)
    , tagBits
    , fieldBits
    , cellBits
    , heapCells
    , semispaceCells
    ) where

-- | Cell tags.  Fixnums and symbols are immediate: they live in the
-- fields themselves, not behind a pointer.
data Tag
    = TagNil
    | TagCons
    | TagFixnum
    | TagSymbol
    deriving stock (Eq, Ord, Show, Enum, Bounded)

tagBits, fieldBits, cellBits :: Int
tagBits = 4
fieldBits = 30
cellBits = tagBits + 2 * fieldBits

-- | Total cells in the heap, and the size of one Cheney semispace.
heapCells, semispaceCells :: Int
heapCells = 26624
semispaceCells = heapCells `div` 2
