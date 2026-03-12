// Tests for sayable-date — mirrors the canonical test specification.
// All test IDs reference date/config/tests.json.

import "./format_date" for SayableDate
import "./locales/en" for ENLocale
import "./locales/de" for DELocale
import "./locales/fr" for FRLocale
import "./locales/ja" for JALocale
import "./locales/ru" for RULocale
import "./locales/ar" for ARLocale
import "./locales/es" for ESLocale

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
var fmt = SayableDate.new(ENLocale)

// ================================================================
// 1. Null / edge cases
// ================================================================
t.section("1. Null / edge cases")

// 1.1
t.assertNull("1.1", fmt.formatDate(null))

// 1.2
t.assertNull("1.2", fmt.formatDate(""))

// 1.3
t.assertNull("1.3", fmt.formatDate("invalid"))

// 1.4
t.assertNull("1.4", fmt.formatRelative("2025-03-15", null))

// 1.5
t.assertNull("1.5", fmt.formatRelative(null, "2025-03-15"))

// ================================================================
// 2. format_date — normal compactness (English)
// ================================================================
t.section("2. format_date normal")

// 2.1
t.assert("2.1", fmt.formatDate("2025-03-15"), "March 15th")

// 2.2
t.assert("2.2", fmt.formatDate("2025-01-01"), "January 1st")

// 2.3
t.assert("2.3", fmt.formatDate("2025-05-22"), "May 22nd")

// 2.4
t.assert("2.4", fmt.formatDate("2025-07-03"), "July 3rd")

// 2.5
t.assert("2.5", fmt.formatDate("2025-12-31"), "December 31st")

// 2.6
t.assert("2.6", fmt.formatDate("2025-06-11"), "June 11th")

// 2.7
t.assert("2.7", fmt.formatDate("2025-03-15T14:30:00"), "March 15th")

// ================================================================
// 3. format_date — short compactness (English)
// ================================================================
t.section("3. format_date short")
var shortFmt = SayableDate.new(ENLocale, "short")

// 3.1
t.assert("3.1", shortFmt.formatDate("2025-03-15"), "Mar 15")

// 3.2
t.assert("3.2", shortFmt.formatDate("2025-01-01"), "Jan 1")

// 3.3
t.assert("3.3", shortFmt.formatDate("2025-12-25"), "Dec 25")

// ================================================================
// 4. format_date — compact (English)
// ================================================================
t.section("4. format_date compact")
var compactFmt = SayableDate.new(ENLocale, "compact")

// 4.1
t.assert("4.1", compactFmt.formatDate("2025-03-15"), "3/15")

// 4.2
t.assert("4.2", compactFmt.formatDate("2025-01-01"), "1/1")

// ================================================================
// 5. format_relative — proximity tiers (English)
// ================================================================
t.section("5. format_relative proximity")

// 5.1
t.assert("5.1", fmt.formatRelative("2025-03-15", "2025-03-15"), "today")

// 5.2
t.assert("5.2", fmt.formatRelative("2025-03-16", "2025-03-15"), "tomorrow")

// 5.3
t.assert("5.3", fmt.formatRelative("2025-03-14", "2025-03-15"), "yesterday")

// 5.4
t.assert("5.4", fmt.formatRelative("2025-03-17", "2025-03-15"), "the day after tomorrow")

// 5.5
t.assert("5.5", fmt.formatRelative("2025-03-13", "2025-03-15"), "the day before yesterday")

// 5.6
t.assert("5.6", fmt.formatRelative("2025-03-19", "2025-03-15"), "this Wednesday")

// 5.7
t.assert("5.7", fmt.formatRelative("2025-03-20", "2025-03-15"), "this Thursday")

// 5.8
t.assert("5.8", fmt.formatRelative("2025-03-11", "2025-03-15"), "last Tuesday")

// 5.9
t.assert("5.9", fmt.formatRelative("2025-03-22", "2025-03-15"), "next Saturday")

