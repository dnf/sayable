module SayableDate

export DateLocale, DateCompactnessOverride,
       Compactness, Normal, Short, Compact,
       SayableDateFormatter, format_date, format_date_with_year, format_relative, get_locale

const VERSION = "0.5.0"

include("locale.jl")
include("format_date.jl")
include("locales/registry.jl")

end # module
