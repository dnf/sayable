struct SayableTimeFormatter
    locale::TimeLocale
    compactness::Compactness
    short_clock::Union{ShortClockConfig, Nothing}
end

function SayableTimeFormatter(locale::TimeLocale, compactness::Compactness=Normal)
    ovr = if compactness == Short
        locale.short_override
    elseif compactness == Compact
        locale.compact_override
    else
        nothing
    end

    short_clock = ovr !== nothing ? ovr.clock : nothing

    SayableTimeFormatter(locale, compactness, short_clock)
end

function _parse_time(input_str::String)
    isempty(input_str) && return nothing
    t = input_str
    if occursin("T", t)
        t = string(split(t, "T")[2])
    end
    if occursin("+", t)
        t = string(split(t, "+")[1])
    end
    if occursin("Z", t)
        t = string(split(t, "Z")[1])
    end
    parts = split(t, ":")
    length(parts) < 2 && return nothing
    hour = tryparse(Int, string(parts[1]))
    # Handle fractional seconds in minute part
    min_str = string(parts[2])
    if occursin(".", min_str)
        min_str = string(split(min_str, ".")[1])
    end
    minute = tryparse(Int, min_str)
    (hour === nothing || minute === nothing) && return nothing
    (hour < 0 || hour > 23 || minute < 0 || minute > 59) && return nothing
    (hour, minute)
end

function _round_to_5(minute::Int)
    ((minute + 2) ÷ 5) * 5
end

function _format_natural(fmt::SayableTimeFormatter, hour::Int, minute::Int)
    clock = fmt.locale.clock
    rounded = _round_to_5(minute)
    h = hour
    if rounded == 60
        rounded = 0
        h = (h + 1) % 24
    end
    if rounded == 0
        h == 0 && return clock.midnight
        h == 12 && return clock.noon
    end
    h12 = h % 12
    next_h12 = (h + 1) % 12
    h_name = clock.hours[h12 + 1]
    next_h_name = clock.hours[next_h12 + 1]
    pattern = get(clock.patterns, rounded, get(clock.patterns, 0, "{h}"))
    result = replace(pattern, "{h}" => h_name)
    result = replace(result, "{next_h}" => next_h_name)
    result
end

function _format_digital(fmt::SayableTimeFormatter, hour::Int, minute::Int)
    sc = fmt.short_clock
    fm = sc.format
    if sc.use24h
        return replace(replace(fm, "{h}" => string(hour)), "{mm}" => lpad(string(minute), 2, '0'))
    end
    h12 = hour % 12
    h12 == 0 && (h12 = 12)
    am_pm = sc.am_pm !== nothing ? sc.am_pm : ("AM", "PM")
    ampm_str = hour < 12 ? am_pm[1] : am_pm[2]
    result = replace(fm, "{h}" => string(h12))
    result = replace(result, "{mm}" => lpad(string(minute), 2, '0'))
    result = replace(result, "{ampm}" => ampm_str)
    result
end

function format_time(fmt::SayableTimeFormatter, input_str::String)
    isempty(input_str) && return nothing
    parsed = _parse_time(input_str)
    parsed === nothing && return nothing
    hour, minute = parsed

    if fmt.compactness != Normal && fmt.short_clock !== nothing
        return _format_digital(fmt, hour, minute)
    end
    _format_natural(fmt, hour, minute)
end
