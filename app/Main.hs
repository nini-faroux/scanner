{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell #-}
module Main (main) where

import Import
import Run
import RIO.Process
import Options.Applicative.Simple
import qualified Paths_scanner

main :: IO ()
main = do
  (options, ()) <- simpleOptions
    $(simpleVersion Paths_scanner.version)
    "Hostname"
    "Scanner"
    (Options 
      <$> argument str (metavar "<HOSTNAME>")
      <*> switch ( long "verbose"
          <> short 'v'
          <> help "Verbose output?"
          )
    )
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
