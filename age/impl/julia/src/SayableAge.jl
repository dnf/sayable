module SayableAge

using Dates

export AgeLocale, CompactnessOverride, StageLabel, GenderedStage,
       Compactness, Normal, Short, Compact,
       SayableAgeFormatter, format_age, format_stage, get_locale

const VERSION = "0.5.0"

include("locale.jl")
include("format_age.jl")
include("locales/registry.jl")

end # module
