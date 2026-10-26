// sayable-age Goose implementation — canonical tests.
//
// Every test is annotated with its ID from age/config/tests.json. The
// default-asOf tests (15.1, 15.2, 23.1-23.3) are skipped: like the other
// compiled implementations, the API always takes an explicit asOf. Null
// and undefined inputs are passed as "".

import sayableage from "../sayableage";
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

fn locale_for(code: const u8[:]) -> sayableage::Locale {
    let locale, found = sayableage::get_locale(code);
    guard found else { abort(str("unknown locale in test: ", code)); }
    return locale;
}

fn check_age(id: const u8[:], code: const u8[:], compactness: sayableage::Compactness, dob: u8[:], as_of: u8[:], want: u8[:]) {
    let locale = locale_for(code);
    let got, ok = sayableage::format_age(locale, compactness, dob, as_of);
    expect(id, got, ok, want);
}

fn check_age_contains(id: const u8[:], code: const u8[:], compactness: sayableage::Compactness, dob: u8[:], as_of: u8[:], fragment: u8[:]) {
    let locale = locale_for(code);
    let got, ok = sayableage::format_age(locale, compactness, dob, as_of);
    if ok && find(got, fragment) >= 0 { passed += 1; return; }
    fail(id, str("got '", got, "', want text containing '", fragment, "'"));
}

fn check_no_age(id: const u8[:], code: const u8[:], compactness: sayableage::Compactness, dob: u8[:], as_of: u8[:]) {
    let locale = locale_for(code);
    let got, ok = sayableage::format_age(locale, compactness, dob, as_of);
    expect_none(id, got, ok);
}

fn check_stage(id: const u8[:], code: const u8[:], dob: u8[:], as_of: u8[:], gender: u8[:], want: u8[:]) {
    let locale = locale_for(code);
    let got, ok = sayableage::format_stage(locale, dob, as_of, gender);
    expect(id, got, ok, want);
}

fn check_no_stage(id: const u8[:], code: const u8[:], dob: u8[:], as_of: u8[:], gender: u8[:]) {
    let locale = locale_for(code);
    let got, ok = sayableage::format_stage(locale, dob, as_of, gender);
    expect_none(id, got, ok);
}

fn check_locale(id: const u8[:], code: u8[:], want_code: u8[:]) {
    let locale, found = sayableage::get_locale(code);
    expect(id, locale.code, found, want_code);
}

fn check_no_locale(id: const u8[:], code: u8[:]) {
    let locale, found = sayableage::get_locale(code);
    expect_none(id, locale.code, found);
}

