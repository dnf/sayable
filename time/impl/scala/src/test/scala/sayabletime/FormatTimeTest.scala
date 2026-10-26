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

    // 6.2
    @Test
    def `French singular hour`(): Unit =
        val st = SayableTime(Locales.FR)
        assertEquals(Some("une heure"), st.formatTime("13:00"))

    // 6.3
    @Test
    def `French half past singular hour`(): Unit =
        val st = SayableTime(Locales.FR)
        assertEquals(Some("une heure et demie"), st.formatTime("13:30"))

    // 6.4
    @Test
    def `French quarter to`(): Unit =
        val st = SayableTime(Locales.FR)
        assertEquals(Some("trois heures moins le quart"), st.formatTime("14:45"))

    // 6.5
    @Test
    def `French ten to`(): Unit =
        val st = SayableTime(Locales.FR)
        assertEquals(Some("trois heures moins dix"), st.formatTime("14:50"))

    // ================================================================
    // Section 7: Locale — Japanese
    // ================================================================
    // 7.1
    @Test
    def `Japanese half past`(): Unit =
        val st = SayableTime(Locales.JA)
        assertEquals(Some("\u4E09\u6642\u534A"), st.formatTime("15:30"))

    // ================================================================
    // Section 8: Locale — Finnish (dot separator, short)
    // ================================================================
    // 8.1
    @Test
    def `Finnish dot separator`(): Unit =
        val st = SayableTime(Locales.FI, Compactness.SHORT)
        assertEquals(Some("14.15"), st.formatTime("14:15"))

    // 8.2
    @Test
    def `Finnish midnight dot`(): Unit =
        val st = SayableTime(Locales.FI, Compactness.SHORT)
        assertEquals(Some("0.00"), st.formatTime("00:00"))

    // ================================================================
    // Minutes in short and compact modes
    // ================================================================

    // 9.1
    @Test
    def `digital modes keep the exact minute en short 18-01`(): Unit =
        val f = SayableTime(Locales.EN, Compactness.SHORT)
        assertEquals(Some("6:01 PM"), f.formatTime("18:01"))

    // 9.2
    @Test
    def `digital modes keep the exact minute en compact 19-05`(): Unit =
        val f = SayableTime(Locales.EN, Compactness.COMPACT)
        assertEquals(Some("7:05p"), f.formatTime("19:05"))

    // ================================================================
    // Input validation
    // ================================================================

    // 10.1
    @Test
    def `one digit hour`(): Unit =
        val f = SayableTime(Locales.EN)
        assertEquals(Some("half past nine"), f.formatTime("9:30"))

    // 10.2
    @Test
    def `two digit hour`(): Unit =
        val f = SayableTime(Locales.EN)
        assertEquals(Some("half past nine"), f.formatTime("09:30"))

    // 10.3
    @Test
    def `leading whitespace`(): Unit =
        val f = SayableTime(Locales.EN)
        assertEquals(None, f.formatTime(" 9:30"))

    // 10.4
    @Test
    def `trailing whitespace`(): Unit =
        val f = SayableTime(Locales.EN)
        assertEquals(None, f.formatTime("9:30 "))

    // 10.5
    @Test
    def `minutes need two digits`(): Unit =
        val f = SayableTime(Locales.EN)
        assertEquals(None, f.formatTime("9:5"))

    // 10.6
    @Test
    def `hour out of range`(): Unit =
        val f = SayableTime(Locales.EN)
        assertEquals(None, f.formatTime("24:00"))

    // 10.7
    @Test
    def `seconds are allowed and ignored`(): Unit =
        val f = SayableTime(Locales.EN)
        assertEquals(Some("a quarter past two"), f.formatTime("14:15:30"))

    // 10.8
    @Test
    def `iso datetime with zone suffix ignored`(): Unit =
        val f = SayableTime(Locales.EN)
        assertEquals(Some("a quarter past two"), f.formatTime("2025-01-15T14:15:00Z"))

    // 10.9
    @Test
    def `iso datetime with an impossible date`(): Unit =
        val f = SayableTime(Locales.EN)
        assertEquals(None, f.formatTime("2025-02-30T14:15:00"))
