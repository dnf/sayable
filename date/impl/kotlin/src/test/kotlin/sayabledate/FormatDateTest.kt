package sayabledate

import sayabledate.locales.Locales
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull

class FormatDateTest {

    // ── Section 1: Null / edge cases ────────────────────────────────────

    @Test // 1.1
    fun `format_date null returns null`() {
        val f = SayableDate(Locales.EN)
        assertNull(f.formatDate(null))
    }

    @Test // 1.2
    fun `format_date empty returns null`() {
        val f = SayableDate(Locales.EN)
        assertNull(f.formatDate(""))
    }

    @Test // 1.3
    fun `format_date invalid returns null`() {
        val f = SayableDate(Locales.EN)
        assertNull(f.formatDate("invalid"))
    }

    @Test // 1.4
    fun `format_relative null asOf returns null`() {
        val f = SayableDate(Locales.EN)
        assertNull(f.formatRelative("2025-03-15", null))
    }

    @Test // 1.5
    fun `format_relative null date returns null`() {
        val f = SayableDate(Locales.EN)
        assertNull(f.formatRelative(null, "2025-03-15"))
    }

    // ── Section 2: format_date — normal compactness (English) ───────────

    @Test // 2.1
    fun `format_date March 15th`() {
        val f = SayableDate(Locales.EN)
        assertEquals("March 15th", f.formatDate("2025-03-15"))
    }

    @Test // 2.2
    fun `format_date January 1st`() {
        val f = SayableDate(Locales.EN)
        assertEquals("January 1st", f.formatDate("2025-01-01"))
    }

    @Test // 2.3
    fun `format_date May 22nd`() {
        val f = SayableDate(Locales.EN)
        assertEquals("May 22nd", f.formatDate("2025-05-22"))
    }

    @Test // 2.4
    fun `format_date July 3rd`() {
        val f = SayableDate(Locales.EN)
        assertEquals("July 3rd", f.formatDate("2025-07-03"))
    }

    @Test // 2.5
    fun `format_date December 31st`() {
        val f = SayableDate(Locales.EN)
        assertEquals("December 31st", f.formatDate("2025-12-31"))
    }

    @Test // 2.6
    fun `format_date June 11th — no exception for 11`() {
        val f = SayableDate(Locales.EN)
        assertEquals("June 11th", f.formatDate("2025-06-11"))
    }

    @Test // 2.7
    fun `format_date ISO datetime input`() {
        val f = SayableDate(Locales.EN)
        assertEquals("March 15th", f.formatDate("2025-03-15T14:30:00"))
    }

    // ── Section 3: format_date — short compactness (English) ────────────

    @Test // 3.1
    fun `format_date short Mar 15`() {
        val f = SayableDate(Locales.EN, Compactness.SHORT)
        assertEquals("Mar 15", f.formatDate("2025-03-15"))
    }

    @Test // 3.2
    fun `format_date short Jan 1`() {
        val f = SayableDate(Locales.EN, Compactness.SHORT)
        assertEquals("Jan 1", f.formatDate("2025-01-01"))
    }

    @Test // 3.3
    fun `format_date short Dec 25`() {
        val f = SayableDate(Locales.EN, Compactness.SHORT)
        assertEquals("Dec 25", f.formatDate("2025-12-25"))
    }

    // ── Section 4: format_date — compact (English) ──────────────────────

    @Test // 4.1
    fun `format_date compact 3-15`() {
        val f = SayableDate(Locales.EN, Compactness.COMPACT)
        assertEquals("3/15", f.formatDate("2025-03-15"))
    }

    @Test // 4.2
    fun `format_date compact 1-1`() {
        val f = SayableDate(Locales.EN, Compactness.COMPACT)
        assertEquals("1/1", f.formatDate("2025-01-01"))
    }

    // ── Section 5: format_relative — proximity tiers (English) ──────────

    @Test // 5.1
    fun `format_relative today`() {
        val f = SayableDate(Locales.EN)
        assertEquals("today", f.formatRelative("2025-03-15", "2025-03-15"))
    }

