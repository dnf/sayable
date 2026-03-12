defmodule SayableDurationTest do
  use ExUnit.Case, async: true

  # Helpers
  defp dur(seconds),
    do: SayableDuration.format_duration(SayableDuration.Locales.EN.locale(), :normal, seconds)

  defp dur_short(seconds),
    do: SayableDuration.format_duration(SayableDuration.Locales.EN.locale(), :short, seconds)

  defp dur_compact(seconds),
    do: SayableDuration.format_duration(SayableDuration.Locales.EN.locale(), :compact, seconds)

  defp dur_iso(s, e),
    do: SayableDuration.format_duration(SayableDuration.Locales.EN.locale(), :normal, s, e)

  defp since(s, a),
    do: SayableDuration.format_since(SayableDuration.Locales.EN.locale(), :normal, s, a)

  defp until_fn(t, a),
    do: SayableDuration.format_until(SayableDuration.Locales.EN.locale(), :normal, t, a)

  defp dur_locale(locale, seconds),
    do: SayableDuration.format_duration(locale, :normal, seconds)

  defp since_locale(locale, s, a),
    do: SayableDuration.format_since(locale, :normal, s, a)

  # 1. Null / edge cases
  # 1.1
  test "1.1 - null seconds returns nil" do
    assert dur(nil) == nil
  end

  # 1.2
  test "1.2 - negative seconds returns nil" do
    assert dur(-1) == nil
  end

  # 1.3
  test "1.3 - format_since with null start returns nil" do
    assert since(nil, "2025-01-15T10:00:00") == nil
  end

  # 1.4
  test "1.4 - format_until with null target returns nil" do
    assert until_fn(nil, "2025-01-15T10:00:00") == nil
  end

  # 1.5
  test "1.5 - format_since with asOf before start returns nil" do
    assert since("2025-01-15T10:00:00", "2025-01-15T09:00:00") == nil
  end

  # 1.6
  test "1.6 - format_until with target in the past returns nil" do
    assert until_fn("2025-01-15T09:00:00", "2025-01-15T10:00:00") == nil
  end

  # 2. Duration — seconds tier (0-59s)
  # 2.1
  test "2.1 - 0 seconds: just now" do
    assert dur(0) == {:ok, "just now"}
  end

  # 2.2
  test "2.2 - 1 second" do
    assert dur(1) == {:ok, "1 second"}
  end

  # 2.3
  test "2.3 - 45 seconds" do
    assert dur(45) == {:ok, "45 seconds"}
  end

  # 2.4
  test "2.4 - 59 seconds" do
    assert dur(59) == {:ok, "59 seconds"}
  end

  # 3. Duration — minutes + seconds tier (1-4 min)
  # 3.1
  test "3.1 - 1 minute" do
    assert dur(60) == {:ok, "1 minute"}
  end

  # 3.2
  test "3.2 - 1 minute, 30 seconds" do
    assert dur(90) == {:ok, "1 minute, 30 seconds"}
  end

  # 3.3
  test "3.3 - 4 minutes" do
    assert dur(240) == {:ok, "4 minutes"}
  end

  # 3.4
  test "3.4 - 4 minutes, 30 seconds" do
    assert dur(270) == {:ok, "4 minutes, 30 seconds"}
  end

  # 4. Duration — minutes tier (5-59 min)
  # 4.1
  test "4.1 - 5 minutes" do
    assert dur(300) == {:ok, "5 minutes"}
  end

  # 4.2
  test "4.2 - 25 minutes" do
    assert dur(1500) == {:ok, "25 minutes"}
  end

  # 4.3
  test "4.3 - 59 minutes" do
    assert dur(3540) == {:ok, "59 minutes"}
  end

  # 5. Duration — hours + minutes tier (1-5 hr)
  # 5.1
  test "5.1 - 1 hour" do
    assert dur(3600) == {:ok, "1 hour"}
  end

  # 5.2
  test "5.2 - 1½ hours (half marker)" do
    assert dur(5400) == {:ok, "1½ hours"}
  end

  # 5.3
  test "5.3 - 2 hours, 15 minutes" do
    assert dur(8100) == {:ok, "2 hours, 15 minutes"}
  end

  # 5.4
  test "5.4 - 5 hours" do
    assert dur(18000) == {:ok, "5 hours"}
  end

  # 6. Duration — hours tier (6-23 hr)
  # 6.1
  test "6.1 - 8 hours" do
    assert dur(28800) == {:ok, "8 hours"}
  end

  # 6.2
  test "6.2 - 23 hours" do
    assert dur(82800) == {:ok, "23 hours"}
  end

  # 7. Duration — days tier
  # 7.1
  test "7.1 - 1 day" do
    assert dur(86400) == {:ok, "1 day"}
  end

  # 7.2
  test "7.2 - 1 day, 3 hours" do
    assert dur(97200) == {:ok, "1 day, 3 hours"}
  end

  # 7.3
  test "7.3 - 1½ days (half marker)" do
    assert dur(129_600) == {:ok, "1½ days"}
  end

  # 7.4
  test "7.4 - 5 days" do
    assert dur(432_000) == {:ok, "5 days"}
  end

  # 7.5
  test "7.5 - 2 days" do
    assert dur(172_800) == {:ok, "2 days"}
  end

  # 8. Duration — weeks tier
  # 8.1
  test "8.1 - 1 week" do
    assert dur(604_800) == {:ok, "1 week"}
  end

  # 8.2
  test "8.2 - 2 weeks, 1 day" do
    assert dur(1_296_000) == {:ok, "2 weeks, 1 day"}
  end

  # 8.3
  test "8.3 - 4 weeks" do
    assert dur(2_419_200) == {:ok, "4 weeks"}
  end

  # 9. Duration — months and years tier
  # 9.1
  test "9.1 - 1 month (~31 days)" do
    assert dur(2_678_400) == {:ok, "1 month"}
  end

  # 9.2
  test "9.2 - 3 months (~91 days)" do
    assert dur(7_884_000) == {:ok, "3 months"}
  end

  # 9.3
  test "9.3 - 1 year (365 days)" do
    assert dur(31_536_000) == {:ok, "1 year"}
  end

  # 9.4
  test "9.4 - 1 year, 3 months (~456 days)" do
    assert dur(39_420_000) == {:ok, "1 year, 3 months"}
  end

  # 10. Duration from ISO timestamps
  # 10.1
  test "10.1 - ISO: 1½ hours" do
    assert dur_iso("2025-01-15T10:00:00", "2025-01-15T11:30:00") == {:ok, "1½ hours"}
  end

  # 10.2
  test "10.2 - ISO: 45 minutes" do
    assert dur_iso("2025-01-15T10:00:00", "2025-01-15T10:45:00") == {:ok, "45 minutes"}
  end

  # 11. Relative time — since
  # 11.1
  test "11.1 - since: just now" do
    assert since("2025-01-15T10:00:00", "2025-01-15T10:00:00") == {:ok, "just now"}
  end

  # 11.2
  test "11.2 - since: 30 seconds ago" do
    assert since("2025-01-15T10:00:00", "2025-01-15T10:00:30") == {:ok, "30 seconds ago"}
  end

  # 11.3
  test "11.3 - since: 45 minutes ago" do
    assert since("2025-01-15T10:00:00", "2025-01-15T10:45:00") == {:ok, "45 minutes ago"}
  end

  # 11.4
  test "11.4 - since: 3 hours ago" do
    assert since("2025-01-15T10:00:00", "2025-01-15T13:00:00") == {:ok, "3 hours ago"}
  end

  # 12. Relative time — until
  # 12.1
  test "12.1 - until: just now" do
    assert until_fn("2025-01-15T10:00:00", "2025-01-15T10:00:00") == {:ok, "just now"}
  end

  # 12.2
  test "12.2 - until: in 20 minutes" do
    assert until_fn("2025-01-15T10:20:00", "2025-01-15T10:00:00") == {:ok, "in 20 minutes"}
  end

  # 12.3
  test "12.3 - until: in 3 hours" do
    assert until_fn("2025-01-15T13:00:00", "2025-01-15T10:00:00") == {:ok, "in 3 hours"}
  end

  # 13. Locale — German
  # 13.1
  test "13.1 - German: 1 Stunde" do
    de = SayableDuration.Locales.DE.locale()
    assert dur_locale(de, 3600) == {:ok, "1 Stunde"}
  end

  # 13.2
  test "13.2 - German: vor 5 Minuten" do
    de = SayableDuration.Locales.DE.locale()
    assert since_locale(de, "2025-01-15T10:00:00", "2025-01-15T10:05:00") == {:ok, "vor 5 Minuten"}
  end

  # 14. Locale — French
  # 14.1
  test "14.1 - French: 2 heures" do
    fr = SayableDuration.Locales.FR.locale()
    assert dur_locale(fr, 7200) == {:ok, "2 heures"}
  end

  # 15. Locale — Japanese
  # 15.1
  test "15.1 - Japanese: 2分" do
    ja = SayableDuration.Locales.JA.locale()
    assert dur_locale(ja, 120) == {:ok, "2分"}
  end

  # 15.2
  test "15.2 - Japanese: 1時間前" do
    ja = SayableDuration.Locales.JA.locale()
    assert since_locale(ja, "2025-01-15T10:00:00", "2025-01-15T11:00:00") == {:ok, "1時間前"}
  end

  # 16. Short compactness — duration
  # 16.1
  test "16.1 - short: 1h" do
    assert dur_short(3600) == {:ok, "1h"}
  end

  # 16.2
  test "16.2 - short: 1m, 30s" do
    assert dur_short(90) == {:ok, "1m, 30s"}
  end

  # 17. Compact compactness — duration
  # 17.1
  test "17.1 - compact: 1h" do
    assert dur_compact(3600) == {:ok, "1h"}
  end

  # 17.2
  test "17.2 - compact: 1m30s" do
    assert dur_compact(90) == {:ok, "1m30s"}
  end
end
