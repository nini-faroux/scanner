{-# LANGUAGE NoImplicitPrelude #-}

module Dns where

import Import
import Network.DNS
import qualified Data.ByteString.Char8 as BS8

lookupIPv4 :: BS8.ByteString -> IO (Either DNSError [IPv4])
lookupIPv4 hostName = do
    rs <- makeResolvSeed defaultResolvConf
    withResolver rs $ \resolver -> lookupA resolver hostName

ipToAddress :: [IPv4] -> IPAddress
ipToAddress = listToTuple . intsToWords . fromIPv4 . head'

intsToWords :: [Int] -> [Word8]
intsToWords = map fromIntegral

listToTuple :: [Word8] -> IPAddress
listToTuple [a,b,c,d] = (a, b, c, d)

head' :: [a] -> a
head' (x:_) = x
