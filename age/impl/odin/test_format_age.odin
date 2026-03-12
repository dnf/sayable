package sayableage

import "core:testing"
import "core:fmt"

expect_str :: proc(t: ^testing.T, expected: string, actual: Maybe(string), loc := #caller_location) {
    if v, ok := actual.?; ok {
        testing.expect_value(t, v, expected, loc = loc)
    } else {
        fmt.printf("Expected %q but got nil at %v\n", expected, loc)
        testing.expect(t, false, loc = loc)
    }
}

expect_nil :: proc(t: ^testing.T, actual: Maybe(string), loc := #caller_location) {
    if v, ok := actual.?; ok {
        fmt.printf("Expected nil but got %q at %v\n", v, loc)
        testing.expect(t, false, loc = loc)
    }
}

expect_contains :: proc(t: ^testing.T, actual: Maybe(string), substr: string, loc := #caller_location) {
    if v, ok := actual.?; ok {
        if index_of(v, substr) < 0 {
            fmt.printf("Expected %q to contain %q at %v\n", v, substr, loc)
            testing.expect(t, false, loc = loc)
        }
    } else {
        fmt.printf("Expected string containing %q but got nil at %v\n", substr, loc)
        testing.expect(t, false, loc = loc)
    }
}

fmt_age :: proc(buf: []u8, dob, as_of: string) -> Maybe(string) {
    return format_age(buf, &locale_en, .Normal, dob, as_of)
}

// ================================================================
// formatAge -- null/edge cases
// ================================================================

// 1.1, 1.3
@(test)
test_empty_string :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_nil(t, fmt_age(buf[:], "", "2025-06-15"))
}

// 1.4
@(test)
test_future_dob :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_nil(t, fmt_age(buf[:], "2025-07-01", "2025-06-15"))
}

// 1.5
@(test)
test_exactly_500_years :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "500 years", fmt_age(buf[:], "1525-06-15", "2025-06-15"))
}

// 1.6
@(test)
test_501_years_exceeds_max :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_nil(t, fmt_age(buf[:], "1524-06-15", "2025-06-15"))
}

// 1.7
@(test)
test_1000_years_exceeds_max :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_nil(t, fmt_age(buf[:], "1025-06-15", "2025-06-15"))
}

// ================================================================
// formatAge -- days tier (0-6)
// ================================================================

// 2.1
@(test)
test_born_today :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "Newborn", fmt_age(buf[:], "2025-06-15", "2025-06-15"))
}

// 2.2
@(test)
test_1_day_ago :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "1 day", fmt_age(buf[:], "2025-06-14", "2025-06-15"))
}

// 2.3
@(test)
test_3_days_ago :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "3 days", fmt_age(buf[:], "2025-06-12", "2025-06-15"))
}

// 2.4
@(test)
test_6_days_ago :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "6 days", fmt_age(buf[:], "2025-06-09", "2025-06-15"))
}

// 2.5
@(test)
test_7_days_is_1_week :: proc(t: ^testing.T) {
    buf: [256]u8
    expect_str(t, "1 week", fmt_age(buf[:], "2025-06-08", "2025-06-15"))
}

// ================================================================
// formatAge -- weeks+days tier (7 days to <3 months)
// ================================================================

// 3.1 - 3.12
@(test) test_7_days :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 week", fmt_age(buf[:], "2025-06-08", "2025-06-15")) }
@(test) test_8_days :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 week, 1 day", fmt_age(buf[:], "2025-06-07", "2025-06-15")) }
@(test) test_9_days :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 week, 2 days", fmt_age(buf[:], "2025-06-06", "2025-06-15")) }
@(test) test_13_days :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 week, 6 days", fmt_age(buf[:], "2025-06-02", "2025-06-15")) }
@(test) test_14_days :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2 weeks", fmt_age(buf[:], "2025-06-01", "2025-06-15")) }
@(test) test_15_days :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2 weeks, 1 day", fmt_age(buf[:], "2025-05-31", "2025-06-15")) }
@(test) test_20_days :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2 weeks, 6 days", fmt_age(buf[:], "2025-05-26", "2025-06-15")) }
@(test) test_21_days :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 weeks", fmt_age(buf[:], "2025-05-25", "2025-06-15")) }
@(test) test_1_cal_month_still_weeks :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "4 weeks, 3 days", fmt_age(buf[:], "2025-05-15", "2025-06-15")) }
@(test) test_2_cal_months_still_weeks :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "8 weeks, 5 days", fmt_age(buf[:], "2025-04-15", "2025-06-15")) }
@(test) test_one_day_before_3mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "13 weeks", fmt_age(buf[:], "2025-03-15", "2025-06-14")) }
@(test) test_on_3mo_birthday :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 months", fmt_age(buf[:], "2025-03-15", "2025-06-15")) }

