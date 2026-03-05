<?php

declare(strict_types=1);

namespace SayableDate\Tests;

use SayableDate\Compactness;
use SayableDate\Locales\Locales;
use SayableDate\SayableDate;
use PHPUnit\Framework\TestCase;

use function SayableDate\formatDate;
use function SayableDate\formatRelative;

/**
 * Canonical test suite — test cases from config/tests.json.
 */
final class FormatDateTest extends TestCase
{
    // ================================================================
    // Section 1: Null / edge cases
    // ================================================================

    // 1.1
    public function test_null_date_returns_null(): void
    {
        $this->assertNull(formatDate(null));
    }

    // 1.2
    public function test_empty_date_returns_null(): void
    {
        $this->assertNull(formatDate(''));
    }

    // 1.3
    public function test_invalid_date_returns_null(): void
    {
        $this->assertNull(formatDate('invalid'));
    }

    // 1.4
    public function test_relative_null_asOf_returns_null(): void
    {
        $this->assertNull(formatRelative('2025-03-15', null));
    }

    // 1.5
    public function test_relative_null_date_returns_null(): void
    {
        $this->assertNull(formatRelative(null, '2025-03-15'));
    }

    // ================================================================
    // Section 2: format_date — normal compactness (English)
    // ================================================================

    // 2.1
    public function test_march_15th(): void
    {
        $this->assertSame('March 15th', formatDate('2025-03-15'));
    }

    // 2.2
    public function test_january_1st(): void
    {
        $this->assertSame('January 1st', formatDate('2025-01-01'));
    }

    // 2.3
    public function test_may_22nd(): void
    {
        $this->assertSame('May 22nd', formatDate('2025-05-22'));
    }

    // 2.4
    public function test_july_3rd(): void
    {
        $this->assertSame('July 3rd', formatDate('2025-07-03'));
    }

    // 2.5
    public function test_december_31st(): void
    {
        $this->assertSame('December 31st', formatDate('2025-12-31'));
    }

    // 2.6
    public function test_june_11th(): void
    {
        $this->assertSame('June 11th', formatDate('2025-06-11'));
    }

    // 2.7
    public function test_iso_datetime_input(): void
    {
        $this->assertSame('March 15th', formatDate('2025-03-15T14:30:00'));
    }

    // ================================================================
    // Section 3: format_date — short compactness (English)
    // ================================================================

    // 3.1
    public function test_short_mar_15(): void
    {
        $sd = new SayableDate(Locales::EN(), Compactness::Short);
        $this->assertSame('Mar 15', $sd->formatDate('2025-03-15'));
    }

    // 3.2
    public function test_short_jan_1(): void
    {
        $sd = new SayableDate(Locales::EN(), Compactness::Short);
        $this->assertSame('Jan 1', $sd->formatDate('2025-01-01'));
    }

    // 3.3
    public function test_short_dec_25(): void
    {
        $sd = new SayableDate(Locales::EN(), Compactness::Short);
        $this->assertSame('Dec 25', $sd->formatDate('2025-12-25'));
    }

    // ================================================================
    // Section 4: format_date — compact (English)
    // ================================================================

    // 4.1
    public function test_compact_3_15(): void
    {
        $sd = new SayableDate(Locales::EN(), Compactness::Compact);
        $this->assertSame('3/15', $sd->formatDate('2025-03-15'));
    }

    // 4.2
    public function test_compact_1_1(): void
    {
        $sd = new SayableDate(Locales::EN(), Compactness::Compact);
        $this->assertSame('1/1', $sd->formatDate('2025-01-01'));
    }

    // ================================================================
    // Section 5: format_relative — proximity tiers (English)
    // ================================================================

    // 5.1
    public function test_relative_today(): void
    {
        $sd = new SayableDate(Locales::EN());
        $this->assertSame('today', $sd->formatRelative('2025-03-15', '2025-03-15'));
    }

    // 5.2
    public function test_relative_tomorrow(): void
    {
        $sd = new SayableDate(Locales::EN());
        $this->assertSame('tomorrow', $sd->formatRelative('2025-03-16', '2025-03-15'));
    }

