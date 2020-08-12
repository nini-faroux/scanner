{-# LANGUAGE NoImplicitPrelude #-}

module Scanner.Network.Util where

import Import

ipToAddress :: [IPv4] -> IPAddress
ipToAddress = listToIPAddress . intsToWords . fromIPv4 . head'

intsToWords :: [Int] -> [Word8]
intsToWords = map fromIntegral

listToIPAddress :: [Word8] -> IPAddress
listToIPAddress [a,b,c,d] = IPAddress a b c d

head' :: [a] -> a
head' (x:_) = x
