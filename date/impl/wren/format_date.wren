// Human-friendly date formatting.

import "./locales/registry" for LocaleRegistry

class SayableDate {
  static version { "0.5.0" }

  construct new(locale) {
    _locale = locale
    _compactness = "normal"
    _ovr = null
    init_()
  }

  construct new(locale, compactness) {
    _locale = locale
    _compactness = compactness
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
    _months = pickList_("months", _locale.months)
    _monthsInDate = pickList_("monthsInDate", _locale.monthsInDate)
    _weekdays = pickList_("weekdays", _locale.weekdays)
    _dayFormat = pick_("dayFormat", _locale.dayFormat)

    // When short overrides dayFormat but not dayFormatExceptions, clear exceptions
    if (_ovr != null && _ovr.containsKey("dayFormat") && !_ovr.containsKey("dayFormatExceptions")) {
      _dayFormatExceptions = {}
    } else {
      _dayFormatExceptions = pickMap_("dayFormatExceptions", _locale.dayFormatExceptions)
    }

    _datePattern = pick_("datePattern", _locale.datePattern)
    _datePatternWithYear = pick_("datePatternWithYear", _locale.datePatternWithYear)
    _today = _locale.today
    _tomorrow = _locale.tomorrow
    _yesterday = _locale.yesterday
  }

  pick_(attr, defaultVal) {
    if (_ovr != null && _ovr.containsKey(attr)) return _ovr[attr]
    return defaultVal
  }

  pickList_(attr, defaultVal) {
    if (_ovr != null && _ovr.containsKey(attr)) return _ovr[attr]
    return defaultVal
  }

  pickMap_(attr, defaultVal) {
    if (_ovr != null && _ovr.containsKey(attr)) return _ovr[attr]
    return defaultVal
  }

  formatDate(date) {
    if (date == null || date == "") return null
    var parsed = SayableDate.parseDate_(date)
    if (parsed == null) return null
    return formatAbsolute_(parsed[0], parsed[1], parsed[2], false)
  }

  formatDateWithYear(date) {
    if (date == null || date == "") return null
    var parsed = SayableDate.parseDate_(date)
    if (parsed == null) return null
    return formatAbsolute_(parsed[0], parsed[1], parsed[2], true)
  }

  formatRelative(date, asOf) {
    if (date == null || date == "" || asOf == null || asOf == "") return null
    var parsedDate = SayableDate.parseDate_(date)
    var parsedAsOf = SayableDate.parseDate_(asOf)
    if (parsedDate == null || parsedAsOf == null) return null

    var dy = parsedDate[0]
    var dm = parsedDate[1]
    var dd = parsedDate[2]
    var ay = parsedAsOf[0]
    var am = parsedAsOf[1]
    var ad = parsedAsOf[2]

    var dateJdn = SayableDate.toJdn_(dy, dm, dd)
    var asofJdn = SayableDate.toJdn_(ay, am, ad)
    var diff = dateJdn - asofJdn

    // Today
    if (diff == 0) return _today

    // Tomorrow
    if (diff == 1) return _tomorrow

    // Yesterday
    if (diff == -1) return _yesterday

    var isCompact = _compactness == "compact"

    // Day after tomorrow (optional)
    if (diff == 2 && _locale.dayAfterTomorrow != null && !isCompact) {
      return _locale.dayAfterTomorrow
    }

    // Day before yesterday (optional)
    if (diff == -2 && _locale.dayBeforeYesterday != null && !isCompact) {
      return _locale.dayBeforeYesterday
    }

    // Compact mode: skip weekday references, go straight to calendar date
    if (isCompact) {
      var includeYear = dy != ay
      return formatAbsolute_(dy, dm, dd, includeYear)
    }

    // This weekday (+2 to +6)
    if (diff >= 2 && diff <= 6 && _locale.thisWeekday != null) {
      var dow = SayableDate.weekday_(dy, dm, dd)
      var weekdayName = _weekdays[dow]
      return _locale.thisWeekday.replace("{weekday}", weekdayName)
    }

    // Last weekday (-2 to -6)
    if (diff >= -6 && diff <= -2 && _locale.lastWeekday != null) {
      var dow = SayableDate.weekday_(dy, dm, dd)
      var weekdayName = _weekdays[dow]
      return _locale.lastWeekday.replace("{weekday}", weekdayName)
    }

    // Next weekday (+7 to +13)
    if (diff >= 7 && diff <= 13 && _locale.nextWeekday != null) {
      var dow = SayableDate.weekday_(dy, dm, dd)
      var weekdayName = _weekdays[dow]
      return _locale.nextWeekday.replace("{weekday}", weekdayName)
    }

    // Calendar fallback
    var includeYear = dy != ay
    return formatAbsolute_(dy, dm, dd, includeYear)
  }

