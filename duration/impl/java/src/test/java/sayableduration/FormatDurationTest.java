package sayableduration;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import org.junit.jupiter.api.Test;
import sayableduration.locales.Locales;

class FormatDurationTest {

    // ================================================================
    // Section 1: Null / edge cases
    // ================================================================

    // 1.1
    @Test
    void formatDurationNullReturnsNull() {
        assertNull(SayableDuration.formatDurationSecondsDefault(-1));
    }

    // 1.2
    @Test
    void formatDurationNegativeReturnsNull() {
        assertNull(SayableDuration.formatDurationSecondsDefault(-1));
    }

    // 1.3
    @Test
    void formatSinceNullStartReturnsNull() {
        assertNull(SayableDuration.formatSinceDefault(null, "2025-01-15T10:00:00"));
    }

    // 1.4
    @Test
    void formatUntilNullTargetReturnsNull() {
        assertNull(SayableDuration.formatUntilDefault(null, "2025-01-15T10:00:00"));
    }

    // 1.5
    @Test
    void formatSinceAsOfBeforeStartReturnsNull() {
        assertNull(SayableDuration.formatSinceDefault("2025-01-15T10:00:00", "2025-01-15T09:00:00"));
    }

    // 1.6
    @Test
    void formatUntilTargetInThePastReturnsNull() {
        assertNull(SayableDuration.formatUntilDefault("2025-01-15T09:00:00", "2025-01-15T10:00:00"));
    }

    // ================================================================
    // Section 2: Duration — seconds tier (0-59s)
    // ================================================================

    // 2.1
    @Test
    void zeroSecondsIsJustNow() {
        assertEquals("just now", SayableDuration.formatDurationSecondsDefault(0));
    }

    // 2.2
    @Test
    void oneSecond() {
        assertEquals("1 second", SayableDuration.formatDurationSecondsDefault(1));
    }

    // 2.3
    @Test
    void fortyFiveSeconds() {
        assertEquals("45 seconds", SayableDuration.formatDurationSecondsDefault(45));
    }

    // 2.4
    @Test
    void fiftyNineSeconds() {
        assertEquals("59 seconds", SayableDuration.formatDurationSecondsDefault(59));
    }

    // ================================================================
    // Section 3: Duration — minutes + seconds tier (1-4 min)
    // ================================================================

    // 3.1
    @Test
    void oneMinute() {
        assertEquals("1 minute", SayableDuration.formatDurationSecondsDefault(60));
    }

    // 3.2
    @Test
    void oneMinuteThirtySeconds() {
        assertEquals("1 minute, 30 seconds", SayableDuration.formatDurationSecondsDefault(90));
    }

    // 3.3
    @Test
    void fourMinutes() {
        assertEquals("4 minutes", SayableDuration.formatDurationSecondsDefault(240));
    }

    // 3.4
    @Test
    void fourMinutesThirtySeconds() {
        assertEquals("4 minutes, 30 seconds", SayableDuration.formatDurationSecondsDefault(270));
    }

    // ================================================================
    // Section 4: Duration — minutes tier (5-59 min)
    // ================================================================

    // 4.1
    @Test
    void fiveMinutes() {
        assertEquals("5 minutes", SayableDuration.formatDurationSecondsDefault(300));
    }

    // 4.2
    @Test
    void twentyFiveMinutes() {
        assertEquals("25 minutes", SayableDuration.formatDurationSecondsDefault(1500));
    }

    // 4.3
    @Test
    void fiftyNineMinutes() {
        assertEquals("59 minutes", SayableDuration.formatDurationSecondsDefault(3540));
    }

    // ================================================================
    // Section 5: Duration — hours + minutes tier (1-5 hr)
    // ================================================================

    // 5.1
    @Test
    void oneHour() {
        assertEquals("1 hour", SayableDuration.formatDurationSecondsDefault(3600));
    }

    // 5.2
    @Test
    void oneAndHalfHours() {
        assertEquals("1\u00BD hours", SayableDuration.formatDurationSecondsDefault(5400));
    }

