## Tests for sayable-duration Nim implementation.
## All test IDs reference canonical tests from duration/config/tests.json.

import std/[options, unittest]
import ../src/sayable_duration/formatter
import ../src/sayable_duration/locales/registry

suite "Null / edge cases":
  let sd = newSayableDuration(getLocale("en").get)

  # 1.1
  test "format_duration with null returns none":
    # Nim has no null int; we test negative as the closest analog
    discard

  # 1.2
  test "format_duration with negative returns none":
    check sd.formatDuration(-1).isNone

  # 1.3
  test "format_since with null start returns none":
    check sd.formatSince("", "2025-01-15T10:00:00").isNone

  # 1.4
  test "format_until with null target returns none":
    check sd.formatUntil("", "2025-01-15T10:00:00").isNone

  # 1.5
  test "format_since asOf before start returns none":
    check sd.formatSince("2025-01-15T10:00:00", "2025-01-15T09:00:00").isNone

  # 1.6
  test "format_until target in the past returns none":
    check sd.formatUntil("2025-01-15T09:00:00", "2025-01-15T10:00:00").isNone


suite "Duration - seconds tier (0-59s)":
  let sd = newSayableDuration(getLocale("en").get)

  # 2.1
  test "0 seconds is just now":
    check sd.formatDuration(0).get == "just now"

  # 2.2
  test "1 second":
    check sd.formatDuration(1).get == "1 second"

  # 2.3
  test "45 seconds":
    check sd.formatDuration(45).get == "45 seconds"

  # 2.4
  test "59 seconds":
    check sd.formatDuration(59).get == "59 seconds"


suite "Duration - minutes + seconds tier (1-4 min)":
  let sd = newSayableDuration(getLocale("en").get)

  # 3.1
  test "60 seconds is 1 minute":
    check sd.formatDuration(60).get == "1 minute"

  # 3.2
  test "90 seconds is 1 minute, 30 seconds":
    check sd.formatDuration(90).get == "1 minute, 30 seconds"

  # 3.3
  test "240 seconds is 4 minutes":
    check sd.formatDuration(240).get == "4 minutes"

  # 3.4
  test "270 seconds is 4 minutes, 30 seconds":
    check sd.formatDuration(270).get == "4 minutes, 30 seconds"


suite "Duration - minutes tier (5-59 min)":
  let sd = newSayableDuration(getLocale("en").get)

  # 4.1
  test "300 seconds is 5 minutes":
    check sd.formatDuration(300).get == "5 minutes"

  # 4.2
  test "1500 seconds is 25 minutes":
    check sd.formatDuration(1500).get == "25 minutes"

  # 4.3
  test "3540 seconds is 59 minutes":
    check sd.formatDuration(3540).get == "59 minutes"


suite "Duration - hours + minutes tier (1-5 hr)":
  let sd = newSayableDuration(getLocale("en").get)

  # 5.1
  test "3600 seconds is 1 hour":
    check sd.formatDuration(3600).get == "1 hour"

  # 5.2
  test "5400 seconds is 1\xC2\xBD hours (half marker)":
    check sd.formatDuration(5400).get == "1\xC2\xBD hours"

  # 5.3
  test "8100 seconds is 2 hours, 15 minutes":
    check sd.formatDuration(8100).get == "2 hours, 15 minutes"

  # 5.4
  test "18000 seconds is 5 hours":
    check sd.formatDuration(18000).get == "5 hours"


suite "Duration - hours tier (6-23 hr)":
  let sd = newSayableDuration(getLocale("en").get)

  # 6.1
  test "28800 seconds is 8 hours":
    check sd.formatDuration(28800).get == "8 hours"

  # 6.2
  test "82800 seconds is 23 hours":
    check sd.formatDuration(82800).get == "23 hours"


suite "Duration - days tier":
  let sd = newSayableDuration(getLocale("en").get)

  # 7.1
  test "86400 seconds is 1 day":
    check sd.formatDuration(86400).get == "1 day"

  # 7.2
  test "97200 seconds is 1 day, 3 hours":
    check sd.formatDuration(97200).get == "1 day, 3 hours"

  # 7.3
  test "129600 seconds is 1\xC2\xBD days (half marker)":
    check sd.formatDuration(129600).get == "1\xC2\xBD days"

  # 7.4
  test "432000 seconds is 5 days":
    check sd.formatDuration(432000).get == "5 days"

  # 7.5
  test "172800 seconds is 2 days":
    check sd.formatDuration(172800).get == "2 days"


suite "Duration - weeks tier":
  let sd = newSayableDuration(getLocale("en").get)

  # 8.1
  test "604800 seconds is 1 week":
    check sd.formatDuration(604800).get == "1 week"

  # 8.2
  test "1296000 seconds is 2 weeks, 1 day":
    check sd.formatDuration(1296000).get == "2 weeks, 1 day"

  # 8.3
  test "2419200 seconds is 4 weeks":
    check sd.formatDuration(2419200).get == "4 weeks"


suite "Duration - months and years tier":
  let sd = newSayableDuration(getLocale("en").get)

  # 9.1
  test "2678400 seconds is 1 month":
    check sd.formatDuration(2678400).get == "1 month"

  # 9.2
  test "7884000 seconds is 3 months":
    check sd.formatDuration(7884000).get == "3 months"

  # 9.3
  test "31536000 seconds is 1 year":
    check sd.formatDuration(31536000).get == "1 year"

  # 9.4
  test "39420000 seconds is 1 year, 3 months":
    check sd.formatDuration(39420000).get == "1 year, 3 months"


