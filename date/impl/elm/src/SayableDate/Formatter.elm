module SayableDate.Formatter exposing (formatDate, formatDateWithYear, formatRelative, version)

import Dict
import SayableDate.Internal exposing (parseDate, toJDN, weekday)
import SayableDate.Types
    exposing
        ( Compactness(..)
        , CompactnessOverride
        , Locale
        )


version : String
version =
    "0.5.0"


type alias Resolved =
    { months : List String
    , monthsInDate : Maybe (List String)
    , weekdays : List String
    , dayFormat : String
    , dayFormatExceptions : Dict.Dict String String
    , datePattern : String
    , datePatternWithYear : String
    , today : String
    , tomorrow : String
    , yesterday : String
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
            { months = loc.months
            , monthsInDate = loc.monthsInDate
            , weekdays = loc.weekdays
            , dayFormat = loc.dayFormat
            , dayFormatExceptions = loc.dayFormatExceptions
            , datePattern = loc.datePattern
            , datePatternWithYear = loc.datePatternWithYear
            , today = loc.today
            , tomorrow = loc.tomorrow
            , yesterday = loc.yesterday
            }

        Just ovr ->
            { months = Maybe.withDefault loc.months ovr.ovrMonths
            , monthsInDate =
                case ovr.ovrMonthsInDate of
                    Just m ->
                        Just m

                    Nothing ->
                        loc.monthsInDate
            , weekdays = Maybe.withDefault loc.weekdays ovr.ovrWeekdays
            , dayFormat = Maybe.withDefault loc.dayFormat ovr.ovrDayFormat
            , dayFormatExceptions =
                case ovr.ovrDayFormat of
                    Just _ ->
                        case ovr.ovrDayFormatExceptions of
                            Just exc ->
                                exc

                            Nothing ->
                                Dict.empty

                    Nothing ->
                        Maybe.withDefault loc.dayFormatExceptions ovr.ovrDayFormatExceptions
            , datePattern = Maybe.withDefault loc.datePattern ovr.ovrDatePattern
            , datePatternWithYear = Maybe.withDefault loc.datePatternWithYear ovr.ovrDatePatternWithYear
            , today = Maybe.withDefault loc.today ovr.ovrToday
            , tomorrow = Maybe.withDefault loc.tomorrow ovr.ovrTomorrow
            , yesterday = Maybe.withDefault loc.yesterday ovr.ovrYesterday
            }


formatDate : Locale -> Compactness -> String -> Maybe String
formatDate loc compactness date =
    if String.isEmpty date then
        Nothing

    else
        case parseDate date of
            Nothing ->
                Nothing

            Just ( y, m, d ) ->
                let
                    r =
                        resolveLocale loc compactness
                in
                Just (formatAbsolute r y m d False)


formatDateWithYear : Locale -> Compactness -> String -> Maybe String
formatDateWithYear loc compactness date =
    if String.isEmpty date then
        Nothing

    else
        case parseDate date of
            Nothing ->
                Nothing

            Just ( y, m, d ) ->
                let
                    r =
                        resolveLocale loc compactness
                in
                Just (formatAbsolute r y m d True)


formatRelative : Locale -> Compactness -> String -> String -> Maybe String
formatRelative loc compactness date asOf =
    if String.isEmpty date || String.isEmpty asOf then
        Nothing

    else
        case ( parseDate date, parseDate asOf ) of
            ( Just ( dy, dm, dd ), Just ( ay, am, ad ) ) ->
                let
                    dateJdn =
                        toJDN dy dm dd

                    asOfJdn =
                        toJDN ay am ad

                    diff =
                        dateJdn - asOfJdn

                    r =
                        resolveLocale loc compactness

                    isCompact =
                        compactness == Compact
                in
                if diff == 0 then
                    Just r.today

                else if diff == 1 then
                    Just r.tomorrow

                else if diff == -1 then
                    Just r.yesterday

                else if diff == 2 && loc.dayAfterTomorrow /= Nothing && not isCompact then
                    loc.dayAfterTomorrow

                else if diff == -2 && loc.dayBeforeYesterday /= Nothing && not isCompact then
                    loc.dayBeforeYesterday

                else if isCompact then
                    let
                        includeYear =
                            dy /= ay
                    in
                    Just (formatAbsolute r dy dm dd includeYear)

                else if diff >= 2 && diff <= 6 && loc.thisWeekday /= Nothing then
                    let
                        dow =
                            weekday dy dm dd

                        weekdayName =
                            listGet dow r.weekdays |> Maybe.withDefault ""
                    in
                    loc.thisWeekday
                        |> Maybe.map (String.replace "{weekday}" weekdayName)

                else if diff >= -6 && diff <= -2 && loc.lastWeekday /= Nothing then
                    let
                        dow =
                            weekday dy dm dd

                        weekdayName =
                            listGet dow r.weekdays |> Maybe.withDefault ""
                    in
                    loc.lastWeekday
                        |> Maybe.map (String.replace "{weekday}" weekdayName)

                else if diff >= 7 && diff <= 13 && loc.nextWeekday /= Nothing then
                    let
                        dow =
                            weekday dy dm dd

                        weekdayName =
                            listGet dow r.weekdays |> Maybe.withDefault ""
                    in
                    loc.nextWeekday
                        |> Maybe.map (String.replace "{weekday}" weekdayName)

                else
                    let
                        includeYear =
                            dy /= ay
                    in
                    Just (formatAbsolute r dy dm dd includeYear)

            _ ->
                Nothing


formatAbsolute : Resolved -> Int -> Int -> Int -> Bool -> String
formatAbsolute r year month day includeYear =
    let
        dayStr =
            String.fromInt day

        fmt =
            case Dict.get dayStr r.dayFormatExceptions of
                Just f ->
                    f

                Nothing ->
                    r.dayFormat

        formattedDay =
            String.replace "{n}" dayStr fmt

        monthNames =
            case r.monthsInDate of
                Just mid ->
                    mid

                Nothing ->
                    r.months

        monthName =
            listGet (month - 1) monthNames |> Maybe.withDefault ""

        pattern =
            if includeYear then
                r.datePatternWithYear

            else
                r.datePattern

        result =
            pattern
                |> String.replace "{month}" monthName
                |> String.replace "{day}" formattedDay
                |> String.replace "{d}" (String.fromInt day)
                |> String.replace "{m}" (String.fromInt month)
    in
    if includeYear then
        result
            |> String.replace "{year}" (String.fromInt year)
            |> String.replace "{yy}" (String.padLeft 2 '0' (String.fromInt (modBy 100 year)))

    else
        result


listGet : Int -> List a -> Maybe a
listGet index list =
    list
        |> List.drop index
        |> List.head
