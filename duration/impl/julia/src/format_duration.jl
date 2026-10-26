const MAX_DURATION_MONTHS = 6000  # 500 years, the same ceiling as sayable-age

struct SayableDurationFormatter
    locale::DurationLocale
    second::Any
    minute::Any
    hour::Any
    day::Any
    week::Any
    month::Any
    year::Any
    half::String
    delimiter::String
    just_now::String
    ago::String
    in_future::String
end

function SayableDurationFormatter(locale::DurationLocale, compactness::Compactness=Normal)
    sec = locale.units["second"]
    min = locale.units["minute"]
    hr = locale.units["hour"]
    day = locale.units["day"]
    week = locale.units["week"]
    mon = locale.units["month"]
    yr = locale.units["year"]
    half = locale.half
    delim = locale.delimiter
    jn = locale.just_now
    ag = locale.ago
    inf = locale.in_future

    ovr = if compactness == Short
        locale.short_override
    elseif compactness == Compact
        locale.compact_override
    else
        nothing
    end

    if ovr !== nothing
        if ovr.units !== nothing
            haskey(ovr.units, "second") && (sec = ovr.units["second"])
            haskey(ovr.units, "minute") && (min = ovr.units["minute"])
            haskey(ovr.units, "hour") && (hr = ovr.units["hour"])
            haskey(ovr.units, "day") && (day = ovr.units["day"])
            haskey(ovr.units, "week") && (week = ovr.units["week"])
            haskey(ovr.units, "month") && (mon = ovr.units["month"])
            haskey(ovr.units, "year") && (yr = ovr.units["year"])
        end
        ovr.half !== nothing && (half = ovr.half)
        ovr.delimiter !== nothing && (delim = ovr.delimiter)
        ovr.ago !== nothing && (ag = ovr.ago)
        ovr.in_future !== nothing && (inf = ovr.in_future)
    end

    SayableDurationFormatter(locale, sec, min, hr, day, week, mon, yr,
                             half, delim, jn, ag, inf)
end

function _resolve_unit(count::Int, uf, locale::DurationLocale, half::String="")
    base_n = string(count)
    n = base_n
    if half != "" && occursin("{n}", half)
        n = replace(half, "{n}" => base_n)
    end

    template = if isa(uf, String)
        uf
    else
        # Half-marked values use "other" plural
        cat = half != "" ? "other" : locale.plural(count)
        get(uf, cat, get(uf, "other", ""))
    end

    result = replace(template, "{n}" => n)

    if half != "" && occursin("{0}", half)
        result = replace(half, "{0}" => result)
    end

    result
end

