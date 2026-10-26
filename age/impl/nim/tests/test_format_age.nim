## Tests for formatAge and formatStage — all canonical test cases from age/config/tests.json.

import std/[unittest, options, times]
import ../src/sayable_age/locale
import ../src/sayable_age/formatter
import ../src/sayable_age/locales/registry
import ../src/sayable_age/locales/en
import ../src/sayable_age/locales/es
import ../src/sayable_age/locales/he
import ../src/sayable_age/locales/mk
import ../src/sayable_age/locales/sw
import ../src/sayable_age/locales/id
import ../src/sayable_age/locales/am


# ================================================================
# Default asOf (current date)
# ================================================================
# The library has no way to override "today", so these derive the input
# from the real current date (UTC, as the library reads it).
proc isoDate(d: DateTime): string =
  d.format("yyyy-MM-dd")

proc yearsAgo(years: int): string =
  ## Same month and day `years` ago, clamped so Feb 29 stays a real date.
  let today = now().utc
  let year = today.year - years
  let day = min(today.monthday, getDaysInMonth(today.month, year))
  isoDate(dateTime(year, today.month, day, zone = utc()))

suite "Default asOf (current date)":
  let sa = newSayableAge(EN)

  # 15.1
  test "five years ago is 5 years":
    check sa.formatAge(yearsAgo(5)) == some("5 years")

  # 15.2
  test "five days ago is 5 days":
    check sa.formatAge(isoDate(now().utc - 5.days)) == some("5 days")

  # 23.1
  test "stage of today is Newborn":
    check sa.formatStage(isoDate(now().utc)) == some("Newborn")

  # 23.2
  test "stage of five years ago is Child":
    check sa.formatStage(yearsAgo(5)) == some("Child")

  # 23.3
  test "stage of forty-five years ago is Adult":
    check sa.formatStage(yearsAgo(45)) == some("Adult")


# ================================================================
# Null / edge cases
# ================================================================
suite "Null / edge cases":
  let sa = newSayableAge(EN)

  # 1.1
  test "returns none for empty input":
    check sa.formatAge("", "2025-06-15").isNone

  # 1.4
  test "returns none for future date of birth":
    check sa.formatAge("2025-07-01", "2025-06-15").isNone

  # 1.3
  test "returns none for empty string":
    check sa.formatAge("", "2025-06-15").isNone

  # 1.5
  test "exactly 500 years is allowed":
    check sa.formatAge("1525-06-15", "2025-06-15") == some("500 years")

  # 1.6
  test "501 years exceeds max age":
    check sa.formatAge("1524-06-15", "2025-06-15").isNone

  # 1.7
  test "1000 years exceeds max age":
    check sa.formatAge("1025-06-15", "2025-06-15").isNone


# ================================================================
# Days tier: 0-6 days
# ================================================================
suite "Days tier":
  let sa = newSayableAge(EN)

  # 2.1
  test "born today":
    check sa.formatAge("2025-06-15", "2025-06-15") == some("Newborn")

  # 2.2
  test "born 1 day ago singular":
    check sa.formatAge("2025-06-14", "2025-06-15") == some("1 day")

  # 2.3
  test "born 3 days ago":
    check sa.formatAge("2025-06-12", "2025-06-15") == some("3 days")

  # 2.4
  test "born 6 days ago":
    check sa.formatAge("2025-06-09", "2025-06-15") == some("6 days")

  # 2.5
  test "never shows 7+ days":
    check sa.formatAge("2025-06-08", "2025-06-15") == some("1 week")


# ================================================================
# Weeks+days tier: 7 days to <3 calendar months
# ================================================================
suite "Weeks+days tier":
  let sa = newSayableAge(EN)

  # 3.1
  test "7 days":
    check sa.formatAge("2025-06-08", "2025-06-15") == some("1 week")

  # 3.2
  test "8 days":
    check sa.formatAge("2025-06-07", "2025-06-15") == some("1 week, 1 day")

  # 3.3
  test "9 days":
    check sa.formatAge("2025-06-06", "2025-06-15") == some("1 week, 2 days")

  # 3.4
  test "13 days":
    check sa.formatAge("2025-06-02", "2025-06-15") == some("1 week, 6 days")

  # 3.5
  test "14 days":
    check sa.formatAge("2025-06-01", "2025-06-15") == some("2 weeks")

  # 3.6
  test "15 days":
    check sa.formatAge("2025-05-31", "2025-06-15") == some("2 weeks, 1 day")

  # 3.7
  test "20 days":
    check sa.formatAge("2025-05-26", "2025-06-15") == some("2 weeks, 6 days")

  # 3.8
  test "21 days":
    check sa.formatAge("2025-05-25", "2025-06-15") == some("3 weeks")

  # 3.9
  test "at 1 calendar month still shows weeks days":
    check sa.formatAge("2025-05-15", "2025-06-15") == some("4 weeks, 3 days")

  # 3.10
  test "at 2 calendar months still shows weeks days":
    check sa.formatAge("2025-04-15", "2025-06-15") == some("8 weeks, 5 days")

  # 3.11
  test "one day before 3 month birthday":
    check sa.formatAge("2025-03-15", "2025-06-14") == some("13 weeks")

  # 3.12
  test "on 3 month birthday switches to months":
    check sa.formatAge("2025-03-15", "2025-06-15") == some("3 months")


