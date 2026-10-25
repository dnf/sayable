import gleeunit
import gleeunit/should
import sayabledate
import sayabledate/locales/ar as locale_ar
import sayabledate/locales/de as locale_de
import sayabledate/locales/en as locale_en
import sayabledate/locales/es as locale_es
import sayabledate/locales/fr as locale_fr
import sayabledate/locales/ja as locale_ja
import sayabledate/locales/cs as locale_cs
import sayabledate/locales/fi as locale_fi
import sayabledate/locales/kek as locale_kek
import sayabledate/locales/kw as locale_kw
import sayabledate/locales/mam as locale_mam
import sayabledate/locales/ru as locale_ru
import sayabledate/locales/sk as locale_sk
import sayabledate/locales/tg as locale_tg
import sayabledate/locales/uk as locale_uk
import sayabledate/types.{Compact, Normal, Short}

pub fn main() {
  gleeunit.main()
}

// Helpers

fn date(d: String) -> Result(String, Nil) {
  sayabledate.format_date(locale_en.locale(), Normal, d)
}

fn date_short(d: String) -> Result(String, Nil) {
  sayabledate.format_date(locale_en.locale(), Short, d)
}

fn date_compact(d: String) -> Result(String, Nil) {
  sayabledate.format_date(locale_en.locale(), Compact, d)
}

fn relative(d: String, as_of: String) -> Result(String, Nil) {
  sayabledate.format_relative(locale_en.locale(), Normal, d, as_of)
}

fn relative_compact(d: String, as_of: String) -> Result(String, Nil) {
  sayabledate.format_relative(locale_en.locale(), Compact, d, as_of)
}

// 1. Null / edge cases

// 1.1
pub fn null_date_test() {
  sayabledate.format_date(locale_en.locale(), Normal, "")
  |> should.equal(Error(Nil))
}

// 1.2
pub fn empty_date_test() {
  sayabledate.format_date(locale_en.locale(), Normal, "")
  |> should.equal(Error(Nil))
}

// 1.3
pub fn invalid_date_test() {
  sayabledate.format_date(locale_en.locale(), Normal, "invalid")
  |> should.equal(Error(Nil))
}

// 1.4
pub fn null_as_of_test() {
  sayabledate.format_relative(locale_en.locale(), Normal, "2025-03-15", "")
  |> should.equal(Error(Nil))
}

// 1.5
pub fn null_date_relative_test() {
  sayabledate.format_relative(locale_en.locale(), Normal, "", "2025-03-15")
  |> should.equal(Error(Nil))
}

// 2. format_date -- normal compactness (English)

// 2.1
pub fn format_date_march_15_test() {
  date("2025-03-15") |> should.equal(Ok("March 15th"))
}

// 2.2
pub fn format_date_jan_1_test() {
  date("2025-01-01") |> should.equal(Ok("January 1st"))
}

// 2.3
pub fn format_date_may_22_test() {
  date("2025-05-22") |> should.equal(Ok("May 22nd"))
}

// 2.4
pub fn format_date_jul_3_test() {
  date("2025-07-03") |> should.equal(Ok("July 3rd"))
}

// 2.5
pub fn format_date_dec_31_test() {
  date("2025-12-31") |> should.equal(Ok("December 31st"))
}

// 2.6
pub fn format_date_jun_11_test() {
  date("2025-06-11") |> should.equal(Ok("June 11th"))
}

// 2.7
pub fn format_date_iso_datetime_test() {
  date("2025-03-15T14:30:00") |> should.equal(Ok("March 15th"))
}

// 3. format_date -- short compactness (English)

// 3.1
pub fn short_march_15_test() {
  date_short("2025-03-15") |> should.equal(Ok("Mar 15"))
}

// 3.2
pub fn short_jan_1_test() {
  date_short("2025-01-01") |> should.equal(Ok("Jan 1"))
}

// 3.3
pub fn short_dec_25_test() {
  date_short("2025-12-25") |> should.equal(Ok("Dec 25"))
}

// 4. format_date -- compact (English)

// 4.1
pub fn compact_march_15_test() {
  date_compact("2025-03-15") |> should.equal(Ok("3/15"))
}

// 4.2
pub fn compact_jan_1_test() {
  date_compact("2025-01-01") |> should.equal(Ok("1/1"))
}

// 5. format_relative -- proximity tiers (English)

// 5.1
pub fn relative_today_test() {
  relative("2025-03-15", "2025-03-15") |> should.equal(Ok("today"))
}

// 5.2
pub fn relative_tomorrow_test() {
  relative("2025-03-16", "2025-03-15") |> should.equal(Ok("tomorrow"))
}

// 5.3
pub fn relative_yesterday_test() {
  relative("2025-03-14", "2025-03-15") |> should.equal(Ok("yesterday"))
}

// 5.4
pub fn relative_day_after_tomorrow_test() {
  relative("2025-03-17", "2025-03-15")
  |> should.equal(Ok("the day after tomorrow"))
}

