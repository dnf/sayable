defmodule SayableAgeTest do
  use ExUnit.Case, async: true

  # Helpers
  defp age(dob, as_of), do: SayableAge.format_age(SayableAge.Locales.EN.locale(), :normal, dob, as_of)
  defp age_short(dob, as_of), do: SayableAge.format_age(SayableAge.Locales.EN.locale(), :short, dob, as_of)
  defp age_compact(dob, as_of), do: SayableAge.format_age(SayableAge.Locales.EN.locale(), :compact, dob, as_of)
  defp age_locale(locale, dob, as_of), do: SayableAge.format_age(locale, :normal, dob, as_of)
  defp stage(dob, as_of), do: SayableAge.format_stage(SayableAge.Locales.EN.locale(), dob, as_of, nil)
  defp stage_locale(locale, dob, as_of, gender), do: SayableAge.format_stage(locale, dob, as_of, gender)

  defp contains_week?(result) do
    case result do
      {:ok, s} -> String.contains?(s, "week")
      _ -> false
    end
  end

  # 1. Null / edge cases
  test "1.1/1.3 - empty DOB returns error" do
    assert age("", "2025-06-15") == :error
  end

  test "1.2 - empty DOB returns error" do
    assert age("", "2025-06-15") == :error
  end

  test "1.4 - future DOB returns error" do
    assert age("2025-07-01", "2025-06-15") == :error
  end

  test "1.5 - 500 years is valid" do
    assert age("1525-06-15", "2025-06-15") == {:ok, "500 years"}
  end

  test "1.6 - 501 years returns error" do
    assert age("1524-06-15", "2025-06-15") == :error
  end

  test "1.7 - 1000 years returns error" do
    assert age("1025-06-15", "2025-06-15") == :error
  end

  # 2. Days tier (0-6 days)
  test "2.1 - same day shows Newborn" do
    assert age("2025-06-15", "2025-06-15") == {:ok, "Newborn"}
  end

  test "2.2 - 1 day old" do
    assert age("2025-06-14", "2025-06-15") == {:ok, "1 day"}
  end

  test "2.3 - 3 days old" do
    assert age("2025-06-12", "2025-06-15") == {:ok, "3 days"}
  end

  test "2.4 - 6 days old" do
    assert age("2025-06-09", "2025-06-15") == {:ok, "6 days"}
  end

  test "2.5 - 7 days becomes 1 week" do
    assert age("2025-06-08", "2025-06-15") == {:ok, "1 week"}
  end

  # 3. Weeks+days tier
  test "3.1 - exactly 1 week" do
    assert age("2025-06-08", "2025-06-15") == {:ok, "1 week"}
  end

  test "3.2 - 1 week, 1 day" do
    assert age("2025-06-07", "2025-06-15") == {:ok, "1 week, 1 day"}
  end

  test "3.3 - 1 week, 2 days" do
    assert age("2025-06-06", "2025-06-15") == {:ok, "1 week, 2 days"}
  end

  test "3.4 - 1 week, 6 days" do
    assert age("2025-06-02", "2025-06-15") == {:ok, "1 week, 6 days"}
  end

  test "3.5 - 2 weeks" do
    assert age("2025-06-01", "2025-06-15") == {:ok, "2 weeks"}
  end

  test "3.6 - 2 weeks, 1 day" do
    assert age("2025-05-31", "2025-06-15") == {:ok, "2 weeks, 1 day"}
  end

  test "3.7 - 2 weeks, 6 days" do
    assert age("2025-05-26", "2025-06-15") == {:ok, "2 weeks, 6 days"}
  end

  test "3.8 - 3 weeks" do
    assert age("2025-05-25", "2025-06-15") == {:ok, "3 weeks"}
  end

  test "3.9 - 4 weeks, 3 days" do
    assert age("2025-05-15", "2025-06-15") == {:ok, "4 weeks, 3 days"}
  end

  test "3.10 - 8 weeks, 5 days" do
    assert age("2025-04-15", "2025-06-15") == {:ok, "8 weeks, 5 days"}
  end

  test "3.11 - 13 weeks (still under 3 months)" do
    assert age("2025-03-15", "2025-06-14") == {:ok, "13 weeks"}
  end

  test "3.12 - exactly 3 months transitions to months" do
    assert age("2025-03-15", "2025-06-15") == {:ok, "3 months"}
  end

  # 4. Month boundaries - standard months
  test "4.1 - 3 months standard" do
    assert age("2025-01-01", "2025-04-01") == {:ok, "3 months"}
  end

  test "4.2 - just under 3 months shows weeks" do
    assert contains_week?(age("2025-01-01", "2025-03-31"))
  end

  test "4.3 - 3 months mid-month" do
    assert age("2025-06-15", "2025-09-15") == {:ok, "3 months"}
  end

  test "4.4 - just under 3 months mid-month shows weeks" do
    assert contains_week?(age("2025-06-15", "2025-09-14"))
  end

  test "4.5 - 6 months" do
    assert age("2025-06-15", "2025-12-15") == {:ok, "6 months"}
  end

  # 5. Month boundaries - Feb non-leap
  test "5.1 - Jan 31 to Feb 28 non-leap" do
    assert age("2025-01-31", "2025-02-28") == {:ok, "4 weeks"}
  end

  test "5.2 - Jan 31 to Apr 30 = 3 months" do
    assert age("2025-01-31", "2025-04-30") == {:ok, "3 months"}
  end

  test "5.3 - Jan 31 to Apr 29 shows weeks" do
    assert contains_week?(age("2025-01-31", "2025-04-29"))
  end

  test "5.4 - Feb 1 to May 1 = 3 months" do
    assert age("2025-02-01", "2025-05-01") == {:ok, "3 months"}
  end

  test "5.5 - Feb 1 to Apr 30 shows weeks" do
    assert contains_week?(age("2025-02-01", "2025-04-30"))
  end

  # 6. Month boundaries - Feb leap year
  test "6.1 - Jan 31 to Feb 29 leap" do
    assert age("2024-01-31", "2024-02-29") == {:ok, "4 weeks, 1 day"}
  end

  test "6.2 - Jan 31 to Feb 28 leap" do
    assert age("2024-01-31", "2024-02-28") == {:ok, "4 weeks"}
  end

  test "6.3 - Jan 31 to Apr 30 leap = 3 months" do
    assert age("2024-01-31", "2024-04-30") == {:ok, "3 months"}
  end

  test "6.4 - Jan 30 to Feb 29 shows weeks" do
    assert contains_week?(age("2024-01-30", "2024-02-29"))
  end

  test "6.5 - Jan 30 to Feb 28 shows weeks" do
    assert contains_week?(age("2024-01-30", "2024-02-28"))
  end

  # 7. Month boundaries - 30-day months
  test "7.1 - Mar 31 to Jun 30 = 3 months" do
    assert age("2025-03-31", "2025-06-30") == {:ok, "3 months"}
  end

  test "7.2 - Mar 31 to Jun 29 shows weeks" do
    assert contains_week?(age("2025-03-31", "2025-06-29"))
  end

  test "7.3 - Aug 31 to Nov 30 = 3 months" do
    assert age("2025-08-31", "2025-11-30") == {:ok, "3 months"}
  end

  test "7.4 - Aug 31 to Nov 29 shows weeks" do
    assert contains_week?(age("2025-08-31", "2025-11-29"))
  end

  # 8. Leap year baby
  test "8.1 - leap baby 3 months" do
    assert age("2024-02-29", "2024-05-29") == {:ok, "3 months"}
  end

  test "8.2 - leap baby just under 3 months shows weeks" do
    assert contains_week?(age("2024-02-29", "2024-05-28"))
  end

  test "8.3 - leap baby turns 12 months on Feb 28" do
    assert age("2024-02-29", "2025-02-28") == {:ok, "12 months"}
  end

  test "8.4 - leap baby turns 12 months on Mar 1" do
    assert age("2024-02-29", "2025-03-01") == {:ok, "12 months"}
  end

  # 9. Months tier (3-23 months)
  test "9.1 - 3 months" do
    assert age("2025-01-15", "2025-04-15") == {:ok, "3 months"}
  end

  test "9.2 - 6 months" do
    assert age("2025-01-15", "2025-07-15") == {:ok, "6 months"}
  end

  test "9.3 - 12 months" do
    assert age("2024-06-15", "2025-06-15") == {:ok, "12 months"}
  end

  test "9.4 - 23 months" do
    assert age("2024-01-15", "2025-12-15") == {:ok, "23 months"}
  end

  test "9.5 - 5 months (day before 6 month mark)" do
    assert age("2025-01-15", "2025-07-14") == {:ok, "5 months"}
  end

  test "9.6 - 5 months cross-year" do
    assert age("2024-11-10", "2025-04-10") == {:ok, "5 months"}
  end

  # 10. Years+months tier (24-35 months)
  test "10.1 - exactly 2 years" do
    assert age("2023-06-15", "2025-06-15") == {:ok, "2 years"}
  end

  test "10.2 - 2 years, 1 month" do
    assert age("2023-06-15", "2025-07-15") == {:ok, "2 years, 1 month"}
  end

  test "10.3 - 2 years, 6 months" do
    assert age("2023-06-15", "2025-12-15") == {:ok, "2 years, 6 months"}
  end

  test "10.4 - 2 years, 11 months" do
    assert age("2023-06-15", "2026-05-15") == {:ok, "2 years, 11 months"}
  end

  test "10.5 - just under 24 months shows 23 months" do
    assert age("2023-06-15", "2025-06-14") == {:ok, "23 months"}
  end

  # 11. Half-year tier (3-6 years)
  test "11.1 - 3 years" do
    assert age("2022-06-15", "2025-06-15") == {:ok, "3 years"}
  end

  test "11.2 - 3 years (5 months past)" do
    assert age("2022-06-15", "2025-11-15") == {:ok, "3 years"}
  end

  test "11.3 - 3½ years" do
    assert age("2022-06-15", "2025-12-15") == {:ok, "3½ years"}
  end

  test "11.4 - 3½ years (11 months past)" do
    assert age("2022-06-15", "2026-05-15") == {:ok, "3½ years"}
  end

  test "11.5 - 4 years" do
    assert age("2021-06-15", "2025-06-15") == {:ok, "4 years"}
  end

  test "11.6 - 4½ years" do
    assert age("2021-06-15", "2025-12-15") == {:ok, "4½ years"}
  end

  test "11.7 - 5 years" do
    assert age("2020-06-15", "2025-06-15") == {:ok, "5 years"}
  end

  test "11.8 - 5½ years" do
    assert age("2020-06-15", "2026-02-15") == {:ok, "5½ years"}
  end

  test "11.9 - 6 years" do
    assert age("2019-06-15", "2025-06-15") == {:ok, "6 years"}
  end

  test "11.10 - 6½ years" do
    assert age("2019-06-15", "2025-12-15") == {:ok, "6½ years"}
  end

  test "11.11 - 6½ years (11 months past)" do
    assert age("2019-06-15", "2026-05-15") == {:ok, "6½ years"}
  end

  test "11.12 - just under 3 years shows 2 years, 11 months" do
    assert age("2022-06-15", "2025-06-14") == {:ok, "2 years, 11 months"}
  end

  # 12. Integer tier (7+ years)
  test "12.1 - 7 years" do
    assert age("2018-06-15", "2025-06-15") == {:ok, "7 years"}
  end

  test "12.2 - 7 years (3 months past)" do
    assert age("2018-03-20", "2025-06-15") == {:ok, "7 years"}
  end

  test "12.3 - 45 years" do
    assert age("1980-01-01", "2025-06-15") == {:ok, "45 years"}
  end

  # 13. Cross-year transitions with February
  test "13.1 - Dec 31 to Mar 31 = 3 months" do
    assert age("2024-12-31", "2025-03-31") == {:ok, "3 months"}
  end

  test "13.2 - Dec 31 to Mar 30 shows weeks" do
    assert contains_week?(age("2024-12-31", "2025-03-30"))
  end

  test "13.3 - Nov 30 to Feb 28 = 3 months" do
    assert age("2024-11-30", "2025-02-28") == {:ok, "3 months"}
  end

  test "13.4 - Nov 30 to Feb 27 shows weeks" do
    assert contains_week?(age("2024-11-30", "2025-02-27"))
  end

  # 14. Born-on-31st progression
  test "14.1 - Jan 31 to Apr 30 = 3 months" do
    assert age("2025-01-31", "2025-04-30") == {:ok, "3 months"}
  end

  test "14.2 - Jan 31 to May 31 = 4 months" do
    assert age("2025-01-31", "2025-05-31") == {:ok, "4 months"}
  end

  test "14.3 - Jan 31 to Jun 30 = 5 months" do
    assert age("2025-01-31", "2025-06-30") == {:ok, "5 months"}
  end

  test "14.4 - Jan 31 to Jul 1 = 5 months" do
    assert age("2025-01-31", "2025-07-01") == {:ok, "5 months"}
  end

  test "14.5 - Jan 31 to Jul 31 = 6 months" do
    assert age("2025-01-31", "2025-07-31") == {:ok, "6 months"}
  end

  # 15. Default asOf — skipped (test only pure variants)

  # 16. formatStage - null / edge cases
  test "16.1/16.2/16.3 - empty DOB returns error for stage" do
    assert stage("", "2025-06-15") == :error
  end

  test "16.4 - future DOB returns error for stage" do
    assert stage("2025-07-01", "2025-06-15") == :error
  end

  test "16.5 - 500 years old is Adult" do
    assert stage("1525-06-15", "2025-06-15") == {:ok, "Adult"}
  end

  test "16.6 - 501 years returns error for stage" do
    assert stage("1524-06-15", "2025-06-15") == :error
  end

  # 17. formatStage - Newborn
  test "17.1 - same day is Newborn" do
    assert stage("2025-06-15", "2025-06-15") == {:ok, "Newborn"}
  end

  test "17.2 - 1 day is Newborn" do
    assert stage("2025-06-14", "2025-06-15") == {:ok, "Newborn"}
  end

  test "17.3 - 3 weeks is Newborn" do
    assert stage("2025-05-25", "2025-06-15") == {:ok, "Newborn"}
  end

  test "17.4 - 1 month is Newborn" do
    assert stage("2025-05-15", "2025-06-15") == {:ok, "Newborn"}
  end

  test "17.5 - just under 2 months is Newborn" do
    assert stage("2025-04-16", "2025-06-15") == {:ok, "Newborn"}
  end

  test "17.6 - exactly 2 months is Infant" do
    assert stage("2025-04-15", "2025-06-15") == {:ok, "Infant"}
  end

  # 18. formatStage - Infant
  test "18.1 - 2 months is Infant" do
    assert stage("2025-04-15", "2025-06-15") == {:ok, "Infant"}
  end

  test "18.2 - 6 months is Infant" do
    assert stage("2024-12-15", "2025-06-15") == {:ok, "Infant"}
  end

  test "18.3 - 11 months is Infant" do
    assert stage("2024-07-15", "2025-06-15") == {:ok, "Infant"}
  end

  test "18.4 - 12 months is Toddler" do
    assert stage("2024-06-15", "2025-06-15") == {:ok, "Toddler"}
  end

  # 19. formatStage - Toddler
  test "19.1 - 12 months is Toddler" do
    assert stage("2024-06-15", "2025-06-15") == {:ok, "Toddler"}
  end

  test "19.2 - 18 months is Toddler" do
    assert stage("2024-01-15", "2025-07-15") == {:ok, "Toddler"}
  end

  test "19.3 - 24 months is Toddler" do
    assert stage("2023-06-15", "2025-06-15") == {:ok, "Toddler"}
  end

  test "19.4 - 35 months is Toddler" do
    assert stage("2023-06-15", "2026-05-15") == {:ok, "Toddler"}
  end

  test "19.5 - 36 months is Child" do
    assert stage("2022-06-15", "2025-06-15") == {:ok, "Child"}
  end

  # 20. formatStage - Child
  test "20.1 - 3 years is Child" do
    assert stage("2022-06-15", "2025-06-15") == {:ok, "Child"}
  end

  test "20.2 - 4 years is Child" do
    assert stage("2021-06-15", "2025-06-15") == {:ok, "Child"}
  end

  test "20.3 - 6 years is Child" do
    assert stage("2019-06-15", "2025-06-15") == {:ok, "Child"}
  end

  test "20.4 - 9 years is Child" do
    assert stage("2016-06-15", "2025-06-15") == {:ok, "Child"}
  end

  test "20.5 - 12 years 11 months is Child" do
    assert stage("2013-06-15", "2026-05-15") == {:ok, "Child"}
  end

  test "20.6 - 13 years is Teenager" do
    assert stage("2012-06-15", "2025-06-15") == {:ok, "Teenager"}
  end

  # 21. formatStage - Teenager
  test "21.1 - 13 years is Teenager" do
    assert stage("2012-06-15", "2025-06-15") == {:ok, "Teenager"}
  end

  test "21.2 - 15 years is Teenager" do
    assert stage("2010-06-15", "2025-06-15") == {:ok, "Teenager"}
  end

  test "21.3 - 17 years 11 months is Teenager" do
    assert stage("2008-06-15", "2026-05-15") == {:ok, "Teenager"}
  end

  test "21.4 - 18 years is Adult" do
    assert stage("2007-06-15", "2025-06-15") == {:ok, "Adult"}
  end

  # 22. formatStage - Adult
  test "22.1 - 18 years is Adult" do
    assert stage("2007-06-15", "2025-06-15") == {:ok, "Adult"}
  end

  test "22.2 - 25 years is Adult" do
    assert stage("2000-06-15", "2025-06-15") == {:ok, "Adult"}
  end

  test "22.3 - 45 years is Adult" do
    assert stage("1980-01-01", "2025-06-15") == {:ok, "Adult"}
  end

  # 23. formatStage — default asOf — skipped

  # 24. SayableAge class — English locale delegation
  test "24.1 - delegation: Newborn" do
    en = SayableAge.Locales.EN.locale()
    assert SayableAge.format_age(en, :normal, "2025-06-15", "2025-06-15") == {:ok, "Newborn"}
  end

  test "24.2 - delegation: 3 days" do
    en = SayableAge.Locales.EN.locale()
    assert SayableAge.format_age(en, :normal, "2025-06-12", "2025-06-15") == {:ok, "3 days"}
  end

  test "24.3 - delegation: 1 week, 1 day" do
    en = SayableAge.Locales.EN.locale()
    assert SayableAge.format_age(en, :normal, "2025-06-07", "2025-06-15") == {:ok, "1 week, 1 day"}
  end

  test "24.4 - delegation: 6 months" do
    en = SayableAge.Locales.EN.locale()
    assert SayableAge.format_age(en, :normal, "2025-01-15", "2025-07-15") == {:ok, "6 months"}
  end

  test "24.5 - delegation: 2 years, 1 month" do
    en = SayableAge.Locales.EN.locale()
    assert SayableAge.format_age(en, :normal, "2023-06-15", "2025-07-15") == {:ok, "2 years, 1 month"}
  end

  test "24.6 - delegation: 3½ years" do
    en = SayableAge.Locales.EN.locale()
    assert SayableAge.format_age(en, :normal, "2022-06-15", "2025-12-15") == {:ok, "3½ years"}
  end

  test "24.7 - delegation: 7 years" do
    en = SayableAge.Locales.EN.locale()
    assert SayableAge.format_age(en, :normal, "2018-06-15", "2025-06-15") == {:ok, "7 years"}
  end

  test "24.8 - delegation: stage Newborn" do
    en = SayableAge.Locales.EN.locale()
    assert SayableAge.format_stage(en, "2025-06-15", "2025-06-15", nil) == {:ok, "Newborn"}
  end

  test "24.9 - delegation: stage Infant" do
    en = SayableAge.Locales.EN.locale()
    assert SayableAge.format_stage(en, "2025-01-15", "2025-06-15", nil) == {:ok, "Infant"}
  end

  test "24.10 - delegation: stage Toddler" do
    en = SayableAge.Locales.EN.locale()
    assert SayableAge.format_stage(en, "2024-06-15", "2025-06-15", nil) == {:ok, "Toddler"}
  end

  test "24.11 - delegation: stage Child" do
    en = SayableAge.Locales.EN.locale()
    assert SayableAge.format_stage(en, "2022-06-15", "2025-06-15", nil) == {:ok, "Child"}
  end

  test "24.12 - delegation: stage Teenager" do
    en = SayableAge.Locales.EN.locale()
    assert SayableAge.format_stage(en, "2012-06-15", "2025-06-15", nil) == {:ok, "Teenager"}
  end

  test "24.13 - delegation: stage Adult" do
    en = SayableAge.Locales.EN.locale()
    assert SayableAge.format_stage(en, "2007-06-15", "2025-06-15", nil) == {:ok, "Adult"}
  end

  test "24.14 - delegation: empty DOB error" do
    en = SayableAge.Locales.EN.locale()
    assert SayableAge.format_age(en, :normal, "", "2025-06-15") == :error
  end

  test "24.15 - delegation: empty DOB stage error" do
    en = SayableAge.Locales.EN.locale()
    assert SayableAge.format_stage(en, "", "2025-06-15", nil) == :error
  end

  # 25. i18n — Spanish locale
  test "25.1 - Spanish: Newborn" do
    es = SayableAge.Locales.ES.locale()
    assert age_locale(es, "2025-06-15", "2025-06-15") == {:ok, "Recién nacido"}
  end

  test "25.2 - Spanish: 1 day" do
    es = SayableAge.Locales.ES.locale()
    assert age_locale(es, "2025-06-14", "2025-06-15") == {:ok, "1 día"}
  end

  test "25.3 - Spanish: 3 days" do
    es = SayableAge.Locales.ES.locale()
    assert age_locale(es, "2025-06-12", "2025-06-15") == {:ok, "3 días"}
  end

  test "25.4 - Spanish: 1 week" do
    es = SayableAge.Locales.ES.locale()
    assert age_locale(es, "2025-06-08", "2025-06-15") == {:ok, "1 semana"}
  end

  test "25.5 - Spanish: 1 week, 1 day" do
    es = SayableAge.Locales.ES.locale()
    assert age_locale(es, "2025-06-07", "2025-06-15") == {:ok, "1 semana, 1 día"}
  end

  test "25.6 - Spanish: 2 weeks, 6 days" do
    es = SayableAge.Locales.ES.locale()
    assert age_locale(es, "2025-05-26", "2025-06-15") == {:ok, "2 semanas, 6 días"}
  end

  test "25.7 - Spanish: 6 months" do
    es = SayableAge.Locales.ES.locale()
    assert age_locale(es, "2025-01-15", "2025-07-15") == {:ok, "6 meses"}
  end

  test "25.8 - Spanish: 2 years, 1 month" do
    es = SayableAge.Locales.ES.locale()
    assert age_locale(es, "2023-06-15", "2025-07-15") == {:ok, "2 años, 1 mes"}
  end

  test "25.9 - Spanish: 2 years, 6 months" do
    es = SayableAge.Locales.ES.locale()
    assert age_locale(es, "2023-06-15", "2025-12-15") == {:ok, "2 años, 6 meses"}
  end

  test "25.10 - Spanish: 3½ years" do
    es = SayableAge.Locales.ES.locale()
    assert age_locale(es, "2022-06-15", "2025-12-15") == {:ok, "3 y medio años"}
  end

  test "25.11 - Spanish: 3 years" do
    es = SayableAge.Locales.ES.locale()
    assert age_locale(es, "2022-06-15", "2025-06-15") == {:ok, "3 años"}
  end

  test "25.12 - Spanish: 7 years" do
    es = SayableAge.Locales.ES.locale()
    assert age_locale(es, "2018-06-15", "2025-06-15") == {:ok, "7 años"}
  end

  test "25.13 - Spanish: stage Newborn" do
    es = SayableAge.Locales.ES.locale()
    assert stage_locale(es, "2025-06-15", "2025-06-15", nil) == {:ok, "Recién nacido"}
  end

  test "25.14 - Spanish: stage Infant" do
    es = SayableAge.Locales.ES.locale()
    assert stage_locale(es, "2025-01-15", "2025-06-15", nil) == {:ok, "Bebé"}
  end

  test "25.15 - Spanish: stage Toddler" do
    es = SayableAge.Locales.ES.locale()
    assert stage_locale(es, "2024-06-15", "2025-06-15", nil) == {:ok, "Niño pequeño"}
  end

  test "25.16 - Spanish: stage Child" do
    es = SayableAge.Locales.ES.locale()
    assert stage_locale(es, "2022-06-15", "2025-06-15", nil) == {:ok, "Niño"}
  end

  test "25.17 - Spanish: stage Teenager" do
    es = SayableAge.Locales.ES.locale()
    assert stage_locale(es, "2012-06-15", "2025-06-15", nil) == {:ok, "Adolescente"}
  end

  test "25.18 - Spanish: stage Adult" do
    es = SayableAge.Locales.ES.locale()
    assert stage_locale(es, "2007-06-15", "2025-06-15", nil) == {:ok, "Adulto"}
  end

  test "25.19 - Spanish: empty DOB error" do
    es = SayableAge.Locales.ES.locale()
    assert age_locale(es, "", "2025-06-15") == :error
  end

  test "25.20 - Spanish: empty DOB stage error" do
    es = SayableAge.Locales.ES.locale()
    assert stage_locale(es, "", "2025-06-15", nil) == :error
  end

  # 26. Compactness - short
  test "26.1 - short: 3 days" do
    assert age_short("2025-06-12", "2025-06-15") == {:ok, "3 d"}
  end

  test "26.2 - short: 1 week" do
    assert age_short("2025-06-08", "2025-06-15") == {:ok, "1 wk"}
  end

  test "26.3 - short: 1 week, 1 day" do
    assert age_short("2025-06-07", "2025-06-15") == {:ok, "1 wk, 1 d"}
  end

  test "26.4 - short: 6 months" do
    assert age_short("2025-01-15", "2025-07-15") == {:ok, "6 mo"}
  end

  test "26.5 - short: 2 years, 1 month" do
    assert age_short("2023-06-15", "2025-07-15") == {:ok, "2 yr, 1 mo"}
  end

  test "26.6 - short: 3½ years" do
    assert age_short("2022-06-15", "2025-12-15") == {:ok, "3½ yr"}
  end

  test "26.7 - short: 7 years" do
    assert age_short("2018-06-15", "2025-06-15") == {:ok, "7 yr"}
  end

  test "26.8 - short: Newborn" do
    assert age_short("2025-06-15", "2025-06-15") == {:ok, "Newborn"}
  end

  test "26.9 - short: stage still works" do
    assert stage("2025-01-15", "2025-06-15") == {:ok, "Infant"}
  end

  # 27. Compactness - compact
  test "27.1 - compact: 3 days" do
    assert age_compact("2025-06-12", "2025-06-15") == {:ok, "3d"}
  end

  test "27.2 - compact: 1 week" do
    assert age_compact("2025-06-08", "2025-06-15") == {:ok, "1w"}
  end

  test "27.3 - compact: 1 week, 1 day" do
    assert age_compact("2025-06-07", "2025-06-15") == {:ok, "1w1d"}
  end

  test "27.4 - compact: 6 months" do
    assert age_compact("2025-01-15", "2025-07-15") == {:ok, "6m"}
  end

  test "27.5 - compact: 2 years, 1 month" do
    assert age_compact("2023-06-15", "2025-07-15") == {:ok, "2y1m"}
  end

  test "27.6 - compact: 3½ years" do
    assert age_compact("2022-06-15", "2025-12-15") == {:ok, "3½y"}
  end

  test "27.7 - compact: 7 years" do
    assert age_compact("2018-06-15", "2025-06-15") == {:ok, "7y"}
  end

  test "27.8 - compact: Newborn" do
    assert age_compact("2025-06-15", "2025-06-15") == {:ok, "Newborn"}
  end

  # 29. Locale-specific edge cases

  # 29.1 — Hebrew (he) — dual forms
  test "29.1 - Hebrew: Newborn" do
    he = SayableAge.Locales.HE.locale()
    assert age_locale(he, "2025-06-15", "2025-06-15") == {:ok, "רק נולד"}
  end

  test "29.2 - Hebrew: 1 day" do
    he = SayableAge.Locales.HE.locale()
    assert age_locale(he, "2025-06-14", "2025-06-15") == {:ok, "יום 1"}
  end

  test "29.3 - Hebrew: 3 days" do
    he = SayableAge.Locales.HE.locale()
    assert age_locale(he, "2025-06-12", "2025-06-15") == {:ok, "3 ימים"}
  end

  test "29.4 - Hebrew: 2 weeks" do
    he = SayableAge.Locales.HE.locale()
    assert age_locale(he, "2025-06-01", "2025-06-15") == {:ok, "שבועיים"}
  end

  test "29.5 - Hebrew: 3 weeks" do
    he = SayableAge.Locales.HE.locale()
    assert age_locale(he, "2025-05-25", "2025-06-15") == {:ok, "3 שבועות"}
  end

  test "29.6 - Hebrew: 6 months" do
    he = SayableAge.Locales.HE.locale()
    assert age_locale(he, "2025-01-15", "2025-07-15") == {:ok, "6 חודשים"}
  end

  test "29.7 - Hebrew: 3 months" do
    he = SayableAge.Locales.HE.locale()
    assert age_locale(he, "2025-03-15", "2025-06-15") == {:ok, "3 חודשים"}
  end

  test "29.8 - Hebrew: 2 years, 1 month" do
    he = SayableAge.Locales.HE.locale()
    assert age_locale(he, "2023-06-15", "2025-07-15") == {:ok, "שנתיים, חודש 1"}
  end

  test "29.9 - Hebrew: 3½ years" do
    he = SayableAge.Locales.HE.locale()
    assert age_locale(he, "2022-06-15", "2025-12-15") == {:ok, "3 שנים וחצי"}
  end

  test "29.10 - Hebrew: 7 years" do
    he = SayableAge.Locales.HE.locale()
    assert age_locale(he, "2018-06-15", "2025-06-15") == {:ok, "7 שנים"}
  end

  test "29.11 - Hebrew: stage Newborn male" do
    he = SayableAge.Locales.HE.locale()
    assert stage_locale(he, "2025-06-15", "2025-06-15", :male) == {:ok, "רק נולד"}
  end

  test "29.12 - Hebrew: stage Newborn female" do
    he = SayableAge.Locales.HE.locale()
    assert stage_locale(he, "2025-06-15", "2025-06-15", :female) == {:ok, "רק נולדה"}
  end

  test "29.13 - Hebrew: stage Adult male" do
    he = SayableAge.Locales.HE.locale()
    assert stage_locale(he, "2007-06-15", "2025-06-15", :male) == {:ok, "מבוגר"}
  end

  test "29.14 - Hebrew: stage Adult female" do
    he = SayableAge.Locales.HE.locale()
    assert stage_locale(he, "2007-06-15", "2025-06-15", :female) == {:ok, "מבוגרת"}
  end

  # 29.2 — Macedonian (mk)
  test "29.15 - Macedonian: Newborn" do
    mk = SayableAge.Locales.MK.locale()
    assert age_locale(mk, "2025-06-15", "2025-06-15") == {:ok, "Новороденче"}
  end

  test "29.16 - Macedonian: 1 day" do
    mk = SayableAge.Locales.MK.locale()
    assert age_locale(mk, "2025-06-14", "2025-06-15") == {:ok, "1 ден"}
  end

  test "29.17 - Macedonian: 3 days" do
    mk = SayableAge.Locales.MK.locale()
    assert age_locale(mk, "2025-06-12", "2025-06-15") == {:ok, "3 дена"}
  end

  test "29.18 - Macedonian: 6 months" do
    mk = SayableAge.Locales.MK.locale()
    assert age_locale(mk, "2025-01-15", "2025-07-15") == {:ok, "6 месеци"}
  end

  test "29.19 - Macedonian: 2 years, 1 month" do
    mk = SayableAge.Locales.MK.locale()
    assert age_locale(mk, "2023-06-15", "2025-07-15") == {:ok, "2 години, 1 месец"}
  end

  test "29.20 - Macedonian: 3½ years" do
    mk = SayableAge.Locales.MK.locale()
    assert age_locale(mk, "2022-06-15", "2025-12-15") == {:ok, "3 години и пол"}
  end

  test "29.21 - Macedonian: 7 years" do
    mk = SayableAge.Locales.MK.locale()
    assert age_locale(mk, "2018-06-15", "2025-06-15") == {:ok, "7 години"}
  end

  # 29.3 — Swahili (sw)
  test "29.22 - Swahili: Newborn" do
    sw = SayableAge.Locales.SW.locale()
    assert age_locale(sw, "2025-06-15", "2025-06-15") == {:ok, "Mzaliwa mpya"}
  end

  test "29.23 - Swahili: 1 day" do
    sw = SayableAge.Locales.SW.locale()
    assert age_locale(sw, "2025-06-14", "2025-06-15") == {:ok, "siku 1"}
  end

  test "29.24 - Swahili: 3 days" do
    sw = SayableAge.Locales.SW.locale()
    assert age_locale(sw, "2025-06-12", "2025-06-15") == {:ok, "siku 3"}
  end

  test "29.25 - Swahili: 6 months" do
    sw = SayableAge.Locales.SW.locale()
    assert age_locale(sw, "2025-01-15", "2025-07-15") == {:ok, "miezi 6"}
  end

  test "29.26 - Swahili: 2 years, 1 month" do
    sw = SayableAge.Locales.SW.locale()
    assert age_locale(sw, "2023-06-15", "2025-07-15") == {:ok, "miaka 2, mwezi 1"}
  end

  test "29.27 - Swahili: 3½ years" do
    sw = SayableAge.Locales.SW.locale()
    assert age_locale(sw, "2022-06-15", "2025-12-15") == {:ok, "miaka 3 na nusu"}
  end

  # 29.4 — Indonesian (id) — other_only
  test "29.28 - Indonesian: Newborn" do
    id = SayableAge.Locales.ID.locale()
    assert age_locale(id, "2025-06-15", "2025-06-15") == {:ok, "Baru lahir"}
  end

  test "29.29 - Indonesian: 1 day" do
    id = SayableAge.Locales.ID.locale()
    assert age_locale(id, "2025-06-14", "2025-06-15") == {:ok, "1 hari"}
  end

  test "29.30 - Indonesian: 3 days" do
    id = SayableAge.Locales.ID.locale()
    assert age_locale(id, "2025-06-12", "2025-06-15") == {:ok, "3 hari"}
  end

  test "29.31 - Indonesian: 6 months" do
    id = SayableAge.Locales.ID.locale()
    assert age_locale(id, "2025-01-15", "2025-07-15") == {:ok, "6 bulan"}
  end

  test "29.32 - Indonesian: 3½ years" do
    id = SayableAge.Locales.ID.locale()
    assert age_locale(id, "2022-06-15", "2025-12-15") == {:ok, "3 tahun setengah"}
  end

  test "29.33 - Indonesian: 7 years" do
    id = SayableAge.Locales.ID.locale()
    assert age_locale(id, "2018-06-15", "2025-06-15") == {:ok, "7 tahun"}
  end

  # 29.5 — Amharic (am)
  test "29.34 - Amharic: Newborn" do
    am = SayableAge.Locales.AM.locale()
    assert age_locale(am, "2025-06-15", "2025-06-15") == {:ok, "አዲስ የተወለደ"}
  end

  test "29.35 - Amharic: 1 day" do
    am = SayableAge.Locales.AM.locale()
    assert age_locale(am, "2025-06-14", "2025-06-15") == {:ok, "1 ቀን"}
  end

  test "29.36 - Amharic: 3 days" do
    am = SayableAge.Locales.AM.locale()
    assert age_locale(am, "2025-06-12", "2025-06-15") == {:ok, "3 ቀናት"}
  end

  test "29.37 - Amharic: 1 week, 1 day" do
    am = SayableAge.Locales.AM.locale()
    assert age_locale(am, "2025-06-07", "2025-06-15") == {:ok, "1 ሳምንት፣ 1 ቀን"}
  end

  test "29.38 - Amharic: 6 months" do
    am = SayableAge.Locales.AM.locale()
    assert age_locale(am, "2025-01-15", "2025-07-15") == {:ok, "6 ወራት"}
  end

  test "29.39 - Amharic: 3½ years" do
    am = SayableAge.Locales.AM.locale()
    assert age_locale(am, "2022-06-15", "2025-12-15") == {:ok, "3 ዓመታት ተኩል"}
  end

  # 30. Locale lookup by code string
  test "30.1 - locale lookup: en" do
    {:ok, locale} = SayableAge.get_locale("en")
    assert locale.code == "en"
  end

  test "30.2 - locale lookup: fr" do
    {:ok, locale} = SayableAge.get_locale("fr")
    assert locale.code == "fr"
  end

  test "30.3 - locale lookup: unknown code" do
    assert SayableAge.get_locale("xx") == :error
  end

  test "30.4 - locale lookup: empty string" do
    assert SayableAge.get_locale("") == :error
  end

  test "30.5 - locale lookup: uppercase fails" do
    assert SayableAge.get_locale("EN") == :error
  end
end
