package sayabletime

import org.junit.jupiter.api.Test

import sayabletime.locales.Locales

import static org.junit.jupiter.api.Assertions.assertEquals
import static org.junit.jupiter.api.Assertions.assertNull

class FormatTimeTest {

    // ================================================================
    // Section 1: Null / edge cases
    // ================================================================

    // 1.1
    @Test
    void 'null input returns null'() {
        assertNull(SayableTime.formatTimeDefault(null))
    }

    // 1.2
    @Test
    void 'empty string returns null'() {
        assertNull(SayableTime.formatTimeDefault(''))
    }

    // 1.3
    @Test
    void 'invalid string returns null'() {
        assertNull(SayableTime.formatTimeDefault('invalid'))
    }

    // 1.4
    @Test
    void 'out of range returns null'() {
        assertNull(SayableTime.formatTimeDefault('25:00'))
    }

    // ================================================================
    // Section 2: Clock time (normal compactness)
    // ================================================================

    // 2.1
    @Test
    void 'midnight'() {
        SayableTime st = new SayableTime(Locales.EN)
        assertEquals('midnight', st.formatTime('00:00'))
    }

    // 2.2
    @Test
    void 'noon'() {
        SayableTime st = new SayableTime(Locales.EN)
        assertEquals('noon', st.formatTime('12:00'))
    }

    // 2.3
    @Test
    void 'o clock'() {
        SayableTime st = new SayableTime(Locales.EN)
        assertEquals("three o'clock", st.formatTime('15:00'))
    }

    // 2.4
    @Test
    void 'quarter past'() {
        SayableTime st = new SayableTime(Locales.EN)
        assertEquals('a quarter past two', st.formatTime('14:15'))
    }

    // 2.5
    @Test
    void 'half past'() {
        SayableTime st = new SayableTime(Locales.EN)
        assertEquals('half past nine', st.formatTime('09:30'))
    }

    // 2.6
    @Test
    void 'quarter to'() {
        SayableTime st = new SayableTime(Locales.EN)
        assertEquals('a quarter to eleven', st.formatTime('10:45'))
    }

    // 2.7
    @Test
    void 'five past'() {
        SayableTime st = new SayableTime(Locales.EN)
        assertEquals('five past eight', st.formatTime('08:05'))
    }

    // 2.8
    @Test
    void 'five to'() {
        SayableTime st = new SayableTime(Locales.EN)
        assertEquals('five to five', st.formatTime('16:55'))
    }

    // 2.9
    @Test
    void 'rounds to midnight'() {
        SayableTime st = new SayableTime(Locales.EN)
        assertEquals('midnight', st.formatTime('23:58'))
    }

    // 2.10
    @Test
    void 'rounds to twenty'() {
        SayableTime st = new SayableTime(Locales.EN)
        assertEquals('twenty past seven', st.formatTime('07:22'))
    }

    // 2.11
    @Test
    void 'ISO datetime input'() {
        SayableTime st = new SayableTime(Locales.EN)
        assertEquals('a quarter past two', st.formatTime('2025-01-15T14:15:00'))
    }

    // ================================================================
    // Section 3: Clock time (short compactness)
    // ================================================================

    // 3.1
    @Test
    void 'short PM'() {
        SayableTime st = new SayableTime(Locales.EN, Compactness.SHORT)
        assertEquals('2:15 PM', st.formatTime('14:15'))
    }

    // 3.2
    @Test
    void 'short AM'() {
        SayableTime st = new SayableTime(Locales.EN, Compactness.SHORT)
        assertEquals('9:30 AM', st.formatTime('09:30'))
    }

    // 3.3
    @Test
    void 'short midnight'() {
        SayableTime st = new SayableTime(Locales.EN, Compactness.SHORT)
        assertEquals('12:00 AM', st.formatTime('00:00'))
    }

    // 3.4
    @Test
    void 'short noon'() {
        SayableTime st = new SayableTime(Locales.EN, Compactness.SHORT)
        assertEquals('12:00 PM', st.formatTime('12:00'))
    }

    // ================================================================
    // Section 4: Clock time (compact)
    // ================================================================

    // 4.1
    @Test
    void 'compact PM'() {
        SayableTime st = new SayableTime(Locales.EN, Compactness.COMPACT)
        assertEquals('2:15p', st.formatTime('14:15'))
    }

    // 4.2
    @Test
    void 'compact AM'() {
        SayableTime st = new SayableTime(Locales.EN, Compactness.COMPACT)
        assertEquals('9:30a', st.formatTime('09:30'))
    }

    // ================================================================
    // Section 5: Locale -- German
    // ================================================================