// ================================================================
// formatAge -- month boundaries: standard months (4.1 - 4.5)
// ================================================================
@(test) test_jan1_apr1_3mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 months", fmt_age(buf[:], "2025-01-01", "2025-04-01")) }
@(test) test_jan1_mar31_weeks :: proc(t: ^testing.T) { buf: [256]u8; expect_contains(t, fmt_age(buf[:], "2025-01-01", "2025-03-31"), "weeks") }
@(test) test_jun15_sep15_3mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 months", fmt_age(buf[:], "2025-06-15", "2025-09-15")) }
@(test) test_jun15_sep14_weeks :: proc(t: ^testing.T) { buf: [256]u8; expect_contains(t, fmt_age(buf[:], "2025-06-15", "2025-09-14"), "weeks") }
@(test) test_jun15_dec15_6mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "6 months", fmt_age(buf[:], "2025-06-15", "2025-12-15")) }

// ================================================================
// formatAge -- month boundaries: February non-leap (5.1 - 5.5)
// ================================================================
@(test) test_jan31_feb28_nonleap :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "4 weeks", fmt_age(buf[:], "2025-01-31", "2025-02-28")) }
@(test) test_jan31_apr30_3mo_clamp :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 months", fmt_age(buf[:], "2025-01-31", "2025-04-30")) }
@(test) test_jan31_apr29_weeks :: proc(t: ^testing.T) { buf: [256]u8; expect_contains(t, fmt_age(buf[:], "2025-01-31", "2025-04-29"), "weeks") }
@(test) test_feb1_may1_3mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 months", fmt_age(buf[:], "2025-02-01", "2025-05-01")) }
@(test) test_feb1_apr30_weeks :: proc(t: ^testing.T) { buf: [256]u8; expect_contains(t, fmt_age(buf[:], "2025-02-01", "2025-04-30"), "weeks") }

// ================================================================
// formatAge -- month boundaries: February leap year (6.1 - 6.5)
// ================================================================
@(test) test_jan31_feb29_leap :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "4 weeks, 1 day", fmt_age(buf[:], "2024-01-31", "2024-02-29")) }
@(test) test_jan31_feb28_leap :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "4 weeks", fmt_age(buf[:], "2024-01-31", "2024-02-28")) }
@(test) test_jan31_apr30_leap_3mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 months", fmt_age(buf[:], "2024-01-31", "2024-04-30")) }
@(test) test_jan30_feb29_leap_weeks :: proc(t: ^testing.T) { buf: [256]u8; expect_contains(t, fmt_age(buf[:], "2024-01-30", "2024-02-29"), "weeks") }
@(test) test_jan30_feb28_leap_weeks :: proc(t: ^testing.T) { buf: [256]u8; expect_contains(t, fmt_age(buf[:], "2024-01-30", "2024-02-28"), "weeks") }

// ================================================================
// formatAge -- month boundaries: 30-day months (7.1 - 7.4)
// ================================================================
@(test) test_mar31_jun30_3mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 months", fmt_age(buf[:], "2025-03-31", "2025-06-30")) }
@(test) test_mar31_jun29_weeks :: proc(t: ^testing.T) { buf: [256]u8; expect_contains(t, fmt_age(buf[:], "2025-03-31", "2025-06-29"), "weeks") }
@(test) test_aug31_nov30_3mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 months", fmt_age(buf[:], "2025-08-31", "2025-11-30")) }
@(test) test_aug31_nov29_weeks :: proc(t: ^testing.T) { buf: [256]u8; expect_contains(t, fmt_age(buf[:], "2025-08-31", "2025-11-29"), "weeks") }

// ================================================================
// formatAge -- leap year baby (8.1 - 8.4)
// ================================================================
@(test) test_feb29_may29_3mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 months", fmt_age(buf[:], "2024-02-29", "2024-05-29")) }
@(test) test_feb29_may28_weeks :: proc(t: ^testing.T) { buf: [256]u8; expect_contains(t, fmt_age(buf[:], "2024-02-29", "2024-05-28"), "weeks") }
@(test) test_feb29_2024_feb28_2025_12mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "12 months", fmt_age(buf[:], "2024-02-29", "2025-02-28")) }
@(test) test_feb29_2024_mar1_2025_12mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "12 months", fmt_age(buf[:], "2024-02-29", "2025-03-01")) }

// ================================================================
// formatAge -- months tier (9.1 - 9.6)
// ================================================================
@(test) test_3_months :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 months", fmt_age(buf[:], "2025-01-15", "2025-04-15")) }
@(test) test_6_months :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "6 months", fmt_age(buf[:], "2025-01-15", "2025-07-15")) }
@(test) test_12_months :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "12 months", fmt_age(buf[:], "2024-06-15", "2025-06-15")) }
@(test) test_23_months :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "23 months", fmt_age(buf[:], "2024-01-15", "2025-12-15")) }
@(test) test_5_months :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "5 months", fmt_age(buf[:], "2025-01-15", "2025-07-14")) }
@(test) test_5_months_cross_year :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "5 months", fmt_age(buf[:], "2024-11-10", "2025-04-10")) }

