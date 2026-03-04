package sayableduration

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Test
import sayableduration.locales.Locales

class FormatDurationTest {

    // ================================================================
    // Section 1: Null / edge cases
    // ================================================================

    // 1.1
    @Test
    fun `format_duration null returns null`() {
        assertNull(SayableDuration.formatDurationSeconds(-1))
    }

    // 1.2
    @Test
    fun `format_duration negative returns null`() {
        assertNull(SayableDuration.formatDurationSeconds(-1))
    }

    // 1.3
    @Test
    fun `format_since null start returns null`() {
        assertNull(SayableDuration.formatSince(null, "2025-01-15T10:00:00"))
    }

    // 1.4
    @Test
    fun `format_until null target returns null`() {
        assertNull(SayableDuration.formatUntil(null, "2025-01-15T10:00:00"))
    }

    // 1.5
    @Test
    fun `format_since asOf before start returns null`() {
        assertNull(SayableDuration.formatSince("2025-01-15T10:00:00", "2025-01-15T09:00:00"))
    }

    // 1.6
    @Test
    fun `format_until target in the past returns null`() {
        assertNull(SayableDuration.formatUntil("2025-01-15T09:00:00", "2025-01-15T10:00:00"))
    }

    // ================================================================
    // Section 2: Duration — seconds tier (0-59s)
    // ================================================================

    // 2.1
    @Test
    fun `0 seconds is just now`() {
        assertEquals("just now", SayableDuration.formatDurationSeconds(0))
    }

    // 2.2
    @Test
    fun `1 second`() {
        assertEquals("1 second", SayableDuration.formatDurationSeconds(1))
    }

    // 2.3
    @Test
    fun `45 seconds`() {
        assertEquals("45 seconds", SayableDuration.formatDurationSeconds(45))
    }

    // 2.4
    @Test
    fun `59 seconds`() {
        assertEquals("59 seconds", SayableDuration.formatDurationSeconds(59))
    }

    // ================================================================
    // Section 3: Duration — minutes + seconds tier (1-4 min)
    // ================================================================

    // 3.1
    @Test
    fun `1 minute`() {
        assertEquals("1 minute", SayableDuration.formatDurationSeconds(60))
    }

    // 3.2
    @Test
    fun `1 minute 30 seconds`() {
        assertEquals("1 minute, 30 seconds", SayableDuration.formatDurationSeconds(90))
    }

    // 3.3
    @Test
    fun `4 minutes`() {
        assertEquals("4 minutes", SayableDuration.formatDurationSeconds(240))
    }

    // 3.4
    @Test
    fun `4 minutes 30 seconds`() {
        assertEquals("4 minutes, 30 seconds", SayableDuration.formatDurationSeconds(270))
    }

    // ================================================================
    // Section 4: Duration — minutes tier (5-59 min)
    // ================================================================

    // 4.1
    @Test
    fun `5 minutes`() {
        assertEquals("5 minutes", SayableDuration.formatDurationSeconds(300))
    }

    // 4.2
    @Test
    fun `25 minutes`() {
        assertEquals("25 minutes", SayableDuration.formatDurationSeconds(1500))
    }

    // 4.3
    @Test
    fun `59 minutes`() {
        assertEquals("59 minutes", SayableDuration.formatDurationSeconds(3540))
    }

    // ================================================================
    // Section 5: Duration — hours + minutes tier (1-5 hr)
    // ================================================================

    // 5.1
    @Test
    fun `1 hour`() {
        assertEquals("1 hour", SayableDuration.formatDurationSeconds(3600))
    }

    // 5.2
    @Test
    fun `1 and half hours`() {
        assertEquals("1\u00BD hours", SayableDuration.formatDurationSeconds(5400))
    }

    // 5.3
    @Test
    fun `2 hours 15 minutes`() {
        assertEquals("2 hours, 15 minutes", SayableDuration.formatDurationSeconds(8100))
    }

    // 5.4
    @Test
    fun `5 hours`() {
        assertEquals("5 hours", SayableDuration.formatDurationSeconds(18000))
    }

    // ================================================================
    // Section 6: Duration — hours tier (6-23 hr)
    // ================================================================

    // 6.1
    @Test
    fun `8 hours`() {
        assertEquals("8 hours", SayableDuration.formatDurationSeconds(28800))
    }

    // 6.2
    @Test
    fun `23 hours`() {
        assertEquals("23 hours", SayableDuration.formatDurationSeconds(82800))
    }

    // ================================================================
    // Section 7: Duration — days tier
    // ================================================================

    // 7.1
    @Test
    fun `1 day`() {
        assertEquals("1 day", SayableDuration.formatDurationSeconds(86400))
    }

    // 7.2
    @Test
    fun `1 day 3 hours`() {
        assertEquals("1 day, 3 hours", SayableDuration.formatDurationSeconds(97200))
    }

    // 7.3
    @Test
    fun `1 and half days`() {
        assertEquals("1\u00BD days", SayableDuration.formatDurationSeconds(129600))
    }

    // 7.4
    @Test
    fun `5 days`() {
        assertEquals("5 days", SayableDuration.formatDurationSeconds(432000))
    }

    // 7.5
    @Test
    fun `2 days`() {
        assertEquals("2 days", SayableDuration.formatDurationSeconds(172800))
    }

    // ================================================================
    // Section 8: Duration — weeks tier
    // ================================================================

    // 8.1
    @Test
    fun `1 week`() {
        assertEquals("1 week", SayableDuration.formatDurationSeconds(604800))
    }

    // 8.2
    @Test
    fun `2 weeks 1 day`() {
        assertEquals("2 weeks, 1 day", SayableDuration.formatDurationSeconds(1296000))
    }

