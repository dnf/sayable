module SayableDuration.Formatter exposing (formatDuration, formatDurationTimestamps, formatSince, formatUntil, version)

import Dict
import SayableDuration.Internal exposing (parseIsoToSeconds)
import SayableDuration.Types
    exposing
        ( Compactness(..)
        , CompactnessOverride
        , Locale
        , UnitForms(..)
        , lookupUnitForm
        )


version : String
version =
    "0.5.0"


type alias Resolved =
    { units : Dict.Dict String UnitForms
    , half : String
    , delimiter : String
    , justNow : String
    , ago : String
    , inFuture : String
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
            { units = loc.units
            , half = loc.half
            , delimiter = loc.delimiter
            , justNow = loc.justNow
            , ago = loc.ago
            , inFuture = loc.inFuture
            }

        Just ovr ->
            let
                mergedUnits =
                    case ovr.ovrUnits of
                        Just ovrU ->
                            Dict.foldl
                                (\k v acc -> Dict.insert k v acc)
                                loc.units
                                ovrU

                        Nothing ->
                            loc.units
            in
            { units = mergedUnits
            , half = Maybe.withDefault loc.half ovr.ovrHalf
            , delimiter = Maybe.withDefault loc.delimiter ovr.ovrDelimiter
            , justNow = loc.justNow
            , ago = Maybe.withDefault loc.ago ovr.ovrAgo
            , inFuture = Maybe.withDefault loc.inFuture ovr.ovrInFuture
            }


formatDuration : Locale -> Compactness -> Int -> Maybe String
formatDuration loc compactness seconds =
    if seconds < 0 then
        Nothing

    else
        let
            r =
                resolveLocale loc compactness
        in
        Just (formatDurationSeconds loc r seconds)


formatDurationTimestamps : Locale -> Compactness -> String -> String -> Maybe String
formatDurationTimestamps loc compactness start end =
    if String.isEmpty start || String.isEmpty end then
        Nothing

    else
        case ( parseIsoToSeconds start, parseIsoToSeconds end ) of
            ( Just s, Just e ) ->
                let
                    totalSeconds =
                        abs (e - s)

                    r =
                        resolveLocale loc compactness
                in
                Just (formatDurationSeconds loc r totalSeconds)

            _ ->
                Nothing


formatSince : Locale -> Compactness -> String -> String -> Maybe String
formatSince loc compactness start asOf =
    if String.isEmpty start || String.isEmpty asOf then
        Nothing

    else
        case ( parseIsoToSeconds start, parseIsoToSeconds asOf ) of
            ( Just s, Just a ) ->
                let
                    diff =
                        a - s
                in
                if diff < 0 then
                    Nothing

                else if diff == 0 then
                    let
                        r =
                            resolveLocale loc compactness
                    in
                    Just r.justNow

                else
                    let
                        r =
                            resolveLocale loc compactness

                        dur =
                            formatDurationSeconds loc r diff
                    in
                    Just (String.replace "{0}" dur r.ago)

            _ ->
                Nothing


formatUntil : Locale -> Compactness -> String -> String -> Maybe String
formatUntil loc compactness target asOf =
    if String.isEmpty target || String.isEmpty asOf then
        Nothing

    else
        case ( parseIsoToSeconds target, parseIsoToSeconds asOf ) of
            ( Just t, Just a ) ->
                let
                    diff =
                        t - a
                in
                if diff < 0 then
                    Nothing

                else if diff == 0 then
                    let
                        r =
                            resolveLocale loc compactness
                    in
                    Just r.justNow

                else
                    let
                        r =
                            resolveLocale loc compactness

                        dur =
                            formatDurationSeconds loc r diff
                    in
                    Just (String.replace "{0}" dur r.inFuture)

            _ ->
                Nothing


formatDurationSeconds : Locale -> Resolved -> Int -> String
formatDurationSeconds loc r total =
    if total == 0 then
        r.justNow

    else if total < 60 then
        resolveUnit total "second" loc r ""

    else
        let
            totalMinutes =
                total // 60

            remainderSeconds =
                modBy 60 total
        in
        if totalMinutes < 5 then
            let
                result =
                    resolveUnit totalMinutes "minute" loc r ""
            in
            if remainderSeconds > 0 then
                result ++ r.delimiter ++ resolveUnit remainderSeconds "second" loc r ""

            else
                result

        else if totalMinutes < 60 then
            resolveUnit totalMinutes "minute" loc r ""

        else
            let
                totalHours =
                    total // 3600

                remainderMinutes =
                    modBy 3600 total // 60
            in
            if totalHours <= 5 then
                if remainderMinutes == 30 then
                    resolveUnit totalHours "hour" loc r r.half

                else
                    let
                        result =
                            resolveUnit totalHours "hour" loc r ""
                    in
                    if remainderMinutes > 0 then
                        result ++ r.delimiter ++ resolveUnit remainderMinutes "minute" loc r ""

                    else
                        result

            else if totalHours < 24 then
                resolveUnit totalHours "hour" loc r ""

            else
                let
                    totalDays =
                        total // 86400

                    remainderHours =
                        modBy 86400 total // 3600
                in
                if totalDays <= 2 then
                    if remainderHours == 12 then
                        resolveUnit totalDays "day" loc r r.half

                    else
                        let
                            result =
                                resolveUnit totalDays "day" loc r ""
                        in
                        if remainderHours > 0 then
                            result ++ r.delimiter ++ resolveUnit remainderHours "hour" loc r ""

                        else
                            result

                else if totalDays < 7 then
                    resolveUnit totalDays "day" loc r ""

                else if totalDays < 30 then
                    let
                        totalWeeks =
                            totalDays // 7

                        remainderDays =
                            modBy 7 totalDays

                        result =
                            resolveUnit totalWeeks "week" loc r ""
                    in
                    if remainderDays > 0 then
                        result ++ r.delimiter ++ resolveUnit remainderDays "day" loc r ""

                    else
                        result

                else
                    let
                        totalMonths =
                            round (toFloat totalDays / 30.44)

                        effectiveMonths =
                            if totalMonths == 0 then
                                1

                            else
                                totalMonths
                    in
                    if effectiveMonths < 12 then
                        resolveUnit effectiveMonths "month" loc r ""

                    else
                        let
                            totalYears =
                                effectiveMonths // 12

                            remainderMonths =
                                modBy 12 effectiveMonths

                            result =
                                resolveUnit totalYears "year" loc r ""
                        in
                        if remainderMonths > 0 then
                            result ++ r.delimiter ++ resolveUnit remainderMonths "month" loc r ""

                        else
                            result


resolveUnit : Int -> String -> Locale -> Resolved -> String -> String
resolveUnit count unitName loc r half =
    let
        uf =
            Dict.get unitName r.units

        baseN =
            String.fromInt count

        n =
            if not (String.isEmpty half) && String.contains "{n}" half then
                String.replace "{n}" baseN half

            else
                baseN

        template =
            case uf of
                Just (Simple s) ->
                    s

                Just (Pluralized forms) ->
                    let
                        category =
                            if not (String.isEmpty half) then
                                SayableDuration.Types.Other

                            else
                                loc.plural count
                    in
                    lookupUnitForm category forms

                Nothing ->
                    "{n}"

        result =
            String.replace "{n}" n template
    in
    if not (String.isEmpty half) && String.contains "{0}" half then
        String.replace "{0}" result half

    else
        result
