module ParentTime.Formatter exposing (formatAge, formatStage, version)

import ParentTime.Internal exposing (computeAge)
import ParentTime.Types
    exposing
        ( Compactness(..)
        , CompactnessOverride
        , Gender
        , Locale
        , StageLabel
        , UnitForms(..)
        , lookupUnitForm
        , resolveStageLabel
        )


version : String
version =
    "0.5.0"


formatAge : Locale -> Compactness -> String -> String -> Maybe String
formatAge loc compactness dob asOf =
    if String.isEmpty dob then
        Nothing

    else
        case computeAge dob asOf of
            Nothing ->
                Nothing

            Just ( months, diffDays ) ->
                if months > 6000 then
                    Nothing

                else
                    let
                        resolved =
                            resolveLocale loc compactness
                    in
                    Just (formatTier loc resolved months diffDays)


formatStage : Locale -> String -> String -> Maybe Gender -> Maybe String
formatStage loc dob asOf gender =
    if String.isEmpty dob then
        Nothing

    else
        case computeAge dob asOf of
            Nothing ->
                Nothing

            Just ( months, _ ) ->
                let
                    label =
                        stageLabel loc.stages months
                in
                Just (resolveStageLabel label gender)


type alias Resolved =
    { day : UnitForms
    , week : UnitForms
    , month : UnitForms
    , year : UnitForms
    , half : String
    , delimiter : String
    , justBorn : String
    }


resolveLocale : Locale -> Compactness -> Resolved
resolveLocale loc compactness =
    let
        mOvr =
            case compactness of
                Normal ->
                    Nothing

                Short ->
                    loc.short

                Compact ->
                    loc.compact
    in
    case mOvr of
        Nothing ->
            { day = loc.day
            , week = loc.week
            , month = loc.month
            , year = loc.year
            , half = loc.half
            , delimiter = loc.delimiter
            , justBorn = loc.justBorn
            }

        Just ovr ->
            { day = Maybe.withDefault loc.day ovr.ovrDay
            , week = Maybe.withDefault loc.week ovr.ovrWeek
            , month = Maybe.withDefault loc.month ovr.ovrMonth
            , year = Maybe.withDefault loc.year ovr.ovrYear
            , half = Maybe.withDefault loc.half ovr.ovrHalf
            , delimiter = Maybe.withDefault loc.delimiter ovr.ovrDelimiter
            , justBorn = Maybe.withDefault loc.justBorn ovr.ovrJustBorn
            }


formatTier : Locale -> Resolved -> Int -> Int -> String
formatTier loc r months diffDays =
    if diffDays == 0 then
        r.justBorn

    else if diffDays < 7 then
        resolveUnit diffDays r.day loc ""

    else if months < 3 then
        let
            weeks =
                diffDays // 7

            days =
                modBy 7 diffDays

            wStr =
                resolveUnit weeks r.week loc ""
        in
        if days > 0 then
            wStr ++ r.delimiter ++ resolveUnit days r.day loc ""

        else
            wStr

    else if months < 24 then
        resolveUnit months r.month loc ""

    else if months < 36 then
        let
            years =
                months // 12

            rem =
                modBy 12 months

            yStr =
                resolveUnit years r.year loc ""
        in
        if rem == 0 then
            yStr

        else
            yStr ++ r.delimiter ++ resolveUnit rem r.month loc ""

    else if months < 84 then
        let
            years =
                months // 12

            rem =
                modBy 12 months
        in
        if rem >= 6 then
            resolveUnit years r.year loc r.half

        else
            resolveUnit years r.year loc ""

    else
        let
            years =
                months // 12
        in
        resolveUnit years r.year loc ""


resolveUnit : Int -> UnitForms -> Locale -> String -> String
resolveUnit count uf loc half =
    let
        baseN =
            String.fromInt count

        n =
            if not (String.isEmpty half) && String.contains "{n}" half then
                String.replace "{n}" baseN half

            else
                baseN

        template =
            case uf of
                Simple s ->
                    s

                Pluralized forms ->
                    lookupUnitForm (loc.plural count) forms

        result =
            String.replace "{n}" n template
    in
    if not (String.isEmpty half) && String.contains "{0}" half then
        String.replace "{0}" result half

    else
        result


stageLabel : ParentTime.Types.Stages -> Int -> StageLabel
stageLabel stages months =
    if months < 2 then
        stages.newborn

    else if months < 12 then
        stages.infant

    else if months < 36 then
        stages.toddler

    else if months < 156 then
        stages.child

    else if months < 216 then
        stages.teenager

    else
        stages.adult
