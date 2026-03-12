port module Main exposing (main)

import Dict
import Json.Decode as D
import Platform
import SayableAge.Formatter as AgeFormatter
import SayableAge.Locales as AgeLocales
import SayableAge.Types as AgeTypes
import SayableDate.Formatter as DateFormatter
import SayableDate.Locales as DateLocales
import SayableDate.Types as DateTypes
import SayableTime.Formatter as TimeFormatter
import SayableTime.Locales as TimeLocales
import SayableTime.Types as TimeTypes
import SayableDuration.Formatter as DurationFormatter
import SayableDuration.Locales as DurationLocales
import SayableDuration.Types as DurationTypes


port sendResult : { output : String, exitCode : Int } -> Cmd msg


type alias Flags =
    { command : String
    , args : List String
    , locale : String
    , asOf : String
    , compactness : String
    , gender : String
    , withYear : Bool
    }


flagsDecoder : D.Decoder Flags
flagsDecoder =
    D.map7 Flags
        (D.field "command" D.string)
        (D.field "args" (D.list D.string))
        (D.field "locale" D.string)
        (D.field "asOf" D.string)
        (D.field "compactness" D.string)
        (D.field "gender" D.string)
        (D.field "withYear" D.bool)


type alias Model =
    ()


type Msg
    = NoOp


