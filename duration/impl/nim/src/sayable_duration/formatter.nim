## Human-friendly duration and relative time formatting.

import std/[options, tables, strutils, math]
import locale

const Version* = "0.5.0"


proc isLeapYear(year: int): bool =
  (year mod 4 == 0 and year mod 100 != 0) or (year mod 400 == 0)

proc daysInMonth(year, month: int): int =
  case month
  of 1, 3, 5, 7, 8, 10, 12: 31
  of 4, 6, 9, 11: 30
  of 2:
    if isLeapYear(year): 29 else: 28
  else: 0


proc daysSinceEpoch(year, month, day: int): int =
  ## Days since 2000-01-01 reference epoch.
  var days = 0
  if year >= 2000:
    for y in 2000 ..< year:
      days += (if isLeapYear(y): 366 else: 365)
  else:
    for y in year ..< 2000:
      days -= (if isLeapYear(y): 366 else: 365)
  for m in 1 ..< month:
    days += daysInMonth(year, m)
  days + day - 1


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


proc parseIsoToSeconds(isoStr: string): Option[int] =
  ## Parse a timestamp YYYY-MM-DDTHH:MM[:SS[.fff]][zone] (docs/input-formats.md)
  ## to seconds since 2000-01-01 for diffing; none if malformed.
  if isoStr.len < 11 or isoStr[4] != '-' or isoStr[7] != '-' or isoStr[10] != 'T' or
      digitRun(isoStr, 0) != 4 or digitRun(isoStr, 5) != 2 or digitRun(isoStr, 8) != 2:
    return none(int)
  let year = digitsValue(isoStr, 0, 4)
  let month = digitsValue(isoStr, 5, 2)
  let day = digitsValue(isoStr, 8, 2)
  if month < 1 or month > 12 or day < 1 or day > daysInMonth(year, month):
    return none(int)
  let clock = parseClock(isoStr[11 .. ^1])
  if clock.isNone:
    return none(int)
  let (hour, minute, second) = clock.get
  some(daysSinceEpoch(year, month, day) * 86400 + hour * 3600 + minute * 60 + second)


const MaxDurationMonths = 6000  ## 500 years, the same ceiling as sayable-age


proc approximateMonths(totalDays: int): int =
  ## Months from whole days, 30.44 days to the month, rounded.
  round(totalDays.float / 30.44).int


proc pick[T](override: Option[T], getter: proc(o: T): Option[string],
    default: string): string =
  if override.isSome:
    let val = getter(override.get)
    if val.isSome:
      return val.get
  default


type SayableDuration* = object
  locale: DurationLocale
  units: Table[string, UnitForms]
  half: string
  delimiter: string
  justNow: string
  ago: string
  inFuture: string


proc newSayableDuration*(locale: DurationLocale,
    compactness: Compactness = cNormal): SayableDuration =
  let ovr = case compactness
    of cShort: locale.short
    of cCompact: locale.compact
    of cNormal: none(CompactnessOverride)

  var units: Table[string, UnitForms]
  let ovrUnits = if ovr.isSome and ovr.get.units.isSome: ovr.get.units
                 else: none(OrderedTable[string, UnitForms])
  for k in ["second", "minute", "hour", "day", "week", "month", "year"]:
    if ovrUnits.isSome and k in ovrUnits.get:
      units[k] = ovrUnits.get[k]
    else:
      units[k] = locale.units[k]

  let half = pick(ovr, proc(o: CompactnessOverride): Option[
      string] = o.half, locale.half)
  let delimiter = pick(ovr, proc(o: CompactnessOverride): Option[
      string] = o.delimiter, locale.delimiter)
  let ago = pick(ovr, proc(o: CompactnessOverride): Option[
      string] = o.ago, locale.ago)
  let inFuture = pick(ovr, proc(o: CompactnessOverride): Option[
      string] = o.inFuture, locale.inFuture)

  SayableDuration(
    locale: locale,
    units: units,
    half: half,
    delimiter: delimiter,
    justNow: locale.justNow,
    ago: ago,
    inFuture: inFuture,
  )


