module Dns where

import Network.DNS
import Data.IP (IPv4)
import qualified Data.ByteString.Char8 as BS8

lookupIPv4 :: BS8.ByteString -> IO (Either DNSError [IPv4])
lookupIPv4 hostName = do
    rs <- makeResolvSeed defaultResolvConf
    withResolver rs $ \resolver -> lookupA resolver hostName
