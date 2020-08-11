{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell #-}
module Main (main) where

import Run
import Import
import Scanner.Options.Options
import qualified Paths_scanner
import RIO.Process

main :: IO ()
main = do
  (options, ()) <- simpleOptions
    $(simpleVersion Paths_scanner.version)
    "Scanner"
    "Scanner"
    optionsParser
    empty
  lo <- logOptionsHandle stderr (optionsVerbose options)
  pc <- mkDefaultProcessContext
  withLogFunc lo $ \lf ->
    let app = App
          { appLogFunc = lf
          , appProcessContext = pc
          , appOptions = options
          }
     in runRIO app run
