module SayableTime

export TimeLocale, ClockConfig, ShortClockConfig, TimeCompactnessOverride,
       Compactness, Normal, Short, Compact,
       SayableTimeFormatter, format_time, get_locale

const VERSION = "0.5.0"

include("locale.jl")
include("format_time.jl")
include("locales/registry.jl")

end # module
