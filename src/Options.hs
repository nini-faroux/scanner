{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

module Options where

import Import
import RIO.Partial (read)
import qualified Data.ByteString.Char8 as BS8
import qualified Data.Attoparsec.ByteString as P
import qualified Data.Attoparsec.ByteString.Char8 as AC

parsePort :: P.Parser [PortNumber]
parsePort = do
  s <- AC.many1 AC.digit
  n <- P.peekWord8
  if isNothing n
    then return [read s]
    else do
      d <- AC.take 1
      if d /= "-"
        then fail "Invalid Input"
        else do
          e <- AC.many1 AC.digit
          n' <- P.peekWord8
          if isNothing n'
            then return [read s, read e]
            else fail "Invalid Input"

optionsParser :: Parser Options
optionsParser = Options <$> hostTarget <*> portTarget <*> verbose

hostTarget :: Parser BS8.ByteString
hostTarget = argument str (metavar "<HOSTNAME>")

portTarget :: Parser [PortNumber]
portTarget = option portReader (short 'p' <> long "port" <> help "Check single port or range of ports")

portReader :: ReadM [PortNumber]
portReader = eitherReader (P.parseOnly parsePort . BS8.pack)

verbose :: Parser Bool
verbose = switch (short 'v' <> long "verbose" <> help "Verbose output")
