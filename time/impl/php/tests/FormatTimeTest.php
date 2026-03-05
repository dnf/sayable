<?php

declare(strict_types=1);

namespace SayableTime\Tests;

use SayableTime\Compactness;
use SayableTime\Locales\Locales;
use SayableTime\SayableTime;
use PHPUnit\Framework\TestCase;

use function SayableTime\formatTime;

/**
 * Canonical test suite — test cases from config/tests.json.
 */
final class FormatTimeTest extends TestCase
{
    // ================================================================
    // Section 1: Null / edge cases
    // ================================================================

    // 1.1
    public function test_null_returns_null(): void
    {
        $this->assertNull(formatTime(null));
    }

    // 1.2
    public function test_empty_returns_null(): void
    {
        $this->assertNull(formatTime(''));
    }

    // 1.3
    public function test_invalid_returns_null(): void
    {
        $this->assertNull(formatTime('invalid'));
    }

    // 1.4
    public function test_out_of_range_returns_null(): void
    {
        $this->assertNull(formatTime('25:00'));
    }

    // ================================================================
    // Section 2: Clock time (normal compactness)
    // ================================================================

    // 2.1
    public function test_midnight(): void
    {
        $this->assertSame('midnight', formatTime('00:00'));
    }

    // 2.2
    public function test_noon(): void
    {
        $this->assertSame('noon', formatTime('12:00'));
    }

    // 2.3
    public function test_three_oclock(): void
    {
        $this->assertSame("three o'clock", formatTime('15:00'));
    }

    // 2.4
    public function test_quarter_past_two(): void
    {
        $this->assertSame('a quarter past two', formatTime('14:15'));
    }

    // 2.5
    public function test_half_past_nine(): void
    {
        $this->assertSame('half past nine', formatTime('09:30'));
    }

    // 2.6
    public function test_quarter_to_eleven(): void
    {
        $this->assertSame('a quarter to eleven', formatTime('10:45'));
    }

    // 2.7
    public function test_five_past_eight(): void
    {
        $this->assertSame('five past eight', formatTime('08:05'));
    }

    // 2.8
    public function test_five_to_five(): void
    {
        $this->assertSame('five to five', formatTime('16:55'));
    }

    // 2.9
    public function test_rounds_to_midnight(): void
    {
        $this->assertSame('midnight', formatTime('23:58'));
    }

    // 2.10
    public function test_22_rounds_to_20(): void
    {
        $this->assertSame('twenty past seven', formatTime('07:22'));
    }

    // 2.11
    public function test_iso_datetime_input(): void
    {
        $this->assertSame('a quarter past two', formatTime('2025-01-15T14:15:00'));
    }

    // ================================================================
    // Section 3: Clock time (short compactness)
    // ================================================================

    // 3.1
    public function test_short_214_pm(): void
    {
        $st = new SayableTime(Locales::EN(), Compactness::Short);
        $this->assertSame('2:15 PM', $st->formatTime('14:15'));
    }

    // 3.2
    public function test_short_930_am(): void
    {
        $st = new SayableTime(Locales::EN(), Compactness::Short);
        $this->assertSame('9:30 AM', $st->formatTime('09:30'));
    }

    // 3.3
    public function test_short_midnight(): void
    {
        $st = new SayableTime(Locales::EN(), Compactness::Short);
        $this->assertSame('12:00 AM', $st->formatTime('00:00'));
    }

    // 3.4
    public function test_short_noon(): void
    {
        $st = new SayableTime(Locales::EN(), Compactness::Short);
        $this->assertSame('12:00 PM', $st->formatTime('12:00'));
    }

    // ================================================================
    // Section 4: Clock time (compact)
    // ================================================================

    // 4.1
    public function test_compact_215p(): void
    {
        $st = new SayableTime(Locales::EN(), Compactness::Compact);
        $this->assertSame('2:15p', $st->formatTime('14:15'));
    }

    // 4.2
    public function test_compact_930a(): void
    {
        $st = new SayableTime(Locales::EN(), Compactness::Compact);
        $this->assertSame('9:30a', $st->formatTime('09:30'));
    }

    // ================================================================
    // Section 5: Locale — German
    // ================================================================

    // 5.1
    public function test_german_half_to_pattern(): void
    {
        $st = new SayableTime(Locales::DE());
        $this->assertSame('halb vier', $st->formatTime('15:30'));
    }

    // ================================================================
    // Section 6: Locale — French
    // ================================================================

    // 6.1
    public function test_french_quarter_past(): void
    {
        $st = new SayableTime(Locales::FR());
        $this->assertSame('trois heures et quart', $st->formatTime('15:15'));
    }

    // ================================================================
    // Section 7: Locale — Japanese
    // ================================================================

    // 7.1
    public function test_japanese_half_past(): void
    {
        $st = new SayableTime(Locales::JA());
        $this->assertSame("\u{4E09}\u{6642}\u{534A}", $st->formatTime('15:30'));
    }
}