# ================================================================
# Month boundaries
# ================================================================
suite "Month boundary - standard":
  let sa = newSayableAge(EN)

  # 4.1
  test "born jan1 check apr1":
    check sa.formatAge("2025-01-01", "2025-04-01") == some("3 months")

  # 4.2
  test "born jan1 check mar31 still weeks":
    let result = sa.formatAge("2025-01-01", "2025-03-31")
    check result.isSome
    check "weeks" in result.get

  # 4.3
  test "born jun15 check sep15":
    check sa.formatAge("2025-06-15", "2025-09-15") == some("3 months")

  # 4.4
  test "born jun15 check sep14 still weeks":
    let result = sa.formatAge("2025-06-15", "2025-09-14")
    check result.isSome
    check "weeks" in result.get

  # 4.5
  test "born jun15 check dec15":
    check sa.formatAge("2025-06-15", "2025-12-15") == some("6 months")


suite "Month boundary - Feb nonleap":
  let sa = newSayableAge(EN)

  # 5.1
  test "born jan31 check feb28 nonleap":
    check sa.formatAge("2025-01-31", "2025-02-28") == some("4 weeks")

  # 5.2
  test "born jan31 check apr30":
    check sa.formatAge("2025-01-31", "2025-04-30") == some("3 months")

  # 5.3
  test "born jan31 check apr29 still weeks":
    let result = sa.formatAge("2025-01-31", "2025-04-29")
    check result.isSome
    check "weeks" in result.get

  # 5.4
  test "born feb1 check may1":
    check sa.formatAge("2025-02-01", "2025-05-01") == some("3 months")

  # 5.5
  test "born feb1 check apr30 still weeks":
    let result = sa.formatAge("2025-02-01", "2025-04-30")
    check result.isSome
    check "weeks" in result.get


suite "Month boundary - Feb leap":
  let sa = newSayableAge(EN)

  # 6.1
  test "born jan31 check feb29 leap":
    check sa.formatAge("2024-01-31", "2024-02-29") == some("4 weeks, 1 day")

  # 6.2
  test "born jan31 check feb28 leap":
    check sa.formatAge("2024-01-31", "2024-02-28") == some("4 weeks")

  # 6.3
  test "born jan31 check apr30 leap":
    check sa.formatAge("2024-01-31", "2024-04-30") == some("3 months")

  # 6.4
  test "born jan30 check feb29 leap still weeks":
    let result = sa.formatAge("2024-01-30", "2024-02-29")
    check result.isSome
    check "weeks" in result.get

  # 6.5
  test "born jan30 check feb28 leap still weeks":
    let result = sa.formatAge("2024-01-30", "2024-02-28")
    check result.isSome
    check "weeks" in result.get


suite "Month boundary - 30 day months":
  let sa = newSayableAge(EN)

  # 7.1
  test "born mar31 check jun30":
    check sa.formatAge("2025-03-31", "2025-06-30") == some("3 months")

  # 7.2
  test "born mar31 check jun29 still weeks":
    let result = sa.formatAge("2025-03-31", "2025-06-29")
    check result.isSome
    check "weeks" in result.get

  # 7.3
  test "born aug31 check nov30":
    check sa.formatAge("2025-08-31", "2025-11-30") == some("3 months")

  # 7.4
  test "born aug31 check nov29 still weeks":
    let result = sa.formatAge("2025-08-31", "2025-11-29")
    check result.isSome
    check "weeks" in result.get


suite "Month boundary - leap year baby":
  let sa = newSayableAge(EN)

  # 8.1
  test "born feb29 check may29":
    check sa.formatAge("2024-02-29", "2024-05-29") == some("3 months")

  # 8.2
  test "born feb29 check may28 still weeks":
    let result = sa.formatAge("2024-02-29", "2024-05-28")
    check result.isSome
    check "weeks" in result.get

  # 8.3
  test "born feb29 check feb28 nonleap":
    check sa.formatAge("2024-02-29", "2025-02-28") == some("12 months")

  # 8.4
  test "born feb29 check mar1 next year":
    check sa.formatAge("2024-02-29", "2025-03-01") == some("12 months")


# ================================================================
# Months tier: 3-23 months
# ================================================================
suite "Months tier":
  let sa = newSayableAge(EN)

  # 9.1
  test "3 months at transition":
    check sa.formatAge("2025-01-15", "2025-04-15") == some("3 months")

  # 9.2
  test "6 months":
    check sa.formatAge("2025-01-15", "2025-07-15") == some("6 months")

  # 9.3
  test "12 months not 1 year":
    check sa.formatAge("2024-06-15", "2025-06-15") == some("12 months")

  # 9.4
  test "23 months upper boundary":
    check sa.formatAge("2024-01-15", "2025-12-15") == some("23 months")

  # 9.5
  test "one day before month boundary":
    check sa.formatAge("2025-01-15", "2025-07-14") == some("5 months")

  # 9.6
  test "crossing year boundary":
    check sa.formatAge("2024-11-10", "2025-04-10") == some("5 months")


