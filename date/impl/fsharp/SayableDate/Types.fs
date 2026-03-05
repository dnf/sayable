namespace SayableDateLib

module Types =

    type Compactness =
        | Normal
        | Short
        | Compact

    type CompactnessOverride =
        { Months: string[] option
          MonthsInDate: string[] option
          Weekdays: string[] option
          DayFormat: string option
          DayFormatExceptions: Map<string, string> option
          DatePattern: string option
          DatePatternWithYear: string option
          Today: string option
          Tomorrow: string option
          Yesterday: string option }

    type DateLocale =
        { Code: string
          Months: string[]
          Weekdays: string[]
          DayFormat: string
          DayFormatExceptions: Map<string, string>
          DatePattern: string
          DatePatternWithYear: string
          Today: string
          Tomorrow: string
          Yesterday: string
          DayAfterTomorrow: string option
          DayBeforeYesterday: string option
          ThisWeekday: string option
          NextWeekday: string option
          LastWeekday: string option
          MonthsInDate: string[] option
          ShortOverride: CompactnessOverride option
          CompactOverride: CompactnessOverride option }
