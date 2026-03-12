// Tests for sayable-duration — mirrors the canonical test specification.
// All test IDs reference duration/config/tests.json.

import "./format_duration" for SayableDuration
import "./locales/en" for ENLocale
import "./locales/de" for DELocale
import "./locales/fr" for FRLocale
import "./locales/ja" for JALocale

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
var fmt = SayableDuration.new(ENLocale)

// ================================================================
// 1. Null / edge cases
// ================================================================
t.section("1. Null / edge cases")

// 1.1
t.assertNull("1.1", fmt.formatDuration(null))

// 1.2
t.assertNull("1.2", fmt.formatDuration(-1))

// 1.3
t.assertNull("1.3", fmt.formatSince(null, "2025-01-15T10:00:00"))

// 1.4
t.assertNull("1.4", fmt.formatUntil(null, "2025-01-15T10:00:00"))

// 1.5
t.assertNull("1.5", fmt.formatSince("2025-01-15T10:00:00", "2025-01-15T09:00:00"))

// 1.6
t.assertNull("1.6", fmt.formatUntil("2025-01-15T09:00:00", "2025-01-15T10:00:00"))

// ================================================================
// 2. Duration — seconds tier (0-59s)
// ================================================================
t.section("2. Seconds tier")

// 2.1
t.assert("2.1", fmt.formatDuration(0), "just now")

// 2.2
t.assert("2.2", fmt.formatDuration(1), "1 second")

// 2.3
t.assert("2.3", fmt.formatDuration(45), "45 seconds")

// 2.4
t.assert("2.4", fmt.formatDuration(59), "59 seconds")

// ================================================================
// 3. Duration — minutes + seconds tier (1-4 min)
// ================================================================
t.section("3. Minutes + seconds tier")

// 3.1
t.assert("3.1", fmt.formatDuration(60), "1 minute")

// 3.2
t.assert("3.2", fmt.formatDuration(90), "1 minute, 30 seconds")

// 3.3
t.assert("3.3", fmt.formatDuration(240), "4 minutes")

// 3.4
t.assert("3.4", fmt.formatDuration(270), "4 minutes, 30 seconds")

// ================================================================
// 4. Duration — minutes tier (5-59 min)
// ================================================================
t.section("4. Minutes tier")

// 4.1
t.assert("4.1", fmt.formatDuration(300), "5 minutes")

// 4.2
t.assert("4.2", fmt.formatDuration(1500), "25 minutes")

// 4.3
t.assert("4.3", fmt.formatDuration(3540), "59 minutes")

// ================================================================
// 5. Duration — hours + minutes tier (1-5 hr)
// ================================================================
t.section("5. Hours + minutes tier")

// 5.1
t.assert("5.1", fmt.formatDuration(3600), "1 hour")

// 5.2
t.assert("5.2", fmt.formatDuration(5400), "1½ hours")

// 5.3
t.assert("5.3", fmt.formatDuration(8100), "2 hours, 15 minutes")

// 5.4
t.assert("5.4", fmt.formatDuration(18000), "5 hours")

// ================================================================
// 6. Duration — hours tier (6-23 hr)
// ================================================================
t.section("6. Hours tier")

// 6.1
t.assert("6.1", fmt.formatDuration(28800), "8 hours")

// 6.2
t.assert("6.2", fmt.formatDuration(82800), "23 hours")

// ================================================================
// 7. Duration — days tier
// ================================================================
t.section("7. Days tier")

// 7.1
t.assert("7.1", fmt.formatDuration(86400), "1 day")

// 7.2
t.assert("7.2", fmt.formatDuration(97200), "1 day, 3 hours")

// 7.3
t.assert("7.3", fmt.formatDuration(129600), "1½ days")

// 7.4
t.assert("7.4", fmt.formatDuration(432000), "5 days")

// 7.5
t.assert("7.5", fmt.formatDuration(172800), "2 days")

// ================================================================
// 8. Duration — weeks tier
// ================================================================
t.section("8. Weeks tier")

// 8.1
t.assert("8.1", fmt.formatDuration(604800), "1 week")