# ================================================================
# Years+months tier: 24-35 months
# ================================================================
suite "Years+months tier":
  let sa = newSayableAge(EN)

  # 10.1
  test "2 years at 24 months":
    check sa.formatAge("2023-06-15", "2025-06-15") == some("2 years")

  # 10.2
  test "2 years 1 month singular":
    check sa.formatAge("2023-06-15", "2025-07-15") == some("2 years, 1 month")

  # 10.3
  test "2 years 6 months":
    check sa.formatAge("2023-06-15", "2025-12-15") == some("2 years, 6 months")

  # 10.4
  test "2 years 11 months upper boundary":
    check sa.formatAge("2023-06-15", "2026-05-15") == some("2 years, 11 months")

  # 10.5
  test "one day before 24 months stays in months":
    check sa.formatAge("2023-06-15", "2025-06-14") == some("23 months")


# ================================================================
# Half-year tier: 3-6 years
# ================================================================
suite "Half-year tier":
  let sa = newSayableAge(EN)

  # 11.1
  test "3 years exact":
    check sa.formatAge("2022-06-15", "2025-06-15") == some("3 years")

  # 11.2
  test "3 years 5 months":
    check sa.formatAge("2022-06-15", "2025-11-15") == some("3 years")

  # 11.3
  test "3 and half years":
    check sa.formatAge("2022-06-15", "2025-12-15") == some("3\xC2\xBD years")

  # 11.4
  test "3 years 11 months":
    check sa.formatAge("2022-06-15", "2026-05-15") == some("3\xC2\xBD years")

  # 11.5
  test "4 years exact":
    check sa.formatAge("2021-06-15", "2025-06-15") == some("4 years")

  # 11.6
  test "4 and half years":
    check sa.formatAge("2021-06-15", "2025-12-15") == some("4\xC2\xBD years")

  # 11.7
  test "5 years exact":
    check sa.formatAge("2020-06-15", "2025-06-15") == some("5 years")

  # 11.8
  test "5 and half years":
    check sa.formatAge("2020-06-15", "2026-02-15") == some("5\xC2\xBD years")

  # 11.9
  test "6 years exact":
    check sa.formatAge("2019-06-15", "2025-06-15") == some("6 years")

  # 11.10
  test "6 and half years":
    check sa.formatAge("2019-06-15", "2025-12-15") == some("6\xC2\xBD years")

  # 11.11
  test "6 years 11 months":
    check sa.formatAge("2019-06-15", "2026-05-15") == some("6\xC2\xBD years")

  # 11.12
  test "one day before 3rd birthday":
    check sa.formatAge("2022-06-15", "2025-06-14") == some("2 years, 11 months")


# ================================================================
# Integer tier: 7+ years
# ================================================================
suite "Integer tier":
  let sa = newSayableAge(EN)

  # 12.1
  test "7 years exact":
    check sa.formatAge("2018-06-15", "2025-06-15") == some("7 years")

  # 12.2
  test "7 years 6 months no half":
    check sa.formatAge("2018-03-20", "2025-06-15") == some("7 years")

  # 12.3
  test "45 years adult":
    check sa.formatAge("1980-01-01", "2025-06-15") == some("45 years")


# ================================================================
# Cross-year transitions with short months
# ================================================================
suite "Cross-year with Feb":
  let sa = newSayableAge(EN)

  # 13.1
  test "born dec31 check mar31":
    check sa.formatAge("2024-12-31", "2025-03-31") == some("3 months")

  # 13.2
  test "born dec31 check mar30 still weeks":
    let result = sa.formatAge("2024-12-31", "2025-03-30")
    check result.isSome
    check "weeks" in result.get

  # 13.3
  test "born nov30 check feb28":
    check sa.formatAge("2024-11-30", "2025-02-28") == some("3 months")

  # 13.4
  test "born nov30 check feb27 still weeks":
    let result = sa.formatAge("2024-11-30", "2025-02-27")
    check result.isSome
    check "weeks" in result.get


# ================================================================
# Regression: born on 31st tracked through multiple months
# ================================================================
suite "Born on 31st progression":
  let sa = newSayableAge(EN)

  # 14.1
  test "jan31 to apr30":
    check sa.formatAge("2025-01-31", "2025-04-30") == some("3 months")

  # 14.2
  test "jan31 to may31":
    check sa.formatAge("2025-01-31", "2025-05-31") == some("4 months")

  # 14.3
  test "jan31 to jun30 clamped":
    check sa.formatAge("2025-01-31", "2025-06-30") == some("5 months")

  # 14.4
  test "jan31 to jul1 before birthday":
    check sa.formatAge("2025-01-31", "2025-07-01") == some("5 months")

  # 14.5
  test "jan31 to jul31":
    check sa.formatAge("2025-01-31", "2025-07-31") == some("6 months")


# ================================================================
# format_stage
# ================================================================
suite "Stage edge cases":
  let sa = newSayableAge(EN)

  # 16.1
  test "returns none for empty":
    check sa.formatStage("", "2025-06-15").isNone

  # 16.4
  test "returns none for future dob":
    check sa.formatStage("2025-07-01", "2025-06-15").isNone

  # 16.3
  test "returns none for empty string":
    check sa.formatStage("", "2025-06-15").isNone

  # 16.5
  test "exactly 500 years returns adult":
    check sa.formatStage("1525-06-15", "2025-06-15") == some("Adult")

  # 16.6
  test "501 years exceeds max age":
    check sa.formatStage("1524-06-15", "2025-06-15").isNone