    // 5.3
    public function test_relative_yesterday(): void
    {
        $sd = new SayableDate(Locales::EN());
        $this->assertSame('yesterday', $sd->formatRelative('2025-03-14', '2025-03-15'));
    }

    // 5.4
    public function test_relative_day_after_tomorrow(): void
    {
        $sd = new SayableDate(Locales::EN());
        $this->assertSame('the day after tomorrow', $sd->formatRelative('2025-03-17', '2025-03-15'));
    }

    // 5.5
    public function test_relative_day_before_yesterday(): void
    {
        $sd = new SayableDate(Locales::EN());
        $this->assertSame('the day before yesterday', $sd->formatRelative('2025-03-13', '2025-03-15'));
    }

    // 5.6
    public function test_relative_this_wednesday(): void
    {
        $sd = new SayableDate(Locales::EN());
        $this->assertSame('this Wednesday', $sd->formatRelative('2025-03-19', '2025-03-15'));
    }

    // 5.7
    public function test_relative_this_thursday(): void
    {
        $sd = new SayableDate(Locales::EN());
        $this->assertSame('this Thursday', $sd->formatRelative('2025-03-20', '2025-03-15'));
    }

    // 5.8
    public function test_relative_last_tuesday(): void
    {
        $sd = new SayableDate(Locales::EN());
        $this->assertSame('last Tuesday', $sd->formatRelative('2025-03-11', '2025-03-15'));
    }

    // 5.9
    public function test_relative_next_saturday(): void
    {
        $sd = new SayableDate(Locales::EN());
        $this->assertSame('next Saturday', $sd->formatRelative('2025-03-22', '2025-03-15'));
    }

    // 5.10
    public function test_relative_next_thursday(): void
    {
        $sd = new SayableDate(Locales::EN());
        $this->assertSame('next Thursday', $sd->formatRelative('2025-03-27', '2025-03-15'));
    }

    // 5.11
    public function test_relative_calendar_fallback_same_year(): void
    {
        $sd = new SayableDate(Locales::EN());
        $this->assertSame('March 1st', $sd->formatRelative('2025-03-01', '2025-03-15'));
    }

    // 5.12
    public function test_relative_calendar_fallback_future_same_year(): void
    {
        $sd = new SayableDate(Locales::EN());
        $this->assertSame('April 10th', $sd->formatRelative('2025-04-10', '2025-03-15'));
    }

    // 5.13
    public function test_relative_different_year_future(): void
    {
        $sd = new SayableDate(Locales::EN());
        $this->assertSame('January 5th, 2026', $sd->formatRelative('2026-01-05', '2025-03-15'));
    }

    // 5.14
    public function test_relative_different_year_past(): void
    {
        $sd = new SayableDate(Locales::EN());
        $this->assertSame('December 25th, 2024', $sd->formatRelative('2024-12-25', '2025-03-15'));
    }

    // ================================================================
    // Section 6: format_relative — compact skips weekday tiers
    // ================================================================

    // 6.1
    public function test_compact_relative_today(): void
    {
        $sd = new SayableDate(Locales::EN(), Compactness::Compact);
        $this->assertSame('today', $sd->formatRelative('2025-03-15', '2025-03-15'));
    }

    // 6.2
    public function test_compact_relative_tomorrow(): void
    {
        $sd = new SayableDate(Locales::EN(), Compactness::Compact);
        $this->assertSame('tomorrow', $sd->formatRelative('2025-03-16', '2025-03-15'));
    }

    // 6.3
    public function test_compact_relative_numeric(): void
    {
        $sd = new SayableDate(Locales::EN(), Compactness::Compact);
        $this->assertSame('3/19', $sd->formatRelative('2025-03-19', '2025-03-15'));
    }

    // 6.4
    public function test_compact_relative_with_year(): void
    {
        $sd = new SayableDate(Locales::EN(), Compactness::Compact);
        $this->assertSame('1/5/26', $sd->formatRelative('2026-01-05', '2025-03-15'));
    }

    // ================================================================
    // Section 7: Locale — German
    // ================================================================

    // 7.1
    public function test_german_format_date(): void
    {
        $sd = new SayableDate(Locales::DE());
        $this->assertSame("15. M\u{00E4}rz", $sd->formatDate('2025-03-15'));
    }

