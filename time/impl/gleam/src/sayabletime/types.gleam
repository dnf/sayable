/// Types for the sayable-time locale system.
pub type Compactness {
  Normal
  Short
  Compact
}

pub type ClockConfig {
  ClockConfig(
    hours: List(String),
    midnight: String,
    noon: String,
    patterns: List(#(Int, String)),
  )
}

pub type ShortClockConfig {
  ShortClockConfig(
    use24h: Bool,
    format: String,
    am_pm: Result(#(String, String), Nil),
  )
}

pub type CompactnessOverride {
  CompactnessOverride(clock: Result(ShortClockConfig, Nil))
}

pub type TimeLocale {
  TimeLocale(
    code: String,
    clock: ClockConfig,
    short: Result(CompactnessOverride, Nil),
    compact: Result(CompactnessOverride, Nil),
  )
}
