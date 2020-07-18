module Scanner.Options.Options where

import Scanner.Import
import Scanner.Options.PortParser
import qualified RIO.ByteString as BS

optionsParser :: Parser Options
optionsParser = Options <$> hostTarget <*> portTarget <*> verbose

hostTarget :: Parser BS.ByteString
hostTarget = argument str (metavar "<HOSTNAME>")

verbose :: Parser Bool
verbose = switch (short 'v' <> long "verbose" <> help "Verbose output")
