module SayableAge.Types
    ( PluralCategory(..)
    , UnitForms(..)
    , Compactness(..)
    , CompactnessOverride(..)
    , Gender(..)
    , StageLabel(..)
    , Stages(..)
    , Locale(..)
    , resolveStageLabel
    , lookupUnitForm
    ) where

data PluralCategory = Zero | One | Two | Few | Many | Other
    deriving (Eq, Show)

data UnitForms = Simple String | Pluralized [(PluralCategory, String)]

data Compactness = Normal | Short | Compact
    deriving (Eq)

data CompactnessOverride = CompactnessOverride
    { ovrDay       :: Maybe UnitForms
    , ovrWeek      :: Maybe UnitForms
    , ovrMonth     :: Maybe UnitForms
    , ovrYear      :: Maybe UnitForms
    , ovrHalf      :: Maybe String
    , ovrDelimiter :: Maybe String
    , ovrJustBorn  :: Maybe String
    }

data Gender = M | F
    deriving (Eq, Show)

data StageLabel = Neutral String | Gendered String String

data Stages = Stages
    { stageNewborn  :: StageLabel
    , stageInfant   :: StageLabel
    , stageToddler  :: StageLabel
    , stageChild    :: StageLabel
    , stageTeenager :: StageLabel
    , stageAdult    :: StageLabel
    }

data Locale = Locale
    { localeCode      :: String
    , localePlural    :: Int -> PluralCategory
    , localeDay       :: UnitForms
    , localeWeek      :: UnitForms
    , localeMonth     :: UnitForms
    , localeYear      :: UnitForms
    , localeHalf      :: String
    , localeDelimiter :: String
    , localeJustBorn  :: String
    , localeStages    :: Stages
    , localeShort     :: Maybe CompactnessOverride
    , localeCompact   :: Maybe CompactnessOverride
    }

instance Show Locale where
    show loc = "Locale {localeCode = " ++ show (localeCode loc) ++ "}"

resolveStageLabel :: StageLabel -> Maybe Gender -> String
resolveStageLabel (Neutral s) _        = s
resolveStageLabel (Gendered _ f) (Just F) = f
resolveStageLabel (Gendered m _) _     = m

lookupUnitForm :: PluralCategory -> [(PluralCategory, String)] -> String
lookupUnitForm cat forms =
    case lookup cat forms of
        Just s  -> s
        Nothing -> case lookup Other forms of
            Just s  -> s
            Nothing -> ""
