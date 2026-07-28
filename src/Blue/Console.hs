-- | GETC and PUTC.  On the laptop they are stdin and stdout; on the
-- board they are the keyboard FIFO and the terminal circuit.  Same
-- interface, so the ROM image does not know the difference.
module Blue.Console (Console (..), stdioConsole) where

data Console m = Console
    { getc :: m Char
    , putc :: Char -> m ()
    }

stdioConsole :: Console IO
stdioConsole = error "Blue.Console.stdioConsole: TODO (M1)"
