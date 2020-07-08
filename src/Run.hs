{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleInstances #-}
module Run (run) where

import Import
import Dns
import Scanner

run :: RIO App ()
run = do
  app <- ask
  let host = targetHost $ appOptions app
  let port = targetPort $ appOptions app
  ipv4 <- liftIO $ lookupIPv4 host
  case ipv4 of
      Left err -> logInfo $ displayShow err <> ": Host not found"
      Right ip' -> do 
        logInfo $ "Host: " <> displayShow host <> ", IP: " <> displayShow ip'
        let ip = ipToAddress ip'
        isOpen <- liftIO $ checkPort ip port
        if isOpen then logInfo $ "Port " <> displayShow port <> " is open"
                  else logInfo $ "Port " <> displayShow port <> " is closed"