suite "Stage newborn":
  let sa = newSayableAge(EN)

  # 17.1
  test "born today":
    check sa.formatStage("2025-06-15", "2025-06-15") == some("Newborn")

  # 17.2
  test "1 day old":
    check sa.formatStage("2025-06-14", "2025-06-15") == some("Newborn")

  # 17.3
  test "3 weeks old":
    check sa.formatStage("2025-05-25", "2025-06-15") == some("Newborn")

  # 17.4
  test "1 month old":
    check sa.formatStage("2025-05-15", "2025-06-15") == some("Newborn")

  # 17.5
  test "1 month 29 days still newborn":
    check sa.formatStage("2025-04-16", "2025-06-15") == some("Newborn")

  # 17.6
  test "exactly 2 months becomes infant":
    check sa.formatStage("2025-04-15", "2025-06-15") == some("Infant")


suite "Stage infant":
  let sa = newSayableAge(EN)

  # 18.1
  test "2 months":
    check sa.formatStage("2025-04-15", "2025-06-15") == some("Infant")

  # 18.2
  test "6 months":
    check sa.formatStage("2024-12-15", "2025-06-15") == some("Infant")

  # 18.3
  test "11 months":
    check sa.formatStage("2024-07-15", "2025-06-15") == some("Infant")

  # 18.4
  test "exactly 12 months becomes toddler":
    check sa.formatStage("2024-06-15", "2025-06-15") == some("Toddler")


suite "Stage toddler":
  let sa = newSayableAge(EN)

  # 19.1
  test "12 months":
    check sa.formatStage("2024-06-15", "2025-06-15") == some("Toddler")

  # 19.2
  test "18 months":
    check sa.formatStage("2024-01-15", "2025-07-15") == some("Toddler")

  # 19.3
  test "24 months":
    check sa.formatStage("2023-06-15", "2025-06-15") == some("Toddler")

  # 19.4
  test "35 months still toddler":
    check sa.formatStage("2023-06-15", "2026-05-15") == some("Toddler")

  # 19.5
  test "exactly 36 months becomes child":
    check sa.formatStage("2022-06-15", "2025-06-15") == some("Child")


suite "Stage child":
  let sa = newSayableAge(EN)

  # 20.1
  test "3 years":
    check sa.formatStage("2022-06-15", "2025-06-15") == some("Child")

  # 20.2
  test "4 years":
    check sa.formatStage("2021-06-15", "2025-06-15") == some("Child")

  # 20.3
  test "6 years":
    check sa.formatStage("2019-06-15", "2025-06-15") == some("Child")

  # 20.4
  test "9 years":
    check sa.formatStage("2016-06-15", "2025-06-15") == some("Child")

  # 20.5
  test "12 years 11 months still child":
    check sa.formatStage("2013-06-15", "2026-05-15") == some("Child")

  # 20.6
  test "exactly 13 years becomes teenager":
    check sa.formatStage("2012-06-15", "2025-06-15") == some("Teenager")


suite "Stage teenager":
  let sa = newSayableAge(EN)

  # 21.1
  test "13 years":
    check sa.formatStage("2012-06-15", "2025-06-15") == some("Teenager")

  # 21.2
  test "15 years":
    check sa.formatStage("2010-06-15", "2025-06-15") == some("Teenager")

  # 21.3
  test "17 years 11 months still teenager":
    check sa.formatStage("2008-06-15", "2026-05-15") == some("Teenager")

  # 21.4
  test "exactly 18 years becomes adult":
    check sa.formatStage("2007-06-15", "2025-06-15") == some("Adult")


suite "Stage adult":
  let sa = newSayableAge(EN)

  # 22.1
  test "18 years":
    check sa.formatStage("2007-06-15", "2025-06-15") == some("Adult")

  # 22.2
  test "25 years":
    check sa.formatStage("2000-06-15", "2025-06-15") == some("Adult")

  # 22.3
  test "45 years":
    check sa.formatStage("1980-01-01", "2025-06-15") == some("Adult")


# ================================================================
# SayableAge class
# ================================================================
suite "SayableAge English":
  # 24.1, 24.2, 24.3, 24.4, 24.5, 24.6, 24.7
  test "formatAge delegates":
    let sa = newSayableAge(EN)
    check sa.formatAge("2025-06-15", "2025-06-15") == some("Newborn")
    check sa.formatAge("2025-06-12", "2025-06-15") == some("3 days")
    check sa.formatAge("2025-06-07", "2025-06-15") == some("1 week, 1 day")
    check sa.formatAge("2025-01-15", "2025-07-15") == some("6 months")
    check sa.formatAge("2023-06-15", "2025-07-15") == some("2 years, 1 month")
    check sa.formatAge("2022-06-15", "2025-12-15") == some("3\xC2\xBD years")
    check sa.formatAge("2018-06-15", "2025-06-15") == some("7 years")

  # 24.8, 24.9, 24.10, 24.11, 24.12, 24.13
  test "formatStage delegates":
    let sa = newSayableAge(EN)
    check sa.formatStage("2025-06-15", "2025-06-15") == some("Newborn")
    check sa.formatStage("2025-01-15", "2025-06-15") == some("Infant")
    check sa.formatStage("2024-06-15", "2025-06-15") == some("Toddler")
    check sa.formatStage("2022-06-15", "2025-06-15") == some("Child")
    check sa.formatStage("2012-06-15", "2025-06-15") == some("Teenager")
    check sa.formatStage("2007-06-15", "2025-06-15") == some("Adult")

  # 24.14, 24.15
  test "returns none for invalid":
    let sa = newSayableAge(EN)
    check sa.formatAge("", "2025-06-15").isNone
    check sa.formatStage("", "2025-06-15").isNone


