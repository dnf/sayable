import gleam/string
import gleeunit
import gleeunit/should
import sayableage
import sayableage/locales/am as locale_am
import sayableage/locales/en as locale_en
import sayableage/locales/es as locale_es
import sayableage/locales/he as locale_he
import sayableage/locales/id as locale_id
import sayableage/locales/mk as locale_mk
import sayableage/locales/pl as locale_pl
import sayableage/locales/shi as locale_shi
import sayableage/locales/sw as locale_sw
import sayableage/types.{Compact, Female, Male, Normal, Short}

pub fn main() {
  gleeunit.main()
}

// Helpers

fn age(dob: String, as_of: String) -> Result(String, Nil) {
  sayableage.format_age(locale_en.locale(), Normal, dob, as_of)
}

fn age_short(dob: String, as_of: String) -> Result(String, Nil) {
  sayableage.format_age(locale_en.locale(), Short, dob, as_of)
}

fn age_compact(dob: String, as_of: String) -> Result(String, Nil) {
  sayableage.format_age(locale_en.locale(), Compact, dob, as_of)
}

fn age_locale(
  locale: types.AgeLocale,
  dob: String,
  as_of: String,
) -> Result(String, Nil) {
  sayableage.format_age(locale, Normal, dob, as_of)
}

fn stage(dob: String, as_of: String) -> Result(String, Nil) {
  sayableage.format_stage(locale_en.locale(), dob, as_of, Error(Nil))
}

fn stage_locale(
  locale: types.AgeLocale,
  dob: String,
  as_of: String,
  gender: Result(types.Gender, Nil),
) -> Result(String, Nil) {
  sayableage.format_stage(locale, dob, as_of, gender)
}

fn contains_week(r: Result(String, Nil)) -> Bool {
  case r {
    Ok(s) -> string.contains(s, "week")
    Error(Nil) -> False
  }
}

// 1. Null / edge cases

// 1.1, 1.3
pub fn null_empty_dob_test() {
  age("", "2025-06-15") |> should.equal(Error(Nil))
}

// 1.4
pub fn null_future_dob_test() {
  age("2025-07-01", "2025-06-15") |> should.equal(Error(Nil))
}

// 1.5
pub fn null_500_years_valid_test() {
  age("1525-06-15", "2025-06-15") |> should.equal(Ok("500 years"))
}

// 1.6
pub fn null_501_years_error_test() {
  age("1524-06-15", "2025-06-15") |> should.equal(Error(Nil))
}

// 1.7
pub fn null_1000_years_error_test() {
  age("1025-06-15", "2025-06-15") |> should.equal(Error(Nil))
}

// 2. Days tier (0-6 days)

// 2.1
pub fn days_same_day_newborn_test() {
  age("2025-06-15", "2025-06-15") |> should.equal(Ok("Newborn"))
}

// 2.2
pub fn days_1_day_test() {
  age("2025-06-14", "2025-06-15") |> should.equal(Ok("1 day"))
}

// 2.3
pub fn days_3_days_test() {
  age("2025-06-12", "2025-06-15") |> should.equal(Ok("3 days"))
}

// 2.4
pub fn days_6_days_test() {
  age("2025-06-09", "2025-06-15") |> should.equal(Ok("6 days"))
}

// 2.5
pub fn days_7_becomes_1_week_test() {
  age("2025-06-08", "2025-06-15") |> should.equal(Ok("1 week"))
}

// 3. Weeks+days tier

// 3.1
pub fn weeks_exactly_1_week_test() {
  age("2025-06-08", "2025-06-15") |> should.equal(Ok("1 week"))
}

// 3.2
pub fn weeks_1_week_1_day_test() {
  age("2025-06-07", "2025-06-15") |> should.equal(Ok("1 week, 1 day"))
}

// 3.3
pub fn weeks_1_week_2_days_test() {
  age("2025-06-06", "2025-06-15") |> should.equal(Ok("1 week, 2 days"))
}

// 3.4
pub fn weeks_1_week_6_days_test() {
  age("2025-06-02", "2025-06-15") |> should.equal(Ok("1 week, 6 days"))
}

// 3.5
pub fn weeks_2_weeks_test() {
  age("2025-06-01", "2025-06-15") |> should.equal(Ok("2 weeks"))
}

// 3.6
pub fn weeks_2_weeks_1_day_test() {
  age("2025-05-31", "2025-06-15") |> should.equal(Ok("2 weeks, 1 day"))
}

// 3.7
pub fn weeks_2_weeks_6_days_test() {
  age("2025-05-26", "2025-06-15") |> should.equal(Ok("2 weeks, 6 days"))
}

// 3.8
pub fn weeks_3_weeks_test() {
  age("2025-05-25", "2025-06-15") |> should.equal(Ok("3 weeks"))
}

// 3.9
pub fn weeks_4_weeks_3_days_test() {
  age("2025-05-15", "2025-06-15") |> should.equal(Ok("4 weeks, 3 days"))
}

// 3.10
pub fn weeks_8_weeks_5_days_test() {
  age("2025-04-15", "2025-06-15") |> should.equal(Ok("8 weeks, 5 days"))
}

// 3.11
pub fn weeks_13_weeks_under_3_months_test() {
  age("2025-03-15", "2025-06-14") |> should.equal(Ok("13 weeks"))
}

// 3.12
pub fn weeks_exactly_3_months_transition_test() {
  age("2025-03-15", "2025-06-15") |> should.equal(Ok("3 months"))
}

// 4. Month boundaries - standard months

