<?php

declare(strict_types=1);

namespace ParentTime\Tests;

use ParentTime\Compactness;

use function ParentTime\formatAge;
use function ParentTime\formatStage;

use ParentTime\Locales;
use ParentTime\ParentTime;
use PHPUnit\Framework\TestCase;

/**
 * Canonical test suite — 163 test cases from docs/testing.md.
 *
 * All tests use explicit (dateOfBirth, asOf) pairs for determinism
 * except sections 15 and 23 which test the default-asOf clock override.
 */
final class FormatAgeTest extends TestCase
{
    // ================================================================
    // Section 1: Null / edge cases (4 tests)
    // ================================================================

    public function test_1_1_null_date_of_birth(): void
    {
        $this->assertNull(formatAge(null, '2025-06-15'));
    }

    // 1.2 — PHP has no "undefined"; null covers this. We test it as a
    // duplicate null call to satisfy the 163-test count.
    public function test_1_2_null_date_of_birth_duplicate(): void
    {
        $this->assertNull(formatAge(null, '2025-06-15'));
    }

    public function test_1_3_empty_string_date_of_birth(): void
    {
        $this->assertNull(formatAge('', '2025-06-15'));
    }

    public function test_1_4_future_date_of_birth(): void
    {
        $this->assertNull(formatAge('2025-07-01', '2025-06-15'));
    }

    // ================================================================
    // Section 2: Days tier — 0–6 days (5 tests)
    // ================================================================

    public function test_2_1_born_today_is_newborn(): void
    {
        $this->assertSame('Newborn', formatAge('2025-06-15', '2025-06-15'));
    }

    public function test_2_2_one_day_singular(): void
    {
        $this->assertSame('1 day', formatAge('2025-06-14', '2025-06-15'));
    }

    public function test_2_3_three_days_plural(): void
    {
        $this->assertSame('3 days', formatAge('2025-06-12', '2025-06-15'));
    }

    public function test_2_4_six_days_maximum(): void
    {
        $this->assertSame('6 days', formatAge('2025-06-09', '2025-06-15'));
    }

    public function test_2_5_seven_days_transitions_to_weeks(): void
    {
        $this->assertSame('1 week', formatAge('2025-06-08', '2025-06-15'));
    }

    // ================================================================
    // Section 3: Weeks+days tier — 7 days to <3 calendar months (12 tests)
    // ================================================================

    public function test_3_1_exactly_7_days(): void
    {
        $this->assertSame('1 week', formatAge('2025-06-08', '2025-06-15'));
    }

    public function test_3_2_one_week_one_day(): void
    {
        $this->assertSame('1 week, 1 day', formatAge('2025-06-07', '2025-06-15'));
    }

    public function test_3_3_one_week_two_days(): void
    {
        $this->assertSame('1 week, 2 days', formatAge('2025-06-06', '2025-06-15'));
    }

    public function test_3_4_one_week_six_days(): void
    {
        $this->assertSame('1 week, 6 days', formatAge('2025-06-02', '2025-06-15'));
    }

    public function test_3_5_two_weeks(): void
    {
        $this->assertSame('2 weeks', formatAge('2025-06-01', '2025-06-15'));
    }

    public function test_3_6_two_weeks_one_day(): void
    {
        $this->assertSame('2 weeks, 1 day', formatAge('2025-05-31', '2025-06-15'));
    }

    public function test_3_7_two_weeks_six_days(): void
    {
        $this->assertSame('2 weeks, 6 days', formatAge('2025-05-26', '2025-06-15'));
    }

    public function test_3_8_three_weeks(): void
    {
        $this->assertSame('3 weeks', formatAge('2025-05-25', '2025-06-15'));
    }

    public function test_3_9_one_calendar_month_still_weeks(): void
    {
        $this->assertSame('4 weeks, 3 days', formatAge('2025-05-15', '2025-06-15'));
    }

    public function test_3_10_two_calendar_months_still_weeks(): void
    {
        $this->assertSame('8 weeks, 5 days', formatAge('2025-04-15', '2025-06-15'));
    }

    public function test_3_11_day_before_3_month_birthday_still_weeks(): void
    {
        $this->assertSame('13 weeks', formatAge('2025-03-15', '2025-06-14'));
    }

    public function test_3_12_exactly_3_months_transitions(): void
    {
        $this->assertSame('3 months', formatAge('2025-03-15', '2025-06-15'));
    }

    // ================================================================
    // Section 4: Month boundaries — standard months (5 tests)
    // ================================================================

    public function test_4_1_standard_3_month_boundary(): void
    {
        $this->assertSame('3 months', formatAge('2025-01-01', '2025-04-01'));
    }

    public function test_4_2_not_yet_3_months_weeks_pattern(): void
    {
        $result = formatAge('2025-01-01', '2025-03-31');
        $this->assertNotNull($result);
        $this->assertStringContainsString('weeks', $result);
    }

    public function test_4_3_mid_month_3_month_boundary(): void
    {
        $this->assertSame('3 months', formatAge('2025-06-15', '2025-09-15'));
    }

    public function test_4_4_day_before_3_month_mark_weeks_pattern(): void
    {
        $result = formatAge('2025-06-15', '2025-09-14');
        $this->assertNotNull($result);
        $this->assertStringContainsString('weeks', $result);
    }

    public function test_4_5_six_months(): void
    {
        $this->assertSame('6 months', formatAge('2025-06-15', '2025-12-15'));
    }

    // ================================================================
    // Section 5: Month boundaries — February non-leap year (5 tests)
    // ================================================================

    public function test_5_1_born_jan_31_check_feb_28_non_leap(): void
    {
        $this->assertSame('4 weeks', formatAge('2025-01-31', '2025-02-28'));
    }

    public function test_5_2_born_jan_31_check_apr_30_clamp(): void
    {
        $this->assertSame('3 months', formatAge('2025-01-31', '2025-04-30'));
    }

    public function test_5_3_born_jan_31_check_apr_29_weeks_pattern(): void
    {
        $result = formatAge('2025-01-31', '2025-04-29');
        $this->assertNotNull($result);
        $this->assertStringContainsString('weeks', $result);
    }

