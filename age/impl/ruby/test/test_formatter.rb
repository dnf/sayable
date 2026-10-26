# frozen_string_literal: true

require 'minitest/autorun'
require 'sayable_age'

# All tests use explicit (dob, as_of) pairs for determinism.

class TestFormatAge < Minitest::Test
  # ================================================================
  # Null / edge cases
  # ================================================================
  # 1.1
  def test_returns_nil_for_nil_input
    assert_nil SayableAge.format_age(nil, '2025-06-15')
  end

  # 1.3
  def test_returns_nil_for_empty_string
    assert_nil SayableAge.format_age('', '2025-06-15')
  end

  # 1.4
  def test_returns_nil_for_future_dob
    assert_nil SayableAge.format_age('2025-07-01', '2025-06-15')
  end

  # 1.5
  def test_exactly_500_years_is_allowed
    assert_equal '500 years', SayableAge.format_age('1525-06-15', '2025-06-15')
  end

  # 1.6
  def test_501_years_exceeds_max_age
    assert_nil SayableAge.format_age('1524-06-15', '2025-06-15')
  end

  # 1.7
  def test_1000_years_exceeds_max_age
    assert_nil SayableAge.format_age('1025-06-15', '2025-06-15')
  end

  # ================================================================
  # Days tier: 0-6 days
  # ================================================================
  # 2.1
  def test_born_today_newborn
    assert_equal 'Newborn', SayableAge.format_age('2025-06-15', '2025-06-15')
  end

  # 2.2
  def test_1_day_singular
    assert_equal '1 day', SayableAge.format_age('2025-06-14', '2025-06-15')
  end

  # 2.3
  def test_3_days
    assert_equal '3 days', SayableAge.format_age('2025-06-12', '2025-06-15')
  end

  # 2.4
  def test_6_days
    assert_equal '6 days', SayableAge.format_age('2025-06-09', '2025-06-15')
  end

  # 2.5
  def test_7_days_becomes_1_week
    assert_equal '1 week', SayableAge.format_age('2025-06-08', '2025-06-15')
  end

  # ================================================================
  # Weeks+days tier: 7 days to <3 months
  # ================================================================
  # 3.1
  def test_7_days
    assert_equal '1 week', SayableAge.format_age('2025-06-08', '2025-06-15')
  end

  # 3.2
  def test_8_days
    assert_equal '1 week, 1 day', SayableAge.format_age('2025-06-07', '2025-06-15')
  end

  # 3.3
  def test_9_days
    assert_equal '1 week, 2 days', SayableAge.format_age('2025-06-06', '2025-06-15')
  end

  # 3.4
  def test_13_days
    assert_equal '1 week, 6 days', SayableAge.format_age('2025-06-02', '2025-06-15')
  end

  # 3.5
  def test_14_days
    assert_equal '2 weeks', SayableAge.format_age('2025-06-01', '2025-06-15')
  end

  # 3.6
  def test_15_days
    assert_equal '2 weeks, 1 day', SayableAge.format_age('2025-05-31', '2025-06-15')
  end

  # 3.7
  def test_20_days
    assert_equal '2 weeks, 6 days', SayableAge.format_age('2025-05-26', '2025-06-15')
  end

  # 3.8
  def test_21_days
    assert_equal '3 weeks', SayableAge.format_age('2025-05-25', '2025-06-15')
  end

  # 3.9
  def test_at_1_cal_month_still_weeks_days
    assert_equal '4 weeks, 3 days', SayableAge.format_age('2025-05-15', '2025-06-15')
  end

  # 3.10
  def test_at_2_cal_months_still_weeks_days
    assert_equal '8 weeks, 5 days', SayableAge.format_age('2025-04-15', '2025-06-15')
  end

  # 3.11
  def test_one_day_before_3mo_still_weeks
    assert_equal '13 weeks', SayableAge.format_age('2025-03-15', '2025-06-14')
  end

  # 3.12
  def test_on_3mo_birthday_switches
    assert_equal '3 months', SayableAge.format_age('2025-03-15', '2025-06-15')
  end

  # ================================================================
  # Month boundaries: standard months
  # ================================================================
  # 4.1
  def test_jan1_apr1_3mo
    assert_equal '3 months', SayableAge.format_age('2025-01-01', '2025-04-01')
  end

  # 4.2
  def test_jan1_mar31_still_weeks
    assert_match(/weeks/, SayableAge.format_age('2025-01-01', '2025-03-31'))
  end

  # 4.3
  def test_jun15_sep15_3mo
    assert_equal '3 months', SayableAge.format_age('2025-06-15', '2025-09-15')
  end

  # 4.4
  def test_jun15_sep14_still_weeks
    assert_match(/weeks/, SayableAge.format_age('2025-06-15', '2025-09-14'))
  end

  # 4.5
  def test_jun15_dec15_6mo
    assert_equal '6 months', SayableAge.format_age('2025-06-15', '2025-12-15')
  end

  # ================================================================
  # Month boundaries: February non-leap
  # ================================================================
  # 5.1
  def test_jan31_feb28_non_leap
    assert_equal '4 weeks', SayableAge.format_age('2025-01-31', '2025-02-28')
  end

  # 5.2
  def test_jan31_apr30_3mo_clamp
    assert_equal '3 months', SayableAge.format_age('2025-01-31', '2025-04-30')
  end

  # 5.3
  def test_jan31_apr29_still_weeks
    assert_match(/weeks/, SayableAge.format_age('2025-01-31', '2025-04-29'))
  end

  # 5.4
  def test_feb1_may1_3mo
    assert_equal '3 months', SayableAge.format_age('2025-02-01', '2025-05-01')
  end

  # 5.5
  def test_feb1_apr30_still_weeks
    assert_match(/weeks/, SayableAge.format_age('2025-02-01', '2025-04-30'))
  end

  # ================================================================
  # Month boundaries: February leap year
  # ================================================================
  # 6.1
  def test_jan31_feb29_leap
    assert_equal '4 weeks, 1 day', SayableAge.format_age('2024-01-31', '2024-02-29')
  end

  # 6.2
  def test_jan31_feb28_leap
    assert_equal '4 weeks', SayableAge.format_age('2024-01-31', '2024-02-28')
  end

  # 6.3
  def test_jan31_apr30_leap_3mo
    assert_equal '3 months', SayableAge.format_age('2024-01-31', '2024-04-30')
  end

  # 6.4
  def test_jan30_feb29_leap_still_weeks
    assert_match(/weeks/, SayableAge.format_age('2024-01-30', '2024-02-29'))
  end

  # 6.5
  def test_jan30_feb28_leap_still_weeks
    assert_match(/weeks/, SayableAge.format_age('2024-01-30', '2024-02-28'))
  end

  # ================================================================
  # Month boundaries: 30-day months
  # ================================================================
  # 7.1
  def test_mar31_jun30_3mo
    assert_equal '3 months', SayableAge.format_age('2025-03-31', '2025-06-30')
  end

  # 7.2
  def test_mar31_jun29_still_weeks
    assert_match(/weeks/, SayableAge.format_age('2025-03-31', '2025-06-29'))
  end

  # 7.3
  def test_aug31_nov30_3mo
    assert_equal '3 months', SayableAge.format_age('2025-08-31', '2025-11-30')
  end

  # 7.4
  def test_aug31_nov29_still_weeks
    assert_match(/weeks/, SayableAge.format_age('2025-08-31', '2025-11-29'))
  end

  # ================================================================
  # Month boundaries: leap year baby (born Feb 29)
  # ================================================================
  # 8.1
  def test_feb29_may29_3mo
    assert_equal '3 months', SayableAge.format_age('2024-02-29', '2024-05-29')
  end

  # 8.2
  def test_feb29_may28_still_weeks
    assert_match(/weeks/, SayableAge.format_age('2024-02-29', '2024-05-28'))
  end

  # 8.3
  def test_feb29_2024_feb28_2025_12mo
    assert_equal '12 months', SayableAge.format_age('2024-02-29', '2025-02-28')
  end

  # 8.4
  def test_feb29_2024_mar1_2025_12mo
    assert_equal '12 months', SayableAge.format_age('2024-02-29', '2025-03-01')
  end

  # ================================================================
  # Months tier: 3-23 months
  # ================================================================
  # 9.1
  def test_3_months_at_transition
    assert_equal '3 months', SayableAge.format_age('2025-01-15', '2025-04-15')
  end

  # 9.2
  def test_6_months
    assert_equal '6 months', SayableAge.format_age('2025-01-15', '2025-07-15')
  end

  # 9.3
  def test_12_months_not_1_year
    assert_equal '12 months', SayableAge.format_age('2024-06-15', '2025-06-15')
  end

  # 9.4
  def test_23_months_upper_boundary
    assert_equal '23 months', SayableAge.format_age('2024-01-15', '2025-12-15')
  end

  # 9.5
  def test_one_day_before_month_boundary
    assert_equal '5 months', SayableAge.format_age('2025-01-15', '2025-07-14')
  end

  # 9.6
  def test_crossing_year_boundary
    assert_equal '5 months', SayableAge.format_age('2024-11-10', '2025-04-10')
  end

  # ================================================================
  # Years+months tier: 24-35 months
  # ================================================================
  # 10.1
  def test_2_years_at_24mo
    assert_equal '2 years', SayableAge.format_age('2023-06-15', '2025-06-15')
  end

  # 10.2
  def test_2_years_1_month
    assert_equal '2 years, 1 month', SayableAge.format_age('2023-06-15', '2025-07-15')
  end

  # 10.3
  def test_2_years_6_months
    assert_equal '2 years, 6 months', SayableAge.format_age('2023-06-15', '2025-12-15')
  end

  # 10.4
  def test_2_years_11_months
    assert_equal '2 years, 11 months', SayableAge.format_age('2023-06-15', '2026-05-15')
  end

  # 10.5
  def test_one_day_before_24mo_stays_months
    assert_equal '23 months', SayableAge.format_age('2023-06-15', '2025-06-14')
  end

  # ================================================================
  # Half-year tier: 3-6 years
  # ================================================================
  # 11.1
  def test_3_years_exactly
    assert_equal '3 years', SayableAge.format_age('2022-06-15', '2025-06-15')
  end

  # 11.2
  def test_3_years_5_months
    assert_equal '3 years', SayableAge.format_age('2022-06-15', '2025-11-15')
  end

  # 11.3
  def test_3_half_years_at_3y6m
    assert_equal "3\u00BD years", SayableAge.format_age('2022-06-15', '2025-12-15')
  end

  # 11.4
  def test_3_half_years_at_3y11m
    assert_equal "3\u00BD years", SayableAge.format_age('2022-06-15', '2026-05-15')
  end

  # 11.5
  def test_4_years_exactly
    assert_equal '4 years', SayableAge.format_age('2021-06-15', '2025-06-15')
  end

  # 11.6
  def test_4_half_years
    assert_equal "4\u00BD years", SayableAge.format_age('2021-06-15', '2025-12-15')
  end

  # 11.7
  def test_5_years
    assert_equal '5 years', SayableAge.format_age('2020-06-15', '2025-06-15')
  end

  # 11.8
  def test_5_half_years_at_5y8m
    assert_equal "5\u00BD years", SayableAge.format_age('2020-06-15', '2026-02-15')
  end

  # 11.9
  def test_6_years
    assert_equal '6 years', SayableAge.format_age('2019-06-15', '2025-06-15')
  end

  # 11.10
  def test_6_half_years
    assert_equal "6\u00BD years", SayableAge.format_age('2019-06-15', '2025-12-15')
  end

  # 11.11
  def test_6_half_years_at_6y11m
    assert_equal "6\u00BD years", SayableAge.format_age('2019-06-15', '2026-05-15')
  end

  # 11.12
  def test_one_day_before_3rd_bday
    assert_equal '2 years, 11 months', SayableAge.format_age('2022-06-15', '2025-06-14')
  end

  # ================================================================
  # Integer tier: 7+ years
  # ================================================================
  # 12.1
  def test_7_years_exactly
    assert_equal '7 years', SayableAge.format_age('2018-06-15', '2025-06-15')
  end

  # 12.2
  def test_7_years_6_months_no_half
    assert_equal '7 years', SayableAge.format_age('2018-03-20', '2025-06-15')
  end

  # 12.3
  def test_45_years
    assert_equal '45 years', SayableAge.format_age('1980-01-01', '2025-06-15')
  end

  # ================================================================
  # Cross-year transitions with Feb
  # ================================================================
  # 13.1
  def test_dec31_mar31_3mo
    assert_equal '3 months', SayableAge.format_age('2024-12-31', '2025-03-31')
  end

  # 13.2
  def test_dec31_mar30_still_weeks
    assert_match(/weeks/, SayableAge.format_age('2024-12-31', '2025-03-30'))
  end

  # 13.3
  def test_nov30_feb28_3mo
    assert_equal '3 months', SayableAge.format_age('2024-11-30', '2025-02-28')
  end

  # 13.4
  def test_nov30_feb27_still_weeks
    assert_match(/weeks/, SayableAge.format_age('2024-11-30', '2025-02-27'))
  end

  # ================================================================
  # Born-on-31st progression
  # ================================================================
  # 14.1
  def test_jan31_apr30_3mo
    assert_equal '3 months', SayableAge.format_age('2025-01-31', '2025-04-30')
  end

  # 14.2
  def test_jan31_may31_4mo
    assert_equal '4 months', SayableAge.format_age('2025-01-31', '2025-05-31')
  end

  # 14.3
  def test_jan31_jun30_5mo_clamped
    assert_equal '5 months', SayableAge.format_age('2025-01-31', '2025-06-30')
  end

  # 14.4
  def test_jan31_jul1_5mo
    assert_equal '5 months', SayableAge.format_age('2025-01-31', '2025-07-01')
  end

  # 14.5
  def test_jan31_jul31_6mo
    assert_equal '6 months', SayableAge.format_age('2025-01-31', '2025-07-31')
  end

  # ================================================================
  # Default as_of (uses current date)
  # ================================================================
  # 15.1, 15.2
  def test_default_as_of
    original = Date.method(:today)
    Date.define_singleton_method(:today) { Date.new(2025, 6, 15) }
    assert_equal '5 years', SayableAge.format_age('2020-01-01')
    assert_equal '5 days', SayableAge.format_age('2025-06-10')
  ensure
    Date.define_singleton_method(:today, original)
  end