// 4.1
pub fn month_boundary_3_months_standard_test() {
  age("2025-01-01", "2025-04-01") |> should.equal(Ok("3 months"))
}

// 4.2
pub fn month_boundary_under_3_months_shows_weeks_test() {
  age("2025-01-01", "2025-03-31") |> contains_week |> should.be_true
}

// 4.3
pub fn month_boundary_3_months_mid_month_test() {
  age("2025-06-15", "2025-09-15") |> should.equal(Ok("3 months"))
}

// 4.4
pub fn month_boundary_under_3_months_mid_month_shows_weeks_test() {
  age("2025-06-15", "2025-09-14") |> contains_week |> should.be_true
}

// 4.5
pub fn month_boundary_6_months_test() {
  age("2025-06-15", "2025-12-15") |> should.equal(Ok("6 months"))
}

// 5. Month boundaries - Feb non-leap

// 5.1
pub fn feb_nonleap_jan31_to_feb28_test() {
  age("2025-01-31", "2025-02-28") |> should.equal(Ok("4 weeks"))
}

// 5.2
pub fn feb_nonleap_jan31_to_apr30_test() {
  age("2025-01-31", "2025-04-30") |> should.equal(Ok("3 months"))
}

// 5.3
pub fn feb_nonleap_jan31_to_apr29_shows_weeks_test() {
  age("2025-01-31", "2025-04-29") |> contains_week |> should.be_true
}

// 5.4
pub fn feb_nonleap_feb1_to_may1_test() {
  age("2025-02-01", "2025-05-01") |> should.equal(Ok("3 months"))
}

// 5.5
pub fn feb_nonleap_feb1_to_apr30_shows_weeks_test() {
  age("2025-02-01", "2025-04-30") |> contains_week |> should.be_true
}

// 6. Month boundaries - Feb leap year

// 6.1
pub fn feb_leap_jan31_to_feb29_test() {
  age("2024-01-31", "2024-02-29") |> should.equal(Ok("4 weeks, 1 day"))
}

// 6.2
pub fn feb_leap_jan31_to_feb28_test() {
  age("2024-01-31", "2024-02-28") |> should.equal(Ok("4 weeks"))
}

// 6.3
pub fn feb_leap_jan31_to_apr30_test() {
  age("2024-01-31", "2024-04-30") |> should.equal(Ok("3 months"))
}

// 6.4
pub fn feb_leap_jan30_to_feb29_shows_weeks_test() {
  age("2024-01-30", "2024-02-29") |> contains_week |> should.be_true
}

// 6.5
pub fn feb_leap_jan30_to_feb28_shows_weeks_test() {
  age("2024-01-30", "2024-02-28") |> contains_week |> should.be_true
}

// 7. Month boundaries - 30-day months

// 7.1
pub fn month_30day_mar31_to_jun30_test() {
  age("2025-03-31", "2025-06-30") |> should.equal(Ok("3 months"))
}

// 7.2
pub fn month_30day_mar31_to_jun29_shows_weeks_test() {
  age("2025-03-31", "2025-06-29") |> contains_week |> should.be_true
}

// 7.3
pub fn month_30day_aug31_to_nov30_test() {
  age("2025-08-31", "2025-11-30") |> should.equal(Ok("3 months"))
}

// 7.4
pub fn month_30day_aug31_to_nov29_shows_weeks_test() {
  age("2025-08-31", "2025-11-29") |> contains_week |> should.be_true
}

// 8. Leap year baby

// 8.1
pub fn leap_baby_3_months_test() {
  age("2024-02-29", "2024-05-29") |> should.equal(Ok("3 months"))
}

// 8.2
pub fn leap_baby_under_3_months_shows_weeks_test() {
  age("2024-02-29", "2024-05-28") |> contains_week |> should.be_true
}

// 8.3
pub fn leap_baby_12_months_feb28_test() {
  age("2024-02-29", "2025-02-28") |> should.equal(Ok("12 months"))
}

// 8.4
pub fn leap_baby_12_months_mar1_test() {
  age("2024-02-29", "2025-03-01") |> should.equal(Ok("12 months"))
}

// 9. Months tier (3-23 months)

// 9.1
pub fn months_3_months_test() {
  age("2025-01-15", "2025-04-15") |> should.equal(Ok("3 months"))
}

// 9.2
pub fn months_6_months_test() {
  age("2025-01-15", "2025-07-15") |> should.equal(Ok("6 months"))
}

// 9.3
pub fn months_12_months_test() {
  age("2024-06-15", "2025-06-15") |> should.equal(Ok("12 months"))
}

// 9.4
pub fn months_23_months_test() {
  age("2024-01-15", "2025-12-15") |> should.equal(Ok("23 months"))
}

// 9.5
pub fn months_5_months_day_before_test() {
  age("2025-01-15", "2025-07-14") |> should.equal(Ok("5 months"))
}

// 9.6
pub fn months_5_months_cross_year_test() {
  age("2024-11-10", "2025-04-10") |> should.equal(Ok("5 months"))
}

// 10. Years+months tier (24-35 months)

// 10.1
pub fn years_months_exactly_2_years_test() {
  age("2023-06-15", "2025-06-15") |> should.equal(Ok("2 years"))
}

// 10.2
pub fn years_months_2_years_1_month_test() {
  age("2023-06-15", "2025-07-15") |> should.equal(Ok("2 years, 1 month"))
}

// 10.3
pub fn years_months_2_years_6_months_test() {
  age("2023-06-15", "2025-12-15") |> should.equal(Ok("2 years, 6 months"))
}

