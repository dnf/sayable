package sayableage

import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Test
import java.time.LocalDate
import sayableage.locales.Locales

import static org.junit.jupiter.api.Assertions.assertEquals
import static org.junit.jupiter.api.Assertions.assertNotNull
import static org.junit.jupiter.api.Assertions.assertNull
import static org.junit.jupiter.api.Assertions.assertTrue

class FormatAgeTest {

    @AfterEach
    void resetTimeNow() {
        SayableAge.timeNow = { -> LocalDate.now() }
    }

    // ================================================================
    // formatAge -- null/edge cases
    // ================================================================
    // 1.1
    @Test
    void 'null dob returns null'() {
        assertNull(SayableAge.formatAgeDefault(null, '2025-06-15'))
    }

    // 1.3
    @Test
    void 'empty string returns null'() {
        assertNull(SayableAge.formatAgeDefault('', '2025-06-15'))
    }

    // 1.4
    @Test
    void 'future dob returns null'() {
        assertNull(SayableAge.formatAgeDefault('2025-07-01', '2025-06-15'))
    }

    // 1.5
    @Test
    void 'exactly 500 years is allowed'() {
        assertEquals('500 years', SayableAge.formatAgeDefault('1525-06-15', '2025-06-15'))
    }

    // 1.6
    @Test
    void '501 years exceeds max age'() {
        assertNull(SayableAge.formatAgeDefault('1524-06-15', '2025-06-15'))
    }

    // 1.7
    @Test
    void '1000 years exceeds max age'() {
        assertNull(SayableAge.formatAgeDefault('1025-06-15', '2025-06-15'))
    }

    // ================================================================
    // formatAge -- days tier (0-6)
    // ================================================================
    // 2.1
    @Test
    void 'born today'() {
        assertEquals('Newborn', SayableAge.formatAgeDefault('2025-06-15', '2025-06-15'))
    }

    // 2.2
    @Test
    void '1 day ago (singular)'() {
        assertEquals('1 day', SayableAge.formatAgeDefault('2025-06-14', '2025-06-15'))
    }

    // 2.3
    @Test
    void '3 days ago'() {
        assertEquals('3 days', SayableAge.formatAgeDefault('2025-06-12', '2025-06-15'))
    }

    // 2.4
    @Test
    void '6 days ago'() {
        assertEquals('6 days', SayableAge.formatAgeDefault('2025-06-09', '2025-06-15'))
    }

    // 2.5
    @Test
    void '7 days becomes 1 week'() {
        assertEquals('1 week', SayableAge.formatAgeDefault('2025-06-08', '2025-06-15'))
    }

    // ================================================================
    // formatAge -- weeks+days tier (7 days to less than 3 months)
    // ================================================================
    // 3.1
    @Test
    void '7 days is 1 week'() {
        assertEquals('1 week', SayableAge.formatAgeDefault('2025-06-08', '2025-06-15'))
    }

    // 3.2
    @Test
    void '8 days is 1 week 1 day'() {
        assertEquals('1 week, 1 day', SayableAge.formatAgeDefault('2025-06-07', '2025-06-15'))
    }

    // 3.3
    @Test
    void '9 days is 1 week 2 days'() {
        assertEquals('1 week, 2 days', SayableAge.formatAgeDefault('2025-06-06', '2025-06-15'))
    }

    // 3.4
    @Test
    void '13 days is 1 week 6 days'() {
        assertEquals('1 week, 6 days', SayableAge.formatAgeDefault('2025-06-02', '2025-06-15'))
    }

    // 3.5
    @Test
    void '14 days is 2 weeks'() {
        assertEquals('2 weeks', SayableAge.formatAgeDefault('2025-06-01', '2025-06-15'))
    }

    // 3.6
    @Test
    void '15 days is 2 weeks 1 day'() {
        assertEquals('2 weeks, 1 day', SayableAge.formatAgeDefault('2025-05-31', '2025-06-15'))
    }

    // 3.7
    @Test
    void '20 days is 2 weeks 6 days'() {
        assertEquals('2 weeks, 6 days', SayableAge.formatAgeDefault('2025-05-26', '2025-06-15'))
    }

    // 3.8
    @Test
    void '21 days is 3 weeks'() {
        assertEquals('3 weeks', SayableAge.formatAgeDefault('2025-05-25', '2025-06-15'))
    }

    // 3.9
    @Test
    void 'at 1 cal month still weeks+days'() {
        assertEquals('4 weeks, 3 days', SayableAge.formatAgeDefault('2025-05-15', '2025-06-15'))
    }

    // 3.10
    @Test
    void 'at 2 cal months still weeks+days'() {
        assertEquals('8 weeks, 5 days', SayableAge.formatAgeDefault('2025-04-15', '2025-06-15'))
    }

    // 3.11
    @Test
    void 'one day before 3mo still weeks'() {
        assertEquals('13 weeks', SayableAge.formatAgeDefault('2025-03-15', '2025-06-14'))
    }

    // 3.12
    @Test
    void 'on 3mo birthday switches'() {
        assertEquals('3 months', SayableAge.formatAgeDefault('2025-03-15', '2025-06-15'))
    }

    // ================================================================
    // formatAge -- month boundaries: standard months
    // ================================================================
    // 4.1
    @Test
    void 'Jan1 to Apr1 is 3mo'() {
        assertEquals('3 months', SayableAge.formatAgeDefault('2025-01-01', '2025-04-01'))
    }

    // 4.2
    @Test
    void 'Jan1 to Mar31 still weeks'() {
        String result = SayableAge.formatAgeDefault('2025-01-01', '2025-03-31')
        assertNotNull(result)
        assertTrue(result.contains('weeks'))
    }

    // 4.3
    @Test
    void 'Jun15 to Sep15 is 3mo'() {
        assertEquals('3 months', SayableAge.formatAgeDefault('2025-06-15', '2025-09-15'))
    }

    // 4.4
    @Test
    void 'Jun15 to Sep14 still weeks'() {
        String result = SayableAge.formatAgeDefault('2025-06-15', '2025-09-14')
        assertNotNull(result)
        assertTrue(result.contains('weeks'))
    }

    // 4.5
    @Test
    void 'Jun15 to Dec15 is 6mo'() {
        assertEquals('6 months', SayableAge.formatAgeDefault('2025-06-15', '2025-12-15'))
    }

    // ================================================================
    // formatAge -- month boundaries: February non-leap
    // ================================================================
    // 5.1
    @Test
    void 'Jan31 to Feb28 non-leap'() {
        assertEquals('4 weeks', SayableAge.formatAgeDefault('2025-01-31', '2025-02-28'))
    }

    // 5.2
    @Test
    void 'Jan31 to Apr30 is 3mo clamp'() {
        assertEquals('3 months', SayableAge.formatAgeDefault('2025-01-31', '2025-04-30'))
    }

    // 5.3
    @Test
    void 'Jan31 to Apr29 still weeks'() {
        String result = SayableAge.formatAgeDefault('2025-01-31', '2025-04-29')
        assertNotNull(result)
        assertTrue(result.contains('weeks'))
    }