// ================================================================
// formatAge -- years+months tier (10.1 - 10.5)
// ================================================================
@(test) test_2_years :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2 years", fmt_age(buf[:], "2023-06-15", "2025-06-15")) }
@(test) test_2y1m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2 years, 1 month", fmt_age(buf[:], "2023-06-15", "2025-07-15")) }
@(test) test_2y6m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2 years, 6 months", fmt_age(buf[:], "2023-06-15", "2025-12-15")) }
@(test) test_2y11m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2 years, 11 months", fmt_age(buf[:], "2023-06-15", "2026-05-15")) }
@(test) test_before_24mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "23 months", fmt_age(buf[:], "2023-06-15", "2025-06-14")) }

// ================================================================
// formatAge -- half-year tier (11.1 - 11.12)
// ================================================================
@(test) test_3y_exact :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 years", fmt_age(buf[:], "2022-06-15", "2025-06-15")) }
@(test) test_3y5m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 years", fmt_age(buf[:], "2022-06-15", "2025-11-15")) }
@(test) test_3_half_at_3y6m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3\u00BD years", fmt_age(buf[:], "2022-06-15", "2025-12-15")) }
@(test) test_3_half_at_3y11m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3\u00BD years", fmt_age(buf[:], "2022-06-15", "2026-05-15")) }
@(test) test_4y_exact :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "4 years", fmt_age(buf[:], "2021-06-15", "2025-06-15")) }
@(test) test_4_half :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "4\u00BD years", fmt_age(buf[:], "2021-06-15", "2025-12-15")) }
@(test) test_5y :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "5 years", fmt_age(buf[:], "2020-06-15", "2025-06-15")) }
@(test) test_5_half :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "5\u00BD years", fmt_age(buf[:], "2020-06-15", "2026-02-15")) }
@(test) test_6y :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "6 years", fmt_age(buf[:], "2019-06-15", "2025-06-15")) }
@(test) test_6_half :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "6\u00BD years", fmt_age(buf[:], "2019-06-15", "2025-12-15")) }
@(test) test_6_half_at_6y11m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "6\u00BD years", fmt_age(buf[:], "2019-06-15", "2026-05-15")) }
@(test) test_before_3rd_bday :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2 years, 11 months", fmt_age(buf[:], "2022-06-15", "2025-06-14")) }

// ================================================================
// formatAge -- integer tier 7+ years (12.1 - 12.3)
// ================================================================
@(test) test_7y :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "7 years", fmt_age(buf[:], "2018-06-15", "2025-06-15")) }
@(test) test_7y6m_no_half :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "7 years", fmt_age(buf[:], "2018-03-20", "2025-06-15")) }
@(test) test_45y :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "45 years", fmt_age(buf[:], "1980-01-01", "2025-06-15")) }

// ================================================================
// formatAge -- cross-year transitions (13.1 - 13.4)
// ================================================================
@(test) test_dec31_mar31_3mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 months", fmt_age(buf[:], "2024-12-31", "2025-03-31")) }
@(test) test_dec31_mar30_weeks :: proc(t: ^testing.T) { buf: [256]u8; expect_contains(t, fmt_age(buf[:], "2024-12-31", "2025-03-30"), "weeks") }
@(test) test_nov30_feb28_3mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 months", fmt_age(buf[:], "2024-11-30", "2025-02-28")) }
@(test) test_nov30_feb27_weeks :: proc(t: ^testing.T) { buf: [256]u8; expect_contains(t, fmt_age(buf[:], "2024-11-30", "2025-02-27"), "weeks") }

// ================================================================
// formatAge -- born-on-31st (14.1 - 14.5)
// ================================================================
@(test) test_jan31_apr30_3mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 months", fmt_age(buf[:], "2025-01-31", "2025-04-30")) }
@(test) test_jan31_may31_4mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "4 months", fmt_age(buf[:], "2025-01-31", "2025-05-31")) }
@(test) test_jan31_jun30_5mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "5 months", fmt_age(buf[:], "2025-01-31", "2025-06-30")) }
@(test) test_jan31_jul1_5mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "5 months", fmt_age(buf[:], "2025-01-31", "2025-07-01")) }
@(test) test_jan31_jul31_6mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "6 months", fmt_age(buf[:], "2025-01-31", "2025-07-31")) }

// ================================================================
// formatStage -- null/edge cases (16.1 - 16.6)
// ================================================================
@(test) test_stage_empty :: proc(t: ^testing.T) { expect_nil(t, format_stage(&locale_en, "", "2025-06-15", "")) }
@(test) test_stage_future :: proc(t: ^testing.T) { expect_nil(t, format_stage(&locale_en, "2025-07-01", "2025-06-15", "")) }
@(test) test_stage_500y :: proc(t: ^testing.T) { expect_str(t, "Adult", format_stage(&locale_en, "1525-06-15", "2025-06-15", "")) }
@(test) test_stage_501y :: proc(t: ^testing.T) { expect_nil(t, format_stage(&locale_en, "1524-06-15", "2025-06-15", "")) }

