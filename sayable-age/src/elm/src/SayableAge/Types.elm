module SayableAge.Types exposing
    ( Compactness(..)
    , CompactnessOverride
    , Gender(..)
    , Locale
    , PluralCategory(..)
    , StageLabel(..)
    , Stages
    , UnitForms(..)
    , lookupUnitForm
    , resolveStageLabel
    )


type PluralCategory
    = Zero
    | One
    | Two
    | Few
    | Many
    | Other


type UnitForms
    = Simple String
    | Pluralized (List ( PluralCategory, String ))


type Compactness
    = Normal
    | Short
    | Compact


type Gender
    = M
    | F


type StageLabel
    = Neutral String
    | Gendered String String


type alias Stages =
    { newborn : StageLabel
    , infant : StageLabel
    , toddler : StageLabel
    , child : StageLabel
    , teenager : StageLabel
    , adult : StageLabel
    }


type alias CompactnessOverride =
    { ovrDay : Maybe UnitForms
    , ovrWeek : Maybe UnitForms
    , ovrMonth : Maybe UnitForms
    , ovrYear : Maybe UnitForms
    , ovrHalf : Maybe String
    , ovrDelimiter : Maybe String
    , ovrJustBorn : Maybe String
    }


type alias Locale =
    { code : String
    , plural : Int -> PluralCategory
    , day : UnitForms
    , week : UnitForms
    , month : UnitForms
    , year : UnitForms
    , half : String
    , delimiter : String
    , justBorn : String
    , stages : Stages
    , short : Maybe CompactnessOverride
    , compact : Maybe CompactnessOverride
    }


resolveStageLabel : StageLabel -> Maybe Gender -> String
resolveStageLabel label gender =
    case label of
        Neutral s ->
            s

        Gendered m f ->
            case gender of
                Just F ->
                    f

                _ ->
                    m


lookupUnitForm : PluralCategory -> List ( PluralCategory, String ) -> String
lookupUnitForm cat forms =
    case findForm cat forms of
        Just s ->
            s

        Nothing ->
            case findForm Other forms of
                Just s ->
                    s

                Nothing ->
                    ""


findForm : PluralCategory -> List ( PluralCategory, String ) -> Maybe String
findForm cat forms =
    case forms of
        [] ->
            Nothing

        ( c, s ) :: rest ->
            if c == cat then
                Just s

            else
                findForm cat rest
