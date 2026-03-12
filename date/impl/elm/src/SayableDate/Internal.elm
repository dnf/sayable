module SayableDate.Internal exposing (parseDate, toJDN, weekday)


parseDate : String -> Maybe ( Int, Int, Int )
parseDate s =
    if String.isEmpty s then
        Nothing

    else
        let
            datePart =
                if String.contains "T" s then
                    String.left (Maybe.withDefault (String.length s) (indexOf "T" s)) s

                else
                    s
        in
        if String.length datePart < 10 then
            Nothing

        else if String.slice 4 5 datePart /= "-" || String.slice 7 8 datePart /= "-" then
            Nothing

        else
            let
                yStr =
                    String.slice 0 4 datePart

                mStr =
                    String.slice 5 7 datePart

                dStr =
                    String.slice 8 10 datePart
            in
            case ( String.toInt yStr, String.toInt mStr, String.toInt dStr ) of
                ( Just y, Just m, Just d ) ->
                    if m < 1 || m > 12 || d < 1 || d > 31 then
                        Nothing

                    else
                        Just ( y, m, d )

                _ ->
                    Nothing


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
