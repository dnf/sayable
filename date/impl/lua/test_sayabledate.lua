--- Tests for sayabledate — mirrors the canonical test specification.
-- All test IDs reference date/config/tests.json.

local sd = require("sayabledate")
local format_date = sd.format_date
local format_relative = sd.format_relative
local get_locale = sd.get_locale

-- ================================================================
-- 1. Null / edge cases
-- ================================================================
describe("Null / edge cases", function()
    -- 1.1
    it("format_date nil returns nil", function()
        assert.is_nil(format_date(nil))
    end)

    -- 1.2
    it("format_date empty returns nil", function()
        assert.is_nil(format_date(""))
    end)

    -- 1.3
    it("format_date invalid returns nil", function()
        assert.is_nil(format_date("invalid"))
    end)

    -- 1.4
    it("format_relative nil asOf returns nil", function()
        assert.is_nil(format_relative("2025-03-15", nil))
    end)

    -- 1.5
    it("format_relative nil date returns nil", function()
        assert.is_nil(format_relative(nil, "2025-03-15"))
    end)
end)

-- ================================================================
-- 2. format_date — normal compactness (English)
-- ================================================================
describe("format_date — normal compactness (English)", function()
    -- 2.1
    it("March 15th", function()
        assert.are.equal("March 15th", format_date("2025-03-15"))
    end)

    -- 2.2
    it("January 1st", function()
        assert.are.equal("January 1st", format_date("2025-01-01"))
    end)

    -- 2.3
    it("May 22nd", function()
        assert.are.equal("May 22nd", format_date("2025-05-22"))
    end)

    -- 2.4
    it("July 3rd", function()
        assert.are.equal("July 3rd", format_date("2025-07-03"))
    end)

    -- 2.5
    it("December 31st", function()
        assert.are.equal("December 31st", format_date("2025-12-31"))
    end)

    -- 2.6
    it("June 11th — no exception for 11", function()
        assert.are.equal("June 11th", format_date("2025-06-11"))
    end)

    -- 2.7
    it("ISO datetime input", function()
        assert.are.equal("March 15th", format_date("2025-03-15T14:30:00"))
    end)
end)

-- ================================================================
-- 3. format_date — short compactness (English)
-- ================================================================
describe("format_date — short compactness (English)", function()
    local en = get_locale("en")
    local sdf = sd.new(en, "short")

    -- 3.1
    it("Mar 15", function()
        assert.are.equal("Mar 15", sdf.format_date("2025-03-15"))
    end)

    -- 3.2
    it("Jan 1", function()
        assert.are.equal("Jan 1", sdf.format_date("2025-01-01"))
    end)

    -- 3.3
    it("Dec 25", function()
        assert.are.equal("Dec 25", sdf.format_date("2025-12-25"))
    end)
end)

-- ================================================================
-- 4. format_date — compact (English)
-- ================================================================
describe("format_date — compact (English)", function()
    local en = get_locale("en")
    local sdf = sd.new(en, "compact")

    -- 4.1
    it("3/15", function()
        assert.are.equal("3/15", sdf.format_date("2025-03-15"))
    end)

    -- 4.2
    it("1/1", function()
        assert.are.equal("1/1", sdf.format_date("2025-01-01"))
    end)
end)

-- ================================================================
-- 5. format_relative — proximity tiers (English)
-- ================================================================
describe("format_relative — proximity tiers (English)", function()
    -- 5.1
    it("today", function()
        assert.are.equal("today", format_relative("2025-03-15", "2025-03-15"))
    end)

    -- 5.2
    it("tomorrow", function()
        assert.are.equal("tomorrow", format_relative("2025-03-16", "2025-03-15"))
    end)

    -- 5.3
    it("yesterday", function()
        assert.are.equal("yesterday", format_relative("2025-03-14", "2025-03-15"))
    end)

    -- 5.4
    it("the day after tomorrow", function()
        assert.are.equal("the day after tomorrow", format_relative("2025-03-17", "2025-03-15"))
    end)

    -- 5.5
    it("the day before yesterday", function()
        assert.are.equal("the day before yesterday", format_relative("2025-03-13", "2025-03-15"))
    end)

    -- 5.6
    it("this Wednesday (+4 days)", function()
        assert.are.equal("this Wednesday", format_relative("2025-03-19", "2025-03-15"))
    end)

    -- 5.7
    it("this Thursday (+5 days)", function()
        assert.are.equal("this Thursday", format_relative("2025-03-20", "2025-03-15"))
    end)

    -- 5.8
    it("last Tuesday (-4 days)", function()
        assert.are.equal("last Tuesday", format_relative("2025-03-11", "2025-03-15"))
    end)

    -- 5.9
    it("next Saturday (+7 days)", function()
        assert.are.equal("next Saturday", format_relative("2025-03-22", "2025-03-15"))
    end)

    -- 5.10
    it("next Thursday (+12 days)", function()
        assert.are.equal("next Thursday", format_relative("2025-03-27", "2025-03-15"))
    end)

    -- 5.11
    it("calendar same year past (-14 days)", function()
        assert.are.equal("March 1st", format_relative("2025-03-01", "2025-03-15"))
    end)

    -- 5.12
    it("calendar same year future (+26 days)", function()
        assert.are.equal("April 10th", format_relative("2025-04-10", "2025-03-15"))
    end)

    -- 5.13
    it("different year future includes year", function()
        assert.are.equal("January 5th, 2026", format_relative("2026-01-05", "2025-03-15"))
    end)

    -- 5.14
    it("past year includes year", function()
        assert.are.equal("December 25th, 2024", format_relative("2024-12-25", "2025-03-15"))
    end)
end)