    // 5.3
    @Test
    void twoHoursFifteenMinutes() {
        assertEquals("2 hours, 15 minutes", SayableDuration.formatDurationSecondsDefault(8100));
    }

    // 5.4
    @Test
    void fiveHours() {
        assertEquals("5 hours", SayableDuration.formatDurationSecondsDefault(18000));
    }

    // ================================================================
    // Section 6: Duration — hours tier (6-23 hr)
    // ================================================================

    // 6.1
    @Test
    void eightHours() {
        assertEquals("8 hours", SayableDuration.formatDurationSecondsDefault(28800));
    }

    // 6.2
    @Test
    void twentyThreeHours() {
        assertEquals("23 hours", SayableDuration.formatDurationSecondsDefault(82800));
    }

    // ================================================================
    // Section 7: Duration — days tier
    // ================================================================

    // 7.1
    @Test
    void oneDay() {
        assertEquals("1 day", SayableDuration.formatDurationSecondsDefault(86400));
    }

    // 7.2
    @Test
    void oneDayThreeHours() {
        assertEquals("1 day, 3 hours", SayableDuration.formatDurationSecondsDefault(97200));
    }

    // 7.3
    @Test
    void oneAndHalfDays() {
        assertEquals("1\u00BD days", SayableDuration.formatDurationSecondsDefault(129600));
    }

    // 7.4
    @Test
    void fiveDays() {
        assertEquals("5 days", SayableDuration.formatDurationSecondsDefault(432000));
    }

    // 7.5
    @Test
    void twoDays() {
        assertEquals("2 days", SayableDuration.formatDurationSecondsDefault(172800));
    }

    // ================================================================
    // Section 8: Duration — weeks tier
    // ================================================================

    // 8.1
    @Test
    void oneWeek() {
        assertEquals("1 week", SayableDuration.formatDurationSecondsDefault(604800));
    }

    // 8.2
    @Test
    void twoWeeksOneDay() {
        assertEquals("2 weeks, 1 day", SayableDuration.formatDurationSecondsDefault(1296000));
    }

    // 8.3
    @Test
    void fourWeeks() {
        assertEquals("4 weeks", SayableDuration.formatDurationSecondsDefault(2419200));
    }

    // ================================================================
    // Section 9: Duration — months and years tier
    // ================================================================

    // 9.1
    @Test
    void oneMonth() {
        assertEquals("1 month", SayableDuration.formatDurationSecondsDefault(2678400));
    }

    // 9.2
    @Test
    void threeMonths() {
        assertEquals("3 months", SayableDuration.formatDurationSecondsDefault(7884000));
    }

    // 9.3
    @Test
    void oneYear() {
        assertEquals("1 year", SayableDuration.formatDurationSecondsDefault(31536000));
    }

    // 9.4
    @Test
    void oneYearThreeMonths() {
        assertEquals("1 year, 3 months", SayableDuration.formatDurationSecondsDefault(39420000));
    }

    // ================================================================
    // Section 10: Duration from ISO timestamps
    // ================================================================

    // 10.1
    @Test
    void isoOneAndHalfHours() {
        assertEquals(
            "1\u00BD hours",
            SayableDuration.formatDurationIsoDefault("2025-01-15T10:00:00", "2025-01-15T11:30:00")
        );
    }

    // 10.2
    @Test
    void isoFortyFiveMinutes() {
        assertEquals(
            "45 minutes",
            SayableDuration.formatDurationIsoDefault("2025-01-15T10:00:00", "2025-01-15T10:45:00")
        );
    }

    // ================================================================
    // Section 11: Relative time — since
    // ================================================================

    // 11.1
    @Test
    void sinceJustNow() {
        assertEquals(
            "just now",
            SayableDuration.formatSinceDefault("2025-01-15T10:00:00", "2025-01-15T10:00:00")
        );
    }

    // 11.2
    @Test
    void sinceThirtySecondsAgo() {
        assertEquals(
            "30 seconds ago",
            SayableDuration.formatSinceDefault("2025-01-15T10:00:00", "2025-01-15T10:00:30")
        );
    }

