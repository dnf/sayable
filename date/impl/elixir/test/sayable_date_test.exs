defmodule SayableDateTest do
  use ExUnit.Case, async: true

  # Helpers
  defp date(d), do: SayableDate.format_date(SayableDate.Locales.EN.locale(), :normal, d)
  defp date_short(d), do: SayableDate.format_date(SayableDate.Locales.EN.locale(), :short, d)
  defp date_compact(d), do: SayableDate.format_date(SayableDate.Locales.EN.locale(), :compact, d)

  defp relative(d, as_of),
    do: SayableDate.format_relative(SayableDate.Locales.EN.locale(), :normal, d, as_of)

  defp relative_compact(d, as_of),
    do: SayableDate.format_relative(SayableDate.Locales.EN.locale(), :compact, d, as_of)

  defp date_locale(locale, d),
    do: SayableDate.format_date(locale, :normal, d)

  defp relative_locale(locale, d, as_of),
    do: SayableDate.format_relative(locale, :normal, d, as_of)

  # 1. Null / edge cases
  # 1.1
  test "1.1 - null date returns nil" do
    assert date(nil) == nil
  end

  # 1.2
  test "1.2 - empty string returns nil" do
    assert date("") == nil
  end

  # 1.3
  test "1.3 - invalid date returns nil" do
    assert date("invalid") == nil
  end

  # 1.4
  test "1.4 - format_relative with null asOf returns nil" do
    assert relative("2025-03-15", nil) == nil
  end

  # 1.5
  test "1.5 - format_relative with null date returns nil" do
    assert relative(nil, "2025-03-15") == nil
  end

  # 2. format_date — normal compactness (English)
  # 2.1
  test "2.1 - March 15th" do
    assert date("2025-03-15") == {:ok, "March 15th"}
  end

  # 2.2
  test "2.2 - January 1st" do
    assert date("2025-01-01") == {:ok, "January 1st"}
  end

  # 2.3
  test "2.3 - May 22nd" do
    assert date("2025-05-22") == {:ok, "May 22nd"}
  end

  # 2.4
  test "2.4 - July 3rd" do
    assert date("2025-07-03") == {:ok, "July 3rd"}
  end

  # 2.5
  test "2.5 - December 31st" do
    assert date("2025-12-31") == {:ok, "December 31st"}
  end

  # 2.6
  test "2.6 - June 11th (no exception for 11)" do
    assert date("2025-06-11") == {:ok, "June 11th"}
  end

  # 2.7
  test "2.7 - ISO datetime input" do
    assert date("2025-03-15T14:30:00") == {:ok, "March 15th"}
  end

  # 3. format_date — short compactness (English)
  # 3.1
  test "3.1 - short: Mar 15" do
    assert date_short("2025-03-15") == {:ok, "Mar 15"}
  end

  # 3.2
  test "3.2 - short: Jan 1" do
    assert date_short("2025-01-01") == {:ok, "Jan 1"}
  end

  # 3.3
  test "3.3 - short: Dec 25" do
    assert date_short("2025-12-25") == {:ok, "Dec 25"}
  end

  # 4. format_date — compact (English)
  # 4.1
  test "4.1 - compact: 3/15" do
    assert date_compact("2025-03-15") == {:ok, "3/15"}
  end

  # 4.2
  test "4.2 - compact: 1/1" do
    assert date_compact("2025-01-01") == {:ok, "1/1"}
  end

  # 5. format_relative — proximity tiers (English)
  # 5.1
  test "5.1 - today" do
    assert relative("2025-03-15", "2025-03-15") == {:ok, "today"}
  end

  # 5.2
  test "5.2 - tomorrow" do
    assert relative("2025-03-16", "2025-03-15") == {:ok, "tomorrow"}
  end

  # 5.3
  test "5.3 - yesterday" do
    assert relative("2025-03-14", "2025-03-15") == {:ok, "yesterday"}
  end

  # 5.4
  test "5.4 - the day after tomorrow" do
    assert relative("2025-03-17", "2025-03-15") == {:ok, "the day after tomorrow"}
  end

  # 5.5
  test "5.5 - the day before yesterday" do
    assert relative("2025-03-13", "2025-03-15") == {:ok, "the day before yesterday"}
  end

  # 5.6
  test "5.6 - this Wednesday (+4 days)" do
    assert relative("2025-03-19", "2025-03-15") == {:ok, "this Wednesday"}
  end

  # 5.7
  test "5.7 - this Thursday (+5 days)" do
    assert relative("2025-03-20", "2025-03-15") == {:ok, "this Thursday"}
  end

  # 5.8
  test "5.8 - last Tuesday (-4 days)" do
    assert relative("2025-03-11", "2025-03-15") == {:ok, "last Tuesday"}
  end

  # 5.9
  test "5.9 - next Saturday (+7 days)" do
    assert relative("2025-03-22", "2025-03-15") == {:ok, "next Saturday"}
  end

  # 5.10
  test "5.10 - next Thursday (+12 days)" do
    assert relative("2025-03-27", "2025-03-15") == {:ok, "next Thursday"}
  end

  # 5.11
  test "5.11 - calendar fallback same year" do
    assert relative("2025-03-01", "2025-03-15") == {:ok, "March 1st"}
  end

  # 5.12
  test "5.12 - calendar fallback same year (+26 days)" do
    assert relative("2025-04-10", "2025-03-15") == {:ok, "April 10th"}
  end

  # 5.13
  test "5.13 - different year includes year" do
    assert relative("2026-01-05", "2025-03-15") == {:ok, "January 5th, 2026"}
  end

  # 5.14
  test "5.14 - past year includes year" do
    assert relative("2024-12-25", "2025-03-15") == {:ok, "December 25th, 2024"}
  end

  # 6. format_relative — compact skips weekday tiers
  # 6.1
  test "6.1 - compact: today" do
    assert relative_compact("2025-03-15", "2025-03-15") == {:ok, "today"}
  end

  # 6.2
  test "6.2 - compact: tomorrow" do
    assert relative_compact("2025-03-16", "2025-03-15") == {:ok, "tomorrow"}
  end

  # 6.3
  test "6.3 - compact: numeric fallback" do
    assert relative_compact("2025-03-19", "2025-03-15") == {:ok, "3/19"}
  end

  # 6.4
  test "6.4 - compact: different year" do
    assert relative_compact("2026-01-05", "2025-03-15") == {:ok, "1/5/26"}
  end

  # 7. Locale — German
  # 7.1
  test "7.1 - German: format_date" do
    de = SayableDate.Locales.DE.locale()
    assert date_locale(de, "2025-03-15") == {:ok, "15. März"}
  end

  # 7.2
  test "7.2 - German: morgen" do
    de = SayableDate.Locales.DE.locale()
    assert relative_locale(de, "2025-03-16", "2025-03-15") == {:ok, "morgen"}
  end

  # 7.3
  test "7.3 - German: übermorgen" do
    de = SayableDate.Locales.DE.locale()
    assert relative_locale(de, "2025-03-17", "2025-03-15") == {:ok, "übermorgen"}
  end

  # 7.4
  test "7.4 - German: diesen Mittwoch" do
    de = SayableDate.Locales.DE.locale()
    assert relative_locale(de, "2025-03-19", "2025-03-15") == {:ok, "diesen Mittwoch"}
  end

  # 8. Locale — French
  # 8.1
  test "8.1 - French: 1er mars" do
    fr = SayableDate.Locales.FR.locale()
    assert date_locale(fr, "2025-03-01") == {:ok, "1er mars"}
  end

  # 8.2
  test "8.2 - French: 15 mars" do
    fr = SayableDate.Locales.FR.locale()
    assert date_locale(fr, "2025-03-15") == {:ok, "15 mars"}
  end

  # 8.3
  test "8.3 - French: demain" do
    fr = SayableDate.Locales.FR.locale()
    assert relative_locale(fr, "2025-03-16", "2025-03-15") == {:ok, "demain"}
  end

  # 9. Locale — Japanese
  # 9.1
  test "9.1 - Japanese: format_date" do
    ja = SayableDate.Locales.JA.locale()
    assert date_locale(ja, "2025-03-15") == {:ok, "3月15日"}
  end

  # 9.2
  test "9.2 - Japanese: 明日" do
    ja = SayableDate.Locales.JA.locale()
    assert relative_locale(ja, "2025-03-16", "2025-03-15") == {:ok, "明日"}
  end

  # 9.3
  test "9.3 - Japanese: 今度の水曜日" do
    ja = SayableDate.Locales.JA.locale()
    assert relative_locale(ja, "2025-03-19", "2025-03-15") == {:ok, "今度の水曜日"}
  end

  # 10. Locale — Russian (genitive months)
  # 10.1
  test "10.1 - Russian: genitive month form" do
    ru = SayableDate.Locales.RU.locale()
    assert date_locale(ru, "2025-03-15") == {:ok, "15 марта"}
  end

  # 10.2
  test "10.2 - Russian: завтра" do
    ru = SayableDate.Locales.RU.locale()
    assert relative_locale(ru, "2025-03-16", "2025-03-15") == {:ok, "завтра"}
  end

  # 11. Locale — Arabic
  # 11.1
  test "11.1 - Arabic: format_date" do
    ar = SayableDate.Locales.AR.locale()
    assert date_locale(ar, "2025-03-15") == {:ok, "15 مارس"}
  end

  # 11.2
  test "11.2 - Arabic: غداً" do
    ar = SayableDate.Locales.AR.locale()
    assert relative_locale(ar, "2025-03-16", "2025-03-15") == {:ok, "غداً"}
  end

  # 12. Locale — Spanish
  # 12.1
  test "12.1 - Spanish: format_date" do
    es = SayableDate.Locales.ES.locale()
    assert date_locale(es, "2025-03-15") == {:ok, "15 de marzo"}
  end

  # 12.2
  test "12.2 - Spanish: pasado mañana" do
    es = SayableDate.Locales.ES.locale()
    assert relative_locale(es, "2025-03-17", "2025-03-15") == {:ok, "pasado mañana"}
  end

  # 13. format_date_with_year
  # 13.1
  test "13.1 - en normal format_date_with_year" do
    assert SayableDate.format_date_with_year(
             SayableDate.Locales.EN.locale(),
             :normal,
             "2018-02-04"
           ) == {:ok, "February 4th, 2018"}
  end

  # 13.2
  test "13.2 - en short format_date_with_year" do
    assert SayableDate.format_date_with_year(
             SayableDate.Locales.EN.locale(),
             :short,
             "2025-03-15"
           ) == {:ok, "Mar 15, 2025"}
  end

  # 13.3
  test "13.3 - en compact format_date_with_year" do
    assert SayableDate.format_date_with_year(
             SayableDate.Locales.EN.locale(),
             :compact,
             "1997-01-21"
           ) == {:ok, "1/21/97"}
  end

  # 13.4
  test "13.4 - two-digit year keeps its leading zero" do
    assert SayableDate.format_date_with_year(
             SayableDate.Locales.TG.locale(),
             :compact,
             "2007-05-20"
           ) == {:ok, "20/5/07"}
  end

  # 13.5
  test "13.5 - fi short format_date_with_year" do
    assert SayableDate.format_date_with_year(
             SayableDate.Locales.FI.locale(),
             :short,
             "1996-06-21"
           ) == {:ok, "21. kesäkuuta 1996"}
  end

  # 14. Short month names (locales that keep the full genitive)
  # 14.1
  test "14.1 - sk short format_date" do
    assert SayableDate.format_date(SayableDate.Locales.SK.locale(), :short, "2031-02-15") ==
             {:ok, "15. februára"}
  end

  # 14.2
  test "14.2 - cs short format_date" do
    assert SayableDate.format_date(SayableDate.Locales.CS.locale(), :short, "2025-12-10") ==
             {:ok, "10. prosince"}
  end

  # 14.3
  test "14.3 - uk short format_date" do
    assert SayableDate.format_date(SayableDate.Locales.UK.locale(), :short, "2025-11-05") ==
             {:ok, "5 листопада"}
  end

  # 14.4
  test "14.4 - fi short format_relative" do
    assert SayableDate.format_relative(
             SayableDate.Locales.FI.locale(),
             :short,
             "1998-08-08",
             "1998-08-15"
           ) == {:ok, "8. elokuuta"}
  end

  # 15. format_relative — short phrases
  # 15.1
  test "15.1 - day after tomorrow" do
    assert SayableDate.format_relative(
             SayableDate.Locales.KW.locale(),
             :short,
             "2035-12-04",
             "2035-12-02"
           ) == {:ok, "an Mth ma"}
  end

  # 15.2
  test "15.2 - day before yesterday" do
    assert SayableDate.format_relative(
             SayableDate.Locales.MAM.locale(),
             :short,
             "2000-01-23",
             "2000-01-25"
           ) == {:ok, "Dom nchi'j"}
  end

  # 15.3
  test "15.3 - day after tomorrow" do
    assert SayableDate.format_relative(
             SayableDate.Locales.KEK.locale(),
             :short,
             "2014-10-24",
             "2014-10-22"
           ) == {:ok, "a'in Vie"}
  end

  # 16. Input validation
  # 16.1
  test "16.1 - February 30 doesn't exist" do
    assert SayableDate.format_date(SayableDate.Locales.EN.locale(), :normal, "2025-02-30") == nil
  end

  # 16.2
  test "16.2 - Month 13" do
    assert SayableDate.format_date(SayableDate.Locales.EN.locale(), :normal, "2025-13-01") == nil
  end

  # 16.3
  test "16.3 - Unpadded month and day" do
    assert SayableDate.format_date(SayableDate.Locales.EN.locale(), :normal, "2025-6-1") == nil
  end

  # 16.4
  test "16.4 - Surrounding whitespace" do
    assert SayableDate.format_date(SayableDate.Locales.EN.locale(), :normal, " 2025-06-01") == nil
  end

  # 16.5
  test "16.5 - An ISO datetime: only the date part is used" do
    assert SayableDate.format_date(
             SayableDate.Locales.EN.locale(),
             :normal,
             "2025-06-01T10:00:00"
           ) == {:ok, "June 1st"}
  end

  # 16.6
  test "16.6 - February 29 in a non-leap year" do
    assert SayableDate.format_date_with_year(
             SayableDate.Locales.EN.locale(),
             :normal,
             "2023-02-29"
           ) == nil
  end

  # 16.7
  test "16.7 - Invalid asOf" do
    assert SayableDate.format_relative(
             SayableDate.Locales.EN.locale(),
             :normal,
             "2025-03-16",
             "2025-04-31"
           ) == nil
  end
end
