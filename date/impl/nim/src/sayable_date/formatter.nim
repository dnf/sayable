## Human-friendly date formatting.

import std/[options, tables, strutils]
import locale

const Version* = "0.5.0"


proc parseDate(s: string): Option[tuple[year, month, day: int]] =
  ## Parse YYYY-MM-DD or ISO datetime to (year, month, day).
  if s.len == 0:
    return none(tuple[year, month, day: int])
  let datePart = if "T" in s: s.split("T")[0] else: s
  let parts = datePart.split("-")
  if parts.len != 3:
    return none(tuple[year, month, day: int])
  try:
    let year = parseInt(parts[0])
    let month = parseInt(parts[1])
    let day = parseInt(parts[2])
    if month < 1 or month > 12 or day < 1 or day > 31:
      return none(tuple[year, month, day: int])
    some((year: year, month: month, day: day))
  except ValueError:
    none(tuple[year, month, day: int])


proc toJdn(year, month, day: int): int =
  ## Julian Day Number for day-difference arithmetic.
  let a = (14 - month) div 12
  let y = year + 4800 - a
  let m = month + 12 * a - 3
  day + (153 * m + 2) div 5 + 365 * y + y div 4 - y div 100 + y div 400 - 32045


proc weekday(year, month, day: int): int =
  ## Day of week: 0=Sunday, 1=Monday, ..., 6=Saturday.
  let jdn = toJdn(year, month, day)
  (jdn + 1) mod 7


proc pickStr(override: Option[CompactnessOverride],
    getter: proc(o: CompactnessOverride): Option[string],
    default: string): string =
  if override.isSome:
    let val = getter(override.get)
    if val.isSome:
      return val.get
  default


proc pickSeq(override: Option[CompactnessOverride],
    getter: proc(o: CompactnessOverride): Option[seq[string]],
    default: seq[string]): seq[string] =
  if override.isSome:
    let val = getter(override.get)
    if val.isSome:
      return val.get
  default


proc pickTable(override: Option[CompactnessOverride],
    getter: proc(o: CompactnessOverride): Option[OrderedTable[string, string]],
    default: OrderedTable[string, string]): OrderedTable[string, string] =
  if override.isSome:
    let val = getter(override.get)
    if val.isSome:
      return val.get
  default


type SayableDate* = object
  locale: DateLocale
  compactness: Compactness
  months: seq[string]
  monthsInDate: Option[seq[string]]
  weekdays: seq[string]
  dayFormat: string
  dayFormatExceptions: OrderedTable[string, string]
  datePattern: string
  datePatternWithYear: string
  today: string
  tomorrow: string
  yesterday: string


proc newSayableDate*(locale: DateLocale,
    compactness: Compactness = cNormal): SayableDate =
  let ovr = case compactness
    of cShort: locale.short
    of cCompact: locale.compact
    of cNormal: none(CompactnessOverride)

  let months = pickSeq(ovr,
    proc(o: CompactnessOverride): Option[seq[string]] = o.months,
    locale.months)
  let monthsInDate = if ovr.isSome and ovr.get.monthsInDate.isSome:
      ovr.get.monthsInDate
    else:
      locale.monthsInDate
  let weekdays = pickSeq(ovr,
    proc(o: CompactnessOverride): Option[seq[string]] = o.weekdays,
    locale.weekdays)
  let dayFormat = pickStr(ovr,
    proc(o: CompactnessOverride): Option[string] = o.dayFormat,
    locale.dayFormat)

  # When override sets dayFormat but not dayFormatExceptions, clear exceptions
  var dayFormatExceptions: OrderedTable[string, string]
  if ovr.isSome and ovr.get.dayFormat.isSome and ovr.get.dayFormatExceptions.isNone:
    dayFormatExceptions = initOrderedTable[string, string]()
  else:
    dayFormatExceptions = pickTable(ovr,
      proc(o: CompactnessOverride): Option[OrderedTable[string, string]] = o.dayFormatExceptions,
      locale.dayFormatExceptions)

  let datePattern = pickStr(ovr,
    proc(o: CompactnessOverride): Option[string] = o.datePattern,
    locale.datePattern)
  let datePatternWithYear = pickStr(ovr,
    proc(o: CompactnessOverride): Option[string] = o.datePatternWithYear,
    locale.datePatternWithYear)
  let today = pickStr(ovr,
    proc(o: CompactnessOverride): Option[string] = o.today,
    locale.today)
  let tomorrow = pickStr(ovr,
    proc(o: CompactnessOverride): Option[string] = o.tomorrow,
    locale.tomorrow)
  let yesterday = pickStr(ovr,
    proc(o: CompactnessOverride): Option[string] = o.yesterday,
    locale.yesterday)

  SayableDate(
    locale: locale,
    compactness: compactness,
    months: months,
    monthsInDate: monthsInDate,
    weekdays: weekdays,
    dayFormat: dayFormat,
    dayFormatExceptions: dayFormatExceptions,
    datePattern: datePattern,
    datePatternWithYear: datePatternWithYear,
    today: today,
    tomorrow: tomorrow,
    yesterday: yesterday,
  )