    // 11.3
    @Test
    void sinceFortyFiveMinutesAgo() {
        assertEquals(
            "45 minutes ago",
            SayableDuration.formatSinceDefault("2025-01-15T10:00:00", "2025-01-15T10:45:00")
        );
    }

    // 11.4
    @Test
    void sinceThreeHoursAgo() {
        assertEquals(
            "3 hours ago",
            SayableDuration.formatSinceDefault("2025-01-15T10:00:00", "2025-01-15T13:00:00")
        );
    }

    // ================================================================
    // Section 12: Relative time — until
    // ================================================================

    // 12.1
    @Test
    void untilJustNow() {
        assertEquals(
            "just now",
            SayableDuration.formatUntilDefault("2025-01-15T10:00:00", "2025-01-15T10:00:00")
        );
    }

    // 12.2
    @Test
    void untilInTwentyMinutes() {
        assertEquals(
            "in 20 minutes",
            SayableDuration.formatUntilDefault("2025-01-15T10:20:00", "2025-01-15T10:00:00")
        );
    }

    // 12.3
    @Test
    void untilInThreeHours() {
        assertEquals(
            "in 3 hours",
            SayableDuration.formatUntilDefault("2025-01-15T13:00:00", "2025-01-15T10:00:00")
        );
    }

    // ================================================================
    // Section 13: Locale — German
    // ================================================================

    // 13.1
    @Test
    void germanOneHour() {
        SayableDuration sd = new SayableDuration(Locales.DE);
        assertEquals("1 Stunde", sd.formatDurationSeconds(3600));
    }

    // 13.2
    @Test
    void germanSinceFiveMinutes() {
        SayableDuration sd = new SayableDuration(Locales.DE);
        assertEquals(
            "vor 5 Minuten",
            sd.formatSince("2025-01-15T10:00:00", "2025-01-15T10:05:00")
        );
    }

    // ================================================================
    // Section 14: Locale — French
    // ================================================================

    // 14.1
    @Test
    void frenchTwoHours() {
        SayableDuration sd = new SayableDuration(Locales.FR);
        assertEquals("2 heures", sd.formatDurationSeconds(7200));
    }

    // ================================================================
    // Section 15: Locale — Japanese
    // ================================================================

    // 15.1
    @Test
    void japaneseTwoMinutes() {
        SayableDuration sd = new SayableDuration(Locales.JA);
        assertEquals("2\u5206", sd.formatDurationSeconds(120));
    }

    // 15.2
    @Test
    void japaneseSinceOneHour() {
        SayableDuration sd = new SayableDuration(Locales.JA);
        assertEquals(
            "1\u6642\u9593\u524D",
            sd.formatSince("2025-01-15T10:00:00", "2025-01-15T11:00:00")
        );
    }

    // ================================================================
    // Section 16: Short compactness — duration
    // ================================================================

    // 16.1
    @Test
    void shortOneHour() {
        SayableDuration sd = new SayableDuration(Locales.EN, Compactness.SHORT);
        assertEquals("1h", sd.formatDurationSeconds(3600));
    }

    // 16.2
    @Test
    void shortOneMinuteThirtySeconds() {
        SayableDuration sd = new SayableDuration(Locales.EN, Compactness.SHORT);
        assertEquals("1m, 30s", sd.formatDurationSeconds(90));
    }

    // ================================================================
    // Section 17: Compact compactness — duration
    // ================================================================

    // 17.1
    @Test
    void compactOneHour() {
        SayableDuration sd = new SayableDuration(Locales.EN, Compactness.COMPACT);
        assertEquals("1h", sd.formatDurationSeconds(3600));
    }

    // 17.2
    @Test
    void compactOneMinuteThirtySeconds() {
        SayableDuration sd = new SayableDuration(Locales.EN, Compactness.COMPACT);
        assertEquals("1m30s", sd.formatDurationSeconds(90));
    }
}
