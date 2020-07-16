{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
module Run (run) where

import Import
import Util
import Dns
import Scanner
import qualified RIO.NonEmpty as NE

run :: RIO App ()
run = do
  app <- ask
  let host = targetHost $ appOptions app
  let ports = targetPort $ appOptions app
  ipv4 <- liftIO $ lookupIPv4 host
  case ipv4 of
      Left err -> logInfo $ displayShow err <> ": Host not found"
      Right ip' -> do 
        logInfo $ "Host: " <> displayShow host <> ", IP: " <> displayShow ip'
        let ip = ipToAddress ip'
        statuses <- liftIO $ getOpenPortsConcurrently ip (portListFromRange (NE.head ports) (NE.last ports))
        logInfo $ displayShow statuses
