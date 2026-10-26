// Tests for sayableage — mirrors the canonical test specification.
// All test IDs reference config/tests.json.

import "./sayableage" for SayableAge
import "./locales/en" for ENLocale
import "./locales/es" for ESLocale
import "./locales/he" for HELocale
import "./locales/mk" for MKLocale
import "./locales/sw" for SWLocale
import "./locales/id" for IDLocale
import "./locales/am" for AMLocale
import "./locales/pl" for PLLocale
import "./locales/shi" for SHILocale

class Test {
  construct new() {
    _pass = 0
    _fail = 0
    _section = ""
  }

  section(name) { _section = name }

  assert(id, actual, expected) {
    if (actual == expected) {
      _pass = _pass + 1
    } else {
      _fail = _fail + 1
      System.print("FAIL %(_section) [%(id)]: expected %(expected == null ? "null" : "\"%(expected)\""), got %(actual == null ? "null" : "\"%(actual)\"")")
    }
  }

  assertNull(id, actual) {
    if (actual == null) {
      _pass = _pass + 1
    } else {
      _fail = _fail + 1
      System.print("FAIL %(_section) [%(id)]: expected null, got \"%(actual)\"")
    }
  }

  assertNotNull(id, actual) {
    if (actual != null) {
      _pass = _pass + 1
    } else {
      _fail = _fail + 1
      System.print("FAIL %(_section) [%(id)]: expected non-null, got null")
    }
  }

  assertContains(id, actual, substring) {
    if (actual != null && actual.contains(substring)) {
      _pass = _pass + 1
    } else {
      _fail = _fail + 1
      System.print("FAIL %(_section) [%(id)]: expected string containing \"%(substring)\", got %(actual == null ? "null" : "\"%(actual)\"")")
    }
  }

  summary() {
    var total = _pass + _fail
    System.print("")
    System.print("%(total) tests: %(_pass) passed, %(_fail) failed")
    if (_fail > 0) {
      Fiber.abort("%(total) tests: %(_pass) passed, %(_fail) failed")
    }
  }
}

var t = Test.new()
var fmt = SayableAge.new(ENLocale)

// ================================================================
// 1. Null / edge cases
// ================================================================
t.section("1. Null / edge cases")

// 1.1
t.assertNull("1.1", fmt.formatAge(null, "2025-06-15"))

// 1.3
t.assertNull("1.3", fmt.formatAge("", "2025-06-15"))

// 1.4
t.assertNull("1.4", fmt.formatAge("2025-07-01", "2025-06-15"))

// 1.5
t.assert("1.5", fmt.formatAge("1525-06-15", "2025-06-15"), "500 years")

// 1.6
t.assertNull("1.6", fmt.formatAge("1524-06-15", "2025-06-15"))

// 1.7
t.assertNull("1.7", fmt.formatAge("1025-06-15", "2025-06-15"))

// ================================================================
// 2. Days tier (0-6 days)
// ================================================================
t.section("2. Days tier")

// 2.1
t.assert("2.1", fmt.formatAge("2025-06-15", "2025-06-15"), "Newborn")

// 2.2
t.assert("2.2", fmt.formatAge("2025-06-14", "2025-06-15"), "1 day")

// 2.3
t.assert("2.3", fmt.formatAge("2025-06-12", "2025-06-15"), "3 days")

// 2.4
t.assert("2.4", fmt.formatAge("2025-06-09", "2025-06-15"), "6 days")

// 2.5
t.assert("2.5", fmt.formatAge("2025-06-08", "2025-06-15"), "1 week")

// ================================================================
// 3. Weeks+days tier (7 days to <3 calendar months)
// ================================================================
t.section("3. Weeks+days tier")

// 3.1
t.assert("3.1", fmt.formatAge("2025-06-08", "2025-06-15"), "1 week")

// 3.2
t.assert("3.2", fmt.formatAge("2025-06-07", "2025-06-15"), "1 week, 1 day")

// 3.3
t.assert("3.3", fmt.formatAge("2025-06-06", "2025-06-15"), "1 week, 2 days")

// 3.4
t.assert("3.4", fmt.formatAge("2025-06-02", "2025-06-15"), "1 week, 6 days")

