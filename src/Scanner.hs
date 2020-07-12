{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}

module Scanner where

import Import
import qualified Data.List.NonEmpty as L
import GHC.IO.Exception (IOException(..))
import Foreign.C.Error (Errno(..), eCONNREFUSED)

getOpenPortsConcurrently :: IPAddress -> NonEmpty PortNumber -> IO (NonEmpty (PortNumber, PortStatus))
getOpenPortsConcurrently address ps = do
  ps' <- getPortStatusConcurrently address ps
  return . L.fromList $ L.filter (\(_, s) -> s == Open) ps'

getPortStatusConcurrently :: IPAddress -> NonEmpty PortNumber -> IO (NonEmpty (PortNumber, PortStatus))
getPortStatusConcurrently address = do
    pooledMapConcurrentlyN 100 (\p -> checkPortOpen address p >>= \s -> if s then return (p, Open) else return (p, Closed))

getPortStatusSync :: IPAddress -> [PortNumber] -> IO [PortNumber]
getPortStatusSync address ps = 
  foldM (\acc p -> checkPortOpen address p >>= \s -> if s then return (p : acc) else return acc) [] ps >>= \ps' -> return $ reverse ps'

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
