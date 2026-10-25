package sayableduration

import static org.junit.jupiter.api.Assertions.assertEquals
import static org.junit.jupiter.api.Assertions.assertNull

import org.junit.jupiter.api.Test
import sayableduration.locales.Locales

class FormatDurationTest {

    // ================================================================
    // Section 1: Null / edge cases
    // ================================================================

    // 1.1
    @Test
    void 'format_duration null returns null'() {
        assertNull(SayableDuration.formatDurationSecondsDefault(-1))
    }

    // 1.2
    @Test
    void 'format_duration negative returns null'() {
        assertNull(SayableDuration.formatDurationSecondsDefault(-1))
    }

    // 1.3
    @Test
    void 'format_since null start returns null'() {
        assertNull(SayableDuration.formatSinceDefault(null, '2025-01-15T10:00:00'))
    }

    // 1.4
    @Test
    void 'format_until null target returns null'() {
        assertNull(SayableDuration.formatUntilDefault(null, '2025-01-15T10:00:00'))
    }

    // 1.5
    @Test
    void 'format_since asOf before start returns null'() {
        assertNull(SayableDuration.formatSinceDefault('2025-01-15T10:00:00', '2025-01-15T09:00:00'))
    }

    // 1.6
    @Test
    void 'format_until target in the past returns null'() {
        assertNull(SayableDuration.formatUntilDefault('2025-01-15T09:00:00', '2025-01-15T10:00:00'))
    }

    // ================================================================
    // Section 2: Duration — seconds tier (0-59s)
    // ================================================================

    // 2.1
    @Test
    void 'zero seconds is just now'() {
        assertEquals('just now', SayableDuration.formatDurationSecondsDefault(0))
    }

    // 2.2
    @Test
    void 'one second'() {
        assertEquals('1 second', SayableDuration.formatDurationSecondsDefault(1))
    }

    // 2.3
    @Test
    void 'forty-five seconds'() {
        assertEquals('45 seconds', SayableDuration.formatDurationSecondsDefault(45))
    }

    // 2.4
    @Test
    void 'fifty-nine seconds'() {
        assertEquals('59 seconds', SayableDuration.formatDurationSecondsDefault(59))
    }

    // ================================================================
    // Section 3: Duration — minutes + seconds tier (1-4 min)
    // ================================================================

    // 3.1
    @Test
    void 'one minute'() {
        assertEquals('1 minute', SayableDuration.formatDurationSecondsDefault(60))
    }

    // 3.2
    @Test
    void 'one minute thirty seconds'() {
        assertEquals('1 minute, 30 seconds', SayableDuration.formatDurationSecondsDefault(90))
    }

    // 3.3
    @Test
    void 'four minutes'() {
        assertEquals('4 minutes', SayableDuration.formatDurationSecondsDefault(240))
    }

    // 3.4
    @Test
    void 'four minutes thirty seconds'() {
        assertEquals('4 minutes, 30 seconds', SayableDuration.formatDurationSecondsDefault(270))
    }

    // ================================================================
    // Section 4: Duration — minutes tier (5-59 min)
    // ================================================================

    // 4.1
    @Test
    void 'five minutes'() {
        assertEquals('5 minutes', SayableDuration.formatDurationSecondsDefault(300))
    }

    // 4.2
    @Test
    void 'twenty-five minutes'() {
        assertEquals('25 minutes', SayableDuration.formatDurationSecondsDefault(1500))
    }

    // 4.3
    @Test
    void 'fifty-nine minutes'() {
        assertEquals('59 minutes', SayableDuration.formatDurationSecondsDefault(3540))
    }

    // ================================================================
    // Section 5: Duration — hours + minutes tier (1-5 hr)
    // ================================================================

    // 5.1
    @Test
    void 'one hour'() {
        assertEquals('1 hour', SayableDuration.formatDurationSecondsDefault(3600))
    }

    // 5.2
    @Test
    void 'one and a half hours'() {
        assertEquals("1\u00BD hours", SayableDuration.formatDurationSecondsDefault(5400))
    }

    // 5.3
    @Test
    void 'two hours fifteen minutes'() {
        assertEquals('2 hours, 15 minutes', SayableDuration.formatDurationSecondsDefault(8100))
    }

    // 5.4
    @Test
    void 'five hours'() {
        assertEquals('5 hours', SayableDuration.formatDurationSecondsDefault(18000))
    }

    // ================================================================
    // Section 6: Duration — hours tier (6-23 hr)
    // ================================================================

    // 6.1
    @Test
    void 'eight hours'() {
        assertEquals('8 hours', SayableDuration.formatDurationSecondsDefault(28800))
    }

    // 6.2
    @Test
    void 'twenty-three hours'() {
        assertEquals('23 hours', SayableDuration.formatDurationSecondsDefault(82800))
    }

    // ================================================================
    // Section 7: Duration — days tier
    // ================================================================

    // 7.1
    @Test
    void 'one day'() {
        assertEquals('1 day', SayableDuration.formatDurationSecondsDefault(86400))
    }