// ================================================================
// formatStage -- newborn (17.1 - 17.6)
// ================================================================
@(test) test_stage_newborn_today :: proc(t: ^testing.T) { expect_str(t, "Newborn", format_stage(&locale_en, "2025-06-15", "2025-06-15", "")) }
@(test) test_stage_newborn_1d :: proc(t: ^testing.T) { expect_str(t, "Newborn", format_stage(&locale_en, "2025-06-14", "2025-06-15", "")) }
@(test) test_stage_newborn_3w :: proc(t: ^testing.T) { expect_str(t, "Newborn", format_stage(&locale_en, "2025-05-25", "2025-06-15", "")) }
@(test) test_stage_newborn_1m :: proc(t: ^testing.T) { expect_str(t, "Newborn", format_stage(&locale_en, "2025-05-15", "2025-06-15", "")) }
@(test) test_stage_newborn_1m29d :: proc(t: ^testing.T) { expect_str(t, "Newborn", format_stage(&locale_en, "2025-04-16", "2025-06-15", "")) }
@(test) test_stage_2m_infant :: proc(t: ^testing.T) { expect_str(t, "Infant", format_stage(&locale_en, "2025-04-15", "2025-06-15", "")) }

// ================================================================
// formatStage -- infant (18.1 - 18.4)
// ================================================================
@(test) test_stage_infant_2m :: proc(t: ^testing.T) { expect_str(t, "Infant", format_stage(&locale_en, "2025-04-15", "2025-06-15", "")) }
@(test) test_stage_infant_6m :: proc(t: ^testing.T) { expect_str(t, "Infant", format_stage(&locale_en, "2024-12-15", "2025-06-15", "")) }
@(test) test_stage_infant_11m :: proc(t: ^testing.T) { expect_str(t, "Infant", format_stage(&locale_en, "2024-07-15", "2025-06-15", "")) }
@(test) test_stage_12m_toddler :: proc(t: ^testing.T) { expect_str(t, "Toddler", format_stage(&locale_en, "2024-06-15", "2025-06-15", "")) }

// ================================================================
// formatStage -- toddler (19.1 - 19.5)
// ================================================================
@(test) test_stage_toddler_12m :: proc(t: ^testing.T) { expect_str(t, "Toddler", format_stage(&locale_en, "2024-06-15", "2025-06-15", "")) }
@(test) test_stage_toddler_18m :: proc(t: ^testing.T) { expect_str(t, "Toddler", format_stage(&locale_en, "2024-01-15", "2025-07-15", "")) }
@(test) test_stage_toddler_24m :: proc(t: ^testing.T) { expect_str(t, "Toddler", format_stage(&locale_en, "2023-06-15", "2025-06-15", "")) }
@(test) test_stage_toddler_35m :: proc(t: ^testing.T) { expect_str(t, "Toddler", format_stage(&locale_en, "2023-06-15", "2026-05-15", "")) }
@(test) test_stage_36m_child :: proc(t: ^testing.T) { expect_str(t, "Child", format_stage(&locale_en, "2022-06-15", "2025-06-15", "")) }

// ================================================================
// formatStage -- child (20.1 - 20.6)
// ================================================================
@(test) test_stage_child_3y :: proc(t: ^testing.T) { expect_str(t, "Child", format_stage(&locale_en, "2022-06-15", "2025-06-15", "")) }
@(test) test_stage_child_4y :: proc(t: ^testing.T) { expect_str(t, "Child", format_stage(&locale_en, "2021-06-15", "2025-06-15", "")) }
@(test) test_stage_child_6y :: proc(t: ^testing.T) { expect_str(t, "Child", format_stage(&locale_en, "2019-06-15", "2025-06-15", "")) }
@(test) test_stage_child_9y :: proc(t: ^testing.T) { expect_str(t, "Child", format_stage(&locale_en, "2016-06-15", "2025-06-15", "")) }
@(test) test_stage_child_12y11m :: proc(t: ^testing.T) { expect_str(t, "Child", format_stage(&locale_en, "2013-06-15", "2026-05-15", "")) }
@(test) test_stage_13y_teenager :: proc(t: ^testing.T) { expect_str(t, "Teenager", format_stage(&locale_en, "2012-06-15", "2025-06-15", "")) }

// ================================================================
// formatStage -- teenager (21.1 - 21.4)
// ================================================================
@(test) test_stage_teenager_13y :: proc(t: ^testing.T) { expect_str(t, "Teenager", format_stage(&locale_en, "2012-06-15", "2025-06-15", "")) }
@(test) test_stage_teenager_15y :: proc(t: ^testing.T) { expect_str(t, "Teenager", format_stage(&locale_en, "2010-06-15", "2025-06-15", "")) }
@(test) test_stage_teenager_17y11m :: proc(t: ^testing.T) { expect_str(t, "Teenager", format_stage(&locale_en, "2008-06-15", "2026-05-15", "")) }
@(test) test_stage_18y_adult :: proc(t: ^testing.T) { expect_str(t, "Adult", format_stage(&locale_en, "2007-06-15", "2025-06-15", "")) }