-- ================================================================
-- 6. format_relative — compact skips weekday tiers
-- ================================================================
describe("format_relative — compact skips weekday tiers", function()
    local en = get_locale("en")
    local sdf = sd.new(en, "compact")

    -- 6.1
    it("compact today", function()
        assert.are.equal("today", sdf.format_relative("2025-03-15", "2025-03-15"))
    end)

    -- 6.2
    it("compact tomorrow", function()
        assert.are.equal("tomorrow", sdf.format_relative("2025-03-16", "2025-03-15"))
    end)

    -- 6.3
    it("compact goes straight to numeric", function()
        assert.are.equal("3/19", sdf.format_relative("2025-03-19", "2025-03-15"))
    end)

    -- 6.4
    it("compact different year", function()
        assert.are.equal("1/5/26", sdf.format_relative("2026-01-05", "2025-03-15"))
    end)
end)

-- ================================================================
-- 7. Locale — German
-- ================================================================
describe("Locale — German", function()
    local de = get_locale("de")
    local sdf = sd.new(de)

    -- 7.1
    it("15. März", function()
        assert.are.equal("15. März", sdf.format_date("2025-03-15"))
    end)

    -- 7.2
    it("morgen", function()
        assert.are.equal("morgen", sdf.format_relative("2025-03-16", "2025-03-15"))
    end)

    -- 7.3
    it("übermorgen", function()
        assert.are.equal("übermorgen", sdf.format_relative("2025-03-17", "2025-03-15"))
    end)

    -- 7.4
    it("diesen Mittwoch", function()
        assert.are.equal("diesen Mittwoch", sdf.format_relative("2025-03-19", "2025-03-15"))
    end)
end)

-- ================================================================
-- 8. Locale — French
-- ================================================================
describe("Locale — French", function()
    local fr = get_locale("fr")
    local sdf = sd.new(fr)

    -- 8.1
    it("1er mars", function()
        assert.are.equal("1er mars", sdf.format_date("2025-03-01"))
    end)

    -- 8.2
    it("15 mars", function()
        assert.are.equal("15 mars", sdf.format_date("2025-03-15"))
    end)

    -- 8.3
    it("demain", function()
        assert.are.equal("demain", sdf.format_relative("2025-03-16", "2025-03-15"))
    end)
end)

-- ================================================================
-- 9. Locale — Japanese
-- ================================================================
describe("Locale — Japanese", function()
    local ja = get_locale("ja")
    local sdf = sd.new(ja)

    -- 9.1
    it("3月15日", function()
        assert.are.equal("3月15日", sdf.format_date("2025-03-15"))
    end)

    -- 9.2
    it("明日", function()
        assert.are.equal("明日", sdf.format_relative("2025-03-16", "2025-03-15"))
    end)

    -- 9.3
    it("今度の水曜日", function()
        assert.are.equal("今度の水曜日", sdf.format_relative("2025-03-19", "2025-03-15"))
    end)
end)

-- ================================================================
-- 10. Locale — Russian (genitive months)
-- ================================================================
describe("Locale — Russian", function()
    local ru = get_locale("ru")
    local sdf = sd.new(ru)

    -- 10.1
    it("15 марта", function()
        assert.are.equal("15 марта", sdf.format_date("2025-03-15"))
    end)

    -- 10.2
    it("завтра", function()
        assert.are.equal("завтра", sdf.format_relative("2025-03-16", "2025-03-15"))
    end)
end)

-- ================================================================
-- 11. Locale — Arabic
-- ================================================================
describe("Locale — Arabic", function()
    local ar = get_locale("ar")
    local sdf = sd.new(ar)

    -- 11.1
    it("15 مارس", function()
        assert.are.equal("15 مارس", sdf.format_date("2025-03-15"))
    end)

    -- 11.2
    it("غداً", function()
        assert.are.equal("غداً", sdf.format_relative("2025-03-16", "2025-03-15"))
    end)
end)

-- ================================================================
-- 12. Locale — Spanish
-- ================================================================
describe("Locale — Spanish", function()
    local es = get_locale("es")
    local sdf = sd.new(es)

    -- 12.1
    it("15 de marzo", function()
        assert.are.equal("15 de marzo", sdf.format_date("2025-03-15"))
    end)

    -- 12.2
    it("pasado mañana", function()
        assert.are.equal("pasado mañana", sdf.format_relative("2025-03-17", "2025-03-15"))
    end)
end)
