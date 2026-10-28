module SayableDate.Internal exposing (parseDate, toJDN, weekday)


parseDate : String -> Maybe ( Int, Int, Int )
parseDate s =
    let
        datePart =
            String.left 10 s

        digitsAt from to =
            String.all Char.isDigit (String.slice from to datePart)

        isDateOrDatetime =
            String.length s == 10 || (String.length s > 10 && String.slice 10 11 s == "T")

        isDateShape =
            String.slice 4 5 datePart
                == "-"
                && String.slice 7 8 datePart
                == "-"
                && digitsAt 0 4
                && digitsAt 5 7
                && digitsAt 8 10
    in
    if not (isDateOrDatetime && isDateShape) then
        Nothing

    else
        case ( String.toInt (String.slice 0 4 datePart), String.toInt (String.slice 5 7 datePart), String.toInt (String.slice 8 10 datePart) ) of
            ( Just y, Just m, Just d ) ->
                if m >= 1 && m <= 12 && d >= 1 && d <= daysInMonth y m then
                    Just ( y, m, d )

                else
                    Nothing

            _ ->
                Nothing


isLeapYear : Int -> Bool
isLeapYear y =
    (modBy 4 y == 0 && modBy 100 y /= 0) || modBy 400 y == 0


daysInMonth : Int -> Int -> Int
daysInMonth y m =
    if m == 2 then
        if isLeapYear y then
            29

        else
            28

    else if List.member m [ 4, 6, 9, 11 ] then
        30

    else
        31


toJDN : Int -> Int -> Int -> Int
toJDN year month day =
    let
        a =
            (14 - month) // 12

        y =
            year + 4800 - a

        m =
            month + 12 * a - 3
    in
    day + (153 * m + 2) // 5 + 365 * y + y // 4 - y // 100 + y // 400 - 32045


weekday : Int -> Int -> Int -> Int
weekday year month day =
    modBy 7 (toJDN year month day + 1)
