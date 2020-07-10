{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

module Options where

import Import
import RIO.Partial (read)
import qualified Data.ByteString.Char8 as BS8
import qualified Data.Attoparsec.ByteString as P
import qualified Data.Attoparsec.ByteString.Char8 as AC

optionsParser :: Parser Options
optionsParser = Options <$> hostTarget <*> portTarget <*> verbose

hostTarget :: Parser BS8.ByteString
hostTarget = argument str (metavar "<HOSTNAME>")

portTarget :: Parser [PortNumber]
portTarget = option portReader (short 'p' <> long "port" <> help "Check single port or range of ports")

portReader :: ReadM [PortNumber]
portReader = eitherReader (P.parseOnly parsePort . BS8.pack)

parsePort :: P.Parser [PortNumber]
parsePort = do
  s <- AC.many1 AC.digit
  n <- P.peekWord8
  if isNothing n
    then do
      if checkPortInRange s 
        then return [read s]
        else fail "Invalid Input: Port must be in range 0-65535"
    else do
      d <- AC.take 1
      if d /= "-"
        then fail "Invalid Input: -p n or -p s-e"
        else do
          e <- AC.many1 AC.digit
          n' <- P.peekWord8
          if isNothing n'
            then if not (checkPortInRange e)
                 then fail "Invalid Input: Port must be in range 0-65535"
                 else do
                   let check = checkInterval s e
                   if not check 
                     then fail "Invalid range parameters"
                     else return [read s, read e]
          else fail "Invalid Input: -p n or -p s-e"

checkInterval :: String -> String -> Bool
checkInterval s e
  | (read s :: Int) > (read e :: Int) = False
  | otherwise = True

checkPortInRange :: String -> Bool
checkPortInRange s
  | pn < 0 || pn > 65535 = False
  | otherwise = True
  where pn = read s :: Int

verbose :: Parser Bool
verbose = switch (short 'v' <> long "verbose" <> help "Verbose output")
