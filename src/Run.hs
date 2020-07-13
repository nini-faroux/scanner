{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
module Run (run) where

import Import
import Util
import Dns
import Scanner
import qualified Data.List.NonEmpty as L

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
        statuses <- liftIO $ getOpenPortsConcurrently ip (L.fromList [L.head ports..L.last ports])
        logInfo $ displayShow statuses
