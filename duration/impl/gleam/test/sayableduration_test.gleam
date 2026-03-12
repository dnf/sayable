import gleeunit
import gleeunit/should
import sayableduration
import sayableduration/locales/de as locale_de
import sayableduration/locales/en as locale_en
import sayableduration/locales/fr as locale_fr
import sayableduration/locales/ja as locale_ja
import sayableduration/types.{Compact, Normal, Short}

pub fn main() {
  gleeunit.main()
}

// Helpers

fn dur(seconds: Int) -> Result(String, Nil) {
  sayableduration.format_duration(locale_en.locale(), Normal, seconds)
}

fn dur_short(seconds: Int) -> Result(String, Nil) {
  sayableduration.format_duration(locale_en.locale(), Short, seconds)
}

fn dur_compact(seconds: Int) -> Result(String, Nil) {
  sayableduration.format_duration(locale_en.locale(), Compact, seconds)
}

fn since(start: String, as_of: String) -> Result(String, Nil) {
  sayableduration.format_since(locale_en.locale(), Normal, start, as_of)
}

fn until(target: String, as_of: String) -> Result(String, Nil) {
  sayableduration.format_until(locale_en.locale(), Normal, target, as_of)
}

// 1. Null / edge cases

// 1.1
pub fn null_seconds_test() {
  sayableduration.format_duration(locale_en.locale(), Normal, -1)
  |> should.equal(Error(Nil))
}

// 1.2
pub fn negative_seconds_test() {
  sayableduration.format_duration(locale_en.locale(), Normal, -1)
  |> should.equal(Error(Nil))
}

// 1.3
pub fn null_start_since_test() {
  sayableduration.format_since(locale_en.locale(), Normal, "", "2025-01-15T10:00:00")
  |> should.equal(Error(Nil))
}

// 1.4
pub fn null_target_until_test() {
  sayableduration.format_until(locale_en.locale(), Normal, "", "2025-01-15T10:00:00")
  |> should.equal(Error(Nil))
}

// 1.5
pub fn since_as_of_before_start_test() {
  since("2025-01-15T10:00:00", "2025-01-15T09:00:00")
  |> should.equal(Error(Nil))
}

// 1.6
pub fn until_target_in_past_test() {
  until("2025-01-15T09:00:00", "2025-01-15T10:00:00")
  |> should.equal(Error(Nil))
}

// 2. Duration -- seconds tier (0-59s)

// 2.1
pub fn zero_seconds_test() {
  dur(0) |> should.equal(Ok("just now"))
}

// 2.2
pub fn one_second_test() {
  dur(1) |> should.equal(Ok("1 second"))
}

// 2.3
pub fn forty_five_seconds_test() {
  dur(45) |> should.equal(Ok("45 seconds"))
}

// 2.4
pub fn fifty_nine_seconds_test() {
  dur(59) |> should.equal(Ok("59 seconds"))
}

// 3. Duration -- minutes + seconds tier (1-4 min)

// 3.1
pub fn one_minute_test() {
  dur(60) |> should.equal(Ok("1 minute"))
}

// 3.2
pub fn one_minute_thirty_seconds_test() {
  dur(90) |> should.equal(Ok("1 minute, 30 seconds"))
}

// 3.3
pub fn four_minutes_test() {
  dur(240) |> should.equal(Ok("4 minutes"))
}

// 3.4
pub fn four_minutes_thirty_seconds_test() {
  dur(270) |> should.equal(Ok("4 minutes, 30 seconds"))
}

// 4. Duration -- minutes tier (5-59 min)

// 4.1
pub fn five_minutes_test() {
  dur(300) |> should.equal(Ok("5 minutes"))
}

// 4.2
pub fn twenty_five_minutes_test() {
  dur(1500) |> should.equal(Ok("25 minutes"))
}

// 4.3
pub fn fifty_nine_minutes_test() {
  dur(3540) |> should.equal(Ok("59 minutes"))
}

// 5. Duration -- hours + minutes tier (1-5 hr)

// 5.1
pub fn one_hour_test() {
  dur(3600) |> should.equal(Ok("1 hour"))
}

// 5.2
pub fn one_half_hours_test() {
  dur(5400) |> should.equal(Ok("1½ hours"))
}

// 5.3
pub fn two_hours_fifteen_minutes_test() {
  dur(8100) |> should.equal(Ok("2 hours, 15 minutes"))
}

// 5.4
pub fn five_hours_test() {
  dur(18_000) |> should.equal(Ok("5 hours"))
}

// 6. Duration -- hours tier (6-23 hr)

// 6.1
pub fn eight_hours_test() {
  dur(28_800) |> should.equal(Ok("8 hours"))
}

// 6.2
pub fn twenty_three_hours_test() {
  dur(82_800) |> should.equal(Ok("23 hours"))
}

// 7. Duration -- days tier

// 7.1
pub fn one_day_test() {
  dur(86_400) |> should.equal(Ok("1 day"))
}

// 7.2
pub fn one_day_three_hours_test() {
  dur(97_200) |> should.equal(Ok("1 day, 3 hours"))
}

