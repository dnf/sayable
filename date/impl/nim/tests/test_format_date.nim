## Tests for sayable-date Nim implementation.
## All test IDs reference canonical tests from date/config/tests.json.

import std/[options, unittest]
import ../src/sayable_date/formatter
import ../src/sayable_date/locales/registry

suite "Null / edge cases":
  # 1.1
  test "format_date with null returns none":
    let sd = newSayableDate(getLocale("en").get)
    check sd.formatDate("").isNone

  # 1.2
  test "format_date with empty string returns none":
    let sd = newSayableDate(getLocale("en").get)
    check sd.formatDate("").isNone

  # 1.3
  test "format_date with invalid string returns none":
    let sd = newSayableDate(getLocale("en").get)
    check sd.formatDate("invalid").isNone

  # 1.4
  test "format_relative with null asOf returns none":
    let sd = newSayableDate(getLocale("en").get)
    check sd.formatRelative("2025-03-15", "").isNone

  # 1.5
  test "format_relative with null date returns none":
    let sd = newSayableDate(getLocale("en").get)
    check sd.formatRelative("", "2025-03-15").isNone


suite "format_date - normal compactness (English)":
  let sd = newSayableDate(getLocale("en").get)

  # 2.1
  test "March 15th":
    check sd.formatDate("2025-03-15").get == "March 15th"

  # 2.2
  test "January 1st":
    check sd.formatDate("2025-01-01").get == "January 1st"

  # 2.3
  test "May 22nd":
    check sd.formatDate("2025-05-22").get == "May 22nd"

  # 2.4
  test "July 3rd":
    check sd.formatDate("2025-07-03").get == "July 3rd"

  # 2.5
  test "December 31st":
    check sd.formatDate("2025-12-31").get == "December 31st"

  # 2.6
  test "June 11th - no exception for 11":
    check sd.formatDate("2025-06-11").get == "June 11th"

  # 2.7
  test "ISO datetime input":
    check sd.formatDate("2025-03-15T14:30:00").get == "March 15th"


suite "format_date - short compactness (English)":
  let sd = newSayableDate(getLocale("en").get, cShort)

  # 3.1
  test "Mar 15":
    check sd.formatDate("2025-03-15").get == "Mar 15"

  # 3.2
  test "Jan 1":
    check sd.formatDate("2025-01-01").get == "Jan 1"

  # 3.3
  test "Dec 25":
    check sd.formatDate("2025-12-25").get == "Dec 25"


suite "format_date - compact (English)":
  let sd = newSayableDate(getLocale("en").get, cCompact)

  # 4.1
  test "3/15":
    check sd.formatDate("2025-03-15").get == "3/15"

  # 4.2
  test "1/1":
    check sd.formatDate("2025-01-01").get == "1/1"


suite "format_relative - proximity tiers (English)":
  let sd = newSayableDate(getLocale("en").get)

  # 5.1
  test "today":
    check sd.formatRelative("2025-03-15", "2025-03-15").get == "today"

  # 5.2
  test "tomorrow":
    check sd.formatRelative("2025-03-16", "2025-03-15").get == "tomorrow"

  # 5.3
  test "yesterday":
    check sd.formatRelative("2025-03-14", "2025-03-15").get == "yesterday"

  # 5.4
  test "day after tomorrow":
    check sd.formatRelative("2025-03-17", "2025-03-15").get == "the day after tomorrow"

  # 5.5
  test "day before yesterday":
    check sd.formatRelative("2025-03-13", "2025-03-15").get == "the day before yesterday"

  # 5.6
  test "this Wednesday (+4 days)":
    check sd.formatRelative("2025-03-19", "2025-03-15").get == "this Wednesday"

  # 5.7
  test "this Thursday (+5 days)":
    check sd.formatRelative("2025-03-20", "2025-03-15").get == "this Thursday"

  # 5.8
  test "last Tuesday (-4 days)":
    check sd.formatRelative("2025-03-11", "2025-03-15").get == "last Tuesday"

  # 5.9
  test "next Saturday (+7 days)":
    check sd.formatRelative("2025-03-22", "2025-03-15").get == "next Saturday"

  # 5.10
  test "next Thursday (+12 days)":
    check sd.formatRelative("2025-03-27", "2025-03-15").get == "next Thursday"

  # 5.11
  test "calendar fallback same year (-14 days)":
    check sd.formatRelative("2025-03-01", "2025-03-15").get == "March 1st"

  # 5.12
  test "calendar fallback same year (+26 days)":
    check sd.formatRelative("2025-04-10", "2025-03-15").get == "April 10th"

  # 5.13
  test "different year includes year":
    check sd.formatRelative("2026-01-05", "2025-03-15").get == "January 5th, 2026"

  # 5.14
  test "past year includes year":
    check sd.formatRelative("2024-12-25", "2025-03-15").get == "December 25th, 2024"