// 3.5
t.assert("3.5", fmt.formatAge("2025-06-01", "2025-06-15"), "2 weeks")

// 3.6
t.assert("3.6", fmt.formatAge("2025-05-31", "2025-06-15"), "2 weeks, 1 day")

// 3.7
t.assert("3.7", fmt.formatAge("2025-05-26", "2025-06-15"), "2 weeks, 6 days")

// 3.8
t.assert("3.8", fmt.formatAge("2025-05-25", "2025-06-15"), "3 weeks")

// 3.9
t.assert("3.9", fmt.formatAge("2025-05-15", "2025-06-15"), "4 weeks, 3 days")

// 3.10
t.assert("3.10", fmt.formatAge("2025-04-15", "2025-06-15"), "8 weeks, 5 days")

// 3.11
t.assert("3.11", fmt.formatAge("2025-03-15", "2025-06-14"), "13 weeks")

// 3.12
t.assert("3.12", fmt.formatAge("2025-03-15", "2025-06-15"), "3 months")

// ================================================================
// 4. Month boundaries — standard months
// ================================================================
t.section("4. Month boundaries — standard")

// 4.1
t.assert("4.1", fmt.formatAge("2025-01-01", "2025-04-01"), "3 months")

// 4.2
t.assertContains("4.2", fmt.formatAge("2025-01-01", "2025-03-31"), "week")

// 4.3
t.assert("4.3", fmt.formatAge("2025-06-15", "2025-09-15"), "3 months")

// 4.4
t.assertContains("4.4", fmt.formatAge("2025-06-15", "2025-09-14"), "week")

// 4.5
t.assert("4.5", fmt.formatAge("2025-06-15", "2025-12-15"), "6 months")

// ================================================================
// 5. Month boundaries — February non-leap year
// ================================================================
t.section("5. February non-leap year")

// 5.1
t.assert("5.1", fmt.formatAge("2025-01-31", "2025-02-28"), "4 weeks")

// 5.2
t.assert("5.2", fmt.formatAge("2025-01-31", "2025-04-30"), "3 months")

// 5.3
t.assertContains("5.3", fmt.formatAge("2025-01-31", "2025-04-29"), "week")

// 5.4
t.assert("5.4", fmt.formatAge("2025-02-01", "2025-05-01"), "3 months")

// 5.5
t.assertContains("5.5", fmt.formatAge("2025-02-01", "2025-04-30"), "week")

// ================================================================
// 6. Month boundaries — February leap year
// ================================================================
t.section("6. February leap year")

// 6.1
t.assert("6.1", fmt.formatAge("2024-01-31", "2024-02-29"), "4 weeks, 1 day")

// 6.2
t.assert("6.2", fmt.formatAge("2024-01-31", "2024-02-28"), "4 weeks")

// 6.3
t.assert("6.3", fmt.formatAge("2024-01-31", "2024-04-30"), "3 months")

// 6.4
t.assertContains("6.4", fmt.formatAge("2024-01-30", "2024-02-29"), "week")

// 6.5
t.assertContains("6.5", fmt.formatAge("2024-01-30", "2024-02-28"), "week")

// ================================================================
// 7. Month boundaries — 30-day months
// ================================================================
t.section("7. 30-day months")

// 7.1
t.assert("7.1", fmt.formatAge("2025-03-31", "2025-06-30"), "3 months")

// 7.2
t.assertContains("7.2", fmt.formatAge("2025-03-31", "2025-06-29"), "week")

// 7.3
t.assert("7.3", fmt.formatAge("2025-08-31", "2025-11-30"), "3 months")

// 7.4
t.assertContains("7.4", fmt.formatAge("2025-08-31", "2025-11-29"), "week")

// ================================================================
// 8. Leap year baby (born Feb 29)
// ================================================================
t.section("8. Leap year baby")

// 8.1
t.assert("8.1", fmt.formatAge("2024-02-29", "2024-05-29"), "3 months")

// 8.2
t.assertContains("8.2", fmt.formatAge("2024-02-29", "2024-05-28"), "week")

// 8.3
t.assert("8.3", fmt.formatAge("2024-02-29", "2025-02-28"), "12 months")

