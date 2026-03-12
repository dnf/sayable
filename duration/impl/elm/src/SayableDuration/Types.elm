module SayableDuration.Types exposing
    ( Compactness(..)
    , CompactnessOverride
    , Locale
    , PluralCategory(..)
    , UnitForms(..)
    , lookupUnitForm
    )

import Dict exposing (Dict)


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


type alias CompactnessOverride =
    { ovrUnits : Maybe (Dict String UnitForms)
    , ovrHalf : Maybe String
    , ovrDelimiter : Maybe String
    , ovrAgo : Maybe String
    , ovrInFuture : Maybe String
    }


type alias Locale =
    { code : String
    , plural : Int -> PluralCategory
    , units : Dict String UnitForms
    , half : String
    , delimiter : String
    , justNow : String
    , ago : String
    , inFuture : String
    , short : Maybe CompactnessOverride
    , compact : Maybe CompactnessOverride
    }


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
