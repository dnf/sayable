// sayable-time Goose implementation — canonical tests.
//
// Every test is annotated with its ID from time/config/tests.json. None
// need the system clock, so all of them are implemented. Null input is
// passed as "".

import sayabletime from "../sayabletime";
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

fn locale_for(code: const u8[:]) -> sayabletime::TimeLocale {
    let locale, found = sayabletime::get_locale(code);
    guard found else { abort(str("unknown locale in test: ", code)); }
    return locale;
}

fn check_time(id: const u8[:], code: const u8[:], compactness: sayabletime::Compactness, input: u8[:], want: u8[:]) {
    let locale = locale_for(code);
    let got, ok = sayabletime::format_time(locale, compactness, input);
    expect(id, got, ok, want);
}

fn check_no_time(id: const u8[:], input: u8[:]) {
    let locale = locale_for("en");
    let got, ok = sayabletime::format_time(locale, sayabletime::Compactness.Normal, input);
    expect_none(id, got, ok);
}

fn check_spoken(id: const u8[:], input: u8[:], want: u8[:]) {
    check_time(id, "en", sayabletime::Compactness.Normal, input, want);
}

fn main() {
    // Not in tests.json: the version constant matches time/config/version.json.
    expect("version", sayabletime::VERSION, true, "0.5.0");

    // Not in tests.json: locale lookup is exact.
    let en, found_en = sayabletime::get_locale("en");
    expect("lookup", en.code, found_en, "en");
    let unknown, found_unknown = sayabletime::get_locale("xx");
    expect_none("lookup-unknown", unknown.code, found_unknown);

    // ---- Section 1: Null / edge cases ----

    // 1.1
    check_no_time("1.1", "");
    // 1.2
    check_no_time("1.2", "");
    // 1.3
    check_no_time("1.3", "invalid");
    // 1.4
    check_no_time("1.4", "25:00");

    // ---- Section 2: Clock time (normal compactness) ----

    // 2.1
    check_spoken("2.1", "00:00", "midnight");
    // 2.2
    check_spoken("2.2", "12:00", "noon");
    // 2.3
    check_spoken("2.3", "15:00", "three o'clock");
    // 2.4
    check_spoken("2.4", "14:15", "a quarter past two");
    // 2.5
    check_spoken("2.5", "09:30", "half past nine");
    // 2.6
    check_spoken("2.6", "10:45", "a quarter to eleven");
    // 2.7
    check_spoken("2.7", "08:05", "five past eight");
    // 2.8
    check_spoken("2.8", "16:55", "five to five");
    // 2.9 — rounds to 0:00 of the next day
    check_spoken("2.9", "23:58", "midnight");
    // 2.10 — 22 rounds to 20
    check_spoken("2.10", "07:22", "twenty past seven");
    // 2.11 — ISO datetime input
    check_spoken("2.11", "2025-01-15T14:15:00", "a quarter past two");

    // ---- Section 3: Clock time (short compactness) ----

    let short = sayabletime::Compactness.Short;
    // 3.1
    check_time("3.1", "en", short, "14:15", "2:15 PM");
    // 3.2
    check_time("3.2", "en", short, "09:30", "9:30 AM");
    // 3.3
    check_time("3.3", "en", short, "00:00", "12:00 AM");
    // 3.4
    check_time("3.4", "en", short, "12:00", "12:00 PM");

    // ---- Section 4: Clock time (compact) ----

    let compact = sayabletime::Compactness.Compact;
    // 4.1
    check_time("4.1", "en", compact, "14:15", "2:15p");
    // 4.2
    check_time("4.2", "en", compact, "09:30", "9:30a");

    // ---- Sections 5-7: Locales ----

    let normal = sayabletime::Compactness.Normal;
    // 5.1 — German half-to pattern
    check_time("5.1", "de", normal, "15:30", "halb vier");
    // 6.1
    check_time("6.1", "fr", normal, "15:15", "trois heures et quart");
    // 7.1
    check_time("7.1", "ja", normal, "15:30", "三時半");

    // ---- Section 8: Finnish (dot separator, short) ----

    // 8.1 — dot separator per CLDR Finnish time format
    check_time("8.1", "fi", short, "14:15", "14.15");
    // 8.2 — midnight in 24h dot format
    check_time("8.2", "fi", short, "00:00", "0.00");

    print(passed, " passed, ", failed, " failed");
    if failed > 0 { exit(1); }
}
