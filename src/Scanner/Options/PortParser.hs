{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

module Scanner.Options.PortParser where

import Import
import qualified RIO.Text as T
import qualified Data.Attoparsec.ByteString as P
import qualified Data.Attoparsec.ByteString.Char8 as AC

portTarget :: Parser (NonEmpty PortNumber)
portTarget = option portReader (short 'p' <> long "port" <> help "Check single port or range of ports")

portReader :: ReadM (NonEmpty PortNumber)
portReader = eitherReader (P.parseOnly parsePortArgs . T.encodeUtf8 . T.pack)

parsePortArgs :: P.Parser (NonEmpty PortNumber)
parsePortArgs = do
  s <- AC.decimal
  n <- P.peekWord8
  if isNothing n
    then runCheckPortArgs s s
    else do
      d <- AC.take 1
      if d /= "-"
        then failPort InvalidPortFormat
        else portArgSequence s

portArgSequence :: Integer -> P.Parser (NonEmpty PortNumber)
portArgSequence s = do
  e <- AC.decimal
  n' <- P.peekWord8
  if isNothing n'
    then runCheckPortArgs s e
    else failPort InvalidPortFormat

runCheckPortArgs :: Integer -> Integer -> P.Parser (NonEmpty PortNumber)
runCheckPortArgs s e = 
  case checkPortArgs s e of
      Left err -> failPort err
      Right ps -> return ps

checkPortArgs :: Integer -> Integer -> Either PortError (NonEmpty PortNumber)
checkPortArgs s e
  | s > e = Left InvalidPortRange
  | s > 65535 || e > 65535 = Left InvalidPortNumber
  | otherwise = Right $ fromIntegral s :| [fromIntegral e]

failPort :: PortError -> P.Parser (NonEmpty PortNumber)
failPort pe = fail $ show pe
