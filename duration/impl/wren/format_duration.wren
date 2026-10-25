// Human-friendly duration and relative time formatting.

import "./locales/registry" for LocaleRegistry

class SayableDuration {
  static version { "0.5.0" }

  // 500 years, the same ceiling as sayable-age
  static maxDurationMonths { 6000 }

  construct new(locale) {
    _locale = locale
    _ovr = null
    init_()
  }

  construct new(locale, compactness) {
    _locale = locale
    if (compactness == "short") {
      _ovr = locale.short
    } else if (compactness == "compact") {
      _ovr = locale.compact
    } else {
      _ovr = null
    }
    init_()
  }

  init_() {
    var ovrUnits = (_ovr != null && _ovr.containsKey("units")) ? _ovr["units"] : null
    _units = {}
    for (k in ["second", "minute", "hour", "day", "week", "month", "year"]) {
      if (ovrUnits != null && ovrUnits.containsKey(k)) {
        _units[k] = ovrUnits[k]
      } else {
        _units[k] = _locale.units[k]
      }
    }
    _half = pick_("half", _locale.half)
    _delimiter = pick_("delimiter", _locale.delimiter)
    _justNow = _locale.justNow
    _ago = pick_("ago", _locale.ago)
    _inFuture = pick_("inFuture", _locale.inFuture)
  }

  pick_(attr, defaultVal) {
    if (_ovr != null && _ovr.containsKey(attr)) return _ovr[attr]
    return defaultVal
  }

  formatDuration(startOrSeconds) { formatDuration(startOrSeconds, null) }

  formatDuration(startOrSeconds, end) {
    if (startOrSeconds == null) return null

    var totalSeconds
    if (startOrSeconds is Num) {
      totalSeconds = startOrSeconds
    } else if (startOrSeconds is String) {
      if (end == null) return null
      var s = SayableDuration.parseIsoToSeconds_(startOrSeconds)
      var e = SayableDuration.parseIsoToSeconds_(end)
      if (s == null || e == null) return null
      totalSeconds = (e - s).abs
    } else {
      return null
    }

    if (totalSeconds < 0) return null

    return formatDurationSeconds_(totalSeconds)
  }

  formatDurationSeconds_(total) {
    // 0 seconds
    if (total == 0) return _justNow

    // 1-59 seconds
    if (total < 60) return resolveUnit_(total, _units["second"], "")

    var totalMinutes = (total / 60).floor
    var remainderSeconds = total % 60

    // 1-4 minutes: minutes + seconds
    if (totalMinutes < 5) {
      var result = resolveUnit_(totalMinutes, _units["minute"], "")
      if (remainderSeconds > 0) {
        result = result + _delimiter + resolveUnit_(remainderSeconds, _units["second"], "")
      }
      return result
    }

    // 5-59 minutes
    if (totalMinutes < 60) return resolveUnit_(totalMinutes, _units["minute"], "")

    var totalHours = (total / 3600).floor
    var remainderMinutes = ((total % 3600) / 60).floor

    // 1-5 hours: hours + minutes (with half marker)
    if (totalHours <= 5) {
      if (remainderMinutes == 30) {
        return resolveUnit_(totalHours, _units["hour"], _half)
      }
      var result = resolveUnit_(totalHours, _units["hour"], "")
      if (remainderMinutes > 0) {
        result = result + _delimiter + resolveUnit_(remainderMinutes, _units["minute"], "")
      }
      return result
    }

    // 6-23 hours
    if (totalHours < 24) return resolveUnit_(totalHours, _units["hour"], "")

    var totalDays = (total / 86400).floor
    var remainderHours = ((total % 86400) / 3600).floor

    // 1-2 days: days + hours (with half marker)
    if (totalDays <= 2) {
      if (remainderHours == 12) {
        return resolveUnit_(totalDays, _units["day"], _half)
      }
      var result = resolveUnit_(totalDays, _units["day"], "")
      if (remainderHours > 0) {
        result = result + _delimiter + resolveUnit_(remainderHours, _units["hour"], "")
      }
      return result
    }

    // 3-6 days
    if (totalDays < 7) return resolveUnit_(totalDays, _units["day"], "")

    var totalWeeks = (totalDays / 7).floor
    var remainderDays = totalDays % 7

    // 1-4 weeks: weeks + days (up to 29 days)
    if (totalDays < 30) {
      var result = resolveUnit_(totalWeeks, _units["week"], "")
      if (remainderDays > 0) {
        result = result + _delimiter + resolveUnit_(remainderDays, _units["day"], "")
      }
      return result
    }

    // Approximate months (30.44 days average)
    var totalMonths = (totalDays / 30.44 + 0.5).floor
    if (totalMonths > SayableDuration.maxDurationMonths) return null

    // 1-11 months
    if (totalMonths < 12) {
      if (totalMonths == 0) totalMonths = 1
      return resolveUnit_(totalMonths, _units["month"], "")
    }

    // 12+ months: years + months
    var totalYears = (totalMonths / 12).floor
    var remainderMonths = totalMonths % 12
    var result = resolveUnit_(totalYears, _units["year"], "")
    if (remainderMonths > 0) {
      result = result + _delimiter + resolveUnit_(remainderMonths, _units["month"], "")
    }
    return result
  }

