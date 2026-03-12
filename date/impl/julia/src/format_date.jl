struct SayableDateFormatter
    locale::DateLocale
    compactness::Compactness
    months::Vector{String}
    months_in_date::Union{Vector{String}, Nothing}
    weekdays::Vector{String}
    day_format::String
    day_format_exceptions::Dict{String, String}
    date_pattern::String
    date_pattern_with_year::String
    today::String
    tomorrow::String
    yesterday::String
end

function SayableDateFormatter(locale::DateLocale, compactness::Compactness=Normal)
    ovr = if compactness == Short
        locale.short_override
    elseif compactness == Compact
        locale.compact_override
    else
        nothing
    end

    months = _pick_vec(ovr, :months, locale.months)
    months_in_date = _pick_vec_or_nothing(ovr, :months_in_date, locale.months_in_date)
    wdays = _pick_vec(ovr, :weekdays, locale.weekdays)
    df = _pick_str(ovr, :day_format, locale.day_format)

    # When short override sets day_format but not day_format_exceptions, clear exceptions
    dfe = if ovr !== nothing && ovr.day_format !== nothing && ovr.day_format_exceptions === nothing
        Dict{String, String}()
    else
        _pick_dict(ovr, :day_format_exceptions, locale.day_format_exceptions)
    end

    dp = _pick_str(ovr, :date_pattern, locale.date_pattern)
    dpy = _pick_str(ovr, :date_pattern_with_year, locale.date_pattern_with_year)
    td = _pick_str(ovr, :today, locale.today)
    tm = _pick_str(ovr, :tomorrow, locale.tomorrow)
    yd = _pick_str(ovr, :yesterday, locale.yesterday)

    SayableDateFormatter(locale, compactness, months, months_in_date, wdays,
                         df, dfe, dp, dpy, td, tm, yd)
end

function _pick_str(ovr, field::Symbol, default::String)
    ovr === nothing && return default
    val = getfield(ovr, field)
    val === nothing && return default
    return val
end

function _pick_vec(ovr, field::Symbol, default::Vector{String})
    ovr === nothing && return default
    val = getfield(ovr, field)
    val === nothing && return default
    return val
end

function _pick_vec_or_nothing(ovr, field::Symbol, default::Union{Vector{String}, Nothing})
    ovr === nothing && return default
    val = getfield(ovr, field)
    val === nothing && return default
    return val
end

function _pick_dict(ovr, field::Symbol, default::Dict{String, String})
    ovr === nothing && return default
    val = getfield(ovr, field)
    val === nothing && return default
    return val
end

function _parse_date(s::String)
    isempty(s) && return nothing
    # Handle ISO datetime (strip time part)
    date_part = occursin("T", s) ? split(s, "T")[1] : s
    parts = split(date_part, "-")
    length(parts) != 3 && return nothing
    y = tryparse(Int, parts[1])
    m = tryparse(Int, parts[2])
    d = tryparse(Int, parts[3])
    (y === nothing || m === nothing || d === nothing) && return nothing
    (m < 1 || m > 12 || d < 1 || d > 31) && return nothing
    (y, m, d)
end

function _to_jdn(year::Int, month::Int, day::Int)
    a = (14 - month) ÷ 12
    y = year + 4800 - a
    m = month + 12 * a - 3
    day + (153 * m + 2) ÷ 5 + 365 * y + y ÷ 4 - y ÷ 100 + y ÷ 400 - 32045
end

function _weekday(year::Int, month::Int, day::Int)
    # 0=Sunday, 1=Monday, ..., 6=Saturday
    jdn = _to_jdn(year, month, day)
    (jdn + 1) % 7
end

function _format_absolute(fmt::SayableDateFormatter, year::Int, month::Int, day::Int, include_year::Bool)
    day_str = string(day)
    day_fmt = get(fmt.day_format_exceptions, day_str, fmt.day_format)
    formatted_day = replace(day_fmt, "{n}" => day_str)

    month_names = fmt.months_in_date !== nothing ? fmt.months_in_date : fmt.months
    month_name = month_names[month]

    pattern = include_year ? fmt.date_pattern_with_year : fmt.date_pattern
    result = replace(pattern, "{month}" => month_name)
    result = replace(result, "{day}" => formatted_day)
    result = replace(result, "{d}" => string(day))
    result = replace(result, "{m}" => string(month))
    if include_year
        result = replace(result, "{year}" => string(year))
        yy = lpad(string(year % 100), 2, '0')
        result = replace(result, "{yy}" => yy)
    end
    result
end

function format_date(fmt::SayableDateFormatter, date::String)
    isempty(date) && return nothing
    parsed = _parse_date(date)
    parsed === nothing && return nothing
    y, m, d = parsed
    _format_absolute(fmt, y, m, d, false)
end

function format_date_with_year(fmt::SayableDateFormatter, date::String)
    isempty(date) && return nothing
    parsed = _parse_date(date)
    parsed === nothing && return nothing
    y, m, d = parsed
    _format_absolute(fmt, y, m, d, true)
end

function format_relative(fmt::SayableDateFormatter, date::String, as_of::String)
    (isempty(date) || isempty(as_of)) && return nothing
    parsed_date = _parse_date(date)
    parsed_as_of = _parse_date(as_of)
    (parsed_date === nothing || parsed_as_of === nothing) && return nothing

    dy, dm, dd = parsed_date
    ay, am, ad = parsed_as_of

    date_jdn = _to_jdn(dy, dm, dd)
    asof_jdn = _to_jdn(ay, am, ad)
    diff = date_jdn - asof_jdn

    # Today
    diff == 0 && return fmt.today

    # Tomorrow
    diff == 1 && return fmt.tomorrow

    # Yesterday
    diff == -1 && return fmt.yesterday

    loc = fmt.locale
    is_compact = fmt.compactness == Compact

    # Day after tomorrow
    if diff == 2 && loc.day_after_tomorrow !== nothing && !is_compact
        return loc.day_after_tomorrow
    end

    # Day before yesterday
    if diff == -2 && loc.day_before_yesterday !== nothing && !is_compact
        return loc.day_before_yesterday
    end

    # Compact mode: skip weekday references, go straight to calendar date
    if is_compact
        include_year = dy != ay
        return _format_absolute(fmt, dy, dm, dd, include_year)
    end

    # This weekday (+2 to +6)
    if 2 <= diff <= 6 && loc.this_weekday !== nothing
        dow = _weekday(dy, dm, dd)
        weekday_name = fmt.weekdays[dow + 1]
        return replace(loc.this_weekday, "{weekday}" => weekday_name)
    end

    # Last weekday (-2 to -6)
    if -6 <= diff <= -2 && loc.last_weekday !== nothing
        dow = _weekday(dy, dm, dd)
        weekday_name = fmt.weekdays[dow + 1]
        return replace(loc.last_weekday, "{weekday}" => weekday_name)
    end

    # Next weekday (+7 to +13)
    if 7 <= diff <= 13 && loc.next_weekday !== nothing
        dow = _weekday(dy, dm, dd)
        weekday_name = fmt.weekdays[dow + 1]
        return replace(loc.next_weekday, "{weekday}" => weekday_name)
    end

    # Calendar fallback
    include_year = dy != ay
    _format_absolute(fmt, dy, dm, dd, include_year)
end
