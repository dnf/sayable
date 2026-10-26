--- Tests for sayabletime — mirrors the canonical test specification.
-- All test IDs reference time/config/tests.json.

local st = require("sayabletime")
local format_time = st.format_time
local get_locale = st.get_locale

-- ================================================================
-- 1. Null / edge cases
-- ================================================================
describe("Null / edge cases", function()
    -- 1.1
    it("nil input returns nil", function()
        assert.is_nil(format_time(nil))
    end)

    -- 1.2
    it("empty string returns nil", function()
        assert.is_nil(format_time(""))
    end)

    -- 1.3
    it("invalid string returns nil", function()
        assert.is_nil(format_time("invalid"))
    end)

    -- 1.4
    it("out of range returns nil", function()
        assert.is_nil(format_time("25:00"))
    end)
end)

-- ================================================================
-- 2. Clock time (normal compactness)
-- ================================================================
describe("Clock time — normal compactness", function()
    -- 2.1
    it("midnight", function()
        assert.are.equal("midnight", format_time("00:00"))
    end)

    -- 2.2
    it("noon", function()
        assert.are.equal("noon", format_time("12:00"))
    end)

    -- 2.3
    it("three o'clock", function()
        assert.are.equal("three o'clock", format_time("15:00"))
    end)

    -- 2.4
    it("a quarter past two", function()
        assert.are.equal("a quarter past two", format_time("14:15"))
    end)

    -- 2.5
    it("half past nine", function()
        assert.are.equal("half past nine", format_time("09:30"))
    end)

    -- 2.6
    it("a quarter to eleven", function()
        assert.are.equal("a quarter to eleven", format_time("10:45"))
    end)

    -- 2.7
    it("five past eight", function()
        assert.are.equal("five past eight", format_time("08:05"))
    end)

    -- 2.8
    it("five to five", function()
        assert.are.equal("five to five", format_time("16:55"))
    end)

    -- 2.9
    it("rounds to midnight", function()
        assert.are.equal("midnight", format_time("23:58"))
    end)

    -- 2.10
    it("rounds to twenty past", function()
        assert.are.equal("twenty past seven", format_time("07:22"))
    end)

    -- 2.11
    it("ISO datetime input", function()
        assert.are.equal("a quarter past two", format_time("2025-01-15T14:15:00"))
    end)
end)

-- ================================================================
-- 3. Clock time (short compactness)
-- ================================================================
describe("Clock time — short compactness", function()
    local en = get_locale("en")
    local stf = st.new(en, "short")

    -- 3.1
    it("2:15 PM", function()
        assert.are.equal("2:15 PM", stf.format_time("14:15"))
    end)

    -- 3.2
    it("9:30 AM", function()
        assert.are.equal("9:30 AM", stf.format_time("09:30"))
    end)

    -- 3.3
    it("12:00 AM (midnight)", function()
        assert.are.equal("12:00 AM", stf.format_time("00:00"))
    end)

    -- 3.4
    it("12:00 PM (noon)", function()
        assert.are.equal("12:00 PM", stf.format_time("12:00"))
    end)
end)

-- ================================================================
-- 4. Clock time (compact)
-- ================================================================
describe("Clock time — compact", function()
    local en = get_locale("en")
    local stf = st.new(en, "compact")

    -- 4.1
    it("2:15p", function()
        assert.are.equal("2:15p", stf.format_time("14:15"))
    end)

    -- 4.2
    it("9:30a", function()
        assert.are.equal("9:30a", stf.format_time("09:30"))
    end)
end)

-- ================================================================
-- 5. Locale — German
-- ================================================================
describe("Locale — German", function()
    local de = get_locale("de")
    local stf = st.new(de)

    -- 5.1
    it("halb vier (German half-to pattern)", function()
        assert.are.equal("halb vier", stf.format_time("15:30"))
    end)
end)

-- ================================================================
-- 6. Locale — French
-- ================================================================
describe("Locale — French", function()
    local fr = get_locale("fr")
    local stf = st.new(fr)

    -- 6.1
    it("trois heures et quart", function()
        assert.are.equal("trois heures et quart", stf.format_time("15:15"))
    end)

    -- 6.2
    it("une heure", function()
        assert.are.equal("une heure", stf.format_time("13:00"))
    end)

    -- 6.3
    it("une heure et demie", function()
        assert.are.equal("une heure et demie", stf.format_time("13:30"))
    end)

    -- 6.4
    it("trois heures moins le quart", function()
        assert.are.equal("trois heures moins le quart", stf.format_time("14:45"))
    end)

    -- 6.5
    it("trois heures moins dix", function()
        assert.are.equal("trois heures moins dix", stf.format_time("14:50"))
    end)
end)

-- ================================================================
-- 7. Locale — Japanese
-- ================================================================
describe("Locale — Japanese", function()
    local ja = get_locale("ja")
    local stf = st.new(ja)

    -- 7.1
    it("三時半", function()
        assert.are.equal("三時半", stf.format_time("15:30"))
    end)
end)

-- ================================================================
-- 8. Locale — Finnish (dot separator, short)
-- ================================================================
describe("Locale — Finnish (dot separator, short)", function()
    local fi = get_locale("fi")
    local stf = st.new(fi, "short")

    -- 8.1
    it("14.15 dot separator", function()
        assert.are.equal("14.15", stf.format_time("14:15"))
    end)

    -- 8.2
    it("0.00 midnight dot", function()
        assert.are.equal("0.00", stf.format_time("00:00"))
    end)
end)

-- ================================================================
-- Sections 9-10: minutes in short/compact, input validation
-- ================================================================
describe("Sections 9-10: minutes in short/compact, input validation", function()
    -- 9.1
    it("digital modes keep the exact minute", function()
        assert.are.equal("6:01 PM", st.new(st.get_locale("en"), "short").format_time("18:01"))
    end)

    -- 9.2
    it("digital modes keep the exact minute", function()
        assert.are.equal("7:05p", st.new(st.get_locale("en"), "compact").format_time("19:05"))
    end)

    -- 10.1
    it("one-digit hour", function()
        assert.are.equal("half past nine", st.new(st.get_locale("en")).format_time("9:30"))
    end)

    -- 10.2
    it("two-digit hour", function()
        assert.are.equal("half past nine", st.new(st.get_locale("en")).format_time("09:30"))
    end)

    -- 10.3
    it("leading whitespace", function()
        assert.is_nil(st.new(st.get_locale("en")).format_time(" 9:30"))
    end)

    -- 10.4
    it("trailing whitespace", function()
        assert.is_nil(st.new(st.get_locale("en")).format_time("9:30 "))
    end)

    -- 10.5
    it("minutes need two digits", function()
        assert.is_nil(st.new(st.get_locale("en")).format_time("9:5"))
    end)

    -- 10.6
    it("hour out of range", function()
        assert.is_nil(st.new(st.get_locale("en")).format_time("24:00"))
    end)

    -- 10.7
    it("seconds are allowed and ignored", function()
        assert.are.equal("a quarter past two", st.new(st.get_locale("en")).format_time("14:15:30"))
    end)

    -- 10.8
    it("ISO datetime with zone suffix (ignored)", function()
        assert.are.equal("a quarter past two", st.new(st.get_locale("en")).format_time("2025-01-15T14:15:00Z"))
    end)

    -- 10.9
    it("ISO datetime with an impossible date", function()
        assert.is_nil(st.new(st.get_locale("en")).format_time("2025-02-30T14:15:00"))
    end)
end)
