## Locale definitions for clock time formatting.

import std/[options, tables]

type
  ClockConfig* = object
    hours*: seq[string]
    midnight*: string
    noon*: string
    patterns*: OrderedTable[int, string]

  ShortClockConfig* = object
    use24h*: bool
    format*: string
    amPm*: Option[(string, string)]

  CompactnessOverride* = object
    clock*: Option[ShortClockConfig]

  TimeLocale* = object
    code*: string
    clock*: ClockConfig
    short*: Option[CompactnessOverride]
    compact*: Option[CompactnessOverride]

  Compactness* = enum
    cNormal = "normal"
    cShort = "short"
    cCompact = "compact"
