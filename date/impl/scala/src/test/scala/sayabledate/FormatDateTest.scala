package sayabledate

import org.junit.jupiter.api.Assertions.{assertEquals, assertTrue}
import org.junit.jupiter.api.Test
import sayabledate.locales.Locales

class FormatDateTest:

    // ── Section 1: Null / edge cases ────────────────────────────────────

    @Test // 1.1
    def `format_date null returns None`(): Unit =
        val f = SayableDate(Locales.EN)
        assertTrue(f.formatDate(null).isEmpty)

    @Test // 1.2
    def `format_date empty returns None`(): Unit =
        val f = SayableDate(Locales.EN)
        assertTrue(f.formatDate("").isEmpty)

    @Test // 1.3
    def `format_date invalid returns None`(): Unit =
        val f = SayableDate(Locales.EN)
        assertTrue(f.formatDate("invalid").isEmpty)

    @Test // 1.4
    def `format_relative null asOf returns None`(): Unit =
        val f = SayableDate(Locales.EN)
        assertTrue(f.formatRelative("2025-03-15", null).isEmpty)

    @Test // 1.5
    def `format_relative null date returns None`(): Unit =
        val f = SayableDate(Locales.EN)
        assertTrue(f.formatRelative(null, "2025-03-15").isEmpty)

    // ── Section 2: format_date — normal compactness (English) ───────────

    @Test // 2.1
    def `format_date March 15th`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("March 15th"), f.formatDate("2025-03-15"))

    @Test // 2.2
    def `format_date January 1st`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("January 1st"), f.formatDate("2025-01-01"))

    @Test // 2.3
    def `format_date May 22nd`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("May 22nd"), f.formatDate("2025-05-22"))

    @Test // 2.4
    def `format_date July 3rd`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("July 3rd"), f.formatDate("2025-07-03"))

    @Test // 2.5
    def `format_date December 31st`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("December 31st"), f.formatDate("2025-12-31"))

    @Test // 2.6
    def `format_date June 11th`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("June 11th"), f.formatDate("2025-06-11"))

    @Test // 2.7
    def `format_date ISO datetime input`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("March 15th"), f.formatDate("2025-03-15T14:30:00"))

    // ── Section 3: format_date — short compactness (English) ────────────

    @Test // 3.1
    def `format_date short Mar 15`(): Unit =
        val f = SayableDate(Locales.EN, Compactness.SHORT)
        assertEquals(Some("Mar 15"), f.formatDate("2025-03-15"))

    @Test // 3.2
    def `format_date short Jan 1`(): Unit =
        val f = SayableDate(Locales.EN, Compactness.SHORT)
        assertEquals(Some("Jan 1"), f.formatDate("2025-01-01"))

    @Test // 3.3
    def `format_date short Dec 25`(): Unit =
        val f = SayableDate(Locales.EN, Compactness.SHORT)
        assertEquals(Some("Dec 25"), f.formatDate("2025-12-25"))

    // ── Section 4: format_date — compact (English) ──────────────────────

    @Test // 4.1
    def `format_date compact 3-15`(): Unit =
        val f = SayableDate(Locales.EN, Compactness.COMPACT)
        assertEquals(Some("3/15"), f.formatDate("2025-03-15"))

    @Test // 4.2
    def `format_date compact 1-1`(): Unit =
        val f = SayableDate(Locales.EN, Compactness.COMPACT)
        assertEquals(Some("1/1"), f.formatDate("2025-01-01"))

    // ── Section 5: format_relative — proximity tiers (English) ──────────

    @Test // 5.1
    def `format_relative today`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("today"), f.formatRelative("2025-03-15", "2025-03-15"))

    @Test // 5.2
    def `format_relative tomorrow`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("tomorrow"), f.formatRelative("2025-03-16", "2025-03-15"))

    @Test // 5.3
    def `format_relative yesterday`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("yesterday"), f.formatRelative("2025-03-14", "2025-03-15"))

    @Test // 5.4
    def `format_relative day after tomorrow`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("the day after tomorrow"), f.formatRelative("2025-03-17", "2025-03-15"))

    @Test // 5.5
    def `format_relative day before yesterday`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("the day before yesterday"), f.formatRelative("2025-03-13", "2025-03-15"))

    @Test // 5.6
    def `format_relative this Wednesday`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("this Wednesday"), f.formatRelative("2025-03-19", "2025-03-15"))

    @Test // 5.7
    def `format_relative this Thursday`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("this Thursday"), f.formatRelative("2025-03-20", "2025-03-15"))

    @Test // 5.8
    def `format_relative last Tuesday`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("last Tuesday"), f.formatRelative("2025-03-11", "2025-03-15"))

    @Test // 5.9
    def `format_relative next Saturday`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("next Saturday"), f.formatRelative("2025-03-22", "2025-03-15"))

    @Test // 5.10
    def `format_relative next Thursday`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("next Thursday"), f.formatRelative("2025-03-27", "2025-03-15"))

    @Test // 5.11
    def `format_relative calendar same year past`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("March 1st"), f.formatRelative("2025-03-01", "2025-03-15"))

    @Test // 5.12
    def `format_relative calendar same year future`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("April 10th"), f.formatRelative("2025-04-10", "2025-03-15"))

    @Test // 5.13
    def `format_relative different year future includes year`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("January 5th, 2026"), f.formatRelative("2026-01-05", "2025-03-15"))

    @Test // 5.14
    def `format_relative past year includes year`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("December 25th, 2024"), f.formatRelative("2024-12-25", "2025-03-15"))

    // ── Section 6: format_relative — compact skips weekday tiers ────────

    @Test // 6.1
    def `format_relative compact today`(): Unit =
        val f = SayableDate(Locales.EN, Compactness.COMPACT)
        assertEquals(Some("today"), f.formatRelative("2025-03-15", "2025-03-15"))

    @Test // 6.2
    def `format_relative compact tomorrow`(): Unit =
        val f = SayableDate(Locales.EN, Compactness.COMPACT)
        assertEquals(Some("tomorrow"), f.formatRelative("2025-03-16", "2025-03-15"))

    @Test // 6.3
    def `format_relative compact goes straight to numeric`(): Unit =
        val f = SayableDate(Locales.EN, Compactness.COMPACT)
        assertEquals(Some("3/19"), f.formatRelative("2025-03-19", "2025-03-15"))

    @Test // 6.4
    def `format_relative compact different year`(): Unit =
        val f = SayableDate(Locales.EN, Compactness.COMPACT)
        assertEquals(Some("1/5/26"), f.formatRelative("2026-01-05", "2025-03-15"))

    // ── Section 7: Locale — German ──────────────────────────────────────

    @Test // 7.1
    def `format_date German`(): Unit =
        val f = SayableDate(Locales.DE)
        assertEquals(Some("15. M\u00E4rz"), f.formatDate("2025-03-15"))

    @Test // 7.2
    def `format_relative German tomorrow`(): Unit =
        val f = SayableDate(Locales.DE)
        assertEquals(Some("morgen"), f.formatRelative("2025-03-16", "2025-03-15"))

    @Test // 7.3
    def `format_relative German day after tomorrow`(): Unit =
        val f = SayableDate(Locales.DE)
        assertEquals(Some("\u00FCbermorgen"), f.formatRelative("2025-03-17", "2025-03-15"))

    @Test // 7.4
    def `format_relative German this Wednesday`(): Unit =
        val f = SayableDate(Locales.DE)
        assertEquals(Some("diesen Mittwoch"), f.formatRelative("2025-03-19", "2025-03-15"))

    // ── Section 8: Locale — French ──────────────────────────────────────

    @Test // 8.1
    def `format_date French 1er mars`(): Unit =
        val f = SayableDate(Locales.FR)
        assertEquals(Some("1er mars"), f.formatDate("2025-03-01"))

    @Test // 8.2
    def `format_date French 15 mars`(): Unit =
        val f = SayableDate(Locales.FR)
        assertEquals(Some("15 mars"), f.formatDate("2025-03-15"))

    @Test // 8.3
    def `format_relative French tomorrow`(): Unit =
        val f = SayableDate(Locales.FR)
        assertEquals(Some("demain"), f.formatRelative("2025-03-16", "2025-03-15"))

    // ── Section 9: Locale — Japanese ────────────────────────────────────

    @Test // 9.1
    def `format_date Japanese`(): Unit =
        val f = SayableDate(Locales.JA)
        assertEquals(Some("3\u670815\u65E5"), f.formatDate("2025-03-15"))

    @Test // 9.2
    def `format_relative Japanese tomorrow`(): Unit =
        val f = SayableDate(Locales.JA)
        assertEquals(Some("\u660E\u65E5"), f.formatRelative("2025-03-16", "2025-03-15"))

    @Test // 9.3
    def `format_relative Japanese this Wednesday`(): Unit =
        val f = SayableDate(Locales.JA)
        assertEquals(Some("\u4ECA\u5EA6\u306E\u6C34\u66DC\u65E5"), f.formatRelative("2025-03-19", "2025-03-15"))

    // ── Section 10: Locale — Russian (genitive months) ──────────────────

    @Test // 10.1
    def `format_date Russian genitive months`(): Unit =
        val f = SayableDate(Locales.RU)
        assertEquals(Some("15 \u043C\u0430\u0440\u0442\u0430"), f.formatDate("2025-03-15"))

    @Test // 10.2
    def `format_relative Russian tomorrow`(): Unit =
        val f = SayableDate(Locales.RU)
        assertEquals(Some("\u0437\u0430\u0432\u0442\u0440\u0430"), f.formatRelative("2025-03-16", "2025-03-15"))

    // ── Section 11: Locale — Arabic ─────────────────────────────────────

    @Test // 11.1
    def `format_date Arabic`(): Unit =
        val f = SayableDate(Locales.AR)
        assertEquals(Some("15 \u0645\u0627\u0631\u0633"), f.formatDate("2025-03-15"))

    @Test // 11.2
    def `format_relative Arabic tomorrow`(): Unit =
        val f = SayableDate(Locales.AR)
        assertEquals(Some("\u063A\u062F\u0627\u064B"), f.formatRelative("2025-03-16", "2025-03-15"))

    // ── Section 12: Locale — Spanish ────────────────────────────────────

    @Test // 12.1
    def `format_date Spanish`(): Unit =
        val f = SayableDate(Locales.ES)
        assertEquals(Some("15 de marzo"), f.formatDate("2025-03-15"))

    @Test // 12.2
    def `format_relative Spanish day after tomorrow`(): Unit =
        val f = SayableDate(Locales.ES)
        assertEquals(Some("pasado ma\u00F1ana"), f.formatRelative("2025-03-17", "2025-03-15"))

    // ── Version ─────────────────────────────────────────────────────────

    @Test
    def `version matches config`(): Unit =
        assertEquals("0.5.0", Version)

    // ================================================================
    // format_date_with_year
    // ================================================================

    @Test // 13.1
    def `format date with year en normal 2018-02-04`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("February 4th, 2018"), f.formatDateWithYear("2018-02-04"))

    @Test // 13.2
    def `format date with year en short 2025-03-15`(): Unit =
        val f = SayableDate(Locales.EN, Compactness.SHORT)
        assertEquals(Some("Mar 15, 2025"), f.formatDateWithYear("2025-03-15"))

    @Test // 13.3
    def `format date with year en compact 1997-01-21`(): Unit =
        val f = SayableDate(Locales.EN, Compactness.COMPACT)
        assertEquals(Some("1/21/97"), f.formatDateWithYear("1997-01-21"))

    @Test // 13.4
    def `two digit year keeps its leading zero`(): Unit =
        val f = SayableDate(Locales.TG, Compactness.COMPACT)
        assertEquals(Some("20/5/07"), f.formatDateWithYear("2007-05-20"))

    @Test // 13.5
    def `format date with year fi short 1996-06-21`(): Unit =
        val f = SayableDate(Locales.FI, Compactness.SHORT)
        assertEquals(Some("21. kes\u00E4kuuta 1996"), f.formatDateWithYear("1996-06-21"))

    // ================================================================
    // Short month names (locales that keep the full genitive)
    // ================================================================

    @Test // 14.1
    def `short month names locales that keep the sk short 2031-02-15`(): Unit =
        val f = SayableDate(Locales.SK, Compactness.SHORT)
        assertEquals(Some("15. febru\u00E1ra"), f.formatDate("2031-02-15"))

    @Test // 14.2
    def `short month names locales that keep the cs short 2025-12-10`(): Unit =
        val f = SayableDate(Locales.CS, Compactness.SHORT)
        assertEquals(Some("10. prosince"), f.formatDate("2025-12-10"))

    @Test // 14.3
    def `short month names locales that keep the uk short 2025-11-05`(): Unit =
        val f = SayableDate(Locales.UK, Compactness.SHORT)
        assertEquals(Some("5 \u043B\u0438\u0441\u0442\u043E\u043F\u0430\u0434\u0430"), f.formatDate("2025-11-05"))

    @Test // 14.4
    def `short month names locales that keep the fi short 1998-08-08`(): Unit =
        val f = SayableDate(Locales.FI, Compactness.SHORT)
        assertEquals(Some("8. elokuuta"), f.formatRelative("1998-08-08", "1998-08-15"))

    // ================================================================
    // format_relative — short phrases
    // ================================================================

    @Test // 15.1
    def `day after tomorrow kw short 2035-12-04`(): Unit =
        val f = SayableDate(Locales.KW, Compactness.SHORT)
        assertEquals(Some("an Mth ma"), f.formatRelative("2035-12-04", "2035-12-02"))

    @Test // 15.2
    def `day before yesterday`(): Unit =
        val f = SayableDate(Locales.MAM, Compactness.SHORT)
        assertEquals(Some("Dom nchi'j"), f.formatRelative("2000-01-23", "2000-01-25"))

    @Test // 15.3
    def `day after tomorrow kek short 2014-10-24`(): Unit =
        val f = SayableDate(Locales.KEK, Compactness.SHORT)
        assertEquals(Some("a'in Vie"), f.formatRelative("2014-10-24", "2014-10-22"))

    // ================================================================
    // Input validation
    // ================================================================

    @Test // 16.1
    def `february 30 doesnt exist`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(None, f.formatDate("2025-02-30"))

    @Test // 16.2
    def `month 13`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(None, f.formatDate("2025-13-01"))

    @Test // 16.3
    def `unpadded month and day`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(None, f.formatDate("2025-6-1"))

    @Test // 16.4
    def `surrounding whitespace`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(None, f.formatDate(" 2025-06-01"))

    @Test // 16.5
    def `an iso datetime only the date part`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(Some("June 1st"), f.formatDate("2025-06-01T10:00:00"))

    @Test // 16.6
    def `february 29 in a non leap year`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(None, f.formatDateWithYear("2023-02-29"))

    @Test // 16.7
    def `invalid asof`(): Unit =
        val f = SayableDate(Locales.EN)
        assertEquals(None, f.formatRelative("2025-03-16", "2025-04-31"))