// ================================================================
// formatStage -- adult (22.1 - 22.3)
// ================================================================
@(test) test_stage_adult_18y :: proc(t: ^testing.T) { expect_str(t, "Adult", format_stage(&locale_en, "2007-06-15", "2025-06-15", "")) }
@(test) test_stage_adult_25y :: proc(t: ^testing.T) { expect_str(t, "Adult", format_stage(&locale_en, "2000-06-15", "2025-06-15", "")) }
@(test) test_stage_adult_45y :: proc(t: ^testing.T) { expect_str(t, "Adult", format_stage(&locale_en, "1980-01-01", "2025-06-15", "")) }

// ================================================================
// EN integration (24.1 - 24.15)
// ================================================================
@(test) test_en_newborn :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "Newborn", format_age(buf[:], &locale_en, .Normal, "2025-06-15", "2025-06-15")) }
@(test) test_en_3_days :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 days", format_age(buf[:], &locale_en, .Normal, "2025-06-12", "2025-06-15")) }
@(test) test_en_1w1d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 week, 1 day", format_age(buf[:], &locale_en, .Normal, "2025-06-07", "2025-06-15")) }
@(test) test_en_6mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "6 months", format_age(buf[:], &locale_en, .Normal, "2025-01-15", "2025-07-15")) }
@(test) test_en_2y1m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2 years, 1 month", format_age(buf[:], &locale_en, .Normal, "2023-06-15", "2025-07-15")) }
@(test) test_en_3_half :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3\u00BD years", format_age(buf[:], &locale_en, .Normal, "2022-06-15", "2025-12-15")) }
@(test) test_en_7y :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "7 years", format_age(buf[:], &locale_en, .Normal, "2018-06-15", "2025-06-15")) }
@(test) test_en_stage_newborn :: proc(t: ^testing.T) { expect_str(t, "Newborn", format_stage(&locale_en, "2025-06-15", "2025-06-15", "")) }
@(test) test_en_stage_infant :: proc(t: ^testing.T) { expect_str(t, "Infant", format_stage(&locale_en, "2025-01-15", "2025-06-15", "")) }
@(test) test_en_stage_toddler :: proc(t: ^testing.T) { expect_str(t, "Toddler", format_stage(&locale_en, "2024-06-15", "2025-06-15", "")) }
@(test) test_en_stage_child :: proc(t: ^testing.T) { expect_str(t, "Child", format_stage(&locale_en, "2022-06-15", "2025-06-15", "")) }
@(test) test_en_stage_teenager :: proc(t: ^testing.T) { expect_str(t, "Teenager", format_stage(&locale_en, "2012-06-15", "2025-06-15", "")) }
@(test) test_en_stage_adult :: proc(t: ^testing.T) { expect_str(t, "Adult", format_stage(&locale_en, "2007-06-15", "2025-06-15", "")) }
@(test) test_en_null_age :: proc(t: ^testing.T) { buf: [256]u8; expect_nil(t, format_age(buf[:], &locale_en, .Normal, "", "2025-06-15")) }
@(test) test_en_null_stage :: proc(t: ^testing.T) { expect_nil(t, format_stage(&locale_en, "", "2025-06-15", "")) }

// ================================================================
// ES integration (25.1 - 25.20)
// ================================================================
@(test) test_es_just_born :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "Recién nacido", format_age(buf[:], &locale_es, .Normal, "2025-06-15", "2025-06-15")) }
@(test) test_es_1d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 día", format_age(buf[:], &locale_es, .Normal, "2025-06-14", "2025-06-15")) }
@(test) test_es_3d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 días", format_age(buf[:], &locale_es, .Normal, "2025-06-12", "2025-06-15")) }
@(test) test_es_1w :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 semana", format_age(buf[:], &locale_es, .Normal, "2025-06-08", "2025-06-15")) }
@(test) test_es_1w1d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 semana, 1 día", format_age(buf[:], &locale_es, .Normal, "2025-06-07", "2025-06-15")) }
@(test) test_es_2w6d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2 semanas, 6 días", format_age(buf[:], &locale_es, .Normal, "2025-05-26", "2025-06-15")) }
@(test) test_es_6mo :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "6 meses", format_age(buf[:], &locale_es, .Normal, "2025-01-15", "2025-07-15")) }
@(test) test_es_2y1m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2 años, 1 mes", format_age(buf[:], &locale_es, .Normal, "2023-06-15", "2025-07-15")) }
@(test) test_es_2y6m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2 años, 6 meses", format_age(buf[:], &locale_es, .Normal, "2023-06-15", "2025-12-15")) }
@(test) test_es_half :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 y medio años", format_age(buf[:], &locale_es, .Normal, "2022-06-15", "2025-12-15")) }
@(test) test_es_3y :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 años", format_age(buf[:], &locale_es, .Normal, "2022-06-15", "2025-06-15")) }
@(test) test_es_7y :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "7 años", format_age(buf[:], &locale_es, .Normal, "2018-06-15", "2025-06-15")) }
@(test) test_es_stage_newborn :: proc(t: ^testing.T) { expect_str(t, "Recién nacido", format_stage(&locale_es, "2025-06-15", "2025-06-15", "")) }
@(test) test_es_stage_infant :: proc(t: ^testing.T) { expect_str(t, "Bebé", format_stage(&locale_es, "2025-01-15", "2025-06-15", "")) }
@(test) test_es_stage_toddler :: proc(t: ^testing.T) { expect_str(t, "Niño pequeño", format_stage(&locale_es, "2024-06-15", "2025-06-15", "")) }
@(test) test_es_stage_child :: proc(t: ^testing.T) { expect_str(t, "Niño", format_stage(&locale_es, "2022-06-15", "2025-06-15", "")) }
@(test) test_es_stage_teenager :: proc(t: ^testing.T) { expect_str(t, "Adolescente", format_stage(&locale_es, "2012-06-15", "2025-06-15", "")) }
@(test) test_es_stage_adult :: proc(t: ^testing.T) { expect_str(t, "Adulto", format_stage(&locale_es, "2007-06-15", "2025-06-15", "")) }
@(test) test_es_null :: proc(t: ^testing.T) { buf: [256]u8; expect_nil(t, format_age(buf[:], &locale_es, .Normal, "", "2025-06-15")) }
@(test) test_es_null_stage :: proc(t: ^testing.T) { expect_nil(t, format_stage(&locale_es, "", "2025-06-15", "")) }

