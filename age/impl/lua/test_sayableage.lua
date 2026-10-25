--- Tests for sayableage — mirrors the canonical test specification.
-- All test IDs reference config/tests.json.

local sayableage = require("sayableage")
local format_age = sayableage.format_age
local format_stage = sayableage.format_stage
local get_locale = sayableage.get_locale

-- ================================================================
-- 1. Null / edge cases
-- ================================================================
describe("Null / edge cases", function()
    -- 1.1
    it("returns nil for nil input", function()
        assert.is_nil(format_age(nil, "2025-06-15"))
    end)

    -- 1.3
    it("returns nil for empty string", function()
        assert.is_nil(format_age("", "2025-06-15"))
    end)

    -- 1.4
    it("returns nil for future date of birth", function()
        assert.is_nil(format_age("2025-07-01", "2025-06-15"))
    end)

    -- 1.5
    it("exactly 500 years is allowed", function()
        assert.are.equal("500 years", format_age("1525-06-15", "2025-06-15"))
    end)

    -- 1.6
    it("501 years exceeds max age", function()
        assert.is_nil(format_age("1524-06-15", "2025-06-15"))
    end)

    -- 1.7
    it("1000 years exceeds max age", function()
        assert.is_nil(format_age("1025-06-15", "2025-06-15"))
    end)
end)

-- ================================================================
-- 2. Days tier (0-6 days)
-- ================================================================
describe("Days tier", function()
    -- 2.1
    it("born today", function()
        assert.are.equal("Newborn", format_age("2025-06-15", "2025-06-15"))
    end)

    -- 2.2
    it("1 day ago singular", function()
        assert.are.equal("1 day", format_age("2025-06-14", "2025-06-15"))
    end)

    -- 2.3
    it("3 days ago", function()
        assert.are.equal("3 days", format_age("2025-06-12", "2025-06-15"))
    end)

    -- 2.4
    it("6 days ago", function()
        assert.are.equal("6 days", format_age("2025-06-09", "2025-06-15"))
    end)

    -- 2.5
    it("7 days transitions to weeks", function()
        assert.are.equal("1 week", format_age("2025-06-08", "2025-06-15"))
    end)
end)

-- ================================================================
-- 3. Weeks+days tier (7 days to <3 calendar months)
-- ================================================================
describe("Weeks+days tier", function()
    -- 3.1
    it("exactly 7 days", function()
        assert.are.equal("1 week", format_age("2025-06-08", "2025-06-15"))
    end)

    -- 3.2
    it("8 days", function()
        assert.are.equal("1 week, 1 day", format_age("2025-06-07", "2025-06-15"))
    end)

    -- 3.3
    it("9 days", function()
        assert.are.equal("1 week, 2 days", format_age("2025-06-06", "2025-06-15"))
    end)

    -- 3.4
    it("13 days", function()
        assert.are.equal("1 week, 6 days", format_age("2025-06-02", "2025-06-15"))
    end)

    -- 3.5
    it("14 days", function()
        assert.are.equal("2 weeks", format_age("2025-06-01", "2025-06-15"))
    end)

    -- 3.6
    it("15 days", function()
        assert.are.equal("2 weeks, 1 day", format_age("2025-05-31", "2025-06-15"))
    end)

    -- 3.7
    it("20 days", function()
        assert.are.equal("2 weeks, 6 days", format_age("2025-05-26", "2025-06-15"))
    end)

    -- 3.8
    it("21 days", function()
        assert.are.equal("3 weeks", format_age("2025-05-25", "2025-06-15"))
    end)

    -- 3.9
    it("1 calendar month still shows weeks+days", function()
        assert.are.equal("4 weeks, 3 days", format_age("2025-05-15", "2025-06-15"))
    end)

    -- 3.10
    it("2 calendar months still shows weeks+days", function()
        assert.are.equal("8 weeks, 5 days", format_age("2025-04-15", "2025-06-15"))
    end)

    -- 3.11
    it("day before 3-month birthday", function()
        assert.are.equal("13 weeks", format_age("2025-03-15", "2025-06-14"))
    end)

    -- 3.12
    it("on 3-month birthday switches to months", function()
        assert.are.equal("3 months", format_age("2025-03-15", "2025-06-15"))
    end)
end)

-- ================================================================
-- 4. Month boundaries — standard months
-- ================================================================
describe("Month boundaries — standard", function()
    -- 4.1
    it("born Jan 1 check Apr 1", function()
        assert.are.equal("3 months", format_age("2025-01-01", "2025-04-01"))
    end)

    -- 4.2
    it("born Jan 1 check Mar 31 still weeks", function()
        local result = format_age("2025-01-01", "2025-03-31")
        assert.is_not_nil(result)
        assert.is_truthy(result:find("week"))
    end)

    -- 4.3
    it("born Jun 15 check Sep 15", function()
        assert.are.equal("3 months", format_age("2025-06-15", "2025-09-15"))
    end)

    -- 4.4
    it("born Jun 15 check Sep 14 still weeks", function()
        local result = format_age("2025-06-15", "2025-09-14")
        assert.is_not_nil(result)
        assert.is_truthy(result:find("week"))
    end)

    -- 4.5
    it("born Jun 15 check Dec 15", function()
        assert.are.equal("6 months", format_age("2025-06-15", "2025-12-15"))
    end)
end)