// 5.10
t.assert("5.10", fmt.formatRelative("2025-03-27", "2025-03-15"), "next Thursday")

// 5.11
t.assert("5.11", fmt.formatRelative("2025-03-01", "2025-03-15"), "March 1st")

// 5.12
t.assert("5.12", fmt.formatRelative("2025-04-10", "2025-03-15"), "April 10th")

// 5.13
t.assert("5.13", fmt.formatRelative("2026-01-05", "2025-03-15"), "January 5th, 2026")

// 5.14
t.assert("5.14", fmt.formatRelative("2024-12-25", "2025-03-15"), "December 25th, 2024")

// ================================================================
// 6. format_relative — compact skips weekday tiers
// ================================================================
t.section("6. format_relative compact")

// 6.1
t.assert("6.1", compactFmt.formatRelative("2025-03-15", "2025-03-15"), "today")

// 6.2
t.assert("6.2", compactFmt.formatRelative("2025-03-16", "2025-03-15"), "tomorrow")

// 6.3
t.assert("6.3", compactFmt.formatRelative("2025-03-19", "2025-03-15"), "3/19")

// 6.4
t.assert("6.4", compactFmt.formatRelative("2026-01-05", "2025-03-15"), "1/5/26")

// ================================================================
// 7. Locale — German
// ================================================================
t.section("7. German locale")
var deFmt = SayableDate.new(DELocale)

// 7.1
t.assert("7.1", deFmt.formatDate("2025-03-15"), "15. März")

// 7.2
t.assert("7.2", deFmt.formatRelative("2025-03-16", "2025-03-15"), "morgen")

// 7.3
t.assert("7.3", deFmt.formatRelative("2025-03-17", "2025-03-15"), "übermorgen")

// 7.4
t.assert("7.4", deFmt.formatRelative("2025-03-19", "2025-03-15"), "diesen Mittwoch")

// ================================================================
// 8. Locale — French
// ================================================================
t.section("8. French locale")
var frFmt = SayableDate.new(FRLocale)

// 8.1
t.assert("8.1", frFmt.formatDate("2025-03-01"), "1er mars")

// 8.2
t.assert("8.2", frFmt.formatDate("2025-03-15"), "15 mars")

// 8.3
t.assert("8.3", frFmt.formatRelative("2025-03-16", "2025-03-15"), "demain")

// ================================================================
// 9. Locale — Japanese
// ================================================================
t.section("9. Japanese locale")
var jaFmt = SayableDate.new(JALocale)

// 9.1
t.assert("9.1", jaFmt.formatDate("2025-03-15"), "3月15日")

// 9.2
t.assert("9.2", jaFmt.formatRelative("2025-03-16", "2025-03-15"), "明日")

// 9.3
t.assert("9.3", jaFmt.formatRelative("2025-03-19", "2025-03-15"), "今度の水曜日")

// ================================================================
// 10. Locale — Russian (genitive months)
// ================================================================
t.section("10. Russian locale")
var ruFmt = SayableDate.new(RULocale)

// 10.1
t.assert("10.1", ruFmt.formatDate("2025-03-15"), "15 марта")

// 10.2
t.assert("10.2", ruFmt.formatRelative("2025-03-16", "2025-03-15"), "завтра")

// ================================================================
// 11. Locale — Arabic
// ================================================================
t.section("11. Arabic locale")
var arFmt = SayableDate.new(ARLocale)

// 11.1
t.assert("11.1", arFmt.formatDate("2025-03-15"), "15 مارس")

// 11.2
t.assert("11.2", arFmt.formatRelative("2025-03-16", "2025-03-15"), "غداً")

// ================================================================
// 12. Locale — Spanish
// ================================================================
t.section("12. Spanish locale")
var esFmt = SayableDate.new(ESLocale)

// 12.1
t.assert("12.1", esFmt.formatDate("2025-03-15"), "15 de marzo")

// 12.2
t.assert("12.2", esFmt.formatRelative("2025-03-17", "2025-03-15"), "pasado mañana")

// ================================================================
t.summary()
