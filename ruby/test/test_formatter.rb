# frozen_string_literal: true

require 'minitest/autorun'
require 'parent_time'

# All tests use explicit (dob, as_of) pairs for determinism.

class TestFormatAge < Minitest::Test
  # ================================================================
  # Null / edge cases
  # ================================================================
  def test_returns_nil_for_nil_input
    assert_nil ParentTime.format_age(nil, '2025-06-15')
  end

  def test_returns_nil_for_empty_string
    assert_nil ParentTime.format_age('', '2025-06-15')
  end

  def test_returns_nil_for_future_dob
    assert_nil ParentTime.format_age('2025-07-01', '2025-06-15')
  end

  # ================================================================
  # Days tier: 0-6 days
  # ================================================================
  def test_born_today_newborn
    assert_equal 'Newborn', ParentTime.format_age('2025-06-15', '2025-06-15')
  end

  def test_1_day_singular
    assert_equal '1 day', ParentTime.format_age('2025-06-14', '2025-06-15')
  end

  def test_3_days
    assert_equal '3 days', ParentTime.format_age('2025-06-12', '2025-06-15')
  end

  def test_6_days
    assert_equal '6 days', ParentTime.format_age('2025-06-09', '2025-06-15')
  end

  def test_7_days_becomes_1_week
    assert_equal '1 week', ParentTime.format_age('2025-06-08', '2025-06-15')
  end

  # ================================================================
  # Weeks+days tier: 7 days to <3 months
  # ================================================================
  def test_7_days
    assert_equal '1 week', ParentTime.format_age('2025-06-08', '2025-06-15')
  end

  def test_8_days
    assert_equal '1 week, 1 day', ParentTime.format_age('2025-06-07', '2025-06-15')
  end

  def test_9_days
    assert_equal '1 week, 2 days', ParentTime.format_age('2025-06-06', '2025-06-15')
  end

  def test_13_days
    assert_equal '1 week, 6 days', ParentTime.format_age('2025-06-02', '2025-06-15')
  end

  def test_14_days
    assert_equal '2 weeks', ParentTime.format_age('2025-06-01', '2025-06-15')
  end

  def test_15_days
    assert_equal '2 weeks, 1 day', ParentTime.format_age('2025-05-31', '2025-06-15')
  end

  def test_20_days
    assert_equal '2 weeks, 6 days', ParentTime.format_age('2025-05-26', '2025-06-15')
  end

  def test_21_days
    assert_equal '3 weeks', ParentTime.format_age('2025-05-25', '2025-06-15')
  end

  def test_at_1_cal_month_still_weeks_days
    assert_equal '4 weeks, 3 days', ParentTime.format_age('2025-05-15', '2025-06-15')
  end

  def test_at_2_cal_months_still_weeks_days
    assert_equal '8 weeks, 5 days', ParentTime.format_age('2025-04-15', '2025-06-15')
  end

  def test_one_day_before_3mo_still_weeks
    assert_equal '13 weeks', ParentTime.format_age('2025-03-15', '2025-06-14')
  end

  def test_on_3mo_birthday_switches
    assert_equal '3 months', ParentTime.format_age('2025-03-15', '2025-06-15')
  end

  # ================================================================
  # Month boundaries: standard months
  # ================================================================
  def test_jan1_apr1_3mo
    assert_equal '3 months', ParentTime.format_age('2025-01-01', '2025-04-01')
  end

  def test_jan1_mar31_still_weeks
    assert_match(/weeks/, ParentTime.format_age('2025-01-01', '2025-03-31'))
  end

  def test_jun15_sep15_3mo
    assert_equal '3 months', ParentTime.format_age('2025-06-15', '2025-09-15')
  end

  def test_jun15_sep14_still_weeks
    assert_match(/weeks/, ParentTime.format_age('2025-06-15', '2025-09-14'))
  end

  def test_jun15_dec15_6mo
    assert_equal '6 months', ParentTime.format_age('2025-06-15', '2025-12-15')
  end

  # ================================================================
  # Month boundaries: February non-leap
  # ================================================================
  def test_jan31_feb28_non_leap
    assert_equal '4 weeks', ParentTime.format_age('2025-01-31', '2025-02-28')
  end

  def test_jan31_apr30_3mo_clamp
    assert_equal '3 months', ParentTime.format_age('2025-01-31', '2025-04-30')
  end

  def test_jan31_apr29_still_weeks
    assert_match(/weeks/, ParentTime.format_age('2025-01-31', '2025-04-29'))
  end

  def test_feb1_may1_3mo
    assert_equal '3 months', ParentTime.format_age('2025-02-01', '2025-05-01')
  end

  def test_feb1_apr30_still_weeks
    assert_match(/weeks/, ParentTime.format_age('2025-02-01', '2025-04-30'))
  end

  # ================================================================
  # Month boundaries: February leap year
  # ================================================================
  def test_jan31_feb29_leap
    assert_equal '4 weeks, 1 day', ParentTime.format_age('2024-01-31', '2024-02-29')
  end

  def test_jan31_feb28_leap
    assert_equal '4 weeks', ParentTime.format_age('2024-01-31', '2024-02-28')
  end

  def test_jan31_apr30_leap_3mo
    assert_equal '3 months', ParentTime.format_age('2024-01-31', '2024-04-30')
  end

  def test_jan30_feb29_leap_still_weeks
    assert_match(/weeks/, ParentTime.format_age('2024-01-30', '2024-02-29'))
  end

  def test_jan30_feb28_leap_still_weeks
    assert_match(/weeks/, ParentTime.format_age('2024-01-30', '2024-02-28'))
  end

  # ================================================================
  # Month boundaries: 30-day months
  # ================================================================
  def test_mar31_jun30_3mo
    assert_equal '3 months', ParentTime.format_age('2025-03-31', '2025-06-30')
  end

  def test_mar31_jun29_still_weeks
    assert_match(/weeks/, ParentTime.format_age('2025-03-31', '2025-06-29'))
  end

  def test_aug31_nov30_3mo
    assert_equal '3 months', ParentTime.format_age('2025-08-31', '2025-11-30')
  end

  def test_aug31_nov29_still_weeks
    assert_match(/weeks/, ParentTime.format_age('2025-08-31', '2025-11-29'))
  end

  # ================================================================
  # Month boundaries: leap year baby (born Feb 29)
  # ================================================================
  def test_feb29_may29_3mo
    assert_equal '3 months', ParentTime.format_age('2024-02-29', '2024-05-29')
  end

  def test_feb29_may28_still_weeks
    assert_match(/weeks/, ParentTime.format_age('2024-02-29', '2024-05-28'))
  end

  def test_feb29_2024_feb28_2025_12mo
    assert_equal '12 months', ParentTime.format_age('2024-02-29', '2025-02-28')
  end

  def test_feb29_2024_mar1_2025_12mo
    assert_equal '12 months', ParentTime.format_age('2024-02-29', '2025-03-01')
  end

  # ================================================================
  # Months tier: 3-23 months
  # ================================================================
  def test_3_months_at_transition
    assert_equal '3 months', ParentTime.format_age('2025-01-15', '2025-04-15')
  end

  def test_6_months
    assert_equal '6 months', ParentTime.format_age('2025-01-15', '2025-07-15')
  end

  def test_12_months_not_1_year
    assert_equal '12 months', ParentTime.format_age('2024-06-15', '2025-06-15')
  end

  def test_23_months_upper_boundary
    assert_equal '23 months', ParentTime.format_age('2024-01-15', '2025-12-15')
  end

  def test_one_day_before_month_boundary
    assert_equal '5 months', ParentTime.format_age('2025-01-15', '2025-07-14')
  end

  def test_crossing_year_boundary
    assert_equal '5 months', ParentTime.format_age('2024-11-10', '2025-04-10')
  end

  # ================================================================
  # Years+months tier: 24-35 months
  # ================================================================
  def test_2_years_at_24mo
    assert_equal '2 years', ParentTime.format_age('2023-06-15', '2025-06-15')
  end

  def test_2_years_1_month
    assert_equal '2 years, 1 month', ParentTime.format_age('2023-06-15', '2025-07-15')
  end

  def test_2_years_6_months
    assert_equal '2 years, 6 months', ParentTime.format_age('2023-06-15', '2025-12-15')
  end

  def test_2_years_11_months
    assert_equal '2 years, 11 months', ParentTime.format_age('2023-06-15', '2026-05-15')
  end

  def test_one_day_before_24mo_stays_months
    assert_equal '23 months', ParentTime.format_age('2023-06-15', '2025-06-14')
  end

  # ================================================================
  # Half-year tier: 3-6 years
  # ================================================================
  def test_3_years_exactly
    assert_equal '3 years', ParentTime.format_age('2022-06-15', '2025-06-15')
  end

  def test_3_years_5_months
    assert_equal '3 years', ParentTime.format_age('2022-06-15', '2025-11-15')
  end

  def test_3_half_years_at_3y6m
    assert_equal "3\u00BD years", ParentTime.format_age('2022-06-15', '2025-12-15')
  end

  def test_3_half_years_at_3y11m
    assert_equal "3\u00BD years", ParentTime.format_age('2022-06-15', '2026-05-15')
  end

  def test_4_years_exactly
    assert_equal '4 years', ParentTime.format_age('2021-06-15', '2025-06-15')
  end

  def test_4_half_years
    assert_equal "4\u00BD years", ParentTime.format_age('2021-06-15', '2025-12-15')
  end

  def test_5_years
    assert_equal '5 years', ParentTime.format_age('2020-06-15', '2025-06-15')
  end

  def test_5_half_years_at_5y8m
    assert_equal "5\u00BD years", ParentTime.format_age('2020-06-15', '2026-02-15')
  end

  def test_6_years
    assert_equal '6 years', ParentTime.format_age('2019-06-15', '2025-06-15')
  end

  def test_6_half_years
    assert_equal "6\u00BD years", ParentTime.format_age('2019-06-15', '2025-12-15')
  end

  def test_6_half_years_at_6y11m
    assert_equal "6\u00BD years", ParentTime.format_age('2019-06-15', '2026-05-15')
  end

  def test_one_day_before_3rd_bday
    assert_equal '2 years, 11 months', ParentTime.format_age('2022-06-15', '2025-06-14')
  end

  # ================================================================
  # Integer tier: 7+ years
  # ================================================================
  def test_7_years_exactly
    assert_equal '7 years', ParentTime.format_age('2018-06-15', '2025-06-15')
  end

  def test_7_years_6_months_no_half
    assert_equal '7 years', ParentTime.format_age('2018-03-20', '2025-06-15')
  end

  def test_45_years
    assert_equal '45 years', ParentTime.format_age('1980-01-01', '2025-06-15')
  end

  # ================================================================
  # Cross-year transitions with Feb
  # ================================================================
  def test_dec31_mar31_3mo
    assert_equal '3 months', ParentTime.format_age('2024-12-31', '2025-03-31')
  end

  def test_dec31_mar30_still_weeks
    assert_match(/weeks/, ParentTime.format_age('2024-12-31', '2025-03-30'))
  end

  def test_nov30_feb28_3mo
    assert_equal '3 months', ParentTime.format_age('2024-11-30', '2025-02-28')
  end

  def test_nov30_feb27_still_weeks
    assert_match(/weeks/, ParentTime.format_age('2024-11-30', '2025-02-27'))
  end

  # ================================================================
  # Born-on-31st progression
  # ================================================================
  def test_jan31_apr30_3mo
    assert_equal '3 months', ParentTime.format_age('2025-01-31', '2025-04-30')
  end

  def test_jan31_may31_4mo
    assert_equal '4 months', ParentTime.format_age('2025-01-31', '2025-05-31')
  end

  def test_jan31_jun30_5mo_clamped
    assert_equal '5 months', ParentTime.format_age('2025-01-31', '2025-06-30')
  end

  def test_jan31_jul1_5mo
    assert_equal '5 months', ParentTime.format_age('2025-01-31', '2025-07-01')
  end

  def test_jan31_jul31_6mo
    assert_equal '6 months', ParentTime.format_age('2025-01-31', '2025-07-31')
  end

  # ================================================================
  # Default as_of (uses current date)
  # ================================================================
  def test_default_as_of
    Date.stub(:today, Date.new(2025, 6, 15)) do
      assert_equal '5 years', ParentTime.format_age('2020-01-01')
      assert_equal '5 days', ParentTime.format_age('2025-06-10')
    end
  end