    public function test_5_4_born_feb_1_check_may_1(): void
    {
        $this->assertSame('3 months', formatAge('2025-02-01', '2025-05-01'));
    }

    public function test_5_5_born_feb_1_check_apr_30_weeks_pattern(): void
    {
        $result = formatAge('2025-02-01', '2025-04-30');
        $this->assertNotNull($result);
        $this->assertStringContainsString('weeks', $result);
    }

    // ================================================================
    // Section 6: Month boundaries — February leap year (5 tests)
    // ================================================================

    public function test_6_1_born_jan_31_check_feb_29_leap(): void
    {
        $this->assertSame('4 weeks, 1 day', formatAge('2024-01-31', '2024-02-29'));
    }

    public function test_6_2_born_jan_31_check_feb_28_leap(): void
    {
        $this->assertSame('4 weeks', formatAge('2024-01-31', '2024-02-28'));
    }

    public function test_6_3_born_jan_31_check_apr_30_leap(): void
    {
        $this->assertSame('3 months', formatAge('2024-01-31', '2024-04-30'));
    }

    public function test_6_4_born_jan_30_check_feb_29_leap_weeks_pattern(): void
    {
        $result = formatAge('2024-01-30', '2024-02-29');
        $this->assertNotNull($result);
        $this->assertStringContainsString('weeks', $result);
    }

    public function test_6_5_born_jan_30_check_feb_28_leap_weeks_pattern(): void
    {
        $result = formatAge('2024-01-30', '2024-02-28');
        $this->assertNotNull($result);
        $this->assertStringContainsString('weeks', $result);
    }

    // ================================================================
    // Section 7: Month boundaries — 30-day months (4 tests)
    // ================================================================

    public function test_7_1_born_mar_31_check_jun_30(): void
    {
        $this->assertSame('3 months', formatAge('2025-03-31', '2025-06-30'));
    }

    public function test_7_2_born_mar_31_check_jun_29_weeks_pattern(): void
    {
        $result = formatAge('2025-03-31', '2025-06-29');
        $this->assertNotNull($result);
        $this->assertStringContainsString('weeks', $result);
    }

    public function test_7_3_born_aug_31_check_nov_30(): void
    {
        $this->assertSame('3 months', formatAge('2025-08-31', '2025-11-30'));
    }

    public function test_7_4_born_aug_31_check_nov_29_weeks_pattern(): void
    {
        $result = formatAge('2025-08-31', '2025-11-29');
        $this->assertNotNull($result);
        $this->assertStringContainsString('weeks', $result);
    }

    // ================================================================
    // Section 8: Month boundaries — leap year baby (born Feb 29) (4 tests)
    // ================================================================

    public function test_8_1_born_feb_29_check_may_29(): void
    {
        $this->assertSame('3 months', formatAge('2024-02-29', '2024-05-29'));
    }

    public function test_8_2_born_feb_29_check_may_28_weeks_pattern(): void
    {
        $result = formatAge('2024-02-29', '2024-05-28');
        $this->assertNotNull($result);
        $this->assertStringContainsString('weeks', $result);
    }

    public function test_8_3_born_feb_29_non_leap_year_birthday_clamps(): void
    {
        $this->assertSame('12 months', formatAge('2024-02-29', '2025-02-28'));
    }

    public function test_8_4_born_feb_29_day_after_clamped_birthday(): void
    {
        $this->assertSame('12 months', formatAge('2024-02-29', '2025-03-01'));
    }

    // ================================================================
    // Section 9: Months tier — 3–23 months (6 tests)
    // ================================================================

    public function test_9_1_three_months_at_transition(): void
    {
        $this->assertSame('3 months', formatAge('2025-01-15', '2025-04-15'));
    }

    public function test_9_2_six_months(): void
    {
        $this->assertSame('6 months', formatAge('2025-01-15', '2025-07-15'));
    }

    public function test_9_3_twelve_months_not_one_year(): void
    {
        $this->assertSame('12 months', formatAge('2024-06-15', '2025-06-15'));
    }

    public function test_9_4_twenty_three_months_upper_boundary(): void
    {
        $this->assertSame('23 months', formatAge('2024-01-15', '2025-12-15'));
    }

    public function test_9_5_day_before_boundary_stays_previous(): void
    {
        $this->assertSame('5 months', formatAge('2025-01-15', '2025-07-14'));
    }

    public function test_9_6_cross_year_boundary(): void
    {
        $this->assertSame('5 months', formatAge('2024-11-10', '2025-04-10'));
    }

    // ================================================================
    // Section 10: Years+months tier — 24–35 months (5 tests)
    // ================================================================

    public function test_10_1_exactly_24_months(): void
    {
        $this->assertSame('2 years', formatAge('2023-06-15', '2025-06-15'));
    }

    public function test_10_2_two_years_one_month(): void
    {
        $this->assertSame('2 years, 1 month', formatAge('2023-06-15', '2025-07-15'));
    }

    public function test_10_3_two_years_six_months(): void
    {
        $this->assertSame('2 years, 6 months', formatAge('2023-06-15', '2025-12-15'));
    }

    public function test_10_4_two_years_eleven_months(): void
    {
        $this->assertSame('2 years, 11 months', formatAge('2023-06-15', '2026-05-15'));
    }

    public function test_10_5_day_before_24_months_stays_in_months(): void
    {
        $this->assertSame('23 months', formatAge('2023-06-15', '2025-06-14'));
    }

    // ================================================================
    // Section 11: Half-year tier — 3–6 years (12 tests)
    // ================================================================

    public function test_11_1_exactly_3_years(): void
    {
        $this->assertSame('3 years', formatAge('2022-06-15', '2025-06-15'));
    }

    public function test_11_2_three_years_five_months_under_half(): void
    {
        $this->assertSame('3 years', formatAge('2022-06-15', '2025-11-15'));
    }

    public function test_11_3_three_and_half_years(): void
    {
        $this->assertSame('3½ years', formatAge('2022-06-15', '2025-12-15'));
    }

