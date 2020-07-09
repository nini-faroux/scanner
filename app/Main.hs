{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TemplateHaskell #-}
module Main (main) where

import Import
import Run
import qualified Data.ByteString.Char8 as BS8
import RIO.Process
import Options.Applicative.Simple
import qualified Paths_scanner

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

optionsParser :: Parser Options
optionsParser = Options <$> hostTarget <*> portTarget <*> verbose

hostTarget :: Parser BS8.ByteString
hostTarget = argument str (metavar "<HOSTNAME>")

portTarget :: Parser PortNumber
portTarget = option auto (short 'p' <> long "port" <> help "Check if specific port is open")

verbose :: Parser Bool
verbose = switch (short 'v' <> long "verbose" <> help "Verbose output")
