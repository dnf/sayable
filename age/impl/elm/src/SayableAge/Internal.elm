module SayableAge.Internal exposing (computeAge, daysBetween, daysInMonth, isLeapYear, parseDate)


parseDate : String -> Maybe ( Int, Int, Int )
parseDate s =
    let
        digitsAt from to =
            String.all Char.isDigit (String.slice from to s)

        isDateShape =
            String.length s
                == 10
                && String.slice 4 5 s
                == "-"
                && String.slice 7 8 s
                == "-"
                && digitsAt 0 4
                && digitsAt 5 7
                && digitsAt 8 10
    in
    if not isDateShape then
        Nothing

    else
        case ( String.toInt (String.slice 0 4 s), String.toInt (String.slice 5 7 s), String.toInt (String.slice 8 10 s) ) of
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


toJDN : Int -> Int -> Int -> Int
toJDN y m d =
    let
        a =
            (14 - m) // 12

        yy =
            y + 4800 - a

        mm =
            m + 12 * a - 3
    in
    d + (153 * mm + 2) // 5 + 365 * yy + yy // 4 - yy // 100 + yy // 400 - 32045


daysBetween : ( Int, Int, Int ) -> ( Int, Int, Int ) -> Int
daysBetween ( y1, m1, d1 ) ( y2, m2, d2 ) =
    toJDN y2 m2 d2 - toJDN y1 m1 d1


computeAge : String -> String -> Maybe ( Int, Int )
computeAge dob asOf =
    case ( parseDate dob, parseDate asOf ) of
        ( Just ( dy, dm, dd ), Just ( ry, rm, rd ) ) ->
            let
                diffDays =
                    daysBetween ( dy, dm, dd ) ( ry, rm, rd )
            in
            if diffDays < 0 then
                Nothing

            else
                let
                    lastDay =
                        daysInMonth ry rm

                    clampedBirthday =
                        min dd lastDay

                    months0 =
                        (ry - dy) * 12 + (rm - dm)

                    months =
                        if rd < clampedBirthday then
                            months0 - 1

                        else
                            months0
                in
                if months > 6000 then
                    Nothing

                else
                    Just ( months, diffDays )

        _ ->
            Nothing
