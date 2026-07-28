module Blue.Interpreter (runInterpreter, pExpr) where

import Blue.Core
import Blue.Eval (eval)
import Blue.Par (myLexer, pExpr)
import Blue.Skel ()
import Control.Monad (when)
import System.Exit (exitSuccess)
import System.IO (BufferMode (LineBuffering, NoBuffering), hSetBuffering, isEOF, stdout)

exitRepl :: IO ()
exitRepl = do
    hSetBuffering stdout LineBuffering
    exitSuccess

repl :: IO ()
repl = do
    putStr "BLUE> "
    isEOF >>= flip when exitRepl
    l <- getLine
    case l of
        [] -> repl
        ":q" -> exitRepl
        ":quit" -> exitRepl
        l' ->
            case pExpr (myLexer l') of
                Left err -> print err >> repl
                Right ast ->
                    let ir = desugar ast
                     in case eval ir [] of
                            Left err -> print err >> repl
                            Right val -> print val >> repl

runInterpreter :: IO ()
runInterpreter = do
    putStrLn "Welcome to Blue, version 0.0.1!"
    putStrLn "Type :q or :quit to quit"
    hSetBuffering stdout NoBuffering
    repl
