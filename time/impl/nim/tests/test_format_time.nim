## Tests for sayable-time Nim implementation.
## All test IDs reference canonical tests from time/config/tests.json.

import std/[options, unittest]
import ../src/sayable_time/formatter
import ../src/sayable_time/locales/registry

suite "Null / edge cases":
  let st = newSayableTime(getLocale("en").get)

  # 1.1
  test "format_time with null returns none":
    check st.formatTime("").isNone

  # 1.2
  test "format_time with empty string returns none":
    check st.formatTime("").isNone

  # 1.3
  test "format_time with invalid string returns none":
    check st.formatTime("invalid").isNone

  # 1.4
  test "format_time with 25:00 returns none":
    check st.formatTime("25:00").isNone


suite "Clock time (normal compactness)":
  let st = newSayableTime(getLocale("en").get)

  # 2.1
  test "midnight":
    check st.formatTime("00:00").get == "midnight"

  # 2.2
  test "noon":
    check st.formatTime("12:00").get == "noon"

  # 2.3
  test "three o'clock":
    check st.formatTime("15:00").get == "three o'clock"

  # 2.4
  test "a quarter past two":
    check st.formatTime("14:15").get == "a quarter past two"

  # 2.5
  test "half past nine":
    check st.formatTime("09:30").get == "half past nine"

  # 2.6
  test "a quarter to eleven":
    check st.formatTime("10:45").get == "a quarter to eleven"

  # 2.7
  test "five past eight":
    check st.formatTime("08:05").get == "five past eight"

  # 2.8
  test "five to five":
    check st.formatTime("16:55").get == "five to five"

  # 2.9
  test "23:58 rounds to midnight":
    check st.formatTime("23:58").get == "midnight"

  # 2.10
  test "07:22 rounds to twenty past seven":
    check st.formatTime("07:22").get == "twenty past seven"

  # 2.11
  test "ISO datetime input":
    check st.formatTime("2025-01-15T14:15:00").get == "a quarter past two"


suite "Clock time (short compactness)":
  let st = newSayableTime(getLocale("en").get, cShort)

  # 3.1
  test "2:15 PM":
    check st.formatTime("14:15").get == "2:15 PM"

  # 3.2
  test "9:30 AM":
    check st.formatTime("09:30").get == "9:30 AM"

  # 3.3
  test "12:00 AM":
    check st.formatTime("00:00").get == "12:00 AM"

  # 3.4
  test "12:00 PM":
    check st.formatTime("12:00").get == "12:00 PM"


suite "Clock time (compact)":
  let st = newSayableTime(getLocale("en").get, cCompact)

  # 4.1
  test "2:15p":
    check st.formatTime("14:15").get == "2:15p"

  # 4.2
  test "9:30a":
    check st.formatTime("09:30").get == "9:30a"


suite "Locale - German":
  let st = newSayableTime(getLocale("de").get)

  # 5.1
  test "halb vier":
    check st.formatTime("15:30").get == "halb vier"


suite "Locale - French":
  let st = newSayableTime(getLocale("fr").get)

  # 6.1
  test "trois heures et quart":
    check st.formatTime("15:15").get == "trois heures et quart"

  # 6.2
  test "une heure":
    check st.formatTime("13:00").get == "une heure"

  # 6.3
  test "une heure et demie":
    check st.formatTime("13:30").get == "une heure et demie"

  # 6.4
  test "trois heures moins le quart":
    check st.formatTime("14:45").get == "trois heures moins le quart"

  # 6.5
  test "trois heures moins dix":
    check st.formatTime("14:50").get == "trois heures moins dix"


suite "Locale - Japanese":
  let st = newSayableTime(getLocale("ja").get)

  # 7.1
  test "san ji han":
    check st.formatTime("15:30").get == "\xE4\xB8\x89\xE6\x99\x82\xE5\x8D\x8A"


suite "Locale - Finnish (dot separator, short)":
  let st = newSayableTime(getLocale("fi").get, cShort)

  # 8.1
  test "14.15 dot separator":
    check st.formatTime("14:15").get == "14.15"

  # 8.2
  test "0.00 midnight dot":
    check st.formatTime("00:00").get == "0.00"

# ================================================================
# Section 9: Minutes in short and compact modes
# ================================================================
suite "Section 9: Minutes in short and compact modes":
  # 9.1
  test "9.1 digital modes keep the exact minute":
    check newSayableTime(getLocale("en").get, cShort).formatTime("18:01") == some("6:01 PM")

  # 9.2
  test "9.2 digital modes keep the exact minute":
    check newSayableTime(getLocale("en").get, cCompact).formatTime("19:05") == some("7:05p")


# ================================================================
# Section 10: Input validation
# ================================================================
suite "Section 10: Input validation":
  # 10.1
  test "10.1 one-digit hour":
    check newSayableTime(getLocale("en").get).formatTime("9:30") == some("half past nine")

  # 10.2
  test "10.2 two-digit hour":
    check newSayableTime(getLocale("en").get).formatTime("09:30") == some("half past nine")

  # 10.3
  test "10.3 leading whitespace":
    check newSayableTime(getLocale("en").get).formatTime(" 9:30").isNone

  # 10.4
  test "10.4 trailing whitespace":
    check newSayableTime(getLocale("en").get).formatTime("9:30 ").isNone

  # 10.5
  test "10.5 minutes need two digits":
    check newSayableTime(getLocale("en").get).formatTime("9:5").isNone

  # 10.6
  test "10.6 hour out of range":
    check newSayableTime(getLocale("en").get).formatTime("24:00").isNone

  # 10.7
  test "10.7 seconds are allowed and ignored":
    check newSayableTime(getLocale("en").get).formatTime("14:15:30") == some("a quarter past two")

  # 10.8
  test "10.8 ISO datetime with zone suffix (ignored)":
    check newSayableTime(getLocale("en").get).formatTime("2025-01-15T14:15:00Z") == some("a quarter past two")

  # 10.9
  test "10.9 ISO datetime with an impossible date":
    check newSayableTime(getLocale("en").get).formatTime("2025-02-30T14:15:00").isNone

