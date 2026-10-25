// sayable-duration Goose implementation — canonical tests.
//
// Every test is annotated with its ID from duration/config/tests.json;
// all of them are implemented. Goose has no null, so null strings are
// passed as "" and the null seconds of 1.1 as a negative count (as the
// Zig port does).

import sayableduration from "../sayableduration";
import std;
import os;

let NORMAL = sayableduration::Compactness.Normal;
let SHORT = sayableduration::Compactness.Short;
let COMPACT = sayableduration::Compactness.Compact;

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

fn locale_for(code: const u8[:]) -> sayableduration::Locale {
    let locale, found = sayableduration::get_locale(code);
    guard found else { abort(str("unknown locale in test: ", code)); }
    return locale;
}

fn check_seconds(id: const u8[:], code: const u8[:], compactness: sayableduration::Compactness, seconds: i64, want: u8[:]) {
    let locale = locale_for(code);
    let got, ok = sayableduration::format_duration(locale, compactness, seconds);
    expect(id, got, ok, want);
}

fn check_no_seconds(id: const u8[:], code: const u8[:], compactness: sayableduration::Compactness, seconds: i64) {
    let locale = locale_for(code);
    let got, ok = sayableduration::format_duration(locale, compactness, seconds);
    expect_none(id, got, ok);
}

fn check_iso(id: const u8[:], code: const u8[:], compactness: sayableduration::Compactness, start: u8[:], end: u8[:], want: u8[:]) {
    let locale = locale_for(code);
    let got, ok = sayableduration::format_duration_iso(locale, compactness, start, end);
    expect(id, got, ok, want);
}

fn check_no_iso(id: const u8[:], code: const u8[:], compactness: sayableduration::Compactness, start: u8[:], end: u8[:]) {
    let locale = locale_for(code);
    let got, ok = sayableduration::format_duration_iso(locale, compactness, start, end);
    expect_none(id, got, ok);
}

fn check_since(id: const u8[:], code: const u8[:], compactness: sayableduration::Compactness, start: u8[:], as_of: u8[:], want: u8[:]) {
    let locale = locale_for(code);
    let got, ok = sayableduration::format_since(locale, compactness, start, as_of);
    expect(id, got, ok, want);
}

fn check_no_since(id: const u8[:], code: const u8[:], compactness: sayableduration::Compactness, start: u8[:], as_of: u8[:]) {
    let locale = locale_for(code);
    let got, ok = sayableduration::format_since(locale, compactness, start, as_of);
    expect_none(id, got, ok);
}

fn check_until(id: const u8[:], code: const u8[:], compactness: sayableduration::Compactness, target: u8[:], as_of: u8[:], want: u8[:]) {
    let locale = locale_for(code);
    let got, ok = sayableduration::format_until(locale, compactness, target, as_of);
    expect(id, got, ok, want);
}

fn check_no_until(id: const u8[:], code: const u8[:], compactness: sayableduration::Compactness, target: u8[:], as_of: u8[:]) {
    let locale = locale_for(code);
    let got, ok = sayableduration::format_until(locale, compactness, target, as_of);
    expect_none(id, got, ok);
}