// 5.5
pub fn relative_day_before_yesterday_test() {
  relative("2025-03-13", "2025-03-15")
  |> should.equal(Ok("the day before yesterday"))
}

// 5.6
pub fn relative_this_wednesday_test() {
  relative("2025-03-19", "2025-03-15")
  |> should.equal(Ok("this Wednesday"))
}

// 5.7
pub fn relative_this_thursday_test() {
  relative("2025-03-20", "2025-03-15")
  |> should.equal(Ok("this Thursday"))
}

// 5.8
pub fn relative_last_tuesday_test() {
  relative("2025-03-11", "2025-03-15")
  |> should.equal(Ok("last Tuesday"))
}

// 5.9
pub fn relative_next_saturday_test() {
  relative("2025-03-22", "2025-03-15")
  |> should.equal(Ok("next Saturday"))
}

// 5.10
pub fn relative_next_thursday_test() {
  relative("2025-03-27", "2025-03-15")
  |> should.equal(Ok("next Thursday"))
}

// 5.11
pub fn relative_calendar_fallback_same_year_test() {
  relative("2025-03-01", "2025-03-15")
  |> should.equal(Ok("March 1st"))
}

// 5.12
pub fn relative_calendar_fallback_future_test() {
  relative("2025-04-10", "2025-03-15")
  |> should.equal(Ok("April 10th"))
}

// 5.13
pub fn relative_different_year_future_test() {
  relative("2026-01-05", "2025-03-15")
  |> should.equal(Ok("January 5th, 2026"))
}

// 5.14
pub fn relative_different_year_past_test() {
  relative("2024-12-25", "2025-03-15")
  |> should.equal(Ok("December 25th, 2024"))
}

// 6. format_relative -- compact skips weekday tiers

// 6.1
pub fn compact_relative_today_test() {
  relative_compact("2025-03-15", "2025-03-15")
  |> should.equal(Ok("today"))
}

// 6.2
pub fn compact_relative_tomorrow_test() {
  relative_compact("2025-03-16", "2025-03-15")
  |> should.equal(Ok("tomorrow"))
}

// 6.3
pub fn compact_relative_numeric_test() {
  relative_compact("2025-03-19", "2025-03-15")
  |> should.equal(Ok("3/19"))
}

// 6.4
pub fn compact_relative_different_year_test() {
  relative_compact("2026-01-05", "2025-03-15")
  |> should.equal(Ok("1/5/26"))
}

// 7. Locale -- German

// 7.1
pub fn german_format_date_test() {
  sayabledate.format_date(locale_de.locale(), Normal, "2025-03-15")
  |> should.equal(Ok("15. März"))
}

// 7.2
pub fn german_relative_tomorrow_test() {
  sayabledate.format_relative(locale_de.locale(), Normal, "2025-03-16", "2025-03-15")
  |> should.equal(Ok("morgen"))
}

// 7.3
pub fn german_relative_day_after_tomorrow_test() {
  sayabledate.format_relative(locale_de.locale(), Normal, "2025-03-17", "2025-03-15")
  |> should.equal(Ok("übermorgen"))
}

// 7.4
pub fn german_relative_this_weekday_test() {
  sayabledate.format_relative(locale_de.locale(), Normal, "2025-03-19", "2025-03-15")
  |> should.equal(Ok("diesen Mittwoch"))
}

// 8. Locale -- French

// 8.1
pub fn french_format_date_1er_test() {
  sayabledate.format_date(locale_fr.locale(), Normal, "2025-03-01")
  |> should.equal(Ok("1er mars"))
}

// 8.2
pub fn french_format_date_15_test() {
  sayabledate.format_date(locale_fr.locale(), Normal, "2025-03-15")
  |> should.equal(Ok("15 mars"))
}

// 8.3
pub fn french_relative_tomorrow_test() {
  sayabledate.format_relative(locale_fr.locale(), Normal, "2025-03-16", "2025-03-15")
  |> should.equal(Ok("demain"))
}

// 9. Locale -- Japanese

// 9.1
pub fn japanese_format_date_test() {
  sayabledate.format_date(locale_ja.locale(), Normal, "2025-03-15")
  |> should.equal(Ok("3月15日"))
}

// 9.2
pub fn japanese_relative_tomorrow_test() {
  sayabledate.format_relative(locale_ja.locale(), Normal, "2025-03-16", "2025-03-15")
  |> should.equal(Ok("明日"))
}

// 9.3
pub fn japanese_relative_this_weekday_test() {
  sayabledate.format_relative(locale_ja.locale(), Normal, "2025-03-19", "2025-03-15")
  |> should.equal(Ok("今度の水曜日"))
}

// 10. Locale -- Russian (genitive months)

// 10.1
pub fn russian_format_date_genitive_test() {
  sayabledate.format_date(locale_ru.locale(), Normal, "2025-03-15")
  |> should.equal(Ok("15 марта"))
}

