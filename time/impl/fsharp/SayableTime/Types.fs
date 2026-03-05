namespace SayableTimeLib

module Types =

    type ClockConfig =
        { Hours: string[]
          Midnight: string
          Noon: string
          Patterns: Map<int, string> }

    type ShortClockConfig =
        { Use24h: bool
          AmPm: (string * string) option
          Format: string }

    type CompactnessOverride =
        { Clock: ShortClockConfig option }

    type Compactness =
        | Normal
        | Short
        | Compact

    type TimeLocale =
        { Code: string
          Clock: ClockConfig
          ShortOverride: CompactnessOverride option
          CompactOverride: CompactnessOverride option }
