## Human-friendly clock time formatting.

import std/[options, tables, strutils]
import locale

const Version* = "0.5.0"


proc parseTime(inputStr: string): Option[tuple[hour, minute: int]] =
  ## Parse HH:MM or ISO datetime to (hour, minute).
  if inputStr.len == 0:
    return none(tuple[hour, minute: int])
  var t = inputStr
  if "T" in t:
    t = t.split("T")[1]
  if "+" in t:
    t = t.split("+")[0]
  if "Z" in t:
    t = t.split("Z")[0]
  let parts = t.split(":")
  if parts.len < 2:
    return none(tuple[hour, minute: int])
  try:
    let hour = parseInt(parts[0])
    let minute = parseInt(parts[1].split(".")[0])
    if hour < 0 or hour > 23 or minute < 0 or minute > 59:
      return none(tuple[hour, minute: int])
    some((hour: hour, minute: minute))
  except ValueError:
    none(tuple[hour, minute: int])


proc roundTo5(minute: int): int =
  ## Round minute to nearest 5.
  ((minute + 2) div 5) * 5


type SayableTime* = object
  locale: TimeLocale
  compactness: Compactness
  shortClock: Option[ShortClockConfig]


proc newSayableTime*(locale: TimeLocale,
    compactness: Compactness = cNormal): SayableTime =
  let ovr = case compactness
    of cShort: locale.short
    of cCompact: locale.compact
    of cNormal: none(CompactnessOverride)
  let shortClock = if ovr.isSome: ovr.get.clock else: none(ShortClockConfig)
  SayableTime(locale: locale, compactness: compactness, shortClock: shortClock)


proc formatNatural(st: SayableTime, hour, minute: int): string =
  let clock = st.locale.clock
  var rounded = roundTo5(minute)
  var h = hour
  if rounded == 60:
    rounded = 0
    h = (h + 1) mod 24
  if rounded == 0:
    if h == 0:
      return clock.midnight
    if h == 12:
      return clock.noon
  let h12 = h mod 12
  let nextH12 = (h + 1) mod 12
  let hName = clock.hours[h12]
  let nextHName = clock.hours[nextH12]
  var pattern: string
  if rounded in clock.patterns:
    pattern = clock.patterns[rounded]
  elif 0 in clock.patterns:
    pattern = clock.patterns[0]
  else:
    pattern = "{h}"
  pattern.replace("{h}", hName).replace("{next_h}", nextHName)


proc formatDigital(st: SayableTime, hour, minute: int): string =
  let sc = st.shortClock.get
  let fmt = sc.format
  if sc.use24h:
    return fmt.replace("{h}", $hour).replace("{mm}", align($minute, 2, '0'))
  var h12 = hour mod 12
  if h12 == 0:
    h12 = 12
  let amPm = if sc.amPm.isSome: sc.amPm.get else: ("AM", "PM")
  let ampmStr = if hour < 12: amPm[0] else: amPm[1]
  fmt.replace("{h}", $h12).replace("{mm}", align($minute, 2, '0')).replace("{ampm}", ampmStr)


proc formatTime*(st: SayableTime, inputStr: string): Option[string] =
  ## Format a time as natural language clock reading.
  if inputStr.len == 0:
    return none(string)
  let parsed = parseTime(inputStr)
  if parsed.isNone:
    return none(string)
  let (hour, minute) = parsed.get
  if st.compactness != cNormal and st.shortClock.isSome:
    some(st.formatDigital(hour, minute))
  else:
    some(st.formatNatural(hour, minute))