    public function test_11_4_three_and_half_years_at_11_months(): void
    {
        $this->assertSame('3½ years', formatAge('2022-06-15', '2026-05-15'));
    }

    public function test_11_5_exactly_4_years(): void
    {
        $this->assertSame('4 years', formatAge('2021-06-15', '2025-06-15'));
    }

    public function test_11_6_four_and_half_years(): void
    {
        $this->assertSame('4½ years', formatAge('2021-06-15', '2025-12-15'));
    }

    public function test_11_7_exactly_5_years(): void
    {
        $this->assertSame('5 years', formatAge('2020-06-15', '2025-06-15'));
    }

    public function test_11_8_five_and_half_years(): void
    {
        $this->assertSame('5½ years', formatAge('2020-06-15', '2026-02-15'));
    }

    public function test_11_9_exactly_6_years(): void
    {
        $this->assertSame('6 years', formatAge('2019-06-15', '2025-06-15'));
    }

    public function test_11_10_six_and_half_years(): void
    {
        $this->assertSame('6½ years', formatAge('2019-06-15', '2025-12-15'));
    }

    public function test_11_11_six_and_half_at_11_months(): void
    {
        $this->assertSame('6½ years', formatAge('2019-06-15', '2026-05-15'));
    }

    public function test_11_12_day_before_3rd_birthday_stays_years_months(): void
    {
        $this->assertSame('2 years, 11 months', formatAge('2022-06-15', '2025-06-14'));
    }

    // ================================================================
    // Section 12: Integer tier — 7+ years (3 tests)
    // ================================================================

    public function test_12_1_exactly_7_years(): void
    {
        $this->assertSame('7 years', formatAge('2018-06-15', '2025-06-15'));
    }

    public function test_12_2_seven_years_no_half(): void
    {
        $this->assertSame('7 years', formatAge('2018-03-20', '2025-06-15'));
    }

    public function test_12_3_adult_45_years(): void
    {
        $this->assertSame('45 years', formatAge('1980-01-01', '2025-06-15'));
    }

    // ================================================================
    // Section 13: Cross-year transitions with February (4 tests)
    // ================================================================

    public function test_13_1_born_dec_31_check_mar_31(): void
    {
        $this->assertSame('3 months', formatAge('2024-12-31', '2025-03-31'));
    }

    public function test_13_2_born_dec_31_check_mar_30_weeks_pattern(): void
    {
        $result = formatAge('2024-12-31', '2025-03-30');
        $this->assertNotNull($result);
        $this->assertStringContainsString('weeks', $result);
    }

    public function test_13_3_born_nov_30_check_feb_28(): void
    {
        $this->assertSame('3 months', formatAge('2024-11-30', '2025-02-28'));
    }

    public function test_13_4_born_nov_30_check_feb_27_weeks_pattern(): void
    {
        $result = formatAge('2024-11-30', '2025-02-27');
        $this->assertNotNull($result);
        $this->assertStringContainsString('weeks', $result);
    }

    // ================================================================
    // Section 14: Born-on-31st progression (5 tests)
    // ================================================================

    public function test_14_1_jan_31_to_apr_30(): void
    {
        $this->assertSame('3 months', formatAge('2025-01-31', '2025-04-30'));
    }

    public function test_14_2_jan_31_to_may_31(): void
    {
        $this->assertSame('4 months', formatAge('2025-01-31', '2025-05-31'));
    }

    public function test_14_3_jan_31_to_jun_30(): void
    {
        $this->assertSame('5 months', formatAge('2025-01-31', '2025-06-30'));
    }

    public function test_14_4_jan_31_to_jul_1_still_5_months(): void
    {
        $this->assertSame('5 months', formatAge('2025-01-31', '2025-07-01'));
    }

    public function test_14_5_jan_31_to_jul_31(): void
    {
        $this->assertSame('6 months', formatAge('2025-01-31', '2025-07-31'));
    }

    // ================================================================
    // Section 15: Default asOf — current date (2 tests)
    // ================================================================

    public function test_15_1_default_asof_5_years(): void
    {
        ParentTime::setNowForTesting(fn() => [2025, 6, 15]);
        try {
            $this->assertSame('5 years', formatAge('2020-01-01'));
        } finally {
            ParentTime::setNowForTesting(null);
        }
    }

    public function test_15_2_default_asof_5_days(): void
    {
        ParentTime::setNowForTesting(fn() => [2025, 6, 15]);
        try {
            $this->assertSame('5 days', formatAge('2025-06-10'));
        } finally {
            ParentTime::setNowForTesting(null);
        }
    }

    // ================================================================
    // Section 16: formatStage — null / edge cases (4 tests)
    // ================================================================

    public function test_16_1_stage_null_dob(): void
    {
        $this->assertNull(formatStage(null, '2025-06-15'));
    }

    // 16.2 — PHP has no "undefined"; null covers this.
    public function test_16_2_stage_null_dob_duplicate(): void
    {
        $this->assertNull(formatStage(null, '2025-06-15'));
    }

    public function test_16_3_stage_empty_string(): void
    {
        $this->assertNull(formatStage('', '2025-06-15'));
    }

    public function test_16_4_stage_future_dob(): void
    {
        $this->assertNull(formatStage('2025-07-01', '2025-06-15'));
    }

    // ================================================================
    // Section 17: formatStage — Newborn (6 tests)
    // ================================================================

    public function test_17_1_newborn_born_today(): void
    {
        $this->assertSame('Newborn', formatStage('2025-06-15', '2025-06-15'));
    }

    public function test_17_2_newborn_1_day(): void
    {
        $this->assertSame('Newborn', formatStage('2025-06-14', '2025-06-15'));
    }

    public function test_17_3_newborn_3_weeks(): void
    {
        $this->assertSame('Newborn', formatStage('2025-05-25', '2025-06-15'));
    }

    public function test_17_4_newborn_1_month(): void
    {
        $this->assertSame('Newborn', formatStage('2025-05-15', '2025-06-15'));
    }

