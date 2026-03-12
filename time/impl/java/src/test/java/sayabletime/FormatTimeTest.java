package sayabletime;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import org.junit.jupiter.api.Test;
import sayabletime.locales.Locales;

class FormatTimeTest {

    // ================================================================
    // Section 1: Null / edge cases
    // ================================================================

    // 1.1
    @Test
    void nullInputReturnsNull() {
        assertNull(SayableTime.formatTimeDefault(null));
    }

    // 1.2
    @Test
    void emptyStringReturnsNull() {
        assertNull(SayableTime.formatTimeDefault(""));
    }

    // 1.3
    @Test
    void invalidStringReturnsNull() {
        assertNull(SayableTime.formatTimeDefault("invalid"));
    }

    // 1.4
    @Test
    void outOfRangeReturnsNull() {
        assertNull(SayableTime.formatTimeDefault("25:00"));
    }

    // ================================================================
    // Section 2: Clock time (normal compactness)
    // ================================================================

    // 2.1
    @Test
    void midnight() {
        SayableTime st = new SayableTime(Locales.EN);
        assertEquals("midnight", st.formatTime("00:00"));
    }

    // 2.2
    @Test
    void noon() {
        SayableTime st = new SayableTime(Locales.EN);
        assertEquals("noon", st.formatTime("12:00"));
    }

    // 2.3
    @Test
    void oClock() {
        SayableTime st = new SayableTime(Locales.EN);
        assertEquals("three o'clock", st.formatTime("15:00"));
    }

    // 2.4
    @Test
    void quarterPast() {
        SayableTime st = new SayableTime(Locales.EN);
        assertEquals("a quarter past two", st.formatTime("14:15"));
    }

    // 2.5
    @Test
    void halfPast() {
        SayableTime st = new SayableTime(Locales.EN);
        assertEquals("half past nine", st.formatTime("09:30"));
    }

    // 2.6
    @Test
    void quarterTo() {
        SayableTime st = new SayableTime(Locales.EN);
        assertEquals("a quarter to eleven", st.formatTime("10:45"));
    }

    // 2.7
    @Test
    void fivePast() {
        SayableTime st = new SayableTime(Locales.EN);
        assertEquals("five past eight", st.formatTime("08:05"));
    }

    // 2.8
    @Test
    void fiveTo() {
        SayableTime st = new SayableTime(Locales.EN);
        assertEquals("five to five", st.formatTime("16:55"));
    }

    // 2.9 — rounds to 0:00 of next day
    @Test
    void roundsToMidnight() {
        SayableTime st = new SayableTime(Locales.EN);
        assertEquals("midnight", st.formatTime("23:58"));
    }

    // 2.10 — 22 rounds to 20
    @Test
    void roundsToTwenty() {
        SayableTime st = new SayableTime(Locales.EN);
        assertEquals("twenty past seven", st.formatTime("07:22"));
    }

    // 2.11 — ISO datetime input
    @Test
    void isoDatetimeInput() {
        SayableTime st = new SayableTime(Locales.EN);
        assertEquals("a quarter past two", st.formatTime("2025-01-15T14:15:00"));
    }

    // ================================================================
    // Section 3: Clock time (short compactness)
    // ================================================================

    // 3.1
    @Test
    void shortPm() {
        SayableTime st = new SayableTime(Locales.EN, Compactness.SHORT);
        assertEquals("2:15 PM", st.formatTime("14:15"));
    }

    // 3.2
    @Test
    void shortAm() {
        SayableTime st = new SayableTime(Locales.EN, Compactness.SHORT);
        assertEquals("9:30 AM", st.formatTime("09:30"));
    }

    // 3.3
    @Test
    void shortMidnight() {
        SayableTime st = new SayableTime(Locales.EN, Compactness.SHORT);
        assertEquals("12:00 AM", st.formatTime("00:00"));
    }

    // 3.4
    @Test
    void shortNoon() {
        SayableTime st = new SayableTime(Locales.EN, Compactness.SHORT);
        assertEquals("12:00 PM", st.formatTime("12:00"));
    }

    // ================================================================
    // Section 4: Clock time (compact)
    // ================================================================

    // 4.1
    @Test
    void compactPm() {
        SayableTime st = new SayableTime(Locales.EN, Compactness.COMPACT);
        assertEquals("2:15p", st.formatTime("14:15"));
    }

    // 4.2
    @Test
    void compactAm() {
        SayableTime st = new SayableTime(Locales.EN, Compactness.COMPACT);
        assertEquals("9:30a", st.formatTime("09:30"));
    }

    // ================================================================
    // Section 5: Locale — German
    // ================================================================

    // 5.1 — German half-to pattern
    @Test
    void germanHalfToPattern() {
        SayableTime st = new SayableTime(Locales.DE);
        assertEquals("halb vier", st.formatTime("15:30"));
    }

    // ================================================================
    // Section 6: Locale — French
    // ================================================================

    // 6.1
    @Test
    void frenchQuarterPast() {
        SayableTime st = new SayableTime(Locales.FR);
        assertEquals("trois heures et quart", st.formatTime("15:15"));
    }

    // ================================================================
    // Section 7: Locale — Japanese
    // ================================================================

    // 7.1
    @Test
    void japaneseHalfPast() {
        SayableTime st = new SayableTime(Locales.JA);
        assertEquals("\u4E09\u6642\u534A", st.formatTime("15:30"));
    }

    // ================================================================
    // Section 8: Locale — Finnish (dot separator, short)
    // ================================================================

    // 8.1
    @Test
    void finnishDotSeparator() {
        SayableTime st = new SayableTime(Locales.FI, Compactness.SHORT);
        assertEquals("14.15", st.formatTime("14:15"));
    }

    // 8.2
    @Test
    void finnishMidnightDot() {
        SayableTime st = new SayableTime(Locales.FI, Compactness.SHORT);
        assertEquals("0.00", st.formatTime("00:00"));
    }
}