  formatAbsolute_(year, month, day, includeYear) {
    // Format the day with ordinal
    var dayStr = day.toString
    var fmt = _dayFormatExceptions.containsKey(dayStr) ? _dayFormatExceptions[dayStr] : _dayFormat
    var formattedDay = fmt.replace("{n}", dayStr)

    // Pick month name (genitive form if available)
    var monthNames = _monthsInDate != null ? _monthsInDate : _months
    var monthName = monthNames[month - 1]

    var pattern = includeYear ? _datePatternWithYear : _datePattern
    var result = pattern.replace("{month}", monthName)
    result = result.replace("{day}", formattedDay)
    result = result.replace("{d}", day.toString)
    result = result.replace("{m}", month.toString)
    if (includeYear) {
      result = result.replace("{year}", year.toString)
      var yy = (year % 100).toString
      if (yy.count == 1) yy = "0" + yy
      result = result.replace("{yy}", yy)
    }

    return result
  }

  static isLeapYear_(y) { (y % 4 == 0 && y % 100 != 0) || y % 400 == 0 }

  static daysInMonth_(y, m) {
    if (m == 2) return isLeapYear_(y) ? 29 : 28
    return (m == 4 || m == 6 || m == 9 || m == 11) ? 30 : 31
  }

  static isDigitAt_(bytes, i) { bytes[i] >= 48 && bytes[i] <= 57 }

  static digitsValue_(bytes, from, to) {
    var value = 0
    for (i in from...to) value = value * 10 + bytes[i] - 48
    return value
  }

  // YYYY-MM-DD naming a real calendar day, optionally followed by T and a
  // time (which is not read), as [year, month, day]; else null.
  static parseDate_(s) {
    if (!(s is String)) return null
    var bytes = s.bytes
    var isDateAlone = bytes.count == 10
    var isDateTime = bytes.count > 10 && bytes[10] == 84
    if (!isDateAlone && !isDateTime) return null
    if (bytes[4] != 45 || bytes[7] != 45) return null
    for (i in [0, 1, 2, 3, 5, 6, 8, 9]) {
      if (!isDigitAt_(bytes, i)) return null
    }
    var year = digitsValue_(bytes, 0, 4)
    var month = digitsValue_(bytes, 5, 7)
    var day = digitsValue_(bytes, 8, 10)
    if (month < 1 || month > 12 || day < 1 || day > daysInMonth_(year, month)) return null
    return [year, month, day]
  }

  static toJdn_(year, month, day) {
    var a = ((14 - month) / 12).floor
    var y = year + 4800 - a
    var m = month + 12 * a - 3
    return day + ((153 * m + 2) / 5).floor + 365 * y + (y / 4).floor - (y / 100).floor + (y / 400).floor - 32045
  }

  static weekday_(year, month, day) {
    // 0=Sunday, 1=Monday, ..., 6=Saturday
    var jdn = toJdn_(year, month, day)
    return (jdn + 1) % 7
  }

  static getLocale(code) { LocaleRegistry.getLocale(code) }
}
