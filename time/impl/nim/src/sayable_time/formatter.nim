## Human-friendly clock time formatting.

import std/[options, tables, strutils]
import locale

const Version* = "0.5.0"


proc digitRun(s: string, start: int): int =
  ## Number of ASCII digits in s from start.
  var n = 0
  while start + n < s.len and s[start + n] in {'0'..'9'}:
    inc n
  n


proc digitsValue(s: string, start, count: int): int =
  ## Value of the count ASCII digits at start (the caller has checked them).
  for i in start ..< start + count:
    result = result * 10 + (ord(s[i]) - ord('0'))


proc isZoneSuffix(s: string, start: int): bool =
  ## Nothing, "Z", or "+HH:MM" / "-HH:MM" from start to the end of s.
  let zone = s[start .. ^1]
  if zone.len == 0 or zone == "Z":
    return true
  zone.len == 6 and zone[0] in {'+', '-'} and digitRun(zone, 1) == 2 and
    zone[3] == ':' and digitRun(zone, 4) == 2


proc parseClock(clock: string): Option[tuple[hour, minute, second: int]] =
  ## H:MM or HH:MM, optional :SS, optional . plus digits after the seconds, and
  ## an optional zone suffix, which is validated but ignored.
  let hourLen = digitRun(clock, 0)
  if hourLen < 1 or hourLen > 2 or clock.len < hourLen + 3 or clock[hourLen] != ':' or
      digitRun(clock, hourLen + 1) < 2:
    return none(tuple[hour, minute, second: int])
  let hour = digitsValue(clock, 0, hourLen)
  let minute = digitsValue(clock, hourLen + 1, 2)
  var second = 0
  var rest = hourLen + 3
  if rest < clock.len and clock[rest] == ':':
    if digitRun(clock, rest + 1) < 2:
      return none(tuple[hour, minute, second: int])
    second = digitsValue(clock, rest + 1, 2)
    rest += 3
    if rest < clock.len and clock[rest] == '.':
      let fractionLen = digitRun(clock, rest + 1)
      if fractionLen == 0:
        return none(tuple[hour, minute, second: int])
      rest += 1 + fractionLen
  if not isZoneSuffix(clock, rest) or hour > 23 or minute > 59 or second > 59:
    return none(tuple[hour, minute, second: int])
  some((hour: hour, minute: minute, second: second))


proc daysInMonth(year, month: int): int =
  ## Days in a Gregorian month (leap years by the 4/100/400 rule).
  case month
  of 2:
    if (year mod 4 == 0 and year mod 100 != 0) or year mod 400 == 0: 29 else: 28
  of 4, 6, 9, 11: 30
  else: 31


proc isRealDate(s: string): bool =
  ## Exactly YYYY-MM-DD naming a real calendar day.
  if s.len != 10 or s[4] != '-' or s[7] != '-' or digitRun(s, 0) != 4 or
      digitRun(s, 5) != 2 or digitRun(s, 8) != 2:
    return false
  let month = digitsValue(s, 5, 2)
  let day = digitsValue(s, 8, 2)
  month >= 1 and month <= 12 and day >= 1 and day <= daysInMonth(digitsValue(s, 0, 4), month)


proc parseTime(inputStr: string): Option[tuple[hour, minute: int]] =
  ## Parse a clock time, alone or after the T of an ISO datetime whose date is
  ## valid, to (hour, minute) (docs/input-formats.md).
  var clock = inputStr
  let tPos = inputStr.find('T')
  if tPos >= 0:
    if not isRealDate(inputStr[0 ..< tPos]):
      return none(tuple[hour, minute: int])
    clock = inputStr[tPos + 1 .. ^1]
  let parsed = parseClock(clock)
  if parsed.isNone:
    return none(tuple[hour, minute: int])
  some((hour: parsed.get.hour, minute: parsed.get.minute))


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
