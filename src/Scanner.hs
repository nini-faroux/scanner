{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

module Scanner where

import Import
import qualified RIO.List as L
import GHC.IO.Exception (IOException(..))
import Foreign.C.Error (Errno(..), eCONNREFUSED)

getOpenPortsConcurrently :: IPAddress -> [PortNumber] -> IO [(PortNumber, PortStatus)]
getOpenPortsConcurrently address ps = do
  ps' <- getPortStatusConcurrently address ps
  return $ filter (\(_, s) -> s == Open) ps'

getPortStatusConcurrently :: IPAddress -> [PortNumber] -> IO [(PortNumber, PortStatus)]
getPortStatusConcurrently address = do
    pooledMapConcurrentlyN 100 (\p -> checkPortOpen address p >>= \s -> if s then return (p, Open) else return (p, Closed))

checkPortOpen :: IPAddress -> PortNumber -> IO Bool
checkPortOpen address port = do
  bracket (socket AF_INET Stream 6) close' $ \socket' -> do
       response <- connectSocket socket' address port 500000
       case response of
           Nothing -> return False
           Just (Right ()) -> return True
           Just (Left err) -> 
             if (Errno <$> ioe_errno err) == Just eCONNREFUSED
               then return False
               else throwIO err

connectSocket :: Exception e => Socket -> IPAddress -> PortNumber -> Int -> IO (Maybe (Either e ()))
connectSocket socket' address port delay = timeout delay $ try $ connect socket' sockAddr
  where
    sockAddr = SockAddrInet port $ tupleToHostAddress address

portListFromRange :: PortNumber -> PortNumber -> [PortNumber]
portListFromRange start end = take range $ L.unfoldr (\b -> Just (b, b + 1)) start
  where
    range 
      | start == end = 1
      | otherwise = fromIntegral $ (end - start) + 1

