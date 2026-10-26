import gleeunit
import gleeunit/should
import sayabletime
import sayabletime/locales/de as locale_de
import sayabletime/locales/en as locale_en
import sayabletime/locales/fr as locale_fr
import sayabletime/locales/fi as locale_fi
import sayabletime/locales/ja as locale_ja
import sayabletime/types.{Compact, Normal, Short}

pub fn main() {
  gleeunit.main()
}

// Helpers

fn time(t: String) -> Result(String, Nil) {
  sayabletime.format_time(locale_en.locale(), Normal, t)
}

fn time_short(t: String) -> Result(String, Nil) {
  sayabletime.format_time(locale_en.locale(), Short, t)
}

fn time_compact(t: String) -> Result(String, Nil) {
  sayabletime.format_time(locale_en.locale(), Compact, t)
}

// 1. Null / edge cases

// 1.1
pub fn null_time_test() {
  sayabletime.format_time(locale_en.locale(), Normal, "")
  |> should.equal(Error(Nil))
}

// 1.2
pub fn empty_time_test() {
  sayabletime.format_time(locale_en.locale(), Normal, "")
  |> should.equal(Error(Nil))
}

// 1.3
pub fn invalid_time_test() {
  sayabletime.format_time(locale_en.locale(), Normal, "invalid")
  |> should.equal(Error(Nil))
}

// 1.4
pub fn out_of_range_time_test() {
  sayabletime.format_time(locale_en.locale(), Normal, "25:00")
  |> should.equal(Error(Nil))
}

// 2. Clock time (normal compactness)

// 2.1
pub fn midnight_test() {
  time("00:00") |> should.equal(Ok("midnight"))
}

// 2.2
pub fn noon_test() {
  time("12:00") |> should.equal(Ok("noon"))
}

// 2.3
pub fn three_oclock_test() {
  time("15:00") |> should.equal(Ok("three o'clock"))
}

// 2.4
pub fn quarter_past_two_test() {
  time("14:15") |> should.equal(Ok("a quarter past two"))
}

// 2.5
pub fn half_past_nine_test() {
  time("09:30") |> should.equal(Ok("half past nine"))
}

// 2.6
pub fn quarter_to_eleven_test() {
  time("10:45") |> should.equal(Ok("a quarter to eleven"))
}

// 2.7
pub fn five_past_eight_test() {
  time("08:05") |> should.equal(Ok("five past eight"))
}

// 2.8
pub fn five_to_five_test() {
  time("16:55") |> should.equal(Ok("five to five"))
}

// 2.9
pub fn rounds_to_midnight_test() {
  time("23:58") |> should.equal(Ok("midnight"))
}

// 2.10
pub fn twenty_past_seven_test() {
  time("07:22") |> should.equal(Ok("twenty past seven"))
}

// 2.11
pub fn iso_datetime_input_test() {
  time("2025-01-15T14:15:00") |> should.equal(Ok("a quarter past two"))
}

// 3. Clock time (short compactness)

// 3.1
pub fn short_2_15_pm_test() {
  time_short("14:15") |> should.equal(Ok("2:15 PM"))
}

// 3.2
pub fn short_9_30_am_test() {
  time_short("09:30") |> should.equal(Ok("9:30 AM"))
}

// 3.3
pub fn short_12_00_am_test() {
  time_short("00:00") |> should.equal(Ok("12:00 AM"))
}

// 3.4
pub fn short_12_00_pm_test() {
  time_short("12:00") |> should.equal(Ok("12:00 PM"))
}

// 4. Clock time (compact)

// 4.1
pub fn compact_2_15p_test() {
  time_compact("14:15") |> should.equal(Ok("2:15p"))
}

// 4.2
pub fn compact_9_30a_test() {
  time_compact("09:30") |> should.equal(Ok("9:30a"))
}

// 5. Locale -- German

// 5.1
pub fn german_half_past_three_test() {
  sayabletime.format_time(locale_de.locale(), Normal, "15:30")
  |> should.equal(Ok("halb vier"))
}

// 6. Locale -- French

// 6.1
pub fn french_quarter_past_three_test() {
  sayabletime.format_time(locale_fr.locale(), Normal, "15:15")
  |> should.equal(Ok("trois heures et quart"))
}

// 6.2
pub fn french_on_the_hour_test() {
  sayabletime.format_time(locale_fr.locale(), Normal, "13:00")
  |> should.equal(Ok("une heure"))
}

// 6.3
pub fn french_half_past_test() {
  sayabletime.format_time(locale_fr.locale(), Normal, "13:30")
  |> should.equal(Ok("une heure et demie"))
}

// 6.4
pub fn french_quarter_to_test() {
  sayabletime.format_time(locale_fr.locale(), Normal, "14:45")
  |> should.equal(Ok("trois heures moins le quart"))
}

// 6.5
pub fn french_ten_to_test() {
  sayabletime.format_time(locale_fr.locale(), Normal, "14:50")
  |> should.equal(Ok("trois heures moins dix"))
}

// 7. Locale -- Japanese

// 7.1
pub fn japanese_half_past_three_test() {
  sayabletime.format_time(locale_ja.locale(), Normal, "15:30")
  |> should.equal(Ok("三時半"))
}

// 8. Locale -- Finnish (dot separator, short)

// 8.1
pub fn finnish_dot_separator_test() {
  sayabletime.format_time(locale_fi.locale(), Short, "14:15")
  |> should.equal(Ok("14.15"))
}

// 8.2
pub fn finnish_midnight_dot_test() {
  sayabletime.format_time(locale_fi.locale(), Short, "00:00")
  |> should.equal(Ok("0.00"))
}

// 9. Minutes in short and compact modes

// 9.1
pub fn short_keeps_exact_minute_test() {
  time_short("18:01") |> should.equal(Ok("6:01 PM"))
}

// 9.2
pub fn compact_keeps_exact_minute_test() {
  time_compact("19:05") |> should.equal(Ok("7:05p"))
}

// 10. Input validation

// 10.1
pub fn one_digit_hour_test() {
  time("9:30") |> should.equal(Ok("half past nine"))
}

// 10.2
pub fn two_digit_hour_test() {
  time("09:30") |> should.equal(Ok("half past nine"))
}

// 10.3
pub fn leading_whitespace_test() {
  time(" 9:30") |> should.equal(Error(Nil))
}

// 10.4
pub fn trailing_whitespace_test() {
  time("9:30 ") |> should.equal(Error(Nil))
}

// 10.5
pub fn one_digit_minute_test() {
  time("9:5") |> should.equal(Error(Nil))
}

// 10.6
pub fn hour_out_of_range_test() {
  time("24:00") |> should.equal(Error(Nil))
}

// 10.7
pub fn seconds_ignored_test() {
  time("14:15:30") |> should.equal(Ok("a quarter past two"))
}

// 10.8
pub fn iso_datetime_with_zone_test() {
  time("2025-01-15T14:15:00Z") |> should.equal(Ok("a quarter past two"))
}

// 10.9
pub fn iso_datetime_impossible_date_test() {
  time("2025-02-30T14:15:00") |> should.equal(Error(Nil))
}
