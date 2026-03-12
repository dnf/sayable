type compactness = Normal | Short | Compact

type clock_config =
  { hours : string list
  ; midnight : string
  ; noon : string
  ; patterns : (int * string) list
  }

type short_clock_config =
  { use_24h : bool
  ; format : string
  ; am_pm : (string * string) option
  }

type compactness_override =
  { clock : short_clock_config option
  }

type time_locale =
  { code : string
  ; clock : clock_config
  ; short : compactness_override option
  ; compact : compactness_override option
  }