// ================================================================
// Compactness: short (26.1 - 26.9)
// ================================================================
@(test) test_short_days :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 d", format_age(buf[:], &locale_en, .Short, "2025-06-12", "2025-06-15")) }
@(test) test_short_weeks :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 wk", format_age(buf[:], &locale_en, .Short, "2025-06-08", "2025-06-15")) }
@(test) test_short_w_d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 wk, 1 d", format_age(buf[:], &locale_en, .Short, "2025-06-07", "2025-06-15")) }
@(test) test_short_months :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "6 mo", format_age(buf[:], &locale_en, .Short, "2025-01-15", "2025-07-15")) }
@(test) test_short_y_m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2 yr, 1 mo", format_age(buf[:], &locale_en, .Short, "2023-06-15", "2025-07-15")) }
@(test) test_short_half :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3\u00BD yr", format_age(buf[:], &locale_en, .Short, "2022-06-15", "2025-12-15")) }
@(test) test_short_years :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "7 yr", format_age(buf[:], &locale_en, .Short, "2018-06-15", "2025-06-15")) }
@(test) test_short_born :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "Newborn", format_age(buf[:], &locale_en, .Short, "2025-06-15", "2025-06-15")) }
@(test) test_short_stage :: proc(t: ^testing.T) { expect_str(t, "Infant", format_stage(&locale_en, "2025-01-15", "2025-06-15", "")) }

// ================================================================
// Compactness: compact (27.1 - 27.8)
// ================================================================
@(test) test_compact_days :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3d", format_age(buf[:], &locale_en, .Compact, "2025-06-12", "2025-06-15")) }
@(test) test_compact_weeks :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1w", format_age(buf[:], &locale_en, .Compact, "2025-06-08", "2025-06-15")) }
@(test) test_compact_w_d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1w1d", format_age(buf[:], &locale_en, .Compact, "2025-06-07", "2025-06-15")) }
@(test) test_compact_months :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "6m", format_age(buf[:], &locale_en, .Compact, "2025-01-15", "2025-07-15")) }
@(test) test_compact_y_m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2y1m", format_age(buf[:], &locale_en, .Compact, "2023-06-15", "2025-07-15")) }
@(test) test_compact_half :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3\u00BDy", format_age(buf[:], &locale_en, .Compact, "2022-06-15", "2025-12-15")) }
@(test) test_compact_years :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "7y", format_age(buf[:], &locale_en, .Compact, "2018-06-15", "2025-06-15")) }
@(test) test_compact_born :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "Newborn", format_age(buf[:], &locale_en, .Compact, "2025-06-15", "2025-06-15")) }