proc formatDurationSeconds(sd: SayableDuration, total: int): string =
  ## Apply duration tiers to total seconds.
  let loc = sd.locale

  # 0 seconds
  if total == 0:
    return sd.justNow

  # 1-59 seconds
  if total < 60:
    return resolveUnit(total, sd.units["second"], loc)

  let totalMinutes = total div 60
  let remainderSeconds = total mod 60

  # 1-4 minutes: minutes + seconds
  if totalMinutes < 5:
    result = resolveUnit(totalMinutes, sd.units["minute"], loc)
    if remainderSeconds > 0:
      result.add(sd.delimiter)
      result.add(resolveUnit(remainderSeconds, sd.units["second"], loc))
    return result

  # 5-59 minutes
  if totalMinutes < 60:
    return resolveUnit(totalMinutes, sd.units["minute"], loc)

  let totalHours = total div 3600
  let remainderMinutes = (total mod 3600) div 60

  # 1-5 hours: hours + minutes (with half marker)
  if totalHours <= 5:
    if remainderMinutes == 30:
      return resolveUnit(totalHours, sd.units["hour"], loc, sd.half)
    result = resolveUnit(totalHours, sd.units["hour"], loc)
    if remainderMinutes > 0:
      result.add(sd.delimiter)
      result.add(resolveUnit(remainderMinutes, sd.units["minute"], loc))
    return result

  # 6-23 hours
  if totalHours < 24:
    return resolveUnit(totalHours, sd.units["hour"], loc)

  let totalDays = total div 86400
  let remainderHours = (total mod 86400) div 3600

  # 1-2 days: days + hours (with half marker)
  if totalDays <= 2:
    if remainderHours == 12:
      return resolveUnit(totalDays, sd.units["day"], loc, sd.half)
    result = resolveUnit(totalDays, sd.units["day"], loc)
    if remainderHours > 0:
      result.add(sd.delimiter)
      result.add(resolveUnit(remainderHours, sd.units["hour"], loc))
    return result

  # 3-6 days
  if totalDays < 7:
    return resolveUnit(totalDays, sd.units["day"], loc)

  let totalWeeks = totalDays div 7
  let remainderDays = totalDays mod 7

  # 1-4 weeks: weeks + days
  if totalDays < 30:
    result = resolveUnit(totalWeeks, sd.units["week"], loc)
    if remainderDays > 0:
      result.add(sd.delimiter)
      result.add(resolveUnit(remainderDays, sd.units["day"], loc))
    return result

  # Approximate months (30.44 days average)
  var totalMonths = approximateMonths(totalDays)

  # 1-11 months
  if totalMonths < 12:
    if totalMonths == 0:
      totalMonths = 1
    return resolveUnit(totalMonths, sd.units["month"], loc)

  # 12+ months: years + months
  let totalYears = totalMonths div 12
  let remainderMonths = totalMonths mod 12
  result = resolveUnit(totalYears, sd.units["year"], loc)
  if remainderMonths > 0:
    result.add(sd.delimiter)
    result.add(resolveUnit(remainderMonths, sd.units["month"], loc))


proc formatWithinCeiling(sd: SayableDuration, total: int): Option[string] =
  ## Apply the duration tiers; none beyond the 500-year ceiling.
  let wholeDays = total div 86400
  if wholeDays >= 30 and approximateMonths(wholeDays) > MaxDurationMonths:
    return none(string)
  some(sd.formatDurationSeconds(total))


proc formatDuration*(sd: SayableDuration,
    seconds: int): Option[string] =
  ## Format a duration in seconds as human-friendly text.
  if seconds < 0:
    return none(string)
  sd.formatWithinCeiling(seconds)


proc formatDurationIso*(sd: SayableDuration,
    startIso: string, endIso: string): Option[string] =
  ## Format duration between two ISO datetime strings.
  if startIso.len == 0 or endIso.len == 0:
    return none(string)
  let s = parseIsoToSeconds(startIso)
  let e = parseIsoToSeconds(endIso)
  if s.isNone or e.isNone:
    return none(string)
  sd.formatWithinCeiling(abs(e.get - s.get))


proc formatSince*(sd: SayableDuration,
    start: string, asOf: string): Option[string] =
  ## Format elapsed time as "X ago".
  if start.len == 0 or asOf.len == 0:
    return none(string)
  let s = parseIsoToSeconds(start)
  let a = parseIsoToSeconds(asOf)
  if s.isNone or a.isNone:
    return none(string)
  let diff = a.get - s.get
  if diff < 0:
    return none(string)
  if diff == 0:
    return some(sd.justNow)
  let dur = sd.formatWithinCeiling(diff)
  if dur.isNone:
    return none(string)
  some(sd.ago.replace("{0}", dur.get))


proc formatUntil*(sd: SayableDuration,
    target: string, asOf: string): Option[string] =
  ## Format time until a future event as "in X".
  if target.len == 0 or asOf.len == 0:
    return none(string)
  let t = parseIsoToSeconds(target)
  let a = parseIsoToSeconds(asOf)
  if t.isNone or a.isNone:
    return none(string)
  let diff = t.get - a.get
  if diff < 0:
    return none(string)
  if diff == 0:
    return some(sd.justNow)
  let dur = sd.formatWithinCeiling(diff)
  if dur.isNone:
    return none(string)
  some(sd.inFuture.replace("{0}", dur.get))