suite "format_relative - compact skips weekday tiers":
  let sd = newSayableDate(getLocale("en").get, cCompact)

  # 6.1
  test "compact today":
    check sd.formatRelative("2025-03-15", "2025-03-15").get == "today"

  # 6.2
  test "compact tomorrow":
    check sd.formatRelative("2025-03-16", "2025-03-15").get == "tomorrow"

  # 6.3
  test "compact goes straight to numeric":
    check sd.formatRelative("2025-03-19", "2025-03-15").get == "3/19"

  # 6.4
  test "compact different year":
    check sd.formatRelative("2026-01-05", "2025-03-15").get == "1/5/26"


suite "Locale - German":
  let sd = newSayableDate(getLocale("de").get)

  # 7.1
  test "format_date German":
    check sd.formatDate("2025-03-15").get == "15. M\xC3\xA4rz"

  # 7.2
  test "format_relative morgen":
    check sd.formatRelative("2025-03-16", "2025-03-15").get == "morgen"

  # 7.3
  test "format_relative uebermorgen":
    check sd.formatRelative("2025-03-17", "2025-03-15").get == "\xC3\xBCbermorgen"

  # 7.4
  test "format_relative diesen Mittwoch":
    check sd.formatRelative("2025-03-19", "2025-03-15").get == "diesen Mittwoch"


suite "Locale - French":
  let sd = newSayableDate(getLocale("fr").get)

  # 8.1
  test "format_date 1er mars":
    check sd.formatDate("2025-03-01").get == "1er mars"

  # 8.2
  test "format_date 15 mars":
    check sd.formatDate("2025-03-15").get == "15 mars"

  # 8.3
  test "format_relative demain":
    check sd.formatRelative("2025-03-16", "2025-03-15").get == "demain"


suite "Locale - Japanese":
  let sd = newSayableDate(getLocale("ja").get)

  # 9.1
  test "format_date Japanese":
    check sd.formatDate("2025-03-15").get == "3\xE6\x9C\x8815\xE6\x97\xA5"

  # 9.2
  test "format_relative ashita":
    check sd.formatRelative("2025-03-16", "2025-03-15").get == "\xE6\x98\x8E\xE6\x97\xA5"

  # 9.3
  test "format_relative kondo no suiyoubi":
    check sd.formatRelative("2025-03-19", "2025-03-15").get == "\xE4\xBB\x8A\xE5\xBA\xA6\xE3\x81\xAE\xE6\xB0\xB4\xE6\x9B\x9C\xE6\x97\xA5"


suite "Locale - Russian (genitive months)":
  let sd = newSayableDate(getLocale("ru").get)

  # 10.1
  test "format_date Russian genitive":
    check sd.formatDate("2025-03-15").get == "15 \xD0\xBC\xD0\xB0\xD1\x80\xD1\x82\xD0\xB0"

  # 10.2
  test "format_relative zavtra":
    check sd.formatRelative("2025-03-16", "2025-03-15").get == "\xD0\xB7\xD0\xB0\xD0\xB2\xD1\x82\xD1\x80\xD0\xB0"


suite "Locale - Arabic":
  let sd = newSayableDate(getLocale("ar").get)

  # 11.1
  test "format_date Arabic":
    check sd.formatDate("2025-03-15").get == "15 \xD9\x85\xD8\xA7\xD8\xB1\xD8\xB3"

  # 11.2
  test "format_relative ghadan":
    check sd.formatRelative("2025-03-16", "2025-03-15").get == "\xD8\xBA\xD8\xAF\xD8\xA7\xD9\x8B"