end

# ================================================================
# formatStage
# ================================================================
class TestFormatStage < Minitest::Test
  def test_returns_nil_for_nil
    assert_nil ParentTime.format_stage(nil, '2025-06-15')
  end

  def test_returns_nil_for_empty
    assert_nil ParentTime.format_stage('', '2025-06-15')
  end

  def test_returns_nil_for_future
    assert_nil ParentTime.format_stage('2025-07-01', '2025-06-15')
  end

  # Newborn: 0-1 months
  def test_newborn_born_today
    assert_equal 'Newborn', ParentTime.format_stage('2025-06-15', '2025-06-15')
  end

  def test_newborn_1_day
    assert_equal 'Newborn', ParentTime.format_stage('2025-06-14', '2025-06-15')
  end

  def test_newborn_3_weeks
    assert_equal 'Newborn', ParentTime.format_stage('2025-05-25', '2025-06-15')
  end

  def test_newborn_1_month
    assert_equal 'Newborn', ParentTime.format_stage('2025-05-15', '2025-06-15')
  end

  def test_newborn_1_month_29_days
    assert_equal 'Newborn', ParentTime.format_stage('2025-04-16', '2025-06-15')
  end

  def test_exactly_2_months_infant
    assert_equal 'Infant', ParentTime.format_stage('2025-04-15', '2025-06-15')
  end

  # Infant: 2-11 months
  def test_infant_2_months
    assert_equal 'Infant', ParentTime.format_stage('2025-04-15', '2025-06-15')
  end

  def test_infant_6_months
    assert_equal 'Infant', ParentTime.format_stage('2024-12-15', '2025-06-15')
  end

  def test_infant_11_months
    assert_equal 'Infant', ParentTime.format_stage('2024-07-15', '2025-06-15')
  end

  def test_exactly_12_months_toddler
    assert_equal 'Toddler', ParentTime.format_stage('2024-06-15', '2025-06-15')
  end

  # Toddler: 12-35 months
  def test_toddler_12_months
    assert_equal 'Toddler', ParentTime.format_stage('2024-06-15', '2025-06-15')
  end

  def test_toddler_18_months
    assert_equal 'Toddler', ParentTime.format_stage('2024-01-15', '2025-07-15')
  end

  def test_toddler_24_months
    assert_equal 'Toddler', ParentTime.format_stage('2023-06-15', '2025-06-15')
  end

  def test_toddler_35_months
    assert_equal 'Toddler', ParentTime.format_stage('2023-06-15', '2026-05-15')
  end

  def test_exactly_36_months_child
    assert_equal 'Child', ParentTime.format_stage('2022-06-15', '2025-06-15')
  end

  # Child: 36-155 months
  def test_child_3_years
    assert_equal 'Child', ParentTime.format_stage('2022-06-15', '2025-06-15')
  end

  def test_child_4_years
    assert_equal 'Child', ParentTime.format_stage('2021-06-15', '2025-06-15')
  end

  def test_child_6_years
    assert_equal 'Child', ParentTime.format_stage('2019-06-15', '2025-06-15')
  end

  def test_child_9_years
    assert_equal 'Child', ParentTime.format_stage('2016-06-15', '2025-06-15')
  end

  def test_child_12y11m
    assert_equal 'Child', ParentTime.format_stage('2013-06-15', '2026-05-15')
  end

  def test_exactly_13_years_teenager
    assert_equal 'Teenager', ParentTime.format_stage('2012-06-15', '2025-06-15')
  end

  # Teenager: 156-215 months
  def test_teenager_13_years
    assert_equal 'Teenager', ParentTime.format_stage('2012-06-15', '2025-06-15')
  end

  def test_teenager_15_years
    assert_equal 'Teenager', ParentTime.format_stage('2010-06-15', '2025-06-15')
  end

  def test_teenager_17y11m
    assert_equal 'Teenager', ParentTime.format_stage('2008-06-15', '2026-05-15')
  end

  def test_exactly_18_years_adult
    assert_equal 'Adult', ParentTime.format_stage('2007-06-15', '2025-06-15')
  end

  # Adult: 216+ months
  def test_adult_18_years
    assert_equal 'Adult', ParentTime.format_stage('2007-06-15', '2025-06-15')
  end

  def test_adult_25_years
    assert_equal 'Adult', ParentTime.format_stage('2000-06-15', '2025-06-15')
  end

  def test_adult_45_years
    assert_equal 'Adult', ParentTime.format_stage('1980-01-01', '2025-06-15')
  end

  def test_stage_default_as_of
    Date.stub(:today, Date.new(2025, 6, 15)) do
      assert_equal 'Newborn', ParentTime.format_stage('2025-06-15')
      assert_equal 'Child', ParentTime.format_stage('2020-01-01')
      assert_equal 'Adult', ParentTime.format_stage('1980-01-01')
    end
  end
