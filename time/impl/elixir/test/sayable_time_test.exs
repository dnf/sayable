defmodule SayableTimeTest do
  use ExUnit.Case, async: true

  # Helpers
  defp time(t), do: SayableTime.format_time(SayableTime.Locales.EN.locale(), :normal, t)
  defp time_short(t), do: SayableTime.format_time(SayableTime.Locales.EN.locale(), :short, t)
  defp time_compact(t), do: SayableTime.format_time(SayableTime.Locales.EN.locale(), :compact, t)
  defp time_locale(locale, t), do: SayableTime.format_time(locale, :normal, t)

  # 1. Null / edge cases
  # 1.1
  test "1.1 - null time returns nil" do
    assert time(nil) == nil
  end

  # 1.2
  test "1.2 - empty string returns nil" do
    assert time("") == nil
  end

  # 1.3
  test "1.3 - invalid time returns nil" do
    assert time("invalid") == nil
  end

  # 1.4
  test "1.4 - out of range returns nil" do
    assert time("25:00") == nil
  end

  # 2. Clock time (normal compactness)
  # 2.1
  test "2.1 - midnight" do
    assert time("00:00") == {:ok, "midnight"}
  end

  # 2.2
  test "2.2 - noon" do
    assert time("12:00") == {:ok, "noon"}
  end

  # 2.3
  test "2.3 - three o'clock" do
    assert time("15:00") == {:ok, "three o'clock"}
  end

  # 2.4
  test "2.4 - a quarter past two" do
    assert time("14:15") == {:ok, "a quarter past two"}
  end

  # 2.5
  test "2.5 - half past nine" do
    assert time("09:30") == {:ok, "half past nine"}
  end

  # 2.6
  test "2.6 - a quarter to eleven" do
    assert time("10:45") == {:ok, "a quarter to eleven"}
  end

  # 2.7
  test "2.7 - five past eight" do
    assert time("08:05") == {:ok, "five past eight"}
  end

  # 2.8
  test "2.8 - five to five" do
    assert time("16:55") == {:ok, "five to five"}
  end

  # 2.9
  test "2.9 - 23:58 rounds to midnight" do
    assert time("23:58") == {:ok, "midnight"}
  end

  # 2.10
  test "2.10 - 07:22 rounds to twenty past seven" do
    assert time("07:22") == {:ok, "twenty past seven"}
  end

  # 2.11
  test "2.11 - ISO datetime input" do
    assert time("2025-01-15T14:15:00") == {:ok, "a quarter past two"}
  end

  # 3. Clock time (short compactness)
  # 3.1
  test "3.1 - short: 2:15 PM" do
    assert time_short("14:15") == {:ok, "2:15 PM"}
  end

  # 3.2
  test "3.2 - short: 9:30 AM" do
    assert time_short("09:30") == {:ok, "9:30 AM"}
  end

  # 3.3
  test "3.3 - short: 12:00 AM" do
    assert time_short("00:00") == {:ok, "12:00 AM"}
  end

  # 3.4
  test "3.4 - short: 12:00 PM" do
    assert time_short("12:00") == {:ok, "12:00 PM"}
  end

  # 4. Clock time (compact)
  # 4.1
  test "4.1 - compact: 2:15p" do
    assert time_compact("14:15") == {:ok, "2:15p"}
  end

  # 4.2
  test "4.2 - compact: 9:30a" do
    assert time_compact("09:30") == {:ok, "9:30a"}
  end

  # 5. Locale — German
  # 5.1
  test "5.1 - German: halb vier" do
    de = SayableTime.Locales.DE.locale()
    assert time_locale(de, "15:30") == {:ok, "halb vier"}
  end

  # 6. Locale — French
  # 6.1
  test "6.1 - French: trois heures et quart" do
    fr = SayableTime.Locales.FR.locale()
    assert time_locale(fr, "15:15") == {:ok, "trois heures et quart"}
  end

  # 7. Locale — Japanese
  # 7.1
  test "7.1 - Japanese: 三時半" do
    ja = SayableTime.Locales.JA.locale()
    assert time_locale(ja, "15:30") == {:ok, "三時半"}
  end

  # 8. Locale — Finnish (dot separator, short)
  # 8.1
  test "8.1 - Finnish: 14.15 dot separator" do
    fi = SayableTime.Locales.FI.locale()
    assert SayableTime.format_time(fi, :short, "14:15") == {:ok, "14.15"}
  end

  # 8.2
  test "8.2 - Finnish: 0.00 midnight dot" do
    fi = SayableTime.Locales.FI.locale()
    assert SayableTime.format_time(fi, :short, "00:00") == {:ok, "0.00"}
  end
end