    // 5.4
    @Test
    void 'Feb1 to May1 is 3mo'() {
        assertEquals('3 months', SayableAge.formatAgeDefault('2025-02-01', '2025-05-01'))
    }

    // 5.5
    @Test
    void 'Feb1 to Apr30 still weeks'() {
        String result = SayableAge.formatAgeDefault('2025-02-01', '2025-04-30')
        assertNotNull(result)
        assertTrue(result.contains('weeks'))
    }

    // ================================================================
    // formatAge -- month boundaries: February leap year
    // ================================================================
    // 6.1
    @Test
    void 'Jan31 to Feb29 leap'() {
        assertEquals('4 weeks, 1 day', SayableAge.formatAgeDefault('2024-01-31', '2024-02-29'))
    }

    // 6.2
    @Test
    void 'Jan31 to Feb28 leap'() {
        assertEquals('4 weeks', SayableAge.formatAgeDefault('2024-01-31', '2024-02-28'))
    }

    // 6.3
    @Test
    void 'Jan31 to Apr30 leap is 3mo'() {
        assertEquals('3 months', SayableAge.formatAgeDefault('2024-01-31', '2024-04-30'))
    }

    // 6.4
    @Test
    void 'Jan30 to Feb29 leap still weeks'() {
        String result = SayableAge.formatAgeDefault('2024-01-30', '2024-02-29')
        assertNotNull(result)
        assertTrue(result.contains('weeks'))
    }

    // 6.5
    @Test
    void 'Jan30 to Feb28 leap still weeks'() {
        String result = SayableAge.formatAgeDefault('2024-01-30', '2024-02-28')
        assertNotNull(result)
        assertTrue(result.contains('weeks'))
    }

    // ================================================================
    // formatAge -- month boundaries: 30-day months
    // ================================================================
    // 7.1
    @Test
    void 'Mar31 to Jun30 is 3mo clamped'() {
        assertEquals('3 months', SayableAge.formatAgeDefault('2025-03-31', '2025-06-30'))
    }

    // 7.2
    @Test
    void 'Mar31 to Jun29 still weeks'() {
        String result = SayableAge.formatAgeDefault('2025-03-31', '2025-06-29')
        assertNotNull(result)
        assertTrue(result.contains('weeks'))
    }

    // 7.3
    @Test
    void 'Aug31 to Nov30 is 3mo'() {
        assertEquals('3 months', SayableAge.formatAgeDefault('2025-08-31', '2025-11-30'))
    }

    // 7.4
    @Test
    void 'Aug31 to Nov29 still weeks'() {
        String result = SayableAge.formatAgeDefault('2025-08-31', '2025-11-29')
        assertNotNull(result)
        assertTrue(result.contains('weeks'))
    }

    // ================================================================
    // formatAge -- month boundaries: leap year baby (born Feb 29)
    // ================================================================
    // 8.1
    @Test
    void 'Feb29 to May29 is 3mo'() {
        assertEquals('3 months', SayableAge.formatAgeDefault('2024-02-29', '2024-05-29'))
    }

    // 8.2
    @Test
    void 'Feb29 to May28 still weeks'() {
        String result = SayableAge.formatAgeDefault('2024-02-29', '2024-05-28')
        assertNotNull(result)
        assertTrue(result.contains('weeks'))
    }

    // 8.3
    @Test
    void 'Feb29 2024 to Feb28 2025 is 12mo'() {
        assertEquals('12 months', SayableAge.formatAgeDefault('2024-02-29', '2025-02-28'))
    }

    // 8.4
    @Test
    void 'Feb29 2024 to Mar1 2025 is 12mo'() {
        assertEquals('12 months', SayableAge.formatAgeDefault('2024-02-29', '2025-03-01'))
    }

    // ================================================================
    // formatAge -- months tier (3-23)
    // ================================================================
    // 9.1
    @Test
    void '3 months at transition'() {
        assertEquals('3 months', SayableAge.formatAgeDefault('2025-01-15', '2025-04-15'))
    }

    // 9.2
    @Test
    void '6 months'() {
        assertEquals('6 months', SayableAge.formatAgeDefault('2025-01-15', '2025-07-15'))
    }

    // 9.3
    @Test
    void '12 months not 1 year'() {
        assertEquals('12 months', SayableAge.formatAgeDefault('2024-06-15', '2025-06-15'))
    }

    // 9.4
    @Test
    void '23 months at upper'() {
        assertEquals('23 months', SayableAge.formatAgeDefault('2024-01-15', '2025-12-15'))
    }

    // 9.5
    @Test
    void 'one day before boundary'() {
        assertEquals('5 months', SayableAge.formatAgeDefault('2025-01-15', '2025-07-14'))
    }

    // 9.6
    @Test
    void 'crossing year boundary'() {
        assertEquals('5 months', SayableAge.formatAgeDefault('2024-11-10', '2025-04-10'))
    }

    // ================================================================
    // formatAge -- years+months tier (24-35 months)
    // ================================================================
    // 10.1
    @Test
    void '2 years at 24mo'() {
        assertEquals('2 years', SayableAge.formatAgeDefault('2023-06-15', '2025-06-15'))
    }

    // 10.2
    @Test
    void '2 years 1 month'() {
        assertEquals('2 years, 1 month', SayableAge.formatAgeDefault('2023-06-15', '2025-07-15'))
    }

    // 10.3
    @Test
    void '2 years 6 months'() {
        assertEquals('2 years, 6 months', SayableAge.formatAgeDefault('2023-06-15', '2025-12-15'))
    }

    // 10.4
    @Test
    void '2 years 11 months'() {
        assertEquals('2 years, 11 months', SayableAge.formatAgeDefault('2023-06-15', '2026-05-15'))
    }

    // 10.5
    @Test
    void 'one day before 24mo'() {
        assertEquals('23 months', SayableAge.formatAgeDefault('2023-06-15', '2025-06-14'))
    }

    // ================================================================
    // formatAge -- half-year tier (3-6 years)
    // ================================================================
    // 11.1
    @Test
    void '3 years exactly'() {
        assertEquals('3 years', SayableAge.formatAgeDefault('2022-06-15', '2025-06-15'))
    }

    // 11.2
    @Test
    void '3 years 5 months'() {
        assertEquals('3 years', SayableAge.formatAgeDefault('2022-06-15', '2025-11-15'))
    }

    // 11.3
    @Test
    void '3 and half years at 3y6m'() {
        assertEquals("3\u00BD years", SayableAge.formatAgeDefault('2022-06-15', '2025-12-15'))
    }

    // 11.4
    @Test
    void '3 and half years at 3y11m'() {
        assertEquals("3\u00BD years", SayableAge.formatAgeDefault('2022-06-15', '2026-05-15'))
    }

    // 11.5
    @Test
    void '4 years exactly'() {
        assertEquals('4 years', SayableAge.formatAgeDefault('2021-06-15', '2025-06-15'))
    }

    // 11.6
    @Test
    void '4 and half years'() {
        assertEquals("4\u00BD years", SayableAge.formatAgeDefault('2021-06-15', '2025-12-15'))
    }

