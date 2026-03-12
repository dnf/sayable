struct DurationCompactnessOverride
    units::Union{Dict{String, Any}, Nothing}
    half::Union{String, Nothing}
    delimiter::Union{String, Nothing}
    ago::Union{String, Nothing}
    in_future::Union{String, Nothing}
end

function DurationCompactnessOverride(; units=nothing, half=nothing, delimiter=nothing,
                                      ago=nothing, in_future=nothing)
    DurationCompactnessOverride(units, half, delimiter, ago, in_future)
end

struct DurationLocale
    code::String
    plural::Function
    units::Dict{String, Any}
    half::String
    delimiter::String
    just_now::String
    ago::String
    in_future::String
    short_override::Union{DurationCompactnessOverride, Nothing}
    compact_override::Union{DurationCompactnessOverride, Nothing}
end

function DurationLocale(; code, plural, units, half, delimiter, just_now, ago, in_future,
                        short_override=nothing, compact_override=nothing)
    DurationLocale(code, plural, units, half, delimiter, just_now, ago, in_future,
                   short_override, compact_override)
end

@enum Compactness Normal Short Compact
