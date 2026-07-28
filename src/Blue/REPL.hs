-- | M1: the whole system as software.  Reader, compiler, reference
-- machine and ROM image wired to a console.
module Blue.REPL (repl) where

import Blue.Console (Console)

repl :: Console IO -> IO ()
repl = error "Blue.REPL.repl: TODO (M1)"