    // 11.7
    @Test
    void '5 years'() {
        assertEquals('5 years', SayableAge.formatAgeDefault('2020-06-15', '2025-06-15'))
    }

    // 11.8
    @Test
    void '5 and half years at 5y8m'() {
        assertEquals("5\u00BD years", SayableAge.formatAgeDefault('2020-06-15', '2026-02-15'))
    }

    // 11.9
    @Test
    void '6 years'() {
        assertEquals('6 years', SayableAge.formatAgeDefault('2019-06-15', '2025-06-15'))
    }

    // 11.10
    @Test
    void '6 and half years'() {
        assertEquals("6\u00BD years", SayableAge.formatAgeDefault('2019-06-15', '2025-12-15'))
    }

    // 11.11
    @Test
    void '6 and half years at 6y11m'() {
        assertEquals("6\u00BD years", SayableAge.formatAgeDefault('2019-06-15', '2026-05-15'))
    }

    // 11.12
    @Test
    void 'one day before 3rd bday'() {
        assertEquals('2 years, 11 months', SayableAge.formatAgeDefault('2022-06-15', '2025-06-14'))
    }

    // ================================================================
    // formatAge -- integer tier (7+ years)
    // ================================================================
    // 12.1
    @Test
    void '7 years exactly'() {
        assertEquals('7 years', SayableAge.formatAgeDefault('2018-06-15', '2025-06-15'))
    }

    // 12.2
    @Test
    void '7 years 6 months no half'() {
        assertEquals('7 years', SayableAge.formatAgeDefault('2018-03-20', '2025-06-15'))
    }

    // 12.3
    @Test
    void '45 years'() {
        assertEquals('45 years', SayableAge.formatAgeDefault('1980-01-01', '2025-06-15'))
    }

    // ================================================================
    // formatAge -- cross-year transitions with Feb
    // ================================================================
    // 13.1
    @Test
    void 'Dec31 to Mar31 is 3mo'() {
        assertEquals('3 months', SayableAge.formatAgeDefault('2024-12-31', '2025-03-31'))
    }

    // 13.2
    @Test
    void 'Dec31 to Mar30 still weeks'() {
        String result = SayableAge.formatAgeDefault('2024-12-31', '2025-03-30')
        assertNotNull(result)
        assertTrue(result.contains('weeks'))
    }

    // 13.3
    @Test
    void 'Nov30 to Feb28 is 3mo'() {
        assertEquals('3 months', SayableAge.formatAgeDefault('2024-11-30', '2025-02-28'))
    }

    // 13.4
    @Test
    void 'Nov30 to Feb27 still weeks'() {
        String result = SayableAge.formatAgeDefault('2024-11-30', '2025-02-27')
        assertNotNull(result)
        assertTrue(result.contains('weeks'))
    }

    // ================================================================
    // formatAge -- born-on-31st progression
    // ================================================================
    // 14.1
    @Test
    void 'Jan31 to Apr30 is 3mo'() {
        assertEquals('3 months', SayableAge.formatAgeDefault('2025-01-31', '2025-04-30'))
    }

    // 14.2
    @Test
    void 'Jan31 to May31 is 4mo'() {
        assertEquals('4 months', SayableAge.formatAgeDefault('2025-01-31', '2025-05-31'))
    }

    // 14.3
    @Test
    void 'Jan31 to Jun30 is 5mo clamped'() {
        assertEquals('5 months', SayableAge.formatAgeDefault('2025-01-31', '2025-06-30'))
    }

    // 14.4
    @Test
    void 'Jan31 to Jul1 is 5mo'() {
        assertEquals('5 months', SayableAge.formatAgeDefault('2025-01-31', '2025-07-01'))
    }

    // 14.5
    @Test
    void 'Jan31 to Jul31 is 6mo'() {
        assertEquals('6 months', SayableAge.formatAgeDefault('2025-01-31', '2025-07-31'))
    }

    // ================================================================
    // formatAge -- default asOf (uses current date)
    // ================================================================
    // 15.1, 15.2
    @Test
    void 'default asOf uses mocked today'() {
        SayableAge.timeNow = { -> LocalDate.of(2025, 6, 15) }
        assertEquals('5 years', SayableAge.formatAgeDefault('2020-01-01'))
        assertEquals('5 days', SayableAge.formatAgeDefault('2025-06-10'))
    }

    // ================================================================
    // formatStage -- null/edge cases
    // ================================================================
    // 16.1
    @Test
    void 'stage null dob returns null'() {
        assertNull(SayableAge.formatStageDefault(null, '2025-06-15'))
    }

    // 16.3
    @Test
    void 'stage empty string returns null'() {
        assertNull(SayableAge.formatStageDefault('', '2025-06-15'))
    }

    // 16.4
    @Test
    void 'stage future dob returns null'() {
        assertNull(SayableAge.formatStageDefault('2025-07-01', '2025-06-15'))
    }

    // 16.5
    @Test
    void 'stage exactly 500 years returns Adult'() {
        assertEquals('Adult', SayableAge.formatStageDefault('1525-06-15', '2025-06-15'))
    }

    // 16.6
    @Test
    void 'stage 501 years exceeds max age'() {
        assertNull(SayableAge.formatStageDefault('1524-06-15', '2025-06-15'))
    }

    // ================================================================
    // formatStage -- newborn
    // ================================================================
    // 17.1
    @Test
    void 'stage born today'() {
        assertEquals('Newborn', SayableAge.formatStageDefault('2025-06-15', '2025-06-15'))
    }

    // 17.2
    @Test
    void 'stage 1 day old'() {
        assertEquals('Newborn', SayableAge.formatStageDefault('2025-06-14', '2025-06-15'))
    }

    // 17.3
    @Test
    void 'stage 3 weeks old'() {
        assertEquals('Newborn', SayableAge.formatStageDefault('2025-05-25', '2025-06-15'))
    }

    // 17.4
    @Test
    void 'stage 1 month old'() {
        assertEquals('Newborn', SayableAge.formatStageDefault('2025-05-15', '2025-06-15'))
    }

    // 17.5
    @Test
    void 'stage 1 month 29 days'() {
        assertEquals('Newborn', SayableAge.formatStageDefault('2025-04-16', '2025-06-15'))
    }

    // 17.6
    @Test
    void 'stage exactly 2 months becomes Infant'() {
        assertEquals('Infant', SayableAge.formatStageDefault('2025-04-15', '2025-06-15'))
    }

    // ================================================================
    // formatStage -- infant
    // ================================================================
    // 18.1
    @Test
    void 'stage 2 months'() {
        assertEquals('Infant', SayableAge.formatStageDefault('2025-04-15', '2025-06-15'))
    }

    // 18.2
    @Test
    void 'stage 6 months'() {
        assertEquals('Infant', SayableAge.formatStageDefault('2024-12-15', '2025-06-15'))
    }

    // 18.3
    @Test
    void 'stage 11 months'() {
        assertEquals('Infant', SayableAge.formatStageDefault('2024-07-15', '2025-06-15'))
    }