# ================================================================
# Compactness levels
# ================================================================
suite "Compactness short":
  let sa = newSayableAge(EN, cShort)

  # 26.1
  test "days":
    check sa.formatAge("2025-06-12", "2025-06-15") == some("3 d")

  # 26.2
  test "weeks":
    check sa.formatAge("2025-06-08", "2025-06-15") == some("1 wk")

  # 26.3
  test "weeks days":
    check sa.formatAge("2025-06-07", "2025-06-15") == some("1 wk, 1 d")

  # 26.4
  test "months":
    check sa.formatAge("2025-01-15", "2025-07-15") == some("6 mo")

  # 26.5
  test "years months":
    check sa.formatAge("2023-06-15", "2025-07-15") == some("2 yr, 1 mo")

  # 26.6
  test "half years":
    check sa.formatAge("2022-06-15", "2025-12-15") == some("3\xC2\xBD yr")

  # 26.7
  test "integer years":
    check sa.formatAge("2018-06-15", "2025-06-15") == some("7 yr")

  # 26.8
  test "just born unchanged":
    check sa.formatAge("2025-06-15", "2025-06-15") == some("Newborn")

  # 26.9
  test "stages unchanged":
    check sa.formatStage("2025-01-15", "2025-06-15") == some("Infant")


suite "Compactness compact":
  let sa = newSayableAge(EN, cCompact)

  # 27.1
  test "days":
    check sa.formatAge("2025-06-12", "2025-06-15") == some("3d")

  # 27.2
  test "weeks":
    check sa.formatAge("2025-06-08", "2025-06-15") == some("1w")

  # 27.3
  test "weeks days no delimiter":
    check sa.formatAge("2025-06-07", "2025-06-15") == some("1w1d")

  # 27.4
  test "months":
    check sa.formatAge("2025-01-15", "2025-07-15") == some("6m")

  # 27.5
  test "years months no delimiter":
    check sa.formatAge("2023-06-15", "2025-07-15") == some("2y1m")

  # 27.6
  test "half years":
    check sa.formatAge("2022-06-15", "2025-12-15") == some("3\xC2\xBD" & "y")

  # 27.7
  test "integer years":
    check sa.formatAge("2018-06-15", "2025-06-15") == some("7y")

  # 27.8
  test "just born unchanged":
    check sa.formatAge("2025-06-15", "2025-06-15") == some("Newborn")


# ================================================================
# resolve_stage helper
# ================================================================
suite "resolveStage":
  test "plain string returns as is":
    check resolveStage(stageNeutral("Newborn")) == "Newborn"

  test "plain string ignores gender":
    check resolveStage(stageNeutral("Newborn"), "f") == "Newborn"
    check resolveStage(stageNeutral("Newborn"), "m") == "Newborn"

  test "gendered dict returns masculine by default":
    let label = stageGendered("Adulto", "Adulta")
    check resolveStage(label) == "Adulto"

  test "gendered dict returns masculine for m":
    let label = stageGendered("Adulto", "Adulta")
    check resolveStage(label, "m") == "Adulto"

  test "gendered dict returns feminine for f":
    let label = stageGendered("Adulto", "Adulta")
    check resolveStage(label, "f") == "Adulta"


# ================================================================
# Locale-specific tests
# ================================================================
suite "Locale Hebrew":
  let sa = newSayableAge(HE)

  # 29.1
  test "just born":
    check sa.formatAge("2025-06-15", "2025-06-15") == some("\xD7\xA8\xD7\xA7 \xD7\xA0\xD7\x95\xD7\x9C\xD7\x93")

  # 29.4
  test "two weeks dual":
    check sa.formatAge("2025-06-01", "2025-06-15") == some("\xD7\xA9\xD7\x91\xD7\x95\xD7\xA2\xD7\x99\xD7\x99\xD7\x9D")


suite "Locale Macedonian":
  let sa = newSayableAge(MK)

  # 29.15
  test "just born":
    check sa.formatAge("2025-06-15", "2025-06-15") == some("\xD0\x9D\xD0\xBE\xD0\xB2\xD0\xBE\xD1\x80\xD0\xBE\xD0\xB4\xD0\xB5\xD0\xBD\xD1\x87\xD0\xB5")


suite "Locale Swahili":
  let sa = newSayableAge(SW)

  # 29.22
  test "just born":
    check sa.formatAge("2025-06-15", "2025-06-15") == some("Mzaliwa mpya")

  # 29.23
  test "one day":
    check sa.formatAge("2025-06-14", "2025-06-15") == some("siku 1")


suite "Locale Indonesian":
  let sa = newSayableAge(ID)

  # 29.28
  test "just born":
    check sa.formatAge("2025-06-15", "2025-06-15") == some("Baru lahir")


suite "Locale Amharic":
  let sa = newSayableAge(AM)

  # 29.34
  test "just born":
    check sa.formatAge("2025-06-15", "2025-06-15") == some("\xE1\x8A\xA0\xE1\x8B\xB2\xE1\x88\xB5 \xE1\x8B\xA8\xE1\x89\xB0\xE1\x8B\x88\xE1\x88\x88\xE1\x8B\xB0")


