module SayableAge exposing (formatAge, formatStage)

import SayableAge.Formatter
import SayableAge.Types exposing (Compactness, Gender, Locale)


formatAge : Locale -> Compactness -> String -> String -> Maybe String
formatAge =
    SayableAge.Formatter.formatAge


formatStage : Locale -> String -> String -> Maybe Gender -> Maybe String
formatStage =
    SayableAge.Formatter.formatStage
