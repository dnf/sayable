// Human-friendly clock time formatting.

import "./locales/registry" for LocaleRegistry

class SayableTime {
  static version { "0.5.0" }

  construct new(locale) {
    _locale = locale
    _compactness = "normal"
    _shortClock = null
  }

  construct new(locale, compactness) {
    _locale = locale
    _compactness = compactness
    if (compactness == "short" || compactness == "compact") {
      var ovr = compactness == "short" ? locale.short : locale.compact
      if (ovr != null && ovr.containsKey("clock")) {
        _shortClock = ovr["clock"]
      } else {
        _shortClock = null
      }
    } else {
      _shortClock = null
    }
  }

  formatTime(inputStr) {
    if (inputStr == null || inputStr == "") return null
    var parsed = SayableTime.parseTime_(inputStr)
    if (parsed == null) return null
    var hour = parsed[0]
    var minute = parsed[1]

    if (_compactness != "normal" && _shortClock != null) {
      return formatDigital_(hour, minute)
    }
    return formatNatural_(hour, minute)
  }

  formatNatural_(hour, minute) {
    var clock = _locale.clock
    var rounded = SayableTime.roundTo5_(minute)
    var h = hour
    if (rounded == 60) {
      rounded = 0
      h = (h + 1) % 24
    }
    if (rounded == 0) {
      if (h == 0) return clock["midnight"]
      if (h == 12) return clock["noon"]
    }
    var h12 = h % 12
    var nextH12 = (h + 1) % 12
    var hName = clock["hours"][h12]
    var nextHName = clock["hours"][nextH12]
    var patterns = clock["patterns"]
    var pattern = patterns.containsKey(rounded) ? patterns[rounded] : patterns[0]
    return pattern.replace("{h}", hName).replace("{next_h}", nextHName)
  }

  formatDigital_(hour, minute) {
    var sc = _shortClock
    var fmt = sc["format"]
    var mm = minute.toString
    if (mm.count == 1) mm = "0" + mm
    if (sc["use24h"]) {
      return fmt.replace("{h}", hour.toString).replace("{mm}", mm)
    }
    var h12 = hour % 12
    if (h12 == 0) h12 = 12
    var amPm = sc.containsKey("amPm") ? sc["amPm"] : ["AM", "PM"]
    var ampmStr = hour < 12 ? amPm[0] : amPm[1]
    return fmt.replace("{h}", h12.toString).replace("{mm}", mm).replace("{ampm}", ampmStr)
  }

  // A clock time (H:MM or HH:MM, optional :SS and fraction, optional zone
  // suffix, which is ignored), alone or after the T of an ISO datetime, as
  // [hour, minute]; else null.
  static parseTime_(inputStr) {
    if (!(inputStr is String) || inputStr == "") return null
    var bytes = inputStr.bytes
    var clockStart = 0
    var t = inputStr.indexOf("T")
    if (t >= 0) {
      if (t != 10 || !isRealDate_(bytes)) return null
      clockStart = 11
    }
    return parseClock_(bytes, clockStart)
  }

  static isDigitAt_(bytes, i) { i < bytes.count && bytes[i] >= 48 && bytes[i] <= 57 }

  static digitsValue_(bytes, from, to) {
    var value = 0
    for (i in from...to) value = value * 10 + bytes[i] - 48
    return value
  }

  static isLeapYear_(y) { (y % 4 == 0 && y % 100 != 0) || y % 400 == 0 }

  static daysInMonth_(y, m) {
    if (m == 2) return isLeapYear_(y) ? 29 : 28
    return (m == 4 || m == 6 || m == 9 || m == 11) ? 30 : 31
  }

  // The first ten bytes are YYYY-MM-DD naming a real calendar day.
  static isRealDate_(bytes) {
    if (bytes[4] != 45 || bytes[7] != 45) return false
    for (i in [0, 1, 2, 3, 5, 6, 8, 9]) {
      if (!isDigitAt_(bytes, i)) return false
    }
    var year = digitsValue_(bytes, 0, 4)
    var month = digitsValue_(bytes, 5, 7)
    var day = digitsValue_(bytes, 8, 10)
    return month >= 1 && month <= 12 && day >= 1 && day <= daysInMonth_(year, month)
  }

  // A zone suffix Z or +HH:MM / -HH:MM running exactly to the end.
  static isZoneSuffix_(bytes, i) {
    var n = bytes.count
    if (i == n) return true
    if (bytes[i] == 90) return i + 1 == n
    if (bytes[i] != 43 && bytes[i] != 45) return false
    return i + 6 == n && isDigitAt_(bytes, i + 1) && isDigitAt_(bytes, i + 2) &&
      bytes[i + 3] == 58 && isDigitAt_(bytes, i + 4) && isDigitAt_(bytes, i + 5)
  }

  static parseClock_(bytes, start) {
    var i = start
    if (!isDigitAt_(bytes, i)) return null
    i = i + 1
    if (isDigitAt_(bytes, i)) i = i + 1
    var hour = digitsValue_(bytes, start, i)
    if (i >= bytes.count || bytes[i] != 58) return null
    if (!isDigitAt_(bytes, i + 1) || !isDigitAt_(bytes, i + 2)) return null
    var minute = digitsValue_(bytes, i + 1, i + 3)
    i = i + 3
    var second = 0
    if (i < bytes.count && bytes[i] == 58) {
      if (!isDigitAt_(bytes, i + 1) || !isDigitAt_(bytes, i + 2)) return null
      second = digitsValue_(bytes, i + 1, i + 3)
      i = i + 3
      if (i < bytes.count && bytes[i] == 46) {
        i = i + 1
        if (!isDigitAt_(bytes, i)) return null
        while (isDigitAt_(bytes, i)) i = i + 1
      }
    }
    if (!isZoneSuffix_(bytes, i)) return null
    if (hour > 23 || minute > 59 || second > 59) return null
    return [hour, minute]
  }

  static roundTo5_(minute) {
    return (((minute + 2) / 5).floor) * 5
  }

  static getLocale(code) { LocaleRegistry.getLocale(code) }
}