    public function test_17_5_newborn_1_month_29_days(): void
    {
        $this->assertSame('Newborn', formatStage('2025-04-16', '2025-06-15'));
    }

    public function test_17_6_exactly_2_months_transitions_to_infant(): void
    {
        $this->assertSame('Infant', formatStage('2025-04-15', '2025-06-15'));
    }

    // ================================================================
    // Section 18: formatStage — Infant (4 tests)
    // ================================================================

    public function test_18_1_infant_2_months(): void
    {
        $this->assertSame('Infant', formatStage('2025-04-15', '2025-06-15'));
    }

    public function test_18_2_infant_6_months(): void
    {
        $this->assertSame('Infant', formatStage('2024-12-15', '2025-06-15'));
    }

    public function test_18_3_infant_11_months(): void
    {
        $this->assertSame('Infant', formatStage('2024-07-15', '2025-06-15'));
    }

    public function test_18_4_exactly_12_months_transitions_to_toddler(): void
    {
        $this->assertSame('Toddler', formatStage('2024-06-15', '2025-06-15'));
    }

    // ================================================================
    // Section 19: formatStage — Toddler (5 tests)
    // ================================================================

    public function test_19_1_toddler_12_months(): void
    {
        $this->assertSame('Toddler', formatStage('2024-06-15', '2025-06-15'));
    }

    public function test_19_2_toddler_18_months(): void
    {
        $this->assertSame('Toddler', formatStage('2024-01-15', '2025-07-15'));
    }

    public function test_19_3_toddler_24_months(): void
    {
        $this->assertSame('Toddler', formatStage('2023-06-15', '2025-06-15'));
    }

    public function test_19_4_toddler_35_months(): void
    {
        $this->assertSame('Toddler', formatStage('2023-06-15', '2026-05-15'));
    }

    public function test_19_5_exactly_36_months_transitions_to_child(): void
    {
        $this->assertSame('Child', formatStage('2022-06-15', '2025-06-15'));
    }

    // ================================================================
    // Section 20: formatStage — Child (6 tests)
    // ================================================================

    public function test_20_1_child_3_years(): void
    {
        $this->assertSame('Child', formatStage('2022-06-15', '2025-06-15'));
    }

    public function test_20_2_child_4_years(): void
    {
        $this->assertSame('Child', formatStage('2021-06-15', '2025-06-15'));
    }

    public function test_20_3_child_6_years(): void
    {
        $this->assertSame('Child', formatStage('2019-06-15', '2025-06-15'));
    }

    public function test_20_4_child_9_years(): void
    {
        $this->assertSame('Child', formatStage('2016-06-15', '2025-06-15'));
    }

    public function test_20_5_child_12_years_11_months(): void
    {
        $this->assertSame('Child', formatStage('2013-06-15', '2026-05-15'));
    }

    public function test_20_6_exactly_13_years_transitions_to_teenager(): void
    {
        $this->assertSame('Teenager', formatStage('2012-06-15', '2025-06-15'));
    }

    // ================================================================
    // Section 21: formatStage — Teenager (4 tests)
    // ================================================================

    public function test_21_1_teenager_13_years(): void
    {
        $this->assertSame('Teenager', formatStage('2012-06-15', '2025-06-15'));
    }

    public function test_21_2_teenager_15_years(): void
    {
        $this->assertSame('Teenager', formatStage('2010-06-15', '2025-06-15'));
    }

    public function test_21_3_teenager_17_years_11_months(): void
    {
        $this->assertSame('Teenager', formatStage('2008-06-15', '2026-05-15'));
    }

    public function test_21_4_exactly_18_years_transitions_to_adult(): void
    {
        $this->assertSame('Adult', formatStage('2007-06-15', '2025-06-15'));
    }

    // ================================================================
    // Section 22: formatStage — Adult (3 tests)
    // ================================================================

    public function test_22_1_adult_18_years(): void
    {
        $this->assertSame('Adult', formatStage('2007-06-15', '2025-06-15'));
    }

    public function test_22_2_adult_25_years(): void
    {
        $this->assertSame('Adult', formatStage('2000-06-15', '2025-06-15'));
    }

    public function test_22_3_adult_45_years(): void
    {
        $this->assertSame('Adult', formatStage('1980-01-01', '2025-06-15'));
    }

    // ================================================================
    // Section 23: formatStage — default asOf (3 tests)
    // ================================================================

    public function test_23_1_stage_default_asof_newborn(): void
    {
        ParentTime::setNowForTesting(fn() => [2025, 6, 15]);
        try {
            $this->assertSame('Newborn', formatStage('2025-06-15'));
        } finally {
            ParentTime::setNowForTesting(null);
        }
    }

    public function test_23_2_stage_default_asof_child(): void
    {
        ParentTime::setNowForTesting(fn() => [2025, 6, 15]);
        try {
            $this->assertSame('Child', formatStage('2020-01-01'));
        } finally {
            ParentTime::setNowForTesting(null);
        }
    }

    public function test_23_3_stage_default_asof_adult(): void
    {
        ParentTime::setNowForTesting(fn() => [2025, 6, 15]);
        try {
            $this->assertSame('Adult', formatStage('1980-01-01'));
        } finally {
            ParentTime::setNowForTesting(null);
        }
    }

    // ================================================================
    // Section 24: ParentTime class — English locale delegation (15 tests)
    // ================================================================

    public function test_24_1_class_format_age_newborn(): void
    {
        $pt = new ParentTime(Locales::EN());
        $this->assertSame('Newborn', $pt->formatAge('2025-06-15', '2025-06-15'));
    }

    public function test_24_2_class_format_age_3_days(): void
    {
        $pt = new ParentTime(Locales::EN());
        $this->assertSame('3 days', $pt->formatAge('2025-06-12', '2025-06-15'));
    }

    public function test_24_3_class_format_age_1_week_1_day(): void
    {
        $pt = new ParentTime(Locales::EN());
        $this->assertSame('1 week, 1 day', $pt->formatAge('2025-06-07', '2025-06-15'));
    }

