{-# LANGUAGE NoImplicitPrelude #-}
module Scanner.Types where

import RIO
import RIO.Process
import Network.Socket
import qualified Data.ByteString.Char8 as BS8

-- | Command line arguments
data Options = Options
  { targetHost :: !BS8.ByteString
  , targetPort :: NonEmpty PortNumber
  , optionsVerbose :: !Bool
  }

data App = App
  { appLogFunc :: !LogFunc
  , appProcessContext :: !ProcessContext
  , appOptions :: !Options
  }

instance HasLogFunc App where
  logFuncL = lens appLogFunc (\x y -> x { appLogFunc = y })
instance HasProcessContext App where
  processContextL = lens appProcessContext (\x y -> x { appProcessContext = y })

data PortError =
    InvalidPortNumber
  | InvalidPortFormat
  | InvalidPortRange
instance Show PortError where
  show InvalidPortNumber = "Invalid Port Argument: Port Numbers must be between 0 and 65535"
  show InvalidPortFormat = "Invalid Port Format, usage: -p <portnumber> or -p <startOfRange>-<endOfRange>"
  show InvalidPortRange = "Invalid Port Range: Start of range must be less than or equal to end of range"

data PortStatus =
    Open
  | Closed
  deriving (Eq, Show)

type IPAddress = (Word8, Word8, Word8, Word8)
