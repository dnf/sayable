module SayableTime.Formatter exposing (formatTime, version)

import Dict
import SayableTime.Internal exposing (parseTime, roundTo5)
import SayableTime.Types
    exposing
        ( Compactness(..)
        , CompactnessOverride
        , Locale
        , ShortClockConfig
        )


version : String
version =
    "0.5.0"


formatTime : Locale -> Compactness -> String -> Maybe String
formatTime loc compactness input =
    if String.isEmpty input then
        Nothing

    else
        case parseTime input of
            Nothing ->
                Nothing

            Just ( hour, minute ) ->
                let
                    mOvr =
                        case compactness of
                            Normal ->
                                Nothing

                            Short ->
                                loc.short

                            Compact ->
                                loc.compact

                    shortClock =
                        mOvr |> Maybe.andThen .clock
                in
                if compactness /= Normal && shortClock /= Nothing then
                    shortClock
                        |> Maybe.map (formatDigital hour minute)

                else
                    Just (formatNatural loc hour minute)


formatNatural : Locale -> Int -> Int -> String
formatNatural loc hour minute =
    let
        clock =
            loc.clock

        rounded =
            roundTo5 minute

        adjustedRounded =
            if rounded == 60 then
                0

            else
                rounded

        adjustedHour =
            if rounded == 60 then
                modBy 24 (hour + 1)

            else
                hour
    in
    if adjustedRounded == 0 then
        if adjustedHour == 0 then
            clock.midnight

        else if adjustedHour == 12 then
            clock.noon

        else
            let
                h12 =
                    modBy 12 adjustedHour

                hName =
                    listGet h12 clock.hours |> Maybe.withDefault ""

                pattern =
                    Dict.get 0 clock.patterns |> Maybe.withDefault "{h}"
            in
            String.replace "{h}" hName pattern

    else
        let
            h12 =
                modBy 12 adjustedHour

            nextH12 =
                modBy 12 (adjustedHour + 1)

            hName =
                listGet h12 clock.hours |> Maybe.withDefault ""

            nextHName =
                listGet nextH12 clock.hours |> Maybe.withDefault ""

            pattern =
                Dict.get adjustedRounded clock.patterns
                    |> Maybe.withDefault (Dict.get 0 clock.patterns |> Maybe.withDefault "{h}")
        in
        pattern
            |> String.replace "{h}" hName
            |> String.replace "{next_h}" nextHName


formatDigital : Int -> Int -> ShortClockConfig -> String
formatDigital hour minute sc =
    let
        fmt =
            sc.format
    in
    if sc.use24h then
        fmt
            |> String.replace "{h}" (String.fromInt hour)
            |> String.replace "{mm}" (String.padLeft 2 '0' (String.fromInt minute))

    else
        let
            h12 =
                modBy 12 hour

            displayH =
                if h12 == 0 then
                    12

                else
                    h12

            amPm =
                case sc.amPm of
                    Just ( am, pm ) ->
                        if hour < 12 then
                            am

                        else
                            pm

                    Nothing ->
                        if hour < 12 then
                            "AM"

                        else
                            "PM"
        in
        fmt
            |> String.replace "{h}" (String.fromInt displayH)
            |> String.replace "{mm}" (String.padLeft 2 '0' (String.fromInt minute))
            |> String.replace "{ampm}" amPm


listGet : Int -> List a -> Maybe a
listGet index list =
    list
        |> List.drop index
        |> List.head
