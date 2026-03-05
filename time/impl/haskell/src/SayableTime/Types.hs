module SayableTime.Types
    ( ClockConfig(..)
    , ShortClockConfig(..)
    , CompactnessOverride(..)
    , Compactness(..)
    , TimeLocale(..)
    ) where

data ClockConfig = ClockConfig
    { clockHours    :: [String]
    , clockMidnight :: String
    , clockNoon     :: String
    , clockPatterns :: [(Int, String)]
    }

data ShortClockConfig = ShortClockConfig
    { shortUse24h :: Bool
    , shortAmPm   :: Maybe (String, String)
    , shortFormat  :: String
    }

data CompactnessOverride = CompactnessOverride
    { ovrClock :: Maybe ShortClockConfig
    }

data Compactness = Normal | Short | Compact
    deriving (Eq)

data TimeLocale = TimeLocale
    { localeCode    :: String
    , localeClock   :: ClockConfig
    , localeShort   :: Maybe CompactnessOverride
    , localeCompact :: Maybe CompactnessOverride
    }

instance Show TimeLocale where
    show loc = "TimeLocale {localeCode = " ++ show (localeCode loc) ++ "}"
