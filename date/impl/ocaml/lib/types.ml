type compactness = Normal | Short | Compact

type compactness_override =
  { ovr_months : string list option
  ; ovr_months_in_date : string list option
  ; ovr_weekdays : string list option
  ; ovr_day_format : string option
  ; ovr_day_format_exceptions : (string * string) list option
  ; ovr_date_pattern : string option
  ; ovr_date_pattern_with_year : string option
  ; ovr_today : string option
  ; ovr_tomorrow : string option
  ; ovr_yesterday : string option
  }

type date_locale =
  { code : string
  ; months : string list
  ; weekdays : string list
  ; day_format : string
  ; day_format_exceptions : (string * string) list
  ; date_pattern : string
  ; date_pattern_with_year : string
  ; today : string
  ; tomorrow : string
  ; yesterday : string
  ; day_after_tomorrow : string option
  ; day_before_yesterday : string option
  ; this_weekday : string option
  ; next_weekday : string option
  ; last_weekday : string option
  ; months_in_date : string list option
  ; short : compactness_override option
  ; compact : compactness_override option
  }