# ================================================================
# Section 25: i18n — locale with all plural features
# ================================================================
suite "Section 25: i18n — locale with all plural features":
  # 25.1
  test "25.1 es justBorn":
    check newSayableAge(ES).formatAge("2025-06-15", "2025-06-15") == some("Reci\xC3\xA9n nacido")
  # 25.2
  test "25.2 es Singular day":
    check newSayableAge(ES).formatAge("2025-06-14", "2025-06-15") == some("1 d\xC3\xADa")
  # 25.3
  test "25.3 es Plural days":
    check newSayableAge(ES).formatAge("2025-06-12", "2025-06-15") == some("3 d\xC3\xADas")
  # 25.4
  test "25.4 es Singular week":
    check newSayableAge(ES).formatAge("2025-06-08", "2025-06-15") == some("1 semana")
  # 25.5
  test "25.5 es Compound":
    check newSayableAge(ES).formatAge("2025-06-07", "2025-06-15") == some("1 semana, 1 d\xC3\xADa")
  # 25.6
  test "25.6 es Plural compound":
    check newSayableAge(ES).formatAge("2025-05-26", "2025-06-15") == some("2 semanas, 6 d\xC3\xADas")
  # 25.7
  test "25.7 es Months":
    check newSayableAge(ES).formatAge("2025-01-15", "2025-07-15") == some("6 meses")
  # 25.8
  test "25.8 es Singular month":
    check newSayableAge(ES).formatAge("2023-06-15", "2025-07-15") == some("2 a\xC3\xB1os, 1 mes")
  # 25.9
  test "25.9 es Years+months":
    check newSayableAge(ES).formatAge("2023-06-15", "2025-12-15") == some("2 a\xC3\xB1os, 6 meses")
  # 25.10
  test "25.10 es Half marker":
    check newSayableAge(ES).formatAge("2022-06-15", "2025-12-15") == some("3 a\xC3\xB1os y medio")
  # 25.11
  test "25.11 es No half":
    check newSayableAge(ES).formatAge("2022-06-15", "2025-06-15") == some("3 a\xC3\xB1os")
  # 25.12
  test "25.12 es 7+ years":
    check newSayableAge(ES).formatAge("2018-06-15", "2025-06-15") == some("7 a\xC3\xB1os")
  # 25.13
  test "25.13 es Stage label":
    check newSayableAge(ES).formatStage("2025-06-15", "2025-06-15") == some("Reci\xC3\xA9n nacido")
  # 25.14
  test "25.14 es ":
    check newSayableAge(ES).formatStage("2025-01-15", "2025-06-15") == some("Beb\xC3\xA9")
  # 25.15
  test "25.15 es ":
    check newSayableAge(ES).formatStage("2024-06-15", "2025-06-15") == some("Ni\xC3\xB1o peque\xC3\xB1o")
  # 25.16
  test "25.16 es ":
    check newSayableAge(ES).formatStage("2022-06-15", "2025-06-15") == some("Ni\xC3\xB1o")
  # 25.17
  test "25.17 es ":
    check newSayableAge(ES).formatStage("2012-06-15", "2025-06-15") == some("Adolescente")
  # 25.18
  test "25.18 es ":
    check newSayableAge(ES).formatStage("2007-06-15", "2025-06-15") == some("Adulto")
  # 25.19
  test "25.19 es Null handling":
    check newSayableAge(ES).formatAge("", "2025-06-15") == none(string)
  # 25.20
  test "25.20 es Null handling":
    check newSayableAge(ES).formatStage("", "2025-06-15") == none(string)