// 10.4
pub fn years_months_2_years_11_months_test() {
  age("2023-06-15", "2026-05-15") |> should.equal(Ok("2 years, 11 months"))
}

// 10.5
pub fn years_months_under_24_months_shows_23_test() {
  age("2023-06-15", "2025-06-14") |> should.equal(Ok("23 months"))
}

// 11. Half-year tier (3-6 years)

// 11.1
pub fn half_3_years_test() {
  age("2022-06-15", "2025-06-15") |> should.equal(Ok("3 years"))
}

// 11.2
pub fn half_3_years_5m_past_test() {
  age("2022-06-15", "2025-11-15") |> should.equal(Ok("3 years"))
}

// 11.3
pub fn half_3_half_years_test() {
  age("2022-06-15", "2025-12-15") |> should.equal(Ok("3½ years"))
}

// 11.4
pub fn half_3_half_years_11m_past_test() {
  age("2022-06-15", "2026-05-15") |> should.equal(Ok("3½ years"))
}

// 11.5
pub fn half_4_years_test() {
  age("2021-06-15", "2025-06-15") |> should.equal(Ok("4 years"))
}

// 11.6
pub fn half_4_half_years_test() {
  age("2021-06-15", "2025-12-15") |> should.equal(Ok("4½ years"))
}

// 11.7
pub fn half_5_years_test() {
  age("2020-06-15", "2025-06-15") |> should.equal(Ok("5 years"))
}

// 11.8
pub fn half_5_half_years_test() {
  age("2020-06-15", "2026-02-15") |> should.equal(Ok("5½ years"))
}

// 11.9
pub fn half_6_years_test() {
  age("2019-06-15", "2025-06-15") |> should.equal(Ok("6 years"))
}

// 11.10
pub fn half_6_half_years_test() {
  age("2019-06-15", "2025-12-15") |> should.equal(Ok("6½ years"))
}

// 11.11
pub fn half_6_half_years_11m_test() {
  age("2019-06-15", "2026-05-15") |> should.equal(Ok("6½ years"))
}

// 11.12
pub fn half_under_3_years_shows_2y11m_test() {
  age("2022-06-15", "2025-06-14") |> should.equal(Ok("2 years, 11 months"))
}

// 12. Integer tier (7+ years)

// 12.1
pub fn integer_7_years_test() {
  age("2018-06-15", "2025-06-15") |> should.equal(Ok("7 years"))
}

// 12.2
pub fn integer_7_years_3m_past_test() {
  age("2018-03-20", "2025-06-15") |> should.equal(Ok("7 years"))
}

// 12.3
pub fn integer_45_years_test() {
  age("1980-01-01", "2025-06-15") |> should.equal(Ok("45 years"))
}

// 13. Cross-year transitions with February

// 13.1
pub fn cross_year_dec31_to_mar31_test() {
  age("2024-12-31", "2025-03-31") |> should.equal(Ok("3 months"))
}

// 13.2
pub fn cross_year_dec31_to_mar30_shows_weeks_test() {
  age("2024-12-31", "2025-03-30") |> contains_week |> should.be_true
}

// 13.3
pub fn cross_year_nov30_to_feb28_test() {
  age("2024-11-30", "2025-02-28") |> should.equal(Ok("3 months"))
}

// 13.4
pub fn cross_year_nov30_to_feb27_shows_weeks_test() {
  age("2024-11-30", "2025-02-27") |> contains_week |> should.be_true
}

// 14. Born-on-31st progression

// 14.1
pub fn born_31st_jan31_to_apr30_test() {
  age("2025-01-31", "2025-04-30") |> should.equal(Ok("3 months"))
}

// 14.2
pub fn born_31st_jan31_to_may31_test() {
  age("2025-01-31", "2025-05-31") |> should.equal(Ok("4 months"))
}

// 14.3
pub fn born_31st_jan31_to_jun30_test() {
  age("2025-01-31", "2025-06-30") |> should.equal(Ok("5 months"))
}

// 14.4
pub fn born_31st_jan31_to_jul1_test() {
  age("2025-01-31", "2025-07-01") |> should.equal(Ok("5 months"))
}

// 14.5
pub fn born_31st_jan31_to_jul31_test() {
  age("2025-01-31", "2025-07-31") |> should.equal(Ok("6 months"))
}

// 15. Default asOf -- skipped (test only pure variants)

// 16. formatStage - null / edge cases

// 16.1, 16.2, 16.3
pub fn stage_null_empty_dob_test() {
  stage("", "2025-06-15") |> should.equal(Error(Nil))
}

// 16.4
pub fn stage_null_future_dob_test() {
  stage("2025-07-01", "2025-06-15") |> should.equal(Error(Nil))
}

// 16.5
pub fn stage_null_500_years_adult_test() {
  stage("1525-06-15", "2025-06-15") |> should.equal(Ok("Adult"))
}

// 16.6
pub fn stage_null_501_years_error_test() {
  stage("1524-06-15", "2025-06-15") |> should.equal(Error(Nil))
}

// 17. formatStage - Newborn

// 17.1
pub fn stage_newborn_same_day_test() {
  stage("2025-06-15", "2025-06-15") |> should.equal(Ok("Newborn"))
}

// 17.2
pub fn stage_newborn_1_day_test() {
  stage("2025-06-14", "2025-06-15") |> should.equal(Ok("Newborn"))
}

// 17.3
pub fn stage_newborn_3_weeks_test() {
  stage("2025-05-25", "2025-06-15") |> should.equal(Ok("Newborn"))
}

