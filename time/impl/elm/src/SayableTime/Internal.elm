module SayableTime.Internal exposing (parseTime, roundTo5)


parseTime : String -> Maybe ( Int, Int )
parseTime input =
    if String.isEmpty input then
        Nothing

    else
        let
            t =
                if String.contains "T" input then
                    String.dropLeft (Maybe.withDefault 0 (indexOf "T" input) + 1) input

                else
                    input

            withoutTz =
                t
                    |> stripAfter "+"
                    |> stripAfter "Z"

            parts =
                String.split ":" withoutTz
        in
        case parts of
            hourStr :: minuteWithFrac :: _ ->
                let
                    minStr =
                        stripAfter "." minuteWithFrac
                in
                case ( String.toInt hourStr, String.toInt minStr ) of
                    ( Just h, Just m ) ->
                        if h < 0 || h > 23 || m < 0 || m > 59 then
                            Nothing

                        else
                            Just ( h, m )

                    _ ->
                        Nothing

            _ ->
                Nothing


roundTo5 : Int -> Int
roundTo5 minute =
    ((minute + 2) // 5) * 5


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
