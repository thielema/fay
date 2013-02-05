{-# LANGUAGE RecordWildCards #-}

module Language.Fay.Compiler.Debug where

import Language.Fay.Compiler.Defaults
import Language.Fay.Compiler
import Language.Fay.Compiler.Misc
import Language.Fay.Types

import Control.Monad.Error
import Data.Default

-- | Compile a String of Fay and print it as beautified JavaScript.
printTestCompile :: String -> IO ()
printTestCompile = printCompile def { configWarn = False } (compileModule False)

-- | Compile a Haskell source string to a JavaScript source string.
compileTestAst :: (Show from,Show to,CompilesTo from to)
             => CompileConfig
             -> (from -> Compile to)
             -> String
             -> IO ()
compileTestAst cfg with from = do
  state <- defaultCompileState
  reader <- defaultCompileReader cfg
  out <- runCompile reader
             state
             (parseResult (throwError . uncurry ParseError)
                          with
                          (parseFay "<interactive>" from))
  case out of
    Left err -> error $ show err
    Right (ok,_,_) -> print ok

debug :: (Show from,Show to,CompilesTo from to) => (from -> Compile to) -> String -> IO ()
debug compile string = do
  putStrLn "AST:\n"
  compileTestAst c compile string
  putStrLn ""
  putStrLn "JS (unoptimized):\n"
  printCompile def { configTypecheck = False } compile string
  putStrLn "JS (optimized):\n"
  printCompile c compile string

  where c = def { configOptimize = True, configTypecheck = False }

-- | Compile the given input and print the output out prettily.
printCompile :: (Show from,Show to,CompilesTo from to)
              => CompileConfig
              -> (from -> Compile to)
              -> String
              -> IO ()
printCompile config with from = do
  result <- compileViaStr "<interactive>" config { configPrettyPrint = True } with from
  case result of
    Left err -> print err
    Right (PrintState{..},_,_) -> do
      putStrLn (concat (reverse (psOutput)))