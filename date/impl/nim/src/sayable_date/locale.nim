## Locale definitions for date formatting.

import std/[options, tables]

type
  CompactnessOverride* = object
    months*: Option[seq[string]]
    monthsInDate*: Option[seq[string]]
    weekdays*: Option[seq[string]]
    dayFormat*: Option[string]
    dayFormatExceptions*: Option[OrderedTable[string, string]]
    datePattern*: Option[string]
    datePatternWithYear*: Option[string]
    today*: Option[string]
    tomorrow*: Option[string]
    yesterday*: Option[string]

  DateLocale* = object
    code*: string
    months*: seq[string]
    weekdays*: seq[string]
    dayFormat*: string
    dayFormatExceptions*: OrderedTable[string, string]
    datePattern*: string
    datePatternWithYear*: string
    today*: string
    tomorrow*: string
    yesterday*: string
    dayAfterTomorrow*: Option[string]
    dayBeforeYesterday*: Option[string]
    thisWeekday*: Option[string]
    nextWeekday*: Option[string]
    lastWeekday*: Option[string]
    monthsInDate*: Option[seq[string]]
    short*: Option[CompactnessOverride]
    compact*: Option[CompactnessOverride]

  Compactness* = enum
    cNormal = "normal"
    cShort = "short"
    cCompact = "compact"