// 8.4
t.assert("8.4", fmt.formatAge("2024-02-29", "2025-03-01"), "12 months")

// ================================================================
// 9. Months tier (3-23 months)
// ================================================================
t.section("9. Months tier")

// 9.1
t.assert("9.1", fmt.formatAge("2025-01-15", "2025-04-15"), "3 months")

// 9.2
t.assert("9.2", fmt.formatAge("2025-01-15", "2025-07-15"), "6 months")

// 9.3
t.assert("9.3", fmt.formatAge("2024-06-15", "2025-06-15"), "12 months")

// 9.4
t.assert("9.4", fmt.formatAge("2024-01-15", "2025-12-15"), "23 months")

// 9.5
t.assert("9.5", fmt.formatAge("2025-01-15", "2025-07-14"), "5 months")

// 9.6
t.assert("9.6", fmt.formatAge("2024-11-10", "2025-04-10"), "5 months")

// ================================================================
// 10. Years+months tier (24-35 months)
// ================================================================
t.section("10. Years+months tier")

// 10.1
t.assert("10.1", fmt.formatAge("2023-06-15", "2025-06-15"), "2 years")

// 10.2
t.assert("10.2", fmt.formatAge("2023-06-15", "2025-07-15"), "2 years, 1 month")

// 10.3
t.assert("10.3", fmt.formatAge("2023-06-15", "2025-12-15"), "2 years, 6 months")

// 10.4
t.assert("10.4", fmt.formatAge("2023-06-15", "2026-05-15"), "2 years, 11 months")

// 10.5
t.assert("10.5", fmt.formatAge("2023-06-15", "2025-06-14"), "23 months")

// ================================================================
// 11. Half-year tier (3-6 years)
// ================================================================
t.section("11. Half-year tier")

// 11.1
t.assert("11.1", fmt.formatAge("2022-06-15", "2025-06-15"), "3 years")

// 11.2
t.assert("11.2", fmt.formatAge("2022-06-15", "2025-11-15"), "3 years")

// 11.3
t.assert("11.3", fmt.formatAge("2022-06-15", "2025-12-15"), "3½ years")

// 11.4
t.assert("11.4", fmt.formatAge("2022-06-15", "2026-05-15"), "3½ years")

// 11.5
t.assert("11.5", fmt.formatAge("2021-06-15", "2025-06-15"), "4 years")

// 11.6
t.assert("11.6", fmt.formatAge("2021-06-15", "2025-12-15"), "4½ years")

// 11.7
t.assert("11.7", fmt.formatAge("2020-06-15", "2025-06-15"), "5 years")

// 11.8
t.assert("11.8", fmt.formatAge("2020-06-15", "2026-02-15"), "5½ years")

// 11.9
t.assert("11.9", fmt.formatAge("2019-06-15", "2025-06-15"), "6 years")

// 11.10
t.assert("11.10", fmt.formatAge("2019-06-15", "2025-12-15"), "6½ years")

// 11.11
t.assert("11.11", fmt.formatAge("2019-06-15", "2026-05-15"), "6½ years")

// 11.12
t.assert("11.12", fmt.formatAge("2022-06-15", "2025-06-14"), "2 years, 11 months")

// ================================================================
// 12. Integer tier (7+ years)
// ================================================================
t.section("12. Integer tier")

// 12.1
t.assert("12.1", fmt.formatAge("2018-06-15", "2025-06-15"), "7 years")

// 12.2
t.assert("12.2", fmt.formatAge("2018-03-20", "2025-06-15"), "7 years")

// 12.3
t.assert("12.3", fmt.formatAge("1980-01-01", "2025-06-15"), "45 years")

// ================================================================
// 13. Cross-year transitions with February
// ================================================================
t.section("13. Cross-year transitions")

// 13.1
t.assert("13.1", fmt.formatAge("2024-12-31", "2025-03-31"), "3 months")

// 13.2
t.assertContains("13.2", fmt.formatAge("2024-12-31", "2025-03-30"), "week")

// 13.3
t.assert("13.3", fmt.formatAge("2024-11-30", "2025-02-28"), "3 months")

// 13.4
t.assertContains("13.4", fmt.formatAge("2024-11-30", "2025-02-27"), "week")