  formatSince(start, asOf) {
    if (start == null || start == "" || asOf == null || asOf == "") return null
    var s = SayableDuration.parseIsoToSeconds_(start)
    var a = SayableDuration.parseIsoToSeconds_(asOf)
    if (s == null || a == null) return null
    var diff = a - s
    if (diff < 0) return null
    if (diff == 0) return _justNow
    var dur = formatDurationSeconds_(diff)
    if (dur == null) return null
    return _ago.replace("{0}", dur)
  }

  formatUntil(target, asOf) {
    if (target == null || target == "" || asOf == null || asOf == "") return null
    var t = SayableDuration.parseIsoToSeconds_(target)
    var a = SayableDuration.parseIsoToSeconds_(asOf)
    if (t == null || a == null) return null
    var diff = t - a
    if (diff < 0) return null
    if (diff == 0) return _justNow
    var dur = formatDurationSeconds_(diff)
    if (dur == null) return null
    return _inFuture.replace("{0}", dur)
  }

  resolveUnit_(count, unitForms, half) {
    var baseN = count.toString
    var n = baseN
    if (half != "" && half.contains("{n}")) {
      n = half.replace("{n}", baseN)
    }
    var template
    if (unitForms is String) {
      template = unitForms
    } else {
      // Half-marked values use "other" plural (e.g. "1½ hours" not "1½ hour")
      var category = (half != "") ? "other" : _locale.plural.call(count)
      template = unitForms.containsKey(category) ? unitForms[category] : unitForms["other"]
    }
    var result = template.replace("{n}", n)
    if (half != "" && half.contains("{0}")) {
      result = half.replace("{0}", result)
    }
    return result
  }

  static isLeapYear_(y) { (y % 4 == 0 && y % 100 != 0) || y % 400 == 0 }

  static daysInMonth_(y, m) {
    var lengths = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if (m == 2 && isLeapYear_(y)) return 29
    return lengths[m]
  }

  static toJdn_(year, month, day) {
    var a = ((14 - month) / 12).floor
    var y = year + 4800 - a
    var m = month + 12 * a - 3
    return day + ((153 * m + 2) / 5).floor + 365 * y + (y / 4).floor - (y / 100).floor + (y / 400).floor - 32045
  }

  static isDigitAt_(bytes, i) { i < bytes.count && bytes[i] >= 48 && bytes[i] <= 57 }

  static digitsValue_(bytes, from, to) {
    var value = 0
    for (i in from...to) value = value * 10 + bytes[i] - 48
    return value
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

  // YYYY-MM-DDTHH:MM with optional :SS, fraction and zone suffix (ignored),
  // as seconds since an arbitrary epoch for diffing; else null.
  static parseIsoToSeconds_(isoStr) {
    if (!(isoStr is String)) return null
    var bytes = isoStr.bytes
    if (bytes.count < 11 || bytes[4] != 45 || bytes[7] != 45 || bytes[10] != 84) return null
    for (i in [0, 1, 2, 3, 5, 6, 8, 9]) {
      if (!isDigitAt_(bytes, i)) return null
    }
    var year = digitsValue_(bytes, 0, 4)
    var month = digitsValue_(bytes, 5, 7)
    var day = digitsValue_(bytes, 8, 10)
    if (month < 1 || month > 12 || day < 1 || day > daysInMonth_(year, month)) return null

    var i = 11
    if (!isDigitAt_(bytes, i)) return null
    i = i + 1
    if (isDigitAt_(bytes, i)) i = i + 1
    var hour = digitsValue_(bytes, 11, i)
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

    return toJdn_(year, month, day) * 86400 + hour * 3600 + minute * 60 + second
  }

  static getLocale(code) { LocaleRegistry.getLocale(code) }
}