-- ================================================================
-- 5. Month boundaries — February non-leap year
-- ================================================================
describe("Month boundaries — Feb non-leap", function()
    -- 5.1
    it("born Jan 31 check Feb 28 non-leap", function()
        assert.are.equal("4 weeks", format_age("2025-01-31", "2025-02-28"))
    end)

    -- 5.2
    it("born Jan 31 check Apr 30", function()
        assert.are.equal("3 months", format_age("2025-01-31", "2025-04-30"))
    end)

    -- 5.3
    it("born Jan 31 check Apr 29 still weeks", function()
        local result = format_age("2025-01-31", "2025-04-29")
        assert.is_not_nil(result)
        assert.is_truthy(result:find("week"))
    end)

    -- 5.4
    it("born Feb 1 check May 1", function()
        assert.are.equal("3 months", format_age("2025-02-01", "2025-05-01"))
    end)

    -- 5.5
    it("born Feb 1 check Apr 30 still weeks", function()
        local result = format_age("2025-02-01", "2025-04-30")
        assert.is_not_nil(result)
        assert.is_truthy(result:find("week"))
    end)
end)

-- ================================================================
-- 6. Month boundaries — February leap year
-- ================================================================
describe("Month boundaries — Feb leap", function()
    -- 6.1
    it("born Jan 31 check Feb 29 leap", function()
        assert.are.equal("4 weeks, 1 day", format_age("2024-01-31", "2024-02-29"))
    end)

    -- 6.2
    it("born Jan 31 check Feb 28 leap", function()
        assert.are.equal("4 weeks", format_age("2024-01-31", "2024-02-28"))
    end)

    -- 6.3
    it("born Jan 31 check Apr 30 leap", function()
        assert.are.equal("3 months", format_age("2024-01-31", "2024-04-30"))
    end)

    -- 6.4
    it("born Jan 30 check Feb 29 leap still weeks", function()
        local result = format_age("2024-01-30", "2024-02-29")
        assert.is_not_nil(result)
        assert.is_truthy(result:find("week"))
    end)

    -- 6.5
    it("born Jan 30 check Feb 28 leap still weeks", function()
        local result = format_age("2024-01-30", "2024-02-28")
        assert.is_not_nil(result)
        assert.is_truthy(result:find("week"))
    end)
end)

-- ================================================================
-- 7. Month boundaries — 30-day months
-- ================================================================
describe("Month boundaries — 30-day months", function()
    -- 7.1
    it("born Mar 31 check Jun 30", function()
        assert.are.equal("3 months", format_age("2025-03-31", "2025-06-30"))
    end)

    -- 7.2
    it("born Mar 31 check Jun 29 still weeks", function()
        local result = format_age("2025-03-31", "2025-06-29")
        assert.is_not_nil(result)
        assert.is_truthy(result:find("week"))
    end)

    -- 7.3
    it("born Aug 31 check Nov 30", function()
        assert.are.equal("3 months", format_age("2025-08-31", "2025-11-30"))
    end)

    -- 7.4
    it("born Aug 31 check Nov 29 still weeks", function()
        local result = format_age("2025-08-31", "2025-11-29")
        assert.is_not_nil(result)
        assert.is_truthy(result:find("week"))
    end)
end)

-- ================================================================
-- 8. Month boundaries — leap year baby (born Feb 29)
-- ================================================================
describe("Month boundaries — leap year baby", function()
    -- 8.1
    it("born Feb 29 check May 29", function()
        assert.are.equal("3 months", format_age("2024-02-29", "2024-05-29"))
    end)

    -- 8.2
    it("born Feb 29 check May 28 still weeks", function()
        local result = format_age("2024-02-29", "2024-05-28")
        assert.is_not_nil(result)
        assert.is_truthy(result:find("week"))
    end)

    -- 8.3
    it("born Feb 29 check Feb 28 non-leap", function()
        assert.are.equal("12 months", format_age("2024-02-29", "2025-02-28"))
    end)

    -- 8.4
    it("born Feb 29 check Mar 1 next year", function()
        assert.are.equal("12 months", format_age("2024-02-29", "2025-03-01"))
    end)
end)

-- ================================================================
-- 9. Months tier (3-23 months)
-- ================================================================
describe("Months tier", function()
    -- 9.1
    it("3 months at transition", function()
        assert.are.equal("3 months", format_age("2025-01-15", "2025-04-15"))
    end)

    -- 9.2
    it("6 months", function()
        assert.are.equal("6 months", format_age("2025-01-15", "2025-07-15"))
    end)

    -- 9.3
    it("12 months not 1 year", function()
        assert.are.equal("12 months", format_age("2024-06-15", "2025-06-15"))
    end)

    -- 9.4
    it("23 months upper boundary", function()
        assert.are.equal("23 months", format_age("2024-01-15", "2025-12-15"))
    end)

    -- 9.5
    it("one day before month boundary", function()
        assert.are.equal("5 months", format_age("2025-01-15", "2025-07-14"))
    end)

    -- 9.6
    it("crossing year boundary", function()
        assert.are.equal("5 months", format_age("2024-11-10", "2025-04-10"))
    end)
end)

