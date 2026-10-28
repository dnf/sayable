module SayableDuration.Internal exposing (parseIsoToSeconds)

{-| YYYY-MM-DDTHH:MM (one- or two-digit hour), then an optional :SS with an
optional fraction, then an optional zone suffix (Z or ±HH:MM) that is
validated but not applied.
-}


parseIsoToSeconds : String -> Maybe Int
parseIsoToSeconds isoStr =
    if String.slice 10 11 isoStr /= "T" then
        Nothing

    else
        case ( parseDatePart (String.left 10 isoStr), parseClock (String.dropLeft 11 isoStr) ) of
            ( Just ( year, month, day ), Just ( hour, minute, second ) ) ->
                Just (daysSinceEpoch year month day * 86400 + hour * 3600 + minute * 60 + second)

            _ ->
                Nothing


parseDatePart : String -> Maybe ( Int, Int, Int )
parseDatePart s =
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
            if isDateShape && m >= 1 && m <= 12 && d >= 1 && d <= daysInMonth y m then
                Just ( y, m, d )

            else
                Nothing

        _ ->
            Nothing


parseClock : String -> Maybe ( Int, Int, Int )
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
                            Just ( h, m, sec )

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


isLeapYear : Int -> Bool
isLeapYear y =
    (modBy 4 y == 0 && modBy 100 y /= 0) || modBy 400 y == 0


daysInMonth : Int -> Int -> Int
daysInMonth y m =
    case m of
        1 ->
            31

        3 ->
            31

        5 ->
            31

        7 ->
            31

        8 ->
            31

        10 ->
            31

        12 ->
            31

        4 ->
            30

        6 ->
            30

        9 ->
            30

        11 ->
            30

        2 ->
            if isLeapYear y then
                29

            else
                28

        _ ->
            30


daysSinceEpoch : Int -> Int -> Int -> Int
daysSinceEpoch year month day =
    let
        yearDays =
            if year >= 2000 then
                yearDaysForward 2000 year 0

            else
                yearDaysBackward year 2000 0

        monthDays =
            monthDaysAccum year 1 month 0
    in
    yearDays + monthDays + day - 1


yearDaysForward : Int -> Int -> Int -> Int
yearDaysForward current target acc =
    if current >= target then
        acc

    else
        yearDaysForward (current + 1)
            target
            (acc
                + (if isLeapYear current then
                    366

                   else
                    365
                  )
            )


yearDaysBackward : Int -> Int -> Int -> Int
yearDaysBackward current target acc =
    if current >= target then
        acc

    else
        yearDaysBackward (current + 1)
            target
            (acc
                - (if isLeapYear current then
                    366

                   else
                    365
                  )
            )


monthDaysAccum : Int -> Int -> Int -> Int -> Int
monthDaysAccum year current target acc =
    if current >= target then
        acc

    else
        monthDaysAccum year (current + 1) target (acc + daysInMonth year current)