# ================================================================
# Section 29: Locale-specific edge cases — plural rules
# ================================================================
suite "Section 29: Locale-specific edge cases — plural rules":
  # 29.2
  test "29.2 he 1 day — one form":
    check newSayableAge(HE).formatAge("2025-06-14", "2025-06-15") == some("\xD7\x99\xD7\x95\xD7\x9D")
  # 29.3
  test "29.3 he 3 days — other form":
    check newSayableAge(HE).formatAge("2025-06-12", "2025-06-15") == some("3 \xD7\x99\xD7\x9E\xD7\x99\xD7\x9D")
  # 29.5
  test "29.5 he 3 weeks — other form":
    check newSayableAge(HE).formatAge("2025-05-25", "2025-06-15") == some("3 \xD7\xA9\xD7\x91\xD7\x95\xD7\xA2\xD7\x95\xD7\xAA")
  # 29.6
  test "29.6 he 6 months — other":
    check newSayableAge(HE).formatAge("2025-01-15", "2025-07-15") == some("6 \xD7\x97\xD7\x95\xD7\x93\xD7\xA9\xD7\x99\xD7\x9D")
  # 29.7
  test "29.7 he 3 months — other":
    check newSayableAge(HE).formatAge("2025-03-15", "2025-06-15") == some("3 \xD7\x97\xD7\x95\xD7\x93\xD7\xA9\xD7\x99\xD7\x9D")
  # 29.8
  test "29.8 he 2y dual + 1m one":
    check newSayableAge(HE).formatAge("2023-06-15", "2025-07-15") == some("\xD7\xA9\xD7\xA0\xD7\xAA\xD7\x99\xD7\x99\xD7\x9D, \xD7\x97\xD7\x95\xD7\x93\xD7\xA9")
  # 29.9
  test "29.9 he 3½ years — half marker":
    check newSayableAge(HE).formatAge("2022-06-15", "2025-12-15") == some("3 \xD7\xA9\xD7\xA0\xD7\x99\xD7\x9D \xD7\x95\xD7\x97\xD7\xA6\xD7\x99")
  # 29.10
  test "29.10 he 7+ years — other":
    check newSayableAge(HE).formatAge("2018-06-15", "2025-06-15") == some("7 \xD7\xA9\xD7\xA0\xD7\x99\xD7\x9D")
  # 29.11
  test "29.11 he masculine newborn":
    check newSayableAge(HE).formatStage("2025-06-15", "2025-06-15", "m") == some("\xD7\xA8\xD7\xA7 \xD7\xA0\xD7\x95\xD7\x9C\xD7\x93")
  # 29.12
  test "29.12 he feminine newborn":
    check newSayableAge(HE).formatStage("2025-06-15", "2025-06-15", "f") == some("\xD7\xA8\xD7\xA7 \xD7\xA0\xD7\x95\xD7\x9C\xD7\x93\xD7\x94")
  # 29.13
  test "29.13 he masculine adult":
    check newSayableAge(HE).formatStage("2007-06-15", "2025-06-15", "m") == some("\xD7\x9E\xD7\x91\xD7\x95\xD7\x92\xD7\xA8")
  # 29.14
  test "29.14 he feminine adult":
    check newSayableAge(HE).formatStage("2007-06-15", "2025-06-15", "f") == some("\xD7\x9E\xD7\x91\xD7\x95\xD7\x92\xD7\xA8\xD7\xAA")
  # 29.16
  test "29.16 mk 1 day — one":
    check newSayableAge(MK).formatAge("2025-06-14", "2025-06-15") == some("1 \xD0\xB4\xD0\xB5\xD0\xBD")
  # 29.17
  test "29.17 mk 3 days — other":
    check newSayableAge(MK).formatAge("2025-06-12", "2025-06-15") == some("3 \xD0\xB4\xD0\xB5\xD0\xBD\xD0\xB0")
  # 29.18
  test "29.18 mk 6 months — other":
    check newSayableAge(MK).formatAge("2025-01-15", "2025-07-15") == some("6 \xD0\xBC\xD0\xB5\xD1\x81\xD0\xB5\xD1\x86\xD0\xB8")
  # 29.19
  test "29.19 mk 2y1m — one for month":
    check newSayableAge(MK).formatAge("2023-06-15", "2025-07-15") == some("2 \xD0\xB3\xD0\xBE\xD0\xB4\xD0\xB8\xD0\xBD\xD0\xB8, 1 \xD0\xBC\xD0\xB5\xD1\x81\xD0\xB5\xD1\x86")
  # 29.20
  test "29.20 mk 3½ years — half marker":
    check newSayableAge(MK).formatAge("2022-06-15", "2025-12-15") == some("3 \xD0\xB3\xD0\xBE\xD0\xB4\xD0\xB8\xD0\xBD\xD0\xB8 \xD0\xB8 \xD0\xBF\xD0\xBE\xD0\xBB")
  # 29.21
  test "29.21 mk 7+ years — other":
    check newSayableAge(MK).formatAge("2018-06-15", "2025-06-15") == some("7 \xD0\xB3\xD0\xBE\xD0\xB4\xD0\xB8\xD0\xBD\xD0\xB8")
  # 29.24
  test "29.24 sw 3 days — other (same word)":
    check newSayableAge(SW).formatAge("2025-06-12", "2025-06-15") == some("siku 3")
  # 29.25
  test "29.25 sw 6 months — other (noun class)":
    check newSayableAge(SW).formatAge("2025-01-15", "2025-07-15") == some("miezi 6")
  # 29.26
  test "29.26 sw 2y other + 1m one":
    check newSayableAge(SW).formatAge("2023-06-15", "2025-07-15") == some("miaka 2, mwezi 1")
  # 29.27
  test "29.27 sw 3½ years — half marker":
    check newSayableAge(SW).formatAge("2022-06-15", "2025-12-15") == some("miaka 3 na nusu")
  # 29.29
  test "29.29 id 1 day":
    check newSayableAge(ID).formatAge("2025-06-14", "2025-06-15") == some("1 hari")
  # 29.30
  test "29.30 id 3 days (same unit)":
    check newSayableAge(ID).formatAge("2025-06-12", "2025-06-15") == some("3 hari")
  # 29.31
  test "29.31 id 6 months":
    check newSayableAge(ID).formatAge("2025-01-15", "2025-07-15") == some("6 bulan")
  # 29.32
  test "29.32 id 3½ years — half marker":
    check newSayableAge(ID).formatAge("2022-06-15", "2025-12-15") == some("3 setengah tahun")
  # 29.33
  test "29.33 id 7+ years":
    check newSayableAge(ID).formatAge("2018-06-15", "2025-06-15") == some("7 tahun")
  # 29.35
  test "29.35 am 1 day — one form":
    check newSayableAge(AM).formatAge("2025-06-14", "2025-06-15") == some("1 \xE1\x89\x80\xE1\x8A\x95")
  # 29.36
  test "29.36 am 3 days — other form":
    check newSayableAge(AM).formatAge("2025-06-12", "2025-06-15") == some("3 \xE1\x89\x80\xE1\x8A\x93\xE1\x89\xB5")
  # 29.37
  test "29.37 am 1w1d with Ethiopic delimiter":
    check newSayableAge(AM).formatAge("2025-06-07", "2025-06-15") == some("1 \xE1\x88\xB3\xE1\x88\x9D\xE1\x8A\x95\xE1\x89\xB5\xE1\x8D\xA3 1 \xE1\x89\x80\xE1\x8A\x95")
  # 29.38
  test "29.38 am 6 months — other form":
    check newSayableAge(AM).formatAge("2025-01-15", "2025-07-15") == some("6 \xE1\x8B\x88\xE1\x88\xAB\xE1\x89\xB5")
  # 29.39
  test "29.39 am 3½ years — half marker":
    check newSayableAge(AM).formatAge("2022-06-15", "2025-12-15") == some("3 \xE1\x8B\x93\xE1\x88\x98\xE1\x89\xB3\xE1\x89\xB5 \xE1\x89\xB0\xE1\x8A\xA9\xE1\x88\x8D")