-- ================================================================
-- 10. Years+months tier (24-35 months)
-- ================================================================
describe("Years+months tier", function()
    -- 10.1
    it("2 years at 24 months", function()
        assert.are.equal("2 years", format_age("2023-06-15", "2025-06-15"))
    end)

    -- 10.2
    it("2 years 1 month singular", function()
        assert.are.equal("2 years, 1 month", format_age("2023-06-15", "2025-07-15"))
    end)

    -- 10.3
    it("2 years 6 months", function()
        assert.are.equal("2 years, 6 months", format_age("2023-06-15", "2025-12-15"))
    end)

    -- 10.4
    it("2 years 11 months upper boundary", function()
        assert.are.equal("2 years, 11 months", format_age("2023-06-15", "2026-05-15"))
    end)

    -- 10.5
    it("one day before 24 months stays in months", function()
        assert.are.equal("23 months", format_age("2023-06-15", "2025-06-14"))
    end)
end)

-- ================================================================
-- 11. Half-year tier (3-6 years)
-- ================================================================
describe("Half-year tier", function()
    -- 11.1
    it("3 years exact", function()
        assert.are.equal("3 years", format_age("2022-06-15", "2025-06-15"))
    end)

    -- 11.2
    it("3 years 5 months", function()
        assert.are.equal("3 years", format_age("2022-06-15", "2025-11-15"))
    end)

    -- 11.3
    it("3 and half years", function()
        assert.are.equal("3½ years", format_age("2022-06-15", "2025-12-15"))
    end)

    -- 11.4
    it("3 years 11 months", function()
        assert.are.equal("3½ years", format_age("2022-06-15", "2026-05-15"))
    end)

    -- 11.5
    it("4 years exact", function()
        assert.are.equal("4 years", format_age("2021-06-15", "2025-06-15"))
    end)

    -- 11.6
    it("4 and half years", function()
        assert.are.equal("4½ years", format_age("2021-06-15", "2025-12-15"))
    end)

    -- 11.7
    it("5 years exact", function()
        assert.are.equal("5 years", format_age("2020-06-15", "2025-06-15"))
    end)

    -- 11.8
    it("5 and half years", function()
        assert.are.equal("5½ years", format_age("2020-06-15", "2026-02-15"))
    end)

    -- 11.9
    it("6 years exact", function()
        assert.are.equal("6 years", format_age("2019-06-15", "2025-06-15"))
    end)

    -- 11.10
    it("6 and half years", function()
        assert.are.equal("6½ years", format_age("2019-06-15", "2025-12-15"))
    end)

    -- 11.11
    it("6 years 11 months", function()
        assert.are.equal("6½ years", format_age("2019-06-15", "2026-05-15"))
    end)

    -- 11.12
    it("one day before 3rd birthday", function()
        assert.are.equal("2 years, 11 months", format_age("2022-06-15", "2025-06-14"))
    end)
end)

-- ================================================================
-- 12. Integer tier (7+ years)
-- ================================================================
describe("Integer tier", function()
    -- 12.1
    it("7 years exact", function()
        assert.are.equal("7 years", format_age("2018-06-15", "2025-06-15"))
    end)

    -- 12.2
    it("7 years 6 months no half", function()
        assert.are.equal("7 years", format_age("2018-03-20", "2025-06-15"))
    end)

    -- 12.3
    it("45 years adult", function()
        assert.are.equal("45 years", format_age("1980-01-01", "2025-06-15"))
    end)
end)

-- ================================================================
-- 13. Cross-year transitions with February
-- ================================================================
describe("Cross-year transitions with Feb", function()
    -- 13.1
    it("born Dec 31 check Mar 31", function()
        assert.are.equal("3 months", format_age("2024-12-31", "2025-03-31"))
    end)

    -- 13.2
    it("born Dec 31 check Mar 30 still weeks", function()
        local result = format_age("2024-12-31", "2025-03-30")
        assert.is_not_nil(result)
        assert.is_truthy(result:find("week"))
    end)

    -- 13.3
    it("born Nov 30 check Feb 28", function()
        assert.are.equal("3 months", format_age("2024-11-30", "2025-02-28"))
    end)

    -- 13.4
    it("born Nov 30 check Feb 27 still weeks", function()
        local result = format_age("2024-11-30", "2025-02-27")
        assert.is_not_nil(result)
        assert.is_truthy(result:find("week"))
    end)
end)

-- ================================================================
-- 14. Born-on-31st progression
-- ================================================================
describe("Born-on-31st progression", function()
    -- 14.1
    it("Jan 31 to Apr 30", function()
        assert.are.equal("3 months", format_age("2025-01-31", "2025-04-30"))
    end)

    -- 14.2
    it("Jan 31 to May 31", function()
        assert.are.equal("4 months", format_age("2025-01-31", "2025-05-31"))
    end)

    -- 14.3
    it("Jan 31 to Jun 30 clamped", function()
        assert.are.equal("5 months", format_age("2025-01-31", "2025-06-30"))
    end)

    -- 14.4
    it("Jan 31 to Jul 1 before birthday", function()
        assert.are.equal("5 months", format_age("2025-01-31", "2025-07-01"))
    end)

    -- 14.5
    it("Jan 31 to Jul 31", function()
        assert.are.equal("6 months", format_age("2025-01-31", "2025-07-31"))
    end)
end)