    // 18.4
    @Test
    void 'stage exactly 12mo becomes Toddler'() {
        assertEquals('Toddler', SayableAge.formatStageDefault('2024-06-15', '2025-06-15'))
    }

    // ================================================================
    // formatStage -- toddler
    // ================================================================
    // 19.1
    @Test
    void 'stage 12 months'() {
        assertEquals('Toddler', SayableAge.formatStageDefault('2024-06-15', '2025-06-15'))
    }

    // 19.2
    @Test
    void 'stage 18 months'() {
        assertEquals('Toddler', SayableAge.formatStageDefault('2024-01-15', '2025-07-15'))
    }

    // 19.3
    @Test
    void 'stage 24 months'() {
        assertEquals('Toddler', SayableAge.formatStageDefault('2023-06-15', '2025-06-15'))
    }

    // 19.4
    @Test
    void 'stage 35 months'() {
        assertEquals('Toddler', SayableAge.formatStageDefault('2023-06-15', '2026-05-15'))
    }

    // 19.5
    @Test
    void 'stage exactly 36mo becomes Child'() {
        assertEquals('Child', SayableAge.formatStageDefault('2022-06-15', '2025-06-15'))
    }

    // ================================================================
    // formatStage -- child
    // ================================================================
    // 20.1
    @Test
    void 'stage 3 years'() {
        assertEquals('Child', SayableAge.formatStageDefault('2022-06-15', '2025-06-15'))
    }

    // 20.2
    @Test
    void 'stage 4 years'() {
        assertEquals('Child', SayableAge.formatStageDefault('2021-06-15', '2025-06-15'))
    }

    // 20.3
    @Test
    void 'stage 6 years'() {
        assertEquals('Child', SayableAge.formatStageDefault('2019-06-15', '2025-06-15'))
    }

    // 20.4
    @Test
    void 'stage 9 years'() {
        assertEquals('Child', SayableAge.formatStageDefault('2016-06-15', '2025-06-15'))
    }

    // 20.5
    @Test
    void 'stage 12y 11mo'() {
        assertEquals('Child', SayableAge.formatStageDefault('2013-06-15', '2026-05-15'))
    }

    // 20.6
    @Test
    void 'stage exactly 13y becomes Teenager'() {
        assertEquals('Teenager', SayableAge.formatStageDefault('2012-06-15', '2025-06-15'))
    }

    // ================================================================
    // formatStage -- teenager
    // ================================================================
    // 21.1
    @Test
    void 'stage 13 years'() {
        assertEquals('Teenager', SayableAge.formatStageDefault('2012-06-15', '2025-06-15'))
    }

    // 21.2
    @Test
    void 'stage 15 years'() {
        assertEquals('Teenager', SayableAge.formatStageDefault('2010-06-15', '2025-06-15'))
    }

    // 21.3
    @Test
    void 'stage 17y 11mo'() {
        assertEquals('Teenager', SayableAge.formatStageDefault('2008-06-15', '2026-05-15'))
    }

    // 21.4
    @Test
    void 'stage exactly 18y becomes Adult'() {
        assertEquals('Adult', SayableAge.formatStageDefault('2007-06-15', '2025-06-15'))
    }

    // ================================================================
    // formatStage -- adult
    // ================================================================
    // 22.1
    @Test
    void 'stage 18 years'() {
        assertEquals('Adult', SayableAge.formatStageDefault('2007-06-15', '2025-06-15'))
    }

    // 22.2
    @Test
    void 'stage 25 years'() {
        assertEquals('Adult', SayableAge.formatStageDefault('2000-06-15', '2025-06-15'))
    }

    // 22.3
    @Test
    void 'stage 45 years'() {
        assertEquals('Adult', SayableAge.formatStageDefault('1980-01-01', '2025-06-15'))
    }

    // ================================================================
    // formatStage -- default asOf
    // ================================================================
    // 23.1, 23.2, 23.3
    @Test
    void 'stage default asOf'() {
        SayableAge.timeNow = { -> LocalDate.of(2025, 6, 15) }
        assertEquals('Newborn', SayableAge.formatStageDefault('2025-06-15'))
        assertEquals('Child', SayableAge.formatStageDefault('2020-01-01'))
        assertEquals('Adult', SayableAge.formatStageDefault('1980-01-01'))
    }

    // ================================================================
    // SayableAge class with English locale
    // ================================================================
    // 24.1, 24.2, 24.3, 24.4, 24.5, 24.6, 24.7, 24.8, 24.9, 24.10, 24.11, 24.12, 24.13, 24.14, 24.15
    @Test
    void 'SayableAge English all tiers'() {
        def pt = new SayableAge(Locales.EN)
        assertEquals('Newborn', pt.formatAge('2025-06-15', '2025-06-15'))
        assertEquals('3 days', pt.formatAge('2025-06-12', '2025-06-15'))
        assertEquals('1 week, 1 day', pt.formatAge('2025-06-07', '2025-06-15'))
        assertEquals('6 months', pt.formatAge('2025-01-15', '2025-07-15'))
        assertEquals('2 years, 1 month', pt.formatAge('2023-06-15', '2025-07-15'))
        assertEquals("3\u00BD years", pt.formatAge('2022-06-15', '2025-12-15'))
        assertEquals('7 years', pt.formatAge('2018-06-15', '2025-06-15'))

        assertEquals('Newborn', pt.formatStage('2025-06-15', '2025-06-15'))
        assertEquals('Infant', pt.formatStage('2025-01-15', '2025-06-15'))
        assertEquals('Toddler', pt.formatStage('2024-06-15', '2025-06-15'))
        assertEquals('Child', pt.formatStage('2022-06-15', '2025-06-15'))
        assertEquals('Teenager', pt.formatStage('2012-06-15', '2025-06-15'))
        assertEquals('Adult', pt.formatStage('2007-06-15', '2025-06-15'))

        assertNull(pt.formatAge(''))
        assertNull(pt.formatStage(''))
    }