    // 7.2
    @Test
    void 'one day three hours'() {
        assertEquals('1 day, 3 hours', SayableDuration.formatDurationSecondsDefault(97200))
    }

    // 7.3
    @Test
    void 'one and a half days'() {
        assertEquals("1\u00BD days", SayableDuration.formatDurationSecondsDefault(129600))
    }

    // 7.4
    @Test
    void 'five days'() {
        assertEquals('5 days', SayableDuration.formatDurationSecondsDefault(432000))
    }

    // 7.5
    @Test
    void 'two days'() {
        assertEquals('2 days', SayableDuration.formatDurationSecondsDefault(172800))
    }

    // ================================================================
    // Section 8: Duration — weeks tier
    // ================================================================

    // 8.1
    @Test
    void 'one week'() {
        assertEquals('1 week', SayableDuration.formatDurationSecondsDefault(604800))
    }

    // 8.2
    @Test
    void 'two weeks one day'() {
        assertEquals('2 weeks, 1 day', SayableDuration.formatDurationSecondsDefault(1296000))
    }

    // 8.3
    @Test
    void 'four weeks'() {
        assertEquals('4 weeks', SayableDuration.formatDurationSecondsDefault(2419200))
    }

    // ================================================================
    // Section 9: Duration — months and years tier
    // ================================================================

    // 9.1
    @Test
    void 'one month'() {
        assertEquals('1 month', SayableDuration.formatDurationSecondsDefault(2678400))
    }

    // 9.2
    @Test
    void 'three months'() {
        assertEquals('3 months', SayableDuration.formatDurationSecondsDefault(7884000))
    }

    // 9.3
    @Test
    void 'one year'() {
        assertEquals('1 year', SayableDuration.formatDurationSecondsDefault(31536000))
    }

    // 9.4
    @Test
    void 'one year three months'() {
        assertEquals('1 year, 3 months', SayableDuration.formatDurationSecondsDefault(39420000))
    }

    // ================================================================
    // Section 10: Duration from ISO timestamps
    // ================================================================

    // 10.1
    @Test
    void 'ISO one and a half hours'() {
        assertEquals(
            "1\u00BD hours",
            SayableDuration.formatDurationIsoDefault('2025-01-15T10:00:00', '2025-01-15T11:30:00')
        )
    }

    // 10.2
    @Test
    void 'ISO forty-five minutes'() {
        assertEquals(
            '45 minutes',
            SayableDuration.formatDurationIsoDefault('2025-01-15T10:00:00', '2025-01-15T10:45:00')
        )
    }

    // ================================================================
    // Section 11: Relative time — since
    // ================================================================

    // 11.1
    @Test
    void 'since just now'() {
        assertEquals(
            'just now',
            SayableDuration.formatSinceDefault('2025-01-15T10:00:00', '2025-01-15T10:00:00')
        )
    }

    // 11.2
    @Test
    void 'since thirty seconds ago'() {
        assertEquals(
            '30 seconds ago',
            SayableDuration.formatSinceDefault('2025-01-15T10:00:00', '2025-01-15T10:00:30')
        )
    }

    // 11.3
    @Test
    void 'since forty-five minutes ago'() {
        assertEquals(
            '45 minutes ago',
            SayableDuration.formatSinceDefault('2025-01-15T10:00:00', '2025-01-15T10:45:00')
        )
    }

    // 11.4
    @Test
    void 'since three hours ago'() {
        assertEquals(
            '3 hours ago',
            SayableDuration.formatSinceDefault('2025-01-15T10:00:00', '2025-01-15T13:00:00')
        )
    }

    // ================================================================
    // Section 12: Relative time — until
    // ================================================================

    // 12.1
    @Test
    void 'until just now'() {
        assertEquals(
            'just now',
            SayableDuration.formatUntilDefault('2025-01-15T10:00:00', '2025-01-15T10:00:00')
        )
    }

    // 12.2
    @Test
    void 'until in twenty minutes'() {
        assertEquals(
            'in 20 minutes',
            SayableDuration.formatUntilDefault('2025-01-15T10:20:00', '2025-01-15T10:00:00')
        )
    }

    // 12.3
    @Test
    void 'until in three hours'() {
        assertEquals(
            'in 3 hours',
            SayableDuration.formatUntilDefault('2025-01-15T13:00:00', '2025-01-15T10:00:00')
        )
    }

    // ================================================================
    // Section 13: Locale — German
    // ================================================================

    // 13.1
    @Test
    void 'German one hour'() {
        SayableDuration sd = new SayableDuration(Locales.DE)
        assertEquals('1 Stunde', sd.formatDurationSeconds(3600))
    }

    // 13.2
    @Test
    void 'German since five minutes'() {
        SayableDuration sd = new SayableDuration(Locales.DE)
        assertEquals(
            'vor 5 Minuten',
            sd.formatSince('2025-01-15T10:00:00', '2025-01-15T10:05:00')
        )
    }