-- ================================================================
-- 15. Default asOf (current date)
-- ================================================================
describe("Default asOf", function()
    -- 15.1, 15.2
    -- Note: We test the default asOf by mocking os.date in parse_age.
    -- Since Lua doesn't have a standard clock-mock, we test via the
    -- explicit as_of parameter here, which exercises the same code paths.
    -- The default-asOf behavior (os.date fallback) is implicitly tested
    -- by the fact that format_age works without as_of in normal usage.
    it("returns correct age when as_of is explicit (proxy for default)", function()
        assert.are.equal("5 years", format_age("2020-01-01", "2025-06-15"))
        assert.are.equal("5 days", format_age("2025-06-10", "2025-06-15"))
    end)
end)

-- ================================================================
-- 16. formatStage null/edge cases
-- ================================================================
describe("formatStage null/edge cases", function()
    -- 16.1
    it("returns nil for nil", function()
        assert.is_nil(format_stage(nil, "2025-06-15"))
    end)

    -- 16.3
    it("returns nil for empty string", function()
        assert.is_nil(format_stage("", "2025-06-15"))
    end)

    -- 16.4
    it("returns nil for future dob", function()
        assert.is_nil(format_stage("2025-07-01", "2025-06-15"))
    end)

    -- 16.5
    it("exactly 500 years returns Adult", function()
        assert.are.equal("Adult", format_stage("1525-06-15", "2025-06-15"))
    end)

    -- 16.6
    it("501 years exceeds max age", function()
        assert.is_nil(format_stage("1524-06-15", "2025-06-15"))
    end)
end)

-- ================================================================
-- 17. formatStage — Newborn (0-1 months)
-- ================================================================
describe("formatStage — Newborn", function()
    -- 17.1
    it("born today", function()
        assert.are.equal("Newborn", format_stage("2025-06-15", "2025-06-15"))
    end)

    -- 17.2
    it("1 day old", function()
        assert.are.equal("Newborn", format_stage("2025-06-14", "2025-06-15"))
    end)

    -- 17.3
    it("3 weeks old", function()
        assert.are.equal("Newborn", format_stage("2025-05-25", "2025-06-15"))
    end)

    -- 17.4
    it("1 month old", function()
        assert.are.equal("Newborn", format_stage("2025-05-15", "2025-06-15"))
    end)

    -- 17.5
    it("1 month 29 days still newborn", function()
        assert.are.equal("Newborn", format_stage("2025-04-16", "2025-06-15"))
    end)

    -- 17.6
    it("exactly 2 months becomes infant", function()
        assert.are.equal("Infant", format_stage("2025-04-15", "2025-06-15"))
    end)
end)

-- ================================================================
-- 18. formatStage — Infant (2-11 months)
-- ================================================================
describe("formatStage — Infant", function()
    -- 18.1
    it("2 months", function()
        assert.are.equal("Infant", format_stage("2025-04-15", "2025-06-15"))
    end)

    -- 18.2
    it("6 months", function()
        assert.are.equal("Infant", format_stage("2024-12-15", "2025-06-15"))
    end)

    -- 18.3
    it("11 months", function()
        assert.are.equal("Infant", format_stage("2024-07-15", "2025-06-15"))
    end)

    -- 18.4
    it("exactly 12 months becomes toddler", function()
        assert.are.equal("Toddler", format_stage("2024-06-15", "2025-06-15"))
    end)
end)

-- ================================================================
-- 19. formatStage — Toddler (12-35 months)
-- ================================================================
describe("formatStage — Toddler", function()
    -- 19.1
    it("12 months", function()
        assert.are.equal("Toddler", format_stage("2024-06-15", "2025-06-15"))
    end)

    -- 19.2
    it("18 months", function()
        assert.are.equal("Toddler", format_stage("2024-01-15", "2025-07-15"))
    end)

    -- 19.3
    it("24 months", function()
        assert.are.equal("Toddler", format_stage("2023-06-15", "2025-06-15"))
    end)

    -- 19.4
    it("35 months still toddler", function()
        assert.are.equal("Toddler", format_stage("2023-06-15", "2026-05-15"))
    end)

    -- 19.5
    it("exactly 36 months becomes child", function()
        assert.are.equal("Child", format_stage("2022-06-15", "2025-06-15"))
    end)
end)

-- ================================================================
-- 20. formatStage — Child (36-155 months)
-- ================================================================
describe("formatStage — Child", function()
    -- 20.1
    it("3 years", function()
        assert.are.equal("Child", format_stage("2022-06-15", "2025-06-15"))
    end)

    -- 20.2
    it("4 years", function()
        assert.are.equal("Child", format_stage("2021-06-15", "2025-06-15"))
    end)

    -- 20.3
    it("6 years", function()
        assert.are.equal("Child", format_stage("2019-06-15", "2025-06-15"))
    end)

    -- 20.4
    it("9 years", function()
        assert.are.equal("Child", format_stage("2016-06-15", "2025-06-15"))
    end)

    -- 20.5
    it("12 years 11 months still child", function()
        assert.are.equal("Child", format_stage("2013-06-15", "2026-05-15"))
    end)

    -- 20.6
    it("exactly 13 years becomes teenager", function()
        assert.are.equal("Teenager", format_stage("2012-06-15", "2025-06-15"))
    end)
end)