    // ================================================================
    // SayableAge with Spanish locale
    // ================================================================
    // 25.1, 25.2, 25.3, 25.4, 25.5, 25.6, 25.7, 25.8, 25.9, 25.10, 25.11, 25.12, 25.13, 25.14, 25.15, 25.16, 25.17, 25.18, 25.19, 25.20
    @Test
    void 'SayableAge Spanish inline locale'() {
        def es = new AgeLocale(
            'es',
            { int n -> n == 1 ? PluralCategory.ONE : PluralCategory.OTHER },
            new Units(
                UnitForms.pluralUnit([(PluralCategory.ONE): "{n} d\u00EDa", (PluralCategory.OTHER): "{n} d\u00EDas"]),
                UnitForms.pluralUnit([(PluralCategory.ONE): "{n} semana", (PluralCategory.OTHER): "{n} semanas"]),
                UnitForms.pluralUnit([(PluralCategory.ONE): "{n} mes", (PluralCategory.OTHER): "{n} meses"]),
                UnitForms.pluralUnit([(PluralCategory.ONE): "{n} a\u00F1o", (PluralCategory.OTHER): "{n} a\u00F1os"])
            ),
            '{0} y medio',
            ', ',
            "Reci\u00E9n nacido",
            new Stages(
                StageLabel.gendered("Reci\u00E9n nacido", "Reci\u00E9n nacida"),
                StageLabel.neutral("Beb\u00E9"),
                StageLabel.gendered("Ni\u00F1o peque\u00F1o", "Ni\u00F1a peque\u00F1a"),
                StageLabel.gendered("Ni\u00F1o", "Ni\u00F1a"),
                StageLabel.neutral('Adolescente'),
                StageLabel.gendered('Adulto', 'Adulta')
            )
        )

        def pt = new SayableAge(es)

        assertEquals("Reci\u00E9n nacido", pt.formatAge('2025-06-15', '2025-06-15'))
        assertEquals("1 d\u00EDa", pt.formatAge('2025-06-14', '2025-06-15'))
        assertEquals("3 d\u00EDas", pt.formatAge('2025-06-12', '2025-06-15'))
        assertEquals('1 semana', pt.formatAge('2025-06-08', '2025-06-15'))
        assertEquals("1 semana, 1 d\u00EDa", pt.formatAge('2025-06-07', '2025-06-15'))
        assertEquals("2 semanas, 6 d\u00EDas", pt.formatAge('2025-05-26', '2025-06-15'))
        assertEquals('6 meses', pt.formatAge('2025-01-15', '2025-07-15'))
        assertEquals("2 a\u00F1os, 1 mes", pt.formatAge('2023-06-15', '2025-07-15'))
        assertEquals("2 a\u00F1os, 6 meses", pt.formatAge('2023-06-15', '2025-12-15'))
        assertEquals("3 a\u00F1os y medio", pt.formatAge('2022-06-15', '2025-12-15'))
        assertEquals("3 a\u00F1os", pt.formatAge('2022-06-15', '2025-06-15'))
        assertEquals("7 a\u00F1os", pt.formatAge('2018-06-15', '2025-06-15'))

        assertEquals("Reci\u00E9n nacido", pt.formatStage('2025-06-15', '2025-06-15'))
        assertEquals("Beb\u00E9", pt.formatStage('2025-01-15', '2025-06-15'))
        assertEquals("Ni\u00F1o peque\u00F1o", pt.formatStage('2024-06-15', '2025-06-15'))
        assertEquals("Ni\u00F1o", pt.formatStage('2022-06-15', '2025-06-15'))
        assertEquals('Adolescente', pt.formatStage('2012-06-15', '2025-06-15'))
        assertEquals('Adulto', pt.formatStage('2007-06-15', '2025-06-15'))

        assertNull(pt.formatAge(''))
        assertNull(pt.formatStage(''))
    }

    // ================================================================
    // Compactness: short
    // ================================================================
    // 26.1, 26.2, 26.3, 26.4, 26.5, 26.6, 26.7, 26.8, 26.9
    @Test
    void 'compact short'() {
        def pt = new SayableAge(Locales.EN, Compactness.SHORT)

        assertEquals('3 d', pt.formatAge('2025-06-12', '2025-06-15'))
        assertEquals('1 wk', pt.formatAge('2025-06-08', '2025-06-15'))
        assertEquals('1 wk, 1 d', pt.formatAge('2025-06-07', '2025-06-15'))
        assertEquals('6 mo', pt.formatAge('2025-01-15', '2025-07-15'))
        assertEquals('2 yr, 1 mo', pt.formatAge('2023-06-15', '2025-07-15'))
        assertEquals("3\u00BD yr", pt.formatAge('2022-06-15', '2025-12-15'))
        assertEquals('7 yr', pt.formatAge('2018-06-15', '2025-06-15'))
        assertEquals('Newborn', pt.formatAge('2025-06-15', '2025-06-15'))
        assertEquals('Infant', pt.formatStage('2025-01-15', '2025-06-15'))
    }

    // ================================================================
    // Compactness: compact
    // ================================================================
    // 27.1, 27.2, 27.3, 27.4, 27.5, 27.6, 27.7, 27.8
    @Test
    void 'compact compact'() {
        def pt = new SayableAge(Locales.EN, Compactness.COMPACT)

        assertEquals('3d', pt.formatAge('2025-06-12', '2025-06-15'))
        assertEquals('1w', pt.formatAge('2025-06-08', '2025-06-15'))
        assertEquals('1w1d', pt.formatAge('2025-06-07', '2025-06-15'))
        assertEquals('6m', pt.formatAge('2025-01-15', '2025-07-15'))
        assertEquals('2y1m', pt.formatAge('2023-06-15', '2025-07-15'))
        assertEquals("3\u00BDy", pt.formatAge('2022-06-15', '2025-12-15'))
        assertEquals('7y', pt.formatAge('2018-06-15', '2025-06-15'))
        assertEquals('Newborn', pt.formatAge('2025-06-15', '2025-06-15'))
    }

    // ================================================================
    // All 168 locales exist and have correct codes
    // ================================================================
    @Test
    void 'all 168 locales exist'() {
        assertEquals(168, Locales.ALL.size())
        def expectedCodes = [
            'af', 'ak', 'am', 'ar', 'ay', 'az', 'bci', 'be', 'bem', 'bg',
            'bi', 'bm', 'bn', 'br', 'bs', 'ca', 'cak', 'ceb', 'cs', 'cy',
            'da', 'de', 'din', 'dje', 'dv', 'dyu', 'dz', 'ee', 'el', 'en',
            'es', 'et', 'eu', 'fa', 'fan', 'ff', 'fi', 'fil', 'fj', 'fon',
            'fr', 'ga', 'gd', 'gl', 'gn', 'gu', 'gv', 'ha', 'he', 'hi',
            'hmn', 'hr', 'ht', 'hu', 'hy', 'id', 'ig', 'is', 'it', 'ja',
            'jv', 'ka', 'kbp', 'kek', 'ki', 'kk', 'kl', 'km', 'kn', 'ko',
            'kpe', 'kri', 'ktu', 'ku', 'kw', 'ky', 'lb', 'lg', 'ln', 'lo',
            'lt', 'luo', 'lv', 'mam', 'men', 'mfe', 'mg', 'mi', 'mk', 'ml',
            'mn', 'mnk', 'mos', 'mr', 'ms', 'mt', 'my', 'nb', 'nd', 'ne',
            'ng', 'nl', 'nr', 'nso', 'nus', 'ny', 'om', 'or', 'pa', 'pis',
            'pl', 'pov', 'ps', 'pt', 'qu', 'quc', 'ro', 'ru', 'rw', 'sar',
            'sd', 'sg', 'shi', 'shn', 'si', 'sk', 'sl', 'sn', 'snk', 'so',
            'sq', 'sr', 'ss', 'st', 'su', 'suk', 'sv', 'sw', 'ta', 'te',
            'tem', 'tet', 'tg', 'th', 'ti', 'tig', 'tk', 'tn', 'tpi', 'tr',
            'ts', 'tum', 'tzm', 'uk', 'umb', 'ur', 'uz', 've', 'vi', 'vmw',
            'wo', 'xh', 'yao', 'yo', 'yue', 'zdj', 'zh', 'zu'
        ]
        for (String code : expectedCodes) {
            def locale = Locales.ALL[code]
            assertNotNull(locale, "Locale $code should exist")
            assertEquals(code, locale.code, "Locale code should match key")
        }
    }

