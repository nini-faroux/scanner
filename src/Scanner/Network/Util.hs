{-# LANGUAGE NoImplicitPrelude #-}

module Scanner.Network.Util where

import Import

ipToAddress :: [IPv4] -> IPAddress
ipToAddress = listToTuple . intsToWords . fromIPv4 . head'

intsToWords :: [Int] -> [Word8]
intsToWords = map fromIntegral

listToTuple :: [Word8] -> IPAddress
listToTuple [a,b,c,d] = (a, b, c, d)

head' :: [a] -> a
head' (x:_) = x