function _is_leap_year(year::Int)
    (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
end

function _days_in_month(year::Int, month::Int)
    month in (1, 3, 5, 7, 8, 10, 12) && return 31
    month in (4, 6, 9, 11) && return 30
    _is_leap_year(year) ? 29 : 28
end

function _days_since_epoch(year::Int, month::Int, day::Int)
    days = 0
    if year >= 2000
        for y in 2000:(year - 1)
            days += _is_leap_year(y) ? 366 : 365
        end
    else
        for y in year:1999
            days -= _is_leap_year(y) ? 366 : 365
        end
    end
    for m in 1:(month - 1)
        days += _days_in_month(year, m)
    end
    days += day - 1
    days
end

# YYYY-MM-DDTHH:MM with optional :SS, fraction and zone suffix (ignored).
const _TIMESTAMP = r"\A([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{1,2}):([0-9]{2})(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?\z"

_capture_int(m::RegexMatch, i::Int) = m[i] === nothing ? 0 : parse(Int, m[i])

function _parse_iso_to_seconds(iso_str::String)
    m = match(_TIMESTAMP, iso_str)
    m === nothing && return nothing
    year, month, day, hour, minute, second = (_capture_int(m, i) for i in 1:6)
    (1 <= month <= 12 && 1 <= day <= _days_in_month(year, month)) || return nothing
    (hour > 23 || minute > 59 || second > 59) && return nothing
    days = _days_since_epoch(year, month, day)
    days * 86400 + hour * 3600 + minute * 60 + second
end

function _format_duration_seconds(fmt::SayableDurationFormatter, total::Int)
    # 0 seconds
    total == 0 && return fmt.just_now

    # 1-59 seconds
    if total < 60
        return _resolve_unit(total, fmt.second, fmt.locale)
    end

    total_minutes = total ÷ 60
    remainder_seconds = total % 60

    # 1-4 minutes: minutes + seconds
    if total_minutes < 5
        result = _resolve_unit(total_minutes, fmt.minute, fmt.locale)
        if remainder_seconds > 0
            result *= fmt.delimiter * _resolve_unit(remainder_seconds, fmt.second, fmt.locale)
        end
        return result
    end

    # 5-59 minutes
    if total_minutes < 60
        return _resolve_unit(total_minutes, fmt.minute, fmt.locale)
    end

    total_hours = total ÷ 3600
    remainder_minutes = (total % 3600) ÷ 60

    # 1-5 hours: hours + minutes (with half marker)
    if total_hours <= 5
        if remainder_minutes == 30
            return _resolve_unit(total_hours, fmt.hour, fmt.locale, fmt.half)
        end
        result = _resolve_unit(total_hours, fmt.hour, fmt.locale)
        if remainder_minutes > 0
            result *= fmt.delimiter * _resolve_unit(remainder_minutes, fmt.minute, fmt.locale)
        end
        return result
    end

    # 6-23 hours
    if total_hours < 24
        return _resolve_unit(total_hours, fmt.hour, fmt.locale)
    end

    total_days = total ÷ 86400
    remainder_hours = (total % 86400) ÷ 3600

    # 1-2 days: days + hours (with half marker)
    if total_days <= 2
        if remainder_hours == 12
            return _resolve_unit(total_days, fmt.day, fmt.locale, fmt.half)
        end
        result = _resolve_unit(total_days, fmt.day, fmt.locale)
        if remainder_hours > 0
            result *= fmt.delimiter * _resolve_unit(remainder_hours, fmt.hour, fmt.locale)
        end
        return result
    end

    # 3-6 days
    if total_days < 7
        return _resolve_unit(total_days, fmt.day, fmt.locale)
    end

    total_weeks = total_days ÷ 7
    remainder_days = total_days % 7

    # 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
    if total_days < 30
        result = _resolve_unit(total_weeks, fmt.week, fmt.locale)
        if remainder_days > 0
            result *= fmt.delimiter * _resolve_unit(remainder_days, fmt.day, fmt.locale)
        end
        return result
    end

    # Approximate months (30.44 days average)
    total_months = round(Int, total_days / 30.44)
    total_months > MAX_DURATION_MONTHS && return nothing

    # 1-11 months
    if total_months < 12
        total_months == 0 && (total_months = 1)
        return _resolve_unit(total_months, fmt.month, fmt.locale)
    end

    # 12+ months: years + months
    total_years = total_months ÷ 12
    remainder_months = total_months % 12
    result = _resolve_unit(total_years, fmt.year, fmt.locale)
    if remainder_months > 0
        result *= fmt.delimiter * _resolve_unit(remainder_months, fmt.month, fmt.locale)
    end
    result
end

function format_duration(fmt::SayableDurationFormatter, seconds::Int)
    seconds < 0 && return nothing
    _format_duration_seconds(fmt, seconds)
end

function format_duration(fmt::SayableDurationFormatter, start::String, end_time::String)
    (isempty(start) || isempty(end_time)) && return nothing
    s = _parse_iso_to_seconds(start)
    e = _parse_iso_to_seconds(end_time)
    (s === nothing || e === nothing) && return nothing
    total = abs(e - s)
    _format_duration_seconds(fmt, total)
end

function format_since(fmt::SayableDurationFormatter, start::String, as_of::String)
    (isempty(start) || isempty(as_of)) && return nothing
    s = _parse_iso_to_seconds(start)
    a = _parse_iso_to_seconds(as_of)
    (s === nothing || a === nothing) && return nothing
    diff = a - s
    diff < 0 && return nothing
    diff == 0 && return fmt.just_now
    dur = _format_duration_seconds(fmt, diff)
    dur === nothing ? nothing : replace(fmt.ago, "{0}" => dur)
end

function format_until(fmt::SayableDurationFormatter, target::String, as_of::String)
    (isempty(target) || isempty(as_of)) && return nothing
    t = _parse_iso_to_seconds(target)
    a = _parse_iso_to_seconds(as_of)
    (t === nothing || a === nothing) && return nothing
    diff = t - a
    diff < 0 && return nothing
    diff == 0 && return fmt.just_now
    dur = _format_duration_seconds(fmt, diff)
    dur === nothing ? nothing : replace(fmt.in_future, "{0}" => dur)
end