// ================================================================
// Gender support (28.x)
// ================================================================
@(test) test_gender_en_neutral :: proc(t: ^testing.T) { expect_str(t, "Newborn", format_stage(&locale_en, "2025-06-15", "2025-06-15", "")) }
@(test) test_gender_en_m :: proc(t: ^testing.T) { expect_str(t, "Newborn", format_stage(&locale_en, "2025-06-15", "2025-06-15", "m")) }
@(test) test_gender_en_f :: proc(t: ^testing.T) { expect_str(t, "Newborn", format_stage(&locale_en, "2025-06-15", "2025-06-15", "f")) }
@(test) test_gender_en_adult :: proc(t: ^testing.T) { expect_str(t, "Adult", format_stage(&locale_en, "2007-06-15", "2025-06-15", "")) }
@(test) test_gender_en_adult_m :: proc(t: ^testing.T) { expect_str(t, "Adult", format_stage(&locale_en, "2007-06-15", "2025-06-15", "m")) }
@(test) test_gender_en_adult_f :: proc(t: ^testing.T) { expect_str(t, "Adult", format_stage(&locale_en, "2007-06-15", "2025-06-15", "f")) }
@(test) test_gender_es_newborn :: proc(t: ^testing.T) { expect_str(t, "Recién nacido", format_stage(&locale_es, "2025-06-15", "2025-06-15", "")) }
@(test) test_gender_es_newborn_f :: proc(t: ^testing.T) { expect_str(t, "Recién nacida", format_stage(&locale_es, "2025-06-15", "2025-06-15", "f")) }
@(test) test_gender_es_toddler :: proc(t: ^testing.T) { expect_str(t, "Niño pequeño", format_stage(&locale_es, "2024-06-15", "2025-06-15", "")) }
@(test) test_gender_es_toddler_f :: proc(t: ^testing.T) { expect_str(t, "Niña pequeña", format_stage(&locale_es, "2024-06-15", "2025-06-15", "f")) }
@(test) test_gender_es_child :: proc(t: ^testing.T) { expect_str(t, "Niño", format_stage(&locale_es, "2022-06-15", "2025-06-15", "")) }
@(test) test_gender_es_child_f :: proc(t: ^testing.T) { expect_str(t, "Niña", format_stage(&locale_es, "2022-06-15", "2025-06-15", "f")) }
@(test) test_gender_es_adult :: proc(t: ^testing.T) { expect_str(t, "Adulto", format_stage(&locale_es, "2007-06-15", "2025-06-15", "")) }
@(test) test_gender_es_adult_f :: proc(t: ^testing.T) { expect_str(t, "Adulta", format_stage(&locale_es, "2007-06-15", "2025-06-15", "f")) }
@(test) test_gender_es_infant_neutral :: proc(t: ^testing.T) { expect_str(t, "Bebé", format_stage(&locale_es, "2025-01-15", "2025-06-15", "")) }
@(test) test_gender_es_infant_f :: proc(t: ^testing.T) { expect_str(t, "Bebé", format_stage(&locale_es, "2025-01-15", "2025-06-15", "f")) }
@(test) test_gender_ar_newborn_m :: proc(t: ^testing.T) { expect_str(t, "حديث الولادة", format_stage(&locale_ar, "2025-06-15", "2025-06-15", "m")) }
@(test) test_gender_ar_newborn_f :: proc(t: ^testing.T) { expect_str(t, "حديثة الولادة", format_stage(&locale_ar, "2025-06-15", "2025-06-15", "f")) }
@(test) test_gender_ar_adult_m :: proc(t: ^testing.T) { expect_str(t, "بالغ", format_stage(&locale_ar, "2007-06-15", "2025-06-15", "m")) }
@(test) test_gender_ar_adult_f :: proc(t: ^testing.T) { expect_str(t, "بالغة", format_stage(&locale_ar, "2007-06-15", "2025-06-15", "f")) }
@(test) test_gender_edge_nil :: proc(t: ^testing.T) { expect_nil(t, format_stage(&locale_es, "", "2025-06-15", "f")) }

// ================================================================
// Section 29: Locale-specific edge cases
// ================================================================
@(test) test_he_born :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "רק נולד", format_age(buf[:], &locale_he, .Normal, "2025-06-15", "2025-06-15")) }
@(test) test_he_1d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "יום 1", format_age(buf[:], &locale_he, .Normal, "2025-06-14", "2025-06-15")) }
@(test) test_he_3d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 ימים", format_age(buf[:], &locale_he, .Normal, "2025-06-12", "2025-06-15")) }
@(test) test_he_2w :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "שבועיים", format_age(buf[:], &locale_he, .Normal, "2025-06-01", "2025-06-15")) }
@(test) test_he_3w :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 שבועות", format_age(buf[:], &locale_he, .Normal, "2025-05-25", "2025-06-15")) }
@(test) test_he_6m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "6 חודשים", format_age(buf[:], &locale_he, .Normal, "2025-01-15", "2025-07-15")) }
@(test) test_he_3m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 חודשים", format_age(buf[:], &locale_he, .Normal, "2025-03-15", "2025-06-15")) }
@(test) test_he_2y1m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "שנתיים, חודש 1", format_age(buf[:], &locale_he, .Normal, "2023-06-15", "2025-07-15")) }
@(test) test_he_half :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 שנים וחצי", format_age(buf[:], &locale_he, .Normal, "2022-06-15", "2025-12-15")) }
@(test) test_he_7y :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "7 שנים", format_age(buf[:], &locale_he, .Normal, "2018-06-15", "2025-06-15")) }
@(test) test_he_stage_m :: proc(t: ^testing.T) { expect_str(t, "רק נולד", format_stage(&locale_he, "2025-06-15", "2025-06-15", "m")) }
@(test) test_he_stage_f :: proc(t: ^testing.T) { expect_str(t, "רק נולדה", format_stage(&locale_he, "2025-06-15", "2025-06-15", "f")) }
@(test) test_he_adult_m :: proc(t: ^testing.T) { expect_str(t, "מבוגר", format_stage(&locale_he, "2007-06-15", "2025-06-15", "m")) }
@(test) test_he_adult_f :: proc(t: ^testing.T) { expect_str(t, "מבוגרת", format_stage(&locale_he, "2007-06-15", "2025-06-15", "f")) }