    // ================================================================
    // Smoke test each locale produces non-null output
    // ================================================================
    @Test
    void 'all locales produce output for basic cases'() {
        for (Map.Entry<String, AgeLocale> entry : Locales.ALL.entrySet()) {
            String code = entry.key
            AgeLocale locale = entry.value
            def pt = new SayableAge(locale)

            // Just born
            String justBorn = pt.formatAge('2025-06-15', '2025-06-15')
            assertNotNull(justBorn, "$code: justBorn should not be null")
            assertTrue(!justBorn.isEmpty(), "$code: justBorn should not be empty")

            // Days
            String days = pt.formatAge('2025-06-12', '2025-06-15')
            assertNotNull(days, "$code: days should not be null")

            // Weeks
            String weeks = pt.formatAge('2025-06-07', '2025-06-15')
            assertNotNull(weeks, "$code: weeks should not be null")

            // Months
            String months = pt.formatAge('2025-01-15', '2025-07-15')
            assertNotNull(months, "$code: months should not be null")

            // Years+months
            String yearsMonths = pt.formatAge('2023-06-15', '2025-07-15')
            assertNotNull(yearsMonths, "$code: years+months should not be null")

            // Half-year
            String halfYear = pt.formatAge('2022-06-15', '2025-12-15')
            assertNotNull(halfYear, "$code: half-year should not be null")

            // Integer years
            String intYears = pt.formatAge('2018-06-15', '2025-06-15')
            assertNotNull(intYears, "$code: integer years should not be null")

            // Stage
            String stage = pt.formatStage('2020-01-01', '2025-06-15')
            assertNotNull(stage, "$code: stage should not be null")
        }
    }

    // ================================================================
    // formatStage -- gender support
    // ================================================================
    @Test
    void 'gender null defaults to masculine for gendered locales'() {
        def pt = new SayableAge(Locales.ES)
        assertEquals("Reci\u00E9n nacido", pt.formatStage('2025-06-15', '2025-06-15'))
        assertEquals("Ni\u00F1o peque\u00F1o", pt.formatStage('2024-06-15', '2025-06-15'))
        assertEquals("Ni\u00F1o", pt.formatStage('2022-06-15', '2025-06-15'))
        assertEquals('Adulto', pt.formatStage('2007-06-15', '2025-06-15'))
    }

    @Test
    void 'gender m returns masculine'() {
        def pt = new SayableAge(Locales.ES)
        assertEquals("Reci\u00E9n nacido", pt.formatStage('2025-06-15', '2025-06-15', 'm'))
        assertEquals("Ni\u00F1o peque\u00F1o", pt.formatStage('2024-06-15', '2025-06-15', 'm'))
        assertEquals("Ni\u00F1o", pt.formatStage('2022-06-15', '2025-06-15', 'm'))
        assertEquals('Adulto', pt.formatStage('2007-06-15', '2025-06-15', 'm'))
    }

    @Test
    void 'gender f returns feminine'() {
        def pt = new SayableAge(Locales.ES)
        assertEquals("Reci\u00E9n nacida", pt.formatStage('2025-06-15', '2025-06-15', 'f'))
        assertEquals("Ni\u00F1a peque\u00F1a", pt.formatStage('2024-06-15', '2025-06-15', 'f'))
        assertEquals("Ni\u00F1a", pt.formatStage('2022-06-15', '2025-06-15', 'f'))
        assertEquals('Adulta', pt.formatStage('2007-06-15', '2025-06-15', 'f'))
    }

    @Test
    void 'gender neutral stages unaffected by gender'() {
        def pt = new SayableAge(Locales.ES)
        assertEquals("Beb\u00E9", pt.formatStage('2025-01-15', '2025-06-15', 'f'))
        assertEquals("Beb\u00E9", pt.formatStage('2025-01-15', '2025-06-15', 'm'))
        assertEquals('Adolescente', pt.formatStage('2012-06-15', '2025-06-15', 'f'))
        assertEquals('Adolescente', pt.formatStage('2012-06-15', '2025-06-15', 'm'))
    }

    @Test
    void 'gender has no effect on neutral locales'() {
        def pt = new SayableAge(Locales.EN)
        assertEquals('Newborn', pt.formatStage('2025-06-15', '2025-06-15', 'f'))
        assertEquals('Newborn', pt.formatStage('2025-06-15', '2025-06-15', 'm'))
        assertEquals('Adult', pt.formatStage('2007-06-15', '2025-06-15', 'f'))
        assertEquals('Adult', pt.formatStage('2007-06-15', '2025-06-15', 'm'))
    }

    @Test
    void 'gender French stages'() {
        def pt = new SayableAge(Locales.FR)
        assertEquals("Nouveau-n\u00E9", pt.formatStage('2025-06-15', '2025-06-15', 'm'))
        assertEquals("Nouveau-n\u00E9e", pt.formatStage('2025-06-15', '2025-06-15', 'f'))
        assertEquals('Nourrisson', pt.formatStage('2025-01-15', '2025-06-15', 'f'))
        assertEquals('Tout-petit', pt.formatStage('2024-06-15', '2025-06-15', 'f'))
        assertEquals('Enfant', pt.formatStage('2022-06-15', '2025-06-15', 'f'))
        assertEquals('Adolescent', pt.formatStage('2012-06-15', '2025-06-15', 'm'))
        assertEquals('Adolescente', pt.formatStage('2012-06-15', '2025-06-15', 'f'))
        assertEquals('Adulte', pt.formatStage('2007-06-15', '2025-06-15', 'f'))
    }

    @Test
    void 'gender Italian stages'() {
        def pt = new SayableAge(Locales.IT)
        assertEquals('Neonato', pt.formatStage('2025-06-15', '2025-06-15', 'm'))
        assertEquals('Neonata', pt.formatStage('2025-06-15', '2025-06-15', 'f'))
        assertEquals('Bimbo', pt.formatStage('2024-06-15', '2025-06-15', 'm'))
        assertEquals('Bimba', pt.formatStage('2024-06-15', '2025-06-15', 'f'))
        assertEquals('Bambino', pt.formatStage('2022-06-15', '2025-06-15', 'm'))
        assertEquals('Bambina', pt.formatStage('2022-06-15', '2025-06-15', 'f'))
        assertEquals('Adulto', pt.formatStage('2007-06-15', '2025-06-15', 'm'))
        assertEquals('Adulta', pt.formatStage('2007-06-15', '2025-06-15', 'f'))
    }