end

# ================================================================
# formatStage
# ================================================================
class TestFormatStage < Minitest::Test
  # 16.1
  def test_returns_nil_for_nil
    assert_nil SayableAge.format_stage(nil, '2025-06-15')
  end

  # 16.3
  def test_returns_nil_for_empty
    assert_nil SayableAge.format_stage('', '2025-06-15')
  end

  # 16.4
  def test_returns_nil_for_future
    assert_nil SayableAge.format_stage('2025-07-01', '2025-06-15')
  end

  # 16.5
  def test_exactly_500_years_returns_adult
    assert_equal 'Adult', SayableAge.format_stage('1525-06-15', '2025-06-15')
  end

  # 16.6
  def test_501_years_exceeds_max_age
    assert_nil SayableAge.format_stage('1524-06-15', '2025-06-15')
  end

  # Newborn: 0-1 months
  # 17.1
  def test_newborn_born_today
    assert_equal 'Newborn', SayableAge.format_stage('2025-06-15', '2025-06-15')
  end

  # 17.2
  def test_newborn_1_day
    assert_equal 'Newborn', SayableAge.format_stage('2025-06-14', '2025-06-15')
  end

  # 17.3
  def test_newborn_3_weeks
    assert_equal 'Newborn', SayableAge.format_stage('2025-05-25', '2025-06-15')
  end

  # 17.4
  def test_newborn_1_month
    assert_equal 'Newborn', SayableAge.format_stage('2025-05-15', '2025-06-15')
  end

  # 17.5
  def test_newborn_1_month_29_days
    assert_equal 'Newborn', SayableAge.format_stage('2025-04-16', '2025-06-15')
  end

  # 17.6
  def test_exactly_2_months_infant
    assert_equal 'Infant', SayableAge.format_stage('2025-04-15', '2025-06-15')
  end

  # Infant: 2-11 months
  # 18.1
  def test_infant_2_months
    assert_equal 'Infant', SayableAge.format_stage('2025-04-15', '2025-06-15')
  end

  # 18.2
  def test_infant_6_months
    assert_equal 'Infant', SayableAge.format_stage('2024-12-15', '2025-06-15')
  end

  # 18.3
  def test_infant_11_months
    assert_equal 'Infant', SayableAge.format_stage('2024-07-15', '2025-06-15')
  end

  # 18.4
  def test_exactly_12_months_toddler
    assert_equal 'Toddler', SayableAge.format_stage('2024-06-15', '2025-06-15')
  end

  # Toddler: 12-35 months
  # 19.1
  def test_toddler_12_months
    assert_equal 'Toddler', SayableAge.format_stage('2024-06-15', '2025-06-15')
  end

  # 19.2
  def test_toddler_18_months
    assert_equal 'Toddler', SayableAge.format_stage('2024-01-15', '2025-07-15')
  end

  # 19.3
  def test_toddler_24_months
    assert_equal 'Toddler', SayableAge.format_stage('2023-06-15', '2025-06-15')
  end

  # 19.4
  def test_toddler_35_months
    assert_equal 'Toddler', SayableAge.format_stage('2023-06-15', '2026-05-15')
  end

  # 19.5
  def test_exactly_36_months_child
    assert_equal 'Child', SayableAge.format_stage('2022-06-15', '2025-06-15')
  end

  # Child: 36-155 months
  # 20.1
  def test_child_3_years
    assert_equal 'Child', SayableAge.format_stage('2022-06-15', '2025-06-15')
  end

  # 20.2
  def test_child_4_years
    assert_equal 'Child', SayableAge.format_stage('2021-06-15', '2025-06-15')
  end

  # 20.3
  def test_child_6_years
    assert_equal 'Child', SayableAge.format_stage('2019-06-15', '2025-06-15')
  end

  # 20.4
  def test_child_9_years
    assert_equal 'Child', SayableAge.format_stage('2016-06-15', '2025-06-15')
  end

  # 20.5
  def test_child_12y11m
    assert_equal 'Child', SayableAge.format_stage('2013-06-15', '2026-05-15')
  end

  # 20.6
  def test_exactly_13_years_teenager
    assert_equal 'Teenager', SayableAge.format_stage('2012-06-15', '2025-06-15')
  end

  # Teenager: 156-215 months
  # 21.1
  def test_teenager_13_years
    assert_equal 'Teenager', SayableAge.format_stage('2012-06-15', '2025-06-15')
  end

  # 21.2
  def test_teenager_15_years
    assert_equal 'Teenager', SayableAge.format_stage('2010-06-15', '2025-06-15')
  end

  # 21.3
  def test_teenager_17y11m
    assert_equal 'Teenager', SayableAge.format_stage('2008-06-15', '2026-05-15')
  end

  # 21.4
  def test_exactly_18_years_adult
    assert_equal 'Adult', SayableAge.format_stage('2007-06-15', '2025-06-15')
  end

  # Adult: 216+ months
  # 22.1
  def test_adult_18_years
    assert_equal 'Adult', SayableAge.format_stage('2007-06-15', '2025-06-15')
  end

  # 22.2
  def test_adult_25_years
    assert_equal 'Adult', SayableAge.format_stage('2000-06-15', '2025-06-15')
  end

  # 22.3
  def test_adult_45_years
    assert_equal 'Adult', SayableAge.format_stage('1980-01-01', '2025-06-15')
  end

  # 23.1, 23.2, 23.3
  def test_stage_default_as_of
    original = Date.method(:today)
    Date.define_singleton_method(:today) { Date.new(2025, 6, 15) }
    assert_equal 'Newborn', SayableAge.format_stage('2025-06-15')
    assert_equal 'Child', SayableAge.format_stage('2020-01-01')
    assert_equal 'Adult', SayableAge.format_stage('1980-01-01')
  ensure
    Date.define_singleton_method(:today, original)
  end