proc formatAbsolute(sd: SayableDate, year, month, day: int,
    includeYear: bool): string =
  let dayStr = $day
  let fmt = if dayStr in sd.dayFormatExceptions: sd.dayFormatExceptions[dayStr]
            else: sd.dayFormat
  let formattedDay = fmt.replace("{n}", dayStr)

  let monthNames = if sd.monthsInDate.isSome: sd.monthsInDate.get
                   else: sd.months
  let monthName = monthNames[month - 1]

  let pattern = if includeYear: sd.datePatternWithYear else: sd.datePattern
  result = pattern.replace("{month}", monthName)
  result = result.replace("{day}", formattedDay)
  result = result.replace("{d}", $day)
  result = result.replace("{m}", $month)
  if includeYear:
    result = result.replace("{year}", $year)
    let yy = year mod 100
    var yyStr = $yy
    if yy < 10:
      yyStr = "0" & yyStr
    result = result.replace("{yy}", yyStr)


proc formatDate*(sd: SayableDate, date: string): Option[string] =
  ## Format a calendar date in locale-appropriate form.
  if date.len == 0:
    return none(string)
  let parsed = parseDate(date)
  if parsed.isNone:
    return none(string)
  let (year, month, day) = parsed.get
  some(sd.formatAbsolute(year, month, day, includeYear = false))


proc formatDateWithYear*(sd: SayableDate, date: string): Option[string] =
  ## Format a calendar date with year in locale-appropriate form.
  if date.len == 0:
    return none(string)
  let parsed = parseDate(date)
  if parsed.isNone:
    return none(string)
  let (year, month, day) = parsed.get
  some(sd.formatAbsolute(year, month, day, includeYear = true))


proc formatRelative*(sd: SayableDate, date: string,
    asOf: string): Option[string] =
  ## Format a date relative to asOf, picking the most natural reference.
  if date.len == 0 or asOf.len == 0:
    return none(string)
  let parsedDate = parseDate(date)
  let parsedAsOf = parseDate(asOf)
  if parsedDate.isNone or parsedAsOf.isNone:
    return none(string)

  let (dy, dm, dd) = parsedDate.get
  let (ay, am, ad) = parsedAsOf.get

  let dateJdn = toJdn(dy, dm, dd)
  let asofJdn = toJdn(ay, am, ad)
  let diff = dateJdn - asofJdn

  # Today
  if diff == 0:
    return some(sd.today)

  # Tomorrow
  if diff == 1:
    return some(sd.tomorrow)

  # Yesterday
  if diff == -1:
    return some(sd.yesterday)

  let loc = sd.locale
  let isCompact = sd.compactness == cCompact

  # Day after tomorrow
  if diff == 2 and loc.dayAfterTomorrow.isSome and not isCompact:
    return some(loc.dayAfterTomorrow.get)

  # Day before yesterday
  if diff == -2 and loc.dayBeforeYesterday.isSome and not isCompact:
    return some(loc.dayBeforeYesterday.get)

  # Compact mode: skip weekday references
  if isCompact:
    let includeYear = dy != ay
    return some(sd.formatAbsolute(dy, dm, dd, includeYear = includeYear))

  # This weekday (+2 to +6)
  if diff >= 2 and diff <= 6 and loc.thisWeekday.isSome:
    let dow = weekday(dy, dm, dd)
    let weekdayName = sd.weekdays[dow]
    return some(loc.thisWeekday.get.replace("{weekday}", weekdayName))

  # Last weekday (-2 to -6)
  if diff >= -6 and diff <= -2 and loc.lastWeekday.isSome:
    let dow = weekday(dy, dm, dd)
    let weekdayName = sd.weekdays[dow]
    return some(loc.lastWeekday.get.replace("{weekday}", weekdayName))

  # Next weekday (+7 to +13)
  if diff >= 7 and diff <= 13 and loc.nextWeekday.isSome:
    let dow = weekday(dy, dm, dd)
    let weekdayName = sd.weekdays[dow]
    return some(loc.nextWeekday.get.replace("{weekday}", weekdayName))

  # Calendar fallback
  let includeYear = dy != ay
  some(sd.formatAbsolute(dy, dm, dd, includeYear = includeYear))
