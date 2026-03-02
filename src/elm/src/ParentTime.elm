module ParentTime exposing (formatAge, formatStage)

import ParentTime.Formatter
import ParentTime.Types exposing (Compactness, Gender, Locale)


formatAge : Locale -> Compactness -> String -> String -> Maybe String
formatAge =
    ParentTime.Formatter.formatAge


formatStage : Locale -> String -> String -> Maybe Gender -> Maybe String
formatStage =
    ParentTime.Formatter.formatStage