suite "Locale - Spanish":
  let sd = newSayableDate(getLocale("es").get)

  # 12.1
  test "format_date Spanish":
    check sd.formatDate("2025-03-15").get == "15 de marzo"

  # 12.2
  test "format_relative pasado manana":
    check sd.formatRelative("2025-03-17", "2025-03-15").get == "pasado ma\xC3\xB1ana"

# ================================================================
# Section 13: format_date_with_year
# ================================================================
suite "Section 13: format_date_with_year":
  # 13.1
  test "13.1":
    check newSayableDate(getLocale("en").get).formatDateWithYear("2018-02-04") == some("February 4th, 2018")

  # 13.2
  test "13.2":
    check newSayableDate(getLocale("en").get, cShort).formatDateWithYear("2025-03-15") == some("Mar 15, 2025")

  # 13.3
  test "13.3":
    check newSayableDate(getLocale("en").get, cCompact).formatDateWithYear("1997-01-21") == some("1/21/97")

  # 13.4
  test "13.4 two-digit year keeps its leading zero":
    check newSayableDate(getLocale("tg").get, cCompact).formatDateWithYear("2007-05-20") == some("20/5/07")

  # 13.5
  test "13.5":
    check newSayableDate(getLocale("fi").get, cShort).formatDateWithYear("1996-06-21") == some("21. kesäkuuta 1996")


# ================================================================
# Section 14: Short month names
# ================================================================
suite "Section 14: Short month names":
  # 14.1
  test "14.1":
    check newSayableDate(getLocale("sk").get, cShort).formatDate("2031-02-15") == some("15. februára")

  # 14.2
  test "14.2":
    check newSayableDate(getLocale("cs").get, cShort).formatDate("2025-12-10") == some("10. prosince")

  # 14.3
  test "14.3":
    check newSayableDate(getLocale("uk").get, cShort).formatDate("2025-11-05") == some("5 листопада")

  # 14.4
  test "14.4":
    check newSayableDate(getLocale("fi").get, cShort).formatRelative("1998-08-08", "1998-08-15") == some("8. elokuuta")


# ================================================================
# Section 15: format_relative — short phrases
# ================================================================
suite "Section 15: format_relative — short phrases":
  # 15.1
  test "15.1 day after tomorrow":
    check newSayableDate(getLocale("kw").get, cShort).formatRelative("2035-12-04", "2035-12-02") == some("an Mth ma")

  # 15.2
  test "15.2 day before yesterday":
    check newSayableDate(getLocale("mam").get, cShort).formatRelative("2000-01-23", "2000-01-25") == some("Dom nchi'j")

  # 15.3
  test "15.3 day after tomorrow":
    check newSayableDate(getLocale("kek").get, cShort).formatRelative("2014-10-24", "2014-10-22") == some("a'in Vie")


# ================================================================
# Section 16: Input validation
# ================================================================
suite "Section 16: Input validation":
  # 16.1
  test "16.1 February 30 doesn't exist":
    check newSayableDate(getLocale("en").get).formatDate("2025-02-30").isNone

  # 16.2
  test "16.2 Month 13":
    check newSayableDate(getLocale("en").get).formatDate("2025-13-01").isNone

  # 16.3
  test "16.3 Unpadded month and day":
    check newSayableDate(getLocale("en").get).formatDate("2025-6-1").isNone

  # 16.4
  test "16.4 Surrounding whitespace":
    check newSayableDate(getLocale("en").get).formatDate(" 2025-06-01").isNone

  # 16.5
  test "16.5 An ISO datetime: only the date part is used":
    check newSayableDate(getLocale("en").get).formatDate("2025-06-01T10:00:00") == some("June 1st")

  # 16.6
  test "16.6 February 29 in a non-leap year":
    check newSayableDate(getLocale("en").get).formatDateWithYear("2023-02-29").isNone

  # 16.7
  test "16.7 Invalid asOf":
    check newSayableDate(getLocale("en").get).formatRelative("2025-03-16", "2025-04-31").isNone