# ================================================================
# Locale lookup
# ================================================================
suite "Locale lookup":
  # 30.1
  test "known locale en":
    let loc = getLocale("en")
    check loc.isSome
    check loc.get.code == "en"

  # 30.2
  test "known locale fr":
    let loc = getLocale("fr")
    check loc.isSome
    check loc.get.code == "fr"

  # 30.3
  test "unknown code":
    check getLocale("xx").isNone

  # 30.4
  test "empty string":
    check getLocale("").isNone

  # 30.5
  test "case sensitive":
    check getLocale("EN").isNone

# ================================================================
# Section 31: Weeks and days across month ends
# ================================================================
suite "Section 31: Weeks and days across month ends":
  # 31.1
  test "31.1 88 days across a 28-day February":
    check newSayableAge(getLocale("en").get).formatAge("2016-12-31", "2017-03-29") == some("12 weeks, 4 days")

  # 31.2
  test "31.2 90 days across a year end into a leap year":
    check newSayableAge(getLocale("en").get).formatAge("1991-11-27", "1992-02-25") == some("12 weeks, 6 days")

  # 31.3
  test "31.3 33 days across a year end":
    check newSayableAge(getLocale("en").get).formatAge("2020-11-30", "2021-01-02") == some("4 weeks, 5 days")

  # 31.4
  test "31.4 Compact form of 31.1":
    check newSayableAge(getLocale("en").get, cCompact).formatAge("2016-12-31", "2017-03-29") == some("12w4d")


# ================================================================
# Section 32: Half years take their plural form from whole years
# ================================================================
suite "Section 32: Half years take their plural form from whole years":
  # 32.1
  test "32.1 Polish 3 is 'few'":
    check newSayableAge(getLocale("pl").get).formatAge("2021-06-15", "2025-01-15") == some("3 i pół lata")

  # 32.2
  test "32.2 Polish 5 is 'many'":
    check newSayableAge(getLocale("pl").get, cShort).formatAge("2020-06-15", "2025-12-15") == some("5 i pół lat")

  # 32.3
  test "32.3 Tachelhit 6 is 'few'":
    check newSayableAge(getLocale("shi").get).formatAge("2005-06-08", "2012-06-07") == some("6 \xE2\xB5\x89\xE2\xB5\x99\xE2\xB4\xB3\xE2\xB4\xB3\xE2\xB5\xAF\xE2\xB4\xB0\xE2\xB5\x99\xE2\xB5\x8F \xE2\xB4\xB7 \xE2\xB5\x93\xE2\xB5\xA3\xE2\xB4\xB3\xE2\xB5\x8F")


# ================================================================
# Section 33: Input validation
# ================================================================
suite "Section 33: Input validation":
  # 33.1
  test "33.1 February 30 doesn't exist":
    check newSayableAge(getLocale("en").get).formatAge("2025-02-30", "2032-06-25").isNone

  # 33.2
  test "33.2 Month 13":
    check newSayableAge(getLocale("en").get).formatAge("2025-13-01", "2027-01-31").isNone

  # 33.3
  test "33.3 February 29 in a non-leap year":
    check newSayableAge(getLocale("en").get).formatAge("2023-02-29", "2025-03-01").isNone

  # 33.4
  test "33.4 Day 00":
    check newSayableAge(getLocale("en").get).formatAge("2025-06-00", "2027-02-25").isNone

  # 33.5
  test "33.5 Unpadded month and day":
    check newSayableAge(getLocale("en").get).formatAge("2025-6-1", "2027-02-25").isNone

  # 33.6
  test "33.6 Surrounding whitespace":
    check newSayableAge(getLocale("en").get).formatAge(" 2025-06-01", "2027-02-25").isNone

  # 33.7
  test "33.7 A datetime is not a date":
    check newSayableAge(getLocale("en").get).formatAge("2025-06-15T10:00:00", "2027-02-25").isNone

  # 33.8
  test "33.8 Invalid asOf":
    check newSayableAge(getLocale("en").get).formatAge("2020-01-01", "2025-04-31").isNone

  # 33.9
  test "33.9 formatStage validates too":
    check newSayableAge(getLocale("en").get).formatStage("2025-02-30", "2027-09-05").isNone

  # 33.10
  test "33.10 February 29 in a leap year is valid":
    check newSayableAge(getLocale("en").get).formatAge("2024-02-29", "2026-03-01") == some("2 years")

