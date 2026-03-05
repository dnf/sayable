module SayableDuration.Types
    ( PluralCategory(..)
    , UnitForms(..)
    , Compactness(..)
    , CompactnessOverride(..)
    , Units(..)
    , DurationLocale(..)
    , lookupUnitForm
    ) where

data PluralCategory = Zero | One | Two | Few | Many | Other
    deriving (Eq, Show)

data UnitForms = Simple String | Pluralized [(PluralCategory, String)]

data Compactness = Normal | Short | Compact
    deriving (Eq)

data Units = Units
    { unitSecond :: UnitForms
    , unitMinute :: UnitForms
    , unitHour   :: UnitForms
    , unitDay    :: UnitForms
    , unitWeek   :: UnitForms
    , unitMonth  :: UnitForms
    , unitYear   :: UnitForms
    }

data CompactnessOverride = CompactnessOverride
    { ovrSecond    :: Maybe UnitForms
    , ovrMinute    :: Maybe UnitForms
    , ovrHour      :: Maybe UnitForms
    , ovrDay       :: Maybe UnitForms
    , ovrWeek      :: Maybe UnitForms
    , ovrMonth     :: Maybe UnitForms
    , ovrYear      :: Maybe UnitForms
    , ovrHalf      :: Maybe String
    , ovrDelimiter :: Maybe String
    , ovrAgo       :: Maybe String
    , ovrInFuture  :: Maybe String
    }

data DurationLocale = DurationLocale
    { localeCode      :: String
    , localePlural    :: Int -> PluralCategory
    , localeUnits     :: Units
    , localeHalf      :: String
    , localeDelimiter :: String
    , localeJustNow   :: String
    , localeAgo       :: String
    , localeInFuture  :: String
    , localeShort     :: Maybe CompactnessOverride
    , localeCompact   :: Maybe CompactnessOverride
    }

instance Show DurationLocale where
    show loc = "DurationLocale {localeCode = " ++ show (localeCode loc) ++ "}"

lookupUnitForm :: PluralCategory -> [(PluralCategory, String)] -> String
lookupUnitForm cat forms =
    case lookup cat forms of
        Just s  -> s
        Nothing -> case lookup Other forms of
            Just s  -> s
            Nothing -> ""