    @Test // 5.2
    fun `format_relative tomorrow`() {
        val f = SayableDate(Locales.EN)
        assertEquals("tomorrow", f.formatRelative("2025-03-16", "2025-03-15"))
    }

    @Test // 5.3
    fun `format_relative yesterday`() {
        val f = SayableDate(Locales.EN)
        assertEquals("yesterday", f.formatRelative("2025-03-14", "2025-03-15"))
    }

    @Test // 5.4
    fun `format_relative day after tomorrow`() {
        val f = SayableDate(Locales.EN)
        assertEquals("the day after tomorrow", f.formatRelative("2025-03-17", "2025-03-15"))
    }

    @Test // 5.5
    fun `format_relative day before yesterday`() {
        val f = SayableDate(Locales.EN)
        assertEquals("the day before yesterday", f.formatRelative("2025-03-13", "2025-03-15"))
    }

    @Test // 5.6
    fun `format_relative this Wednesday — plus 4 days`() {
        val f = SayableDate(Locales.EN)
        assertEquals("this Wednesday", f.formatRelative("2025-03-19", "2025-03-15"))
    }

    @Test // 5.7
    fun `format_relative this Thursday — plus 5 days`() {
        val f = SayableDate(Locales.EN)
        assertEquals("this Thursday", f.formatRelative("2025-03-20", "2025-03-15"))
    }

    @Test // 5.8
    fun `format_relative last Tuesday — minus 4 days`() {
        val f = SayableDate(Locales.EN)
        assertEquals("last Tuesday", f.formatRelative("2025-03-11", "2025-03-15"))
    }

    @Test // 5.9
    fun `format_relative next Saturday — plus 7 days`() {
        val f = SayableDate(Locales.EN)
        assertEquals("next Saturday", f.formatRelative("2025-03-22", "2025-03-15"))
    }

    @Test // 5.10
    fun `format_relative next Thursday — plus 12 days`() {
        val f = SayableDate(Locales.EN)
        assertEquals("next Thursday", f.formatRelative("2025-03-27", "2025-03-15"))
    }

    @Test // 5.11
    fun `format_relative calendar same year past — minus 14 days`() {
        val f = SayableDate(Locales.EN)
        assertEquals("March 1st", f.formatRelative("2025-03-01", "2025-03-15"))
    }

    @Test // 5.12
    fun `format_relative calendar same year future — plus 26 days`() {
        val f = SayableDate(Locales.EN)
        assertEquals("April 10th", f.formatRelative("2025-04-10", "2025-03-15"))
    }

    @Test // 5.13
    fun `format_relative different year future includes year`() {
        val f = SayableDate(Locales.EN)
        assertEquals("January 5th, 2026", f.formatRelative("2026-01-05", "2025-03-15"))
    }

    @Test // 5.14
    fun `format_relative past year includes year`() {
        val f = SayableDate(Locales.EN)
        assertEquals("December 25th, 2024", f.formatRelative("2024-12-25", "2025-03-15"))
    }

    // ── Section 6: format_relative — compact skips weekday tiers ────────

    @Test // 6.1
    fun `format_relative compact today`() {
        val f = SayableDate(Locales.EN, Compactness.COMPACT)
        assertEquals("today", f.formatRelative("2025-03-15", "2025-03-15"))
    }

    @Test // 6.2
    fun `format_relative compact tomorrow`() {
        val f = SayableDate(Locales.EN, Compactness.COMPACT)
        assertEquals("tomorrow", f.formatRelative("2025-03-16", "2025-03-15"))
    }

    @Test // 6.3
    fun `format_relative compact goes straight to numeric`() {
        val f = SayableDate(Locales.EN, Compactness.COMPACT)
        assertEquals("3/19", f.formatRelative("2025-03-19", "2025-03-15"))
    }

    @Test // 6.4
    fun `format_relative compact different year`() {
        val f = SayableDate(Locales.EN, Compactness.COMPACT)
        assertEquals("1/5/26", f.formatRelative("2026-01-05", "2025-03-15"))
    }

