package sayabletime

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Test
import sayabletime.locales.Locales

class FormatTimeTest {

    // ================================================================
    // Section 1: Null / edge cases
    // ================================================================
    // 1.1
    @Test
    fun `null input returns null`() {
        assertNull(SayableTime.formatTime(null))
    }

    // 1.2
    @Test
    fun `empty string returns null`() {
        assertNull(SayableTime.formatTime(""))
    }

    // 1.3
    @Test
    fun `invalid string returns null`() {
        assertNull(SayableTime.formatTime("invalid"))
    }

    // 1.4
    @Test
    fun `out of range returns null`() {
        assertNull(SayableTime.formatTime("25:00"))
    }

    // ================================================================
    // Section 2: Clock time (normal compactness)
    // ================================================================
    // 2.1
    @Test
    fun `midnight`() {
        val st = SayableTime(Locales.EN)
        assertEquals("midnight", st.formatTime("00:00"))
    }

    // 2.2
    @Test
    fun `noon`() {
        val st = SayableTime(Locales.EN)
        assertEquals("noon", st.formatTime("12:00"))
    }

    // 2.3
    @Test
    fun `o'clock`() {
        val st = SayableTime(Locales.EN)
        assertEquals("three o'clock", st.formatTime("15:00"))
    }

    // 2.4
    @Test
    fun `quarter past`() {
        val st = SayableTime(Locales.EN)
        assertEquals("a quarter past two", st.formatTime("14:15"))
    }

    // 2.5
    @Test
    fun `half past`() {
        val st = SayableTime(Locales.EN)
        assertEquals("half past nine", st.formatTime("09:30"))
    }

    // 2.6
    @Test
    fun `quarter to`() {
        val st = SayableTime(Locales.EN)
        assertEquals("a quarter to eleven", st.formatTime("10:45"))
    }

    // 2.7
    @Test
    fun `five past`() {
        val st = SayableTime(Locales.EN)
        assertEquals("five past eight", st.formatTime("08:05"))
    }

    // 2.8
    @Test
    fun `five to`() {
        val st = SayableTime(Locales.EN)
        assertEquals("five to five", st.formatTime("16:55"))
    }

    // 2.9 — rounds to 0:00 of next day
    @Test
    fun `rounds to midnight`() {
        val st = SayableTime(Locales.EN)
        assertEquals("midnight", st.formatTime("23:58"))
    }

    // 2.10 — 22 rounds to 20
    @Test
    fun `rounds to twenty`() {
        val st = SayableTime(Locales.EN)
        assertEquals("twenty past seven", st.formatTime("07:22"))
    }

    // 2.11 — ISO datetime input
    @Test
    fun `ISO datetime input`() {
        val st = SayableTime(Locales.EN)
        assertEquals("a quarter past two", st.formatTime("2025-01-15T14:15:00"))
    }

    // ================================================================
    // Section 3: Clock time (short compactness)
    // ================================================================
    // 3.1
    @Test
    fun `short PM`() {
        val st = SayableTime(Locales.EN, Compactness.SHORT)
        assertEquals("2:15 PM", st.formatTime("14:15"))
    }

    // 3.2
    @Test
    fun `short AM`() {
        val st = SayableTime(Locales.EN, Compactness.SHORT)
        assertEquals("9:30 AM", st.formatTime("09:30"))
    }

    // 3.3
    @Test
    fun `short midnight`() {
        val st = SayableTime(Locales.EN, Compactness.SHORT)
        assertEquals("12:00 AM", st.formatTime("00:00"))
    }

    // 3.4
    @Test
    fun `short noon`() {
        val st = SayableTime(Locales.EN, Compactness.SHORT)
        assertEquals("12:00 PM", st.formatTime("12:00"))
    }

    // ================================================================
    // Section 4: Clock time (compact)
    // ================================================================
    // 4.1
    @Test
    fun `compact PM`() {
        val st = SayableTime(Locales.EN, Compactness.COMPACT)
        assertEquals("2:15p", st.formatTime("14:15"))
    }

