{-# LANGUAGE NoImplicitPrelude #-}
module Types where

import RIO
import RIO.Process
import qualified Data.ByteString.Char8 as BS8

-- | Command line arguments
data Options = Options
  { targetHost :: !BS8.ByteString
  , optionsVerbose :: !Bool
  }

data App = App
  { appLogFunc :: !LogFunc
  , appProcessContext :: !ProcessContext
  , appOptions :: !Options
  -- Add other app-specific configuration information here
  }

instance HasLogFunc App where
  logFuncL = lens appLogFunc (\x y -> x { appLogFunc = y })
instance HasProcessContext App where
  processContextL = lens appProcessContext (\x y -> x { appProcessContext = y })

type IPAddress = (Word8, Word8, Word8, Word8)