// 7.3
pub fn one_half_days_test() {
  dur(129_600) |> should.equal(Ok("1½ days"))
}

// 7.4
pub fn five_days_test() {
  dur(432_000) |> should.equal(Ok("5 days"))
}

// 7.5
pub fn two_days_test() {
  dur(172_800) |> should.equal(Ok("2 days"))
}

// 8. Duration -- weeks tier

// 8.1
pub fn one_week_test() {
  dur(604_800) |> should.equal(Ok("1 week"))
}

// 8.2
pub fn two_weeks_one_day_test() {
  dur(1_296_000) |> should.equal(Ok("2 weeks, 1 day"))
}

// 8.3
pub fn four_weeks_test() {
  dur(2_419_200) |> should.equal(Ok("4 weeks"))
}

// 9. Duration -- months and years tier

// 9.1
pub fn one_month_test() {
  dur(2_678_400) |> should.equal(Ok("1 month"))
}

// 9.2
pub fn three_months_test() {
  dur(7_884_000) |> should.equal(Ok("3 months"))
}

// 9.3
pub fn one_year_test() {
  dur(31_536_000) |> should.equal(Ok("1 year"))
}

// 9.4
pub fn one_year_three_months_test() {
  dur(39_420_000) |> should.equal(Ok("1 year, 3 months"))
}

// 10. Duration from ISO timestamps

// 10.1
pub fn iso_one_half_hours_test() {
  sayableduration.format_duration_timestamps(
    locale_en.locale(),
    Normal,
    "2025-01-15T10:00:00",
    "2025-01-15T11:30:00",
  )
  |> should.equal(Ok("1½ hours"))
}

// 10.2
pub fn iso_forty_five_minutes_test() {
  sayableduration.format_duration_timestamps(
    locale_en.locale(),
    Normal,
    "2025-01-15T10:00:00",
    "2025-01-15T10:45:00",
  )
  |> should.equal(Ok("45 minutes"))
}

// 11. Relative time -- since

// 11.1
pub fn since_just_now_test() {
  since("2025-01-15T10:00:00", "2025-01-15T10:00:00")
  |> should.equal(Ok("just now"))
}

// 11.2
pub fn since_thirty_seconds_ago_test() {
  since("2025-01-15T10:00:00", "2025-01-15T10:00:30")
  |> should.equal(Ok("30 seconds ago"))
}

// 11.3
pub fn since_forty_five_minutes_ago_test() {
  since("2025-01-15T10:00:00", "2025-01-15T10:45:00")
  |> should.equal(Ok("45 minutes ago"))
}

// 11.4
pub fn since_three_hours_ago_test() {
  since("2025-01-15T10:00:00", "2025-01-15T13:00:00")
  |> should.equal(Ok("3 hours ago"))
}

// 12. Relative time -- until

// 12.1
pub fn until_just_now_test() {
  until("2025-01-15T10:00:00", "2025-01-15T10:00:00")
  |> should.equal(Ok("just now"))
}

// 12.2
pub fn until_twenty_minutes_test() {
  until("2025-01-15T10:20:00", "2025-01-15T10:00:00")
  |> should.equal(Ok("in 20 minutes"))
}

// 12.3
pub fn until_three_hours_test() {
  until("2025-01-15T13:00:00", "2025-01-15T10:00:00")
  |> should.equal(Ok("in 3 hours"))
}

// 13. Locale -- German

// 13.1
pub fn german_one_hour_test() {
  sayableduration.format_duration(locale_de.locale(), Normal, 3600)
  |> should.equal(Ok("1 Stunde"))
}

// 13.2
pub fn german_five_minutes_ago_test() {
  sayableduration.format_since(
    locale_de.locale(),
    Normal,
    "2025-01-15T10:00:00",
    "2025-01-15T10:05:00",
  )
  |> should.equal(Ok("vor 5 Minuten"))
}

// 14. Locale -- French

// 14.1
pub fn french_two_hours_test() {
  sayableduration.format_duration(locale_fr.locale(), Normal, 7200)
  |> should.equal(Ok("2 heures"))
}

// 15. Locale -- Japanese

// 15.1
pub fn japanese_two_minutes_test() {
  sayableduration.format_duration(locale_ja.locale(), Normal, 120)
  |> should.equal(Ok("2分"))
}

// 15.2
pub fn japanese_one_hour_ago_test() {
  sayableduration.format_since(
    locale_ja.locale(),
    Normal,
    "2025-01-15T10:00:00",
    "2025-01-15T11:00:00",
  )
  |> should.equal(Ok("1時間前"))
}

// 16. Short compactness -- duration

// 16.1
pub fn short_one_hour_test() {
  dur_short(3600) |> should.equal(Ok("1h"))
}

// 16.2
pub fn short_one_minute_thirty_seconds_test() {
  dur_short(90) |> should.equal(Ok("1m, 30s"))
}

// 17. Compact compactness -- duration

// 17.1
pub fn compact_one_hour_test() {
  dur_compact(3600) |> should.equal(Ok("1h"))
}

// 17.2
pub fn compact_one_minute_thirty_seconds_test() {
  dur_compact(90) |> should.equal(Ok("1m30s"))
}
