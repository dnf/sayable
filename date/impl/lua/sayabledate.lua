--- Human-friendly date formatting.
-- @module sayabledate

local M = {}

M.VERSION = "0.5.0"

local function days_in_month(year, month)
    if month == 2 then
        local leap = (year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0
        return leap and 29 or 28
    end
    if month == 4 or month == 6 or month == 9 or month == 11 then return 30 end
    return 31
end

--- Parse YYYY-MM-DD naming a real calendar day, optionally followed by T and
-- a time (which is not read); nil otherwise.
local function parse_date(s)
    if not s then return nil end
    local y, m, d, rest = s:match("^(%d%d%d%d)-(%d%d)-(%d%d)(.*)$")
    if not y or (rest ~= "" and rest:sub(1, 1) ~= "T") then return nil end
    local year, month, day = tonumber(y), tonumber(m), tonumber(d)
    if month < 1 or month > 12 or day < 1 or day > days_in_month(year, month) then return nil end
    return year, month, day
end

local function to_jdn(year, month, day)
    local a = math.floor((14 - month) / 12)
    local y = year + 4800 - a
    local m = month + 12 * a - 3
    return day + math.floor((153 * m + 2) / 5) + 365 * y + math.floor(y / 4) - math.floor(y / 100) + math.floor(y / 400) - 32045
end

local function weekday(year, month, day)
    return (to_jdn(year, month, day) + 1) % 7
end

--- Create a new SayableDate formatter.
-- @param locale The locale table to use
-- @param compactness "normal", "short", or "compact" (default: "normal")
-- @return A SayableDate formatter object
function M.new(locale, compactness)
    compactness = compactness or "normal"
    local sd = {}

    local ovr
    if compactness == "short" then
        ovr = locale.short
    elseif compactness == "compact" then
        ovr = locale.compact
    end

    local months = (ovr and ovr.months) or locale.months
    local months_in_date = (ovr and ovr.months_in_date) or locale.months_in_date
    local weekdays = (ovr and ovr.weekdays) or locale.weekdays

    local day_format, day_format_exceptions
    -- When override provides day_format but not day_format_exceptions, clear exceptions
    if ovr and ovr.day_format and not ovr.day_format_exceptions then
        day_format = ovr.day_format
        day_format_exceptions = {}
    else
        day_format = (ovr and ovr.day_format) or locale.day_format
        day_format_exceptions = (ovr and ovr.day_format_exceptions) or locale.day_format_exceptions or {}
    end

    local date_pattern = (ovr and ovr.date_pattern) or locale.date_pattern
    local date_pattern_with_year = (ovr and ovr.date_pattern_with_year) or locale.date_pattern_with_year
    local today_str = (ovr and ovr.today) or locale.today
    local tomorrow_str = (ovr and ovr.tomorrow) or locale.tomorrow
    local yesterday_str = (ovr and ovr.yesterday) or locale.yesterday

    local is_compact = compactness == "compact"

    local function format_absolute(year, month, day, include_year)
        local day_str = tostring(day)
        local fmt = day_format_exceptions[day_str] or day_format
        local formatted_day = fmt:gsub("{n}", day_str)

        -- Pick month name (genitive form if available)
        local month_name = (months_in_date or months)[month]

        local pattern = include_year and date_pattern_with_year or date_pattern
        local result = pattern:gsub("{month}", month_name)
        result = result:gsub("{day}", formatted_day)
        result = result:gsub("{d}", tostring(day))
        result = result:gsub("{m}", tostring(month))
        if include_year then
            result = result:gsub("{year}", tostring(year))
            local yy = year % 100
            result = result:gsub("{yy}", string.format("%02d", yy))
        end

        return result
    end

    --- Format a date in locale-appropriate form (no year).
    -- @param date "YYYY-MM-DD" or ISO datetime string
    -- @return Formatted date string, or nil
    function sd.format_date(date)
        if not date or date == "" then return nil end
        local y, m, d = parse_date(date)
        if not y then return nil end
        return format_absolute(y, m, d, false)
    end

    --- Format a date with year in locale-appropriate form.
    -- @param date "YYYY-MM-DD" or ISO datetime string
    -- @return Formatted date string, or nil
    function sd.format_date_with_year(date)
        if not date or date == "" then return nil end
        local y, m, d = parse_date(date)
        if not y then return nil end
        return format_absolute(y, m, d, true)
    end

    --- Format a date relative to as_of.
    -- @param date "YYYY-MM-DD" or ISO datetime string
    -- @param as_of "YYYY-MM-DD" or ISO datetime string
    -- @return Formatted relative date string, or nil
    function sd.format_relative(date, as_of)
        if not date or date == "" then return nil end
        if not as_of or as_of == "" then return nil end

        local dy, dm, dd = parse_date(date)
        local ay, am, ad = parse_date(as_of)
        if not dy or not ay then return nil end

        local date_jdn = to_jdn(dy, dm, dd)
        local asof_jdn = to_jdn(ay, am, ad)
        local diff = date_jdn - asof_jdn

        -- Today
        if diff == 0 then return today_str end

        -- Tomorrow
        if diff == 1 then return tomorrow_str end

        -- Yesterday
        if diff == -1 then return yesterday_str end

        -- Day after tomorrow (optional, skipped in compact mode)
        if diff == 2 and locale.day_after_tomorrow and not is_compact then
            return locale.day_after_tomorrow
        end

        -- Day before yesterday (optional, skipped in compact mode)
        if diff == -2 and locale.day_before_yesterday and not is_compact then
            return locale.day_before_yesterday
        end

        -- Compact mode: skip weekday references, go straight to calendar date
        if is_compact then
            return format_absolute(dy, dm, dd, dy ~= ay)
        end

        -- This weekday (+2 to +6)
        if diff >= 2 and diff <= 6 and locale.this_weekday then
            local dow = weekday(dy, dm, dd)
            -- Lua 1-indexed: weekdays[1] = Sunday (dow 0)
            local wd_name = weekdays[dow + 1]
            return (locale.this_weekday:gsub("{weekday}", wd_name))
        end

        -- Last weekday (-6 to -2)
        if diff >= -6 and diff <= -2 and locale.last_weekday then
            local dow = weekday(dy, dm, dd)
            local wd_name = weekdays[dow + 1]
            return (locale.last_weekday:gsub("{weekday}", wd_name))
        end

        -- Next weekday (+7 to +13)
        if diff >= 7 and diff <= 13 and locale.next_weekday then
            local dow = weekday(dy, dm, dd)
            local wd_name = weekdays[dow + 1]
            return (locale.next_weekday:gsub("{weekday}", wd_name))
        end

        -- Calendar fallback
        return format_absolute(dy, dm, dd, dy ~= ay)
    end

    return sd
end

-- Default English instance
local en = require("locales.en")
local default_sd = M.new(en)

--- Format a date using the default English locale.
-- @param date "YYYY-MM-DD" or ISO datetime string
-- @return Formatted date string, or nil
function M.format_date(date)
    return default_sd.format_date(date)
end

--- Format a relative date using the default English locale.
-- @param date "YYYY-MM-DD" or ISO datetime string
-- @param as_of "YYYY-MM-DD" or ISO datetime string
-- @return Formatted relative date string, or nil
function M.format_relative(date, as_of)
    return default_sd.format_relative(date, as_of)
end

--- Look up a locale by its code string.
-- @param code Locale code string (e.g. "en", "fr")
-- @return Locale table, or nil if not found
function M.get_locale(code)
    local registry = require("locales.init")
    return registry.get_locale(code)
end

return M
