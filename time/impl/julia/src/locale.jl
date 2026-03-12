struct ClockConfig
    hours::Vector{String}
    midnight::String
    noon::String
    patterns::Dict{Int, String}
end

function ClockConfig(; hours, midnight, noon, patterns)
    ClockConfig(hours, midnight, noon, patterns)
end

struct ShortClockConfig
    use24h::Bool
    format::String
    am_pm::Union{Tuple{String, String}, Nothing}
end

function ShortClockConfig(; use24h, format, am_pm=nothing)
    ShortClockConfig(use24h, format, am_pm)
end

struct TimeCompactnessOverride
    clock::Union{ShortClockConfig, Nothing}
end

function TimeCompactnessOverride(; clock=nothing)
    TimeCompactnessOverride(clock)
end

struct TimeLocale
    code::String
    clock::ClockConfig
    short_override::Union{TimeCompactnessOverride, Nothing}
    compact_override::Union{TimeCompactnessOverride, Nothing}
end

function TimeLocale(; code, clock, short_override=nothing, compact_override=nothing)
    TimeLocale(code, clock, short_override, compact_override)
end

@enum Compactness Normal Short Compact
