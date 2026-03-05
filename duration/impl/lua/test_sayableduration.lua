--- Tests for sayableduration — mirrors the canonical test specification.
-- All test IDs reference duration/config/tests.json.

local sd = require("sayableduration")
local format_duration = sd.format_duration
local format_since = sd.format_since
local format_until = sd.format_until
local get_locale = sd.get_locale

-- ================================================================
-- 1. Null / edge cases
-- ================================================================
describe("Null / edge cases", function()
    -- 1.1
    it("format_duration nil returns nil", function()
        assert.is_nil(format_duration(nil))
    end)

    -- 1.2
    it("format_duration negative returns nil", function()
        assert.is_nil(format_duration(-1))
    end)

    -- 1.3
    it("format_since nil start returns nil", function()
        assert.is_nil(format_since(nil, "2025-01-15T10:00:00"))
    end)

    -- 1.4
    it("format_until nil target returns nil", function()
        assert.is_nil(format_until(nil, "2025-01-15T10:00:00"))
    end)

    -- 1.5
    it("format_since asOf before start returns nil", function()
        assert.is_nil(format_since("2025-01-15T10:00:00", "2025-01-15T09:00:00"))
    end)

    -- 1.6
    it("format_until target in the past returns nil", function()
        assert.is_nil(format_until("2025-01-15T09:00:00", "2025-01-15T10:00:00"))
    end)
end)

-- ================================================================
-- 2. Duration — seconds tier (0-59s)
-- ================================================================
describe("Duration — seconds tier", function()
    -- 2.1
    it("0 seconds is just now", function()
        assert.are.equal("just now", format_duration(0))
    end)

    -- 2.2
    it("1 second", function()
        assert.are.equal("1 second", format_duration(1))
    end)

    -- 2.3
    it("45 seconds", function()
        assert.are.equal("45 seconds", format_duration(45))
    end)

    -- 2.4
    it("59 seconds", function()
        assert.are.equal("59 seconds", format_duration(59))
    end)
end)

-- ================================================================
-- 3. Duration — minutes + seconds tier (1-4 min)
-- ================================================================
describe("Duration — minutes + seconds tier", function()
    -- 3.1
    it("1 minute", function()
        assert.are.equal("1 minute", format_duration(60))
    end)

    -- 3.2
    it("1 minute, 30 seconds", function()
        assert.are.equal("1 minute, 30 seconds", format_duration(90))
    end)

    -- 3.3
    it("4 minutes", function()
        assert.are.equal("4 minutes", format_duration(240))
    end)

    -- 3.4
    it("4 minutes, 30 seconds", function()
        assert.are.equal("4 minutes, 30 seconds", format_duration(270))
    end)
end)

-- ================================================================
-- 4. Duration — minutes tier (5-59 min)
-- ================================================================
describe("Duration — minutes tier", function()
    -- 4.1
    it("5 minutes", function()
        assert.are.equal("5 minutes", format_duration(300))
    end)

    -- 4.2
    it("25 minutes", function()
        assert.are.equal("25 minutes", format_duration(1500))
    end)

    -- 4.3
    it("59 minutes", function()
        assert.are.equal("59 minutes", format_duration(3540))
    end)
end)

-- ================================================================
-- 5. Duration — hours + minutes tier (1-5 hr)
-- ================================================================
describe("Duration — hours + minutes tier", function()
    -- 5.1
    it("1 hour", function()
        assert.are.equal("1 hour", format_duration(3600))
    end)

    -- 5.2
    it("1½ hours (half marker)", function()
        assert.are.equal("1½ hours", format_duration(5400))
    end)

    -- 5.3
    it("2 hours, 15 minutes", function()
        assert.are.equal("2 hours, 15 minutes", format_duration(8100))
    end)

    -- 5.4
    it("5 hours", function()
        assert.are.equal("5 hours", format_duration(18000))
    end)
end)

-- ================================================================
-- 6. Duration — hours tier (6-23 hr)
-- ================================================================
describe("Duration — hours tier", function()
    -- 6.1
    it("8 hours", function()
        assert.are.equal("8 hours", format_duration(28800))
    end)

    -- 6.2
    it("23 hours", function()
        assert.are.equal("23 hours", format_duration(82800))
    end)
end)

-- ================================================================
-- 7. Duration — days tier
-- ================================================================
describe("Duration — days tier", function()
    -- 7.1
    it("1 day", function()
        assert.are.equal("1 day", format_duration(86400))
    end)

    -- 7.2
    it("1 day, 3 hours", function()
        assert.are.equal("1 day, 3 hours", format_duration(97200))
    end)

    -- 7.3
    it("1½ days (half marker)", function()
        assert.are.equal("1½ days", format_duration(129600))
    end)

    -- 7.4
    it("5 days", function()
        assert.are.equal("5 days", format_duration(432000))
    end)

    -- 7.5
    it("2 days", function()
        assert.are.equal("2 days", format_duration(172800))
    end)
end)