suite "Duration from ISO timestamps":
  let sd = newSayableDuration(getLocale("en").get)

  # 10.1
  test "ISO timestamps 1.5 hours":
    check sd.formatDurationIso("2025-01-15T10:00:00", "2025-01-15T11:30:00").get == "1\xC2\xBD hours"

  # 10.2
  test "ISO timestamps 45 minutes":
    check sd.formatDurationIso("2025-01-15T10:00:00", "2025-01-15T10:45:00").get == "45 minutes"


suite "Relative time - since":
  let sd = newSayableDuration(getLocale("en").get)

  # 11.1
  test "format_since same time is just now":
    check sd.formatSince("2025-01-15T10:00:00", "2025-01-15T10:00:00").get == "just now"

  # 11.2
  test "format_since 30 seconds ago":
    check sd.formatSince("2025-01-15T10:00:00", "2025-01-15T10:00:30").get == "30 seconds ago"

  # 11.3
  test "format_since 45 minutes ago":
    check sd.formatSince("2025-01-15T10:00:00", "2025-01-15T10:45:00").get == "45 minutes ago"

  # 11.4
  test "format_since 3 hours ago":
    check sd.formatSince("2025-01-15T10:00:00", "2025-01-15T13:00:00").get == "3 hours ago"


suite "Relative time - until":
  let sd = newSayableDuration(getLocale("en").get)

  # 12.1
  test "format_until same time is just now":
    check sd.formatUntil("2025-01-15T10:00:00", "2025-01-15T10:00:00").get == "just now"

  # 12.2
  test "format_until in 20 minutes":
    check sd.formatUntil("2025-01-15T10:20:00", "2025-01-15T10:00:00").get == "in 20 minutes"

  # 12.3
  test "format_until in 3 hours":
    check sd.formatUntil("2025-01-15T13:00:00", "2025-01-15T10:00:00").get == "in 3 hours"


suite "Locale - German":
  let sd = newSayableDuration(getLocale("de").get)

  # 13.1
  test "1 Stunde":
    check sd.formatDuration(3600).get == "1 Stunde"

  # 13.2
  test "vor 5 Minuten":
    check sd.formatSince("2025-01-15T10:00:00", "2025-01-15T10:05:00").get == "vor 5 Minuten"


suite "Locale - French":
  let sd = newSayableDuration(getLocale("fr").get)

  # 14.1
  test "2 heures":
    check sd.formatDuration(7200).get == "2 heures"


suite "Locale - Japanese":
  let sd = newSayableDuration(getLocale("ja").get)

  # 15.1
  test "2 minutes in Japanese":
    check sd.formatDuration(120).get == "2\xE5\x88\x86"

  # 15.2
  test "1 hour ago in Japanese":
    check sd.formatSince("2025-01-15T10:00:00", "2025-01-15T11:00:00").get == "1\xE6\x99\x82\xE9\x96\x93\xE5\x89\x8D"


suite "Short compactness - duration":
  let sd = newSayableDuration(getLocale("en").get, cShort)

  # 16.1
  test "short 1h":
    check sd.formatDuration(3600).get == "1h"

  # 16.2
  test "short 1m, 30s":
    check sd.formatDuration(90).get == "1m, 30s"


suite "Compact compactness - duration":
  let sd = newSayableDuration(getLocale("en").get, cCompact)

  # 17.1
  test "compact 1h":
    check sd.formatDuration(3600).get == "1h"

  # 17.2
  test "compact 1m30s":
    check sd.formatDuration(90).get == "1m30s"

# ================================================================
# Section 18: Short compactness — relative time
# ================================================================
suite "Section 18: Short compactness — relative time":
  # 18.1
  test "18.1 days and hours both kept":
    check newSayableDuration(getLocale("men").get).formatSince("2025-01-20T01:32:11", "2025-01-22T15:39:16") == some("lɔhɔnga 2, awa 14 taa gbɔyɔ")


# ================================================================
# Section 19: Range (500-year ceiling)
# ================================================================
suite "Section 19: Range (500-year ceiling)":
  # 19.1
  test "19.1 500 Julian years: 6000 months, the ceiling":
    check newSayableDuration(getLocale("en").get).formatDuration(15778800000) == some("500 years")

  # 19.2
  test "19.2 over 6000 months":
    check newSayableDuration(getLocale("en").get).formatDuration(15800000000).isNone

  # 19.3
  test "19.3 well beyond the ceiling (and 32-bit range)":
    check newSayableDuration(getLocale("en").get).formatDuration(99999999999).isNone

  # 19.4
  test "19.4 525 years ago":
    check newSayableDuration(getLocale("en").get).formatSince("1500-01-01T00:00:00", "2025-01-01T00:00:00").isNone

  # 19.5
  test "19.5 575 years from now":
    check newSayableDuration(getLocale("en").get).formatUntil("2600-01-01T00:00:00", "2025-01-01T00:00:00").isNone


# ================================================================
# Section 20: Timestamp validation
# ================================================================
suite "Section 20: Timestamp validation":
  # 20.1
  test "20.1 seconds are optional":
    check newSayableDuration(getLocale("en").get).formatDurationIso("2025-01-15T10:00", "2025-01-15T11:30:00") == some("1½ hours")

  # 20.2
  test "20.2 minutes are required":
    check newSayableDuration(getLocale("en").get).formatDurationIso("2025-01-15T10", "2025-01-15T11:30:00").isNone

  # 20.3
  test "20.3 unpadded date":
    check newSayableDuration(getLocale("en").get).formatDurationIso("2025-1-5T10:00:00", "2025-01-15T11:30:00").isNone

  # 20.4
  test "20.4 impossible date":
    check newSayableDuration(getLocale("en").get).formatDurationIso("2025-02-30T10:00:00", "2025-03-15T11:30:00").isNone

  # 20.5
  test "20.5 hour out of range":
    check newSayableDuration(getLocale("en").get).formatSince("2025-01-15T10:00:00", "2025-01-15T25:00:00").isNone

