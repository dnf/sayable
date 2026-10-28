module SayableTime.Internal exposing (parseTime, roundTo5)


parseTime : String -> Maybe ( Int, Int )
parseTime input =
    case splitOnFirstT input of
        Just ( datePart, clock ) ->
            if isRealDate datePart then
                parseClock clock

            else
                Nothing

        Nothing ->
            parseClock input


splitOnFirstT : String -> Maybe ( String, String )
splitOnFirstT s =
    case String.indexes "T" s of
        i :: _ ->
            Just ( String.left i s, String.dropLeft (i + 1) s )

        [] ->
            Nothing


{-| H:MM or HH:MM, optional :SS with an optional fraction, then an optional
zone suffix (Z or ±HH:MM) that is validated but not applied.
-}
parseClock : String -> Maybe ( Int, Int )
parseClock clock =
    let
        hourLength =
            leadingDigitCount clock

        afterHour =
            String.dropLeft hourLength clock

        minuteDigits =
            String.slice 1 3 afterHour

        hasHourAndMinute =
            hourLength >= 1 && hourLength <= 2 && String.left 1 afterHour == ":" && isDigits 2 minuteDigits
    in
    if not hasHourAndMinute then
        Nothing

    else
        case optionalSeconds (String.dropLeft 3 afterHour) of
            Just ( secondDigits, zone ) ->
                case ( String.toInt (String.left hourLength clock), String.toInt minuteDigits, String.toInt secondDigits ) of
                    ( Just h, Just m, Just sec ) ->
                        if isZoneSuffix zone && h <= 23 && m <= 59 && sec <= 59 then
                            Just ( h, m )

                        else
                            Nothing

                    _ ->
                        Nothing

            Nothing ->
                Nothing


{-| Splits an optional ":SS" (with an optional ".digits" fraction) off the
front, returning the seconds digits ("0" when absent) and what follows.
-}
optionalSeconds : String -> Maybe ( String, String )
optionalSeconds rest =
    if String.left 1 rest /= ":" then
        Just ( "0", rest )

    else if not (isDigits 2 (String.slice 1 3 rest)) then
        Nothing

    else
        let
            afterSeconds =
                String.dropLeft 3 rest

            fractionLength =
                leadingDigitCount (String.dropLeft 1 afterSeconds)
        in
        if String.left 1 afterSeconds /= "." then
            Just ( String.slice 1 3 rest, afterSeconds )

        else if fractionLength == 0 then
            Nothing

        else
            Just ( String.slice 1 3 rest, String.dropLeft (1 + fractionLength) afterSeconds )


isZoneSuffix : String -> Bool
isZoneSuffix zone =
    let
        isOffset =
            String.length zone
                == 6
                && List.member (String.left 1 zone) [ "+", "-" ]
                && isDigits 2 (String.slice 1 3 zone)
                && String.slice 3 4 zone
                == ":"
                && isDigits 2 (String.slice 4 6 zone)
    in
    zone == "" || zone == "Z" || isOffset


isRealDate : String -> Bool
isRealDate s =
    let
        isDateShape =
            String.length s
                == 10
                && String.slice 4 5 s
                == "-"
                && String.slice 7 8 s
                == "-"
                && isDigits 4 (String.slice 0 4 s)
                && isDigits 2 (String.slice 5 7 s)
                && isDigits 2 (String.slice 8 10 s)
    in
    case ( String.toInt (String.slice 0 4 s), String.toInt (String.slice 5 7 s), String.toInt (String.slice 8 10 s) ) of
        ( Just y, Just m, Just d ) ->
            isDateShape && m >= 1 && m <= 12 && d >= 1 && d <= daysInMonth y m

        _ ->
            False


daysInMonth : Int -> Int -> Int
daysInMonth y m =
    if m == 2 then
        if (modBy 4 y == 0 && modBy 100 y /= 0) || modBy 400 y == 0 then
            29

        else
            28

    else if List.member m [ 4, 6, 9, 11 ] then
        30

    else
        31


isDigits : Int -> String -> Bool
isDigits count s =
    String.length s == count && String.all Char.isDigit s


leadingDigitCount : String -> Int
leadingDigitCount s =
    String.length s - String.length (dropLeadingDigits s)


dropLeadingDigits : String -> String
dropLeadingDigits s =
    case String.uncons s of
        Just ( c, rest ) ->
            if Char.isDigit c then
                dropLeadingDigits rest

            else
                s

        Nothing ->
            s


roundTo5 : Int -> Int
roundTo5 minute =
    ((minute + 2) // 5) * 5
