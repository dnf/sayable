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

# A clock time (H:MM or HH:MM, optional :SS and fraction, optional zone
# suffix, which is ignored), alone or after the T of an ISO datetime.
const _CLOCK = r"\A([0-9]{1,2}):([0-9]{2})(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?\z"
const _DATE = r"\A([0-9]{4})-([0-9]{2})-([0-9]{2})\z"

_is_leap_year(y::Int) = (y % 4 == 0 && y % 100 != 0) || y % 400 == 0

function _days_in_month(y::Int, m::Int)
    m == 2 && return _is_leap_year(y) ? 29 : 28
    m in (4, 6, 9, 11) ? 30 : 31
end

_is_real_date(y::Int, m::Int, d::Int) = 1 <= m <= 12 && 1 <= d <= _days_in_month(y, m)

_capture_int(m::RegexMatch, i::Int) = m[i] === nothing ? 0 : parse(Int, m[i])

function _has_real_date(date_part::AbstractString)
    d = match(_DATE, date_part)
    d !== nothing && _is_real_date(_capture_int(d, 1), _capture_int(d, 2), _capture_int(d, 3))
end

function _parse_time(input_str::String)
    isempty(input_str) && return nothing
    clock = input_str
    t_index = findfirst('T', input_str)
    if t_index !== nothing
        _has_real_date(SubString(input_str, 1, prevind(input_str, t_index))) || return nothing
        clock = SubString(input_str, nextind(input_str, t_index))
    end
    m = match(_CLOCK, clock)
    m === nothing && return nothing
    hour, minute, second = _capture_int(m, 1), _capture_int(m, 2), _capture_int(m, 3)
    (hour > 23 || minute > 59 || second > 59) && return nothing
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
