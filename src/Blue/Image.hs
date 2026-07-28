-- | Build 4: the ROM image.  Lays compiled code out as cells and
-- emits the BRAM init file Vivado wants (.coe / .mif).
module Blue.Image (Image, layout, toCoe) where

import Data.ByteString (ByteString)

data Image = Image

layout :: a -> Image
layout = error "Blue.Image.layout: TODO (Build 4)"

toCoe :: Image -> ByteString
toCoe = error "Blue.Image.toCoe: TODO (Build 4)"
