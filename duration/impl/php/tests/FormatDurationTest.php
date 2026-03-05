<?php

declare(strict_types=1);

namespace SayableDuration\Tests;

use SayableDuration\Compactness;
use SayableDuration\Locales\Locales;
use SayableDuration\SayableDuration;
use PHPUnit\Framework\TestCase;

use function SayableDuration\formatDuration;
use function SayableDuration\formatSince;
use function SayableDuration\formatUntil;

/**
 * Canonical test suite — test cases from config/tests.json.
 */
final class FormatDurationTest extends TestCase
{
    // ================================================================
    // Section 1: Null / edge cases
    // ================================================================

    // 1.1
    public function test_null_returns_null(): void
    {
        $this->assertNull(formatDuration(-1));
    }

    // 1.2
    public function test_negative_returns_null(): void
    {
        $this->assertNull(formatDuration(-1));
    }

    // 1.3
    public function test_since_null_start_returns_null(): void
    {
        $this->assertNull(formatSince(null, '2025-01-15T10:00:00'));
    }

    // 1.4
    public function test_until_null_target_returns_null(): void
    {
        $this->assertNull(formatUntil(null, '2025-01-15T10:00:00'));
    }

    // 1.5
    public function test_since_asOf_before_start_returns_null(): void
    {
        $this->assertNull(formatSince('2025-01-15T10:00:00', '2025-01-15T09:00:00'));
    }

    // 1.6
    public function test_until_target_in_past_returns_null(): void
    {
        $this->assertNull(formatUntil('2025-01-15T09:00:00', '2025-01-15T10:00:00'));
    }

    // ================================================================
    // Section 2: Duration — seconds tier (0-59s)
    // ================================================================

    // 2.1
    public function test_zero_seconds_is_just_now(): void
    {
        $this->assertSame('just now', formatDuration(0));
    }

    // 2.2
    public function test_1_second(): void
    {
        $this->assertSame('1 second', formatDuration(1));
    }

    // 2.3
    public function test_45_seconds(): void
    {
        $this->assertSame('45 seconds', formatDuration(45));
    }

    // 2.4
    public function test_59_seconds(): void
    {
        $this->assertSame('59 seconds', formatDuration(59));
    }

    // ================================================================
    // Section 3: Duration — minutes + seconds tier (1-4 min)
    // ================================================================

    // 3.1
    public function test_1_minute(): void
    {
        $this->assertSame('1 minute', formatDuration(60));
    }

    // 3.2
    public function test_1_minute_30_seconds(): void
    {
        $this->assertSame('1 minute, 30 seconds', formatDuration(90));
    }

    // 3.3
    public function test_4_minutes(): void
    {
        $this->assertSame('4 minutes', formatDuration(240));
    }

    // 3.4
    public function test_4_minutes_30_seconds(): void
    {
        $this->assertSame('4 minutes, 30 seconds', formatDuration(270));
    }

    // ================================================================
    // Section 4: Duration — minutes tier (5-59 min)
    // ================================================================

    // 4.1
    public function test_5_minutes(): void
    {
        $this->assertSame('5 minutes', formatDuration(300));
    }

    // 4.2
    public function test_25_minutes(): void
    {
        $this->assertSame('25 minutes', formatDuration(1500));
    }

    // 4.3
    public function test_59_minutes(): void
    {
        $this->assertSame('59 minutes', formatDuration(3540));
    }

    // ================================================================
    // Section 5: Duration — hours + minutes tier (1-5 hr)
    // ================================================================

    // 5.1
    public function test_1_hour(): void
    {
        $this->assertSame('1 hour', formatDuration(3600));
    }

    // 5.2
    public function test_1_and_half_hours(): void
    {
        $this->assertSame("1\u{00BD} hours", formatDuration(5400));
    }

    // 5.3
    public function test_2_hours_15_minutes(): void
    {
        $this->assertSame('2 hours, 15 minutes', formatDuration(8100));
    }

    // 5.4
    public function test_5_hours(): void
    {
        $this->assertSame('5 hours', formatDuration(18000));
    }

    // ================================================================
    // Section 6: Duration — hours tier (6-23 hr)
    // ================================================================

    // 6.1
    public function test_8_hours(): void
    {
        $this->assertSame('8 hours', formatDuration(28800));
    }

    // 6.2
    public function test_23_hours(): void
    {
        $this->assertSame('23 hours', formatDuration(82800));
    }

    // ================================================================
    // Section 7: Duration — days tier
    // ================================================================

    // 7.1
    public function test_1_day(): void
    {
        $this->assertSame('1 day', formatDuration(86400));
    }

    // 7.2
    public function test_1_day_3_hours(): void
    {
        $this->assertSame('1 day, 3 hours', formatDuration(97200));
    }

    // 7.3
    public function test_1_and_half_days(): void
    {
        $this->assertSame("1\u{00BD} days", formatDuration(129600));
    }

    // 7.4
    public function test_5_days(): void
    {
        $this->assertSame('5 days', formatDuration(432000));
    }

    // 7.5
    public function test_2_days(): void
    {
        $this->assertSame('2 days', formatDuration(172800));
    }

    // ================================================================
    // Section 8: Duration — weeks tier
    // ================================================================

    // 8.1
    public function test_1_week(): void
    {
        $this->assertSame('1 week', formatDuration(604800));
    }

    // 8.2
    public function test_2_weeks_1_day(): void
    {
        $this->assertSame('2 weeks, 1 day', formatDuration(1296000));
    }