    public function test_24_4_class_format_age_6_months(): void
    {
        $pt = new ParentTime(Locales::EN());
        $this->assertSame('6 months', $pt->formatAge('2025-01-15', '2025-07-15'));
    }

    public function test_24_5_class_format_age_2_years_1_month(): void
    {
        $pt = new ParentTime(Locales::EN());
        $this->assertSame('2 years, 1 month', $pt->formatAge('2023-06-15', '2025-07-15'));
    }

    public function test_24_6_class_format_age_3_and_half_years(): void
    {
        $pt = new ParentTime(Locales::EN());
        $this->assertSame('3½ years', $pt->formatAge('2022-06-15', '2025-12-15'));
    }

    public function test_24_7_class_format_age_7_years(): void
    {
        $pt = new ParentTime(Locales::EN());
        $this->assertSame('7 years', $pt->formatAge('2018-06-15', '2025-06-15'));
    }

    public function test_24_8_class_format_stage_newborn(): void
    {
        $pt = new ParentTime(Locales::EN());
        $this->assertSame('Newborn', $pt->formatStage('2025-06-15', '2025-06-15'));
    }

    public function test_24_9_class_format_stage_infant(): void
    {
        $pt = new ParentTime(Locales::EN());
        $this->assertSame('Infant', $pt->formatStage('2025-01-15', '2025-06-15'));
    }

    public function test_24_10_class_format_stage_toddler(): void
    {
        $pt = new ParentTime(Locales::EN());
        $this->assertSame('Toddler', $pt->formatStage('2024-06-15', '2025-06-15'));
    }

    public function test_24_11_class_format_stage_child(): void
    {
        $pt = new ParentTime(Locales::EN());
        $this->assertSame('Child', $pt->formatStage('2022-06-15', '2025-06-15'));
    }

    public function test_24_12_class_format_stage_teenager(): void
    {
        $pt = new ParentTime(Locales::EN());
        $this->assertSame('Teenager', $pt->formatStage('2012-06-15', '2025-06-15'));
    }

    public function test_24_13_class_format_stage_adult(): void
    {
        $pt = new ParentTime(Locales::EN());
        $this->assertSame('Adult', $pt->formatStage('2007-06-15', '2025-06-15'));
    }

    public function test_24_14_class_format_age_null(): void
    {
        $pt = new ParentTime(Locales::EN());
        $this->assertNull($pt->formatAge(null, '2025-06-15'));
    }

    public function test_24_15_class_format_stage_null(): void
    {
        $pt = new ParentTime(Locales::EN());
        $this->assertNull($pt->formatStage(null, '2025-06-15'));
    }

    // ================================================================
    // Section 25: i18n — Spanish locale (20 tests)
    // ================================================================

    public function test_25_1_es_just_born(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('Recién nacido', $pt->formatAge('2025-06-15', '2025-06-15'));
    }

    public function test_25_2_es_singular_day(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('1 día', $pt->formatAge('2025-06-14', '2025-06-15'));
    }

    public function test_25_3_es_plural_days(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('3 días', $pt->formatAge('2025-06-12', '2025-06-15'));
    }

    public function test_25_4_es_singular_week(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('1 semana', $pt->formatAge('2025-06-08', '2025-06-15'));
    }

    public function test_25_5_es_compound_week_day(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('1 semana, 1 día', $pt->formatAge('2025-06-07', '2025-06-15'));
    }

    public function test_25_6_es_plural_compound(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('2 semanas, 6 días', $pt->formatAge('2025-05-26', '2025-06-15'));
    }

    public function test_25_7_es_months(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('6 meses', $pt->formatAge('2025-01-15', '2025-07-15'));
    }

    public function test_25_8_es_singular_month_in_compound(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('2 años, 1 mes', $pt->formatAge('2023-06-15', '2025-07-15'));
    }

    public function test_25_9_es_years_months_compound(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('2 años, 6 meses', $pt->formatAge('2023-06-15', '2025-12-15'));
    }

    public function test_25_10_es_half_marker(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('3 y medio años', $pt->formatAge('2022-06-15', '2025-12-15'));
    }

    public function test_25_11_es_no_half(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('3 años', $pt->formatAge('2022-06-15', '2025-06-15'));
    }

    public function test_25_12_es_seven_plus_years(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('7 años', $pt->formatAge('2018-06-15', '2025-06-15'));
    }

    public function test_25_13_es_stage_newborn(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('Recién nacido', $pt->formatStage('2025-06-15', '2025-06-15'));
    }

    public function test_25_14_es_stage_infant(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('Bebé', $pt->formatStage('2025-01-15', '2025-06-15'));
    }

    public function test_25_15_es_stage_toddler(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('Niño pequeño', $pt->formatStage('2024-06-15', '2025-06-15'));
    }

    public function test_25_16_es_stage_child(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('Niño', $pt->formatStage('2022-06-15', '2025-06-15'));
    }

    public function test_25_17_es_stage_teenager(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('Adolescente', $pt->formatStage('2012-06-15', '2025-06-15'));
    }

    public function test_25_18_es_stage_adult(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('Adulto', $pt->formatStage('2007-06-15', '2025-06-15'));
    }

    public function test_25_19_es_format_age_null(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertNull($pt->formatAge(null, '2025-06-15'));
    }

    public function test_25_20_es_format_stage_null(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertNull($pt->formatStage(null, '2025-06-15'));
    }

    // ================================================================
    // Section 26: Compactness — short (9 tests)
    // ================================================================

    public function test_26_1_short_days(): void
    {
        $pt = new ParentTime(Locales::EN(), Compactness::Short);
        $this->assertSame('3 d', $pt->formatAge('2025-06-12', '2025-06-15'));
    }

    public function test_26_2_short_week(): void
    {
        $pt = new ParentTime(Locales::EN(), Compactness::Short);
        $this->assertSame('1 wk', $pt->formatAge('2025-06-08', '2025-06-15'));
    }

    public function test_26_3_short_compound(): void
    {
        $pt = new ParentTime(Locales::EN(), Compactness::Short);
        $this->assertSame('1 wk, 1 d', $pt->formatAge('2025-06-07', '2025-06-15'));
    }