-- ================================================================
-- 8. Duration — weeks tier
-- ================================================================
describe("Duration — weeks tier", function()
    -- 8.1
    it("1 week", function()
        assert.are.equal("1 week", format_duration(604800))
    end)

    -- 8.2
    it("2 weeks, 1 day", function()
        assert.are.equal("2 weeks, 1 day", format_duration(1296000))
    end)

    -- 8.3
    it("4 weeks", function()
        assert.are.equal("4 weeks", format_duration(2419200))
    end)
end)

-- ================================================================
-- 9. Duration — months and years tier
-- ================================================================
describe("Duration — months and years tier", function()
    -- 9.1
    it("1 month", function()
        assert.are.equal("1 month", format_duration(2678400))
    end)

    -- 9.2
    it("3 months", function()
        assert.are.equal("3 months", format_duration(7884000))
    end)

    -- 9.3
    it("1 year", function()
        assert.are.equal("1 year", format_duration(31536000))
    end)

    -- 9.4
    it("1 year, 3 months", function()
        assert.are.equal("1 year, 3 months", format_duration(39420000))
    end)
end)

-- ================================================================
-- 10. Duration from ISO timestamps
-- ================================================================
describe("Duration from ISO timestamps", function()
    local en = get_locale("en")
    local sdf = sd.new(en)

    -- 10.1
    it("ISO 1½ hours", function()
        assert.are.equal("1½ hours", sdf.format_duration_iso("2025-01-15T10:00:00", "2025-01-15T11:30:00"))
    end)

    -- 10.2
    it("ISO 45 minutes", function()
        assert.are.equal("45 minutes", sdf.format_duration_iso("2025-01-15T10:00:00", "2025-01-15T10:45:00"))
    end)
end)

-- ================================================================
-- 11. Relative time — since
-- ================================================================
describe("Relative time — since", function()
    -- 11.1
    it("since just now", function()
        assert.are.equal("just now", format_since("2025-01-15T10:00:00", "2025-01-15T10:00:00"))
    end)

    -- 11.2
    it("since 30 seconds ago", function()
        assert.are.equal("30 seconds ago", format_since("2025-01-15T10:00:00", "2025-01-15T10:00:30"))
    end)

    -- 11.3
    it("since 45 minutes ago", function()
        assert.are.equal("45 minutes ago", format_since("2025-01-15T10:00:00", "2025-01-15T10:45:00"))
    end)

    -- 11.4
    it("since 3 hours ago", function()
        assert.are.equal("3 hours ago", format_since("2025-01-15T10:00:00", "2025-01-15T13:00:00"))
    end)
end)

-- ================================================================
-- 12. Relative time — until
-- ================================================================
describe("Relative time — until", function()
    -- 12.1
    it("until just now", function()
        assert.are.equal("just now", format_until("2025-01-15T10:00:00", "2025-01-15T10:00:00"))
    end)

    -- 12.2
    it("until in 20 minutes", function()
        assert.are.equal("in 20 minutes", format_until("2025-01-15T10:20:00", "2025-01-15T10:00:00"))
    end)

    -- 12.3
    it("until in 3 hours", function()
        assert.are.equal("in 3 hours", format_until("2025-01-15T13:00:00", "2025-01-15T10:00:00"))
    end)
end)

-- ================================================================
-- 13. Locale — German
-- ================================================================
describe("Locale — German", function()
    local de = get_locale("de")
    local sdf = sd.new(de)

    -- 13.1
    it("1 Stunde", function()
        assert.are.equal("1 Stunde", sdf.format_duration(3600))
    end)

    -- 13.2
    it("vor 5 Minuten", function()
        assert.are.equal("vor 5 Minuten", sdf.format_since("2025-01-15T10:00:00", "2025-01-15T10:05:00"))
    end)
end)

-- ================================================================
-- 14. Locale — French
-- ================================================================
describe("Locale — French", function()
    local fr = get_locale("fr")
    local sdf = sd.new(fr)

    -- 14.1
    it("2 heures", function()
        assert.are.equal("2 heures", sdf.format_duration(7200))
    end)
end)

-- ================================================================
-- 15. Locale — Japanese
-- ================================================================
describe("Locale — Japanese", function()
    local ja = get_locale("ja")
    local sdf = sd.new(ja)

    -- 15.1
    it("2分", function()
        assert.are.equal("2分", sdf.format_duration(120))
    end)

    -- 15.2
    it("1時間前", function()
        assert.are.equal("1時間前", sdf.format_since("2025-01-15T10:00:00", "2025-01-15T11:00:00"))
    end)
end)

-- ================================================================
-- 16. Short compactness — duration
-- ================================================================
describe("Short compactness — duration", function()
    local en = get_locale("en")
    local sdf = sd.new(en, "short")

    -- 16.1
    it("1h", function()
        assert.are.equal("1h", sdf.format_duration(3600))
    end)

    -- 16.2
    it("1m, 30s", function()
        assert.are.equal("1m, 30s", sdf.format_duration(90))
    end)
end)

-- ================================================================
-- 17. Compact compactness — duration
-- ================================================================
describe("Compact compactness — duration", function()
    local en = get_locale("en")
    local sdf = sd.new(en, "compact")

    -- 17.1
    it("1h", function()
        assert.are.equal("1h", sdf.format_duration(3600))
    end)

    -- 17.2
    it("1m30s", function()
        assert.are.equal("1m30s", sdf.format_duration(90))
    end)
end)