    // 8.3
    public function test_4_weeks(): void
    {
        $this->assertSame('4 weeks', formatDuration(2419200));
    }

    // ================================================================
    // Section 9: Duration — months and years tier
    // ================================================================

    // 9.1
    public function test_1_month(): void
    {
        $this->assertSame('1 month', formatDuration(2678400));
    }

    // 9.2
    public function test_3_months(): void
    {
        $this->assertSame('3 months', formatDuration(7884000));
    }

    // 9.3
    public function test_1_year(): void
    {
        $this->assertSame('1 year', formatDuration(31536000));
    }

    // 9.4
    public function test_1_year_3_months(): void
    {
        $this->assertSame('1 year, 3 months', formatDuration(39420000));
    }

    // ================================================================
    // Section 10: Duration from ISO timestamps
    // ================================================================

    // 10.1
    public function test_iso_1_and_half_hours(): void
    {
        $sd = new SayableDuration(Locales::EN());
        $this->assertSame("1\u{00BD} hours",
            $sd->formatDurationIso('2025-01-15T10:00:00', '2025-01-15T11:30:00'));
    }

    // 10.2
    public function test_iso_45_minutes(): void
    {
        $sd = new SayableDuration(Locales::EN());
        $this->assertSame('45 minutes',
            $sd->formatDurationIso('2025-01-15T10:00:00', '2025-01-15T10:45:00'));
    }

    // ================================================================
    // Section 11: Relative time — since
    // ================================================================

    // 11.1
    public function test_since_just_now(): void
    {
        $this->assertSame('just now',
            formatSince('2025-01-15T10:00:00', '2025-01-15T10:00:00'));
    }

    // 11.2
    public function test_since_30_seconds_ago(): void
    {
        $this->assertSame('30 seconds ago',
            formatSince('2025-01-15T10:00:00', '2025-01-15T10:00:30'));
    }

    // 11.3
    public function test_since_45_minutes_ago(): void
    {
        $this->assertSame('45 minutes ago',
            formatSince('2025-01-15T10:00:00', '2025-01-15T10:45:00'));
    }

    // 11.4
    public function test_since_3_hours_ago(): void
    {
        $this->assertSame('3 hours ago',
            formatSince('2025-01-15T10:00:00', '2025-01-15T13:00:00'));
    }

    // ================================================================
    // Section 12: Relative time — until
    // ================================================================

    // 12.1
    public function test_until_just_now(): void
    {
        $this->assertSame('just now',
            formatUntil('2025-01-15T10:00:00', '2025-01-15T10:00:00'));
    }

    // 12.2
    public function test_until_in_20_minutes(): void
    {
        $this->assertSame('in 20 minutes',
            formatUntil('2025-01-15T10:20:00', '2025-01-15T10:00:00'));
    }

    // 12.3
    public function test_until_in_3_hours(): void
    {
        $this->assertSame('in 3 hours',
            formatUntil('2025-01-15T13:00:00', '2025-01-15T10:00:00'));
    }

    // ================================================================
    // Section 13: Locale — German
    // ================================================================

    // 13.1
    public function test_german_1_hour(): void
    {
        $sd = new SayableDuration(Locales::DE());
        $this->assertSame('1 Stunde', $sd->formatDuration(3600));
    }

    // 13.2
    public function test_german_since_5_minutes(): void
    {
        $sd = new SayableDuration(Locales::DE());
        $this->assertSame('vor 5 Minuten',
            $sd->formatSince('2025-01-15T10:00:00', '2025-01-15T10:05:00'));
    }

    // ================================================================
    // Section 14: Locale — French
    // ================================================================

    // 14.1
    public function test_french_2_hours(): void
    {
        $sd = new SayableDuration(Locales::FR());
        $this->assertSame('2 heures', $sd->formatDuration(7200));
    }

    // ================================================================
    // Section 15: Locale — Japanese
    // ================================================================

    // 15.1
    public function test_japanese_2_minutes(): void
    {
        $sd = new SayableDuration(Locales::JA());
        $this->assertSame("2\u{5206}", $sd->formatDuration(120));
    }

    // 15.2
    public function test_japanese_since_1_hour(): void
    {
        $sd = new SayableDuration(Locales::JA());
        $this->assertSame("1\u{6642}\u{9593}\u{524D}",
            $sd->formatSince('2025-01-15T10:00:00', '2025-01-15T11:00:00'));
    }

    // ================================================================
    // Section 16: Short compactness — duration
    // ================================================================

    // 16.1
    public function test_short_1_hour(): void
    {
        $sd = new SayableDuration(Locales::EN(), Compactness::Short);
        $this->assertSame('1h', $sd->formatDuration(3600));
    }

    // 16.2
    public function test_short_1_minute_30_seconds(): void
    {
        $sd = new SayableDuration(Locales::EN(), Compactness::Short);
        $this->assertSame('1m, 30s', $sd->formatDuration(90));
    }

    // ================================================================
    // Section 17: Compact compactness — duration
    // ================================================================

    // 17.1
    public function test_compact_1_hour(): void
    {
        $sd = new SayableDuration(Locales::EN(), Compactness::Compact);
        $this->assertSame('1h', $sd->formatDuration(3600));
    }

    // 17.2
    public function test_compact_1_minute_30_seconds(): void
    {
        $sd = new SayableDuration(Locales::EN(), Compactness::Compact);
        $this->assertSame('1m30s', $sd->formatDuration(90));
    }
}
