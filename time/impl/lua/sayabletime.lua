--- Human-friendly clock time formatting.
-- @module sayabletime

local M = {}

M.VERSION = "0.5.0"

local function is_real_date(year, month, day)
    if month < 1 or month > 12 or day < 1 then return false end
    local last = 31
    if month == 2 then
        local leap = (year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0
        last = leap and 29 or 28
    elseif month == 4 or month == 6 or month == 9 or month == 11 then
        last = 30
    end
    return day <= last
end

local function is_zone_suffix(s)
    return s == "" or s == "Z" or s:match("^[+-]%d%d:%d%d$") ~= nil
end

--- Parse H:MM or HH:MM, optional :SS and fraction, optional zone suffix
-- (which is ignored); returns hour, minute, second or nil.
local function parse_clock(s)
    local h, m, rest = s:match("^(%d%d?):(%d%d)(.*)$")
    if not h then return nil end
    local sec, after_sec = rest:match("^:(%d%d)(.*)$")
    if sec then
        rest = after_sec:match("^%.%d+(.*)$") or after_sec
    end
    if not is_zone_suffix(rest) then return nil end
    local hour, minute, second = tonumber(h), tonumber(m), tonumber(sec or "0")
    if hour > 23 or minute > 59 or second > 59 then return nil end
    return hour, minute, second
end

--- Parse a clock time, alone or after the T of an ISO datetime whose date
-- part names a real calendar day; returns hour, minute or nil.
local function parse_time(input)
    if not input then return nil end
    local clock = input
    local t_idx = input:find("T", 1, true)
    if t_idx then
        local y, m, d = input:sub(1, t_idx - 1):match("^(%d%d%d%d)-(%d%d)-(%d%d)$")
        if not y or not is_real_date(tonumber(y), tonumber(m), tonumber(d)) then return nil end
        clock = input:sub(t_idx + 1)
    end
    local hour, minute = parse_clock(clock)
    if not hour then return nil end
    return hour, minute
end

local function round_to_5(minute)
    return math.floor((minute + 2) / 5) * 5
end

--- Create a new SayableTime formatter.
-- @param locale The locale table to use
-- @param compactness "normal", "short", or "compact" (default: "normal")
-- @return A SayableTime formatter object
function M.new(locale, compactness)
    compactness = compactness or "normal"
    local st = {}

    local short_clock
    local ovr
    if compactness == "short" then
        ovr = locale.short
    elseif compactness == "compact" then
        ovr = locale.compact
    end
    if ovr then
        short_clock = ovr.clock
    end

    local function format_natural(hour, minute)
        local clock = locale.clock
        local rounded = round_to_5(minute)
        local h = hour
        if rounded == 60 then
            rounded = 0
            h = (h + 1) % 24
        end
        if rounded == 0 then
            if h == 0 then return clock.midnight end
            if h == 12 then return clock.noon end
        end
        local h12 = h % 12
        local next_h12 = (h + 1) % 12
        -- Lua arrays are 1-indexed; hours[1] = "twelve" (index 0 in other langs)
        local h_name = clock.hours[h12 + 1]
        local next_h_name = clock.hours[next_h12 + 1]
        local pattern = clock.patterns[rounded] or clock.patterns[0] or "{h}"
        local result = pattern:gsub("{h}", h_name)
        result = result:gsub("{next_h}", next_h_name)
        return result
    end

    local function format_digital(hour, minute)
        local sc = short_clock
        local fmt = sc.format
        if sc.use24h then
            local result = fmt:gsub("{h}", tostring(hour))
            result = result:gsub("{mm}", string.format("%02d", minute))
            return result
        end
        local h12 = hour % 12
        if h12 == 0 then h12 = 12 end
        local am_pm = sc.am_pm or { "AM", "PM" }
        local ampm_str = hour < 12 and am_pm[1] or am_pm[2]
        local result = fmt:gsub("{h}", tostring(h12))
        result = result:gsub("{mm}", string.format("%02d", minute))
        result = result:gsub("{ampm}", ampm_str)
        return result
    end

    --- Format a time as a natural language clock reading.
    -- @param input "HH:MM" or ISO datetime string
    -- @return Formatted time string, or nil
    function st.format_time(input)
        if not input or input == "" then return nil end
        local hour, minute = parse_time(input)
        if not hour then return nil end

        if short_clock then
            return format_digital(hour, minute)
        end
        return format_natural(hour, minute)
    end

    return st
end

-- Default English instance
local en = require("locales.en")
local default_st = M.new(en)

--- Format clock time using the default English locale.
-- @param input "HH:MM" or ISO datetime string
-- @return Formatted time string, or nil
function M.format_time(input)
    return default_st.format_time(input)
end

--- Look up a locale by its code string.
-- @param code Locale code string (e.g. "en", "fr")
-- @return Locale table, or nil if not found
function M.get_locale(code)
    local registry = require("locales.init")
    return registry.get_locale(code)
end

return M
