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
