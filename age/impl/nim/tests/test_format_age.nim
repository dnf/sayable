## Tests for formatAge and formatStage — all canonical test cases from age/config/tests.json.

import std/[unittest, options, tables]
import ../src/sayable_age/locale
import ../src/sayable_age/formatter
import ../src/sayable_age/locales/registry
import ../src/sayable_age/locales/en
import ../src/sayable_age/locales/es
import ../src/sayable_age/locales/ar
import ../src/sayable_age/locales/he
import ../src/sayable_age/locales/mk
import ../src/sayable_age/locales/sw
import ../src/sayable_age/locales/id
import ../src/sayable_age/locales/am


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

  # 24.8-24.13
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
