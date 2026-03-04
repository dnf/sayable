--- Human-friendly age formatting for young children.
-- @module parenttime

local M = {}

M.VERSION = "0.5.0"

local MAX_AGE_MONTHS = 6000

local function is_leap_year(y)
    return (y % 4 == 0 and y % 100 ~= 0) or (y % 400 == 0)
end

local function days_in_month(y, m)
    local lengths = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    if m == 2 and is_leap_year(y) then return 29 end
    return lengths[m]
end

local function days_between(y1, m1, d1, y2, m2, d2)
    -- Convert a date to a day number using a simple algorithm
    local function to_days(y, m, d)
        -- Adjust for months
        if m <= 2 then
            y = y - 1
            m = m + 12
        end
        -- Julian day number calculation (Gregorian calendar)
        local a = math.floor(y / 100)
        local b = 2 - a + math.floor(a / 4)
        return math.floor(365.25 * (y + 4716)) + math.floor(30.6001 * (m + 1)) + d + b - 1524
    end
    return to_days(y2, m2, d2) - to_days(y1, m1, d1)
end

local function parse_date(s)
    if not s or s == "" then return nil end
    local y, m, d = s:match("^(%d+)-(%d+)-(%d+)$")
    if not y then return nil end
    return tonumber(y), tonumber(m), tonumber(d)
end

local function parse_age(date_of_birth, as_of)
    if not date_of_birth or date_of_birth == "" then return nil end

    local dob_y, dob_m, dob_d = parse_date(date_of_birth)
    if not dob_y then return nil end

    local ref_y, ref_m, ref_d
    if as_of then
        ref_y, ref_m, ref_d = parse_date(as_of)
        if not ref_y then return nil end
    else
        local t = os.date("*t")
        ref_y, ref_m, ref_d = t.year, t.month, t.day
    end

    local diff_days = days_between(dob_y, dob_m, dob_d, ref_y, ref_m, ref_d)
    if diff_days < 0 then return nil end

    local last_day = days_in_month(ref_y, ref_m)
    local clamped_birthday = math.min(dob_d, last_day)
    local months = (ref_y - dob_y) * 12 + (ref_m - dob_m)
    if ref_d < clamped_birthday then
        months = months - 1
    end
    if months > MAX_AGE_MONTHS then return nil end

    return months, diff_days
end

local function stage_key(months)
    if months < 2 then return "newborn" end
    if months < 12 then return "infant" end
    if months < 36 then return "toddler" end
    if months < 156 then return "child" end
    if months < 216 then return "teenager" end
    return "adult"
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
        local category = locale.plural(count)
        template = unit_forms[category] or unit_forms["other"]
    end
    local result = template:gsub("{n}", n)
    if locale.format_unit then
        result = locale.format_unit(count, result)
    end
    if half ~= "" and half:find("{0}", 1, true) then
        result = half:gsub("{0}", result)
    end
    return result
end

local function resolve_stage(label, gender)
    if type(label) == "string" then return label end
    if gender == "f" then return label.f end
    return label.m
end

local function pick(override, attr, default)
    if override then
        local val = override[attr]
        if val ~= nil then return val end
    end
    return default
end

--- Create a new ParentTime formatter.
-- @param locale The locale table to use
-- @param compactness "normal", "short", or "compact" (default: "normal")
-- @return A ParentTime formatter object
function M.new(locale, compactness)
    compactness = compactness or "normal"
    local pt = {}

    local ovr
    if compactness == "short" then
        ovr = locale.short
    elseif compactness == "compact" then
        ovr = locale.compact
    end

    local ovr_units = ovr and ovr.units or nil
    local units = {}
    for _, k in ipairs({ "day", "week", "month", "year" }) do
        if ovr_units and ovr_units[k] then
            units[k] = ovr_units[k]
        else
            units[k] = locale.units[k]
        end
    end

    local half = pick(ovr, "half", locale.half)
    local delimiter = pick(ovr, "delimiter", locale.delimiter)
    local just_born = pick(ovr, "just_born", locale.just_born)

    --- Format a human-friendly age string.
    -- @param date_of_birth YYYY-MM-DD date string
    -- @param as_of YYYY-MM-DD reference date (defaults to today)
    -- @return Formatted age string, or nil on invalid input
    function pt.format_age(date_of_birth, as_of)
        local months, diff_days = parse_age(date_of_birth, as_of)
        if months == nil then return nil end

        -- Tier 1: 0-6 days
        if diff_days == 0 then return just_born end
        if diff_days < 7 then
            return resolve_unit(diff_days, units.day, locale)
        end

        -- Tier 2: weeks + days until 3 calendar months
        if months < 3 then
            local weeks = math.floor(diff_days / 7)
            local days = diff_days % 7
            local result = resolve_unit(weeks, units.week, locale)
            if days > 0 then
                result = result .. delimiter .. resolve_unit(days, units.day, locale)
            end
            return result
        end

        -- Tier 3: 3-23 months
        if months < 24 then
            return resolve_unit(months, units.month, locale)
        end

        -- Tier 4: 24-35 months -> years + months
        if months < 36 then
            local years = math.floor(months / 12)
            local rem = months % 12
            if rem == 0 then
                return resolve_unit(years, units.year, locale)
            end
            return resolve_unit(years, units.year, locale)
                .. delimiter
                .. resolve_unit(rem, units.month, locale)
        end

        -- Tier 5: 3-6 years -> years with half marker
        if months < 84 then
            local years = math.floor(months / 12)
            local rem = months % 12
            if rem >= 6 then
                return resolve_unit(years, units.year, locale, half)
            end
            return resolve_unit(years, units.year, locale)
        end

        -- Tier 6: 7+ years
        return resolve_unit(math.floor(months / 12), units.year, locale)
    end

    --- Format a developmental stage label.
    -- @param date_of_birth YYYY-MM-DD date string
    -- @param as_of YYYY-MM-DD reference date (defaults to today)
    -- @param gender "m" or "f" for gendered locales (optional)
    -- @return Stage label string, or nil on invalid input
    function pt.format_stage(date_of_birth, as_of, gender)
        local months = parse_age(date_of_birth, as_of)
        if months == nil then return nil end
        return resolve_stage(locale.stages[stage_key(months)], gender)
    end

    return pt
end

-- Default English instance
local en = require("locales.en")
local default_pt = M.new(en)

--- Format age using the default English locale.
-- @param date_of_birth YYYY-MM-DD date string
-- @param as_of YYYY-MM-DD reference date (defaults to today)
-- @return Formatted age string, or nil on invalid input
function M.format_age(date_of_birth, as_of)
    return default_pt.format_age(date_of_birth, as_of)
end

--- Format stage using the default English locale.
-- @param date_of_birth YYYY-MM-DD date string
-- @param as_of YYYY-MM-DD reference date (defaults to today)
-- @param gender "m" or "f" for gendered locales (optional)
-- @return Stage label string, or nil on invalid input
function M.format_stage(date_of_birth, as_of, gender)
    return default_pt.format_stage(date_of_birth, as_of, gender)
end

--- Look up a locale by its code string.
-- @param code Locale code string (e.g. "en", "fr")
-- @return Locale table, or nil if not found
function M.get_locale(code)
    local registry = require("locales.init")
    return registry.get_locale(code)
end

return M