// 17.4
pub fn stage_newborn_1_month_test() {
  stage("2025-05-15", "2025-06-15") |> should.equal(Ok("Newborn"))
}

// 17.5
pub fn stage_newborn_just_under_2_months_test() {
  stage("2025-04-16", "2025-06-15") |> should.equal(Ok("Newborn"))
}

// 17.6
pub fn stage_newborn_exactly_2_months_is_infant_test() {
  stage("2025-04-15", "2025-06-15") |> should.equal(Ok("Infant"))
}

// 18. formatStage - Infant

// 18.1
pub fn stage_infant_2_months_test() {
  stage("2025-04-15", "2025-06-15") |> should.equal(Ok("Infant"))
}

// 18.2
pub fn stage_infant_6_months_test() {
  stage("2024-12-15", "2025-06-15") |> should.equal(Ok("Infant"))
}

// 18.3
pub fn stage_infant_11_months_test() {
  stage("2024-07-15", "2025-06-15") |> should.equal(Ok("Infant"))
}

// 18.4
pub fn stage_infant_12_months_is_toddler_test() {
  stage("2024-06-15", "2025-06-15") |> should.equal(Ok("Toddler"))
}

// 19. formatStage - Toddler

// 19.1
pub fn stage_toddler_12_months_test() {
  stage("2024-06-15", "2025-06-15") |> should.equal(Ok("Toddler"))
}

// 19.2
pub fn stage_toddler_18_months_test() {
  stage("2024-01-15", "2025-07-15") |> should.equal(Ok("Toddler"))
}

// 19.3
pub fn stage_toddler_24_months_test() {
  stage("2023-06-15", "2025-06-15") |> should.equal(Ok("Toddler"))
}

// 19.4
pub fn stage_toddler_35_months_test() {
  stage("2023-06-15", "2026-05-15") |> should.equal(Ok("Toddler"))
}

// 19.5
pub fn stage_toddler_36_months_is_child_test() {
  stage("2022-06-15", "2025-06-15") |> should.equal(Ok("Child"))
}

// 20. formatStage - Child

// 20.1
pub fn stage_child_3_years_test() {
  stage("2022-06-15", "2025-06-15") |> should.equal(Ok("Child"))
}

// 20.2
pub fn stage_child_4_years_test() {
  stage("2021-06-15", "2025-06-15") |> should.equal(Ok("Child"))
}

// 20.3
pub fn stage_child_6_years_test() {
  stage("2019-06-15", "2025-06-15") |> should.equal(Ok("Child"))
}

// 20.4
pub fn stage_child_9_years_test() {
  stage("2016-06-15", "2025-06-15") |> should.equal(Ok("Child"))
}

// 20.5
pub fn stage_child_12y11m_test() {
  stage("2013-06-15", "2026-05-15") |> should.equal(Ok("Child"))
}

// 20.6
pub fn stage_child_13_years_is_teenager_test() {
  stage("2012-06-15", "2025-06-15") |> should.equal(Ok("Teenager"))
}

// 21. formatStage - Teenager

// 21.1
pub fn stage_teenager_13_years_test() {
  stage("2012-06-15", "2025-06-15") |> should.equal(Ok("Teenager"))
}

// 21.2
pub fn stage_teenager_15_years_test() {
  stage("2010-06-15", "2025-06-15") |> should.equal(Ok("Teenager"))
}

// 21.3
pub fn stage_teenager_17y11m_test() {
  stage("2008-06-15", "2026-05-15") |> should.equal(Ok("Teenager"))
}

// 21.4
pub fn stage_teenager_18_years_is_adult_test() {
  stage("2007-06-15", "2025-06-15") |> should.equal(Ok("Adult"))
}

// 22. formatStage - Adult

// 22.1
pub fn stage_adult_18_years_test() {
  stage("2007-06-15", "2025-06-15") |> should.equal(Ok("Adult"))
}

// 22.2
pub fn stage_adult_25_years_test() {
  stage("2000-06-15", "2025-06-15") |> should.equal(Ok("Adult"))
}

// 22.3
pub fn stage_adult_45_years_test() {
  stage("1980-01-01", "2025-06-15") |> should.equal(Ok("Adult"))
}

// 23. formatStage - default asOf -- skipped

// 24. SayableAge class - English locale delegation

// 24.1
pub fn delegation_newborn_test() {
  let en = locale_en.locale()
  sayableage.format_age(en, Normal, "2025-06-15", "2025-06-15")
  |> should.equal(Ok("Newborn"))
}

// 24.2
pub fn delegation_3_days_test() {
  let en = locale_en.locale()
  sayableage.format_age(en, Normal, "2025-06-12", "2025-06-15")
  |> should.equal(Ok("3 days"))
}

// 24.3
pub fn delegation_1_week_1_day_test() {
  let en = locale_en.locale()
  sayableage.format_age(en, Normal, "2025-06-07", "2025-06-15")
  |> should.equal(Ok("1 week, 1 day"))
}

// 24.4
pub fn delegation_6_months_test() {
  let en = locale_en.locale()
  sayableage.format_age(en, Normal, "2025-01-15", "2025-07-15")
  |> should.equal(Ok("6 months"))
}

// 24.5
pub fn delegation_2_years_1_month_test() {
  let en = locale_en.locale()
  sayableage.format_age(en, Normal, "2023-06-15", "2025-07-15")
  |> should.equal(Ok("2 years, 1 month"))
}

// 24.6
pub fn delegation_3_half_years_test() {
  let en = locale_en.locale()
  sayableage.format_age(en, Normal, "2022-06-15", "2025-12-15")
  |> should.equal(Ok("3½ years"))
}