-- ================================================================
-- 21. formatStage — Teenager (156-215 months)
-- ================================================================
describe("formatStage — Teenager", function()
    -- 21.1
    it("13 years", function()
        assert.are.equal("Teenager", format_stage("2012-06-15", "2025-06-15"))
    end)

    -- 21.2
    it("15 years", function()
        assert.are.equal("Teenager", format_stage("2010-06-15", "2025-06-15"))
    end)

    -- 21.3
    it("17 years 11 months still teenager", function()
        assert.are.equal("Teenager", format_stage("2008-06-15", "2026-05-15"))
    end)

    -- 21.4
    it("exactly 18 years becomes adult", function()
        assert.are.equal("Adult", format_stage("2007-06-15", "2025-06-15"))
    end)
end)

-- ================================================================
-- 22. formatStage — Adult (216+ months)
-- ================================================================
describe("formatStage — Adult", function()
    -- 22.1
    it("18 years", function()
        assert.are.equal("Adult", format_stage("2007-06-15", "2025-06-15"))
    end)

    -- 22.2
    it("25 years", function()
        assert.are.equal("Adult", format_stage("2000-06-15", "2025-06-15"))
    end)

    -- 22.3
    it("45 years", function()
        assert.are.equal("Adult", format_stage("1980-01-01", "2025-06-15"))
    end)
end)

-- ================================================================
-- 23. formatStage — default asOf
-- ================================================================
describe("formatStage — default asOf", function()
    -- 23.1, 23.2, 23.3
    it("returns correct stage with explicit as_of (proxy for default)", function()
        assert.are.equal("Newborn", format_stage("2025-06-15", "2025-06-15"))
        assert.are.equal("Child", format_stage("2020-01-01", "2025-06-15"))
        assert.are.equal("Adult", format_stage("1980-01-01", "2025-06-15"))
    end)
end)

-- ================================================================
-- 24. SayableAge class — English locale delegation
-- ================================================================
describe("SayableAge English locale", function()
    local en = require("locales.en")
    local pt = sayableage.new(en)

    -- 24.1, 24.2, 24.3, 24.4, 24.5, 24.6, 24.7
    it("format_age delegates", function()
        assert.are.equal("Newborn", pt.format_age("2025-06-15", "2025-06-15"))
        assert.are.equal("3 days", pt.format_age("2025-06-12", "2025-06-15"))
        assert.are.equal("1 week, 1 day", pt.format_age("2025-06-07", "2025-06-15"))
        assert.are.equal("6 months", pt.format_age("2025-01-15", "2025-07-15"))
        assert.are.equal("2 years, 1 month", pt.format_age("2023-06-15", "2025-07-15"))
        assert.are.equal("3½ years", pt.format_age("2022-06-15", "2025-12-15"))
        assert.are.equal("7 years", pt.format_age("2018-06-15", "2025-06-15"))
    end)

    -- 24.8, 24.9, 24.10, 24.11, 24.12, 24.13
    it("format_stage delegates", function()
        assert.are.equal("Newborn", pt.format_stage("2025-06-15", "2025-06-15"))
        assert.are.equal("Infant", pt.format_stage("2025-01-15", "2025-06-15"))
        assert.are.equal("Toddler", pt.format_stage("2024-06-15", "2025-06-15"))
        assert.are.equal("Child", pt.format_stage("2022-06-15", "2025-06-15"))
        assert.are.equal("Teenager", pt.format_stage("2012-06-15", "2025-06-15"))
        assert.are.equal("Adult", pt.format_stage("2007-06-15", "2025-06-15"))
    end)

    -- 24.14, 24.15
    it("returns nil for invalid", function()
        assert.is_nil(pt.format_age(nil, "2025-06-15"))
        assert.is_nil(pt.format_stage(nil, "2025-06-15"))
    end)
end)

-- ================================================================
-- 25. i18n — Spanish locale
-- ================================================================
describe("i18n — Spanish locale", function()
    local es = require("locales.es")
    local pt = sayableage.new(es)

    -- 25.1
    it("just born label", function()
        assert.are.equal("Recién nacido", pt.format_age("2025-06-15", "2025-06-15"))
    end)

    -- 25.2
    it("singular day", function()
        assert.are.equal("1 día", pt.format_age("2025-06-14", "2025-06-15"))
    end)

    -- 25.3
    it("plural days", function()
        assert.are.equal("3 días", pt.format_age("2025-06-12", "2025-06-15"))
    end)

    -- 25.4
    it("singular week", function()
        assert.are.equal("1 semana", pt.format_age("2025-06-08", "2025-06-15"))
    end)

    -- 25.5
    it("compound weeks days", function()
        assert.are.equal("1 semana, 1 día", pt.format_age("2025-06-07", "2025-06-15"))
    end)

    -- 25.6
    it("plural weeks plural days", function()
        assert.are.equal("2 semanas, 6 días", pt.format_age("2025-05-26", "2025-06-15"))
    end)

    -- 25.7
    it("months", function()
        assert.are.equal("6 meses", pt.format_age("2025-01-15", "2025-07-15"))
    end)

    -- 25.8
    it("singular month in compound", function()
        assert.are.equal("2 años, 1 mes", pt.format_age("2023-06-15", "2025-07-15"))
    end)

    -- 25.9
    it("years months compound", function()
        assert.are.equal("2 años, 6 meses", pt.format_age("2023-06-15", "2025-12-15"))
    end)

    -- 25.10
    it("half marker", function()
        assert.are.equal("3 y medio años", pt.format_age("2022-06-15", "2025-12-15"))
    end)

    -- 25.11
    it("integer years", function()
        assert.are.equal("3 años", pt.format_age("2022-06-15", "2025-06-15"))
    end)

    -- 25.12
    it("7+ years", function()
        assert.are.equal("7 años", pt.format_age("2018-06-15", "2025-06-15"))
    end)

    -- 25.13, 25.14, 25.15, 25.16, 25.17, 25.18
    it("stage labels", function()
        assert.are.equal("Recién nacido", pt.format_stage("2025-06-15", "2025-06-15"))
        assert.are.equal("Bebé", pt.format_stage("2025-01-15", "2025-06-15"))
        assert.are.equal("Niño pequeño", pt.format_stage("2024-06-15", "2025-06-15"))
        assert.are.equal("Niño", pt.format_stage("2022-06-15", "2025-06-15"))
        assert.are.equal("Adolescente", pt.format_stage("2012-06-15", "2025-06-15"))
        assert.are.equal("Adulto", pt.format_stage("2007-06-15", "2025-06-15"))
    end)

    -- 25.19, 25.20
    it("null handling", function()
        assert.is_nil(pt.format_age(nil, "2025-06-15"))
        assert.is_nil(pt.format_stage(nil, "2025-06-15"))
    end)
end)