@(test) test_mk_born :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "Новороденче", format_age(buf[:], &locale_mk, .Normal, "2025-06-15", "2025-06-15")) }
@(test) test_mk_1d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 ден", format_age(buf[:], &locale_mk, .Normal, "2025-06-14", "2025-06-15")) }
@(test) test_mk_3d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 дена", format_age(buf[:], &locale_mk, .Normal, "2025-06-12", "2025-06-15")) }
@(test) test_mk_6m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "6 месеци", format_age(buf[:], &locale_mk, .Normal, "2025-01-15", "2025-07-15")) }
@(test) test_mk_2y1m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "2 години, 1 месец", format_age(buf[:], &locale_mk, .Normal, "2023-06-15", "2025-07-15")) }
@(test) test_mk_half :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 години и пол", format_age(buf[:], &locale_mk, .Normal, "2022-06-15", "2025-12-15")) }
@(test) test_mk_7y :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "7 години", format_age(buf[:], &locale_mk, .Normal, "2018-06-15", "2025-06-15")) }

@(test) test_sw_born :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "Mzaliwa mpya", format_age(buf[:], &locale_sw, .Normal, "2025-06-15", "2025-06-15")) }
@(test) test_sw_1d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "siku 1", format_age(buf[:], &locale_sw, .Normal, "2025-06-14", "2025-06-15")) }
@(test) test_sw_3d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "siku 3", format_age(buf[:], &locale_sw, .Normal, "2025-06-12", "2025-06-15")) }
@(test) test_sw_6m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "miezi 6", format_age(buf[:], &locale_sw, .Normal, "2025-01-15", "2025-07-15")) }
@(test) test_sw_2y1m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "miaka 2, mwezi 1", format_age(buf[:], &locale_sw, .Normal, "2023-06-15", "2025-07-15")) }
@(test) test_sw_half :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "miaka 3 na nusu", format_age(buf[:], &locale_sw, .Normal, "2022-06-15", "2025-12-15")) }

@(test) test_id_born :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "Baru lahir", format_age(buf[:], &locale_id, .Normal, "2025-06-15", "2025-06-15")) }
@(test) test_id_1d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 hari", format_age(buf[:], &locale_id, .Normal, "2025-06-14", "2025-06-15")) }
@(test) test_id_3d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 hari", format_age(buf[:], &locale_id, .Normal, "2025-06-12", "2025-06-15")) }
@(test) test_id_6m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "6 bulan", format_age(buf[:], &locale_id, .Normal, "2025-01-15", "2025-07-15")) }
@(test) test_id_half :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 tahun setengah", format_age(buf[:], &locale_id, .Normal, "2022-06-15", "2025-12-15")) }
@(test) test_id_7y :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "7 tahun", format_age(buf[:], &locale_id, .Normal, "2018-06-15", "2025-06-15")) }

@(test) test_am_born :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "አዲስ የተወለደ", format_age(buf[:], &locale_am, .Normal, "2025-06-15", "2025-06-15")) }
@(test) test_am_1d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 ቀን", format_age(buf[:], &locale_am, .Normal, "2025-06-14", "2025-06-15")) }
@(test) test_am_3d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 ቀናት", format_age(buf[:], &locale_am, .Normal, "2025-06-12", "2025-06-15")) }
@(test) test_am_1w1d :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "1 ሳምንት፣ 1 ቀን", format_age(buf[:], &locale_am, .Normal, "2025-06-07", "2025-06-15")) }
@(test) test_am_6m :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "6 ወራት", format_age(buf[:], &locale_am, .Normal, "2025-01-15", "2025-07-15")) }
@(test) test_am_half :: proc(t: ^testing.T) { buf: [256]u8; expect_str(t, "3 ዓመታት ተኩል", format_age(buf[:], &locale_am, .Normal, "2022-06-15", "2025-12-15")) }

// ================================================================
// Section 30: Locale lookup
// ================================================================
@(test) test_get_locale_en :: proc(t: ^testing.T) { loc := get_locale("en"); testing.expect(t, loc != nil); if loc != nil do testing.expect_value(t, loc.code, "en") }
@(test) test_get_locale_fr :: proc(t: ^testing.T) { loc := get_locale("fr"); testing.expect(t, loc != nil); if loc != nil do testing.expect_value(t, loc.code, "fr") }
@(test) test_get_locale_unknown :: proc(t: ^testing.T) { testing.expect(t, get_locale("xx") == nil) }
@(test) test_get_locale_empty :: proc(t: ^testing.T) { testing.expect(t, get_locale("") == nil) }
@(test) test_get_locale_case :: proc(t: ^testing.T) { testing.expect(t, get_locale("EN") == nil) }
