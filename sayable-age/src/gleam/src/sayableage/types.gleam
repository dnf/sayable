/// Types for the sayable-age locale system.

pub type PluralCategory {
  Zero
  One
  Two
  Few
  Many
  Other
}

pub type UnitForms {
  SimpleUnit(template: String)
  PluralUnit(forms: List(#(PluralCategory, String)))
}

pub type StageLabel {
  NeutralStage(label: String)
  GenderedStage(m: String, f: String)
}

pub type Gender {
  Male
  Female
}

pub type Compactness {
  Normal
  Short
  Compact
}

pub type CompactnessOverride {
  CompactnessOverride(
    day: Result(UnitForms, Nil),
    week: Result(UnitForms, Nil),
    month: Result(UnitForms, Nil),
    year: Result(UnitForms, Nil),
    half: Result(String, Nil),
    delimiter: Result(String, Nil),
    just_born: Result(String, Nil),
  )
}

pub type AgeLocale {
  AgeLocale(
    code: String,
    plural: fn(Int) -> PluralCategory,
    day: UnitForms,
    week: UnitForms,
    month: UnitForms,
    year: UnitForms,
    half: String,
    delimiter: String,
    just_born: String,
    newborn: StageLabel,
    infant: StageLabel,
    toddler: StageLabel,
    child: StageLabel,
    teenager: StageLabel,
    adult: StageLabel,
    short: Result(CompactnessOverride, Nil),
    compact: Result(CompactnessOverride, Nil),
  )
}
