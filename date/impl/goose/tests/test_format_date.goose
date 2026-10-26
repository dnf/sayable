// sayable-date Goose implementation — canonical tests.
//
// Every test is annotated with its ID from date/config/tests.json. None
// of them depends on the system clock, so all are implemented. Null
// inputs are passed as "", and tests without a locale use English.

import sayabledate from "../sayabledate";
import std;
import os;

var passed = 0;
var failed = 0;

fn fail(id: const u8[:], detail: u8[:]) {
    failed += 1;
    write_stderr(str("FAIL ", id, ": ", detail, "\n"));
}

fn expect(id: const u8[:], got: u8[:], ok: bool, want: u8[:]) {
    if ok && got == want { passed += 1; return; }
    if ok { fail(id, str("got '", got, "', want '", want, "'")); }
    else { fail(id, str("got none, want '", want, "'")); }
}

fn expect_none(id: const u8[:], got: u8[:], ok: bool) {
    if !ok { passed += 1; return; }
    fail(id, str("got '", got, "', want none"));
}

fn locale_for(code: const u8[:]) -> sayabledate::DateLocale {
    let locale, found = sayabledate::get_locale(code);
    guard found else { abort(str("unknown locale in test: ", code)); }
    return locale;
}

fn check_date(id: const u8[:], code: const u8[:], compactness: sayabledate::Compactness, date: u8[:], want: u8[:]) {
    let locale = locale_for(code);
    let got, ok = sayabledate::format_date(locale, compactness, date);
    expect(id, got, ok, want);
}

fn check_no_date(id: const u8[:], code: const u8[:], compactness: sayabledate::Compactness, date: u8[:]) {
    let locale = locale_for(code);
    let got, ok = sayabledate::format_date(locale, compactness, date);
    expect_none(id, got, ok);
}

fn check_date_with_year(id: const u8[:], code: const u8[:], compactness: sayabledate::Compactness, date: u8[:], want: u8[:]) {
    let locale = locale_for(code);
    let got, ok = sayabledate::format_date_with_year(locale, compactness, date);
    expect(id, got, ok, want);
}

fn check_no_date_with_year(id: const u8[:], code: const u8[:], compactness: sayabledate::Compactness, date: u8[:]) {
    let locale = locale_for(code);
    let got, ok = sayabledate::format_date_with_year(locale, compactness, date);
    expect_none(id, got, ok);
}

fn check_relative(id: const u8[:], code: const u8[:], compactness: sayabledate::Compactness, date: u8[:], as_of: u8[:], want: u8[:]) {
    let locale = locale_for(code);
    let got, ok = sayabledate::format_relative(locale, compactness, date, as_of);
    expect(id, got, ok, want);
}

fn check_no_relative(id: const u8[:], code: const u8[:], compactness: sayabledate::Compactness, date: u8[:], as_of: u8[:]) {
    let locale = locale_for(code);
    let got, ok = sayabledate::format_relative(locale, compactness, date, as_of);
    expect_none(id, got, ok);
}

