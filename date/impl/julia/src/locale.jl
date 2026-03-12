struct DateCompactnessOverride
    months::Union{Vector{String}, Nothing}
    months_in_date::Union{Vector{String}, Nothing}
    weekdays::Union{Vector{String}, Nothing}
    day_format::Union{String, Nothing}
    day_format_exceptions::Union{Dict{String, String}, Nothing}
    date_pattern::Union{String, Nothing}
    date_pattern_with_year::Union{String, Nothing}
    today::Union{String, Nothing}
    tomorrow::Union{String, Nothing}
    yesterday::Union{String, Nothing}
end

function DateCompactnessOverride(; months=nothing, months_in_date=nothing,
                                  weekdays=nothing, day_format=nothing,
                                  day_format_exceptions=nothing,
                                  date_pattern=nothing, date_pattern_with_year=nothing,
                                  today=nothing, tomorrow=nothing, yesterday=nothing)
    DateCompactnessOverride(months, months_in_date, weekdays, day_format,
                            day_format_exceptions, date_pattern, date_pattern_with_year,
                            today, tomorrow, yesterday)
end

struct DateLocale
    code::String
    months::Vector{String}
    weekdays::Vector{String}
    day_format::String
    day_format_exceptions::Dict{String, String}
    date_pattern::String
    date_pattern_with_year::String
    today::String
    tomorrow::String
    yesterday::String
    day_after_tomorrow::Union{String, Nothing}
    day_before_yesterday::Union{String, Nothing}
    this_weekday::Union{String, Nothing}
    next_weekday::Union{String, Nothing}
    last_weekday::Union{String, Nothing}
    months_in_date::Union{Vector{String}, Nothing}
    short_override::Union{DateCompactnessOverride, Nothing}
    compact_override::Union{DateCompactnessOverride, Nothing}
end

function DateLocale(; code, months, weekdays, day_format,
                    day_format_exceptions=Dict{String, String}(),
                    date_pattern="{day} {month}",
                    date_pattern_with_year="{day} {month} {year}",
                    today="today", tomorrow="tomorrow", yesterday="yesterday",
                    day_after_tomorrow=nothing, day_before_yesterday=nothing,
                    this_weekday=nothing, next_weekday=nothing, last_weekday=nothing,
                    months_in_date=nothing,
                    short_override=nothing, compact_override=nothing)
    DateLocale(code, months, weekdays, day_format, day_format_exceptions,
               date_pattern, date_pattern_with_year, today, tomorrow, yesterday,
               day_after_tomorrow, day_before_yesterday,
               this_weekday, next_weekday, last_weekday,
               months_in_date, short_override, compact_override)
end

@enum Compactness Normal Short Compact
