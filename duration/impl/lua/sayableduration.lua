--- Human-friendly duration formatting.
-- @module sayableduration

local M = {}

M.VERSION = "0.5.0"

local MAX_DURATION_MONTHS = 6000 -- 500 years, the same ceiling as sayable-age

local function is_leap_year(y)
    return (y % 4 == 0 and y % 100 ~= 0) or (y % 400 == 0)
end

local function days_in_month(y, m)
    local lengths = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    if m == 2 and is_leap_year(y) then return 29 end
    return lengths[m]
end

local function days_since_epoch(year, month, day)
    local days = 0
    if year >= 2000 then
        for y = 2000, year - 1 do
            days = days + (is_leap_year(y) and 366 or 365)
        end
    else
        for y = year, 1999 do
            days = days - (is_leap_year(y) and 366 or 365)
        end
    end
    for m = 1, month - 1 do
        days = days + days_in_month(year, m)
    end
    days = days + day - 1
    return days
end

local function is_zone_suffix(s)
    return s == "" or s == "Z" or s:match("^[+-]%d%d:%d%d$") ~= nil
end

--- Parse YYYY-MM-DDTHH:MM with optional :SS, fraction and zone suffix
-- (which is ignored) to epoch-ish seconds; nil if malformed.
local function parse_iso_to_seconds(iso)
    if not iso then return nil end
    local y, mo, d, h, mi, rest = iso:match("^(%d%d%d%d)-(%d%d)-(%d%d)T(%d%d?):(%d%d)(.*)$")
    if not y then return nil end
    local sec, after_sec = rest:match("^:(%d%d)(.*)$")
    if sec then
        rest = after_sec:match("^%.%d+(.*)$") or after_sec
    end
    if not is_zone_suffix(rest) then return nil end

    local year, month, day = tonumber(y), tonumber(mo), tonumber(d)
    local hour, minute, second = tonumber(h), tonumber(mi), tonumber(sec or "0")
    if month < 1 or month > 12 or day < 1 or day > days_in_month(year, month) then return nil end
    if hour > 23 or minute > 59 or second > 59 then return nil end

    local days = days_since_epoch(year, month, day)
    return days * 86400 + hour * 3600 + minute * 60 + second
end

local function resolve_unit(count, unit_forms, locale, half)
    half = half or ""
    local base_n
    if locale.format_number then
        base_n = locale.format_number(count)
    else
        base_n = tostring(count)
    end
    local n
    if half ~= "" and half:find("{n}", 1, true) then
        n = half:gsub("{n}", base_n)
    else
        n = base_n
    end
    local template
    if type(unit_forms) == "string" then
        template = unit_forms
    else
        -- Half-marked values use "other" plural (e.g. "1½ hours" not "1½ hour")
        local category
        if half ~= "" then
            category = "other"
        else
            category = locale.plural(count)
        end
        template = unit_forms[category] or unit_forms["other"]
    end
    local result = template:gsub("{n}", n)
    if locale.format_unit then
        result = locale.format_unit(count, result)
    end
    -- Apply {0}-style half marker (wraps the whole expression)
    if half ~= "" and half:find("{0}", 1, true) then
        result = half:gsub("{0}", result)
    end
    return result
end

local function pick(override, attr, default)
    if override then
        local val = override[attr]
        if val ~= nil then return val end
    end
    return default
end