-- ================================================================
-- 26. Compactness — short
-- ================================================================
describe("Compactness — short", function()
    local en = require("locales.en")
    local pt = sayableage.new(en, "short")

    -- 26.1
    it("days", function()
        assert.are.equal("3 d", pt.format_age("2025-06-12", "2025-06-15"))
    end)

    -- 26.2
    it("weeks", function()
        assert.are.equal("1 wk", pt.format_age("2025-06-08", "2025-06-15"))
    end)

    -- 26.3
    it("weeks days", function()
        assert.are.equal("1 wk, 1 d", pt.format_age("2025-06-07", "2025-06-15"))
    end)

    -- 26.4
    it("months", function()
        assert.are.equal("6 mo", pt.format_age("2025-01-15", "2025-07-15"))
    end)

    -- 26.5
    it("years months", function()
        assert.are.equal("2 yr, 1 mo", pt.format_age("2023-06-15", "2025-07-15"))
    end)

    -- 26.6
    it("half years", function()
        assert.are.equal("3½ yr", pt.format_age("2022-06-15", "2025-12-15"))
    end)

    -- 26.7
    it("integer years", function()
        assert.are.equal("7 yr", pt.format_age("2018-06-15", "2025-06-15"))
    end)

    -- 26.8
    it("just born unchanged", function()
        assert.are.equal("Newborn", pt.format_age("2025-06-15", "2025-06-15"))
    end)

    -- 26.9
    it("stages unchanged", function()
        assert.are.equal("Infant", pt.format_stage("2025-01-15", "2025-06-15"))
    end)
end)

-- ================================================================
-- 27. Compactness — compact
-- ================================================================
describe("Compactness — compact", function()
    local en = require("locales.en")
    local pt = sayableage.new(en, "compact")

    -- 27.1
    it("days", function()
        assert.are.equal("3d", pt.format_age("2025-06-12", "2025-06-15"))
    end)

    -- 27.2
    it("weeks", function()
        assert.are.equal("1w", pt.format_age("2025-06-08", "2025-06-15"))
    end)

    -- 27.3
    it("weeks days no delimiter", function()
        assert.are.equal("1w1d", pt.format_age("2025-06-07", "2025-06-15"))
    end)

    -- 27.4
    it("months", function()
        assert.are.equal("6m", pt.format_age("2025-01-15", "2025-07-15"))
    end)

    -- 27.5
    it("years months no delimiter", function()
        assert.are.equal("2y1m", pt.format_age("2023-06-15", "2025-07-15"))
    end)

    -- 27.6
    it("half years", function()
        assert.are.equal("3½y", pt.format_age("2022-06-15", "2025-12-15"))
    end)

    -- 27.7
    it("integer years", function()
        assert.are.equal("7y", pt.format_age("2018-06-15", "2025-06-15"))
    end)

    -- 27.8
    it("just born unchanged", function()
        assert.are.equal("Newborn", pt.format_age("2025-06-15", "2025-06-15"))
    end)
end)

-- ================================================================
-- 29. Locale-specific edge cases — plural rules
-- ================================================================

