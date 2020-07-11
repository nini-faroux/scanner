{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

module Options where

import Import
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
portReader = eitherReader (P.parseOnly parsePortArgs . BS8.pack)

parsePortArgs :: P.Parser [PortNumber]
parsePortArgs = do
  s <- AC.decimal
  n <- P.peekWord8
  if isNothing n
    then case singlePortArg s of
            Left err -> failPort err
            Right ps -> return ps
    else do
      d <- AC.take 1
      if d /= "-"
        then failPort InvalidPortFormat
        else do
          e <- AC.decimal
          n' <- P.peekWord8
          if isNothing n'
            then case multipleArgsPort s e of
                    Left err -> failPort err
                    Right ps -> return ps
            else failPort InvalidPortFormat

failPort :: PortError -> P.Parser [PortNumber]
failPort pe = fail $ show pe

singlePortArg :: Integer -> Either PortError [PortNumber]
singlePortArg n
  | n > 65535 = Left InvalidPortNumber
  | otherwise = Right [fromIntegral n]

multipleArgsPort :: Integer -> Integer -> Either PortError [PortNumber]
multipleArgsPort s e
  | s > e = Left InvalidPortRange
  | e > 65535 = Left InvalidPortNumber
  | otherwise = Right [fromIntegral s, fromIntegral e]

verbose :: Parser Bool
verbose = switch (short 'v' <> long "verbose" <> help "Verbose output")
