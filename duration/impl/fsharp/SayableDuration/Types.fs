namespace SayableDurationLib

module Types =

    type PluralCategory =
        | Zero
        | One
        | Two
        | Few
        | Many
        | Other

    type Compactness =
        | Normal
        | Short
        | Compact

    type UnitForms =
        | Simple of string
        | Plural of Map<PluralCategory, string>

    type Units =
        { Second: UnitForms
          Minute: UnitForms
          Hour: UnitForms
          Day: UnitForms
          Week: UnitForms
          Month: UnitForms
          Year: UnitForms }

    type CompactnessOverride =
        { Second: UnitForms option
          Minute: UnitForms option
          Hour: UnitForms option
          Day: UnitForms option
          Week: UnitForms option
          Month: UnitForms option
          Year: UnitForms option
          Half: string option
          Delimiter: string option
          Ago: string option
          InFuture: string option }

    type DurationLocale =
        { Code: string
          Plural: int -> PluralCategory
          Units: Units
          Half: string
          Delimiter: string
          JustNow: string
          Ago: string
          InFuture: string
          ShortOverride: CompactnessOverride option
          CompactOverride: CompactnessOverride option
          FormatNumber: (int -> string) option
          FormatUnit: (int -> string -> string) option }