end

# ================================================================
# ParentTime::Formatter class
# ================================================================
class TestFormatter < Minitest::Test
  def test_english_format_age
    pt = ParentTime::Formatter.new(ParentTime::Locales::EN)
    assert_equal 'Newborn', pt.format_age('2025-06-15', '2025-06-15')
    assert_equal '3 days', pt.format_age('2025-06-12', '2025-06-15')
    assert_equal '1 week, 1 day', pt.format_age('2025-06-07', '2025-06-15')
    assert_equal '6 months', pt.format_age('2025-01-15', '2025-07-15')
    assert_equal '2 years, 1 month', pt.format_age('2023-06-15', '2025-07-15')
    assert_equal "3\u00BD years", pt.format_age('2022-06-15', '2025-12-15')
    assert_equal '7 years', pt.format_age('2018-06-15', '2025-06-15')
  end

  def test_english_format_stage
    pt = ParentTime::Formatter.new(ParentTime::Locales::EN)
    assert_equal 'Newborn', pt.format_stage('2025-06-15', '2025-06-15')
    assert_equal 'Infant', pt.format_stage('2025-01-15', '2025-06-15')
    assert_equal 'Toddler', pt.format_stage('2024-06-15', '2025-06-15')
    assert_equal 'Child', pt.format_stage('2022-06-15', '2025-06-15')
    assert_equal 'Teenager', pt.format_stage('2012-06-15', '2025-06-15')
    assert_equal 'Adult', pt.format_stage('2007-06-15', '2025-06-15')
  end

  def test_null_handling
    pt = ParentTime::Formatter.new(ParentTime::Locales::EN)
    assert_nil pt.format_age(nil, '2025-06-15')
    assert_nil pt.format_stage(nil, '2025-06-15')
    assert_nil pt.format_age('', '2025-06-15')
  end

  # Spanish-like locale
  def test_spanish_locale
    es = ParentTime::AgeLocale.new(
      code: 'es',
      plural: ->(n) { n == 1 ? :one : :other },
      units: {
        'day' => { one: '{n} día', other: '{n} días' },
        'week' => { one: '{n} semana', other: '{n} semanas' },
        'month' => { one: '{n} mes', other: '{n} meses' },
        'year' => { one: '{n} año', other: '{n} años' }
      },
      half: '{n} y medio',
      delimiter: ', ',
      just_born: 'Recién nacido',
      stages: {
        newborn: 'Recién nacido',
        infant: 'Bebé',
        toddler: 'Niño pequeño',
        child: 'Niño',
        teenager: 'Adolescente',
        adult: 'Adulto'
      }
    )

    pt = ParentTime::Formatter.new(es)

    assert_equal 'Recién nacido', pt.format_age('2025-06-15', '2025-06-15')
    assert_equal '1 día', pt.format_age('2025-06-14', '2025-06-15')
    assert_equal '3 días', pt.format_age('2025-06-12', '2025-06-15')
    assert_equal '1 semana', pt.format_age('2025-06-08', '2025-06-15')
    assert_equal '1 semana, 1 día', pt.format_age('2025-06-07', '2025-06-15')
    assert_equal '2 semanas, 6 días', pt.format_age('2025-05-26', '2025-06-15')
    assert_equal '6 meses', pt.format_age('2025-01-15', '2025-07-15')
    assert_equal '2 años, 1 mes', pt.format_age('2023-06-15', '2025-07-15')
    assert_equal '2 años, 6 meses', pt.format_age('2023-06-15', '2025-12-15')
    assert_equal '3 y medio años', pt.format_age('2022-06-15', '2025-12-15')
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
  def test_compactness_short
    pt = ParentTime::Formatter.new(ParentTime::Locales::EN, compactness: :short)

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
  def test_compactness_compact
    pt = ParentTime::Formatter.new(ParentTime::Locales::EN, compactness: :compact)

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
    pt = ParentTime::Formatter.new(ParentTime::Locales::EN)
    assert_equal 'Newborn', pt.format_stage('2025-06-15', '2025-06-15', gender: 'm')
    assert_equal 'Newborn', pt.format_stage('2025-06-15', '2025-06-15', gender: 'f')
    assert_equal 'Newborn', pt.format_stage('2025-06-15', '2025-06-15', gender: nil)
    assert_equal 'Adult', pt.format_stage('2007-06-15', '2025-06-15', gender: 'f')
  end

  # Spanish: gendered stages (newborn, toddler, child, adult) + neutral (infant, teenager)
  def test_spanish_gendered_stages
    pt = ParentTime::Formatter.new(ParentTime::Locales::ES)

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
    pt = ParentTime::Formatter.new(ParentTime::Locales::AR)

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
    pt = ParentTime::Formatter.new(ParentTime::Locales::DE)
    assert_equal 'Erwachsener', pt.format_stage('2007-06-15', '2025-06-15', gender: 'm')
    assert_equal 'Erwachsene', pt.format_stage('2007-06-15', '2025-06-15', gender: 'f')
    assert_equal 'Erwachsener', pt.format_stage('2007-06-15', '2025-06-15')
  end

  # French: newborn gendered, toddler neutral swap, teenager gendered
  def test_french_gendered_stages
    pt = ParentTime::Formatter.new(ParentTime::Locales::FR)
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
    assert_equal 'Adult', ParentTime.format_stage('2007-06-15', '2025-06-15', gender: 'f')
    assert_equal 'Adult', ParentTime.format_stage('2007-06-15', '2025-06-15', gender: 'm')
  end

  # resolve_stage helper
  def test_resolve_stage_with_string
    assert_equal 'Adult', ParentTime.resolve_stage('Adult', 'm')
    assert_equal 'Adult', ParentTime.resolve_stage('Adult', 'f')
    assert_equal 'Adult', ParentTime.resolve_stage('Adult', nil)
  end

  def test_resolve_stage_with_hash
    label = { m: 'Adulto', f: 'Adulta' }
    assert_equal 'Adulto', ParentTime.resolve_stage(label, 'm')
    assert_equal 'Adulta', ParentTime.resolve_stage(label, 'f')
    assert_equal 'Adulto', ParentTime.resolve_stage(label, nil)
    assert_equal 'Adulto', ParentTime.resolve_stage(label)
  end

  # Nil handling with gender
  def test_format_stage_nil_with_gender
    pt = ParentTime::Formatter.new(ParentTime::Locales::ES)
    assert_nil pt.format_stage(nil, '2025-06-15', gender: 'f')
    assert_nil pt.format_stage('', '2025-06-15', gender: 'm')
  end
end