// 24.7
pub fn delegation_7_years_test() {
  let en = locale_en.locale()
  sayableage.format_age(en, Normal, "2018-06-15", "2025-06-15")
  |> should.equal(Ok("7 years"))
}

// 24.8
pub fn delegation_stage_newborn_test() {
  let en = locale_en.locale()
  sayableage.format_stage(en, "2025-06-15", "2025-06-15", Error(Nil))
  |> should.equal(Ok("Newborn"))
}

// 24.9
pub fn delegation_stage_infant_test() {
  let en = locale_en.locale()
  sayableage.format_stage(en, "2025-01-15", "2025-06-15", Error(Nil))
  |> should.equal(Ok("Infant"))
}

// 24.10
pub fn delegation_stage_toddler_test() {
  let en = locale_en.locale()
  sayableage.format_stage(en, "2024-06-15", "2025-06-15", Error(Nil))
  |> should.equal(Ok("Toddler"))
}

// 24.11
pub fn delegation_stage_child_test() {
  let en = locale_en.locale()
  sayableage.format_stage(en, "2022-06-15", "2025-06-15", Error(Nil))
  |> should.equal(Ok("Child"))
}

// 24.12
pub fn delegation_stage_teenager_test() {
  let en = locale_en.locale()
  sayableage.format_stage(en, "2012-06-15", "2025-06-15", Error(Nil))
  |> should.equal(Ok("Teenager"))
}

// 24.13
pub fn delegation_stage_adult_test() {
  let en = locale_en.locale()
  sayableage.format_stage(en, "2007-06-15", "2025-06-15", Error(Nil))
  |> should.equal(Ok("Adult"))
}

// 24.14
pub fn delegation_empty_dob_error_test() {
  let en = locale_en.locale()
  sayableage.format_age(en, Normal, "", "2025-06-15")
  |> should.equal(Error(Nil))
}

// 24.15
pub fn delegation_empty_dob_stage_error_test() {
  let en = locale_en.locale()
  sayableage.format_stage(en, "", "2025-06-15", Error(Nil))
  |> should.equal(Error(Nil))
}

// 25. i18n - Spanish locale

// 25.1
pub fn spanish_newborn_test() {
  let es = locale_es.locale()
  age_locale(es, "2025-06-15", "2025-06-15") |> should.equal(Ok("Recién nacido"))
}

// 25.2
pub fn spanish_1_day_test() {
  let es = locale_es.locale()
  age_locale(es, "2025-06-14", "2025-06-15") |> should.equal(Ok("1 día"))
}

// 25.3
pub fn spanish_3_days_test() {
  let es = locale_es.locale()
  age_locale(es, "2025-06-12", "2025-06-15") |> should.equal(Ok("3 días"))
}

// 25.4
pub fn spanish_1_week_test() {
  let es = locale_es.locale()
  age_locale(es, "2025-06-08", "2025-06-15") |> should.equal(Ok("1 semana"))
}

// 25.5
pub fn spanish_1_week_1_day_test() {
  let es = locale_es.locale()
  age_locale(es, "2025-06-07", "2025-06-15")
  |> should.equal(Ok("1 semana, 1 día"))
}

// 25.6
pub fn spanish_2_weeks_6_days_test() {
  let es = locale_es.locale()
  age_locale(es, "2025-05-26", "2025-06-15")
  |> should.equal(Ok("2 semanas, 6 días"))
}

// 25.7
pub fn spanish_6_months_test() {
  let es = locale_es.locale()
  age_locale(es, "2025-01-15", "2025-07-15") |> should.equal(Ok("6 meses"))
}

// 25.8
pub fn spanish_2_years_1_month_test() {
  let es = locale_es.locale()
  age_locale(es, "2023-06-15", "2025-07-15")
  |> should.equal(Ok("2 años, 1 mes"))
}

// 25.9
pub fn spanish_2_years_6_months_test() {
  let es = locale_es.locale()
  age_locale(es, "2023-06-15", "2025-12-15")
  |> should.equal(Ok("2 años, 6 meses"))
}

// 25.10
pub fn spanish_3_half_years_test() {
  let es = locale_es.locale()
  age_locale(es, "2022-06-15", "2025-12-15")
  |> should.equal(Ok("3 y medio años"))
}

// 25.11
pub fn spanish_3_years_test() {
  let es = locale_es.locale()
  age_locale(es, "2022-06-15", "2025-06-15") |> should.equal(Ok("3 años"))
}

// 25.12
pub fn spanish_7_years_test() {
  let es = locale_es.locale()
  age_locale(es, "2018-06-15", "2025-06-15") |> should.equal(Ok("7 años"))
}

// 25.13
pub fn spanish_stage_newborn_test() {
  let es = locale_es.locale()
  stage_locale(es, "2025-06-15", "2025-06-15", Error(Nil))
  |> should.equal(Ok("Recién nacido"))
}

// 25.14
pub fn spanish_stage_infant_test() {
  let es = locale_es.locale()
  stage_locale(es, "2025-01-15", "2025-06-15", Error(Nil))
  |> should.equal(Ok("Bebé"))
}

// 25.15
pub fn spanish_stage_toddler_test() {
  let es = locale_es.locale()
  stage_locale(es, "2024-06-15", "2025-06-15", Error(Nil))
  |> should.equal(Ok("Niño pequeño"))
}