    @Test
    void 'gender Arabic all stages'() {
        def pt = new SayableAge(Locales.AR)
        assertEquals("\u062D\u062F\u064A\u062B \u0627\u0644\u0648\u0644\u0627\u062F\u0629", pt.formatStage('2025-06-15', '2025-06-15', 'm'))
        assertEquals("\u062D\u062F\u064A\u062B\u0629 \u0627\u0644\u0648\u0644\u0627\u062F\u0629", pt.formatStage('2025-06-15', '2025-06-15', 'f'))
        assertEquals("\u0631\u0636\u064A\u0639", pt.formatStage('2025-01-15', '2025-06-15', 'm'))
        assertEquals("\u0631\u0636\u064A\u0639\u0629", pt.formatStage('2025-01-15', '2025-06-15', 'f'))
        assertEquals("\u0637\u0641\u0644 \u0635\u063A\u064A\u0631", pt.formatStage('2024-06-15', '2025-06-15', 'm'))
        assertEquals("\u0637\u0641\u0644\u0629 \u0635\u063A\u064A\u0631\u0629", pt.formatStage('2024-06-15', '2025-06-15', 'f'))
        assertEquals("\u0637\u0641\u0644", pt.formatStage('2022-06-15', '2025-06-15', 'm'))
        assertEquals("\u0637\u0641\u0644\u0629", pt.formatStage('2022-06-15', '2025-06-15', 'f'))
        assertEquals("\u0645\u0631\u0627\u0647\u0642", pt.formatStage('2012-06-15', '2025-06-15', 'm'))
        assertEquals("\u0645\u0631\u0627\u0647\u0642\u0629", pt.formatStage('2012-06-15', '2025-06-15', 'f'))
        assertEquals("\u0628\u0627\u0644\u063A", pt.formatStage('2007-06-15', '2025-06-15', 'm'))
        assertEquals("\u0628\u0627\u0644\u063A\u0629", pt.formatStage('2007-06-15', '2025-06-15', 'f'))
    }

    @Test
    void 'gender German adult only'() {
        def pt = new SayableAge(Locales.DE)
        assertEquals('Erwachsener', pt.formatStage('2007-06-15', '2025-06-15', 'm'))
        assertEquals('Erwachsene', pt.formatStage('2007-06-15', '2025-06-15', 'f'))
        assertEquals('Neugeborenes', pt.formatStage('2025-06-15', '2025-06-15', 'f'))
    }

    @Test
    void 'gender companion method'() {
        assertEquals('Newborn', SayableAge.formatStageDefault('2025-06-15', '2025-06-15', 'f'))
        assertEquals('Adult', SayableAge.formatStageDefault('2007-06-15', '2025-06-15', 'f'))
    }

    // ================================================================
    // Section 29: Locale-specific edge cases -- new plural rules
    // ================================================================

    // 29.1, 29.2, 29.3, 29.4, 29.5, 29.6, 29.7, 29.8, 29.9, 29.10, 29.11, 29.12, 29.13, 29.14
    @Test
    void 'Hebrew locale -- dual forms'() {
        def pt = new SayableAge(Locales.HE)
        assertEquals('\u05E8\u05E7 \u05E0\u05D5\u05DC\u05D3', pt.formatAge('2025-06-15', '2025-06-15'))
        assertEquals('\u05D9\u05D5\u05DD', pt.formatAge('2025-06-14', '2025-06-15'))
        assertEquals('3 \u05D9\u05DE\u05D9\u05DD', pt.formatAge('2025-06-12', '2025-06-15'))
        assertEquals('\u05E9\u05D1\u05D5\u05E2\u05D9\u05D9\u05DD', pt.formatAge('2025-06-01', '2025-06-15'))
        assertEquals('3 \u05E9\u05D1\u05D5\u05E2\u05D5\u05EA', pt.formatAge('2025-05-25', '2025-06-15'))
        assertEquals('6 \u05D7\u05D5\u05D3\u05E9\u05D9\u05DD', pt.formatAge('2025-01-15', '2025-07-15'))
        assertEquals('3 \u05D7\u05D5\u05D3\u05E9\u05D9\u05DD', pt.formatAge('2025-03-15', '2025-06-15'))
        assertEquals('\u05E9\u05E0\u05EA\u05D9\u05D9\u05DD, \u05D7\u05D5\u05D3\u05E9', pt.formatAge('2023-06-15', '2025-07-15'))
        assertEquals('3 \u05E9\u05E0\u05D9\u05DD \u05D5\u05D7\u05E6\u05D9', pt.formatAge('2022-06-15', '2025-12-15'))
        assertEquals('7 \u05E9\u05E0\u05D9\u05DD', pt.formatAge('2018-06-15', '2025-06-15'))
        assertEquals('\u05E8\u05E7 \u05E0\u05D5\u05DC\u05D3', pt.formatStage('2025-06-15', '2025-06-15', 'm'))
        assertEquals('\u05E8\u05E7 \u05E0\u05D5\u05DC\u05D3\u05D4', pt.formatStage('2025-06-15', '2025-06-15', 'f'))
        assertEquals('\u05DE\u05D1\u05D5\u05D2\u05E8', pt.formatStage('2007-06-15', '2025-06-15', 'm'))
        assertEquals('\u05DE\u05D1\u05D5\u05D2\u05E8\u05EA', pt.formatStage('2007-06-15', '2025-06-15', 'f'))
    }

    // 29.15, 29.16, 29.17, 29.18, 29.19, 29.20, 29.21
    @Test
    void 'Macedonian locale -- mod10 mod100 rule'() {
        def pt = new SayableAge(Locales.MK)
        assertEquals('\u041D\u043E\u0432\u043E\u0440\u043E\u0434\u0435\u043D\u0447\u0435', pt.formatAge('2025-06-15', '2025-06-15'))
        assertEquals('1 \u0434\u0435\u043D', pt.formatAge('2025-06-14', '2025-06-15'))
        assertEquals('3 \u0434\u0435\u043D\u0430', pt.formatAge('2025-06-12', '2025-06-15'))
        assertEquals('6 \u043C\u0435\u0441\u0435\u0446\u0438', pt.formatAge('2025-01-15', '2025-07-15'))
        assertEquals('2 \u0433\u043E\u0434\u0438\u043D\u0438, 1 \u043C\u0435\u0441\u0435\u0446', pt.formatAge('2023-06-15', '2025-07-15'))
        assertEquals('3 \u0433\u043E\u0434\u0438\u043D\u0438 \u0438 \u043F\u043E\u043B', pt.formatAge('2022-06-15', '2025-12-15'))
        assertEquals('7 \u0433\u043E\u0434\u0438\u043D\u0438', pt.formatAge('2018-06-15', '2025-06-15'))
    }

    // 29.22, 29.23, 29.24, 29.25, 29.26, 29.27
    @Test
    void 'Swahili locale -- noun class changes'() {
        def pt = new SayableAge(Locales.SW)
        assertEquals('Mzaliwa mpya', pt.formatAge('2025-06-15', '2025-06-15'))
        assertEquals('siku 1', pt.formatAge('2025-06-14', '2025-06-15'))
        assertEquals('siku 3', pt.formatAge('2025-06-12', '2025-06-15'))
        assertEquals('miezi 6', pt.formatAge('2025-01-15', '2025-07-15'))
        assertEquals('miaka 2, mwezi 1', pt.formatAge('2023-06-15', '2025-07-15'))
        assertEquals('miaka 3 na nusu', pt.formatAge('2022-06-15', '2025-12-15'))
    }

