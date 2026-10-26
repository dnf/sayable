const MAX_AGE_MONTHS = 6000

struct SayableAgeFormatter
    locale::AgeLocale
    day::Any
    week::Any
    month::Any
    year::Any
    half::String
    delimiter::String
    just_born::String
end

function SayableAgeFormatter(locale::AgeLocale, compactness::Compactness=Normal)
    day = locale.units["day"]
    week = locale.units["week"]
    month = locale.units["month"]
    year = locale.units["year"]
    half = locale.half
    delim = locale.delimiter
    jb = locale.just_born

    ovr = if compactness == Short
        locale.short_override
    elseif compactness == Compact
        locale.compact_override
    else
        nothing
    end

    if ovr !== nothing
        if ovr.units !== nothing
            haskey(ovr.units, "day") && (day = ovr.units["day"])
            haskey(ovr.units, "week") && (week = ovr.units["week"])
            haskey(ovr.units, "month") && (month = ovr.units["month"])
            haskey(ovr.units, "year") && (year = ovr.units["year"])
        end
        ovr.half !== nothing && (half = ovr.half)
        ovr.delimiter !== nothing && (delim = ovr.delimiter)
        ovr.just_born !== nothing && (jb = ovr.just_born)
    end

    SayableAgeFormatter(locale, day, week, month, year, half, delim, jb)
end

function _resolve_unit(count::Int, uf, locale::AgeLocale, half::String)
    base_n = string(count)

    n = base_n
    if half != "" && occursin("{n}", half)
        n = replace(half, "{n}" => base_n)
    end

    template = if isa(uf, String)
        uf
    else
        cat = locale.plural(count)
        get(uf, cat, get(uf, "other", ""))
    end

    result = replace(template, "{n}" => n)

    if half != "" && occursin("{0}", half)
        result = replace(half, "{0}" => result)
    end

    result
end

_is_ascii_digit(b::UInt8) = UInt8('0') <= b <= UInt8('9')

_digits_value(cu, range) = foldl((acc, i) -> acc * 10 + Int(cu[i] - UInt8('0')), range; init=0)

function _days_in_month(y::Int, m::Int)
    Dates.daysinmonth(y, m)
end

# Exactly YYYY-MM-DD naming a real calendar day, else nothing.
function _parse_date(s::String)
    cu = codeunits(s)
    length(cu) != 10 && return nothing
    (cu[5] != UInt8('-') || cu[8] != UInt8('-')) && return nothing
    all(i -> _is_ascii_digit(cu[i]), (1, 2, 3, 4, 6, 7, 9, 10)) || return nothing
    y = _digits_value(cu, 1:4)
    m = _digits_value(cu, 6:7)
    d = _digits_value(cu, 9:10)
    (1 <= m <= 12 && 1 <= d <= _days_in_month(y, m)) || return nothing
    (y, m, d)
end

function _parse_age(dob::String, as_of::String="")
    dob == "" && return nothing

    dob_parts = _parse_date(dob)
    dob_parts === nothing && return nothing
    dob_y, dob_m, dob_d = dob_parts

    if as_of == ""
        now = Dates.today()
        ref_y = Dates.year(now)
        ref_m = Dates.month(now)
        ref_d = Dates.day(now)
    else
        ref_parts = _parse_date(as_of)
        ref_parts === nothing && return nothing
        ref_y, ref_m, ref_d = ref_parts
    end

    dob_date = Dates.Date(dob_y, dob_m, dob_d)
    ref_date = Dates.Date(ref_y, ref_m, ref_d)
    diff_days = Dates.value(ref_date - dob_date)
    diff_days < 0 && return nothing

    last_day = _days_in_month(ref_y, ref_m)
    clamped_birthday = min(dob_d, last_day)
    months = (ref_y - dob_y) * 12 + (ref_m - dob_m)
    if ref_d < clamped_birthday
        months -= 1
    end
    months > MAX_AGE_MONTHS && return nothing

    (months=months, diff_days=diff_days)
end

function _stage_key(months::Int)
    months < 2 && return "newborn"
    months < 12 && return "infant"
    months < 36 && return "toddler"
    months < 156 && return "child"
    months < 216 && return "teenager"
    return "adult"
end

function format_age(fmt::SayableAgeFormatter, dob::String, as_of::String="")
    age = _parse_age(dob, as_of)
    age === nothing && return nothing

    months = age.months
    diff_days = age.diff_days

    # Tier 1: 0 days
    diff_days == 0 && return fmt.just_born

    # Tier 1b: 1-6 days
    if diff_days < 7
        return _resolve_unit(diff_days, fmt.day, fmt.locale, "")
    end

    # Tier 2: weeks + days until 3 calendar months
    if months < 3
        weeks = diff_days ÷ 7
        days = diff_days % 7
        result = _resolve_unit(weeks, fmt.week, fmt.locale, "")
        if days > 0
            result *= fmt.delimiter * _resolve_unit(days, fmt.day, fmt.locale, "")
        end
        return result
    end

    # Tier 3: 3-23 months
    if months < 24
        return _resolve_unit(months, fmt.month, fmt.locale, "")
    end

    # Tier 4: 24-35 months -> years + months
    if months < 36
        years = months ÷ 12
        rem = months % 12
        if rem == 0
            return _resolve_unit(years, fmt.year, fmt.locale, "")
        end
        return _resolve_unit(years, fmt.year, fmt.locale, "") *
               fmt.delimiter *
               _resolve_unit(rem, fmt.month, fmt.locale, "")
    end

    # Tier 5: 3-6 years -> years with half marker
    if months < 84
        years = months ÷ 12
        rem = months % 12
        if rem >= 6
            return _resolve_unit(years, fmt.year, fmt.locale, fmt.half)
        end
        return _resolve_unit(years, fmt.year, fmt.locale, "")
    end

    # Tier 6: 7+ years
    years = months ÷ 12
    return _resolve_unit(years, fmt.year, fmt.locale, "")
end

function format_stage(fmt::SayableAgeFormatter, dob::String, as_of::String="", gender::String="")
    age = _parse_age(dob, as_of)
    age === nothing && return nothing

    key = _stage_key(age.months)
    sl = fmt.locale.stages[key]
    resolve_stage(sl, gender)
end
