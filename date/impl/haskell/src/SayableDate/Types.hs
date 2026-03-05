module SayableDate.Types
    ( Compactness(..)
    , CompactnessOverride(..)
    , DateLocale(..)
    ) where

data Compactness = Normal | Short | Compact
    deriving (Eq)

data CompactnessOverride = CompactnessOverride
    { ovrMonths              :: Maybe [String]
    , ovrMonthsInDate        :: Maybe [String]
    , ovrWeekdays            :: Maybe [String]
    , ovrDayFormat           :: Maybe String
    , ovrDayFormatExceptions :: Maybe [(String, String)]
    , ovrDatePattern         :: Maybe String
    , ovrDatePatternWithYear :: Maybe String
    , ovrToday               :: Maybe String
    , ovrTomorrow            :: Maybe String
    , ovrYesterday           :: Maybe String
    }

data DateLocale = DateLocale
    { localeCode                :: String
    , localeMonths              :: [String]
    , localeWeekdays            :: [String]
    , localeDayFormat           :: String
    , localeDayFormatExceptions :: [(String, String)]
    , localeDatePattern         :: String
    , localeDatePatternWithYear :: String
    , localeToday               :: String
    , localeTomorrow            :: String
    , localeYesterday           :: String
    , localeDayAfterTomorrow    :: Maybe String
    , localeDayBeforeYesterday  :: Maybe String
    , localeThisWeekday         :: Maybe String
    , localeNextWeekday         :: Maybe String
    , localeLastWeekday         :: Maybe String
    , localeMonthsInDate        :: Maybe [String]
    , localeShort               :: Maybe CompactnessOverride
    , localeCompact             :: Maybe CompactnessOverride
    }

instance Show DateLocale where
    show loc = "DateLocale {localeCode = " ++ show (localeCode loc) ++ "}"