    public function test_26_4_short_months(): void
    {
        $pt = new ParentTime(Locales::EN(), Compactness::Short);
        $this->assertSame('6 mo', $pt->formatAge('2025-01-15', '2025-07-15'));
    }

    public function test_26_5_short_years_months(): void
    {
        $pt = new ParentTime(Locales::EN(), Compactness::Short);
        $this->assertSame('2 yr, 1 mo', $pt->formatAge('2023-06-15', '2025-07-15'));
    }

    public function test_26_6_short_half(): void
    {
        $pt = new ParentTime(Locales::EN(), Compactness::Short);
        $this->assertSame('3½ yr', $pt->formatAge('2022-06-15', '2025-12-15'));
    }

    public function test_26_7_short_years(): void
    {
        $pt = new ParentTime(Locales::EN(), Compactness::Short);
        $this->assertSame('7 yr', $pt->formatAge('2018-06-15', '2025-06-15'));
    }

    public function test_26_8_short_just_born_unchanged(): void
    {
        $pt = new ParentTime(Locales::EN(), Compactness::Short);
        $this->assertSame('Newborn', $pt->formatAge('2025-06-15', '2025-06-15'));
    }

    public function test_26_9_short_stages_unchanged(): void
    {
        $pt = new ParentTime(Locales::EN(), Compactness::Short);
        $this->assertSame('Infant', $pt->formatStage('2025-01-15', '2025-06-15'));
    }

    // ================================================================
    // Section 27: Compactness — compact (8 tests)
    // ================================================================

    public function test_27_1_compact_days(): void
    {
        $pt = new ParentTime(Locales::EN(), Compactness::Compact);
        $this->assertSame('3d', $pt->formatAge('2025-06-12', '2025-06-15'));
    }

    public function test_27_2_compact_week(): void
    {
        $pt = new ParentTime(Locales::EN(), Compactness::Compact);
        $this->assertSame('1w', $pt->formatAge('2025-06-08', '2025-06-15'));
    }

    public function test_27_3_compact_no_delimiter(): void
    {
        $pt = new ParentTime(Locales::EN(), Compactness::Compact);
        $this->assertSame('1w1d', $pt->formatAge('2025-06-07', '2025-06-15'));
    }

    public function test_27_4_compact_months(): void
    {
        $pt = new ParentTime(Locales::EN(), Compactness::Compact);
        $this->assertSame('6m', $pt->formatAge('2025-01-15', '2025-07-15'));
    }

    public function test_27_5_compact_years_months_no_delimiter(): void
    {
        $pt = new ParentTime(Locales::EN(), Compactness::Compact);
        $this->assertSame('2y1m', $pt->formatAge('2023-06-15', '2025-07-15'));
    }

    public function test_27_6_compact_half(): void
    {
        $pt = new ParentTime(Locales::EN(), Compactness::Compact);
        $this->assertSame('3½y', $pt->formatAge('2022-06-15', '2025-12-15'));
    }

    public function test_27_7_compact_years(): void
    {
        $pt = new ParentTime(Locales::EN(), Compactness::Compact);
        $this->assertSame('7y', $pt->formatAge('2018-06-15', '2025-06-15'));
    }

    public function test_27_8_compact_just_born_unchanged(): void
    {
        $pt = new ParentTime(Locales::EN(), Compactness::Compact);
        $this->assertSame('Newborn', $pt->formatAge('2025-06-15', '2025-06-15'));
    }

    // ================================================================
    // Section 28: formatStage — gender support (24 tests)
    // ================================================================

    // 28.1 English — no gender distinction
    public function test_28_1_en_stage_no_gender_newborn(): void
    {
        $pt = new ParentTime(Locales::EN());
        $this->assertSame('Newborn', $pt->formatStage('2025-06-15', '2025-06-15'));
    }

    public function test_28_2_en_stage_feminine_newborn_unchanged(): void
    {
        $pt = new ParentTime(Locales::EN());
        $this->assertSame('Newborn', $pt->formatStage('2025-06-15', '2025-06-15', 'f'));
    }

    public function test_28_3_en_stage_feminine_adult_unchanged(): void
    {
        $pt = new ParentTime(Locales::EN());
        $this->assertSame('Adult', $pt->formatStage('2007-06-15', '2025-06-15', 'f'));
    }

    // 28.4-28.9 Spanish — gendered newborn, toddler, child, adult; neutral infant, teenager
    public function test_28_4_es_stage_default_newborn(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('Recién nacido', $pt->formatStage('2025-06-15', '2025-06-15'));
    }

    public function test_28_5_es_stage_feminine_newborn(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('Recién nacida', $pt->formatStage('2025-06-15', '2025-06-15', 'f'));
    }

    public function test_28_6_es_stage_feminine_toddler(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('Niña pequeña', $pt->formatStage('2024-06-15', '2025-06-15', 'f'));
    }

    public function test_28_7_es_stage_feminine_child(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('Niña', $pt->formatStage('2022-06-15', '2025-06-15', 'f'));
    }

    public function test_28_8_es_stage_feminine_adult(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('Adulta', $pt->formatStage('2007-06-15', '2025-06-15', 'f'));
    }

    public function test_28_9_es_stage_feminine_infant_neutral(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertSame('Bebé', $pt->formatStage('2025-01-15', '2025-06-15', 'f'));
    }

    // 28.10-28.11 Arabic — all 6 gendered
    public function test_28_10_ar_stage_default_teenager(): void
    {
        $pt = new ParentTime(Locales::AR());
        $this->assertSame('مراهق', $pt->formatStage('2012-06-15', '2025-06-15'));
    }

    public function test_28_11_ar_stage_feminine_teenager(): void
    {
        $pt = new ParentTime(Locales::AR());
        $this->assertSame('مراهقة', $pt->formatStage('2012-06-15', '2025-06-15', 'f'));
    }

    // 28.12-28.13 Italian — gendered
    public function test_28_12_it_stage_default_child(): void
    {
        $pt = new ParentTime(Locales::IT());
        $this->assertSame('Bambino', $pt->formatStage('2022-06-15', '2025-06-15'));
    }

