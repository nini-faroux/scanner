{-# LANGUAGE NoImplicitPrelude #-}

module Dns where

import Import
import qualified RIO.ByteString as BS

lookupIPv4 :: BS.ByteString -> IO (Either DNSError [IPv4])
lookupIPv4 hostName = do
    rs <- makeResolvSeed defaultResolvConf
    withResolver rs $ \resolver -> lookupA resolver hostName