// ================================================================
// 14. Born-on-31st progression
// ================================================================
t.section("14. Born-on-31st progression")

// 14.1
t.assert("14.1", fmt.formatAge("2025-01-31", "2025-04-30"), "3 months")

// 14.2
t.assert("14.2", fmt.formatAge("2025-01-31", "2025-05-31"), "4 months")

// 14.3
t.assert("14.3", fmt.formatAge("2025-01-31", "2025-06-30"), "5 months")

// 14.4
t.assert("14.4", fmt.formatAge("2025-01-31", "2025-07-01"), "5 months")

// 14.5
t.assert("14.5", fmt.formatAge("2025-01-31", "2025-07-31"), "6 months")

// ================================================================
// Sections 15 and 23 skipped (require system date mocking)
// ================================================================

// ================================================================
// 16. formatStage — null / edge cases
// ================================================================
t.section("16. formatStage null/edge cases")

// 16.1
t.assertNull("16.1", fmt.formatStage(null, "2025-06-15"))

// 16.3
t.assertNull("16.3", fmt.formatStage("", "2025-06-15"))

// 16.4
t.assertNull("16.4", fmt.formatStage("2025-07-01", "2025-06-15"))

// 16.5
t.assert("16.5", fmt.formatStage("1525-06-15", "2025-06-15"), "Adult")

// 16.6
t.assertNull("16.6", fmt.formatStage("1524-06-15", "2025-06-15"))

// ================================================================
// 17. formatStage — Newborn
// ================================================================
t.section("17. Newborn stage")

// 17.1
t.assert("17.1", fmt.formatStage("2025-06-15", "2025-06-15"), "Newborn")

// 17.2
t.assert("17.2", fmt.formatStage("2025-06-14", "2025-06-15"), "Newborn")

// 17.3
t.assert("17.3", fmt.formatStage("2025-05-25", "2025-06-15"), "Newborn")

// 17.4
t.assert("17.4", fmt.formatStage("2025-05-15", "2025-06-15"), "Newborn")

// 17.5
t.assert("17.5", fmt.formatStage("2025-04-16", "2025-06-15"), "Newborn")

// 17.6
t.assert("17.6", fmt.formatStage("2025-04-15", "2025-06-15"), "Infant")

// ================================================================
// 18. formatStage — Infant
// ================================================================
t.section("18. Infant stage")

// 18.1
t.assert("18.1", fmt.formatStage("2025-04-15", "2025-06-15"), "Infant")

// 18.2
t.assert("18.2", fmt.formatStage("2024-12-15", "2025-06-15"), "Infant")

// 18.3
t.assert("18.3", fmt.formatStage("2024-07-15", "2025-06-15"), "Infant")

// 18.4
t.assert("18.4", fmt.formatStage("2024-06-15", "2025-06-15"), "Toddler")

// ================================================================
// 19. formatStage — Toddler
// ================================================================
t.section("19. Toddler stage")

// 19.1
t.assert("19.1", fmt.formatStage("2024-06-15", "2025-06-15"), "Toddler")

// 19.2
t.assert("19.2", fmt.formatStage("2024-01-15", "2025-07-15"), "Toddler")

// 19.3
t.assert("19.3", fmt.formatStage("2023-06-15", "2025-06-15"), "Toddler")

// 19.4
t.assert("19.4", fmt.formatStage("2023-06-15", "2026-05-15"), "Toddler")

// 19.5
t.assert("19.5", fmt.formatStage("2022-06-15", "2025-06-15"), "Child")

// ================================================================
// 20. formatStage — Child
// ================================================================
t.section("20. Child stage")

// 20.1
t.assert("20.1", fmt.formatStage("2022-06-15", "2025-06-15"), "Child")

// 20.2
t.assert("20.2", fmt.formatStage("2021-06-15", "2025-06-15"), "Child")

// 20.3
t.assert("20.3", fmt.formatStage("2019-06-15", "2025-06-15"), "Child")

// 20.4
t.assert("20.4", fmt.formatStage("2016-06-15", "2025-06-15"), "Child")

// 20.5
t.assert("20.5", fmt.formatStage("2013-06-15", "2026-05-15"), "Child")

