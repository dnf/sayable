module SayableDuration

export DurationLocale, DurationCompactnessOverride,
       Compactness, Normal, Short, Compact,
       SayableDurationFormatter, format_duration, format_since, format_until, get_locale

const VERSION = "0.5.0"

include("locale.jl")
include("format_duration.jl")
include("locales/registry.jl")

end # module