// 25.16
pub fn spanish_stage_child_test() {
  let es = locale_es.locale()
  stage_locale(es, "2022-06-15", "2025-06-15", Error(Nil))
  |> should.equal(Ok("Niño"))
}

// 25.17
pub fn spanish_stage_teenager_test() {
  let es = locale_es.locale()
  stage_locale(es, "2012-06-15", "2025-06-15", Error(Nil))
  |> should.equal(Ok("Adolescente"))
}

// 25.18
pub fn spanish_stage_adult_test() {
  let es = locale_es.locale()
  stage_locale(es, "2007-06-15", "2025-06-15", Error(Nil))
  |> should.equal(Ok("Adulto"))
}

// 25.19
pub fn spanish_empty_dob_error_test() {
  let es = locale_es.locale()
  age_locale(es, "", "2025-06-15") |> should.equal(Error(Nil))
}

// 25.20
pub fn spanish_empty_dob_stage_error_test() {
  let es = locale_es.locale()
  stage_locale(es, "", "2025-06-15", Error(Nil)) |> should.equal(Error(Nil))
}

// 26. Compactness - short

// 26.1
pub fn short_3_days_test() {
  age_short("2025-06-12", "2025-06-15") |> should.equal(Ok("3 d"))
}

// 26.2
pub fn short_1_week_test() {
  age_short("2025-06-08", "2025-06-15") |> should.equal(Ok("1 wk"))
}

// 26.3
pub fn short_1_week_1_day_test() {
  age_short("2025-06-07", "2025-06-15") |> should.equal(Ok("1 wk, 1 d"))
}

// 26.4
pub fn short_6_months_test() {
  age_short("2025-01-15", "2025-07-15") |> should.equal(Ok("6 mo"))
}

// 26.5
pub fn short_2_years_1_month_test() {
  age_short("2023-06-15", "2025-07-15") |> should.equal(Ok("2 yr, 1 mo"))
}

// 26.6
pub fn short_3_half_years_test() {
  age_short("2022-06-15", "2025-12-15") |> should.equal(Ok("3½ yr"))
}

// 26.7
pub fn short_7_years_test() {
  age_short("2018-06-15", "2025-06-15") |> should.equal(Ok("7 yr"))
}

// 26.8
pub fn short_newborn_test() {
  age_short("2025-06-15", "2025-06-15") |> should.equal(Ok("Newborn"))
}

// 26.9
pub fn short_stage_still_works_test() {
  stage("2025-01-15", "2025-06-15") |> should.equal(Ok("Infant"))
}

// 27. Compactness - compact

// 27.1
pub fn compact_3_days_test() {
  age_compact("2025-06-12", "2025-06-15") |> should.equal(Ok("3d"))
}

// 27.2
pub fn compact_1_week_test() {
  age_compact("2025-06-08", "2025-06-15") |> should.equal(Ok("1w"))
}

// 27.3
pub fn compact_1_week_1_day_test() {
  age_compact("2025-06-07", "2025-06-15") |> should.equal(Ok("1w1d"))
}

// 27.4
pub fn compact_6_months_test() {
  age_compact("2025-01-15", "2025-07-15") |> should.equal(Ok("6m"))
}

// 27.5
pub fn compact_2_years_1_month_test() {
  age_compact("2023-06-15", "2025-07-15") |> should.equal(Ok("2y1m"))
}

// 27.6
pub fn compact_3_half_years_test() {
  age_compact("2022-06-15", "2025-12-15") |> should.equal(Ok("3½y"))
}

// 27.7
pub fn compact_7_years_test() {
  age_compact("2018-06-15", "2025-06-15") |> should.equal(Ok("7y"))
}

// 27.8
pub fn compact_newborn_test() {
  age_compact("2025-06-15", "2025-06-15") |> should.equal(Ok("Newborn"))
}

// 29. Locale-specific edge cases

// 29.1 - Hebrew (he) - dual forms

// 29.1
pub fn hebrew_newborn_test() {
  let he = locale_he.locale()
  age_locale(he, "2025-06-15", "2025-06-15") |> should.equal(Ok("רק נולד"))
}

// 29.2
pub fn hebrew_1_day_test() {
  let he = locale_he.locale()
  age_locale(he, "2025-06-14", "2025-06-15") |> should.equal(Ok("יום 1"))
}

// 29.3
pub fn hebrew_3_days_test() {
  let he = locale_he.locale()
  age_locale(he, "2025-06-12", "2025-06-15") |> should.equal(Ok("3 ימים"))
}

// 29.4
pub fn hebrew_2_weeks_dual_test() {
  let he = locale_he.locale()
  age_locale(he, "2025-06-01", "2025-06-15") |> should.equal(Ok("שבועיים"))
}

// 29.5
pub fn hebrew_3_weeks_test() {
  let he = locale_he.locale()
  age_locale(he, "2025-05-25", "2025-06-15") |> should.equal(Ok("3 שבועות"))
}

// 29.6
pub fn hebrew_6_months_test() {
  let he = locale_he.locale()
  age_locale(he, "2025-01-15", "2025-07-15") |> should.equal(Ok("6 חודשים"))
}

// 29.7
pub fn hebrew_3_months_test() {
  let he = locale_he.locale()
  age_locale(he, "2025-03-15", "2025-06-15") |> should.equal(Ok("3 חודשים"))
}

// 29.8
pub fn hebrew_2_years_1_month_test() {
  let he = locale_he.locale()
  age_locale(he, "2023-06-15", "2025-07-15")
  |> should.equal(Ok("שנתיים, חודש 1"))
}

