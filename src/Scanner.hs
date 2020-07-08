{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

module Scanner where

import Import

import    GHC.IO.Exception (IOException(..))
import    Foreign.C.Error (Errno(..), eCONNREFUSED)

checkPort :: IPAddress -> PortNumber -> IO Bool
checkPort address port = do
  let socketAddress = SockAddrInet port $ tupleToHostAddress address
  bracket (socket AF_INET Stream 6) close' $ \socket' -> do
    response <- try $ connect socket' socketAddress
    case response of
      Right () -> return True
      Left err ->
        if (Errno <$> ioe_errno err) == Just eCONNREFUSED
          then return False
          else throwIO err
