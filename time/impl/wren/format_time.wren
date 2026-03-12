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

  static parseTime_(inputStr) {
    if (inputStr == null || inputStr == "") return null
    var t = inputStr
    if (t.contains("T")) {
      t = t.split("T")[1]
    }
    if (t.contains("+")) {
      t = t.split("+")[0]
    }
    if (t.contains("Z")) {
      t = t.split("Z")[0]
    }
    var parts = t.split(":")
    if (parts.count < 2) return null
    var hour = Num.fromString(parts[0])
    var minStr = parts[1]
    if (minStr.contains(".")) minStr = minStr.split(".")[0]
    var minute = Num.fromString(minStr)
    if (hour == null || minute == null) return null
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null
    return [hour, minute]
  }

  static roundTo5_(minute) {
    return (((minute + 2) / 5).floor) * 5
  }

  static getLocale(code) { LocaleRegistry.getLocale(code) }
}