    // 5.1
    @Test
    void 'German half-to pattern'() {
        SayableTime st = new SayableTime(Locales.DE)
        assertEquals('halb vier', st.formatTime('15:30'))
    }

    // ================================================================
    // Section 6: Locale -- French
    // ================================================================

    // 6.1
    @Test
    void 'French quarter past'() {
        SayableTime st = new SayableTime(Locales.FR)
        assertEquals('trois heures et quart', st.formatTime('15:15'))
    }

    // 6.2
    @Test
    void 'French on the hour'() {
        SayableTime st = new SayableTime(Locales.FR)
        assertEquals('une heure', st.formatTime('13:00'))
    }

    // 6.3
    @Test
    void 'French half past'() {
        SayableTime st = new SayableTime(Locales.FR)
        assertEquals('une heure et demie', st.formatTime('13:30'))
    }

    // 6.4
    @Test
    void 'French quarter to'() {
        SayableTime st = new SayableTime(Locales.FR)
        assertEquals('trois heures moins le quart', st.formatTime('14:45'))
    }

    // 6.5
    @Test
    void 'French ten to'() {
        SayableTime st = new SayableTime(Locales.FR)
        assertEquals('trois heures moins dix', st.formatTime('14:50'))
    }

    // ================================================================
    // Section 7: Locale -- Japanese
    // ================================================================

    // 7.1
    @Test
    void 'Japanese half past'() {
        SayableTime st = new SayableTime(Locales.JA)
        assertEquals('\u4E09\u6642\u534A', st.formatTime('15:30'))
    }

    // ================================================================
    // Section 8: Locale -- Finnish (dot separator, short)
    // ================================================================

    // 8.1
    @Test
    void 'Finnish dot separator'() {
        SayableTime st = new SayableTime(Locales.FI, Compactness.SHORT)
        assertEquals('14.15', st.formatTime('14:15'))
    }

    // 8.2
    @Test
    void 'Finnish midnight dot'() {
        SayableTime st = new SayableTime(Locales.FI, Compactness.SHORT)
        assertEquals('0.00', st.formatTime('00:00'))
    }

    // ================================================================
    // Version
    // ================================================================

    @Test
    void 'version matches config'() {
        assertEquals('0.5.0', SayableTime.VERSION)
    }

    // ================================================================
    // Minutes in short and compact modes
    // ================================================================

    // 9.1
    @Test
    void 'digital modes keep the exact minute en short 18:01'() {
        SayableTime f = new SayableTime(Locales.EN, Compactness.SHORT)
        assertEquals('6:01 PM', f.formatTime('18:01'))
    }

    // 9.2
    @Test
    void 'digital modes keep the exact minute en compact 19:05'() {
        SayableTime f = new SayableTime(Locales.EN, Compactness.COMPACT)
        assertEquals('7:05p', f.formatTime('19:05'))
    }

    // ================================================================
    // Input validation
    // ================================================================

    // 10.1
    @Test
    void 'one digit hour'() {
        SayableTime f = new SayableTime(Locales.EN)
        assertEquals('half past nine', f.formatTime('9:30'))
    }

    // 10.2
    @Test
    void 'two digit hour'() {
        SayableTime f = new SayableTime(Locales.EN)
        assertEquals('half past nine', f.formatTime('09:30'))
    }

    // 10.3
    @Test
    void 'leading whitespace'() {
        SayableTime f = new SayableTime(Locales.EN)
        assertNull(f.formatTime(' 9:30'))
    }

    // 10.4
    @Test
    void 'trailing whitespace'() {
        SayableTime f = new SayableTime(Locales.EN)
        assertNull(f.formatTime('9:30 '))
    }

    // 10.5
    @Test
    void 'minutes need two digits'() {
        SayableTime f = new SayableTime(Locales.EN)
        assertNull(f.formatTime('9:5'))
    }

    // 10.6
    @Test
    void 'hour out of range'() {
        SayableTime f = new SayableTime(Locales.EN)
        assertNull(f.formatTime('24:00'))
    }

    // 10.7
    @Test
    void 'seconds are allowed and ignored'() {
        SayableTime f = new SayableTime(Locales.EN)
        assertEquals('a quarter past two', f.formatTime('14:15:30'))
    }

    // 10.8
    @Test
    void 'iso datetime with zone suffix ignored'() {
        SayableTime f = new SayableTime(Locales.EN)
        assertEquals('a quarter past two', f.formatTime('2025-01-15T14:15:00Z'))
    }

    // 10.9
    @Test
    void 'iso datetime with an impossible date'() {
        SayableTime f = new SayableTime(Locales.EN)
        assertNull(f.formatTime('2025-02-30T14:15:00'))
    }
}
