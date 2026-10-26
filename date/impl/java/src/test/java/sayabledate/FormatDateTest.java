package sayabledate;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import org.junit.jupiter.api.Test;
import sayabledate.locales.Locales;

class FormatDateTest {

    // ── Section 1: Null / edge cases ────────────────────────────────────

    @Test // 1.1
    void formatDateNullReturnsNull() {
        SayableDate f = new SayableDate(Locales.EN);
        assertNull(f.formatDate(null));
    }

    @Test // 1.2
    void formatDateEmptyReturnsNull() {
        SayableDate f = new SayableDate(Locales.EN);
        assertNull(f.formatDate(""));
    }

    @Test // 1.3
    void formatDateInvalidReturnsNull() {
        SayableDate f = new SayableDate(Locales.EN);
        assertNull(f.formatDate("invalid"));
    }

    @Test // 1.4
    void formatRelativeNullAsOfReturnsNull() {
        SayableDate f = new SayableDate(Locales.EN);
        assertNull(f.formatRelative("2025-03-15", null));
    }

    @Test // 1.5
    void formatRelativeNullDateReturnsNull() {
        SayableDate f = new SayableDate(Locales.EN);
        assertNull(f.formatRelative(null, "2025-03-15"));
    }

    // ── Section 2: format_date — normal compactness (English) ───────────

