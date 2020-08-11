{-# LANGUAGE OverloadedStrings #-}

module Banner.Http where

import Import
import Network.HTTP.Client
import qualified RIO.ByteString as B

generalRequest :: String -> Int -> IO [B.ByteString]
generalRequest req portNum = do
  initReq <- parseRequest req
  let req' = initReq { port = portNum }
  response <- httpLBS req'
  return $ getResponseHeader "Server" response

httpDefault :: Request -> IO [B.ByteString]
httpDefault req = do
    response <- httpLBS req
    return $ getResponseHeader "Server" response

sshService :: String -> IO [B.ByteString]
sshService req = generalRequest req 22

scanme :: String
scanme = "http://scanme.nmap.org"