// 8.2
t.assert("8.2", fmt.formatDuration(1296000), "2 weeks, 1 day")

// 8.3
t.assert("8.3", fmt.formatDuration(2419200), "4 weeks")

// ================================================================
// 9. Duration — months and years tier
// ================================================================
t.section("9. Months and years tier")

// 9.1
t.assert("9.1", fmt.formatDuration(2678400), "1 month")

// 9.2
t.assert("9.2", fmt.formatDuration(7884000), "3 months")

// 9.3
t.assert("9.3", fmt.formatDuration(31536000), "1 year")

// 9.4
t.assert("9.4", fmt.formatDuration(39420000), "1 year, 3 months")

// ================================================================
// 10. Duration from ISO timestamps
// ================================================================
t.section("10. ISO timestamps")

// 10.1
t.assert("10.1", fmt.formatDuration("2025-01-15T10:00:00", "2025-01-15T11:30:00"), "1½ hours")

// 10.2
t.assert("10.2", fmt.formatDuration("2025-01-15T10:00:00", "2025-01-15T10:45:00"), "45 minutes")

// ================================================================
// 11. Relative time — since
// ================================================================
t.section("11. format_since")

// 11.1
t.assert("11.1", fmt.formatSince("2025-01-15T10:00:00", "2025-01-15T10:00:00"), "just now")

// 11.2
t.assert("11.2", fmt.formatSince("2025-01-15T10:00:00", "2025-01-15T10:00:30"), "30 seconds ago")

// 11.3
t.assert("11.3", fmt.formatSince("2025-01-15T10:00:00", "2025-01-15T10:45:00"), "45 minutes ago")

// 11.4
t.assert("11.4", fmt.formatSince("2025-01-15T10:00:00", "2025-01-15T13:00:00"), "3 hours ago")

// ================================================================
// 12. Relative time — until
// ================================================================
t.section("12. format_until")

// 12.1
t.assert("12.1", fmt.formatUntil("2025-01-15T10:00:00", "2025-01-15T10:00:00"), "just now")

// 12.2
t.assert("12.2", fmt.formatUntil("2025-01-15T10:20:00", "2025-01-15T10:00:00"), "in 20 minutes")

// 12.3
t.assert("12.3", fmt.formatUntil("2025-01-15T13:00:00", "2025-01-15T10:00:00"), "in 3 hours")

// ================================================================
// 13. Locale — German
// ================================================================
t.section("13. German locale")
var deFmt = SayableDuration.new(DELocale)

// 13.1
t.assert("13.1", deFmt.formatDuration(3600), "1 Stunde")

// 13.2
t.assert("13.2", deFmt.formatSince("2025-01-15T10:00:00", "2025-01-15T10:05:00"), "vor 5 Minuten")

// ================================================================
// 14. Locale — French
// ================================================================
t.section("14. French locale")
var frFmt = SayableDuration.new(FRLocale)

// 14.1
t.assert("14.1", frFmt.formatDuration(7200), "2 heures")

// ================================================================
// 15. Locale — Japanese
// ================================================================
t.section("15. Japanese locale")
var jaFmt = SayableDuration.new(JALocale)

// 15.1
t.assert("15.1", jaFmt.formatDuration(120), "2分")

// 15.2
t.assert("15.2", jaFmt.formatSince("2025-01-15T10:00:00", "2025-01-15T11:00:00"), "1時間前")

// ================================================================
// 16. Short compactness — duration
// ================================================================
t.section("16. Short compactness")
var shortFmt = SayableDuration.new(ENLocale, "short")

// 16.1
t.assert("16.1", shortFmt.formatDuration(3600), "1h")

// 16.2
t.assert("16.2", shortFmt.formatDuration(90), "1m, 30s")

// ================================================================
// 17. Compact compactness — duration
// ================================================================
t.section("17. Compact compactness")
var compactFmt = SayableDuration.new(ENLocale, "compact")

// 17.1
t.assert("17.1", compactFmt.formatDuration(3600), "1h")

// 17.2
t.assert("17.2", compactFmt.formatDuration(90), "1m30s")

// ================================================================
t.summary()