    // 4.2
    @Test
    fun `compact AM`() {
        val st = SayableTime(Locales.EN, Compactness.COMPACT)
        assertEquals("9:30a", st.formatTime("09:30"))
    }

    // ================================================================
    // Section 5: Locale — German
    // ================================================================
    // 5.1 — German half-to pattern
    @Test
    fun `German half to pattern`() {
        val st = SayableTime(Locales.DE)
        assertEquals("halb vier", st.formatTime("15:30"))
    }

    // ================================================================
    // Section 6: Locale — French
    // ================================================================
    // 6.1
    @Test
    fun `French quarter past`() {
        val st = SayableTime(Locales.FR)
        assertEquals("trois heures et quart", st.formatTime("15:15"))
    }

    // ================================================================
    // Section 7: Locale — Japanese
    // ================================================================
    // 7.1
    @Test
    fun `Japanese half past`() {
        val st = SayableTime(Locales.JA)
        assertEquals("\u4E09\u6642\u534A", st.formatTime("15:30"))
    }

    // ================================================================
    // Section 8: Locale — Finnish (dot separator, short)
    // ================================================================
    // 8.1
    @Test
    fun `Finnish dot separator`() {
        val st = SayableTime(Locales.FI, Compactness.SHORT)
        assertEquals("14.15", st.formatTime("14:15"))
    }

    // 8.2
    @Test
    fun `Finnish midnight dot`() {
        val st = SayableTime(Locales.FI, Compactness.SHORT)
        assertEquals("0.00", st.formatTime("00:00"))
    }

    // ================================================================
    // Minutes in short and compact modes
    // ================================================================

    // 9.1
    @Test
    fun `digital modes keep the exact minute en short 18-01`() {
        val f = SayableTime(Locales.EN, Compactness.SHORT)
        assertEquals("6:01 PM", f.formatTime("18:01"))
    }

    // 9.2
    @Test
    fun `digital modes keep the exact minute en compact 19-05`() {
        val f = SayableTime(Locales.EN, Compactness.COMPACT)
        assertEquals("7:05p", f.formatTime("19:05"))
    }

    // ================================================================
    // Input validation
    // ================================================================

    // 10.1
    @Test
    fun `one digit hour`() {
        val f = SayableTime(Locales.EN)
        assertEquals("half past nine", f.formatTime("9:30"))
    }

    // 10.2
    @Test
    fun `two digit hour`() {
        val f = SayableTime(Locales.EN)
        assertEquals("half past nine", f.formatTime("09:30"))
    }

    // 10.3
    @Test
    fun `leading whitespace`() {
        val f = SayableTime(Locales.EN)
        assertNull(f.formatTime(" 9:30"))
    }

    // 10.4
    @Test
    fun `trailing whitespace`() {
        val f = SayableTime(Locales.EN)
        assertNull(f.formatTime("9:30 "))
    }

    // 10.5
    @Test
    fun `minutes need two digits`() {
        val f = SayableTime(Locales.EN)
        assertNull(f.formatTime("9:5"))
    }

    // 10.6
    @Test
    fun `hour out of range`() {
        val f = SayableTime(Locales.EN)
        assertNull(f.formatTime("24:00"))
    }

    // 10.7
    @Test
    fun `seconds are allowed and ignored`() {
        val f = SayableTime(Locales.EN)
        assertEquals("a quarter past two", f.formatTime("14:15:30"))
    }

    // 10.8
    @Test
    fun `iso datetime with zone suffix ignored`() {
        val f = SayableTime(Locales.EN)
        assertEquals("a quarter past two", f.formatTime("2025-01-15T14:15:00Z"))
    }

    // 10.9
    @Test
    fun `iso datetime with an impossible date`() {
        val f = SayableTime(Locales.EN)
        assertNull(f.formatTime("2025-02-30T14:15:00"))
    }
}