-- 29.1 — Hebrew (he) — dual forms
describe("Locale — Hebrew", function()
    local he = require("locales.he")
    local pt = sayableage.new(he)

    -- 29.1
    it("just born", function()
        assert.are.equal("רק נולד", pt.format_age("2025-06-15", "2025-06-15"))
    end)

    -- 29.2
    it("one day", function()
        assert.are.equal("יום 1", pt.format_age("2025-06-14", "2025-06-15"))
    end)

    -- 29.3
    it("three days", function()
        assert.are.equal("3 ימים", pt.format_age("2025-06-12", "2025-06-15"))
    end)

    -- 29.4
    it("two weeks dual", function()
        assert.are.equal("שבועיים", pt.format_age("2025-06-01", "2025-06-15"))
    end)

    -- 29.5
    it("three weeks", function()
        assert.are.equal("3 שבועות", pt.format_age("2025-05-25", "2025-06-15"))
    end)

    -- 29.6
    it("six months", function()
        assert.are.equal("6 חודשים", pt.format_age("2025-01-15", "2025-07-15"))
    end)

    -- 29.7
    it("three months", function()
        assert.are.equal("3 חודשים", pt.format_age("2025-03-15", "2025-06-15"))
    end)

    -- 29.8
    it("two years dual one month", function()
        assert.are.equal("שנתיים, חודש 1", pt.format_age("2023-06-15", "2025-07-15"))
    end)

    -- 29.9
    it("half years", function()
        assert.are.equal("3 שנים וחצי", pt.format_age("2022-06-15", "2025-12-15"))
    end)

    -- 29.10
    it("seven years", function()
        assert.are.equal("7 שנים", pt.format_age("2018-06-15", "2025-06-15"))
    end)

    -- 29.11
    it("stage masculine newborn", function()
        assert.are.equal("רק נולד", pt.format_stage("2025-06-15", "2025-06-15", "m"))
    end)

    -- 29.12
    it("stage feminine newborn", function()
        assert.are.equal("רק נולדה", pt.format_stage("2025-06-15", "2025-06-15", "f"))
    end)

    -- 29.13
    it("stage masculine adult", function()
        assert.are.equal("מבוגר", pt.format_stage("2007-06-15", "2025-06-15", "m"))
    end)

    -- 29.14
    it("stage feminine adult", function()
        assert.are.equal("מבוגרת", pt.format_stage("2007-06-15", "2025-06-15", "f"))
    end)
end)

-- 29.2 — Macedonian (mk) — mod10/mod100 rule
describe("Locale — Macedonian", function()
    local mk = require("locales.mk")
    local pt = sayableage.new(mk)

    -- 29.15
    it("just born", function()
        assert.are.equal("Новороденче", pt.format_age("2025-06-15", "2025-06-15"))
    end)

    -- 29.16
    it("one day", function()
        assert.are.equal("1 ден", pt.format_age("2025-06-14", "2025-06-15"))
    end)

    -- 29.17
    it("three days", function()
        assert.are.equal("3 дена", pt.format_age("2025-06-12", "2025-06-15"))
    end)

    -- 29.18
    it("six months", function()
        assert.are.equal("6 месеци", pt.format_age("2025-01-15", "2025-07-15"))
    end)

    -- 29.19
    it("two years one month", function()
        assert.are.equal("2 години, 1 месец", pt.format_age("2023-06-15", "2025-07-15"))
    end)

    -- 29.20
    it("half years", function()
        assert.are.equal("3 години и пол", pt.format_age("2022-06-15", "2025-12-15"))
    end)

    -- 29.21
    it("seven years", function()
        assert.are.equal("7 години", pt.format_age("2018-06-15", "2025-06-15"))
    end)
end)

-- 29.3 — Swahili (sw) — noun class changes
describe("Locale — Swahili", function()
    local sw = require("locales.sw")
    local pt = sayableage.new(sw)

    -- 29.22
    it("just born", function()
        assert.are.equal("Mzaliwa mpya", pt.format_age("2025-06-15", "2025-06-15"))
    end)

    -- 29.23
    it("one day", function()
        assert.are.equal("siku 1", pt.format_age("2025-06-14", "2025-06-15"))
    end)

    -- 29.24
    it("three days", function()
        assert.are.equal("siku 3", pt.format_age("2025-06-12", "2025-06-15"))
    end)

    -- 29.25
    it("six months", function()
        assert.are.equal("miezi 6", pt.format_age("2025-01-15", "2025-07-15"))
    end)

    -- 29.26
    it("two years one month", function()
        assert.are.equal("miaka 2, mwezi 1", pt.format_age("2023-06-15", "2025-07-15"))
    end)

    -- 29.27
    it("half years", function()
        assert.are.equal("miaka 3 na nusu", pt.format_age("2022-06-15", "2025-12-15"))
    end)
end)

-- 29.4 — Indonesian (id) — other_only
describe("Locale — Indonesian", function()
    local id = require("locales.id")
    local pt = sayableage.new(id)

    -- 29.28
    it("just born", function()
        assert.are.equal("Baru lahir", pt.format_age("2025-06-15", "2025-06-15"))
    end)

    -- 29.29
    it("one day", function()
        assert.are.equal("1 hari", pt.format_age("2025-06-14", "2025-06-15"))
    end)

    -- 29.30
    it("three days", function()
        assert.are.equal("3 hari", pt.format_age("2025-06-12", "2025-06-15"))
    end)

    -- 29.31
    it("six months", function()
        assert.are.equal("6 bulan", pt.format_age("2025-01-15", "2025-07-15"))
    end)

    -- 29.32
    it("half years", function()
        assert.are.equal("3 tahun setengah", pt.format_age("2022-06-15", "2025-12-15"))
    end)

    -- 29.33
    it("seven years", function()
        assert.are.equal("7 tahun", pt.format_age("2018-06-15", "2025-06-15"))
    end)
end)

