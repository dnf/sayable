/// Types for the sayable-duration locale system.

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

pub type Compactness {
  Normal
  Short
  Compact
}

pub type CompactnessOverride {
  CompactnessOverride(
    units: Result(List(#(String, UnitForms)), Nil),
    half: Result(String, Nil),
    delimiter: Result(String, Nil),
    ago: Result(String, Nil),
    in_future: Result(String, Nil),
  )
}

pub type DurationLocale {
  DurationLocale(
    code: String,
    plural: fn(Int) -> PluralCategory,
    units: List(#(String, UnitForms)),
    half: String,
    delimiter: String,
    just_now: String,
    ago: String,
    in_future: String,
    short: Result(CompactnessOverride, Nil),
    compact: Result(CompactnessOverride, Nil),
  )
}