// 20.6
t.assert("20.6", fmt.formatStage("2012-06-15", "2025-06-15"), "Teenager")

// ================================================================
// 21. formatStage — Teenager
// ================================================================
t.section("21. Teenager stage")

// 21.1
t.assert("21.1", fmt.formatStage("2012-06-15", "2025-06-15"), "Teenager")

// 21.2
t.assert("21.2", fmt.formatStage("2010-06-15", "2025-06-15"), "Teenager")

// 21.3
t.assert("21.3", fmt.formatStage("2008-06-15", "2026-05-15"), "Teenager")

// 21.4
t.assert("21.4", fmt.formatStage("2007-06-15", "2025-06-15"), "Adult")

// ================================================================
// 22. formatStage — Adult
// ================================================================
t.section("22. Adult stage")

// 22.1
t.assert("22.1", fmt.formatStage("2007-06-15", "2025-06-15"), "Adult")

// 22.2
t.assert("22.2", fmt.formatStage("2000-06-15", "2025-06-15"), "Adult")

// 22.3
t.assert("22.3", fmt.formatStage("1980-01-01", "2025-06-15"), "Adult")

// ================================================================
// 24. SayableAge class — English locale delegation
// ================================================================
t.section("24. Class delegation")

// 24.1
t.assert("24.1", fmt.formatAge("2025-06-15", "2025-06-15"), "Newborn")

// 24.2
t.assert("24.2", fmt.formatAge("2025-06-12", "2025-06-15"), "3 days")

// 24.3
t.assert("24.3", fmt.formatAge("2025-06-07", "2025-06-15"), "1 week, 1 day")

// 24.4
t.assert("24.4", fmt.formatAge("2025-01-15", "2025-07-15"), "6 months")

// 24.5
t.assert("24.5", fmt.formatAge("2023-06-15", "2025-07-15"), "2 years, 1 month")

// 24.6
t.assert("24.6", fmt.formatAge("2022-06-15", "2025-12-15"), "3½ years")

// 24.7
t.assert("24.7", fmt.formatAge("2018-06-15", "2025-06-15"), "7 years")

// 24.8
t.assert("24.8", fmt.formatStage("2025-06-15", "2025-06-15"), "Newborn")

// 24.9
t.assert("24.9", fmt.formatStage("2025-01-15", "2025-06-15"), "Infant")

// 24.10
t.assert("24.10", fmt.formatStage("2024-06-15", "2025-06-15"), "Toddler")

// 24.11
t.assert("24.11", fmt.formatStage("2022-06-15", "2025-06-15"), "Child")

// 24.12
t.assert("24.12", fmt.formatStage("2012-06-15", "2025-06-15"), "Teenager")

// 24.13
t.assert("24.13", fmt.formatStage("2007-06-15", "2025-06-15"), "Adult")

// 24.14
t.assertNull("24.14", fmt.formatAge(null, "2025-06-15"))

// 24.15
t.assertNull("24.15", fmt.formatStage(null, "2025-06-15"))

// ================================================================
// 25. i18n — Spanish locale
// ================================================================
t.section("25. i18n Spanish")
var esFmt = SayableAge.new(ESLocale)

// 25.1
t.assert("25.1", esFmt.formatAge("2025-06-15", "2025-06-15"), "Recién nacido")

// 25.2
t.assert("25.2", esFmt.formatAge("2025-06-14", "2025-06-15"), "1 día")

// 25.3
t.assert("25.3", esFmt.formatAge("2025-06-12", "2025-06-15"), "3 días")

// 25.4
t.assert("25.4", esFmt.formatAge("2025-06-08", "2025-06-15"), "1 semana")

// 25.5
t.assert("25.5", esFmt.formatAge("2025-06-07", "2025-06-15"), "1 semana, 1 día")

// 25.6
t.assert("25.6", esFmt.formatAge("2025-05-26", "2025-06-15"), "2 semanas, 6 días")

// 25.7
t.assert("25.7", esFmt.formatAge("2025-01-15", "2025-07-15"), "6 meses")

// 25.8
t.assert("25.8", esFmt.formatAge("2023-06-15", "2025-07-15"), "2 años, 1 mes")