    // ================================================================
    // Section 14: Locale — French
    // ================================================================

    // 14.1
    @Test
    void 'French two hours'() {
        SayableDuration sd = new SayableDuration(Locales.FR)
        assertEquals('2 heures', sd.formatDurationSeconds(7200))
    }

    // ================================================================
    // Section 15: Locale — Japanese
    // ================================================================

    // 15.1
    @Test
    void 'Japanese two minutes'() {
        SayableDuration sd = new SayableDuration(Locales.JA)
        assertEquals("2\u5206", sd.formatDurationSeconds(120))
    }

    // 15.2
    @Test
    void 'Japanese since one hour'() {
        SayableDuration sd = new SayableDuration(Locales.JA)
        assertEquals(
            "1\u6642\u9593\u524D",
            sd.formatSince('2025-01-15T10:00:00', '2025-01-15T11:00:00')
        )
    }

    // ================================================================
    // Section 16: Short compactness — duration
    // ================================================================

    // 16.1
    @Test
    void 'short one hour'() {
        SayableDuration sd = new SayableDuration(Locales.EN, Compactness.SHORT)
        assertEquals('1h', sd.formatDurationSeconds(3600))
    }

    // 16.2
    @Test
    void 'short one minute thirty seconds'() {
        SayableDuration sd = new SayableDuration(Locales.EN, Compactness.SHORT)
        assertEquals('1m, 30s', sd.formatDurationSeconds(90))
    }

    // ================================================================
    // Section 17: Compact compactness — duration
    // ================================================================

    // 17.1
    @Test
    void 'compact one hour'() {
        SayableDuration sd = new SayableDuration(Locales.EN, Compactness.COMPACT)
        assertEquals('1h', sd.formatDurationSeconds(3600))
    }

    // 17.2
    @Test
    void 'compact one minute thirty seconds'() {
        SayableDuration sd = new SayableDuration(Locales.EN, Compactness.COMPACT)
        assertEquals('1m30s', sd.formatDurationSeconds(90))
    }

    // ================================================================
    // Short compactness — relative time
    // ================================================================

    // 18.1
    @Test
    void 'days and hours both kept'() {
        SayableDuration f = new SayableDuration(Locales.MEN, Compactness.SHORT)
        assertEquals('l\u0254h\u0254nga 2, awa 14 taa gb\u0254y\u0254', f.formatSince('2025-01-20T01:32:11', '2025-01-22T15:39:16'))
    }

    // ================================================================
    // Range (500-year ceiling)
    // ================================================================

    // 19.1
    @Test
    void '500 julian years 6000 months the ceiling'() {
        SayableDuration f = new SayableDuration(Locales.EN)
        assertEquals('500 years', f.formatDurationSeconds(15778800000L))
    }

    // 19.2
    @Test
    void 'over 6000 months'() {
        SayableDuration f = new SayableDuration(Locales.EN)
        assertNull(f.formatDurationSeconds(15800000000L))
    }

    // 19.3
    @Test
    void 'well beyond the ceiling and 32 bit'() {
        SayableDuration f = new SayableDuration(Locales.EN)
        assertNull(f.formatDurationSeconds(99999999999L))
    }

    // 19.4
    @Test
    void '525 years ago'() {
        SayableDuration f = new SayableDuration(Locales.EN)
        assertNull(f.formatSince('1500-01-01T00:00:00', '2025-01-01T00:00:00'))
    }

    // 19.5
    @Test
    void '575 years from now'() {
        SayableDuration f = new SayableDuration(Locales.EN)
        assertNull(f.formatUntil('2600-01-01T00:00:00', '2025-01-01T00:00:00'))
    }

    // ================================================================
    // Timestamp validation
    // ================================================================

    // 20.1
    @Test
    void 'seconds are optional'() {
        SayableDuration f = new SayableDuration(Locales.EN)
        assertEquals('1\u00BD hours', f.formatDurationIso('2025-01-15T10:00', '2025-01-15T11:30:00'))
    }

    // 20.2
    @Test
    void 'minutes are required'() {
        SayableDuration f = new SayableDuration(Locales.EN)
        assertNull(f.formatDurationIso('2025-01-15T10', '2025-01-15T11:30:00'))
    }

    // 20.3
    @Test
    void 'unpadded date'() {
        SayableDuration f = new SayableDuration(Locales.EN)
        assertNull(f.formatDurationIso('2025-1-5T10:00:00', '2025-01-15T11:30:00'))
    }

    // 20.4
    @Test
    void 'impossible date'() {
        SayableDuration f = new SayableDuration(Locales.EN)
        assertNull(f.formatDurationIso('2025-02-30T10:00:00', '2025-03-15T11:30:00'))
    }

    // 20.5
    @Test
    void 'hour out of range'() {
        SayableDuration f = new SayableDuration(Locales.EN)
        assertNull(f.formatSince('2025-01-15T10:00:00', '2025-01-15T25:00:00'))
    }
}
