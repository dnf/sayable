struct StageLabel
    label::String
    m::String
    f::String
end

StageLabel(label::String) = StageLabel(label, "", "")
GenderedStage(m::String, f::String) = StageLabel("", m, f)

function resolve_stage(sl::StageLabel, gender::String)
    sl.m == "" && return sl.label
    gender == "f" && return sl.f
    return sl.m
end

struct CompactnessOverride
    units::Union{Dict{String, Any}, Nothing}
    half::Union{String, Nothing}
    delimiter::Union{String, Nothing}
    just_born::Union{String, Nothing}
end

function CompactnessOverride(; units=nothing, half=nothing, delimiter=nothing, just_born=nothing)
    CompactnessOverride(units, half, delimiter, just_born)
end

struct AgeLocale
    code::String
    plural::Function
    units::Dict{String, Any}
    half::String
    delimiter::String
    just_born::String
    stages::Dict{String, StageLabel}
    short_override::Union{CompactnessOverride, Nothing}
    compact_override::Union{CompactnessOverride, Nothing}
end

function AgeLocale(; code, plural, units, half, delimiter, just_born, stages,
                   short_override=nothing, compact_override=nothing)
    AgeLocale(code, plural, units, half, delimiter, just_born, stages,
              short_override, compact_override)
end

@enum Compactness Normal Short Compact
