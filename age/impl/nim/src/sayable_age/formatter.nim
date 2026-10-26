## Human-friendly age formatting for young children.

import std/[options, tables, times]
import locale

const Version* = "0.5.0"
const MaxAgeMonths = 6000


proc isLeapYear(year: int): bool =
  (year mod 4 == 0 and year mod 100 != 0) or (year mod 400 == 0)

proc daysInMonth(year, month: int): int =
  case month
  of 1, 3, 5, 7, 8, 10, 12: 31
  of 4, 6, 9, 11: 30
  of 2:
    if isLeapYear(year): 29 else: 28
  else: 0

proc toJdn(year, month, day: int): int =
  ## Julian Day Number for day-difference arithmetic.
  let a = (14 - month) div 12
  let y = year + 4800 - a
  let m = month + 12 * a - 3
  day + (153 * m + 2) div 5 + 365 * y + y div 4 - y div 100 + y div 400 - 32045


type ParsedAge = object
  months: int
  diffDays: int

proc parseDigits(s: string): Option[int] =
  ## A run of ASCII digits as an int; none if any character isn't a digit.
  var n = 0
  for c in s:
    if c notin {'0'..'9'}:
      return none(int)
    n = n * 10 + (ord(c) - ord('0'))
  some(n)

proc parseDate(s: string): Option[(int, int, int)] =
  ## Exactly YYYY-MM-DD naming a real calendar day (docs/input-formats.md).
  if s.len != 10 or s[4] != '-' or s[7] != '-':
    return none((int, int, int))
  let y = parseDigits(s[0 .. 3])
  let m = parseDigits(s[5 .. 6])
  let d = parseDigits(s[8 .. 9])
  if y.isNone or m.isNone or d.isNone:
    return none((int, int, int))
  if m.get < 1 or m.get > 12 or d.get < 1 or d.get > daysInMonth(y.get, m.get):
    return none((int, int, int))
  some((y.get, m.get, d.get))

proc parseAge(dateOfBirth: string, asOf: string = ""): Option[ParsedAge] =
  ## Parse two YYYY-MM-DD strings into (calendar_months, elapsed_days).
  let dob = parseDate(dateOfBirth)
  if dob.isNone:
    return none(ParsedAge)
  let (dobY, dobM, dobD) = dob.get

  var refY, refM, refD: int
  if asOf.len > 0:
    let asOfDate = parseDate(asOf)
    if asOfDate.isNone:
      return none(ParsedAge)
    (refY, refM, refD) = asOfDate.get
  else:
    let today = now().utc
    refY = today.year
    refM = ord(today.month)
    refD = today.monthday

  let diffDays = toJdn(refY, refM, refD) - toJdn(dobY, dobM, dobD)
  if diffDays < 0:
    return none(ParsedAge)

  let lastDay = daysInMonth(refY, refM)
  let clampedBirthday = min(dobD, lastDay)
  var months = (refY - dobY) * 12 + (refM - dobM)
  if refD < clampedBirthday:
    months -= 1
  if months > MaxAgeMonths:
    return none(ParsedAge)

  some(ParsedAge(months: months, diffDays: diffDays))


proc stageKey(months: int): string =
  if months < 2: "newborn"
  elif months < 12: "infant"
  elif months < 36: "toddler"
  elif months < 156: "child"
  elif months < 216: "teenager"
  else: "adult"


proc pick[T](override: Option[T], getter: proc(o: T): Option[string],
    default: string): string =
  if override.isSome:
    let val = getter(override.get)
    if val.isSome:
      return val.get
  default


type SayableAge* = object
  locale: AgeLocale
  units: Table[string, UnitForms]
  half: string
  delimiter: string
  justBorn: string


proc newSayableAge*(locale: AgeLocale,
    compactness: Compactness = cNormal): SayableAge =
  let ovr = case compactness
    of cShort: locale.short
    of cCompact: locale.compact
    of cNormal: none(CompactnessOverride)

  var units: Table[string, UnitForms]
  let ovrUnits = if ovr.isSome and ovr.get.units.isSome: ovr.get.units
                 else: none(OrderedTable[string, UnitForms])
  for k in ["day", "week", "month", "year"]:
    if ovrUnits.isSome and k in ovrUnits.get:
      units[k] = ovrUnits.get[k]
    else:
      units[k] = locale.units[k]

  let half = pick(ovr, proc(o: CompactnessOverride): Option[
      string] = o.half, locale.half)
  let delimiter = pick(ovr, proc(o: CompactnessOverride): Option[
      string] = o.delimiter, locale.delimiter)
  let justBorn = pick(ovr, proc(o: CompactnessOverride): Option[
      string] = o.justBorn, locale.justBorn)

  SayableAge(locale: locale, units: units, half: half, delimiter: delimiter,
      justBorn: justBorn)


proc formatAge*(sa: SayableAge, dateOfBirth: string,
    asOf: string = ""): Option[string] =
  ## Human-friendly age string.
  let parsed = parseAge(dateOfBirth, asOf)
  if parsed.isNone:
    return none(string)
  let months = parsed.get.months
  let diffDays = parsed.get.diffDays

  # Tier 1: 0-6 days
  if diffDays == 0:
    return some(sa.justBorn)
  if diffDays < 7:
    return some(resolveUnit(diffDays, sa.units["day"], sa.locale))

  # Tier 2: weeks + days until 3 calendar months
  if months < 3:
    let weeks = diffDays div 7
    let days = diffDays mod 7
    var text = resolveUnit(weeks, sa.units["week"], sa.locale)
    if days > 0:
      text.add(sa.delimiter)
      text.add(resolveUnit(days, sa.units["day"], sa.locale))
    return some(text)

  # Tier 3: 3-23 months
  if months < 24:
    return some(resolveUnit(months, sa.units["month"], sa.locale))

  # Tier 4: 24-35 months -> years + months
  if months < 36:
    let years = months div 12
    let rem = months mod 12
    if rem == 0:
      return some(resolveUnit(years, sa.units["year"], sa.locale))
    return some(
      resolveUnit(years, sa.units["year"], sa.locale) &
      sa.delimiter &
      resolveUnit(rem, sa.units["month"], sa.locale)
    )

  # Tier 5: 3-6 years -> years with half marker
  if months < 84:
    let years = months div 12
    let rem = months mod 12
    if rem >= 6:
      return some(resolveUnit(years, sa.units["year"], sa.locale, sa.half))
    return some(resolveUnit(years, sa.units["year"], sa.locale))

  # Tier 6: 7+ years
  some(resolveUnit(months div 12, sa.units["year"], sa.locale))


proc formatStage*(sa: SayableAge, dateOfBirth: string, asOf: string = "",
    gender: string = ""): Option[string] =
  ## Developmental stage label based on age.
  let parsed = parseAge(dateOfBirth, asOf)
  if parsed.isNone:
    return none(string)
  let key = stageKey(parsed.get.months)
  some(resolveStage(sa.locale.stages[key], gender))
