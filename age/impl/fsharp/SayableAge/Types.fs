namespace SayableAgeLib

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

    type StageLabel =
        | Neutral of string
        | Gendered of m: string * f: string

    let resolveStageLabel (gender: string option) (label: StageLabel) : string =
        match label with
        | Neutral s -> s
        | Gendered(m, f) ->
            match gender with
            | Some "f" -> f
            | _ -> m

    type Units =
        { Day: UnitForms
          Week: UnitForms
          Month: UnitForms
          Year: UnitForms }

    type Stages =
        { Newborn: StageLabel
          Infant: StageLabel
          Toddler: StageLabel
          Child: StageLabel
          Teenager: StageLabel
          Adult: StageLabel }

    type CompactnessOverride =
        { Day: UnitForms option
          Week: UnitForms option
          Month: UnitForms option
          Year: UnitForms option
          Half: string option
          Delimiter: string option
          JustBorn: string option }

    type AgeLocale =
        { Code: string
          Plural: int -> PluralCategory
          Units: Units
          Half: string
          Delimiter: string
          JustBorn: string
          Stages: Stages
          ShortOverride: CompactnessOverride option
          CompactOverride: CompactnessOverride option
          FormatNumber: (int -> string) option
          FormatUnit: (int -> string -> string) option }