// 29.9
pub fn hebrew_3_half_years_test() {
  let he = locale_he.locale()
  age_locale(he, "2022-06-15", "2025-12-15")
  |> should.equal(Ok("3 שנים וחצי"))
}

// 29.10
pub fn hebrew_7_years_test() {
  let he = locale_he.locale()
  age_locale(he, "2018-06-15", "2025-06-15") |> should.equal(Ok("7 שנים"))
}

// 29.11
pub fn hebrew_stage_newborn_male_test() {
  let he = locale_he.locale()
  stage_locale(he, "2025-06-15", "2025-06-15", Ok(Male))
  |> should.equal(Ok("רק נולד"))
}

// 29.12
pub fn hebrew_stage_newborn_female_test() {
  let he = locale_he.locale()
  stage_locale(he, "2025-06-15", "2025-06-15", Ok(Female))
  |> should.equal(Ok("רק נולדה"))
}

// 29.13
pub fn hebrew_stage_adult_male_test() {
  let he = locale_he.locale()
  stage_locale(he, "2007-06-15", "2025-06-15", Ok(Male))
  |> should.equal(Ok("מבוגר"))
}

// 29.14
pub fn hebrew_stage_adult_female_test() {
  let he = locale_he.locale()
  stage_locale(he, "2007-06-15", "2025-06-15", Ok(Female))
  |> should.equal(Ok("מבוגרת"))
}

// 29.2 - Macedonian (mk)

// 29.15
pub fn macedonian_newborn_test() {
  let mk_locale = locale_mk.locale()
  age_locale(mk_locale, "2025-06-15", "2025-06-15")
  |> should.equal(Ok("Новороденче"))
}

// 29.16
pub fn macedonian_1_day_test() {
  let mk_locale = locale_mk.locale()
  age_locale(mk_locale, "2025-06-14", "2025-06-15")
  |> should.equal(Ok("1 ден"))
}

// 29.17
pub fn macedonian_3_days_test() {
  let mk_locale = locale_mk.locale()
  age_locale(mk_locale, "2025-06-12", "2025-06-15")
  |> should.equal(Ok("3 дена"))
}

// 29.18
pub fn macedonian_6_months_test() {
  let mk_locale = locale_mk.locale()
  age_locale(mk_locale, "2025-01-15", "2025-07-15")
  |> should.equal(Ok("6 месеци"))
}

// 29.19
pub fn macedonian_2_years_1_month_test() {
  let mk_locale = locale_mk.locale()
  age_locale(mk_locale, "2023-06-15", "2025-07-15")
  |> should.equal(Ok("2 години, 1 месец"))
}

// 29.20
pub fn macedonian_3_half_years_test() {
  let mk_locale = locale_mk.locale()
  age_locale(mk_locale, "2022-06-15", "2025-12-15")
  |> should.equal(Ok("3 години и пол"))
}

// 29.21
pub fn macedonian_7_years_test() {
  let mk_locale = locale_mk.locale()
  age_locale(mk_locale, "2018-06-15", "2025-06-15")
  |> should.equal(Ok("7 години"))
}

// 29.3 - Swahili (sw)

// 29.22
pub fn swahili_newborn_test() {
  let sw_locale = locale_sw.locale()
  age_locale(sw_locale, "2025-06-15", "2025-06-15")
  |> should.equal(Ok("Mzaliwa mpya"))
}

// 29.23
pub fn swahili_1_day_test() {
  let sw_locale = locale_sw.locale()
  age_locale(sw_locale, "2025-06-14", "2025-06-15")
  |> should.equal(Ok("siku 1"))
}

// 29.24
pub fn swahili_3_days_test() {
  let sw_locale = locale_sw.locale()
  age_locale(sw_locale, "2025-06-12", "2025-06-15")
  |> should.equal(Ok("siku 3"))
}

// 29.25
pub fn swahili_6_months_test() {
  let sw_locale = locale_sw.locale()
  age_locale(sw_locale, "2025-01-15", "2025-07-15")
  |> should.equal(Ok("miezi 6"))
}

// 29.26
pub fn swahili_2_years_1_month_test() {
  let sw_locale = locale_sw.locale()
  age_locale(sw_locale, "2023-06-15", "2025-07-15")
  |> should.equal(Ok("miaka 2, mwezi 1"))
}

// 29.27
pub fn swahili_3_half_years_test() {
  let sw_locale = locale_sw.locale()
  age_locale(sw_locale, "2022-06-15", "2025-12-15")
  |> should.equal(Ok("miaka 3 na nusu"))
}

// 29.4 - Indonesian (id) - other_only

// 29.28
pub fn indonesian_newborn_test() {
  let id_locale = locale_id.locale()
  age_locale(id_locale, "2025-06-15", "2025-06-15")
  |> should.equal(Ok("Baru lahir"))
}

// 29.29
pub fn indonesian_1_day_test() {
  let id_locale = locale_id.locale()
  age_locale(id_locale, "2025-06-14", "2025-06-15")
  |> should.equal(Ok("1 hari"))
}

// 29.30
pub fn indonesian_3_days_test() {
  let id_locale = locale_id.locale()
  age_locale(id_locale, "2025-06-12", "2025-06-15")
  |> should.equal(Ok("3 hari"))
}

// 29.31
pub fn indonesian_6_months_test() {
  let id_locale = locale_id.locale()
  age_locale(id_locale, "2025-01-15", "2025-07-15")
  |> should.equal(Ok("6 bulan"))
}

// 29.32
pub fn indonesian_3_half_years_test() {
  let id_locale = locale_id.locale()
  age_locale(id_locale, "2022-06-15", "2025-12-15")
  |> should.equal(Ok("3 tahun setengah"))
}

