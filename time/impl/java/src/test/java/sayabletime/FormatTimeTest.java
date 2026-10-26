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

    // 6.2
    @Test
    void frenchOnTheHour() {
        SayableTime st = new SayableTime(Locales.FR);
        assertEquals("une heure", st.formatTime("13:00"));
    }

    // 6.3
    @Test
    void frenchHalfPast() {
        SayableTime st = new SayableTime(Locales.FR);
        assertEquals("une heure et demie", st.formatTime("13:30"));
    }

    // 6.4
    @Test
    void frenchQuarterTo() {
        SayableTime st = new SayableTime(Locales.FR);
        assertEquals("trois heures moins le quart", st.formatTime("14:45"));
    }

    // 6.5
    @Test
    void frenchTenTo() {
        SayableTime st = new SayableTime(Locales.FR);
        assertEquals("trois heures moins dix", st.formatTime("14:50"));
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

    // ================================================================
    // Minutes in short and compact modes
    // ================================================================

    // 9.1
    @Test
    void s9_1DigitalModesKeepTheExactMinute() {
        SayableTime f = new SayableTime(Locales.EN, Compactness.SHORT);
        assertEquals("6:01 PM", f.formatTime("18:01"));
    }

    // 9.2
    @Test
    void s9_2DigitalModesKeepTheExactMinute() {
        SayableTime f = new SayableTime(Locales.EN, Compactness.COMPACT);
        assertEquals("7:05p", f.formatTime("19:05"));
    }

    // ================================================================
    // Input validation
    // ================================================================

    // 10.1
    @Test
    void s10_1OneDigitHour() {
        SayableTime f = new SayableTime(Locales.EN);
        assertEquals("half past nine", f.formatTime("9:30"));
    }

    // 10.2
    @Test
    void s10_2TwoDigitHour() {
        SayableTime f = new SayableTime(Locales.EN);
        assertEquals("half past nine", f.formatTime("09:30"));
    }

    // 10.3
    @Test
    void s10_3LeadingWhitespace() {
        SayableTime f = new SayableTime(Locales.EN);
        assertNull(f.formatTime(" 9:30"));
    }

    // 10.4
    @Test
    void s10_4TrailingWhitespace() {
        SayableTime f = new SayableTime(Locales.EN);
        assertNull(f.formatTime("9:30 "));
    }

    // 10.5
    @Test
    void s10_5MinutesNeedTwoDigits() {
        SayableTime f = new SayableTime(Locales.EN);
        assertNull(f.formatTime("9:5"));
    }

    // 10.6
    @Test
    void s10_6HourOutOfRange() {
        SayableTime f = new SayableTime(Locales.EN);
        assertNull(f.formatTime("24:00"));
    }

    // 10.7
    @Test
    void s10_7SecondsAreAllowedAndIgnored() {
        SayableTime f = new SayableTime(Locales.EN);
        assertEquals("a quarter past two", f.formatTime("14:15:30"));
    }

    // 10.8
    @Test
    void s10_8ISODatetimeWithZoneSuffixIgnored() {
        SayableTime f = new SayableTime(Locales.EN);
        assertEquals("a quarter past two", f.formatTime("2025-01-15T14:15:00Z"));
    }

    // 10.9
    @Test
    void s10_9ISODatetimeWithAnImpossibleDate() {
        SayableTime f = new SayableTime(Locales.EN);
        assertNull(f.formatTime("2025-02-30T14:15:00"));
    }
}
