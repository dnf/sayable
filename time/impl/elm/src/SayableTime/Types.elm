module SayableTime.Types exposing
    ( ClockConfig
    , Compactness(..)
    , CompactnessOverride
    , Locale
    , ShortClockConfig
    )

import Dict exposing (Dict)


type Compactness
    = Normal
    | Short
    | Compact


type alias ClockConfig =
    { hours : List String
    , midnight : String
    , noon : String
    , patterns : Dict Int String
    }


type alias ShortClockConfig =
    { use24h : Bool
    , format : String
    , amPm : Maybe ( String, String )
    }


type alias CompactnessOverride =
    { clock : Maybe ShortClockConfig
    }


type alias Locale =
    { code : String
    , clock : ClockConfig
    , short : Maybe CompactnessOverride
    , compact : Maybe CompactnessOverride
    }