    // 29.28, 29.29, 29.30, 29.31, 29.32, 29.33
    @Test
    void 'Indonesian locale -- other only'() {
        def pt = new SayableAge(Locales.ID)
        assertEquals('Baru lahir', pt.formatAge('2025-06-15', '2025-06-15'))
        assertEquals('1 hari', pt.formatAge('2025-06-14', '2025-06-15'))
        assertEquals('3 hari', pt.formatAge('2025-06-12', '2025-06-15'))
        assertEquals('6 bulan', pt.formatAge('2025-01-15', '2025-07-15'))
        assertEquals('3 setengah tahun', pt.formatAge('2022-06-15', '2025-12-15'))
        assertEquals('7 tahun', pt.formatAge('2018-06-15', '2025-06-15'))
    }

    // 29.34, 29.35, 29.36, 29.37, 29.38, 29.39
    @Test
    void 'Amharic locale -- Ethiopic delimiter'() {
        def pt = new SayableAge(Locales.AM)
        assertEquals('\u12A0\u12F2\u1235 \u12E8\u1270\u12C8\u1208\u12F0', pt.formatAge('2025-06-15', '2025-06-15'))
        assertEquals('1 \u1240\u1295', pt.formatAge('2025-06-14', '2025-06-15'))
        assertEquals('3 \u1240\u1293\u1275', pt.formatAge('2025-06-12', '2025-06-15'))
        assertEquals('1 \u1233\u121D\u1295\u1275\u1363 1 \u1240\u1295', pt.formatAge('2025-06-07', '2025-06-15'))
        assertEquals('6 \u12C8\u122B\u1275', pt.formatAge('2025-01-15', '2025-07-15'))
        assertEquals('3 \u12D3\u1218\u1273\u1275 \u1270\u12A9\u120D', pt.formatAge('2022-06-15', '2025-12-15'))
    }

    // ================================================================
    // Section 30: Locale lookup by code string
    // ================================================================

    // 30.1
    @Test
    void 'getLocale returns en locale'() {
        def loc = Locales.get('en')
        assertNotNull(loc)
        assertEquals('en', loc.code)
    }

    // 30.2
    @Test
    void 'getLocale returns fr locale'() {
        def loc = Locales.get('fr')
        assertNotNull(loc)
        assertEquals('fr', loc.code)
    }

    // 30.3
    @Test
    void 'getLocale returns null for unknown code'() {
        assertNull(Locales.get('xx'))
    }

    // 30.4
    @Test
    void 'getLocale returns null for empty string'() {
        assertNull(Locales.get(''))
    }

    // 30.5
    @Test
    void 'getLocale is case-sensitive'() {
        assertNull(Locales.get('EN'))
    }

    // ================================================================
    // Weeks and days across month ends
    // ================================================================

    // 31.1
    @Test
    void '88 days across a 28 day february'() {
        SayableAge f = new SayableAge(Locales.EN)
        assertEquals('12 weeks, 4 days', f.formatAge('2016-12-31', '2017-03-29'))
    }

    // 31.2
    @Test
    void '90 days across a year end into'() {
        SayableAge f = new SayableAge(Locales.EN)
        assertEquals('12 weeks, 6 days', f.formatAge('1991-11-27', '1992-02-25'))
    }

    // 31.3
    @Test
    void '33 days across a year end'() {
        SayableAge f = new SayableAge(Locales.EN)
        assertEquals('4 weeks, 5 days', f.formatAge('2020-11-30', '2021-01-02'))
    }

    // 31.4
    @Test
    void 'compact form of 31 1'() {
        SayableAge f = new SayableAge(Locales.EN, Compactness.COMPACT)
        assertEquals('12w4d', f.formatAge('2016-12-31', '2017-03-29'))
    }

    // ================================================================
    // Half years take their plural form from whole years
    // ================================================================

    // 32.1
    @Test
    void 'polish 3 is few'() {
        SayableAge f = new SayableAge(Locales.PL)
        assertEquals('3 i p\u00F3\u0142 lata', f.formatAge('2021-06-15', '2025-01-15'))
    }

    // 32.2
    @Test
    void 'polish 5 is many'() {
        SayableAge f = new SayableAge(Locales.PL, Compactness.SHORT)
        assertEquals('5 i p\u00F3\u0142 lat', f.formatAge('2020-06-15', '2025-12-15'))
    }

    // 32.3
    @Test
    void 'tachelhit 6 is few'() {
        SayableAge f = new SayableAge(Locales.SHI)
        assertEquals('6 \u2D49\u2D59\u2D33\u2D33\u2D6F\u2D30\u2D59\u2D4F \u2D37 \u2D53\u2D63\u2D33\u2D4F', f.formatAge('2005-06-08', '2012-06-07'))
    }

    // ================================================================
    // Input validation
    // ================================================================

    // 33.1
    @Test
    void 'february 30 doesnt exist'() {
        SayableAge f = new SayableAge(Locales.EN)
        assertNull(f.formatAge('2025-02-30', '2032-06-25'))
    }

    // 33.2
    @Test
    void 'month 13'() {
        SayableAge f = new SayableAge(Locales.EN)
        assertNull(f.formatAge('2025-13-01', '2027-01-31'))
    }

    // 33.3
    @Test
    void 'february 29 in a non leap year'() {
        SayableAge f = new SayableAge(Locales.EN)
        assertNull(f.formatAge('2023-02-29', '2025-03-01'))
    }

    // 33.4
    @Test
    void 'day 00'() {
        SayableAge f = new SayableAge(Locales.EN)
        assertNull(f.formatAge('2025-06-00', '2027-02-25'))
    }

    // 33.5
    @Test
    void 'unpadded month and day'() {
        SayableAge f = new SayableAge(Locales.EN)
        assertNull(f.formatAge('2025-6-1', '2027-02-25'))
    }

    // 33.6
    @Test
    void 'surrounding whitespace'() {
        SayableAge f = new SayableAge(Locales.EN)
        assertNull(f.formatAge(' 2025-06-01', '2027-02-25'))
    }

    // 33.7
    @Test
    void 'a datetime is not a date'() {
        SayableAge f = new SayableAge(Locales.EN)
        assertNull(f.formatAge('2025-06-15T10:00:00', '2027-02-25'))
    }

    // 33.8
    @Test
    void 'invalid asof'() {
        SayableAge f = new SayableAge(Locales.EN)
        assertNull(f.formatAge('2020-01-01', '2025-04-31'))
    }

    // 33.9
    @Test
    void 'formatstage validates too'() {
        SayableAge f = new SayableAge(Locales.EN)
        assertNull(f.formatStage('2025-02-30', '2027-09-05'))
    }

    // 33.10
    @Test
    void 'february 29 in a leap year is'() {
        SayableAge f = new SayableAge(Locales.EN)
        assertEquals('2 years', f.formatAge('2024-02-29', '2026-03-01'))
    }
}