// 25.9
t.assert("25.9", esFmt.formatAge("2023-06-15", "2025-12-15"), "2 años, 6 meses")

// 25.10
t.assert("25.10", esFmt.formatAge("2022-06-15", "2025-12-15"), "3 años y medio")

// 25.11
t.assert("25.11", esFmt.formatAge("2022-06-15", "2025-06-15"), "3 años")

// 25.12
t.assert("25.12", esFmt.formatAge("2018-06-15", "2025-06-15"), "7 años")

// 25.13
t.assert("25.13", esFmt.formatStage("2025-06-15", "2025-06-15"), "Recién nacido")

// 25.14
t.assert("25.14", esFmt.formatStage("2025-01-15", "2025-06-15"), "Bebé")

// 25.15
t.assert("25.15", esFmt.formatStage("2024-06-15", "2025-06-15"), "Niño pequeño")

// 25.16
t.assert("25.16", esFmt.formatStage("2022-06-15", "2025-06-15"), "Niño")

// 25.17
t.assert("25.17", esFmt.formatStage("2012-06-15", "2025-06-15"), "Adolescente")

// 25.18
t.assert("25.18", esFmt.formatStage("2007-06-15", "2025-06-15"), "Adulto")

// 25.19
t.assertNull("25.19", esFmt.formatAge(null, "2025-06-15"))

// 25.20
t.assertNull("25.20", esFmt.formatStage(null, "2025-06-15"))

// ================================================================
// 26. Compactness — short
// ================================================================
t.section("26. Compactness short")
var shortFmt = SayableAge.new(ENLocale, "short")

// 26.1
t.assert("26.1", shortFmt.formatAge("2025-06-12", "2025-06-15"), "3 d")

// 26.2
t.assert("26.2", shortFmt.formatAge("2025-06-08", "2025-06-15"), "1 wk")

// 26.3
t.assert("26.3", shortFmt.formatAge("2025-06-07", "2025-06-15"), "1 wk, 1 d")

// 26.4
t.assert("26.4", shortFmt.formatAge("2025-01-15", "2025-07-15"), "6 mo")

// 26.5
t.assert("26.5", shortFmt.formatAge("2023-06-15", "2025-07-15"), "2 yr, 1 mo")

// 26.6
t.assert("26.6", shortFmt.formatAge("2022-06-15", "2025-12-15"), "3½ yr")

// 26.7
t.assert("26.7", shortFmt.formatAge("2018-06-15", "2025-06-15"), "7 yr")

// 26.8
t.assert("26.8", shortFmt.formatAge("2025-06-15", "2025-06-15"), "Newborn")

// 26.9
t.assert("26.9", shortFmt.formatStage("2025-01-15", "2025-06-15"), "Infant")

// ================================================================
// 27. Compactness — compact
// ================================================================
t.section("27. Compactness compact")
var compactFmt = SayableAge.new(ENLocale, "compact")

// 27.1
t.assert("27.1", compactFmt.formatAge("2025-06-12", "2025-06-15"), "3d")

// 27.2
t.assert("27.2", compactFmt.formatAge("2025-06-08", "2025-06-15"), "1w")

// 27.3
t.assert("27.3", compactFmt.formatAge("2025-06-07", "2025-06-15"), "1w1d")

// 27.4
t.assert("27.4", compactFmt.formatAge("2025-01-15", "2025-07-15"), "6m")

// 27.5
t.assert("27.5", compactFmt.formatAge("2023-06-15", "2025-07-15"), "2y1m")

// 27.6
t.assert("27.6", compactFmt.formatAge("2022-06-15", "2025-12-15"), "3½y")

// 27.7
t.assert("27.7", compactFmt.formatAge("2018-06-15", "2025-06-15"), "7y")

// 27.8
t.assert("27.8", compactFmt.formatAge("2025-06-15", "2025-06-15"), "Newborn")

// ================================================================
// 29. Locale-specific edge cases — plural rules
// ================================================================
t.section("29. Locale-specific")
var heFmt = SayableAge.new(HELocale)

// 29.1
t.assert("29.1", heFmt.formatAge("2025-06-15", "2025-06-15"), "רק נולד")

// 29.2
t.assert("29.2", heFmt.formatAge("2025-06-14", "2025-06-15"), "יום")

