--- Human-friendly clock time formatting.
-- @module sayabletime

local M = {}

M.VERSION = "0.1.0"

local function parse_time(input)
    if not input or input == "" then return nil end

    local t = input
    -- Extract time from ISO datetime
    local t_idx = t:find("T", 1, true)
    if t_idx then t = t:sub(t_idx + 1) end

    -- Strip timezone
    local plus_idx = t:find("+", 1, true)
    if plus_idx then t = t:sub(1, plus_idx - 1) end
    local z_idx = t:find("Z", 1, true)
    if z_idx then t = t:sub(1, z_idx - 1) end

    local parts = {}
    for seg in t:gmatch("[^:]+") do
        parts[#parts + 1] = seg
    end
    if #parts < 2 then return nil end

    local hour = tonumber(parts[1])
    local minute = tonumber(parts[2])
    if not hour or not minute then return nil end
    if hour < 0 or hour > 23 or minute < 0 or minute > 59 then return nil end

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