fn main() {
    // Not in tests.json: the version constant matches age/config/version.json.
    expect("version", sayableage::VERSION, true, "0.5.0");

    // ---- 1. Null / edge cases ----
    // 1.1
    check_no_age("1.1", "en", sayableage::Compactness.Normal, "", "");
    // 1.2
    check_no_age("1.2", "en", sayableage::Compactness.Normal, "undefined", "");
    // 1.3
    check_no_age("1.3", "en", sayableage::Compactness.Normal, "", "");
    // 1.4
    check_no_age("1.4", "en", sayableage::Compactness.Normal, "2025-07-01", "2025-06-15");
    // 1.5
    check_age("1.5", "en", sayableage::Compactness.Normal, "1525-06-15", "2025-06-15", "500 years");
    // 1.6
    check_no_age("1.6", "en", sayableage::Compactness.Normal, "1524-06-15", "2025-06-15");
    // 1.7
    check_no_age("1.7", "en", sayableage::Compactness.Normal, "1025-06-15", "2025-06-15");

    // ---- 2. Days tier (0–6 days) ----
    // 2.1
    check_age("2.1", "en", sayableage::Compactness.Normal, "2025-06-15", "2025-06-15", "Newborn");
    // 2.2
    check_age("2.2", "en", sayableage::Compactness.Normal, "2025-06-14", "2025-06-15", "1 day");
    // 2.3
    check_age("2.3", "en", sayableage::Compactness.Normal, "2025-06-12", "2025-06-15", "3 days");
    // 2.4
    check_age("2.4", "en", sayableage::Compactness.Normal, "2025-06-09", "2025-06-15", "6 days");
    // 2.5
    check_age("2.5", "en", sayableage::Compactness.Normal, "2025-06-08", "2025-06-15", "1 week");

    // ---- 3. Weeks+days tier (7 days to <3 calendar months) ----
    // 3.1
    check_age("3.1", "en", sayableage::Compactness.Normal, "2025-06-08", "2025-06-15", "1 week");
    // 3.2
    check_age("3.2", "en", sayableage::Compactness.Normal, "2025-06-07", "2025-06-15", "1 week, 1 day");
    // 3.3
    check_age("3.3", "en", sayableage::Compactness.Normal, "2025-06-06", "2025-06-15", "1 week, 2 days");
    // 3.4
    check_age("3.4", "en", sayableage::Compactness.Normal, "2025-06-02", "2025-06-15", "1 week, 6 days");
    // 3.5
    check_age("3.5", "en", sayableage::Compactness.Normal, "2025-06-01", "2025-06-15", "2 weeks");
    // 3.6
    check_age("3.6", "en", sayableage::Compactness.Normal, "2025-05-31", "2025-06-15", "2 weeks, 1 day");
    // 3.7
    check_age("3.7", "en", sayableage::Compactness.Normal, "2025-05-26", "2025-06-15", "2 weeks, 6 days");
    // 3.8
    check_age("3.8", "en", sayableage::Compactness.Normal, "2025-05-25", "2025-06-15", "3 weeks");
    // 3.9
    check_age("3.9", "en", sayableage::Compactness.Normal, "2025-05-15", "2025-06-15", "4 weeks, 3 days");
    // 3.10
    check_age("3.10", "en", sayableage::Compactness.Normal, "2025-04-15", "2025-06-15", "8 weeks, 5 days");
    // 3.11
    check_age("3.11", "en", sayableage::Compactness.Normal, "2025-03-15", "2025-06-14", "13 weeks");
    // 3.12
    check_age("3.12", "en", sayableage::Compactness.Normal, "2025-03-15", "2025-06-15", "3 months");

    // ---- 4. Month boundaries — standard months ----
    // 4.1
    check_age("4.1", "en", sayableage::Compactness.Normal, "2025-01-01", "2025-04-01", "3 months");
    // 4.2
    check_age_contains("4.2", "en", sayableage::Compactness.Normal, "2025-01-01", "2025-03-31", "weeks");
    // 4.3
    check_age("4.3", "en", sayableage::Compactness.Normal, "2025-06-15", "2025-09-15", "3 months");
    // 4.4
    check_age_contains("4.4", "en", sayableage::Compactness.Normal, "2025-06-15", "2025-09-14", "weeks");
    // 4.5
    check_age("4.5", "en", sayableage::Compactness.Normal, "2025-06-15", "2025-12-15", "6 months");

    // ---- 5. Month boundaries — February non-leap year ----
    // 5.1
    check_age("5.1", "en", sayableage::Compactness.Normal, "2025-01-31", "2025-02-28", "4 weeks");
    // 5.2
    check_age("5.2", "en", sayableage::Compactness.Normal, "2025-01-31", "2025-04-30", "3 months");
    // 5.3
    check_age_contains("5.3", "en", sayableage::Compactness.Normal, "2025-01-31", "2025-04-29", "weeks");
    // 5.4
    check_age("5.4", "en", sayableage::Compactness.Normal, "2025-02-01", "2025-05-01", "3 months");
    // 5.5
    check_age_contains("5.5", "en", sayableage::Compactness.Normal, "2025-02-01", "2025-04-30", "weeks");

    // ---- 6. Month boundaries — February leap year ----
    // 6.1
    check_age("6.1", "en", sayableage::Compactness.Normal, "2024-01-31", "2024-02-29", "4 weeks, 1 day");
    // 6.2
    check_age("6.2", "en", sayableage::Compactness.Normal, "2024-01-31", "2024-02-28", "4 weeks");
    // 6.3
    check_age("6.3", "en", sayableage::Compactness.Normal, "2024-01-31", "2024-04-30", "3 months");
    // 6.4
    check_age_contains("6.4", "en", sayableage::Compactness.Normal, "2024-01-30", "2024-02-29", "weeks");
    // 6.5
    check_age_contains("6.5", "en", sayableage::Compactness.Normal, "2024-01-30", "2024-02-28", "weeks");

    // ---- 7. Month boundaries — 30-day months ----
    // 7.1
    check_age("7.1", "en", sayableage::Compactness.Normal, "2025-03-31", "2025-06-30", "3 months");
    // 7.2
    check_age_contains("7.2", "en", sayableage::Compactness.Normal, "2025-03-31", "2025-06-29", "weeks");
    // 7.3
    check_age("7.3", "en", sayableage::Compactness.Normal, "2025-08-31", "2025-11-30", "3 months");
    // 7.4
    check_age_contains("7.4", "en", sayableage::Compactness.Normal, "2025-08-31", "2025-11-29", "weeks");

    // ---- 8. Month boundaries — leap year baby (born Feb 29) ----
    // 8.1
    check_age("8.1", "en", sayableage::Compactness.Normal, "2024-02-29", "2024-05-29", "3 months");
    // 8.2
    check_age_contains("8.2", "en", sayableage::Compactness.Normal, "2024-02-29", "2024-05-28", "weeks");
    // 8.3
    check_age("8.3", "en", sayableage::Compactness.Normal, "2024-02-29", "2025-02-28", "12 months");
    // 8.4
    check_age("8.4", "en", sayableage::Compactness.Normal, "2024-02-29", "2025-03-01", "12 months");

    // ---- 9. Months tier (3–23 months) ----
    // 9.1
    check_age("9.1", "en", sayableage::Compactness.Normal, "2025-01-15", "2025-04-15", "3 months");
    // 9.2
    check_age("9.2", "en", sayableage::Compactness.Normal, "2025-01-15", "2025-07-15", "6 months");
    // 9.3
    check_age("9.3", "en", sayableage::Compactness.Normal, "2024-06-15", "2025-06-15", "12 months");
    // 9.4
    check_age("9.4", "en", sayableage::Compactness.Normal, "2024-01-15", "2025-12-15", "23 months");
    // 9.5
    check_age("9.5", "en", sayableage::Compactness.Normal, "2025-01-15", "2025-07-14", "5 months");
    // 9.6
    check_age("9.6", "en", sayableage::Compactness.Normal, "2024-11-10", "2025-04-10", "5 months");

    // ---- 10. Years+months tier (24–35 months) ----
    // 10.1
    check_age("10.1", "en", sayableage::Compactness.Normal, "2023-06-15", "2025-06-15", "2 years");
    // 10.2
    check_age("10.2", "en", sayableage::Compactness.Normal, "2023-06-15", "2025-07-15", "2 years, 1 month");
    // 10.3
    check_age("10.3", "en", sayableage::Compactness.Normal, "2023-06-15", "2025-12-15", "2 years, 6 months");
    // 10.4
    check_age("10.4", "en", sayableage::Compactness.Normal, "2023-06-15", "2026-05-15", "2 years, 11 months");
    // 10.5
    check_age("10.5", "en", sayableage::Compactness.Normal, "2023-06-15", "2025-06-14", "23 months");

    // ---- 11. Half-year tier (3–6 years) ----
    // 11.1
    check_age("11.1", "en", sayableage::Compactness.Normal, "2022-06-15", "2025-06-15", "3 years");
    // 11.2
    check_age("11.2", "en", sayableage::Compactness.Normal, "2022-06-15", "2025-11-15", "3 years");
    // 11.3
    check_age("11.3", "en", sayableage::Compactness.Normal, "2022-06-15", "2025-12-15", "3½ years");
    // 11.4
    check_age("11.4", "en", sayableage::Compactness.Normal, "2022-06-15", "2026-05-15", "3½ years");
    // 11.5
    check_age("11.5", "en", sayableage::Compactness.Normal, "2021-06-15", "2025-06-15", "4 years");
    // 11.6
    check_age("11.6", "en", sayableage::Compactness.Normal, "2021-06-15", "2025-12-15", "4½ years");
    // 11.7
    check_age("11.7", "en", sayableage::Compactness.Normal, "2020-06-15", "2025-06-15", "5 years");
    // 11.8
    check_age("11.8", "en", sayableage::Compactness.Normal, "2020-06-15", "2026-02-15", "5½ years");
    // 11.9
    check_age("11.9", "en", sayableage::Compactness.Normal, "2019-06-15", "2025-06-15", "6 years");
    // 11.10
    check_age("11.10", "en", sayableage::Compactness.Normal, "2019-06-15", "2025-12-15", "6½ years");
    // 11.11
    check_age("11.11", "en", sayableage::Compactness.Normal, "2019-06-15", "2026-05-15", "6½ years");
    // 11.12
    check_age("11.12", "en", sayableage::Compactness.Normal, "2022-06-15", "2025-06-14", "2 years, 11 months");

    // ---- 12. Integer tier (7+ years) ----
    // 12.1
    check_age("12.1", "en", sayableage::Compactness.Normal, "2018-06-15", "2025-06-15", "7 years");
    // 12.2
    check_age("12.2", "en", sayableage::Compactness.Normal, "2018-03-20", "2025-06-15", "7 years");
    // 12.3
    check_age("12.3", "en", sayableage::Compactness.Normal, "1980-01-01", "2025-06-15", "45 years");

    // ---- 13. Cross-year transitions with February ----
    // 13.1
    check_age("13.1", "en", sayableage::Compactness.Normal, "2024-12-31", "2025-03-31", "3 months");
    // 13.2
    check_age_contains("13.2", "en", sayableage::Compactness.Normal, "2024-12-31", "2025-03-30", "weeks");
    // 13.3
    check_age("13.3", "en", sayableage::Compactness.Normal, "2024-11-30", "2025-02-28", "3 months");
    // 13.4
    check_age_contains("13.4", "en", sayableage::Compactness.Normal, "2024-11-30", "2025-02-27", "weeks");

    // ---- 14. Born-on-31st progression ----
    // 14.1
    check_age("14.1", "en", sayableage::Compactness.Normal, "2025-01-31", "2025-04-30", "3 months");
    // 14.2
    check_age("14.2", "en", sayableage::Compactness.Normal, "2025-01-31", "2025-05-31", "4 months");
    // 14.3
    check_age("14.3", "en", sayableage::Compactness.Normal, "2025-01-31", "2025-06-30", "5 months");
    // 14.4
    check_age("14.4", "en", sayableage::Compactness.Normal, "2025-01-31", "2025-07-01", "5 months");
    // 14.5
    check_age("14.5", "en", sayableage::Compactness.Normal, "2025-01-31", "2025-07-31", "6 months");

    // ---- 15. Default asOf (current date) ----

    // ---- 16. formatStage — null / edge cases ----
    // 16.1
    check_no_stage("16.1", "en", "", "", "");
    // 16.2
    check_no_stage("16.2", "en", "undefined", "", "");
    // 16.3
    check_no_stage("16.3", "en", "", "", "");
    // 16.4
    check_no_stage("16.4", "en", "2025-07-01", "2025-06-15", "");
    // 16.5
    check_stage("16.5", "en", "1525-06-15", "2025-06-15", "", "Adult");
    // 16.6
    check_no_stage("16.6", "en", "1524-06-15", "2025-06-15", "");

    // ---- 17. formatStage — Newborn (0–1 months, <2 calendar months) ----
    // 17.1
    check_stage("17.1", "en", "2025-06-15", "2025-06-15", "", "Newborn");
    // 17.2
    check_stage("17.2", "en", "2025-06-14", "2025-06-15", "", "Newborn");
    // 17.3
    check_stage("17.3", "en", "2025-05-25", "2025-06-15", "", "Newborn");
    // 17.4
    check_stage("17.4", "en", "2025-05-15", "2025-06-15", "", "Newborn");
    // 17.5
    check_stage("17.5", "en", "2025-04-16", "2025-06-15", "", "Newborn");
    // 17.6
    check_stage("17.6", "en", "2025-04-15", "2025-06-15", "", "Infant");

    // ---- 18. formatStage — Infant (2–11 months) ----
    // 18.1
    check_stage("18.1", "en", "2025-04-15", "2025-06-15", "", "Infant");
    // 18.2
    check_stage("18.2", "en", "2024-12-15", "2025-06-15", "", "Infant");
    // 18.3
    check_stage("18.3", "en", "2024-07-15", "2025-06-15", "", "Infant");
    // 18.4
    check_stage("18.4", "en", "2024-06-15", "2025-06-15", "", "Toddler");

    // ---- 19. formatStage — Toddler (12–35 months) ----
    // 19.1
    check_stage("19.1", "en", "2024-06-15", "2025-06-15", "", "Toddler");
    // 19.2
    check_stage("19.2", "en", "2024-01-15", "2025-07-15", "", "Toddler");
    // 19.3
    check_stage("19.3", "en", "2023-06-15", "2025-06-15", "", "Toddler");
    // 19.4
    check_stage("19.4", "en", "2023-06-15", "2026-05-15", "", "Toddler");
    // 19.5
    check_stage("19.5", "en", "2022-06-15", "2025-06-15", "", "Child");

    // ---- 20. formatStage — Child (36–155 months, 3–12 years) ----
    // 20.1
    check_stage("20.1", "en", "2022-06-15", "2025-06-15", "", "Child");
    // 20.2
    check_stage("20.2", "en", "2021-06-15", "2025-06-15", "", "Child");
    // 20.3
    check_stage("20.3", "en", "2019-06-15", "2025-06-15", "", "Child");
    // 20.4
    check_stage("20.4", "en", "2016-06-15", "2025-06-15", "", "Child");
    // 20.5
    check_stage("20.5", "en", "2013-06-15", "2026-05-15", "", "Child");
    // 20.6
    check_stage("20.6", "en", "2012-06-15", "2025-06-15", "", "Teenager");

    // ---- 21. formatStage — Teenager (156–215 months, 13–17 years) ----
    // 21.1
    check_stage("21.1", "en", "2012-06-15", "2025-06-15", "", "Teenager");
    // 21.2
    check_stage("21.2", "en", "2010-06-15", "2025-06-15", "", "Teenager");
    // 21.3
    check_stage("21.3", "en", "2008-06-15", "2026-05-15", "", "Teenager");
    // 21.4
    check_stage("21.4", "en", "2007-06-15", "2025-06-15", "", "Adult");

    // ---- 22. formatStage — Adult (216+ months, 18+ years) ----
    // 22.1
    check_stage("22.1", "en", "2007-06-15", "2025-06-15", "", "Adult");
    // 22.2
    check_stage("22.2", "en", "2000-06-15", "2025-06-15", "", "Adult");
    // 22.3
    check_stage("22.3", "en", "1980-01-01", "2025-06-15", "", "Adult");

    // ---- 23. formatStage — default asOf ----

    // ---- 24. SayableAge class — English locale delegation ----
    // 24.1
    check_age("24.1", "en", sayableage::Compactness.Normal, "2025-06-15", "2025-06-15", "Newborn");
    // 24.2
    check_age("24.2", "en", sayableage::Compactness.Normal, "2025-06-12", "2025-06-15", "3 days");
    // 24.3
    check_age("24.3", "en", sayableage::Compactness.Normal, "2025-06-07", "2025-06-15", "1 week, 1 day");
    // 24.4
    check_age("24.4", "en", sayableage::Compactness.Normal, "2025-01-15", "2025-07-15", "6 months");
    // 24.5
    check_age("24.5", "en", sayableage::Compactness.Normal, "2023-06-15", "2025-07-15", "2 years, 1 month");
    // 24.6
    check_age("24.6", "en", sayableage::Compactness.Normal, "2022-06-15", "2025-12-15", "3½ years");
    // 24.7
    check_age("24.7", "en", sayableage::Compactness.Normal, "2018-06-15", "2025-06-15", "7 years");
    // 24.8
    check_stage("24.8", "en", "2025-06-15", "2025-06-15", "", "Newborn");
    // 24.9
    check_stage("24.9", "en", "2025-01-15", "2025-06-15", "", "Infant");
    // 24.10
    check_stage("24.10", "en", "2024-06-15", "2025-06-15", "", "Toddler");
    // 24.11
    check_stage("24.11", "en", "2022-06-15", "2025-06-15", "", "Child");
    // 24.12
    check_stage("24.12", "en", "2012-06-15", "2025-06-15", "", "Teenager");
    // 24.13
    check_stage("24.13", "en", "2007-06-15", "2025-06-15", "", "Adult");
    // 24.14
    check_no_age("24.14", "en", sayableage::Compactness.Normal, "", "2025-06-15");
    // 24.15
    check_no_stage("24.15", "en", "", "2025-06-15", "");

    // ---- 25. i18n — locale with all plural features ----
    // 25.1
    check_age("25.1", "es", sayableage::Compactness.Normal, "2025-06-15", "2025-06-15", "Recién nacido");
    // 25.2
    check_age("25.2", "es", sayableage::Compactness.Normal, "2025-06-14", "2025-06-15", "1 día");
    // 25.3
    check_age("25.3", "es", sayableage::Compactness.Normal, "2025-06-12", "2025-06-15", "3 días");
    // 25.4
    check_age("25.4", "es", sayableage::Compactness.Normal, "2025-06-08", "2025-06-15", "1 semana");
    // 25.5
    check_age("25.5", "es", sayableage::Compactness.Normal, "2025-06-07", "2025-06-15", "1 semana, 1 día");
    // 25.6
    check_age("25.6", "es", sayableage::Compactness.Normal, "2025-05-26", "2025-06-15", "2 semanas, 6 días");
    // 25.7
    check_age("25.7", "es", sayableage::Compactness.Normal, "2025-01-15", "2025-07-15", "6 meses");
    // 25.8
    check_age("25.8", "es", sayableage::Compactness.Normal, "2023-06-15", "2025-07-15", "2 años, 1 mes");
    // 25.9
    check_age("25.9", "es", sayableage::Compactness.Normal, "2023-06-15", "2025-12-15", "2 años, 6 meses");
    // 25.10
    check_age("25.10", "es", sayableage::Compactness.Normal, "2022-06-15", "2025-12-15", "3 años y medio");
    // 25.11
    check_age("25.11", "es", sayableage::Compactness.Normal, "2022-06-15", "2025-06-15", "3 años");
    // 25.12
    check_age("25.12", "es", sayableage::Compactness.Normal, "2018-06-15", "2025-06-15", "7 años");
    // 25.13
    check_stage("25.13", "es", "2025-06-15", "2025-06-15", "", "Recién nacido");
    // 25.14
    check_stage("25.14", "es", "2025-01-15", "2025-06-15", "", "Bebé");
    // 25.15
    check_stage("25.15", "es", "2024-06-15", "2025-06-15", "", "Niño pequeño");
    // 25.16
    check_stage("25.16", "es", "2022-06-15", "2025-06-15", "", "Niño");
    // 25.17
    check_stage("25.17", "es", "2012-06-15", "2025-06-15", "", "Adolescente");
    // 25.18
    check_stage("25.18", "es", "2007-06-15", "2025-06-15", "", "Adulto");
    // 25.19
    check_no_age("25.19", "es", sayableage::Compactness.Normal, "", "2025-06-15");
    // 25.20
    check_no_stage("25.20", "es", "", "2025-06-15", "");

    // ---- 26. Compactness — short ----
    // 26.1
    check_age("26.1", "en", sayableage::Compactness.Short, "2025-06-12", "2025-06-15", "3 d");
    // 26.2
    check_age("26.2", "en", sayableage::Compactness.Short, "2025-06-08", "2025-06-15", "1 wk");
    // 26.3
    check_age("26.3", "en", sayableage::Compactness.Short, "2025-06-07", "2025-06-15", "1 wk, 1 d");
    // 26.4
    check_age("26.4", "en", sayableage::Compactness.Short, "2025-01-15", "2025-07-15", "6 mo");
    // 26.5
    check_age("26.5", "en", sayableage::Compactness.Short, "2023-06-15", "2025-07-15", "2 yr, 1 mo");
    // 26.6
    check_age("26.6", "en", sayableage::Compactness.Short, "2022-06-15", "2025-12-15", "3½ yr");
    // 26.7
    check_age("26.7", "en", sayableage::Compactness.Short, "2018-06-15", "2025-06-15", "7 yr");
    // 26.8
    check_age("26.8", "en", sayableage::Compactness.Short, "2025-06-15", "2025-06-15", "Newborn");
    // 26.9
    check_stage("26.9", "en", "2025-01-15", "2025-06-15", "", "Infant");

    // ---- 27. Compactness — compact ----
    // 27.1
    check_age("27.1", "en", sayableage::Compactness.Compact, "2025-06-12", "2025-06-15", "3d");
    // 27.2
    check_age("27.2", "en", sayableage::Compactness.Compact, "2025-06-08", "2025-06-15", "1w");
    // 27.3
    check_age("27.3", "en", sayableage::Compactness.Compact, "2025-06-07", "2025-06-15", "1w1d");
    // 27.4
    check_age("27.4", "en", sayableage::Compactness.Compact, "2025-01-15", "2025-07-15", "6m");
    // 27.5
    check_age("27.5", "en", sayableage::Compactness.Compact, "2023-06-15", "2025-07-15", "2y1m");
    // 27.6
    check_age("27.6", "en", sayableage::Compactness.Compact, "2022-06-15", "2025-12-15", "3½y");
    // 27.7
    check_age("27.7", "en", sayableage::Compactness.Compact, "2018-06-15", "2025-06-15", "7y");
    // 27.8
    check_age("27.8", "en", sayableage::Compactness.Compact, "2025-06-15", "2025-06-15", "Newborn");

    // ---- 29. Locale-specific edge cases — plural rules ----
    // 29.1
    check_age("29.1", "he", sayableage::Compactness.Normal, "2025-06-15", "2025-06-15", "רק נולד");
    // 29.2
    check_age("29.2", "he", sayableage::Compactness.Normal, "2025-06-14", "2025-06-15", "יום");
    // 29.3
    check_age("29.3", "he", sayableage::Compactness.Normal, "2025-06-12", "2025-06-15", "3 ימים");
    // 29.4
    check_age("29.4", "he", sayableage::Compactness.Normal, "2025-06-01", "2025-06-15", "שבועיים");
    // 29.5
    check_age("29.5", "he", sayableage::Compactness.Normal, "2025-05-25", "2025-06-15", "3 שבועות");
    // 29.6
    check_age("29.6", "he", sayableage::Compactness.Normal, "2025-01-15", "2025-07-15", "6 חודשים");
    // 29.7
    check_age("29.7", "he", sayableage::Compactness.Normal, "2025-03-15", "2025-06-15", "3 חודשים");
    // 29.8
    check_age("29.8", "he", sayableage::Compactness.Normal, "2023-06-15", "2025-07-15", "שנתיים, חודש");
    // 29.9
    check_age("29.9", "he", sayableage::Compactness.Normal, "2022-06-15", "2025-12-15", "3 שנים וחצי");
    // 29.10
    check_age("29.10", "he", sayableage::Compactness.Normal, "2018-06-15", "2025-06-15", "7 שנים");
    // 29.11
    check_stage("29.11", "he", "2025-06-15", "2025-06-15", "m", "רק נולד");
    // 29.12
    check_stage("29.12", "he", "2025-06-15", "2025-06-15", "f", "רק נולדה");
    // 29.13
    check_stage("29.13", "he", "2007-06-15", "2025-06-15", "m", "מבוגר");
    // 29.14
    check_stage("29.14", "he", "2007-06-15", "2025-06-15", "f", "מבוגרת");
    // 29.15
    check_age("29.15", "mk", sayableage::Compactness.Normal, "2025-06-15", "2025-06-15", "Новороденче");
    // 29.16
    check_age("29.16", "mk", sayableage::Compactness.Normal, "2025-06-14", "2025-06-15", "1 ден");
    // 29.17
    check_age("29.17", "mk", sayableage::Compactness.Normal, "2025-06-12", "2025-06-15", "3 дена");
    // 29.18
    check_age("29.18", "mk", sayableage::Compactness.Normal, "2025-01-15", "2025-07-15", "6 месеци");
    // 29.19
    check_age("29.19", "mk", sayableage::Compactness.Normal, "2023-06-15", "2025-07-15", "2 години, 1 месец");
    // 29.20
    check_age("29.20", "mk", sayableage::Compactness.Normal, "2022-06-15", "2025-12-15", "3 години и пол");
    // 29.21
    check_age("29.21", "mk", sayableage::Compactness.Normal, "2018-06-15", "2025-06-15", "7 години");
    // 29.22
    check_age("29.22", "sw", sayableage::Compactness.Normal, "2025-06-15", "2025-06-15", "Mzaliwa mpya");
    // 29.23
    check_age("29.23", "sw", sayableage::Compactness.Normal, "2025-06-14", "2025-06-15", "siku 1");
    // 29.24
    check_age("29.24", "sw", sayableage::Compactness.Normal, "2025-06-12", "2025-06-15", "siku 3");
    // 29.25
    check_age("29.25", "sw", sayableage::Compactness.Normal, "2025-01-15", "2025-07-15", "miezi 6");
    // 29.26
    check_age("29.26", "sw", sayableage::Compactness.Normal, "2023-06-15", "2025-07-15", "miaka 2, mwezi 1");
    // 29.27
    check_age("29.27", "sw", sayableage::Compactness.Normal, "2022-06-15", "2025-12-15", "miaka 3 na nusu");
    // 29.28
    check_age("29.28", "id", sayableage::Compactness.Normal, "2025-06-15", "2025-06-15", "Baru lahir");
    // 29.29
    check_age("29.29", "id", sayableage::Compactness.Normal, "2025-06-14", "2025-06-15", "1 hari");
    // 29.30
    check_age("29.30", "id", sayableage::Compactness.Normal, "2025-06-12", "2025-06-15", "3 hari");
    // 29.31
    check_age("29.31", "id", sayableage::Compactness.Normal, "2025-01-15", "2025-07-15", "6 bulan");
    // 29.32
    check_age("29.32", "id", sayableage::Compactness.Normal, "2022-06-15", "2025-12-15", "3 setengah tahun");
    // 29.33
    check_age("29.33", "id", sayableage::Compactness.Normal, "2018-06-15", "2025-06-15", "7 tahun");
    // 29.34
    check_age("29.34", "am", sayableage::Compactness.Normal, "2025-06-15", "2025-06-15", "አዲስ የተወለደ");
    // 29.35
    check_age("29.35", "am", sayableage::Compactness.Normal, "2025-06-14", "2025-06-15", "1 ቀን");
    // 29.36
    check_age("29.36", "am", sayableage::Compactness.Normal, "2025-06-12", "2025-06-15", "3 ቀናት");
    // 29.37
    check_age("29.37", "am", sayableage::Compactness.Normal, "2025-06-07", "2025-06-15", "1 ሳምንት፣ 1 ቀን");
    // 29.38
    check_age("29.38", "am", sayableage::Compactness.Normal, "2025-01-15", "2025-07-15", "6 ወራት");
    // 29.39
    check_age("29.39", "am", sayableage::Compactness.Normal, "2022-06-15", "2025-12-15", "3 ዓመታት ተኩል");

    // ---- 30. Locale lookup by code string ----
    // 30.1
    check_locale("30.1", "en", "en");
    // 30.2
    check_locale("30.2", "fr", "fr");
    // 30.3
    check_no_locale("30.3", "xx");
    // 30.4
    check_no_locale("30.4", "");
    // 30.5
    check_no_locale("30.5", "EN");

    // ---- 31. Weeks and days across month ends ----
    // 31.1
    check_age("31.1", "en", sayableage::Compactness.Normal, "2016-12-31", "2017-03-29", "12 weeks, 4 days");
    // 31.2
    check_age("31.2", "en", sayableage::Compactness.Normal, "1991-11-27", "1992-02-25", "12 weeks, 6 days");
    // 31.3
    check_age("31.3", "en", sayableage::Compactness.Normal, "2020-11-30", "2021-01-02", "4 weeks, 5 days");
    // 31.4
    check_age("31.4", "en", sayableage::Compactness.Compact, "2016-12-31", "2017-03-29", "12w4d");

    // ---- 32. Half years take their plural form from whole years ----
    // 32.1
    check_age("32.1", "pl", sayableage::Compactness.Normal, "2021-06-15", "2025-01-15", "3 i pół lata");
    // 32.2
    check_age("32.2", "pl", sayableage::Compactness.Short, "2020-06-15", "2025-12-15", "5 i pół lat");
    // 32.3
    check_age("32.3", "shi", sayableage::Compactness.Normal, "2005-06-08", "2012-06-07", "6 iseggasen d uzgen");

    // ---- 33. Input validation ----
    // 33.1
    check_no_age("33.1", "en", sayableage::Compactness.Normal, "2025-02-30", "2032-06-25");
    // 33.2
    check_no_age("33.2", "en", sayableage::Compactness.Normal, "2025-13-01", "2027-01-31");
    // 33.3
    check_no_age("33.3", "en", sayableage::Compactness.Normal, "2023-02-29", "2025-03-01");
    // 33.4
    check_no_age("33.4", "en", sayableage::Compactness.Normal, "2025-06-00", "2027-02-25");
    // 33.5
    check_no_age("33.5", "en", sayableage::Compactness.Normal, "2025-6-1", "2027-02-25");
    // 33.6
    check_no_age("33.6", "en", sayableage::Compactness.Normal, " 2025-06-01", "2027-02-25");
    // 33.7
    check_no_age("33.7", "en", sayableage::Compactness.Normal, "2025-06-15T10:00:00", "2027-02-25");
    // 33.8
    check_no_age("33.8", "en", sayableage::Compactness.Normal, "2020-01-01", "2025-04-31");
    // 33.9
    check_no_stage("33.9", "en", "2025-02-30", "2027-09-05", "");
    // 33.10
    check_age("33.10", "en", sayableage::Compactness.Normal, "2024-02-29", "2026-03-01", "2 years");

    print(passed, " passed, ", failed, " failed");
    if failed > 0 { exit(1); }
}