    // 7.2
    public function test_german_tomorrow(): void
    {
        $sd = new SayableDate(Locales::DE());
        $this->assertSame('morgen', $sd->formatRelative('2025-03-16', '2025-03-15'));
    }

    // 7.3
    public function test_german_day_after_tomorrow(): void
    {
        $sd = new SayableDate(Locales::DE());
        $this->assertSame("\u{00FC}bermorgen", $sd->formatRelative('2025-03-17', '2025-03-15'));
    }

    // 7.4
    public function test_german_this_weekday(): void
    {
        $sd = new SayableDate(Locales::DE());
        $this->assertSame('diesen Mittwoch', $sd->formatRelative('2025-03-19', '2025-03-15'));
    }

    // ================================================================
    // Section 8: Locale — French
    // ================================================================

    // 8.1
    public function test_french_1st(): void
    {
        $sd = new SayableDate(Locales::FR());
        $this->assertSame('1er mars', $sd->formatDate('2025-03-01'));
    }

    // 8.2
    public function test_french_15th(): void
    {
        $sd = new SayableDate(Locales::FR());
        $this->assertSame('15 mars', $sd->formatDate('2025-03-15'));
    }

    // 8.3
    public function test_french_tomorrow(): void
    {
        $sd = new SayableDate(Locales::FR());
        $this->assertSame('demain', $sd->formatRelative('2025-03-16', '2025-03-15'));
    }

    // ================================================================
    // Section 9: Locale — Japanese
    // ================================================================

    // 9.1
    public function test_japanese_format_date(): void
    {
        $sd = new SayableDate(Locales::JA());
        $this->assertSame("3\u{6708}15\u{65E5}", $sd->formatDate('2025-03-15'));
    }

    // 9.2
    public function test_japanese_tomorrow(): void
    {
        $sd = new SayableDate(Locales::JA());
        $this->assertSame("\u{660E}\u{65E5}", $sd->formatRelative('2025-03-16', '2025-03-15'));
    }

    // 9.3
    public function test_japanese_this_weekday(): void
    {
        $sd = new SayableDate(Locales::JA());
        $this->assertSame("\u{4ECA}\u{5EA6}\u{306E}\u{6C34}\u{66DC}\u{65E5}", $sd->formatRelative('2025-03-19', '2025-03-15'));
    }

    // ================================================================
    // Section 10: Locale — Russian (genitive months)
    // ================================================================

    // 10.1
    public function test_russian_genitive_month(): void
    {
        $sd = new SayableDate(Locales::RU());
        $this->assertSame("15 \u{043C}\u{0430}\u{0440}\u{0442}\u{0430}", $sd->formatDate('2025-03-15'));
    }

    // 10.2
    public function test_russian_tomorrow(): void
    {
        $sd = new SayableDate(Locales::RU());
        $this->assertSame("\u{0437}\u{0430}\u{0432}\u{0442}\u{0440}\u{0430}", $sd->formatRelative('2025-03-16', '2025-03-15'));
    }

    // ================================================================
    // Section 11: Locale — Arabic
    // ================================================================

    // 11.1
    public function test_arabic_format_date(): void
    {
        $sd = new SayableDate(Locales::AR());
        $this->assertSame("15 \u{0645}\u{0627}\u{0631}\u{0633}", $sd->formatDate('2025-03-15'));
    }

    // 11.2
    public function test_arabic_tomorrow(): void
    {
        $sd = new SayableDate(Locales::AR());
        $this->assertSame("\u{063A}\u{062F}\u{0627}\u{064B}", $sd->formatRelative('2025-03-16', '2025-03-15'));
    }

    // ================================================================
    // Section 12: Locale — Spanish
    // ================================================================

    // 12.1
    public function test_spanish_format_date(): void
    {
        $sd = new SayableDate(Locales::ES());
        $this->assertSame('15 de marzo', $sd->formatDate('2025-03-15'));
    }

    // 12.2
    public function test_spanish_day_after_tomorrow(): void
    {
        $sd = new SayableDate(Locales::ES());
        $this->assertSame("pasado ma\u{00F1}ana", $sd->formatRelative('2025-03-17', '2025-03-15'));
    }
}