// 29.3
t.assert("29.3", heFmt.formatAge("2025-06-12", "2025-06-15"), "3 ימים")

// 29.4
t.assert("29.4", heFmt.formatAge("2025-06-01", "2025-06-15"), "שבועיים")

// 29.5
t.assert("29.5", heFmt.formatAge("2025-05-25", "2025-06-15"), "3 שבועות")

// 29.6
t.assert("29.6", heFmt.formatAge("2025-01-15", "2025-07-15"), "6 חודשים")

// 29.7
t.assert("29.7", heFmt.formatAge("2025-03-15", "2025-06-15"), "3 חודשים")

// 29.8
t.assert("29.8", heFmt.formatAge("2023-06-15", "2025-07-15"), "שנתיים, חודש")

// 29.9
t.assert("29.9", heFmt.formatAge("2022-06-15", "2025-12-15"), "3 שנים וחצי")

// 29.10
t.assert("29.10", heFmt.formatAge("2018-06-15", "2025-06-15"), "7 שנים")

// 29.11
t.assert("29.11", heFmt.formatStage("2025-06-15", "2025-06-15", "m"), "רק נולד")

// 29.12
t.assert("29.12", heFmt.formatStage("2025-06-15", "2025-06-15", "f"), "רק נולדה")

// 29.13
t.assert("29.13", heFmt.formatStage("2007-06-15", "2025-06-15", "m"), "מבוגר")

// 29.14
t.assert("29.14", heFmt.formatStage("2007-06-15", "2025-06-15", "f"), "מבוגרת")

// Macedonian (mk)
var mkFmt = SayableAge.new(MKLocale)

// 29.15
t.assert("29.15", mkFmt.formatAge("2025-06-15", "2025-06-15"), "Новороденче")

// 29.16
t.assert("29.16", mkFmt.formatAge("2025-06-14", "2025-06-15"), "1 ден")

// 29.17
t.assert("29.17", mkFmt.formatAge("2025-06-12", "2025-06-15"), "3 дена")

// 29.18
t.assert("29.18", mkFmt.formatAge("2025-01-15", "2025-07-15"), "6 месеци")

// 29.19
t.assert("29.19", mkFmt.formatAge("2023-06-15", "2025-07-15"), "2 години, 1 месец")

// 29.20
t.assert("29.20", mkFmt.formatAge("2022-06-15", "2025-12-15"), "3 години и пол")

// 29.21
t.assert("29.21", mkFmt.formatAge("2018-06-15", "2025-06-15"), "7 години")

// Swahili (sw)
var swFmt = SayableAge.new(SWLocale)

// 29.22
t.assert("29.22", swFmt.formatAge("2025-06-15", "2025-06-15"), "Mzaliwa mpya")

// 29.23
t.assert("29.23", swFmt.formatAge("2025-06-14", "2025-06-15"), "siku 1")

// 29.24
t.assert("29.24", swFmt.formatAge("2025-06-12", "2025-06-15"), "siku 3")

// 29.25
t.assert("29.25", swFmt.formatAge("2025-01-15", "2025-07-15"), "miezi 6")

// 29.26
t.assert("29.26", swFmt.formatAge("2023-06-15", "2025-07-15"), "miaka 2, mwezi 1")

// 29.27
t.assert("29.27", swFmt.formatAge("2022-06-15", "2025-12-15"), "miaka 3 na nusu")

// Indonesian (id)
var idFmt = SayableAge.new(IDLocale)

// 29.28
t.assert("29.28", idFmt.formatAge("2025-06-15", "2025-06-15"), "Baru lahir")

// 29.29
t.assert("29.29", idFmt.formatAge("2025-06-14", "2025-06-15"), "1 hari")

// 29.30
t.assert("29.30", idFmt.formatAge("2025-06-12", "2025-06-15"), "3 hari")

// 29.31
t.assert("29.31", idFmt.formatAge("2025-01-15", "2025-07-15"), "6 bulan")

// 29.32
t.assert("29.32", idFmt.formatAge("2022-06-15", "2025-12-15"), "3 setengah tahun")

// 29.33
t.assert("29.33", idFmt.formatAge("2018-06-15", "2025-06-15"), "7 tahun")

