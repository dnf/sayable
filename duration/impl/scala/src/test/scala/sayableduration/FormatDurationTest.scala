package sayableduration

import org.junit.jupiter.api.Assertions.{assertEquals, assertTrue}
import org.junit.jupiter.api.Test
import sayableduration.locales.Locales

class FormatDurationTest:

    // ================================================================
    // Section 1: Null / edge cases
    // ================================================================

    // 1.1
    @Test
    def `format_duration null returns None`(): Unit =
        assertTrue(SayableDuration.formatDurationSeconds(-1).isEmpty)

    // 1.2
    @Test
    def `format_duration negative returns None`(): Unit =
        assertTrue(SayableDuration.formatDurationSeconds(-1).isEmpty)

    // 1.3
    @Test
    def `format_since null start returns None`(): Unit =
        assertTrue(SayableDuration.formatSince(null, "2025-01-15T10:00:00").isEmpty)

    // 1.4
    @Test
    def `format_until null target returns None`(): Unit =
        assertTrue(SayableDuration.formatUntil(null, "2025-01-15T10:00:00").isEmpty)

    // 1.5
    @Test
    def `format_since asOf before start returns None`(): Unit =
        assertTrue(SayableDuration.formatSince("2025-01-15T10:00:00", "2025-01-15T09:00:00").isEmpty)

    // 1.6
    @Test
    def `format_until target in the past returns None`(): Unit =
        assertTrue(SayableDuration.formatUntil("2025-01-15T09:00:00", "2025-01-15T10:00:00").isEmpty)

    // ================================================================
    // Section 2: Duration — seconds tier (0-59s)
    // ================================================================

    // 2.1
    @Test
    def `0 seconds is just now`(): Unit =
        assertEquals(Some("just now"), SayableDuration.formatDurationSeconds(0))

    // 2.2
    @Test
    def `1 second`(): Unit =
        assertEquals(Some("1 second"), SayableDuration.formatDurationSeconds(1))

    // 2.3
    @Test
    def `45 seconds`(): Unit =
        assertEquals(Some("45 seconds"), SayableDuration.formatDurationSeconds(45))

    // 2.4
    @Test
    def `59 seconds`(): Unit =
        assertEquals(Some("59 seconds"), SayableDuration.formatDurationSeconds(59))

    // ================================================================
    // Section 3: Duration — minutes + seconds tier (1-4 min)
    // ================================================================

    // 3.1
    @Test
    def `1 minute`(): Unit =
        assertEquals(Some("1 minute"), SayableDuration.formatDurationSeconds(60))

    // 3.2
    @Test
    def `1 minute 30 seconds`(): Unit =
        assertEquals(Some("1 minute, 30 seconds"), SayableDuration.formatDurationSeconds(90))

    // 3.3
    @Test
    def `4 minutes`(): Unit =
        assertEquals(Some("4 minutes"), SayableDuration.formatDurationSeconds(240))

    // 3.4
    @Test
    def `4 minutes 30 seconds`(): Unit =
        assertEquals(Some("4 minutes, 30 seconds"), SayableDuration.formatDurationSeconds(270))

    // ================================================================
    // Section 4: Duration — minutes tier (5-59 min)
    // ================================================================

    // 4.1
    @Test
    def `5 minutes`(): Unit =
        assertEquals(Some("5 minutes"), SayableDuration.formatDurationSeconds(300))

    // 4.2
    @Test
    def `25 minutes`(): Unit =
        assertEquals(Some("25 minutes"), SayableDuration.formatDurationSeconds(1500))

    // 4.3
    @Test
    def `59 minutes`(): Unit =
        assertEquals(Some("59 minutes"), SayableDuration.formatDurationSeconds(3540))

    // ================================================================
    // Section 5: Duration — hours + minutes tier (1-5 hr)
    // ================================================================

    // 5.1
    @Test
    def `1 hour`(): Unit =
        assertEquals(Some("1 hour"), SayableDuration.formatDurationSeconds(3600))

    // 5.2
    @Test
    def `1 and half hours`(): Unit =
        assertEquals(Some("1\u00BD hours"), SayableDuration.formatDurationSeconds(5400))

    // 5.3
    @Test
    def `2 hours 15 minutes`(): Unit =
        assertEquals(Some("2 hours, 15 minutes"), SayableDuration.formatDurationSeconds(8100))

    // 5.4
    @Test
    def `5 hours`(): Unit =
        assertEquals(Some("5 hours"), SayableDuration.formatDurationSeconds(18000))

    // ================================================================
    // Section 6: Duration — hours tier (6-23 hr)
    // ================================================================

    // 6.1
    @Test
    def `8 hours`(): Unit =
        assertEquals(Some("8 hours"), SayableDuration.formatDurationSeconds(28800))

    // 6.2
    @Test
    def `23 hours`(): Unit =
        assertEquals(Some("23 hours"), SayableDuration.formatDurationSeconds(82800))

    // ================================================================
    // Section 7: Duration — days tier
    // ================================================================

    // 7.1
    @Test
    def `1 day`(): Unit =
        assertEquals(Some("1 day"), SayableDuration.formatDurationSeconds(86400))

    // 7.2
    @Test
    def `1 day 3 hours`(): Unit =
        assertEquals(Some("1 day, 3 hours"), SayableDuration.formatDurationSeconds(97200))

    // 7.3
    @Test
    def `1 and half days`(): Unit =
        assertEquals(Some("1\u00BD days"), SayableDuration.formatDurationSeconds(129600))

    // 7.4
    @Test
    def `5 days`(): Unit =
        assertEquals(Some("5 days"), SayableDuration.formatDurationSeconds(432000))

    // 7.5
    @Test
    def `2 days`(): Unit =
        assertEquals(Some("2 days"), SayableDuration.formatDurationSeconds(172800))

    // ================================================================
    // Section 8: Duration — weeks tier
    // ================================================================

    // 8.1
    @Test
    def `1 week`(): Unit =
        assertEquals(Some("1 week"), SayableDuration.formatDurationSeconds(604800))

    // 8.2
    @Test
    def `2 weeks 1 day`(): Unit =
        assertEquals(Some("2 weeks, 1 day"), SayableDuration.formatDurationSeconds(1296000))

    // 8.3
    @Test
    def `4 weeks`(): Unit =
        assertEquals(Some("4 weeks"), SayableDuration.formatDurationSeconds(2419200))

    // ================================================================
    // Section 9: Duration — months and years tier
    // ================================================================

    // 9.1
    @Test
    def `1 month`(): Unit =
        assertEquals(Some("1 month"), SayableDuration.formatDurationSeconds(2678400))

    // 9.2
    @Test
    def `3 months`(): Unit =
        assertEquals(Some("3 months"), SayableDuration.formatDurationSeconds(7884000))

    // 9.3
    @Test
    def `1 year`(): Unit =
        assertEquals(Some("1 year"), SayableDuration.formatDurationSeconds(31536000))

    // 9.4
    @Test
    def `1 year 3 months`(): Unit =
        assertEquals(Some("1 year, 3 months"), SayableDuration.formatDurationSeconds(39420000))

    // ================================================================
    // Section 10: Duration from ISO timestamps
    // ================================================================

    // 10.1
    @Test
    def `ISO 1 and half hours`(): Unit =
        assertEquals(
            Some("1\u00BD hours"),
            SayableDuration.formatDurationIso("2025-01-15T10:00:00", "2025-01-15T11:30:00")
        )

    // 10.2
    @Test
    def `ISO 45 minutes`(): Unit =
        assertEquals(
            Some("45 minutes"),
            SayableDuration.formatDurationIso("2025-01-15T10:00:00", "2025-01-15T10:45:00")
        )

    // ================================================================
    // Section 11: Relative time — since
    // ================================================================

    // 11.1
    @Test
    def `since just now`(): Unit =
        assertEquals(
            Some("just now"),
            SayableDuration.formatSince("2025-01-15T10:00:00", "2025-01-15T10:00:00")
        )

    // 11.2
    @Test
    def `since 30 seconds ago`(): Unit =
        assertEquals(
            Some("30 seconds ago"),
            SayableDuration.formatSince("2025-01-15T10:00:00", "2025-01-15T10:00:30")
        )

    // 11.3
    @Test
    def `since 45 minutes ago`(): Unit =
        assertEquals(
            Some("45 minutes ago"),
            SayableDuration.formatSince("2025-01-15T10:00:00", "2025-01-15T10:45:00")
        )

    // 11.4
    @Test
    def `since 3 hours ago`(): Unit =
        assertEquals(
            Some("3 hours ago"),
            SayableDuration.formatSince("2025-01-15T10:00:00", "2025-01-15T13:00:00")
        )

    // ================================================================
    // Section 12: Relative time — until
    // ================================================================

    // 12.1
    @Test
    def `until just now`(): Unit =
        assertEquals(
            Some("just now"),
            SayableDuration.formatUntil("2025-01-15T10:00:00", "2025-01-15T10:00:00")
        )

    // 12.2
    @Test
    def `until in 20 minutes`(): Unit =
        assertEquals(
            Some("in 20 minutes"),
            SayableDuration.formatUntil("2025-01-15T10:20:00", "2025-01-15T10:00:00")
        )

    // 12.3
    @Test
    def `until in 3 hours`(): Unit =
        assertEquals(
            Some("in 3 hours"),
            SayableDuration.formatUntil("2025-01-15T13:00:00", "2025-01-15T10:00:00")
        )

    // ================================================================
    // Section 13: Locale — German
    // ================================================================

    // 13.1
    @Test
    def `German 1 hour`(): Unit =
        val sd = SayableDuration(Locales.DE)
        assertEquals(Some("1 Stunde"), sd.formatDurationSeconds(3600))

    // 13.2
    @Test
    def `German since 5 minutes`(): Unit =
        val sd = SayableDuration(Locales.DE)
        assertEquals(
            Some("vor 5 Minuten"),
            sd.formatSince("2025-01-15T10:00:00", "2025-01-15T10:05:00")
        )

    // ================================================================
    // Section 14: Locale — French
    // ================================================================

    // 14.1
    @Test
    def `French 2 hours`(): Unit =
        val sd = SayableDuration(Locales.FR)
        assertEquals(Some("2 heures"), sd.formatDurationSeconds(7200))

    // ================================================================
    // Section 15: Locale — Japanese
    // ================================================================

    // 15.1
    @Test
    def `Japanese 2 minutes`(): Unit =
        val sd = SayableDuration(Locales.JA)
        assertEquals(Some("2\u5206"), sd.formatDurationSeconds(120))

    // 15.2
    @Test
    def `Japanese since 1 hour`(): Unit =
        val sd = SayableDuration(Locales.JA)
        assertEquals(
            Some("1\u6642\u9593\u524D"),
            sd.formatSince("2025-01-15T10:00:00", "2025-01-15T11:00:00")
        )

    // ================================================================
    // Section 16: Short compactness — duration
    // ================================================================

    // 16.1
    @Test
    def `short 1 hour`(): Unit =
        val sd = SayableDuration(Locales.EN, Compactness.SHORT)
        assertEquals(Some("1h"), sd.formatDurationSeconds(3600))

    // 16.2
    @Test
    def `short 1 minute 30 seconds`(): Unit =
        val sd = SayableDuration(Locales.EN, Compactness.SHORT)
        assertEquals(Some("1m, 30s"), sd.formatDurationSeconds(90))

    // ================================================================
    // Section 17: Compact compactness — duration
    // ================================================================

    // 17.1
    @Test
    def `compact 1 hour`(): Unit =
        val sd = SayableDuration(Locales.EN, Compactness.COMPACT)
        assertEquals(Some("1h"), sd.formatDurationSeconds(3600))

    // 17.2
    @Test
    def `compact 1 minute 30 seconds`(): Unit =
        val sd = SayableDuration(Locales.EN, Compactness.COMPACT)
        assertEquals(Some("1m30s"), sd.formatDurationSeconds(90))

    // ================================================================
    // Short compactness — relative time
    // ================================================================

    // 18.1
    @Test
    def `days and hours both kept`(): Unit =
        val f = SayableDuration(Locales.MEN, Compactness.SHORT)
        assertEquals(Some("l\u0254h\u0254nga 2, awa 14 taa gb\u0254y\u0254"), f.formatSince("2025-01-20T01:32:11", "2025-01-22T15:39:16"))

    // ================================================================
    // Range (500-year ceiling)
    // ================================================================

    // 19.1
    @Test
    def `500 julian years 6000 months the ceiling`(): Unit =
        val f = SayableDuration(Locales.EN)
        assertEquals(Some("500 years"), f.formatDurationSeconds(15778800000L))

    // 19.2
    @Test
    def `over 6000 months`(): Unit =
        val f = SayableDuration(Locales.EN)
        assertEquals(None, f.formatDurationSeconds(15800000000L))

    // 19.3
    @Test
    def `well beyond the ceiling and 32 bit`(): Unit =
        val f = SayableDuration(Locales.EN)
        assertEquals(None, f.formatDurationSeconds(99999999999L))

    // 19.4
    @Test
    def `525 years ago`(): Unit =
        val f = SayableDuration(Locales.EN)
        assertEquals(None, f.formatSince("1500-01-01T00:00:00", "2025-01-01T00:00:00"))

    // 19.5
    @Test
    def `575 years from now`(): Unit =
        val f = SayableDuration(Locales.EN)
        assertEquals(None, f.formatUntil("2600-01-01T00:00:00", "2025-01-01T00:00:00"))

    // ================================================================
    // Timestamp validation
    // ================================================================

    // 20.1
    @Test
    def `seconds are optional`(): Unit =
        val f = SayableDuration(Locales.EN)
        assertEquals(Some("1\u00BD hours"), f.formatDurationIso("2025-01-15T10:00", "2025-01-15T11:30:00"))

    // 20.2
    @Test
    def `minutes are required`(): Unit =
        val f = SayableDuration(Locales.EN)
        assertEquals(None, f.formatDurationIso("2025-01-15T10", "2025-01-15T11:30:00"))

    // 20.3
    @Test
    def `unpadded date`(): Unit =
        val f = SayableDuration(Locales.EN)
        assertEquals(None, f.formatDurationIso("2025-1-5T10:00:00", "2025-01-15T11:30:00"))

    // 20.4
    @Test
    def `impossible date`(): Unit =
        val f = SayableDuration(Locales.EN)
        assertEquals(None, f.formatDurationIso("2025-02-30T10:00:00", "2025-03-15T11:30:00"))

    // 20.5
    @Test
    def `hour out of range`(): Unit =
        val f = SayableDuration(Locales.EN)
        assertEquals(None, f.formatSince("2025-01-15T10:00:00", "2025-01-15T25:00:00"))