fn main() {
    // Not in tests.json: the version constant matches duration/config/version.json.
    expect("version", sayableduration::VERSION, true, "0.5.0");

    // ---- 1. Null / edge cases ----
    // 1.1
    check_no_seconds("1.1", "en", NORMAL, -999);
    // 1.2
    check_no_seconds("1.2", "en", NORMAL, -1);
    // 1.3
    check_no_since("1.3", "en", NORMAL, "", "2025-01-15T10:00:00");
    // 1.4
    check_no_until("1.4", "en", NORMAL, "", "2025-01-15T10:00:00");
    // 1.5
    check_no_since("1.5", "en", NORMAL, "2025-01-15T10:00:00", "2025-01-15T09:00:00");
    // 1.6
    check_no_until("1.6", "en", NORMAL, "2025-01-15T09:00:00", "2025-01-15T10:00:00");

    // ---- 2. Duration — seconds tier (0-59s) ----
    // 2.1
    check_seconds("2.1", "en", NORMAL, 0, "just now");
    // 2.2
    check_seconds("2.2", "en", NORMAL, 1, "1 second");
    // 2.3
    check_seconds("2.3", "en", NORMAL, 45, "45 seconds");
    // 2.4
    check_seconds("2.4", "en", NORMAL, 59, "59 seconds");

    // ---- 3. Duration — minutes + seconds tier (1-4 min) ----
    // 3.1
    check_seconds("3.1", "en", NORMAL, 60, "1 minute");
    // 3.2
    check_seconds("3.2", "en", NORMAL, 90, "1 minute, 30 seconds");
    // 3.3
    check_seconds("3.3", "en", NORMAL, 240, "4 minutes");
    // 3.4
    check_seconds("3.4", "en", NORMAL, 270, "4 minutes, 30 seconds");

    // ---- 4. Duration — minutes tier (5-59 min) ----
    // 4.1
    check_seconds("4.1", "en", NORMAL, 300, "5 minutes");
    // 4.2
    check_seconds("4.2", "en", NORMAL, 1500, "25 minutes");
    // 4.3
    check_seconds("4.3", "en", NORMAL, 3540, "59 minutes");

    // ---- 5. Duration — hours + minutes tier (1-5 hr) ----
    // 5.1
    check_seconds("5.1", "en", NORMAL, 3600, "1 hour");
    // 5.2
    check_seconds("5.2", "en", NORMAL, 5400, "1½ hours");
    // 5.3
    check_seconds("5.3", "en", NORMAL, 8100, "2 hours, 15 minutes");
    // 5.4
    check_seconds("5.4", "en", NORMAL, 18000, "5 hours");

    // ---- 6. Duration — hours tier (6-23 hr) ----
    // 6.1
    check_seconds("6.1", "en", NORMAL, 28800, "8 hours");
    // 6.2
    check_seconds("6.2", "en", NORMAL, 82800, "23 hours");

    // ---- 7. Duration — days tier ----
    // 7.1
    check_seconds("7.1", "en", NORMAL, 86400, "1 day");
    // 7.2
    check_seconds("7.2", "en", NORMAL, 97200, "1 day, 3 hours");
    // 7.3
    check_seconds("7.3", "en", NORMAL, 129600, "1½ days");
    // 7.4
    check_seconds("7.4", "en", NORMAL, 432000, "5 days");
    // 7.5
    check_seconds("7.5", "en", NORMAL, 172800, "2 days");

    // ---- 8. Duration — weeks tier ----
    // 8.1
    check_seconds("8.1", "en", NORMAL, 604800, "1 week");
    // 8.2
    check_seconds("8.2", "en", NORMAL, 1296000, "2 weeks, 1 day");
    // 8.3
    check_seconds("8.3", "en", NORMAL, 2419200, "4 weeks");

    // ---- 9. Duration — months and years tier ----
    // 9.1
    check_seconds("9.1", "en", NORMAL, 2678400, "1 month");
    // 9.2
    check_seconds("9.2", "en", NORMAL, 7884000, "3 months");
    // 9.3
    check_seconds("9.3", "en", NORMAL, 31536000, "1 year");
    // 9.4
    check_seconds("9.4", "en", NORMAL, 39420000, "1 year, 3 months");

    // ---- 10. Duration from ISO timestamps ----
    // 10.1
    check_iso("10.1", "en", NORMAL, "2025-01-15T10:00:00", "2025-01-15T11:30:00", "1½ hours");
    // 10.2
    check_iso("10.2", "en", NORMAL, "2025-01-15T10:00:00", "2025-01-15T10:45:00", "45 minutes");

    // ---- 11. Relative time — since ----
    // 11.1
    check_since("11.1", "en", NORMAL, "2025-01-15T10:00:00", "2025-01-15T10:00:00", "just now");
    // 11.2
    check_since("11.2", "en", NORMAL, "2025-01-15T10:00:00", "2025-01-15T10:00:30", "30 seconds ago");
    // 11.3
    check_since("11.3", "en", NORMAL, "2025-01-15T10:00:00", "2025-01-15T10:45:00", "45 minutes ago");
    // 11.4
    check_since("11.4", "en", NORMAL, "2025-01-15T10:00:00", "2025-01-15T13:00:00", "3 hours ago");

    // ---- 12. Relative time — until ----
    // 12.1
    check_until("12.1", "en", NORMAL, "2025-01-15T10:00:00", "2025-01-15T10:00:00", "just now");
    // 12.2
    check_until("12.2", "en", NORMAL, "2025-01-15T10:20:00", "2025-01-15T10:00:00", "in 20 minutes");
    // 12.3
    check_until("12.3", "en", NORMAL, "2025-01-15T13:00:00", "2025-01-15T10:00:00", "in 3 hours");

    // ---- 13. Locale — German ----
    // 13.1
    check_seconds("13.1", "de", NORMAL, 3600, "1 Stunde");
    // 13.2
    check_since("13.2", "de", NORMAL, "2025-01-15T10:00:00", "2025-01-15T10:05:00", "vor 5 Minuten");

    // ---- 14. Locale — French ----
    // 14.1
    check_seconds("14.1", "fr", NORMAL, 7200, "2 heures");

    // ---- 15. Locale — Japanese ----
    // 15.1
    check_seconds("15.1", "ja", NORMAL, 120, "2分");
    // 15.2
    check_since("15.2", "ja", NORMAL, "2025-01-15T10:00:00", "2025-01-15T11:00:00", "1時間前");

    // ---- 16. Short compactness — duration ----
    // 16.1
    check_seconds("16.1", "en", SHORT, 3600, "1h");
    // 16.2
    check_seconds("16.2", "en", SHORT, 90, "1m, 30s");

    // ---- 17. Compact compactness — duration ----
    // 17.1
    check_seconds("17.1", "en", COMPACT, 3600, "1h");
    // 17.2
    check_seconds("17.2", "en", COMPACT, 90, "1m30s");

    // ---- 18. Short compactness — relative time ----
    // 18.1
    check_since("18.1", "men", SHORT, "2025-01-20T01:32:11", "2025-01-22T15:39:16", "lɔhɔnga 2, awa 14 taa gbɔyɔ");

    // ---- 19. Range (500-year ceiling) ----
    // 19.1
    check_seconds("19.1", "en", NORMAL, 15778800000, "500 years");
    // 19.2
    check_no_seconds("19.2", "en", NORMAL, 15800000000);
    // 19.3
    check_no_seconds("19.3", "en", NORMAL, 99999999999);
    // 19.4
    check_no_since("19.4", "en", NORMAL, "1500-01-01T00:00:00", "2025-01-01T00:00:00");
    // 19.5
    check_no_until("19.5", "en", NORMAL, "2600-01-01T00:00:00", "2025-01-01T00:00:00");

    // ---- 20. Timestamp validation ----
    // 20.1
    check_iso("20.1", "en", NORMAL, "2025-01-15T10:00", "2025-01-15T11:30:00", "1½ hours");
    // 20.2
    check_no_iso("20.2", "en", NORMAL, "2025-01-15T10", "2025-01-15T11:30:00");
    // 20.3
    check_no_iso("20.3", "en", NORMAL, "2025-1-5T10:00:00", "2025-01-15T11:30:00");
    // 20.4
    check_no_iso("20.4", "en", NORMAL, "2025-02-30T10:00:00", "2025-03-15T11:30:00");
    // 20.5
    check_no_since("20.5", "en", NORMAL, "2025-01-15T10:00:00", "2025-01-15T25:00:00");

    print(passed, " passed, ", failed, " failed");
    if failed > 0 { exit(1); }
}