// 10.2
pub fn russian_relative_tomorrow_test() {
  sayabledate.format_relative(locale_ru.locale(), Normal, "2025-03-16", "2025-03-15")
  |> should.equal(Ok("завтра"))
}

// 11. Locale -- Arabic

// 11.1
pub fn arabic_format_date_test() {
  sayabledate.format_date(locale_ar.locale(), Normal, "2025-03-15")
  |> should.equal(Ok("15 مارس"))
}

// 11.2
pub fn arabic_relative_tomorrow_test() {
  sayabledate.format_relative(locale_ar.locale(), Normal, "2025-03-16", "2025-03-15")
  |> should.equal(Ok("غداً"))
}

// 12. Locale -- Spanish

// 12.1
pub fn spanish_format_date_test() {
  sayabledate.format_date(locale_es.locale(), Normal, "2025-03-15")
  |> should.equal(Ok("15 de marzo"))
}

// 12.2
pub fn spanish_relative_day_after_tomorrow_test() {
  sayabledate.format_relative(locale_es.locale(), Normal, "2025-03-17", "2025-03-15")
  |> should.equal(Ok("pasado mañana"))
}

// 13. format_date_with_year

// 13.1
pub fn with_year_normal_test() {
  sayabledate.format_date_with_year(locale_en.locale(), Normal, "2018-02-04")
  |> should.equal(Ok("February 4th, 2018"))
}

// 13.2
pub fn with_year_short_test() {
  sayabledate.format_date_with_year(locale_en.locale(), Short, "2025-03-15")
  |> should.equal(Ok("Mar 15, 2025"))
}

// 13.3
pub fn with_year_compact_test() {
  sayabledate.format_date_with_year(locale_en.locale(), Compact, "1997-01-21")
  |> should.equal(Ok("1/21/97"))
}

// 13.4
pub fn with_year_compact_two_digit_year_padded_test() {
  sayabledate.format_date_with_year(locale_tg.locale(), Compact, "2007-05-20")
  |> should.equal(Ok("20/5/07"))
}

// 13.5
pub fn with_year_finnish_short_test() {
  sayabledate.format_date_with_year(locale_fi.locale(), Short, "1996-06-21")
  |> should.equal(Ok("21. kesäkuuta 1996"))
}

// 14. Short month names (locales that keep the full genitive)

// 14.1
pub fn slovak_short_month_test() {
  sayabledate.format_date(locale_sk.locale(), Short, "2031-02-15")
  |> should.equal(Ok("15. februára"))
}

// 14.2
pub fn czech_short_month_test() {
  sayabledate.format_date(locale_cs.locale(), Short, "2025-12-10")
  |> should.equal(Ok("10. prosince"))
}

// 14.3
pub fn ukrainian_short_month_test() {
  sayabledate.format_date(locale_uk.locale(), Short, "2025-11-05")
  |> should.equal(Ok("5 листопада"))
}

// 14.4
pub fn finnish_short_relative_month_test() {
  sayabledate.format_relative(locale_fi.locale(), Short, "1998-08-08", "1998-08-15")
  |> should.equal(Ok("8. elokuuta"))
}

// 15. format_relative -- short phrases

// 15.1
pub fn cornish_short_day_after_tomorrow_test() {
  sayabledate.format_relative(locale_kw.locale(), Short, "2035-12-04", "2035-12-02")
  |> should.equal(Ok("an Mth ma"))
}

// 15.2
pub fn mam_short_day_before_yesterday_test() {
  sayabledate.format_relative(locale_mam.locale(), Short, "2000-01-23", "2000-01-25")
  |> should.equal(Ok("Dom nchi'j"))
}

// 15.3
pub fn qeqchi_short_day_after_tomorrow_test() {
  sayabledate.format_relative(locale_kek.locale(), Short, "2014-10-24", "2014-10-22")
  |> should.equal(Ok("a'in Vie"))
}

// 16. Input validation

// 16.1
pub fn invalid_february_30_test() {
  date("2025-02-30") |> should.equal(Error(Nil))
}

// 16.2
pub fn invalid_month_13_test() {
  date("2025-13-01") |> should.equal(Error(Nil))
}

// 16.3
pub fn invalid_unpadded_test() {
  date("2025-6-1") |> should.equal(Error(Nil))
}

// 16.4
pub fn invalid_surrounding_whitespace_test() {
  date(" 2025-06-01") |> should.equal(Error(Nil))
}

// 16.5
pub fn iso_datetime_uses_date_part_test() {
  date("2025-06-01T10:00:00") |> should.equal(Ok("June 1st"))
}

// 16.6
pub fn invalid_february_29_non_leap_with_year_test() {
  sayabledate.format_date_with_year(locale_en.locale(), Normal, "2023-02-29")
  |> should.equal(Error(Nil))
}

// 16.7
pub fn invalid_as_of_relative_test() {
  relative("2025-03-16", "2025-04-31") |> should.equal(Error(Nil))
}
