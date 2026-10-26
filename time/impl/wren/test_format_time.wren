// Tests for sayable-time — mirrors the canonical test specification.
// All test IDs reference time/config/tests.json.

import "./format_time" for SayableTime
import "./locales/en" for ENLocale
import "./locales/de" for DELocale
import "./locales/fr" for FRLocale
import "./locales/ja" for JALocale
import "./locales/fi" for FILocale

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
var fmt = SayableTime.new(ENLocale)

// ================================================================
// 1. Null / edge cases
// ================================================================
t.section("1. Null / edge cases")

// 1.1
t.assertNull("1.1", fmt.formatTime(null))

// 1.2
t.assertNull("1.2", fmt.formatTime(""))

// 1.3
t.assertNull("1.3", fmt.formatTime("invalid"))

// 1.4
t.assertNull("1.4", fmt.formatTime("25:00"))

// ================================================================
// 2. Clock time (normal compactness)
// ================================================================
t.section("2. Clock time normal")

// 2.1
t.assert("2.1", fmt.formatTime("00:00"), "midnight")

// 2.2
t.assert("2.2", fmt.formatTime("12:00"), "noon")

// 2.3
t.assert("2.3", fmt.formatTime("15:00"), "three o'clock")

// 2.4
t.assert("2.4", fmt.formatTime("14:15"), "a quarter past two")

// 2.5
t.assert("2.5", fmt.formatTime("09:30"), "half past nine")

// 2.6
t.assert("2.6", fmt.formatTime("10:45"), "a quarter to eleven")

// 2.7
t.assert("2.7", fmt.formatTime("08:05"), "five past eight")

// 2.8
t.assert("2.8", fmt.formatTime("16:55"), "five to five")

// 2.9
t.assert("2.9", fmt.formatTime("23:58"), "midnight")

// 2.10
t.assert("2.10", fmt.formatTime("07:22"), "twenty past seven")

// 2.11
t.assert("2.11", fmt.formatTime("2025-01-15T14:15:00"), "a quarter past two")

// ================================================================
// 3. Clock time (short compactness)
// ================================================================
t.section("3. Clock time short")
var shortFmt = SayableTime.new(ENLocale, "short")

// 3.1
t.assert("3.1", shortFmt.formatTime("14:15"), "2:15 PM")

// 3.2
t.assert("3.2", shortFmt.formatTime("09:30"), "9:30 AM")

// 3.3
t.assert("3.3", shortFmt.formatTime("00:00"), "12:00 AM")

// 3.4
t.assert("3.4", shortFmt.formatTime("12:00"), "12:00 PM")

// ================================================================
// 4. Clock time (compact)
// ================================================================
t.section("4. Clock time compact")
var compactFmt = SayableTime.new(ENLocale, "compact")

// 4.1
t.assert("4.1", compactFmt.formatTime("14:15"), "2:15p")

// 4.2
t.assert("4.2", compactFmt.formatTime("09:30"), "9:30a")

// ================================================================
// 5. Locale — German
// ================================================================
t.section("5. German locale")
var deFmt = SayableTime.new(DELocale)

// 5.1
t.assert("5.1", deFmt.formatTime("15:30"), "halb vier")

// ================================================================
// 6. Locale — French
// ================================================================
t.section("6. French locale")
var frFmt = SayableTime.new(FRLocale)

// 6.1
t.assert("6.1", frFmt.formatTime("15:15"), "trois heures et quart")

// 6.2
t.assert("6.2", frFmt.formatTime("13:00"), "une heure")

// 6.3
t.assert("6.3", frFmt.formatTime("13:30"), "une heure et demie")

// 6.4
t.assert("6.4", frFmt.formatTime("14:45"), "trois heures moins le quart")

// 6.5
t.assert("6.5", frFmt.formatTime("14:50"), "trois heures moins dix")

// ================================================================
// 7. Locale — Japanese
// ================================================================
t.section("7. Japanese locale")
var jaFmt = SayableTime.new(JALocale)

// 7.1
t.assert("7.1", jaFmt.formatTime("15:30"), "三時半")

// ================================================================
// 8. Locale — Finnish (dot separator, short)
// ================================================================
t.section("8. Finnish locale short")
var fiFmt = SayableTime.new(FILocale, "short")

// 8.1
t.assert("8.1", fiFmt.formatTime("14:15"), "14.15")

// 8.2
t.assert("8.2", fiFmt.formatTime("00:00"), "0.00")

// ================================================================
// 9. Minutes in short and compact modes
// ================================================================
t.section("9. Minutes in short and compact modes")

// 9.1
t.assert("9.1", shortFmt.formatTime("18:01"), "6:01 PM")

// 9.2
t.assert("9.2", compactFmt.formatTime("19:05"), "7:05p")

// ================================================================
// 10. Input validation
// ================================================================
t.section("10. Input validation")

// 10.1
t.assert("10.1", fmt.formatTime("9:30"), "half past nine")

// 10.2
t.assert("10.2", fmt.formatTime("09:30"), "half past nine")

// 10.3
t.assertNull("10.3", fmt.formatTime(" 9:30"))

// 10.4
t.assertNull("10.4", fmt.formatTime("9:30 "))

// 10.5
t.assertNull("10.5", fmt.formatTime("9:5"))

// 10.6
t.assertNull("10.6", fmt.formatTime("24:00"))

// 10.7
t.assert("10.7", fmt.formatTime("14:15:30"), "a quarter past two")

// 10.8
t.assert("10.8", fmt.formatTime("2025-01-15T14:15:00Z"), "a quarter past two")

// 10.9
t.assertNull("10.9", fmt.formatTime("2025-02-30T14:15:00"))

// ================================================================
t.summary()
