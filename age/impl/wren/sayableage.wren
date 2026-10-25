// Human-friendly age formatting for young children.

import "./locales/en" for ENLocale
import "./locales/registry" for LocaleRegistry

class SayableAge {
  static version { "0.5.0" }

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
    for (k in ["day", "week", "month", "year"]) {
      if (ovrUnits != null && ovrUnits.containsKey(k)) {
        _units[k] = ovrUnits[k]
      } else {
        _units[k] = _locale.units[k]
      }
    }
    _half = pick_("half", _locale.half)
    _delimiter = pick_("delimiter", _locale.delimiter)
    _justBorn = pick_("justBorn", _locale.justBorn)
  }

  pick_(attr, defaultVal) {
    if (_ovr != null && _ovr.containsKey(attr)) return _ovr[attr]
    return defaultVal
  }

  formatAge(dateOfBirth, asOf) {
    var parsed = SayableAge.parseAge_(dateOfBirth, asOf)
    if (parsed == null) return null
    var months = parsed[0]
    var diffDays = parsed[1]

    // Tier 1: 0-6 days
    if (diffDays == 0) return _justBorn
    if (diffDays < 7) return resolveUnit_(diffDays, _units["day"], "")

    // Tier 2: weeks + days until 3 calendar months
    if (months < 3) {
      var weeks = (diffDays / 7).floor
      var days = diffDays % 7
      var result = resolveUnit_(weeks, _units["week"], "")
      if (days > 0) {
        result = result + _delimiter + resolveUnit_(days, _units["day"], "")
      }
      return result
    }

    // Tier 3: 3-23 months
    if (months < 24) return resolveUnit_(months, _units["month"], "")

    // Tier 4: 24-35 months -> years + months
    if (months < 36) {
      var years = (months / 12).floor
      var rem = months % 12
      if (rem == 0) return resolveUnit_(years, _units["year"], "")
      return resolveUnit_(years, _units["year"], "") + _delimiter + resolveUnit_(rem, _units["month"], "")
    }

    // Tier 5: 3-6 years -> years with half marker
    if (months < 84) {
      var years = (months / 12).floor
      var rem = months % 12
      if (rem >= 6) return resolveUnit_(years, _units["year"], _half)
      return resolveUnit_(years, _units["year"], "")
    }

    // Tier 6: 7+ years
    return resolveUnit_((months / 12).floor, _units["year"], "")
  }

  formatStage(dateOfBirth, asOf) { formatStage(dateOfBirth, asOf, null) }

  formatStage(dateOfBirth, asOf, gender) {
    var parsed = SayableAge.parseAge_(dateOfBirth, asOf)
    if (parsed == null) return null
    var months = parsed[0]
    var key = SayableAge.stageKey_(months)
    var label = _locale.stages[key]
    return SayableAge.resolveStage_(label, gender)
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
      var category = _locale.plural.call(count)
      template = unitForms.containsKey(category) ? unitForms[category] : unitForms["other"]
    }
    var result = template.replace("{n}", n)
    if (half != "" && half.contains("{0}")) {
      result = half.replace("{0}", result)
    }
    return result
  }

  static stageKey_(months) {
    if (months < 2) return "newborn"
    if (months < 12) return "infant"
    if (months < 36) return "toddler"
    if (months < 156) return "child"
    if (months < 216) return "teenager"
    return "adult"
  }

  static resolveStage_(label, gender) {
    if (label is String) return label
    if (gender == "f") return label["f"]
    return label["m"]
  }

  static isLeapYear_(y) { (y % 4 == 0 && y % 100 != 0) || y % 400 == 0 }

  static daysInMonth_(y, m) {
    var lengths = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if (m == 2 && isLeapYear_(y)) return 29
    return lengths[m]
  }

  static toDayNumber_(y, m, d) {
    if (m <= 2) {
      y = y - 1
      m = m + 12
    }
    var a = (y / 100).floor
    var b = 2 - a + (a / 4).floor
    return (365.25 * (y + 4716)).floor + (30.6001 * (m + 1)).floor + d + b - 1524
  }

  static isDigitAt_(bytes, i) { bytes[i] >= 48 && bytes[i] <= 57 }

  static digitsValue_(bytes, from, to) {
    var value = 0
    for (i in from...to) value = value * 10 + bytes[i] - 48
    return value
  }

  // Exactly YYYY-MM-DD naming a real calendar day, as [y, m, d]; else null.
  static parseDate_(s) {
    if (!(s is String)) return null
    var bytes = s.bytes
    if (bytes.count != 10 || bytes[4] != 45 || bytes[7] != 45) return null
    for (i in [0, 1, 2, 3, 5, 6, 8, 9]) {
      if (!isDigitAt_(bytes, i)) return null
    }
    var y = digitsValue_(bytes, 0, 4)
    var m = digitsValue_(bytes, 5, 7)
    var d = digitsValue_(bytes, 8, 10)
    if (m < 1 || m > 12 || d < 1 || d > daysInMonth_(y, m)) return null
    return [y, m, d]
  }

  static parseAge_(dateOfBirth, asOf) {
    if (dateOfBirth == null || dateOfBirth == "") return null
    // No date library in Wren, so asOf is required.
    if (asOf == null || asOf == "") return null

    var dob = parseDate_(dateOfBirth)
    var ref = parseDate_(asOf)
    if (dob == null || ref == null) return null
    var dobY = dob[0]
    var dobM = dob[1]
    var dobD = dob[2]
    var refY = ref[0]
    var refM = ref[1]
    var refD = ref[2]

    var diffDays = toDayNumber_(refY, refM, refD) - toDayNumber_(dobY, dobM, dobD)
    if (diffDays < 0) return null

    var lastDay = daysInMonth_(refY, refM)
    var clampedBirthday = dobD < lastDay ? dobD : lastDay
    var months = (refY - dobY) * 12 + (refM - dobM)
    if (refD < clampedBirthday) months = months - 1
    if (months > 6000) return null

    return [months, diffDays]
  }

  static formatAge(dateOfBirth, asOf) {
    return SayableAge.defaultFormatter_.formatAge(dateOfBirth, asOf)
  }

  static formatStage(dateOfBirth, asOf) {
    return SayableAge.defaultFormatter_.formatStage(dateOfBirth, asOf)
  }

  static formatStage(dateOfBirth, asOf, gender) {
    return SayableAge.defaultFormatter_.formatStage(dateOfBirth, asOf, gender)
  }

  static defaultFormatter_ {
    if (__default == null) __default = SayableAge.new(ENLocale)
    return __default
  }

  static getLocale(code) { LocaleRegistry.getLocale(code) }
}