fn main() {
    // Not in tests.json: the version constant matches date/config/version.json.
    expect("version", sayabledate::VERSION, true, "0.5.0");

    // ---- 1. Null / edge cases ----
    // 1.1
    check_no_date("1.1", "en", sayabledate::Compactness.Normal, "");
    // 1.2
    check_no_date("1.2", "en", sayabledate::Compactness.Normal, "");
    // 1.3
    check_no_date("1.3", "en", sayabledate::Compactness.Normal, "invalid");
    // 1.4
    check_no_relative("1.4", "en", sayabledate::Compactness.Normal, "2025-03-15", "");
    // 1.5
    check_no_relative("1.5", "en", sayabledate::Compactness.Normal, "", "2025-03-15");

    // ---- 2. format_date — normal compactness (English) ----
    // 2.1
    check_date("2.1", "en", sayabledate::Compactness.Normal, "2025-03-15", "March 15th");
    // 2.2
    check_date("2.2", "en", sayabledate::Compactness.Normal, "2025-01-01", "January 1st");
    // 2.3
    check_date("2.3", "en", sayabledate::Compactness.Normal, "2025-05-22", "May 22nd");
    // 2.4
    check_date("2.4", "en", sayabledate::Compactness.Normal, "2025-07-03", "July 3rd");
    // 2.5
    check_date("2.5", "en", sayabledate::Compactness.Normal, "2025-12-31", "December 31st");
    // 2.6
    check_date("2.6", "en", sayabledate::Compactness.Normal, "2025-06-11", "June 11th");
    // 2.7
    check_date("2.7", "en", sayabledate::Compactness.Normal, "2025-03-15T14:30:00", "March 15th");

    // ---- 3. format_date — short compactness (English) ----
    // 3.1
    check_date("3.1", "en", sayabledate::Compactness.Short, "2025-03-15", "Mar 15");
    // 3.2
    check_date("3.2", "en", sayabledate::Compactness.Short, "2025-01-01", "Jan 1");
    // 3.3
    check_date("3.3", "en", sayabledate::Compactness.Short, "2025-12-25", "Dec 25");

    // ---- 4. format_date — compact (English) ----
    // 4.1
    check_date("4.1", "en", sayabledate::Compactness.Compact, "2025-03-15", "3/15");
    // 4.2
    check_date("4.2", "en", sayabledate::Compactness.Compact, "2025-01-01", "1/1");

    // ---- 5. format_relative — proximity tiers (English) ----
    // 5.1
    check_relative("5.1", "en", sayabledate::Compactness.Normal, "2025-03-15", "2025-03-15", "today");
    // 5.2
    check_relative("5.2", "en", sayabledate::Compactness.Normal, "2025-03-16", "2025-03-15", "tomorrow");
    // 5.3
    check_relative("5.3", "en", sayabledate::Compactness.Normal, "2025-03-14", "2025-03-15", "yesterday");
    // 5.4
    check_relative("5.4", "en", sayabledate::Compactness.Normal, "2025-03-17", "2025-03-15", "the day after tomorrow");
    // 5.5
    check_relative("5.5", "en", sayabledate::Compactness.Normal, "2025-03-13", "2025-03-15", "the day before yesterday");
    // 5.6
    check_relative("5.6", "en", sayabledate::Compactness.Normal, "2025-03-19", "2025-03-15", "this Wednesday");
    // 5.7
    check_relative("5.7", "en", sayabledate::Compactness.Normal, "2025-03-20", "2025-03-15", "this Thursday");
    // 5.8
    check_relative("5.8", "en", sayabledate::Compactness.Normal, "2025-03-11", "2025-03-15", "last Tuesday");
    // 5.9
    check_relative("5.9", "en", sayabledate::Compactness.Normal, "2025-03-22", "2025-03-15", "next Saturday");
    // 5.10
    check_relative("5.10", "en", sayabledate::Compactness.Normal, "2025-03-27", "2025-03-15", "next Thursday");
    // 5.11
    check_relative("5.11", "en", sayabledate::Compactness.Normal, "2025-03-01", "2025-03-15", "March 1st");
    // 5.12
    check_relative("5.12", "en", sayabledate::Compactness.Normal, "2025-04-10", "2025-03-15", "April 10th");
    // 5.13
    check_relative("5.13", "en", sayabledate::Compactness.Normal, "2026-01-05", "2025-03-15", "January 5th, 2026");
    // 5.14
    check_relative("5.14", "en", sayabledate::Compactness.Normal, "2024-12-25", "2025-03-15", "December 25th, 2024");

    // ---- 6. format_relative — compact skips weekday tiers ----
    // 6.1
    check_relative("6.1", "en", sayabledate::Compactness.Compact, "2025-03-15", "2025-03-15", "today");
    // 6.2
    check_relative("6.2", "en", sayabledate::Compactness.Compact, "2025-03-16", "2025-03-15", "tomorrow");
    // 6.3
    check_relative("6.3", "en", sayabledate::Compactness.Compact, "2025-03-19", "2025-03-15", "3/19");
    // 6.4
    check_relative("6.4", "en", sayabledate::Compactness.Compact, "2026-01-05", "2025-03-15", "1/5/26");

    // ---- 7. Locale — German ----
    // 7.1
    check_date("7.1", "de", sayabledate::Compactness.Normal, "2025-03-15", "15. März");
    // 7.2
    check_relative("7.2", "de", sayabledate::Compactness.Normal, "2025-03-16", "2025-03-15", "morgen");
    // 7.3
    check_relative("7.3", "de", sayabledate::Compactness.Normal, "2025-03-17", "2025-03-15", "übermorgen");
    // 7.4
    check_relative("7.4", "de", sayabledate::Compactness.Normal, "2025-03-19", "2025-03-15", "diesen Mittwoch");

    // ---- 8. Locale — French ----
    // 8.1
    check_date("8.1", "fr", sayabledate::Compactness.Normal, "2025-03-01", "1er mars");
    // 8.2
    check_date("8.2", "fr", sayabledate::Compactness.Normal, "2025-03-15", "15 mars");
    // 8.3
    check_relative("8.3", "fr", sayabledate::Compactness.Normal, "2025-03-16", "2025-03-15", "demain");

    // ---- 9. Locale — Japanese ----
    // 9.1
    check_date("9.1", "ja", sayabledate::Compactness.Normal, "2025-03-15", "3月15日");
    // 9.2
    check_relative("9.2", "ja", sayabledate::Compactness.Normal, "2025-03-16", "2025-03-15", "明日");
    // 9.3
    check_relative("9.3", "ja", sayabledate::Compactness.Normal, "2025-03-19", "2025-03-15", "今度の水曜日");

    // ---- 10. Locale — Russian (genitive months) ----
    // 10.1
    check_date("10.1", "ru", sayabledate::Compactness.Normal, "2025-03-15", "15 марта");
    // 10.2
    check_relative("10.2", "ru", sayabledate::Compactness.Normal, "2025-03-16", "2025-03-15", "завтра");

    // ---- 11. Locale — Arabic ----
    // 11.1
    check_date("11.1", "ar", sayabledate::Compactness.Normal, "2025-03-15", "15 مارس");
    // 11.2
    check_relative("11.2", "ar", sayabledate::Compactness.Normal, "2025-03-16", "2025-03-15", "غداً");

    // ---- 12. Locale — Spanish ----
    // 12.1
    check_date("12.1", "es", sayabledate::Compactness.Normal, "2025-03-15", "15 de marzo");
    // 12.2
    check_relative("12.2", "es", sayabledate::Compactness.Normal, "2025-03-17", "2025-03-15", "pasado mañana");

    // ---- 13. format_date_with_year ----
    // 13.1
    check_date_with_year("13.1", "en", sayabledate::Compactness.Normal, "2018-02-04", "February 4th, 2018");
    // 13.2
    check_date_with_year("13.2", "en", sayabledate::Compactness.Short, "2025-03-15", "Mar 15, 2025");
    // 13.3
    check_date_with_year("13.3", "en", sayabledate::Compactness.Compact, "1997-01-21", "1/21/97");
    // 13.4
    check_date_with_year("13.4", "tg", sayabledate::Compactness.Compact, "2007-05-20", "20/5/07");
    // 13.5
    check_date_with_year("13.5", "fi", sayabledate::Compactness.Short, "1996-06-21", "21. kesäkuuta 1996");

    // ---- 14. Short month names (locales that keep the full genitive) ----
    // 14.1
    check_date("14.1", "sk", sayabledate::Compactness.Short, "2031-02-15", "15. februára");
    // 14.2
    check_date("14.2", "cs", sayabledate::Compactness.Short, "2025-12-10", "10. prosince");
    // 14.3
    check_date("14.3", "uk", sayabledate::Compactness.Short, "2025-11-05", "5 листопада");
    // 14.4
    check_relative("14.4", "fi", sayabledate::Compactness.Short, "1998-08-08", "1998-08-15", "8. elokuuta");

    // ---- 15. format_relative — short phrases ----
    // 15.1
    check_relative("15.1", "kw", sayabledate::Compactness.Short, "2035-12-04", "2035-12-02", "an Mth ma");
    // 15.2
    check_relative("15.2", "mam", sayabledate::Compactness.Short, "2000-01-23", "2000-01-25", "Dom nchi'j");
    // 15.3
    check_relative("15.3", "kek", sayabledate::Compactness.Short, "2014-10-24", "2014-10-22", "a'in Vie");

    // ---- 16. Input validation ----
    // 16.1
    check_no_date("16.1", "en", sayabledate::Compactness.Normal, "2025-02-30");
    // 16.2
    check_no_date("16.2", "en", sayabledate::Compactness.Normal, "2025-13-01");
    // 16.3
    check_no_date("16.3", "en", sayabledate::Compactness.Normal, "2025-6-1");
    // 16.4
    check_no_date("16.4", "en", sayabledate::Compactness.Normal, " 2025-06-01");
    // 16.5
    check_date("16.5", "en", sayabledate::Compactness.Normal, "2025-06-01T10:00:00", "June 1st");
    // 16.6
    check_no_date_with_year("16.6", "en", sayabledate::Compactness.Normal, "2023-02-29");
    // 16.7
    check_no_relative("16.7", "en", sayabledate::Compactness.Normal, "2025-03-16", "2025-04-31");

    print(passed, " passed, ", failed, " failed");
    if failed > 0 { exit(1); }
}