    @Test // 2.1
    void formatDateMarch15th() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("March 15th", f.formatDate("2025-03-15"));
    }

    @Test // 2.2
    void formatDateJanuary1st() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("January 1st", f.formatDate("2025-01-01"));
    }

    @Test // 2.3
    void formatDateMay22nd() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("May 22nd", f.formatDate("2025-05-22"));
    }

    @Test // 2.4
    void formatDateJuly3rd() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("July 3rd", f.formatDate("2025-07-03"));
    }

    @Test // 2.5
    void formatDateDecember31st() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("December 31st", f.formatDate("2025-12-31"));
    }

    @Test // 2.6
    void formatDateJune11thNoException() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("June 11th", f.formatDate("2025-06-11"));
    }

    @Test // 2.7
    void formatDateIsoDatetimeInput() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("March 15th", f.formatDate("2025-03-15T14:30:00"));
    }

    // ── Section 3: format_date — short compactness (English) ────────────

    @Test // 3.1
    void formatDateShortMar15() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.SHORT);
        assertEquals("Mar 15", f.formatDate("2025-03-15"));
    }

    @Test // 3.2
    void formatDateShortJan1() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.SHORT);
        assertEquals("Jan 1", f.formatDate("2025-01-01"));
    }

    @Test // 3.3
    void formatDateShortDec25() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.SHORT);
        assertEquals("Dec 25", f.formatDate("2025-12-25"));
    }

    // ── Section 4: format_date — compact (English) ──────────────────────

    @Test // 4.1
    void formatDateCompact315() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.COMPACT);
        assertEquals("3/15", f.formatDate("2025-03-15"));
    }

    @Test // 4.2
    void formatDateCompact11() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.COMPACT);
        assertEquals("1/1", f.formatDate("2025-01-01"));
    }

    // ── Section 5: format_relative — proximity tiers (English) ──────────

    @Test // 5.1
    void formatRelativeToday() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("today", f.formatRelative("2025-03-15", "2025-03-15"));
    }

    @Test // 5.2
    void formatRelativeTomorrow() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("tomorrow", f.formatRelative("2025-03-16", "2025-03-15"));
    }

    @Test // 5.3
    void formatRelativeYesterday() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("yesterday", f.formatRelative("2025-03-14", "2025-03-15"));
    }

    @Test // 5.4
    void formatRelativeDayAfterTomorrow() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("the day after tomorrow", f.formatRelative("2025-03-17", "2025-03-15"));
    }

    @Test // 5.5
    void formatRelativeDayBeforeYesterday() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("the day before yesterday", f.formatRelative("2025-03-13", "2025-03-15"));
    }

    @Test // 5.6
    void formatRelativeThisWednesday() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("this Wednesday", f.formatRelative("2025-03-19", "2025-03-15"));
    }

    @Test // 5.7
    void formatRelativeThisThursday() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("this Thursday", f.formatRelative("2025-03-20", "2025-03-15"));
    }

    @Test // 5.8
    void formatRelativeLastTuesday() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("last Tuesday", f.formatRelative("2025-03-11", "2025-03-15"));
    }

    @Test // 5.9
    void formatRelativeNextSaturday() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("next Saturday", f.formatRelative("2025-03-22", "2025-03-15"));
    }

    @Test // 5.10
    void formatRelativeNextThursday() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("next Thursday", f.formatRelative("2025-03-27", "2025-03-15"));
    }

    @Test // 5.11
    void formatRelativeCalendarSameYearPast() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("March 1st", f.formatRelative("2025-03-01", "2025-03-15"));
    }

    @Test // 5.12
    void formatRelativeCalendarSameYearFuture() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("April 10th", f.formatRelative("2025-04-10", "2025-03-15"));
    }

    @Test // 5.13
    void formatRelativeDifferentYearFuture() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("January 5th, 2026", f.formatRelative("2026-01-05", "2025-03-15"));
    }

    @Test // 5.14
    void formatRelativePastYear() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("December 25th, 2024", f.formatRelative("2024-12-25", "2025-03-15"));
    }

    // ── Section 6: format_relative — compact skips weekday tiers ────────

    @Test // 6.1
    void formatRelativeCompactToday() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.COMPACT);
        assertEquals("today", f.formatRelative("2025-03-15", "2025-03-15"));
    }

    @Test // 6.2
    void formatRelativeCompactTomorrow() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.COMPACT);
        assertEquals("tomorrow", f.formatRelative("2025-03-16", "2025-03-15"));
    }

    @Test // 6.3
    void formatRelativeCompactGoesNumeric() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.COMPACT);
        assertEquals("3/19", f.formatRelative("2025-03-19", "2025-03-15"));
    }

    @Test // 6.4
    void formatRelativeCompactDifferentYear() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.COMPACT);
        assertEquals("1/5/26", f.formatRelative("2026-01-05", "2025-03-15"));
    }

    // ── Section 7: Locale — German ──────────────────────────────────────

    @Test // 7.1
    void formatDateGerman() {
        SayableDate f = new SayableDate(Locales.DE);
        assertEquals("15. M\u00E4rz", f.formatDate("2025-03-15"));
    }

    @Test // 7.2
    void formatRelativeGermanTomorrow() {
        SayableDate f = new SayableDate(Locales.DE);
        assertEquals("morgen", f.formatRelative("2025-03-16", "2025-03-15"));
    }

    @Test // 7.3
    void formatRelativeGermanDayAfterTomorrow() {
        SayableDate f = new SayableDate(Locales.DE);
        assertEquals("\u00FCbermorgen", f.formatRelative("2025-03-17", "2025-03-15"));
    }

    @Test // 7.4
    void formatRelativeGermanThisWednesday() {
        SayableDate f = new SayableDate(Locales.DE);
        assertEquals("diesen Mittwoch", f.formatRelative("2025-03-19", "2025-03-15"));
    }

    // ── Section 8: Locale — French ──────────────────────────────────────

    @Test // 8.1
    void formatDateFrench1erMars() {
        SayableDate f = new SayableDate(Locales.FR);
        assertEquals("1er mars", f.formatDate("2025-03-01"));
    }

    @Test // 8.2
    void formatDateFrench15Mars() {
        SayableDate f = new SayableDate(Locales.FR);
        assertEquals("15 mars", f.formatDate("2025-03-15"));
    }

    @Test // 8.3
    void formatRelativeFrenchTomorrow() {
        SayableDate f = new SayableDate(Locales.FR);
        assertEquals("demain", f.formatRelative("2025-03-16", "2025-03-15"));
    }

    // ── Section 9: Locale — Japanese ────────────────────────────────────

    @Test // 9.1
    void formatDateJapanese() {
        SayableDate f = new SayableDate(Locales.JA);
        assertEquals("3\u670815\u65E5", f.formatDate("2025-03-15"));
    }

    @Test // 9.2
    void formatRelativeJapaneseTomorrow() {
        SayableDate f = new SayableDate(Locales.JA);
        assertEquals("\u660E\u65E5", f.formatRelative("2025-03-16", "2025-03-15"));
    }

    @Test // 9.3
    void formatRelativeJapaneseThisWednesday() {
        SayableDate f = new SayableDate(Locales.JA);
        assertEquals("\u4ECA\u5EA6\u306E\u6C34\u66DC\u65E5", f.formatRelative("2025-03-19", "2025-03-15"));
    }

    // ── Section 10: Locale — Russian (genitive months) ──────────────────

    @Test // 10.1
    void formatDateRussianGenitiveMonths() {
        SayableDate f = new SayableDate(Locales.RU);
        assertEquals("15 \u043C\u0430\u0440\u0442\u0430", f.formatDate("2025-03-15"));
    }

    @Test // 10.2
    void formatRelativeRussianTomorrow() {
        SayableDate f = new SayableDate(Locales.RU);
        assertEquals("\u0437\u0430\u0432\u0442\u0440\u0430", f.formatRelative("2025-03-16", "2025-03-15"));
    }

    // ── Section 11: Locale — Arabic ─────────────────────────────────────

    @Test // 11.1
    void formatDateArabic() {
        SayableDate f = new SayableDate(Locales.AR);
        assertEquals("15 \u0645\u0627\u0631\u0633", f.formatDate("2025-03-15"));
    }

    @Test // 11.2
    void formatRelativeArabicTomorrow() {
        SayableDate f = new SayableDate(Locales.AR);
        assertEquals("\u063A\u062F\u0627\u064B", f.formatRelative("2025-03-16", "2025-03-15"));
    }

    // ── Section 12: Locale — Spanish ────────────────────────────────────

    @Test // 12.1
    void formatDateSpanish() {
        SayableDate f = new SayableDate(Locales.ES);
        assertEquals("15 de marzo", f.formatDate("2025-03-15"));
    }

    @Test // 12.2
    void formatRelativeSpanishDayAfterTomorrow() {
        SayableDate f = new SayableDate(Locales.ES);
        assertEquals("pasado ma\u00F1ana", f.formatRelative("2025-03-17", "2025-03-15"));
    }

    // ── Version ─────────────────────────────────────────────────────────

    @Test
    void versionMatchesConfig() {
        assertEquals("0.5.0", SayableDate.VERSION);
    }

    // ================================================================
    // format_date_with_year
    // ================================================================

    @Test // 13.1
    void s13_1FormatDateWithYear() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("February 4th, 2018", f.formatDateWithYear("2018-02-04"));
    }

    @Test // 13.2
    void s13_2FormatDateWithYear() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.SHORT);
        assertEquals("Mar 15, 2025", f.formatDateWithYear("2025-03-15"));
    }

    @Test // 13.3
    void s13_3FormatDateWithYear() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.COMPACT);
        assertEquals("1/21/97", f.formatDateWithYear("1997-01-21"));
    }

    @Test // 13.4
    void s13_4TwoDigitYearKeepsItsLeadingZero() {
        SayableDate f = new SayableDate(Locales.TG, Compactness.COMPACT);
        assertEquals("20/5/07", f.formatDateWithYear("2007-05-20"));
    }

    @Test // 13.5
    void s13_5FormatDateWithYear() {
        SayableDate f = new SayableDate(Locales.FI, Compactness.SHORT);
        assertEquals("21. kes\u00E4kuuta 1996", f.formatDateWithYear("1996-06-21"));
    }

    // ================================================================
    // Short month names (locales that keep the full genitive)
    // ================================================================

    @Test // 14.1
    void s14_1ShortMonthNamesLocalesThatKeepThe() {
        SayableDate f = new SayableDate(Locales.SK, Compactness.SHORT);
        assertEquals("15. febru\u00E1ra", f.formatDate("2031-02-15"));
    }

    @Test // 14.2
    void s14_2ShortMonthNamesLocalesThatKeepThe() {
        SayableDate f = new SayableDate(Locales.CS, Compactness.SHORT);
        assertEquals("10. prosince", f.formatDate("2025-12-10"));
    }

    @Test // 14.3
    void s14_3ShortMonthNamesLocalesThatKeepThe() {
        SayableDate f = new SayableDate(Locales.UK, Compactness.SHORT);
        assertEquals("5 \u043B\u0438\u0441\u0442\u043E\u043F\u0430\u0434\u0430", f.formatDate("2025-11-05"));
    }

    @Test // 14.4
    void s14_4ShortMonthNamesLocalesThatKeepThe() {
        SayableDate f = new SayableDate(Locales.FI, Compactness.SHORT);
        assertEquals("8. elokuuta", f.formatRelative("1998-08-08", "1998-08-15"));
    }

    // ================================================================
    // format_relative — short phrases
    // ================================================================

    @Test // 15.1
    void s15_1DayAfterTomorrow() {
        SayableDate f = new SayableDate(Locales.KW, Compactness.SHORT);
        assertEquals("an Mth ma", f.formatRelative("2035-12-04", "2035-12-02"));
    }

    @Test // 15.2
    void s15_2DayBeforeYesterday() {
        SayableDate f = new SayableDate(Locales.MAM, Compactness.SHORT);
        assertEquals("Dom nchi'j", f.formatRelative("2000-01-23", "2000-01-25"));
    }

    @Test // 15.3
    void s15_3DayAfterTomorrow() {
        SayableDate f = new SayableDate(Locales.KEK, Compactness.SHORT);
        assertEquals("a'in Vie", f.formatRelative("2014-10-24", "2014-10-22"));
    }

    // ================================================================
    // Input validation
    // ================================================================

    @Test // 16.1
    void s16_1February30DoesntExist() {
        SayableDate f = new SayableDate(Locales.EN);
        assertNull(f.formatDate("2025-02-30"));
    }

    @Test // 16.2
    void s16_2Month13() {
        SayableDate f = new SayableDate(Locales.EN);
        assertNull(f.formatDate("2025-13-01"));
    }

    @Test // 16.3
    void s16_3UnpaddedMonthAndDay() {
        SayableDate f = new SayableDate(Locales.EN);
        assertNull(f.formatDate("2025-6-1"));
    }

    @Test // 16.4
    void s16_4SurroundingWhitespace() {
        SayableDate f = new SayableDate(Locales.EN);
        assertNull(f.formatDate(" 2025-06-01"));
    }

    @Test // 16.5
    void s16_5AnISODatetimeOnlyTheDatePart() {
        SayableDate f = new SayableDate(Locales.EN);
        assertEquals("June 1st", f.formatDate("2025-06-01T10:00:00"));
    }

    @Test // 16.6
    void s16_6February29InANonLeapYear() {
        SayableDate f = new SayableDate(Locales.EN);
        assertNull(f.formatDateWithYear("2023-02-29"));
    }

    @Test // 16.7
    void s16_7InvalidAsOf() {
        SayableDate f = new SayableDate(Locales.EN);
        assertNull(f.formatRelative("2025-03-16", "2025-04-31"));
    }
}