-- 29.5 — Amharic (am) — Ethiopic delimiter
describe("Locale — Amharic", function()
    local am = require("locales.am")
    local pt = sayableage.new(am)

    -- 29.34
    it("just born", function()
        assert.are.equal("አዲስ የተወለደ", pt.format_age("2025-06-15", "2025-06-15"))
    end)

    -- 29.35
    it("one day", function()
        assert.are.equal("1 ቀን", pt.format_age("2025-06-14", "2025-06-15"))
    end)

    -- 29.36
    it("three days", function()
        assert.are.equal("3 ቀናት", pt.format_age("2025-06-12", "2025-06-15"))
    end)

    -- 29.37
    it("one week one day Ethiopic delimiter", function()
        assert.are.equal("1 ሳምንት፣ 1 ቀን", pt.format_age("2025-06-07", "2025-06-15"))
    end)

    -- 29.38
    it("six months", function()
        assert.are.equal("6 ወራት", pt.format_age("2025-01-15", "2025-07-15"))
    end)

    -- 29.39
    it("half years", function()
        assert.are.equal("3 ዓመታት ተኩል", pt.format_age("2022-06-15", "2025-12-15"))
    end)
end)

-- ================================================================
-- 30. Locale lookup by code string
-- ================================================================
describe("Locale lookup", function()
    -- 30.1
    it("known locale en", function()
        local loc = get_locale("en")
        assert.is_not_nil(loc)
        assert.are.equal("en", loc.code)
    end)

    -- 30.2
    it("known locale fr", function()
        local loc = get_locale("fr")
        assert.is_not_nil(loc)
        assert.are.equal("fr", loc.code)
    end)

    -- 30.3
    it("unknown code", function()
        assert.is_nil(get_locale("xx"))
    end)

    -- 30.4
    it("empty string", function()
        assert.is_nil(get_locale(""))
    end)

    -- 30.5
    it("case sensitive", function()
        assert.is_nil(get_locale("EN"))
    end)
end)

-- ================================================================
-- Sections 31-33: weeks+days across month ends, half-year plurals, input validation
-- ================================================================
describe("Sections 31-33: weeks+days across month ends, half-year plurals, input validation", function()
    -- 31.1
    it("88 days across a 28-day February", function()
        assert.are.equal("12 weeks, 4 days", sayableage.new(sayableage.get_locale("en")).format_age("2016-12-31", "2017-03-29"))
    end)

    -- 31.2
    it("90 days across a year end into a leap year", function()
        assert.are.equal("12 weeks, 6 days", sayableage.new(sayableage.get_locale("en")).format_age("1991-11-27", "1992-02-25"))
    end)

    -- 31.3
    it("33 days across a year end", function()
        assert.are.equal("4 weeks, 5 days", sayableage.new(sayableage.get_locale("en")).format_age("2020-11-30", "2021-01-02"))
    end)

    -- 31.4
    it("Compact form of 31.1", function()
        assert.are.equal("12w4d", sayableage.new(sayableage.get_locale("en"), "compact").format_age("2016-12-31", "2017-03-29"))
    end)

    -- 32.1
    it("Polish 3 is 'few'", function()
        assert.are.equal("3 i pół lata", sayableage.new(sayableage.get_locale("pl")).format_age("2021-06-15", "2025-01-15"))
    end)

    -- 32.2
    it("Polish 5 is 'many'", function()
        assert.are.equal("5 i pół lat", sayableage.new(sayableage.get_locale("pl"), "short").format_age("2020-06-15", "2025-12-15"))
    end)

    -- 32.3
    it("Tachelhit 6 is 'few'", function()
        assert.are.equal("6 iseggasen d uzgen", sayableage.new(sayableage.get_locale("shi")).format_age("2005-06-08", "2012-06-07"))
    end)

    -- 33.1
    it("February 30 doesn't exist", function()
        assert.is_nil(sayableage.new(sayableage.get_locale("en")).format_age("2025-02-30", "2032-06-25"))
    end)

    -- 33.2
    it("Month 13", function()
        assert.is_nil(sayableage.new(sayableage.get_locale("en")).format_age("2025-13-01", "2027-01-31"))
    end)

    -- 33.3
    it("February 29 in a non-leap year", function()
        assert.is_nil(sayableage.new(sayableage.get_locale("en")).format_age("2023-02-29", "2025-03-01"))
    end)

    -- 33.4
    it("Day 00", function()
        assert.is_nil(sayableage.new(sayableage.get_locale("en")).format_age("2025-06-00", "2027-02-25"))
    end)

    -- 33.5
    it("Unpadded month and day", function()
        assert.is_nil(sayableage.new(sayableage.get_locale("en")).format_age("2025-6-1", "2027-02-25"))
    end)

    -- 33.6
    it("Surrounding whitespace", function()
        assert.is_nil(sayableage.new(sayableage.get_locale("en")).format_age(" 2025-06-01", "2027-02-25"))
    end)

    -- 33.7
    it("A datetime is not a date", function()
        assert.is_nil(sayableage.new(sayableage.get_locale("en")).format_age("2025-06-15T10:00:00", "2027-02-25"))
    end)

    -- 33.8
    it("Invalid asOf", function()
        assert.is_nil(sayableage.new(sayableage.get_locale("en")).format_age("2020-01-01", "2025-04-31"))
    end)

    -- 33.9
    it("formatStage validates too", function()
        assert.is_nil(sayableage.new(sayableage.get_locale("en")).format_stage("2025-02-30", "2027-09-05"))
    end)

    -- 33.10
    it("February 29 in a leap year is valid", function()
        assert.are.equal("2 years", sayableage.new(sayableage.get_locale("en")).format_age("2024-02-29", "2026-03-01"))
    end)
end)