end

# ================================================================
# SayableAge::Formatter class
# ================================================================
class TestFormatter < Minitest::Test
  # 24.1, 24.2, 24.3, 24.4, 24.5, 24.6, 24.7
  def test_english_format_age
    pt = SayableAge::Formatter.new(SayableAge::Locales::EN)
    assert_equal 'Newborn', pt.format_age('2025-06-15', '2025-06-15')
    assert_equal '3 days', pt.format_age('2025-06-12', '2025-06-15')
    assert_equal '1 week, 1 day', pt.format_age('2025-06-07', '2025-06-15')
    assert_equal '6 months', pt.format_age('2025-01-15', '2025-07-15')
    assert_equal '2 years, 1 month', pt.format_age('2023-06-15', '2025-07-15')
    assert_equal "3\u00BD years", pt.format_age('2022-06-15', '2025-12-15')
    assert_equal '7 years', pt.format_age('2018-06-15', '2025-06-15')
  end

  # 24.8, 24.9, 24.10, 24.11, 24.12, 24.13
  def test_english_format_stage
    pt = SayableAge::Formatter.new(SayableAge::Locales::EN)
    assert_equal 'Newborn', pt.format_stage('2025-06-15', '2025-06-15')
    assert_equal 'Infant', pt.format_stage('2025-01-15', '2025-06-15')
    assert_equal 'Toddler', pt.format_stage('2024-06-15', '2025-06-15')
    assert_equal 'Child', pt.format_stage('2022-06-15', '2025-06-15')
    assert_equal 'Teenager', pt.format_stage('2012-06-15', '2025-06-15')
    assert_equal 'Adult', pt.format_stage('2007-06-15', '2025-06-15')
  end

  # 24.14, 24.15
  def test_null_handling
    pt = SayableAge::Formatter.new(SayableAge::Locales::EN)
    assert_nil pt.format_age(nil, '2025-06-15')
    assert_nil pt.format_stage(nil, '2025-06-15')
    assert_nil pt.format_age('', '2025-06-15')
  end

  # Spanish-like locale
  # 25.1, 25.2, 25.3, 25.4, 25.5, 25.6, 25.7, 25.8, 25.9, 25.10, 25.11, 25.12, 25.13, 25.14, 25.15, 25.16, 25.17, 25.18, 25.19, 25.20
  def test_spanish_locale
    es = SayableAge::AgeLocale.new(
      code: 'es',
      plural: ->(n) { n == 1 ? :one : :other },
      units: {
        'day' => { one: '{n} día', other: '{n} días' },
        'week' => { one: '{n} semana', other: '{n} semanas' },
        'month' => { one: '{n} mes', other: '{n} meses' },
        'year' => { one: '{n} año', other: '{n} años' },
      },
      half: '{0} y medio',
      delimiter: ', ',
      just_born: 'Recién nacido',
      stages: {
        newborn: 'Recién nacido',
        infant: 'Bebé',
        toddler: 'Niño pequeño',
        child: 'Niño',
        teenager: 'Adolescente',
        adult: 'Adulto',
      },
    )

    pt = SayableAge::Formatter.new(es)

    assert_equal 'Recién nacido', pt.format_age('2025-06-15', '2025-06-15')
    assert_equal '1 día', pt.format_age('2025-06-14', '2025-06-15')
    assert_equal '3 días', pt.format_age('2025-06-12', '2025-06-15')
    assert_equal '1 semana', pt.format_age('2025-06-08', '2025-06-15')
    assert_equal '1 semana, 1 día', pt.format_age('2025-06-07', '2025-06-15')
    assert_equal '2 semanas, 6 días', pt.format_age('2025-05-26', '2025-06-15')
    assert_equal '6 meses', pt.format_age('2025-01-15', '2025-07-15')
    assert_equal '2 años, 1 mes', pt.format_age('2023-06-15', '2025-07-15')
    assert_equal '2 años, 6 meses', pt.format_age('2023-06-15', '2025-12-15')
    assert_equal '3 años y medio', pt.format_age('2022-06-15', '2025-12-15')
    assert_equal '3 años', pt.format_age('2022-06-15', '2025-06-15')
    assert_equal '7 años', pt.format_age('2018-06-15', '2025-06-15')

    assert_equal 'Recién nacido', pt.format_stage('2025-06-15', '2025-06-15')
    assert_equal 'Bebé', pt.format_stage('2025-01-15', '2025-06-15')
    assert_equal 'Niño pequeño', pt.format_stage('2024-06-15', '2025-06-15')
    assert_equal 'Niño', pt.format_stage('2022-06-15', '2025-06-15')
    assert_equal 'Adolescente', pt.format_stage('2012-06-15', '2025-06-15')
    assert_equal 'Adulto', pt.format_stage('2007-06-15', '2025-06-15')

    assert_nil pt.format_age(nil, '2025-06-15')
    assert_nil pt.format_stage(nil, '2025-06-15')
  end

  # Compactness: short
  # 26.1, 26.2, 26.3, 26.4, 26.5, 26.6, 26.7, 26.8, 26.9
  def test_compactness_short
    pt = SayableAge::Formatter.new(SayableAge::Locales::EN, compactness: :short)

    assert_equal '3 d', pt.format_age('2025-06-12', '2025-06-15')
    assert_equal '1 wk', pt.format_age('2025-06-08', '2025-06-15')
    assert_equal '1 wk, 1 d', pt.format_age('2025-06-07', '2025-06-15')
    assert_equal '6 mo', pt.format_age('2025-01-15', '2025-07-15')
    assert_equal '2 yr, 1 mo', pt.format_age('2023-06-15', '2025-07-15')
    assert_equal "3\u00BD yr", pt.format_age('2022-06-15', '2025-12-15')
    assert_equal '7 yr', pt.format_age('2018-06-15', '2025-06-15')
    assert_equal 'Newborn', pt.format_age('2025-06-15', '2025-06-15')
    assert_equal 'Infant', pt.format_stage('2025-01-15', '2025-06-15')
  end

  # Compactness: compact
  # 27.1, 27.2, 27.3, 27.4, 27.5, 27.6, 27.7, 27.8
  def test_compactness_compact
    pt = SayableAge::Formatter.new(SayableAge::Locales::EN, compactness: :compact)

    assert_equal '3d', pt.format_age('2025-06-12', '2025-06-15')
    assert_equal '1w', pt.format_age('2025-06-08', '2025-06-15')
    assert_equal '1w1d', pt.format_age('2025-06-07', '2025-06-15')
    assert_equal '6m', pt.format_age('2025-01-15', '2025-07-15')
    assert_equal '2y1m', pt.format_age('2023-06-15', '2025-07-15')
    assert_equal "3\u00BDy", pt.format_age('2022-06-15', '2025-12-15')
    assert_equal '7y', pt.format_age('2018-06-15', '2025-06-15')
    assert_equal 'Newborn', pt.format_age('2025-06-15', '2025-06-15')
  end

  # ================================================================
  # Gender support for format_stage
  # ================================================================

  # English stages are plain strings — gender param is ignored
  def test_english_stage_ignores_gender
    pt = SayableAge::Formatter.new(SayableAge::Locales::EN)
    assert_equal 'Newborn', pt.format_stage('2025-06-15', '2025-06-15', gender: 'm')
    assert_equal 'Newborn', pt.format_stage('2025-06-15', '2025-06-15', gender: 'f')
    assert_equal 'Newborn', pt.format_stage('2025-06-15', '2025-06-15', gender: nil)
    assert_equal 'Adult', pt.format_stage('2007-06-15', '2025-06-15', gender: 'f')
  end

  # Spanish: gendered stages (newborn, toddler, child, adult) + neutral (infant, teenager)
  def test_spanish_gendered_stages
    pt = SayableAge::Formatter.new(SayableAge::Locales::ES)

    # Gendered: defaults to masculine when no gender
    assert_equal 'Recién nacido', pt.format_stage('2025-06-15', '2025-06-15')
    assert_equal 'Recién nacido', pt.format_stage('2025-06-15', '2025-06-15', gender: 'm')
    assert_equal 'Recién nacida', pt.format_stage('2025-06-15', '2025-06-15', gender: 'f')

    # Neutral: stays the same regardless of gender
    assert_equal 'Bebé', pt.format_stage('2025-01-15', '2025-06-15', gender: 'f')
    assert_equal 'Bebé', pt.format_stage('2025-01-15', '2025-06-15', gender: 'm')

    # Toddler gendered
    assert_equal 'Niño pequeño', pt.format_stage('2024-06-15', '2025-06-15', gender: 'm')
    assert_equal 'Niña pequeña', pt.format_stage('2024-06-15', '2025-06-15', gender: 'f')

    # Child gendered
    assert_equal 'Niño', pt.format_stage('2022-06-15', '2025-06-15', gender: 'm')
    assert_equal 'Niña', pt.format_stage('2022-06-15', '2025-06-15', gender: 'f')

    # Teenager neutral
    assert_equal 'Adolescente', pt.format_stage('2012-06-15', '2025-06-15', gender: 'f')

    # Adult gendered
    assert_equal 'Adulto', pt.format_stage('2007-06-15', '2025-06-15', gender: 'm')
    assert_equal 'Adulta', pt.format_stage('2007-06-15', '2025-06-15', gender: 'f')
  end

  # Arabic: all 6 stages are gendered
  def test_arabic_all_gendered_stages
    pt = SayableAge::Formatter.new(SayableAge::Locales::AR)

    assert_equal 'حديث الولادة', pt.format_stage('2025-06-15', '2025-06-15', gender: 'm')
    assert_equal 'حديثة الولادة', pt.format_stage('2025-06-15', '2025-06-15', gender: 'f')
    assert_equal 'رضيع', pt.format_stage('2025-01-15', '2025-06-15', gender: 'm')
    assert_equal 'رضيعة', pt.format_stage('2025-01-15', '2025-06-15', gender: 'f')
    assert_equal 'طفل صغير', pt.format_stage('2024-06-15', '2025-06-15', gender: 'm')
    assert_equal 'طفلة صغيرة', pt.format_stage('2024-06-15', '2025-06-15', gender: 'f')
    assert_equal 'طفل', pt.format_stage('2022-06-15', '2025-06-15', gender: 'm')
    assert_equal 'طفلة', pt.format_stage('2022-06-15', '2025-06-15', gender: 'f')
    assert_equal 'مراهق', pt.format_stage('2012-06-15', '2025-06-15', gender: 'm')
    assert_equal 'مراهقة', pt.format_stage('2012-06-15', '2025-06-15', gender: 'f')
    assert_equal 'بالغ', pt.format_stage('2007-06-15', '2025-06-15', gender: 'm')
    assert_equal 'بالغة', pt.format_stage('2007-06-15', '2025-06-15', gender: 'f')
  end

  # German: only adult is gendered
  def test_german_adult_gendered
    pt = SayableAge::Formatter.new(SayableAge::Locales::DE)
    assert_equal 'Erwachsener', pt.format_stage('2007-06-15', '2025-06-15', gender: 'm')
    assert_equal 'Erwachsene', pt.format_stage('2007-06-15', '2025-06-15', gender: 'f')
    assert_equal 'Erwachsener', pt.format_stage('2007-06-15', '2025-06-15')
  end

  # French: newborn gendered, toddler neutral swap, teenager gendered
  def test_french_gendered_stages
    pt = SayableAge::Formatter.new(SayableAge::Locales::FR)
    assert_equal 'Nouveau-né', pt.format_stage('2025-06-15', '2025-06-15', gender: 'm')
    assert_equal 'Nouveau-née', pt.format_stage('2025-06-15', '2025-06-15', gender: 'f')
    assert_equal 'Tout-petit', pt.format_stage('2024-06-15', '2025-06-15')
    assert_equal 'Adolescent', pt.format_stage('2012-06-15', '2025-06-15', gender: 'm')
    assert_equal 'Adolescente', pt.format_stage('2012-06-15', '2025-06-15', gender: 'f')
    assert_equal 'Adulte', pt.format_stage('2007-06-15', '2025-06-15', gender: 'f')
  end

  # Module-level convenience with gender
  def test_module_level_format_stage_with_gender
    # English is ungendered, so result is same regardless
    assert_equal 'Adult', SayableAge.format_stage('2007-06-15', '2025-06-15', gender: 'f')
    assert_equal 'Adult', SayableAge.format_stage('2007-06-15', '2025-06-15', gender: 'm')
  end

  # resolve_stage helper
  def test_resolve_stage_with_string
    assert_equal 'Adult', SayableAge.resolve_stage('Adult', 'm')
    assert_equal 'Adult', SayableAge.resolve_stage('Adult', 'f')
    assert_equal 'Adult', SayableAge.resolve_stage('Adult', nil)
  end

  def test_resolve_stage_with_hash
    label = { m: 'Adulto', f: 'Adulta' }
    assert_equal 'Adulto', SayableAge.resolve_stage(label, 'm')
    assert_equal 'Adulta', SayableAge.resolve_stage(label, 'f')
    assert_equal 'Adulto', SayableAge.resolve_stage(label, nil)
    assert_equal 'Adulto', SayableAge.resolve_stage(label)
  end

  # Nil handling with gender
  def test_format_stage_nil_with_gender
    pt = SayableAge::Formatter.new(SayableAge::Locales::ES)
    assert_nil pt.format_stage(nil, '2025-06-15', gender: 'f')
    assert_nil pt.format_stage('', '2025-06-15', gender: 'm')
  end

  # ================================================================
  # Section 29: Locale-specific edge cases — new plural rules
  # ================================================================

  # Hebrew (he) — dual forms
  # 29.1
  def test_29_1_he_just_born
    pt = SayableAge::Formatter.new(SayableAge::Locales::HE)
    assert_equal 'רק נולד', pt.format_age('2025-06-15', '2025-06-15')
  end

  # 29.2
  def test_29_2_he_one_day
    pt = SayableAge::Formatter.new(SayableAge::Locales::HE)
    assert_equal 'יום', pt.format_age('2025-06-14', '2025-06-15')
  end

  # 29.3
  def test_29_3_he_three_days
    pt = SayableAge::Formatter.new(SayableAge::Locales::HE)
    assert_equal '3 ימים', pt.format_age('2025-06-12', '2025-06-15')
  end

  # 29.4
  def test_29_4_he_two_weeks_dual
    pt = SayableAge::Formatter.new(SayableAge::Locales::HE)
    assert_equal 'שבועיים', pt.format_age('2025-06-01', '2025-06-15')
  end

  # 29.5
  def test_29_5_he_three_weeks
    pt = SayableAge::Formatter.new(SayableAge::Locales::HE)
    assert_equal '3 שבועות', pt.format_age('2025-05-25', '2025-06-15')
  end

  # 29.6
  def test_29_6_he_six_months
    pt = SayableAge::Formatter.new(SayableAge::Locales::HE)
    assert_equal '6 חודשים', pt.format_age('2025-01-15', '2025-07-15')
  end

  # 29.7
  def test_29_7_he_three_months
    pt = SayableAge::Formatter.new(SayableAge::Locales::HE)
    assert_equal '3 חודשים', pt.format_age('2025-03-15', '2025-06-15')
  end

  # 29.8
  def test_29_8_he_two_years_dual_one_month
    pt = SayableAge::Formatter.new(SayableAge::Locales::HE)
    assert_equal 'שנתיים, חודש', pt.format_age('2023-06-15', '2025-07-15')
  end

  # 29.9
  def test_29_9_he_half_years
    pt = SayableAge::Formatter.new(SayableAge::Locales::HE)
    assert_equal '3 שנים וחצי', pt.format_age('2022-06-15', '2025-12-15')
  end

  # 29.10
  def test_29_10_he_seven_years
    pt = SayableAge::Formatter.new(SayableAge::Locales::HE)
    assert_equal '7 שנים', pt.format_age('2018-06-15', '2025-06-15')
  end

  # 29.11
  def test_29_11_he_stage_masculine_newborn
    pt = SayableAge::Formatter.new(SayableAge::Locales::HE)
    assert_equal 'רק נולד', pt.format_stage('2025-06-15', '2025-06-15', gender: 'm')
  end

  # 29.12
  def test_29_12_he_stage_feminine_newborn
    pt = SayableAge::Formatter.new(SayableAge::Locales::HE)
    assert_equal 'רק נולדה', pt.format_stage('2025-06-15', '2025-06-15', gender: 'f')
  end

  # 29.13
  def test_29_13_he_stage_masculine_adult
    pt = SayableAge::Formatter.new(SayableAge::Locales::HE)
    assert_equal 'מבוגר', pt.format_stage('2007-06-15', '2025-06-15', gender: 'm')
  end

  # 29.14
  def test_29_14_he_stage_feminine_adult
    pt = SayableAge::Formatter.new(SayableAge::Locales::HE)
    assert_equal 'מבוגרת', pt.format_stage('2007-06-15', '2025-06-15', gender: 'f')
  end

  # Macedonian (mk) — mod10/mod100 rule
  # 29.15
  def test_29_15_mk_just_born
    pt = SayableAge::Formatter.new(SayableAge::Locales::MK)
    assert_equal 'Новороденче', pt.format_age('2025-06-15', '2025-06-15')
  end

  # 29.16
  def test_29_16_mk_one_day
    pt = SayableAge::Formatter.new(SayableAge::Locales::MK)
    assert_equal '1 ден', pt.format_age('2025-06-14', '2025-06-15')
  end

  # 29.17
  def test_29_17_mk_three_days
    pt = SayableAge::Formatter.new(SayableAge::Locales::MK)
    assert_equal '3 дена', pt.format_age('2025-06-12', '2025-06-15')
  end

  # 29.18
  def test_29_18_mk_six_months
    pt = SayableAge::Formatter.new(SayableAge::Locales::MK)
    assert_equal '6 месеци', pt.format_age('2025-01-15', '2025-07-15')
  end

  # 29.19
  def test_29_19_mk_two_years_one_month
    pt = SayableAge::Formatter.new(SayableAge::Locales::MK)
    assert_equal '2 години, 1 месец', pt.format_age('2023-06-15', '2025-07-15')
  end

  # 29.20
  def test_29_20_mk_half_years
    pt = SayableAge::Formatter.new(SayableAge::Locales::MK)
    assert_equal '3 години и пол', pt.format_age('2022-06-15', '2025-12-15')
  end

  # 29.21
  def test_29_21_mk_seven_years
    pt = SayableAge::Formatter.new(SayableAge::Locales::MK)
    assert_equal '7 години', pt.format_age('2018-06-15', '2025-06-15')
  end

  # Swahili (sw) — noun class changes
  # 29.22
  def test_29_22_sw_just_born
    pt = SayableAge::Formatter.new(SayableAge::Locales::SW)
    assert_equal 'Mzaliwa mpya', pt.format_age('2025-06-15', '2025-06-15')
  end

  # 29.23
  def test_29_23_sw_one_day
    pt = SayableAge::Formatter.new(SayableAge::Locales::SW)
    assert_equal 'siku 1', pt.format_age('2025-06-14', '2025-06-15')
  end

  # 29.24
  def test_29_24_sw_three_days
    pt = SayableAge::Formatter.new(SayableAge::Locales::SW)
    assert_equal 'siku 3', pt.format_age('2025-06-12', '2025-06-15')
  end

  # 29.25
  def test_29_25_sw_six_months
    pt = SayableAge::Formatter.new(SayableAge::Locales::SW)
    assert_equal 'miezi 6', pt.format_age('2025-01-15', '2025-07-15')
  end

  # 29.26
  def test_29_26_sw_two_years_one_month
    pt = SayableAge::Formatter.new(SayableAge::Locales::SW)
    assert_equal 'miaka 2, mwezi 1', pt.format_age('2023-06-15', '2025-07-15')
  end

  # 29.27
  def test_29_27_sw_half_years
    pt = SayableAge::Formatter.new(SayableAge::Locales::SW)
    assert_equal 'miaka 3 na nusu', pt.format_age('2022-06-15', '2025-12-15')
  end

  # Indonesian (id) — other_only
  # 29.28
  def test_29_28_id_just_born
    pt = SayableAge::Formatter.new(SayableAge::Locales::ID)
    assert_equal 'Baru lahir', pt.format_age('2025-06-15', '2025-06-15')
  end

  def test_29_29_id_one_day
    pt = SayableAge::Formatter.new(SayableAge::Locales::ID)
    assert_equal '1 hari', pt.format_age('2025-06-14', '2025-06-15')
  end

  def test_29_30_id_three_days
    pt = SayableAge::Formatter.new(SayableAge::Locales::ID)
    assert_equal '3 hari', pt.format_age('2025-06-12', '2025-06-15')
  end

  def test_29_31_id_six_months
    pt = SayableAge::Formatter.new(SayableAge::Locales::ID)
    assert_equal '6 bulan', pt.format_age('2025-01-15', '2025-07-15')
  end

  def test_29_32_id_half_years
    pt = SayableAge::Formatter.new(SayableAge::Locales::ID)
    assert_equal '3 setengah tahun', pt.format_age('2022-06-15', '2025-12-15')
  end

  def test_29_33_id_seven_years
    pt = SayableAge::Formatter.new(SayableAge::Locales::ID)
    assert_equal '7 tahun', pt.format_age('2018-06-15', '2025-06-15')
  end

  # Amharic (am) — Ethiopic delimiter
  def test_29_34_am_just_born
    pt = SayableAge::Formatter.new(SayableAge::Locales::AM)
    assert_equal 'አዲስ የተወለደ', pt.format_age('2025-06-15', '2025-06-15')
  end

  def test_29_35_am_one_day
    pt = SayableAge::Formatter.new(SayableAge::Locales::AM)
    assert_equal '1 ቀን', pt.format_age('2025-06-14', '2025-06-15')
  end

  def test_29_36_am_three_days
    pt = SayableAge::Formatter.new(SayableAge::Locales::AM)
    assert_equal '3 ቀናት', pt.format_age('2025-06-12', '2025-06-15')
  end

  def test_29_37_am_one_week_one_day_ethiopic
    pt = SayableAge::Formatter.new(SayableAge::Locales::AM)
    assert_equal '1 ሳምንት፣ 1 ቀን', pt.format_age('2025-06-07', '2025-06-15')
  end

  def test_29_38_am_six_months
    pt = SayableAge::Formatter.new(SayableAge::Locales::AM)
    assert_equal '6 ወራት', pt.format_age('2025-01-15', '2025-07-15')
  end

  def test_29_39_am_half_years
    pt = SayableAge::Formatter.new(SayableAge::Locales::AM)
    assert_equal '3 ዓመታት ተኩል', pt.format_age('2022-06-15', '2025-12-15')
  end

  # ================================================================
  # Section 30: Locale lookup by code string
  # ================================================================

  def test_30_1_get_locale_en
    loc = SayableAge::Locales.get('en')
    refute_nil loc
    assert_equal 'en', loc.code
  end

  def test_30_2_get_locale_fr
    loc = SayableAge::Locales.get('fr')
    refute_nil loc
    assert_equal 'fr', loc.code
  end

  def test_30_3_get_locale_unknown
    assert_nil SayableAge::Locales.get('xx')
  end

  def test_30_4_get_locale_empty
    assert_nil SayableAge::Locales.get('')
  end

  def test_30_5_get_locale_case_sensitive
    assert_nil SayableAge::Locales.get('EN')
  end

  # ================================================================
  # Section 31: Weeks and days across month ends
  # ================================================================

  # 31.1
  def test_31_1_weeks_days_across_short_february
    assert_equal '12 weeks, 4 days', SayableAge.format_age('2016-12-31', '2017-03-29')
  end

  # 31.2
  def test_31_2_weeks_days_into_leap_year
    assert_equal '12 weeks, 6 days', SayableAge.format_age('1991-11-27', '1992-02-25')
  end

  # 31.3
  def test_31_3_weeks_days_across_year_end
    assert_equal '4 weeks, 5 days', SayableAge.format_age('2020-11-30', '2021-01-02')
  end

  # 31.4
  def test_31_4_weeks_days_compact
    pt = SayableAge::Formatter.new(SayableAge::Locales::EN, compactness: :compact)
    assert_equal '12w4d', pt.format_age('2016-12-31', '2017-03-29')
  end

  # ================================================================
  # Section 32: Half years take their plural form from whole years
  # ================================================================

  # 32.1
  def test_32_1_pl_three_and_half_few
    pt = SayableAge::Formatter.new(SayableAge::Locales::PL)
    assert_equal '3 i pół lata', pt.format_age('2021-06-15', '2025-01-15')
  end

  # 32.2
  def test_32_2_pl_five_and_half_many_short
    pt = SayableAge::Formatter.new(SayableAge::Locales::PL, compactness: :short)
    assert_equal '5 i pół lat', pt.format_age('2020-06-15', '2025-12-15')
  end

  # 32.3
  def test_32_3_shi_six_few
    pt = SayableAge::Formatter.new(SayableAge::Locales::SHI)
    assert_equal '6 ⵉⵙⴳⴳⵯⴰⵙⵏ ⴷ ⵓⵣⴳⵏ', pt.format_age('2005-06-08', '2012-06-07')
  end

  # ================================================================
  # Section 33: Input validation
  # ================================================================

  # 33.1
  def test_33_1_february30
    assert_nil SayableAge.format_age('2025-02-30', '2032-06-25')
  end

  # 33.2
  def test_33_2_month13
    assert_nil SayableAge.format_age('2025-13-01', '2027-01-31')
  end

  # 33.3
  def test_33_3_february_29_non_leap
    assert_nil SayableAge.format_age('2023-02-29', '2025-03-01')
  end

  # 33.4
  def test_33_4_day00
    assert_nil SayableAge.format_age('2025-06-00', '2027-02-25')
  end

  # 33.5
  def test_33_5_unpadded
    assert_nil SayableAge.format_age('2025-6-1', '2027-02-25')
  end

  # 33.6
  def test_33_6_whitespace
    assert_nil SayableAge.format_age(' 2025-06-01', '2027-02-25')
  end

  # 33.7
  def test_33_7_datetime_is_not_a_date
    assert_nil SayableAge.format_age('2025-06-15T10:00:00', '2027-02-25')
  end

  # 33.8
  def test_33_8_invalid_as_of
    assert_nil SayableAge.format_age('2020-01-01', '2025-04-31')
  end

  # 33.9
  def test_33_9_format_stage_validates
    assert_nil SayableAge.format_stage('2025-02-30', '2027-09-05')
  end

  # 33.10
  def test_33_10_february_29_leap_year
    assert_equal '2 years', SayableAge.format_age('2024-02-29', '2026-03-01')
  end
end
