{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleInstances #-}
module Run (run) where

import Import

run :: RIO App ()
run = do
  app <- ask
  let host = targetHost $ appOptions app
  ipv4 <- liftIO $ lookupIPv4 host
  case ipv4 of
      Left err -> logInfo $ displayShow err
      Right ip -> logInfo $ "host: " <> displayShow host <> ", ip: " <> displayShow ip
