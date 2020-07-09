{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
module Run (run) where

import Import
import qualified RIO.List.Partial as L'
import Dns
import Scanner

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
        if length ports == 1
          then do 
            isOpen <- liftIO $ checkPort ip (L'.head ports)
            if isOpen then logInfo $ "Port " <> displayShow ports <> " is open"
                      else logInfo $ "Port " <> displayShow ports <> " is closed"
        else do
          statuses <- liftIO $ getOpenPorts ip [L'.head ports..L'.last ports]
          logInfo $ displayShow statuses
