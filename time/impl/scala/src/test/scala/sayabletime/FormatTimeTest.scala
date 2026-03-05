package sayabletime

import org.junit.jupiter.api.Assertions.{assertEquals, assertTrue}
import org.junit.jupiter.api.Test
import sayabletime.locales.Locales

class FormatTimeTest:

    // ================================================================
    // Section 1: Null / edge cases
    // ================================================================
    // 1.1
    @Test
    def `null input returns None`(): Unit =
        assertTrue(SayableTime.formatTime(null).isEmpty)

    // 1.2
    @Test
    def `empty string returns None`(): Unit =
        assertTrue(SayableTime.formatTime("").isEmpty)

    // 1.3
    @Test
    def `invalid string returns None`(): Unit =
        assertTrue(SayableTime.formatTime("invalid").isEmpty)

    // 1.4
    @Test
    def `out of range returns None`(): Unit =
        assertTrue(SayableTime.formatTime("25:00").isEmpty)

    // ================================================================
    // Section 2: Clock time (normal compactness)
    // ================================================================
    // 2.1
    @Test
    def `midnight`(): Unit =
        val st = SayableTime(Locales.EN)
        assertEquals(Some("midnight"), st.formatTime("00:00"))

    // 2.2
    @Test
    def `noon`(): Unit =
        val st = SayableTime(Locales.EN)
        assertEquals(Some("noon"), st.formatTime("12:00"))

    // 2.3
    @Test
    def `oclock`(): Unit =
        val st = SayableTime(Locales.EN)
        assertEquals(Some("three o'clock"), st.formatTime("15:00"))

    // 2.4
    @Test
    def `quarter past`(): Unit =
        val st = SayableTime(Locales.EN)
        assertEquals(Some("a quarter past two"), st.formatTime("14:15"))

    // 2.5
    @Test
    def `half past`(): Unit =
        val st = SayableTime(Locales.EN)
        assertEquals(Some("half past nine"), st.formatTime("09:30"))

    // 2.6
    @Test
    def `quarter to`(): Unit =
        val st = SayableTime(Locales.EN)
        assertEquals(Some("a quarter to eleven"), st.formatTime("10:45"))

    // 2.7
    @Test
    def `five past`(): Unit =
        val st = SayableTime(Locales.EN)
        assertEquals(Some("five past eight"), st.formatTime("08:05"))

    // 2.8
    @Test
    def `five to`(): Unit =
        val st = SayableTime(Locales.EN)
        assertEquals(Some("five to five"), st.formatTime("16:55"))

    // 2.9 — rounds to 0:00 of next day
    @Test
    def `rounds to midnight`(): Unit =
        val st = SayableTime(Locales.EN)
        assertEquals(Some("midnight"), st.formatTime("23:58"))

    // 2.10 — 22 rounds to 20
    @Test
    def `rounds to twenty`(): Unit =
        val st = SayableTime(Locales.EN)
        assertEquals(Some("twenty past seven"), st.formatTime("07:22"))

    // 2.11 — ISO datetime input
    @Test
    def `ISO datetime input`(): Unit =
        val st = SayableTime(Locales.EN)
        assertEquals(Some("a quarter past two"), st.formatTime("2025-01-15T14:15:00"))

    // ================================================================
    // Section 3: Clock time (short compactness)
    // ================================================================
    // 3.1
    @Test
    def `short PM`(): Unit =
        val st = SayableTime(Locales.EN, Compactness.SHORT)
        assertEquals(Some("2:15 PM"), st.formatTime("14:15"))

    // 3.2
    @Test
    def `short AM`(): Unit =
        val st = SayableTime(Locales.EN, Compactness.SHORT)
        assertEquals(Some("9:30 AM"), st.formatTime("09:30"))

    // 3.3
    @Test
    def `short midnight`(): Unit =
        val st = SayableTime(Locales.EN, Compactness.SHORT)
        assertEquals(Some("12:00 AM"), st.formatTime("00:00"))

    // 3.4
    @Test
    def `short noon`(): Unit =
        val st = SayableTime(Locales.EN, Compactness.SHORT)
        assertEquals(Some("12:00 PM"), st.formatTime("12:00"))

    // ================================================================
    // Section 4: Clock time (compact)
    // ================================================================
    // 4.1
    @Test
    def `compact PM`(): Unit =
        val st = SayableTime(Locales.EN, Compactness.COMPACT)
        assertEquals(Some("2:15p"), st.formatTime("14:15"))

    // 4.2
    @Test
    def `compact AM`(): Unit =
        val st = SayableTime(Locales.EN, Compactness.COMPACT)
        assertEquals(Some("9:30a"), st.formatTime("09:30"))

    // ================================================================
    // Section 5: Locale — German
    // ================================================================
    // 5.1 — German half-to pattern
    @Test
    def `German half to pattern`(): Unit =
        val st = SayableTime(Locales.DE)
        assertEquals(Some("halb vier"), st.formatTime("15:30"))

    // ================================================================
    // Section 6: Locale — French
    // ================================================================
    // 6.1
    @Test
    def `French quarter past`(): Unit =
        val st = SayableTime(Locales.FR)
        assertEquals(Some("trois heures et quart"), st.formatTime("15:15"))

    // ================================================================
    // Section 7: Locale — Japanese
    // ================================================================
    // 7.1
    @Test
    def `Japanese half past`(): Unit =
        val st = SayableTime(Locales.JA)
        assertEquals(Some("\u4E09\u6642\u534A"), st.formatTime("15:30"))