main : Program D.Value Model Msg
main =
    Platform.worker
        { init = init
        , update = \_ m -> ( m, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


init : D.Value -> ( Model, Cmd Msg )
init flagsValue =
    case D.decodeValue flagsDecoder flagsValue of
        Err _ ->
            ( (), sendResult { output = "", exitCode = 2 } )

        Ok flags ->
            let
                result =
                    dispatch flags
            in
            ( (), sendResult result )


dispatch : Flags -> { output : String, exitCode : Int }
dispatch flags =
    case flags.command of
        "age" ->
            cmdAge flags

        "stage" ->
            cmdStage flags

        "date" ->
            cmdDate flags

        "relative" ->
            cmdRelative flags

        "time" ->
            cmdTime flags

        "duration" ->
            cmdDuration flags

        "since" ->
            cmdSince flags

        "until" ->
            cmdUntil flags

        "locales" ->
            cmdLocales

        "version" ->
            { output = "sayable " ++ AgeFormatter.version, exitCode = 0 }

        _ ->
            { output = "", exitCode = 2 }


toAgeCompactness : String -> AgeTypes.Compactness
toAgeCompactness s =
    case s of
        "short" ->
            AgeTypes.Short

        "compact" ->
            AgeTypes.Compact

        _ ->
            AgeTypes.Normal


toDateCompactness : String -> DateTypes.Compactness
toDateCompactness s =
    case s of
        "short" ->
            DateTypes.Short

        "compact" ->
            DateTypes.Compact

        _ ->
            DateTypes.Normal


toTimeCompactness : String -> TimeTypes.Compactness
toTimeCompactness s =
    case s of
        "short" ->
            TimeTypes.Short

        "compact" ->
            TimeTypes.Compact

        _ ->
            TimeTypes.Normal


toDurationCompactness : String -> DurationTypes.Compactness
toDurationCompactness s =
    case s of
        "short" ->
            DurationTypes.Short

        "compact" ->
            DurationTypes.Compact

        _ ->
            DurationTypes.Normal


toGender : String -> Maybe AgeTypes.Gender
toGender s =
    case s of
        "m" ->
            Just AgeTypes.M

        "f" ->
            Just AgeTypes.F

        _ ->
            Nothing


nullResult : { output : String, exitCode : Int }
nullResult =
    { output = "", exitCode = 1 }


cmdAge : Flags -> { output : String, exitCode : Int }
cmdAge flags =
    case flags.args of
        [] ->
            { output = "", exitCode = 2 }

        dobRaw :: _ ->
            if dobRaw == "" then
                nullResult

            else
                case AgeLocales.getLocale flags.locale of
                    Nothing ->
                        { output = "", exitCode = 2 }

                    Just locale ->
                        let
                            compactness =
                                toAgeCompactness flags.compactness

                            asOf =
                                if flags.asOf == "" then
                                    ""

                                else
                                    flags.asOf
                        in
                        if asOf == "" then
                            -- Should use today, but the Node wrapper provides it
                            { output = "", exitCode = 2 }

                        else
                            case AgeFormatter.formatAge locale compactness dobRaw asOf of
                                Just result ->
                                    { output = result, exitCode = 0 }

                                Nothing ->
                                    nullResult


cmdStage : Flags -> { output : String, exitCode : Int }
cmdStage flags =
    case flags.args of
        [] ->
            { output = "", exitCode = 2 }

        dobRaw :: _ ->
            if dobRaw == "" then
                nullResult

            else
                case AgeLocales.getLocale flags.locale of
                    Nothing ->
                        { output = "", exitCode = 2 }

                    Just locale ->
                        let
                            asOf =
                                if flags.asOf == "" then
                                    ""

                                else
                                    flags.asOf

                            gender =
                                toGender flags.gender
                        in
                        if asOf == "" then
                            { output = "", exitCode = 2 }

                        else
                            case AgeFormatter.formatStage locale dobRaw asOf gender of
                                Just result ->
                                    { output = result, exitCode = 0 }

                                Nothing ->
                                    nullResult


cmdDate : Flags -> { output : String, exitCode : Int }
cmdDate flags =
    case flags.args of
        [] ->
            { output = "", exitCode = 2 }

        dateRaw :: _ ->
            if dateRaw == "" then
                nullResult

            else
                case DateLocales.getLocale flags.locale of
                    Nothing ->
                        { output = "", exitCode = 2 }

                    Just locale ->
                        let
                            compactness =
                                toDateCompactness flags.compactness

                            result =
                                if flags.withYear then
                                    DateFormatter.formatDateWithYear locale compactness dateRaw

                                else
                                    DateFormatter.formatDate locale compactness dateRaw
                        in
                        case result of
                            Just r ->
                                { output = r, exitCode = 0 }

                            Nothing ->
                                nullResult


cmdRelative : Flags -> { output : String, exitCode : Int }
cmdRelative flags =
    case flags.args of
        [] ->
            { output = "", exitCode = 2 }

        dateRaw :: _ ->
            if dateRaw == "" then
                nullResult

            else
                case DateLocales.getLocale flags.locale of
                    Nothing ->
                        { output = "", exitCode = 2 }

                    Just locale ->
                        let
                            compactness =
                                toDateCompactness flags.compactness
                        in
                        case DateFormatter.formatRelative locale compactness dateRaw flags.asOf of
                            Just r ->
                                { output = r, exitCode = 0 }

                            Nothing ->
                                nullResult


cmdTime : Flags -> { output : String, exitCode : Int }
cmdTime flags =
    case flags.args of
        [] ->
            { output = "", exitCode = 2 }

        timeRaw :: _ ->
            if timeRaw == "" then
                nullResult

            else
                case TimeLocales.getLocale flags.locale of
                    Nothing ->
                        { output = "", exitCode = 2 }

                    Just locale ->
                        let
                            compactness =
                                toTimeCompactness flags.compactness
                        in
                        case TimeFormatter.formatTime locale compactness timeRaw of
                            Just r ->
                                { output = r, exitCode = 0 }

                            Nothing ->
                                nullResult


cmdDuration : Flags -> { output : String, exitCode : Int }
cmdDuration flags =
    case flags.args of
        [] ->
            { output = "", exitCode = 2 }

        valueRaw :: rest ->
            if valueRaw == "" then
                nullResult

            else
                case DurationLocales.getLocale flags.locale of
                    Nothing ->
                        { output = "", exitCode = 2 }

                    Just locale ->
                        let
                            compactness =
                                toDurationCompactness flags.compactness
                        in
                        -- Check if it's an integer (seconds mode)
                        case String.toInt valueRaw of
                            Just seconds ->
                                case DurationFormatter.formatDuration locale compactness seconds of
                                    Just r ->
                                        { output = r, exitCode = 0 }

                                    Nothing ->
                                        nullResult

                            Nothing ->
                                -- Timestamp mode: need an end argument
                                case rest of
                                    [] ->
                                        { output = "", exitCode = 2 }

                                    endRaw :: _ ->
                                        case DurationFormatter.formatDurationTimestamps locale compactness valueRaw endRaw of
                                            Just r ->
                                                { output = r, exitCode = 0 }

                                            Nothing ->
                                                nullResult


cmdSince : Flags -> { output : String, exitCode : Int }
cmdSince flags =
    case flags.args of
        [] ->
            { output = "", exitCode = 2 }

        startRaw :: _ ->
            if startRaw == "" then
                nullResult

            else
                case DurationLocales.getLocale flags.locale of
                    Nothing ->
                        { output = "", exitCode = 2 }

                    Just locale ->
                        let
                            compactness =
                                toDurationCompactness flags.compactness
                        in
                        case DurationFormatter.formatSince locale compactness startRaw flags.asOf of
                            Just r ->
                                { output = r, exitCode = 0 }

                            Nothing ->
                                nullResult


cmdUntil : Flags -> { output : String, exitCode : Int }
cmdUntil flags =
    case flags.args of
        [] ->
            { output = "", exitCode = 2 }

        targetRaw :: _ ->
            if targetRaw == "" then
                nullResult

            else
                case DurationLocales.getLocale flags.locale of
                    Nothing ->
                        { output = "", exitCode = 2 }

                    Just locale ->
                        let
                            compactness =
                                toDurationCompactness flags.compactness
                        in
                        case DurationFormatter.formatUntil locale compactness targetRaw flags.asOf of
                            Just r ->
                                { output = r, exitCode = 0 }

                            Nothing ->
                                nullResult


allLocaleCodes : List String
allLocaleCodes =
    [ "af", "ak", "am", "ar", "az", "bci", "be", "bem", "bg", "bi", "bm", "bn", "br", "bs"
    , "ca", "ceb", "cs", "cy", "da", "de", "din", "dje", "dyu", "ee", "el", "en", "es"
    , "et", "eu", "fa", "fan", "ff", "fi", "fil", "fj", "fon", "fr", "ga", "gd", "gl", "gn"
    , "gu", "gv", "ha", "he", "hi", "hr", "ht", "hu", "hy", "id", "ig", "is", "it"
    , "ja", "jv", "ka", "kbp", "kk", "km", "kn", "ko", "kpe", "ktu", "ku", "kw", "ky"
    , "lg", "ln", "lo", "lt", "lv", "men", "mfe", "mg", "mi", "mk", "ml", "mn", "mnk"
    , "mos", "mr", "ms", "mt", "my", "nb", "nd", "ne", "ng", "nl", "nso", "nus", "ny"
    , "om", "or", "pa", "pis", "pl", "pov", "ps", "pt", "qu", "ro", "ru", "rw", "sar", "sd"
    , "sg", "shi", "si", "sk", "sl", "sn", "snk", "so", "sq", "sr", "ss", "st", "su"
    , "suk", "sv", "sw", "ta", "te", "tem", "tg", "th", "ti", "tig", "tk", "tn", "tpi"
    , "tr", "ts", "tzm", "uk", "umb", "ur", "uz", "vi", "vmw", "wo", "xh", "yo", "yue"
    , "zdj", "zh", "zu"
    ]


cmdLocales : { output : String, exitCode : Int }
cmdLocales =
    let
        validCodes =
            List.filter (\code -> AgeLocales.getLocale code /= Nothing) allLocaleCodes
    in
    { output = String.join "\n" validCodes, exitCode = 0 }