// Amharic (am)
var amFmt = SayableAge.new(AMLocale)

// 29.34
t.assert("29.34", amFmt.formatAge("2025-06-15", "2025-06-15"), "አዲስ የተወለደ")

// 29.35
t.assert("29.35", amFmt.formatAge("2025-06-14", "2025-06-15"), "1 ቀን")

// 29.36
t.assert("29.36", amFmt.formatAge("2025-06-12", "2025-06-15"), "3 ቀናት")

// 29.37
t.assert("29.37", amFmt.formatAge("2025-06-07", "2025-06-15"), "1 ሳምንት፣ 1 ቀን")

// 29.38
t.assert("29.38", amFmt.formatAge("2025-01-15", "2025-07-15"), "6 ወራት")

// 29.39
t.assert("29.39", amFmt.formatAge("2022-06-15", "2025-12-15"), "3 ዓመታት ተኩል")

// ================================================================
// 30. Locale lookup by code string
// ================================================================
t.section("30. Locale lookup")

// 30.1
var enLocale = SayableAge.getLocale("en")
t.assertNotNull("30.1", enLocale)
t.assert("30.1b", enLocale.code, "en")

// 30.2
var frLocale = SayableAge.getLocale("fr")
t.assertNotNull("30.2", frLocale)
t.assert("30.2b", frLocale.code, "fr")

// 30.3
t.assertNull("30.3", SayableAge.getLocale("xx"))

// 30.4
t.assertNull("30.4", SayableAge.getLocale(""))

// 30.5
t.assertNull("30.5", SayableAge.getLocale("EN"))

// ================================================================
// 31. Weeks and days across month ends
// ================================================================
t.section("31. Weeks and days across month ends")

// 31.1
t.assert("31.1", fmt.formatAge("2016-12-31", "2017-03-29"), "12 weeks, 4 days")

// 31.2
t.assert("31.2", fmt.formatAge("1991-11-27", "1992-02-25"), "12 weeks, 6 days")

// 31.3
t.assert("31.3", fmt.formatAge("2020-11-30", "2021-01-02"), "4 weeks, 5 days")

// 31.4
t.assert("31.4", compactFmt.formatAge("2016-12-31", "2017-03-29"), "12w4d")

// ================================================================
// 32. Half years take their plural form from whole years
// ================================================================
t.section("32. Half-year plurals")

var plFmt = SayableAge.new(PLLocale)
var plShortFmt = SayableAge.new(PLLocale, "short")
var shiFmt = SayableAge.new(SHILocale)

// 32.1
t.assert("32.1", plFmt.formatAge("2021-06-15", "2025-01-15"), "3 i pół lata")

// 32.2
t.assert("32.2", plShortFmt.formatAge("2020-06-15", "2025-12-15"), "5 i pół lat")

// 32.3
t.assert("32.3", shiFmt.formatAge("2005-06-08", "2012-06-07"), "6 iseggasen d uzgen")

// ================================================================
// 33. Input validation
// ================================================================
t.section("33. Input validation")

// 33.1
t.assertNull("33.1", fmt.formatAge("2025-02-30", "2032-06-25"))

// 33.2
t.assertNull("33.2", fmt.formatAge("2025-13-01", "2027-01-31"))

// 33.3
t.assertNull("33.3", fmt.formatAge("2023-02-29", "2025-03-01"))

// 33.4
t.assertNull("33.4", fmt.formatAge("2025-06-00", "2027-02-25"))

// 33.5
t.assertNull("33.5", fmt.formatAge("2025-6-1", "2027-02-25"))

// 33.6
t.assertNull("33.6", fmt.formatAge(" 2025-06-01", "2027-02-25"))

// 33.7
t.assertNull("33.7", fmt.formatAge("2025-06-15T10:00:00", "2027-02-25"))

// 33.8
t.assertNull("33.8", fmt.formatAge("2020-01-01", "2025-04-31"))

// 33.9
t.assertNull("33.9", fmt.formatStage("2025-02-30", "2027-09-05"))

// 33.10
t.assert("33.10", fmt.formatAge("2024-02-29", "2026-03-01"), "2 years")

// ================================================================
t.summary()
