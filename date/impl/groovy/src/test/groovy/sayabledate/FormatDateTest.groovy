package sayabledate

import org.junit.jupiter.api.Test

import sayabledate.locales.Locales

import static org.junit.jupiter.api.Assertions.assertEquals
import static org.junit.jupiter.api.Assertions.assertNull

class FormatDateTest {

    // ================================================================
    // Section 1: Null / edge cases
    // ================================================================

    // 1.1
    @Test
    void 'format_date null returns null'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertNull(f.formatDate(null))
    }

    // 1.2
    @Test
    void 'format_date empty returns null'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertNull(f.formatDate(''))
    }

    // 1.3
    @Test
    void 'format_date invalid returns null'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertNull(f.formatDate('invalid'))
    }

    // 1.4
    @Test
    void 'format_relative null asOf returns null'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertNull(f.formatRelative('2025-03-15', null))
    }

    // 1.5
    @Test
    void 'format_relative null date returns null'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertNull(f.formatRelative(null, '2025-03-15'))
    }

    // ================================================================
    // Section 2: format_date -- normal compactness (English)
    // ================================================================

    // 2.1
    @Test
    void 'format_date March 15th'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('March 15th', f.formatDate('2025-03-15'))
    }

    // 2.2
    @Test
    void 'format_date January 1st'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('January 1st', f.formatDate('2025-01-01'))
    }

    // 2.3
    @Test
    void 'format_date May 22nd'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('May 22nd', f.formatDate('2025-05-22'))
    }

    // 2.4
    @Test
    void 'format_date July 3rd'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('July 3rd', f.formatDate('2025-07-03'))
    }

    // 2.5
    @Test
    void 'format_date December 31st'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('December 31st', f.formatDate('2025-12-31'))
    }

    // 2.6
    @Test
    void 'format_date June 11th no exception'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('June 11th', f.formatDate('2025-06-11'))
    }

    // 2.7
    @Test
    void 'format_date ISO datetime input'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('March 15th', f.formatDate('2025-03-15T14:30:00'))
    }

    // ================================================================
    // Section 3: format_date -- short compactness (English)
    // ================================================================

    // 3.1
    @Test
    void 'format_date short Mar 15'() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.SHORT)
        assertEquals('Mar 15', f.formatDate('2025-03-15'))
    }

    // 3.2
    @Test
    void 'format_date short Jan 1'() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.SHORT)
        assertEquals('Jan 1', f.formatDate('2025-01-01'))
    }

    // 3.3
    @Test
    void 'format_date short Dec 25'() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.SHORT)
        assertEquals('Dec 25', f.formatDate('2025-12-25'))
    }

    // ================================================================
    // Section 4: format_date -- compact (English)
    // ================================================================

    // 4.1
    @Test
    void 'format_date compact 3-15'() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.COMPACT)
        assertEquals('3/15', f.formatDate('2025-03-15'))
    }

    // 4.2
    @Test
    void 'format_date compact 1-1'() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.COMPACT)
        assertEquals('1/1', f.formatDate('2025-01-01'))
    }

    // ================================================================
    // Section 5: format_relative -- proximity tiers (English)
    // ================================================================

    // 5.1
    @Test
    void 'format_relative today'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('today', f.formatRelative('2025-03-15', '2025-03-15'))
    }

    // 5.2
    @Test
    void 'format_relative tomorrow'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('tomorrow', f.formatRelative('2025-03-16', '2025-03-15'))
    }

    // 5.3
    @Test
    void 'format_relative yesterday'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('yesterday', f.formatRelative('2025-03-14', '2025-03-15'))
    }

    // 5.4
    @Test
    void 'format_relative day after tomorrow'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('the day after tomorrow', f.formatRelative('2025-03-17', '2025-03-15'))
    }

    // 5.5
    @Test
    void 'format_relative day before yesterday'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('the day before yesterday', f.formatRelative('2025-03-13', '2025-03-15'))
    }

    // 5.6
    @Test
    void 'format_relative this Wednesday'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('this Wednesday', f.formatRelative('2025-03-19', '2025-03-15'))
    }

    // 5.7
    @Test
    void 'format_relative this Thursday'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('this Thursday', f.formatRelative('2025-03-20', '2025-03-15'))
    }

    // 5.8
    @Test
    void 'format_relative last Tuesday'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('last Tuesday', f.formatRelative('2025-03-11', '2025-03-15'))
    }

    // 5.9
    @Test
    void 'format_relative next Saturday'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('next Saturday', f.formatRelative('2025-03-22', '2025-03-15'))
    }

    // 5.10
    @Test
    void 'format_relative next Thursday'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('next Thursday', f.formatRelative('2025-03-27', '2025-03-15'))
    }

    // 5.11
    @Test
    void 'format_relative calendar same year past'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('March 1st', f.formatRelative('2025-03-01', '2025-03-15'))
    }

    // 5.12
    @Test
    void 'format_relative calendar same year future'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('April 10th', f.formatRelative('2025-04-10', '2025-03-15'))
    }

    // 5.13
    @Test
    void 'format_relative different year future'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('January 5th, 2026', f.formatRelative('2026-01-05', '2025-03-15'))
    }

    // 5.14
    @Test
    void 'format_relative past year'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('December 25th, 2024', f.formatRelative('2024-12-25', '2025-03-15'))
    }

    // ================================================================
    // Section 6: format_relative -- compact skips weekday tiers
    // ================================================================

    // 6.1
    @Test
    void 'format_relative compact today'() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.COMPACT)
        assertEquals('today', f.formatRelative('2025-03-15', '2025-03-15'))
    }

    // 6.2
    @Test
    void 'format_relative compact tomorrow'() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.COMPACT)
        assertEquals('tomorrow', f.formatRelative('2025-03-16', '2025-03-15'))
    }

    // 6.3
    @Test
    void 'format_relative compact goes numeric 3-19'() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.COMPACT)
        assertEquals('3/19', f.formatRelative('2025-03-19', '2025-03-15'))
    }

    // 6.4
    @Test
    void 'format_relative compact different year 1-5-26'() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.COMPACT)
        assertEquals('1/5/26', f.formatRelative('2026-01-05', '2025-03-15'))
    }

    // ================================================================
    // Section 7: Locale -- German
    // ================================================================

    // 7.1
    @Test
    void 'format_date German'() {
        SayableDate f = new SayableDate(Locales.DE)
        assertEquals('15. M\u00E4rz', f.formatDate('2025-03-15'))
    }

    // 7.2
    @Test
    void 'format_relative German tomorrow'() {
        SayableDate f = new SayableDate(Locales.DE)
        assertEquals('morgen', f.formatRelative('2025-03-16', '2025-03-15'))
    }

    // 7.3
    @Test
    void 'format_relative German day after tomorrow'() {
        SayableDate f = new SayableDate(Locales.DE)
        assertEquals('\u00FCbermorgen', f.formatRelative('2025-03-17', '2025-03-15'))
    }

    // 7.4
    @Test
    void 'format_relative German this Wednesday'() {
        SayableDate f = new SayableDate(Locales.DE)
        assertEquals('diesen Mittwoch', f.formatRelative('2025-03-19', '2025-03-15'))
    }

    // ================================================================
    // Section 8: Locale -- French
    // ================================================================

    // 8.1
    @Test
    void 'format_date French 1er mars'() {
        SayableDate f = new SayableDate(Locales.FR)
        assertEquals('1er mars', f.formatDate('2025-03-01'))
    }

    // 8.2
    @Test
    void 'format_date French 15 mars'() {
        SayableDate f = new SayableDate(Locales.FR)
        assertEquals('15 mars', f.formatDate('2025-03-15'))
    }

    // 8.3
    @Test
    void 'format_relative French tomorrow'() {
        SayableDate f = new SayableDate(Locales.FR)
        assertEquals('demain', f.formatRelative('2025-03-16', '2025-03-15'))
    }

    // ================================================================
    // Section 9: Locale -- Japanese
    // ================================================================

    // 9.1
    @Test
    void 'format_date Japanese'() {
        SayableDate f = new SayableDate(Locales.JA)
        assertEquals('3\u670815\u65E5', f.formatDate('2025-03-15'))
    }

    // 9.2
    @Test
    void 'format_relative Japanese tomorrow'() {
        SayableDate f = new SayableDate(Locales.JA)
        assertEquals('\u660E\u65E5', f.formatRelative('2025-03-16', '2025-03-15'))
    }

    // 9.3
    @Test
    void 'format_relative Japanese this Wednesday'() {
        SayableDate f = new SayableDate(Locales.JA)
        assertEquals('\u4ECA\u5EA6\u306E\u6C34\u66DC\u65E5', f.formatRelative('2025-03-19', '2025-03-15'))
    }

    // ================================================================
    // Section 10: Locale -- Russian (genitive months)
    // ================================================================

    // 10.1
    @Test
    void 'format_date Russian genitive months'() {
        SayableDate f = new SayableDate(Locales.RU)
        assertEquals('15 \u043C\u0430\u0440\u0442\u0430', f.formatDate('2025-03-15'))
    }

    // 10.2
    @Test
    void 'format_relative Russian tomorrow'() {
        SayableDate f = new SayableDate(Locales.RU)
        assertEquals('\u0437\u0430\u0432\u0442\u0440\u0430', f.formatRelative('2025-03-16', '2025-03-15'))
    }

    // ================================================================
    // Section 11: Locale -- Arabic
    // ================================================================

    // 11.1
    @Test
    void 'format_date Arabic'() {
        SayableDate f = new SayableDate(Locales.AR)
        assertEquals('15 \u0645\u0627\u0631\u0633', f.formatDate('2025-03-15'))
    }

    // 11.2
    @Test
    void 'format_relative Arabic tomorrow'() {
        SayableDate f = new SayableDate(Locales.AR)
        assertEquals('\u063A\u062F\u0627\u064B', f.formatRelative('2025-03-16', '2025-03-15'))
    }

    // ================================================================
    // Section 12: Locale -- Spanish
    // ================================================================

    // 12.1
    @Test
    void 'format_date Spanish'() {
        SayableDate f = new SayableDate(Locales.ES)
        assertEquals('15 de marzo', f.formatDate('2025-03-15'))
    }

    // 12.2
    @Test
    void 'format_relative Spanish day after tomorrow'() {
        SayableDate f = new SayableDate(Locales.ES)
        assertEquals('pasado ma\u00F1ana', f.formatRelative('2025-03-17', '2025-03-15'))
    }

    // ================================================================
    // Version
    // ================================================================

    @Test
    void 'version matches config'() {
        assertEquals('0.5.0', SayableDate.VERSION)
    }

    // ================================================================
    // format_date_with_year
    // ================================================================

    // 13.1
    @Test
    void 'format date with year en normal 2018-02-04'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('February 4th, 2018', f.formatDateWithYear('2018-02-04'))
    }

    // 13.2
    @Test
    void 'format date with year en short 2025-03-15'() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.SHORT)
        assertEquals('Mar 15, 2025', f.formatDateWithYear('2025-03-15'))
    }

    // 13.3
    @Test
    void 'format date with year en compact 1997-01-21'() {
        SayableDate f = new SayableDate(Locales.EN, Compactness.COMPACT)
        assertEquals('1/21/97', f.formatDateWithYear('1997-01-21'))
    }

    // 13.4
    @Test
    void 'two digit year keeps its leading zero'() {
        SayableDate f = new SayableDate(Locales.TG, Compactness.COMPACT)
        assertEquals('20/5/07', f.formatDateWithYear('2007-05-20'))
    }

    // 13.5
    @Test
    void 'format date with year fi short 1996-06-21'() {
        SayableDate f = new SayableDate(Locales.FI, Compactness.SHORT)
        assertEquals('21. kes\u00E4kuuta 1996', f.formatDateWithYear('1996-06-21'))
    }

    // ================================================================
    // Short month names (locales that keep the full genitive)
    // ================================================================

    // 14.1
    @Test
    void 'short month names locales that keep the sk short 2031-02-15'() {
        SayableDate f = new SayableDate(Locales.SK, Compactness.SHORT)
        assertEquals('15. febru\u00E1ra', f.formatDate('2031-02-15'))
    }

    // 14.2
    @Test
    void 'short month names locales that keep the cs short 2025-12-10'() {
        SayableDate f = new SayableDate(Locales.CS, Compactness.SHORT)
        assertEquals('10. prosince', f.formatDate('2025-12-10'))
    }

    // 14.3
    @Test
    void 'short month names locales that keep the uk short 2025-11-05'() {
        SayableDate f = new SayableDate(Locales.UK, Compactness.SHORT)
        assertEquals('5 \u043B\u0438\u0441\u0442\u043E\u043F\u0430\u0434\u0430', f.formatDate('2025-11-05'))
    }

    // 14.4
    @Test
    void 'short month names locales that keep the fi short 1998-08-08'() {
        SayableDate f = new SayableDate(Locales.FI, Compactness.SHORT)
        assertEquals('8. elokuuta', f.formatRelative('1998-08-08', '1998-08-15'))
    }

    // ================================================================
    // format_relative — short phrases
    // ================================================================

    // 15.1
    @Test
    void 'day after tomorrow kw short 2035-12-04'() {
        SayableDate f = new SayableDate(Locales.KW, Compactness.SHORT)
        assertEquals('an Mth ma', f.formatRelative('2035-12-04', '2035-12-02'))
    }

    // 15.2
    @Test
    void 'day before yesterday'() {
        SayableDate f = new SayableDate(Locales.MAM, Compactness.SHORT)
        assertEquals('Dom nchi\'j', f.formatRelative('2000-01-23', '2000-01-25'))
    }

    // 15.3
    @Test
    void 'day after tomorrow kek short 2014-10-24'() {
        SayableDate f = new SayableDate(Locales.KEK, Compactness.SHORT)
        assertEquals('a\'in Vie', f.formatRelative('2014-10-24', '2014-10-22'))
    }

    // ================================================================
    // Input validation
    // ================================================================

    // 16.1
    @Test
    void 'february 30 doesnt exist'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertNull(f.formatDate('2025-02-30'))
    }

    // 16.2
    @Test
    void 'month 13'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertNull(f.formatDate('2025-13-01'))
    }

    // 16.3
    @Test
    void 'unpadded month and day'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertNull(f.formatDate('2025-6-1'))
    }

    // 16.4
    @Test
    void 'surrounding whitespace'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertNull(f.formatDate(' 2025-06-01'))
    }

    // 16.5
    @Test
    void 'an iso datetime only the date part'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertEquals('June 1st', f.formatDate('2025-06-01T10:00:00'))
    }

    // 16.6
    @Test
    void 'february 29 in a non leap year'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertNull(f.formatDateWithYear('2023-02-29'))
    }

    // 16.7
    @Test
    void 'invalid asof'() {
        SayableDate f = new SayableDate(Locales.EN)
        assertNull(f.formatRelative('2025-03-16', '2025-04-31'))
    }
}
