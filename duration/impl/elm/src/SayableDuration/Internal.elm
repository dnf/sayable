module SayableDuration.Internal exposing (parseIsoToSeconds)


parseIsoToSeconds : String -> Maybe Int
parseIsoToSeconds isoStr =
    if String.isEmpty isoStr then
        Nothing

    else
        case indexOf "T" isoStr of
            Nothing ->
                Nothing

            Just tIdx ->
                let
                    datePart =
                        String.left tIdx isoStr

                    timePart =
                        String.dropLeft (tIdx + 1) isoStr
                in
                case parseDatePart datePart of
                    Nothing ->
                        Nothing

                    Just ( year, month, day ) ->
                        case parseTimePart timePart of
                            Nothing ->
                                Nothing

                            Just ( hour, minute, second ) ->
                                let
                                    days =
                                        daysSinceEpoch year month day
                                in
                                Just (days * 86400 + hour * 3600 + minute * 60 + second)


parseDatePart : String -> Maybe ( Int, Int, Int )
parseDatePart s =
    let
        parts =
            String.split "-" s
    in
    case parts of
        [ yStr, mStr, dStr ] ->
            case ( String.toInt yStr, String.toInt mStr, String.toInt dStr ) of
                ( Just y, Just m, Just d ) ->
                    Just ( y, m, d )

                _ ->
                    Nothing

        _ ->
            Nothing


parseTimePart : String -> Maybe ( Int, Int, Int )
parseTimePart s =
    let
        cleaned =
            s
                |> stripAfter "+"
                |> stripAfter "Z"

        parts =
            String.split ":" cleaned
    in
    case parts of
        hourStr :: rest ->
            let
                minStr =
                    case rest of
                        m :: _ ->
                            m

                        [] ->
                            "0"

                secStr =
                    case rest of
                        _ :: s2 :: _ ->
                            stripAfter "." s2

                        _ ->
                            "0"
            in
            case ( String.toInt hourStr, String.toInt minStr, String.toInt secStr ) of
                ( Just h, Just m, Just sec ) ->
                    Just ( h, m, sec )

                _ ->
                    Nothing

        [] ->
            Nothing


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


indexOf : String -> String -> Maybe Int
indexOf needle haystack =
    indexOfHelper needle haystack 0


indexOfHelper : String -> String -> Int -> Maybe Int
indexOfHelper needle haystack offset =
    if offset > String.length haystack - String.length needle then
        Nothing

    else if String.slice offset (offset + String.length needle) haystack == needle then
        Just offset

    else
        indexOfHelper needle haystack (offset + 1)


stripAfter : String -> String -> String
stripAfter sep s =
    case indexOf sep s of
        Just i ->
            String.left i s

        Nothing ->
            s