--- Create a new SayableDuration formatter.
-- @param locale The locale table to use
-- @param compactness "normal", "short", or "compact" (default: "normal")
-- @return A SayableDuration formatter object
function M.new(locale, compactness)
    compactness = compactness or "normal"
    local sd = {}

    local ovr
    if compactness == "short" then
        ovr = locale.short
    elseif compactness == "compact" then
        ovr = locale.compact
    end

    local ovr_units = ovr and ovr.units or nil
    local units = {}
    for _, k in ipairs({ "second", "minute", "hour", "day", "week", "month", "year" }) do
        if ovr_units and ovr_units[k] then
            units[k] = ovr_units[k]
        else
            units[k] = locale.units[k]
        end
    end

    local half = pick(ovr, "half", locale.half)
    local delimiter = pick(ovr, "delimiter", locale.delimiter)
    local just_now = locale.just_now
    local ago = pick(ovr, "ago", locale.ago)
    local in_future = pick(ovr, "in_future", locale.in_future)

    local function format_duration_internal(total)
        -- 0 seconds
        if total == 0 then return just_now end

        -- 1-59 seconds
        if total < 60 then
            return resolve_unit(total, units.second, locale)
        end

        local total_minutes = math.floor(total / 60)
        local remainder_seconds = total % 60

        -- 1-4 minutes: minutes + seconds
        if total_minutes < 5 then
            local result = resolve_unit(total_minutes, units.minute, locale)
            if remainder_seconds > 0 then
                result = result .. delimiter .. resolve_unit(remainder_seconds, units.second, locale)
            end
            return result
        end

        -- 5-59 minutes
        if total_minutes < 60 then
            return resolve_unit(total_minutes, units.minute, locale)
        end

        local total_hours = math.floor(total / 3600)
        local remainder_minutes = math.floor((total % 3600) / 60)

        -- 1-5 hours: hours + minutes (with half marker)
        if total_hours <= 5 then
            if remainder_minutes == 30 then
                return resolve_unit(total_hours, units.hour, locale, half)
            end
            local result = resolve_unit(total_hours, units.hour, locale)
            if remainder_minutes > 0 then
                result = result .. delimiter .. resolve_unit(remainder_minutes, units.minute, locale)
            end
            return result
        end

        -- 6-23 hours
        if total_hours < 24 then
            return resolve_unit(total_hours, units.hour, locale)
        end

        local total_days = math.floor(total / 86400)
        local remainder_hours = math.floor((total % 86400) / 3600)

        -- 1-2 days: days + hours (with half marker)
        if total_days <= 2 then
            if remainder_hours == 12 then
                return resolve_unit(total_days, units.day, locale, half)
            end
            local result = resolve_unit(total_days, units.day, locale)
            if remainder_hours > 0 then
                result = result .. delimiter .. resolve_unit(remainder_hours, units.hour, locale)
            end
            return result
        end

        -- 3-6 days
        if total_days < 7 then
            return resolve_unit(total_days, units.day, locale)
        end

        local total_weeks = math.floor(total_days / 7)
        local remainder_days = total_days % 7

        -- 1-4 weeks: weeks + days (up to 29 days; 30+ transitions to months)
        if total_days < 30 then
            local result = resolve_unit(total_weeks, units.week, locale)
            if remainder_days > 0 then
                result = result .. delimiter .. resolve_unit(remainder_days, units.day, locale)
            end
            return result
        end

        -- Approximate months (30.44 days average)
        local total_months = math.floor(total_days / 30.44 + 0.5)
        if total_months > MAX_DURATION_MONTHS then return nil end

        -- 1-11 months
        if total_months < 12 then
            if total_months == 0 then total_months = 1 end
            return resolve_unit(total_months, units.month, locale)
        end

        -- 12+ months: years + months
        local total_years = math.floor(total_months / 12)
        local remainder_months = total_months % 12
        local result = resolve_unit(total_years, units.year, locale)
        if remainder_months > 0 then
            result = result .. delimiter .. resolve_unit(remainder_months, units.month, locale)
        end
        return result
    end

    --- Format a duration in seconds.
    -- @param seconds Integer number of seconds (nil or negative returns nil)
    -- @return Formatted duration string, or nil
    function sd.format_duration(seconds)
        if seconds == nil then return nil end
        if seconds < 0 then return nil end
        return format_duration_internal(seconds)
    end

    --- Format a duration between two ISO datetime strings.
    -- @param start_iso ISO datetime string
    -- @param end_iso ISO datetime string
    -- @return Formatted duration string, or nil
    function sd.format_duration_iso(start_iso, end_iso)
        if not start_iso or start_iso == "" then return nil end
        if not end_iso or end_iso == "" then return nil end
        local s = parse_iso_to_seconds(start_iso)
        local e = parse_iso_to_seconds(end_iso)
        if not s or not e then return nil end
        local total = math.abs(e - s)
        return format_duration_internal(total)
    end

    --- Format elapsed time as "X ago".
    -- @param start ISO datetime string
    -- @param as_of ISO datetime string
    -- @return Formatted string, or nil
    function sd.format_since(start, as_of)
        if not start or start == "" then return nil end
        if not as_of or as_of == "" then return nil end
        local s = parse_iso_to_seconds(start)
        local a = parse_iso_to_seconds(as_of)
        if not s or not a then return nil end
        local diff = a - s
        if diff < 0 then return nil end
        if diff == 0 then return just_now end
        local dur = format_duration_internal(diff)
        if not dur then return nil end
        return (ago:gsub("{0}", dur))
    end

    --- Format time until a future event as "in X".
    -- @param target ISO datetime string
    -- @param as_of ISO datetime string
    -- @return Formatted string, or nil
    function sd.format_until(target, as_of)
        if not target or target == "" then return nil end
        if not as_of or as_of == "" then return nil end
        local t = parse_iso_to_seconds(target)
        local a = parse_iso_to_seconds(as_of)
        if not t or not a then return nil end
        local diff = t - a
        if diff < 0 then return nil end
        if diff == 0 then return just_now end
        local dur = format_duration_internal(diff)
        if not dur then return nil end
        return (in_future:gsub("{0}", dur))
    end

    return sd
end

-- Default English instance
local en = require("locales.en")
local default_sd = M.new(en)

--- Format duration using the default English locale.
-- @param seconds Integer number of seconds
-- @return Formatted duration string, or nil
function M.format_duration(seconds)
    return default_sd.format_duration(seconds)
end

--- Format elapsed time using the default English locale.
-- @param start ISO datetime string
-- @param as_of ISO datetime string
-- @return Formatted string, or nil
function M.format_since(start, as_of)
    return default_sd.format_since(start, as_of)
end

--- Format time until event using the default English locale.
-- @param target ISO datetime string
-- @param as_of ISO datetime string
-- @return Formatted string, or nil
function M.format_until(target, as_of)
    return default_sd.format_until(target, as_of)
end

--- Look up a locale by its code string.
-- @param code Locale code string (e.g. "en", "fr")
-- @return Locale table, or nil if not found
function M.get_locale(code)
    local registry = require("locales.init")
    return registry.get_locale(code)
end

return M
