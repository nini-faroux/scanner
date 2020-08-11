module Options.Options where

import Import
import Options.PortParser
import qualified RIO.ByteString as BS

optionsParser :: Parser Options
optionsParser = Options <$> hostTarget <*> portTarget <*> verbose

hostTarget :: Parser BS.ByteString
hostTarget = argument str (metavar "<HOSTNAME>")

verbose :: Parser Bool
verbose = switch (short 'v' <> long "verbose" <> help "Verbose output")