    public function test_28_13_it_stage_feminine_child(): void
    {
        $pt = new ParentTime(Locales::IT());
        $this->assertSame('Bambina', $pt->formatStage('2022-06-15', '2025-06-15', 'f'));
    }

    // 28.14-28.15 German — adult only
    public function test_28_14_de_stage_default_adult(): void
    {
        $pt = new ParentTime(Locales::DE());
        $this->assertSame('Erwachsener', $pt->formatStage('2007-06-15', '2025-06-15'));
    }

    public function test_28_15_de_stage_feminine_adult(): void
    {
        $pt = new ParentTime(Locales::DE());
        $this->assertSame('Erwachsene', $pt->formatStage('2007-06-15', '2025-06-15', 'f'));
    }

    // 28.16-28.17 Slovenian — gendered
    public function test_28_16_sl_stage_default_newborn(): void
    {
        $pt = new ParentTime(Locales::SL());
        $this->assertSame('Novorojenček', $pt->formatStage('2025-06-15', '2025-06-15'));
    }

    public function test_28_17_sl_stage_feminine_newborn(): void
    {
        $pt = new ParentTime(Locales::SL());
        $this->assertSame('Novorojenčica', $pt->formatStage('2025-06-15', '2025-06-15', 'f'));
    }

    // 28.18-28.19 Free function — gender parameter works
    public function test_28_18_free_function_default_gender(): void
    {
        $this->assertSame('Adult', formatStage('2007-06-15', '2025-06-15'));
    }

    public function test_28_19_free_function_feminine_unchanged_en(): void
    {
        $this->assertSame('Adult', formatStage('2007-06-15', '2025-06-15', 'f'));
    }

    // 28.20-28.21 French — toddler neutral swap + gendered
    public function test_28_20_fr_stage_default_toddler(): void
    {
        $pt = new ParentTime(Locales::FR());
        $this->assertSame('Tout-petit', $pt->formatStage('2024-06-15', '2025-06-15'));
    }

    public function test_28_21_fr_stage_feminine_teenager(): void
    {
        $pt = new ParentTime(Locales::FR());
        $this->assertSame('Adolescente', $pt->formatStage('2012-06-15', '2025-06-15', 'f'));
    }

    // 28.22 Null dob with gender returns null
    public function test_28_22_null_dob_with_gender(): void
    {
        $pt = new ParentTime(Locales::ES());
        $this->assertNull($pt->formatStage(null, '2025-06-15', 'f'));
    }

    // 28.23-28.24 Polish — teenager and adult gendered
    public function test_28_23_pl_stage_feminine_teenager(): void
    {
        $pt = new ParentTime(Locales::PL());
        $this->assertSame('Nastolatka', $pt->formatStage('2012-06-15', '2025-06-15', 'f'));
    }

    public function test_28_24_pl_stage_feminine_adult(): void
    {
        $pt = new ParentTime(Locales::PL());
        $this->assertSame('Dorosła', $pt->formatStage('2007-06-15', '2025-06-15', 'f'));
    }

    // ================================================================
    // Section 29: Locale-specific edge cases — new plural rules (39 tests)
    // ================================================================

    // Hebrew (he) — dual forms
    public function test_29_1_he_just_born(): void
    {
        $pt = new ParentTime(Locales::HE());
        $this->assertSame('רק נולד', $pt->formatAge('2025-06-15', '2025-06-15'));
    }

    public function test_29_2_he_one_day(): void
    {
        $pt = new ParentTime(Locales::HE());
        $this->assertSame('יום 1', $pt->formatAge('2025-06-14', '2025-06-15'));
    }

    public function test_29_3_he_three_days(): void
    {
        $pt = new ParentTime(Locales::HE());
        $this->assertSame('3 ימים', $pt->formatAge('2025-06-12', '2025-06-15'));
    }

    public function test_29_4_he_two_weeks_dual(): void
    {
        $pt = new ParentTime(Locales::HE());
        $this->assertSame('שבועיים', $pt->formatAge('2025-06-01', '2025-06-15'));
    }

    public function test_29_5_he_three_weeks(): void
    {
        $pt = new ParentTime(Locales::HE());
        $this->assertSame('3 שבועות', $pt->formatAge('2025-05-25', '2025-06-15'));
    }

    public function test_29_6_he_six_months(): void
    {
        $pt = new ParentTime(Locales::HE());
        $this->assertSame('6 חודשים', $pt->formatAge('2025-01-15', '2025-07-15'));
    }

    public function test_29_7_he_three_months(): void
    {
        $pt = new ParentTime(Locales::HE());
        $this->assertSame('3 חודשים', $pt->formatAge('2025-03-15', '2025-06-15'));
    }

    public function test_29_8_he_two_years_dual_one_month(): void
    {
        $pt = new ParentTime(Locales::HE());
        $this->assertSame('שנתיים, חודש 1', $pt->formatAge('2023-06-15', '2025-07-15'));
    }

    public function test_29_9_he_half_years(): void
    {
        $pt = new ParentTime(Locales::HE());
        $this->assertSame('3 שנים וחצי', $pt->formatAge('2022-06-15', '2025-12-15'));
    }

    public function test_29_10_he_seven_years(): void
    {
        $pt = new ParentTime(Locales::HE());
        $this->assertSame('7 שנים', $pt->formatAge('2018-06-15', '2025-06-15'));
    }

    public function test_29_11_he_stage_masculine_newborn(): void
    {
        $pt = new ParentTime(Locales::HE());
        $this->assertSame('רק נולד', $pt->formatStage('2025-06-15', '2025-06-15', 'm'));
    }

    public function test_29_12_he_stage_feminine_newborn(): void
    {
        $pt = new ParentTime(Locales::HE());
        $this->assertSame('רק נולדה', $pt->formatStage('2025-06-15', '2025-06-15', 'f'));
    }

    public function test_29_13_he_stage_masculine_adult(): void
    {
        $pt = new ParentTime(Locales::HE());
        $this->assertSame('מבוגר', $pt->formatStage('2007-06-15', '2025-06-15', 'm'));
    }