    // 8.3
    @Test
    fun `4 weeks`() {
        assertEquals("4 weeks", SayableDuration.formatDurationSeconds(2419200))
    }

    // ================================================================
    // Section 9: Duration — months and years tier
    // ================================================================

    // 9.1
    @Test
    fun `1 month`() {
        assertEquals("1 month", SayableDuration.formatDurationSeconds(2678400))
    }

    // 9.2
    @Test
    fun `3 months`() {
        assertEquals("3 months", SayableDuration.formatDurationSeconds(7884000))
    }

    // 9.3
    @Test
    fun `1 year`() {
        assertEquals("1 year", SayableDuration.formatDurationSeconds(31536000))
    }

    // 9.4
    @Test
    fun `1 year 3 months`() {
        assertEquals("1 year, 3 months", SayableDuration.formatDurationSeconds(39420000))
    }

    // ================================================================
    // Section 10: Duration from ISO timestamps
    // ================================================================

    // 10.1
    @Test
    fun `ISO 1 and half hours`() {
        assertEquals(
            "1\u00BD hours",
            SayableDuration.formatDurationIso("2025-01-15T10:00:00", "2025-01-15T11:30:00")
        )
    }

    // 10.2
    @Test
    fun `ISO 45 minutes`() {
        assertEquals(
            "45 minutes",
            SayableDuration.formatDurationIso("2025-01-15T10:00:00", "2025-01-15T10:45:00")
        )
    }

    // ================================================================
    // Section 11: Relative time — since
    // ================================================================

    // 11.1
    @Test
    fun `since just now`() {
        assertEquals(
            "just now",
            SayableDuration.formatSince("2025-01-15T10:00:00", "2025-01-15T10:00:00")
        )
    }

    // 11.2
    @Test
    fun `since 30 seconds ago`() {
        assertEquals(
            "30 seconds ago",
            SayableDuration.formatSince("2025-01-15T10:00:00", "2025-01-15T10:00:30")
        )
    }

    // 11.3
    @Test
    fun `since 45 minutes ago`() {
        assertEquals(
            "45 minutes ago",
            SayableDuration.formatSince("2025-01-15T10:00:00", "2025-01-15T10:45:00")
        )
    }

    // 11.4
    @Test
    fun `since 3 hours ago`() {
        assertEquals(
            "3 hours ago",
            SayableDuration.formatSince("2025-01-15T10:00:00", "2025-01-15T13:00:00")
        )
    }

    // ================================================================
    // Section 12: Relative time — until
    // ================================================================

    // 12.1
    @Test
    fun `until just now`() {
        assertEquals(
            "just now",
            SayableDuration.formatUntil("2025-01-15T10:00:00", "2025-01-15T10:00:00")
        )
    }

    // 12.2
    @Test
    fun `until in 20 minutes`() {
        assertEquals(
            "in 20 minutes",
            SayableDuration.formatUntil("2025-01-15T10:20:00", "2025-01-15T10:00:00")
        )
    }

    // 12.3
    @Test
    fun `until in 3 hours`() {
        assertEquals(
            "in 3 hours",
            SayableDuration.formatUntil("2025-01-15T13:00:00", "2025-01-15T10:00:00")
        )
    }

    // ================================================================
    // Section 13: Locale — German
    // ================================================================

    // 13.1
    @Test
    fun `German 1 hour`() {
        val sd = SayableDuration(Locales.DE)
        assertEquals("1 Stunde", sd.formatDurationSeconds(3600))
    }

    // 13.2
    @Test
    fun `German since 5 minutes`() {
        val sd = SayableDuration(Locales.DE)
        assertEquals(
            "vor 5 Minuten",
            sd.formatSince("2025-01-15T10:00:00", "2025-01-15T10:05:00")
        )
    }

    // ================================================================
    // Section 14: Locale — French
    // ================================================================

    // 14.1
    @Test
    fun `French 2 hours`() {
        val sd = SayableDuration(Locales.FR)
        assertEquals("2 heures", sd.formatDurationSeconds(7200))
    }

    // ================================================================
    // Section 15: Locale — Japanese
    // ================================================================

    // 15.1
    @Test
    fun `Japanese 2 minutes`() {
        val sd = SayableDuration(Locales.JA)
        assertEquals("2\u5206", sd.formatDurationSeconds(120))
    }

    // 15.2
    @Test
    fun `Japanese since 1 hour`() {
        val sd = SayableDuration(Locales.JA)
        assertEquals(
            "1\u6642\u9593\u524D",
            sd.formatSince("2025-01-15T10:00:00", "2025-01-15T11:00:00")
        )
    }

    // ================================================================
    // Section 16: Short compactness — duration
    // ================================================================

    // 16.1
    @Test
    fun `short 1 hour`() {
        val sd = SayableDuration(Locales.EN, Compactness.SHORT)
        assertEquals("1h", sd.formatDurationSeconds(3600))
    }

    // 16.2
    @Test
    fun `short 1 minute 30 seconds`() {
        val sd = SayableDuration(Locales.EN, Compactness.SHORT)
        assertEquals("1m, 30s", sd.formatDurationSeconds(90))
    }

    // ================================================================
    // Section 17: Compact compactness — duration
    // ================================================================

    // 17.1
    @Test
    fun `compact 1 hour`() {
        val sd = SayableDuration(Locales.EN, Compactness.COMPACT)
        assertEquals("1h", sd.formatDurationSeconds(3600))
    }

    // 17.2
    @Test
    fun `compact 1 minute 30 seconds`() {
        val sd = SayableDuration(Locales.EN, Compactness.COMPACT)
        assertEquals("1m30s", sd.formatDurationSeconds(90))
    }
}
