{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

module Scanner where

import Import
import GHC.IO.Exception (IOException(..))
import Foreign.C.Error (Errno(..), eCONNREFUSED)

getOpenPorts :: IPAddress -> [PortNumber] -> IO [PortNumber]
getOpenPorts address ps = 
  foldM (\acc p -> checkPort address p >>= \s -> if s then return (p : acc) else return acc) [] ps >>= \ps' -> return $ reverse ps'

checkPort :: IPAddress -> PortNumber -> IO Bool
checkPort address port = do
  let socketAddress = SockAddrInet port $ tupleToHostAddress address
  bracket (socket AF_INET Stream 6) close' $ \socket' -> do
       response <- timeout 500000 $ try $ connect socket' socketAddress
       case response of
           Nothing -> return False
           Just (Right ()) -> return True
           Just (Left err) -> 
             if (Errno <$> ioe_errno err) == Just eCONNREFUSED
               then return False
               else throwIO err