// 29.33
pub fn indonesian_7_years_test() {
  let id_locale = locale_id.locale()
  age_locale(id_locale, "2018-06-15", "2025-06-15")
  |> should.equal(Ok("7 tahun"))
}

// 29.5 - Amharic (am)

// 29.34
pub fn amharic_newborn_test() {
  let am_locale = locale_am.locale()
  age_locale(am_locale, "2025-06-15", "2025-06-15")
  |> should.equal(Ok("አዲስ የተወለደ"))
}

// 29.35
pub fn amharic_1_day_test() {
  let am_locale = locale_am.locale()
  age_locale(am_locale, "2025-06-14", "2025-06-15")
  |> should.equal(Ok("1 ቀን"))
}

// 29.36
pub fn amharic_3_days_test() {
  let am_locale = locale_am.locale()
  age_locale(am_locale, "2025-06-12", "2025-06-15")
  |> should.equal(Ok("3 ቀናት"))
}

// 29.37
pub fn amharic_1_week_1_day_test() {
  let am_locale = locale_am.locale()
  age_locale(am_locale, "2025-06-07", "2025-06-15")
  |> should.equal(Ok("1 ሳምንት፣ 1 ቀን"))
}

// 29.38
pub fn amharic_6_months_test() {
  let am_locale = locale_am.locale()
  age_locale(am_locale, "2025-01-15", "2025-07-15")
  |> should.equal(Ok("6 ወራት"))
}

// 29.39
pub fn amharic_3_half_years_test() {
  let am_locale = locale_am.locale()
  age_locale(am_locale, "2022-06-15", "2025-12-15")
  |> should.equal(Ok("3 ዓመታት ተኩል"))
}

// 30. Locale lookup by code string

// 30.1
pub fn locale_lookup_en_test() {
  let assert Ok(locale) = sayableage.get_locale("en")
  locale.code |> should.equal("en")
}

// 30.2
pub fn locale_lookup_fr_test() {
  let assert Ok(locale) = sayableage.get_locale("fr")
  locale.code |> should.equal("fr")
}

// 30.3
pub fn locale_lookup_unknown_test() {
  sayableage.get_locale("xx") |> should.equal(Error(Nil))
}

// 30.4
pub fn locale_lookup_empty_test() {
  sayableage.get_locale("") |> should.equal(Error(Nil))
}

// 30.5
pub fn locale_lookup_uppercase_fails_test() {
  sayableage.get_locale("EN") |> should.equal(Error(Nil))
}

// 31. Weeks and days across month ends

// 31.1
pub fn weeks_days_across_short_february_test() {
  age("2016-12-31", "2017-03-29") |> should.equal(Ok("12 weeks, 4 days"))
}

// 31.2
pub fn weeks_days_across_year_end_into_leap_year_test() {
  age("1991-11-27", "1992-02-25") |> should.equal(Ok("12 weeks, 6 days"))
}

// 31.3
pub fn weeks_days_across_year_end_test() {
  age("2020-11-30", "2021-01-02") |> should.equal(Ok("4 weeks, 5 days"))
}

// 31.4
pub fn weeks_days_across_short_february_compact_test() {
  age_compact("2016-12-31", "2017-03-29") |> should.equal(Ok("12w4d"))
}

// 32. Half years take their plural form from whole years

// 32.1
pub fn polish_half_year_few_test() {
  age_locale(locale_pl.locale(), "2021-06-15", "2025-01-15")
  |> should.equal(Ok("3 i pół lata"))
}

// 32.2
pub fn polish_half_year_many_short_test() {
  sayableage.format_age(locale_pl.locale(), Short, "2020-06-15", "2025-12-15")
  |> should.equal(Ok("5 i pół lat"))
}

// 32.3
pub fn tachelhit_half_year_few_test() {
  age_locale(locale_shi.locale(), "2005-06-08", "2012-06-07")
  |> should.equal(Ok("6 iseggasen d uzgen"))
}

// 33. Input validation

// 33.1
pub fn invalid_february_30_test() {
  age("2025-02-30", "2032-06-25") |> should.equal(Error(Nil))
}

// 33.2
pub fn invalid_month_13_test() {
  age("2025-13-01", "2027-01-31") |> should.equal(Error(Nil))
}

// 33.3
pub fn invalid_february_29_non_leap_test() {
  age("2023-02-29", "2025-03-01") |> should.equal(Error(Nil))
}

// 33.4
pub fn invalid_day_00_test() {
  age("2025-06-00", "2027-02-25") |> should.equal(Error(Nil))
}

// 33.5
pub fn invalid_unpadded_test() {
  age("2025-6-1", "2027-02-25") |> should.equal(Error(Nil))
}

// 33.6
pub fn invalid_surrounding_whitespace_test() {
  age(" 2025-06-01", "2027-02-25") |> should.equal(Error(Nil))
}

// 33.7
pub fn invalid_datetime_test() {
  age("2025-06-15T10:00:00", "2027-02-25") |> should.equal(Error(Nil))
}

// 33.8
pub fn invalid_as_of_test() {
  age("2020-01-01", "2025-04-31") |> should.equal(Error(Nil))
}

// 33.9
pub fn invalid_stage_test() {
  stage("2025-02-30", "2027-09-05") |> should.equal(Error(Nil))
}

// 33.10
pub fn valid_february_29_leap_year_test() {
  age("2024-02-29", "2026-03-01") |> should.equal(Ok("2 years"))
}