    // ── Section 7: Locale — German ──────────────────────────────────────

    @Test // 7.1
    fun `format_date German`() {
        val f = SayableDate(Locales.DE)
        assertEquals("15. März", f.formatDate("2025-03-15"))
    }

    @Test // 7.2
    fun `format_relative German tomorrow`() {
        val f = SayableDate(Locales.DE)
        assertEquals("morgen", f.formatRelative("2025-03-16", "2025-03-15"))
    }

    @Test // 7.3
    fun `format_relative German day after tomorrow`() {
        val f = SayableDate(Locales.DE)
        assertEquals("übermorgen", f.formatRelative("2025-03-17", "2025-03-15"))
    }

    @Test // 7.4
    fun `format_relative German this Wednesday`() {
        val f = SayableDate(Locales.DE)
        assertEquals("diesen Mittwoch", f.formatRelative("2025-03-19", "2025-03-15"))
    }

    // ── Section 8: Locale — French ──────────────────────────────────────

    @Test // 8.1
    fun `format_date French 1er mars`() {
        val f = SayableDate(Locales.FR)
        assertEquals("1er mars", f.formatDate("2025-03-01"))
    }

    @Test // 8.2
    fun `format_date French 15 mars`() {
        val f = SayableDate(Locales.FR)
        assertEquals("15 mars", f.formatDate("2025-03-15"))
    }

    @Test // 8.3
    fun `format_relative French tomorrow`() {
        val f = SayableDate(Locales.FR)
        assertEquals("demain", f.formatRelative("2025-03-16", "2025-03-15"))
    }

    // ── Section 9: Locale — Japanese ────────────────────────────────────

    @Test // 9.1
    fun `format_date Japanese`() {
        val f = SayableDate(Locales.JA)
        assertEquals("3月15日", f.formatDate("2025-03-15"))
    }

    @Test // 9.2
    fun `format_relative Japanese tomorrow`() {
        val f = SayableDate(Locales.JA)
        assertEquals("明日", f.formatRelative("2025-03-16", "2025-03-15"))
    }

    @Test // 9.3
    fun `format_relative Japanese this Wednesday`() {
        val f = SayableDate(Locales.JA)
        assertEquals("今度の水曜日", f.formatRelative("2025-03-19", "2025-03-15"))
    }

    // ── Section 10: Locale — Russian (genitive months) ──────────────────

    @Test // 10.1
    fun `format_date Russian genitive months`() {
        val f = SayableDate(Locales.RU)
        assertEquals("15 марта", f.formatDate("2025-03-15"))
    }

    @Test // 10.2
    fun `format_relative Russian tomorrow`() {
        val f = SayableDate(Locales.RU)
        assertEquals("завтра", f.formatRelative("2025-03-16", "2025-03-15"))
    }

    // ── Section 11: Locale — Arabic ─────────────────────────────────────

    @Test // 11.1
    fun `format_date Arabic`() {
        val f = SayableDate(Locales.AR)
        assertEquals("15 مارس", f.formatDate("2025-03-15"))
    }

    @Test // 11.2
    fun `format_relative Arabic tomorrow`() {
        val f = SayableDate(Locales.AR)
        assertEquals("غداً", f.formatRelative("2025-03-16", "2025-03-15"))
    }

    // ── Section 12: Locale — Spanish ────────────────────────────────────

    @Test // 12.1
    fun `format_date Spanish`() {
        val f = SayableDate(Locales.ES)
        assertEquals("15 de marzo", f.formatDate("2025-03-15"))
    }

    @Test // 12.2
    fun `format_relative Spanish day after tomorrow`() {
        val f = SayableDate(Locales.ES)
        assertEquals("pasado mañana", f.formatRelative("2025-03-17", "2025-03-15"))
    }

    // ── Version ─────────────────────────────────────────────────────────

    @Test
    fun `version matches config`() {
        assertEquals("0.1.0", VERSION)
    }
}
