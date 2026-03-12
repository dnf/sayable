module SayableDate.Types exposing
    ( Compactness(..)
    , CompactnessOverride
    , Locale
    )

import Dict exposing (Dict)


type Compactness
    = Normal
    | Short
    | Compact


type alias CompactnessOverride =
    { ovrMonths : Maybe (List String)
    , ovrMonthsInDate : Maybe (List String)
    , ovrWeekdays : Maybe (List String)
    , ovrDayFormat : Maybe String
    , ovrDayFormatExceptions : Maybe (Dict String String)
    , ovrDatePattern : Maybe String
    , ovrDatePatternWithYear : Maybe String
    , ovrToday : Maybe String
    , ovrTomorrow : Maybe String
    , ovrYesterday : Maybe String
    }


type alias Locale =
    { code : String
    , months : List String
    , weekdays : List String
    , dayFormat : String
    , dayFormatExceptions : Dict String String
    , datePattern : String
    , datePatternWithYear : String
    , today : String
    , tomorrow : String
    , yesterday : String
    , dayAfterTomorrow : Maybe String
    , dayBeforeYesterday : Maybe String
    , thisWeekday : Maybe String
    , nextWeekday : Maybe String
    , lastWeekday : Maybe String
    , monthsInDate : Maybe (List String)
    , short : Maybe CompactnessOverride
    , compact : Maybe CompactnessOverride
    }