    public function test_29_14_he_stage_feminine_adult(): void
    {
        $pt = new ParentTime(Locales::HE());
        $this->assertSame('מבוגרת', $pt->formatStage('2007-06-15', '2025-06-15', 'f'));
    }

    // Macedonian (mk) — mod10/mod100 rule
    public function test_29_15_mk_just_born(): void
    {
        $pt = new ParentTime(Locales::MK());
        $this->assertSame('Новороденче', $pt->formatAge('2025-06-15', '2025-06-15'));
    }

    public function test_29_16_mk_one_day(): void
    {
        $pt = new ParentTime(Locales::MK());
        $this->assertSame('1 ден', $pt->formatAge('2025-06-14', '2025-06-15'));
    }

    public function test_29_17_mk_three_days(): void
    {
        $pt = new ParentTime(Locales::MK());
        $this->assertSame('3 дена', $pt->formatAge('2025-06-12', '2025-06-15'));
    }

    public function test_29_18_mk_six_months(): void
    {
        $pt = new ParentTime(Locales::MK());
        $this->assertSame('6 месеци', $pt->formatAge('2025-01-15', '2025-07-15'));
    }

    public function test_29_19_mk_two_years_one_month(): void
    {
        $pt = new ParentTime(Locales::MK());
        $this->assertSame('2 години, 1 месец', $pt->formatAge('2023-06-15', '2025-07-15'));
    }

    public function test_29_20_mk_half_years(): void
    {
        $pt = new ParentTime(Locales::MK());
        $this->assertSame('3 години и пол', $pt->formatAge('2022-06-15', '2025-12-15'));
    }

    public function test_29_21_mk_seven_years(): void
    {
        $pt = new ParentTime(Locales::MK());
        $this->assertSame('7 години', $pt->formatAge('2018-06-15', '2025-06-15'));
    }

    // Swahili (sw) — noun class changes
    public function test_29_22_sw_just_born(): void
    {
        $pt = new ParentTime(Locales::SW());
        $this->assertSame('Mzaliwa mpya', $pt->formatAge('2025-06-15', '2025-06-15'));
    }

    public function test_29_23_sw_one_day(): void
    {
        $pt = new ParentTime(Locales::SW());
        $this->assertSame('siku 1', $pt->formatAge('2025-06-14', '2025-06-15'));
    }

    public function test_29_24_sw_three_days(): void
    {
        $pt = new ParentTime(Locales::SW());
        $this->assertSame('siku 3', $pt->formatAge('2025-06-12', '2025-06-15'));
    }

    public function test_29_25_sw_six_months(): void
    {
        $pt = new ParentTime(Locales::SW());
        $this->assertSame('miezi 6', $pt->formatAge('2025-01-15', '2025-07-15'));
    }

    public function test_29_26_sw_two_years_one_month(): void
    {
        $pt = new ParentTime(Locales::SW());
        $this->assertSame('miaka 2, mwezi 1', $pt->formatAge('2023-06-15', '2025-07-15'));
    }

    public function test_29_27_sw_half_years(): void
    {
        $pt = new ParentTime(Locales::SW());
        $this->assertSame('miaka 3 na nusu', $pt->formatAge('2022-06-15', '2025-12-15'));
    }

    // Indonesian (id) — other_only
    public function test_29_28_id_just_born(): void
    {
        $pt = new ParentTime(Locales::ID());
        $this->assertSame('Baru lahir', $pt->formatAge('2025-06-15', '2025-06-15'));
    }

    public function test_29_29_id_one_day(): void
    {
        $pt = new ParentTime(Locales::ID());
        $this->assertSame('1 hari', $pt->formatAge('2025-06-14', '2025-06-15'));
    }

    public function test_29_30_id_three_days(): void
    {
        $pt = new ParentTime(Locales::ID());
        $this->assertSame('3 hari', $pt->formatAge('2025-06-12', '2025-06-15'));
    }

    public function test_29_31_id_six_months(): void
    {
        $pt = new ParentTime(Locales::ID());
        $this->assertSame('6 bulan', $pt->formatAge('2025-01-15', '2025-07-15'));
    }

    public function test_29_32_id_half_years(): void
    {
        $pt = new ParentTime(Locales::ID());
        $this->assertSame('3 tahun setengah', $pt->formatAge('2022-06-15', '2025-12-15'));
    }

    public function test_29_33_id_seven_years(): void
    {
        $pt = new ParentTime(Locales::ID());
        $this->assertSame('7 tahun', $pt->formatAge('2018-06-15', '2025-06-15'));
    }

    // Amharic (am) — Ethiopic delimiter
    public function test_29_34_am_just_born(): void
    {
        $pt = new ParentTime(Locales::AM());
        $this->assertSame('አዲስ የተወለደ', $pt->formatAge('2025-06-15', '2025-06-15'));
    }

    public function test_29_35_am_one_day(): void
    {
        $pt = new ParentTime(Locales::AM());
        $this->assertSame('1 ቀን', $pt->formatAge('2025-06-14', '2025-06-15'));
    }

    public function test_29_36_am_three_days(): void
    {
        $pt = new ParentTime(Locales::AM());
        $this->assertSame('3 ቀናት', $pt->formatAge('2025-06-12', '2025-06-15'));
    }

    public function test_29_37_am_one_week_one_day_ethiopic(): void
    {
        $pt = new ParentTime(Locales::AM());
        $this->assertSame('1 ሳምንት፣ 1 ቀን', $pt->formatAge('2025-06-07', '2025-06-15'));
    }

    public function test_29_38_am_six_months(): void
    {
        $pt = new ParentTime(Locales::AM());
        $this->assertSame('6 ወራት', $pt->formatAge('2025-01-15', '2025-07-15'));
    }

    public function test_29_39_am_half_years(): void
    {
        $pt = new ParentTime(Locales::AM());
        $this->assertSame('3 ዓመታት ተኩል', $pt->formatAge('2022-06-15', '2025-12-15'));
    }
}
