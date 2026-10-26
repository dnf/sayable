package sayableage

import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNotNull
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import java.time.LocalDate
import sayableage.locales.Locales

class FormatAgeTest {

    @AfterEach
    fun resetTimeNow() {
        timeNow = { LocalDate.now() }
    }

    // ================================================================
    // formatAge -- null/edge cases
    // ================================================================
    // 1.3
    @Test
    fun `empty string returns null`() {
        assertNull(SayableAge.formatAge("", "2025-06-15"))
    }

    // 1.4
    @Test
    fun `future dob returns null`() {
        assertNull(SayableAge.formatAge("2025-07-01", "2025-06-15"))
    }

    // 1.5
    @Test
    fun `exactly 500 years is allowed`() {
        assertEquals("500 years", SayableAge.formatAge("1525-06-15", "2025-06-15"))
    }

    // 1.6
    @Test
    fun `501 years exceeds max age`() {
        assertNull(SayableAge.formatAge("1524-06-15", "2025-06-15"))
    }

    // 1.7
    @Test
    fun `1000 years exceeds max age`() {
        assertNull(SayableAge.formatAge("1025-06-15", "2025-06-15"))
    }

    // ================================================================
    // formatAge -- days tier (0-6)
    // ================================================================
    // 2.1
    @Test
    fun `born today`() {
        assertEquals("Newborn", SayableAge.formatAge("2025-06-15", "2025-06-15"))
    }

    // 2.2
    @Test
    fun `1 day ago (singular)`() {
        assertEquals("1 day", SayableAge.formatAge("2025-06-14", "2025-06-15"))
    }

    // 2.3
    @Test
    fun `3 days ago`() {
        assertEquals("3 days", SayableAge.formatAge("2025-06-12", "2025-06-15"))
    }

    // 2.4
    @Test
    fun `6 days ago`() {
        assertEquals("6 days", SayableAge.formatAge("2025-06-09", "2025-06-15"))
    }

    // 2.5
    @Test
    fun `7 days becomes 1 week`() {
        assertEquals("1 week", SayableAge.formatAge("2025-06-08", "2025-06-15"))
    }

    // ================================================================
    // formatAge -- weeks+days tier (7 days to less than 3 months)
    // ================================================================
    // 3.1
    @Test
    fun `7 days is 1 week`() {
        assertEquals("1 week", SayableAge.formatAge("2025-06-08", "2025-06-15"))
    }

    // 3.2
    @Test
    fun `8 days is 1 week 1 day`() {
        assertEquals("1 week, 1 day", SayableAge.formatAge("2025-06-07", "2025-06-15"))
    }

    // 3.3
    @Test
    fun `9 days is 1 week 2 days`() {
        assertEquals("1 week, 2 days", SayableAge.formatAge("2025-06-06", "2025-06-15"))
    }

    // 3.4
    @Test
    fun `13 days is 1 week 6 days`() {
        assertEquals("1 week, 6 days", SayableAge.formatAge("2025-06-02", "2025-06-15"))
    }

    // 3.5
    @Test
    fun `14 days is 2 weeks`() {
        assertEquals("2 weeks", SayableAge.formatAge("2025-06-01", "2025-06-15"))
    }

    // 3.6
    @Test
    fun `15 days is 2 weeks 1 day`() {
        assertEquals("2 weeks, 1 day", SayableAge.formatAge("2025-05-31", "2025-06-15"))
    }

    // 3.7
    @Test
    fun `20 days is 2 weeks 6 days`() {
        assertEquals("2 weeks, 6 days", SayableAge.formatAge("2025-05-26", "2025-06-15"))
    }

    // 3.8
    @Test
    fun `21 days is 3 weeks`() {
        assertEquals("3 weeks", SayableAge.formatAge("2025-05-25", "2025-06-15"))
    }

    // 3.9
    @Test
    fun `at 1 cal month still weeks+days`() {
        assertEquals("4 weeks, 3 days", SayableAge.formatAge("2025-05-15", "2025-06-15"))
    }

    // 3.10
    @Test
    fun `at 2 cal months still weeks+days`() {
        assertEquals("8 weeks, 5 days", SayableAge.formatAge("2025-04-15", "2025-06-15"))
    }

    // 3.11
    @Test
    fun `one day before 3mo still weeks`() {
        assertEquals("13 weeks", SayableAge.formatAge("2025-03-15", "2025-06-14"))
    }

    // 3.12
    @Test
    fun `on 3mo birthday switches`() {
        assertEquals("3 months", SayableAge.formatAge("2025-03-15", "2025-06-15"))
    }

    // ================================================================
    // formatAge -- month boundaries: standard months
    // ================================================================
    // 4.1
    @Test
    fun `Jan1 to Apr1 is 3mo`() {
        assertEquals("3 months", SayableAge.formatAge("2025-01-01", "2025-04-01"))
    }

    // 4.2
    @Test
    fun `Jan1 to Mar31 still weeks`() {
        val result = SayableAge.formatAge("2025-01-01", "2025-03-31")
        assertNotNull(result)
        assertTrue(result!!.contains("weeks"))
    }

    // 4.3
    @Test
    fun `Jun15 to Sep15 is 3mo`() {
        assertEquals("3 months", SayableAge.formatAge("2025-06-15", "2025-09-15"))
    }

    // 4.4
    @Test
    fun `Jun15 to Sep14 still weeks`() {
        val result = SayableAge.formatAge("2025-06-15", "2025-09-14")
        assertNotNull(result)
        assertTrue(result!!.contains("weeks"))
    }

    // 4.5
    @Test
    fun `Jun15 to Dec15 is 6mo`() {
        assertEquals("6 months", SayableAge.formatAge("2025-06-15", "2025-12-15"))
    }

    // ================================================================
    // formatAge -- month boundaries: February non-leap
    // ================================================================
    // 5.1
    @Test
    fun `Jan31 to Feb28 non-leap`() {
        assertEquals("4 weeks", SayableAge.formatAge("2025-01-31", "2025-02-28"))
    }

    // 5.2
    @Test
    fun `Jan31 to Apr30 is 3mo (clamp)`() {
        assertEquals("3 months", SayableAge.formatAge("2025-01-31", "2025-04-30"))
    }

    // 5.3
    @Test
    fun `Jan31 to Apr29 still weeks`() {
        val result = SayableAge.formatAge("2025-01-31", "2025-04-29")
        assertNotNull(result)
        assertTrue(result!!.contains("weeks"))
    }

    // 5.4
    @Test
    fun `Feb1 to May1 is 3mo`() {
        assertEquals("3 months", SayableAge.formatAge("2025-02-01", "2025-05-01"))
    }

    // 5.5
    @Test
    fun `Feb1 to Apr30 still weeks`() {
        val result = SayableAge.formatAge("2025-02-01", "2025-04-30")
        assertNotNull(result)
        assertTrue(result!!.contains("weeks"))
    }

    // ================================================================
    // formatAge -- month boundaries: February leap year
    // ================================================================
    // 6.1
    @Test
    fun `Jan31 to Feb29 leap`() {
        assertEquals("4 weeks, 1 day", SayableAge.formatAge("2024-01-31", "2024-02-29"))
    }

    // 6.2
    @Test
    fun `Jan31 to Feb28 leap`() {
        assertEquals("4 weeks", SayableAge.formatAge("2024-01-31", "2024-02-28"))
    }

    // 6.3
    @Test
    fun `Jan31 to Apr30 leap is 3mo`() {
        assertEquals("3 months", SayableAge.formatAge("2024-01-31", "2024-04-30"))
    }

    // 6.4
    @Test
    fun `Jan30 to Feb29 leap still weeks`() {
        val result = SayableAge.formatAge("2024-01-30", "2024-02-29")
        assertNotNull(result)
        assertTrue(result!!.contains("weeks"))
    }

    // 6.5
    @Test
    fun `Jan30 to Feb28 leap still weeks`() {
        val result = SayableAge.formatAge("2024-01-30", "2024-02-28")
        assertNotNull(result)
        assertTrue(result!!.contains("weeks"))
    }

    // ================================================================
    // formatAge -- month boundaries: 30-day months
    // ================================================================
    // 7.1
    @Test
    fun `Mar31 to Jun30 is 3mo (clamped)`() {
        assertEquals("3 months", SayableAge.formatAge("2025-03-31", "2025-06-30"))
    }

    // 7.2
    @Test
    fun `Mar31 to Jun29 still weeks`() {
        val result = SayableAge.formatAge("2025-03-31", "2025-06-29")
        assertNotNull(result)
        assertTrue(result!!.contains("weeks"))
    }

    // 7.3
    @Test
    fun `Aug31 to Nov30 is 3mo`() {
        assertEquals("3 months", SayableAge.formatAge("2025-08-31", "2025-11-30"))
    }

    // 7.4
    @Test
    fun `Aug31 to Nov29 still weeks`() {
        val result = SayableAge.formatAge("2025-08-31", "2025-11-29")
        assertNotNull(result)
        assertTrue(result!!.contains("weeks"))
    }

    // ================================================================
    // formatAge -- month boundaries: leap year baby (born Feb 29)
    // ================================================================
    // 8.1
    @Test
    fun `Feb29 to May29 is 3mo`() {
        assertEquals("3 months", SayableAge.formatAge("2024-02-29", "2024-05-29"))
    }

    // 8.2
    @Test
    fun `Feb29 to May28 still weeks`() {
        val result = SayableAge.formatAge("2024-02-29", "2024-05-28")
        assertNotNull(result)
        assertTrue(result!!.contains("weeks"))
    }

    // 8.3
    @Test
    fun `Feb29 2024 to Feb28 2025 is 12mo`() {
        assertEquals("12 months", SayableAge.formatAge("2024-02-29", "2025-02-28"))
    }

    // 8.4
    @Test
    fun `Feb29 2024 to Mar1 2025 is 12mo`() {
        assertEquals("12 months", SayableAge.formatAge("2024-02-29", "2025-03-01"))
    }

    // ================================================================
    // formatAge -- months tier (3-23)
    // ================================================================
    // 9.1
    @Test
    fun `3 months at transition`() {
        assertEquals("3 months", SayableAge.formatAge("2025-01-15", "2025-04-15"))
    }

    // 9.2
    @Test
    fun `6 months`() {
        assertEquals("6 months", SayableAge.formatAge("2025-01-15", "2025-07-15"))
    }

    // 9.3
    @Test
    fun `12 months (not 1 year)`() {
        assertEquals("12 months", SayableAge.formatAge("2024-06-15", "2025-06-15"))
    }

    // 9.4
    @Test
    fun `23 months at upper`() {
        assertEquals("23 months", SayableAge.formatAge("2024-01-15", "2025-12-15"))
    }

    // 9.5
    @Test
    fun `one day before boundary`() {
        assertEquals("5 months", SayableAge.formatAge("2025-01-15", "2025-07-14"))
    }

    // 9.6
    @Test
    fun `crossing year boundary`() {
        assertEquals("5 months", SayableAge.formatAge("2024-11-10", "2025-04-10"))
    }

    // ================================================================
    // formatAge -- years+months tier (24-35 months)
    // ================================================================
    // 10.1
    @Test
    fun `2 years at 24mo`() {
        assertEquals("2 years", SayableAge.formatAge("2023-06-15", "2025-06-15"))
    }

    // 10.2
    @Test
    fun `2 years 1 month`() {
        assertEquals("2 years, 1 month", SayableAge.formatAge("2023-06-15", "2025-07-15"))
    }

    // 10.3
    @Test
    fun `2 years 6 months`() {
        assertEquals("2 years, 6 months", SayableAge.formatAge("2023-06-15", "2025-12-15"))
    }

    // 10.4
    @Test
    fun `2 years 11 months`() {
        assertEquals("2 years, 11 months", SayableAge.formatAge("2023-06-15", "2026-05-15"))
    }

    // 10.5
    @Test
    fun `one day before 24mo`() {
        assertEquals("23 months", SayableAge.formatAge("2023-06-15", "2025-06-14"))
    }

    // ================================================================
    // formatAge -- half-year tier (3-6 years)
    // ================================================================
    // 11.1
    @Test
    fun `3 years exactly`() {
        assertEquals("3 years", SayableAge.formatAge("2022-06-15", "2025-06-15"))
    }

    // 11.2
    @Test
    fun `3 years 5 months`() {
        assertEquals("3 years", SayableAge.formatAge("2022-06-15", "2025-11-15"))
    }

    // 11.3
    @Test
    fun `3 and half years at 3y6m`() {
        assertEquals("3\u00BD years", SayableAge.formatAge("2022-06-15", "2025-12-15"))
    }

    // 11.4
    @Test
    fun `3 and half years at 3y11m`() {
        assertEquals("3\u00BD years", SayableAge.formatAge("2022-06-15", "2026-05-15"))
    }

    // 11.5
    @Test
    fun `4 years exactly`() {
        assertEquals("4 years", SayableAge.formatAge("2021-06-15", "2025-06-15"))
    }

    // 11.6
    @Test
    fun `4 and half years`() {
        assertEquals("4\u00BD years", SayableAge.formatAge("2021-06-15", "2025-12-15"))
    }

    // 11.7
    @Test
    fun `5 years`() {
        assertEquals("5 years", SayableAge.formatAge("2020-06-15", "2025-06-15"))
    }

    // 11.8
    @Test
    fun `5 and half years at 5y8m`() {
        assertEquals("5\u00BD years", SayableAge.formatAge("2020-06-15", "2026-02-15"))
    }

    // 11.9
    @Test
    fun `6 years`() {
        assertEquals("6 years", SayableAge.formatAge("2019-06-15", "2025-06-15"))
    }

    // 11.10
    @Test
    fun `6 and half years`() {
        assertEquals("6\u00BD years", SayableAge.formatAge("2019-06-15", "2025-12-15"))
    }

    // 11.11
    @Test
    fun `6 and half years at 6y11m`() {
        assertEquals("6\u00BD years", SayableAge.formatAge("2019-06-15", "2026-05-15"))
    }

    // 11.12
    @Test
    fun `one day before 3rd bday`() {
        assertEquals("2 years, 11 months", SayableAge.formatAge("2022-06-15", "2025-06-14"))
    }

    // ================================================================
    // formatAge -- integer tier (7+ years)
    // ================================================================
    // 12.1
    @Test
    fun `7 years exactly`() {
        assertEquals("7 years", SayableAge.formatAge("2018-06-15", "2025-06-15"))
    }

    // 12.2
    @Test
    fun `7 years 6 months no half`() {
        assertEquals("7 years", SayableAge.formatAge("2018-03-20", "2025-06-15"))
    }

    // 12.3
    @Test
    fun `45 years`() {
        assertEquals("45 years", SayableAge.formatAge("1980-01-01", "2025-06-15"))
    }

    // ================================================================
    // formatAge -- cross-year transitions with Feb
    // ================================================================
    // 13.1
    @Test
    fun `Dec31 to Mar31 is 3mo`() {
        assertEquals("3 months", SayableAge.formatAge("2024-12-31", "2025-03-31"))
    }

    // 13.2
    @Test
    fun `Dec31 to Mar30 still weeks`() {
        val result = SayableAge.formatAge("2024-12-31", "2025-03-30")
        assertNotNull(result)
        assertTrue(result!!.contains("weeks"))
    }

    // 13.3
    @Test
    fun `Nov30 to Feb28 is 3mo`() {
        assertEquals("3 months", SayableAge.formatAge("2024-11-30", "2025-02-28"))
    }

    // 13.4
    @Test
    fun `Nov30 to Feb27 still weeks`() {
        val result = SayableAge.formatAge("2024-11-30", "2025-02-27")
        assertNotNull(result)
        assertTrue(result!!.contains("weeks"))
    }

    // ================================================================
    // formatAge -- born-on-31st progression
    // ================================================================
    // 14.1
    @Test
    fun `Jan31 to Apr30 is 3mo`() {
        assertEquals("3 months", SayableAge.formatAge("2025-01-31", "2025-04-30"))
    }

    // 14.2
    @Test
    fun `Jan31 to May31 is 4mo`() {
        assertEquals("4 months", SayableAge.formatAge("2025-01-31", "2025-05-31"))
    }

    // 14.3
    @Test
    fun `Jan31 to Jun30 is 5mo (clamped)`() {
        assertEquals("5 months", SayableAge.formatAge("2025-01-31", "2025-06-30"))
    }

    // 14.4
    @Test
    fun `Jan31 to Jul1 is 5mo`() {
        assertEquals("5 months", SayableAge.formatAge("2025-01-31", "2025-07-01"))
    }

    // 14.5
    @Test
    fun `Jan31 to Jul31 is 6mo`() {
        assertEquals("6 months", SayableAge.formatAge("2025-01-31", "2025-07-31"))
    }

    // ================================================================
    // formatAge -- default asOf (uses current date)
    // ================================================================
    // 15.1, 15.2
    @Test
    fun `default asOf uses mocked today`() {
        timeNow = { LocalDate.of(2025, 6, 15) }
        assertEquals("5 years", SayableAge.formatAge("2020-01-01"))
        assertEquals("5 days", SayableAge.formatAge("2025-06-10"))
    }

    // ================================================================
    // formatStage -- null/edge cases
    // ================================================================
    // 16.3
    @Test
    fun `stage empty string returns null`() {
        assertNull(SayableAge.formatStage("", "2025-06-15"))
    }

    // 16.4
    @Test
    fun `stage future dob returns null`() {
        assertNull(SayableAge.formatStage("2025-07-01", "2025-06-15"))
    }

    // 16.5
    @Test
    fun `stage exactly 500 years returns Adult`() {
        assertEquals("Adult", SayableAge.formatStage("1525-06-15", "2025-06-15"))
    }

    // 16.6
    @Test
    fun `stage 501 years exceeds max age`() {
        assertNull(SayableAge.formatStage("1524-06-15", "2025-06-15"))
    }

    // ================================================================
    // formatStage -- newborn
    // ================================================================
    // 17.1
    @Test
    fun `stage born today`() {
        assertEquals("Newborn", SayableAge.formatStage("2025-06-15", "2025-06-15"))
    }

    // 17.2
    @Test
    fun `stage 1 day old`() {
        assertEquals("Newborn", SayableAge.formatStage("2025-06-14", "2025-06-15"))
    }

    // 17.3
    @Test
    fun `stage 3 weeks old`() {
        assertEquals("Newborn", SayableAge.formatStage("2025-05-25", "2025-06-15"))
    }

    // 17.4
    @Test
    fun `stage 1 month old`() {
        assertEquals("Newborn", SayableAge.formatStage("2025-05-15", "2025-06-15"))
    }

    // 17.5
    @Test
    fun `stage 1 month 29 days`() {
        assertEquals("Newborn", SayableAge.formatStage("2025-04-16", "2025-06-15"))
    }

    // 17.6
    @Test
    fun `stage exactly 2 months becomes Infant`() {
        assertEquals("Infant", SayableAge.formatStage("2025-04-15", "2025-06-15"))
    }

    // ================================================================
    // formatStage -- infant
    // ================================================================
    // 18.1
    @Test
    fun `stage 2 months`() {
        assertEquals("Infant", SayableAge.formatStage("2025-04-15", "2025-06-15"))
    }

    // 18.2
    @Test
    fun `stage 6 months`() {
        assertEquals("Infant", SayableAge.formatStage("2024-12-15", "2025-06-15"))
    }

    // 18.3
    @Test
    fun `stage 11 months`() {
        assertEquals("Infant", SayableAge.formatStage("2024-07-15", "2025-06-15"))
    }

    // 18.4
    @Test
    fun `stage exactly 12mo becomes Toddler`() {
        assertEquals("Toddler", SayableAge.formatStage("2024-06-15", "2025-06-15"))
    }

    // ================================================================
    // formatStage -- toddler
    // ================================================================
    // 19.1
    @Test
    fun `stage 12 months`() {
        assertEquals("Toddler", SayableAge.formatStage("2024-06-15", "2025-06-15"))
    }

    // 19.2
    @Test
    fun `stage 18 months`() {
        assertEquals("Toddler", SayableAge.formatStage("2024-01-15", "2025-07-15"))
    }

    // 19.3
    @Test
    fun `stage 24 months`() {
        assertEquals("Toddler", SayableAge.formatStage("2023-06-15", "2025-06-15"))
    }

    // 19.4
    @Test
    fun `stage 35 months`() {
        assertEquals("Toddler", SayableAge.formatStage("2023-06-15", "2026-05-15"))
    }

    // 19.5
    @Test
    fun `stage exactly 36mo becomes Child`() {
        assertEquals("Child", SayableAge.formatStage("2022-06-15", "2025-06-15"))
    }

    // ================================================================
    // formatStage -- child
    // ================================================================
    // 20.1
    @Test
    fun `stage 3 years`() {
        assertEquals("Child", SayableAge.formatStage("2022-06-15", "2025-06-15"))
    }

    // 20.2
    @Test
    fun `stage 4 years`() {
        assertEquals("Child", SayableAge.formatStage("2021-06-15", "2025-06-15"))
    }

    // 20.3
    @Test
    fun `stage 6 years`() {
        assertEquals("Child", SayableAge.formatStage("2019-06-15", "2025-06-15"))
    }

    // 20.4
    @Test
    fun `stage 9 years`() {
        assertEquals("Child", SayableAge.formatStage("2016-06-15", "2025-06-15"))
    }

    // 20.5
    @Test
    fun `stage 12y 11mo`() {
        assertEquals("Child", SayableAge.formatStage("2013-06-15", "2026-05-15"))
    }

    // 20.6
    @Test
    fun `stage exactly 13y becomes Teenager`() {
        assertEquals("Teenager", SayableAge.formatStage("2012-06-15", "2025-06-15"))
    }

    // ================================================================
    // formatStage -- teenager
    // ================================================================
    // 21.1
    @Test
    fun `stage 13 years`() {
        assertEquals("Teenager", SayableAge.formatStage("2012-06-15", "2025-06-15"))
    }

    // 21.2
    @Test
    fun `stage 15 years`() {
        assertEquals("Teenager", SayableAge.formatStage("2010-06-15", "2025-06-15"))
    }

    // 21.3
    @Test
    fun `stage 17y 11mo`() {
        assertEquals("Teenager", SayableAge.formatStage("2008-06-15", "2026-05-15"))
    }

    // 21.4
    @Test
    fun `stage exactly 18y becomes Adult`() {
        assertEquals("Adult", SayableAge.formatStage("2007-06-15", "2025-06-15"))
    }

    // ================================================================
    // formatStage -- adult
    // ================================================================
    // 22.1
    @Test
    fun `stage 18 years`() {
        assertEquals("Adult", SayableAge.formatStage("2007-06-15", "2025-06-15"))
    }

    // 22.2
    @Test
    fun `stage 25 years`() {
        assertEquals("Adult", SayableAge.formatStage("2000-06-15", "2025-06-15"))
    }

    // 22.3
    @Test
    fun `stage 45 years`() {
        assertEquals("Adult", SayableAge.formatStage("1980-01-01", "2025-06-15"))
    }

    // ================================================================
    // formatStage -- default asOf
    // ================================================================
    // 23.1, 23.2, 23.3
    @Test
    fun `stage default asOf`() {
        timeNow = { LocalDate.of(2025, 6, 15) }
        assertEquals("Newborn", SayableAge.formatStage("2025-06-15"))
        assertEquals("Child", SayableAge.formatStage("2020-01-01"))
        assertEquals("Adult", SayableAge.formatStage("1980-01-01"))
    }

    // ================================================================
    // SayableAge class with English locale
    // ================================================================
    // 24.1, 24.2, 24.3, 24.4, 24.5, 24.6, 24.7, 24.8, 24.9, 24.10, 24.11, 24.12, 24.13, 24.14, 24.15
    @Test
    fun `SayableAge English all tiers`() {
        val pt = SayableAge(Locales.EN)
        assertEquals("Newborn", pt.formatAge("2025-06-15", "2025-06-15"))
        assertEquals("3 days", pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals("1 week, 1 day", pt.formatAge("2025-06-07", "2025-06-15"))
        assertEquals("6 months", pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals("2 years, 1 month", pt.formatAge("2023-06-15", "2025-07-15"))
        assertEquals("3\u00BD years", pt.formatAge("2022-06-15", "2025-12-15"))
        assertEquals("7 years", pt.formatAge("2018-06-15", "2025-06-15"))

        assertEquals("Newborn", pt.formatStage("2025-06-15", "2025-06-15"))
        assertEquals("Infant", pt.formatStage("2025-01-15", "2025-06-15"))
        assertEquals("Toddler", pt.formatStage("2024-06-15", "2025-06-15"))
        assertEquals("Child", pt.formatStage("2022-06-15", "2025-06-15"))
        assertEquals("Teenager", pt.formatStage("2012-06-15", "2025-06-15"))
        assertEquals("Adult", pt.formatStage("2007-06-15", "2025-06-15"))

        assertNull(pt.formatAge(""))
        assertNull(pt.formatStage(""))
    }

    // ================================================================
    // SayableAge with Spanish locale
    // ================================================================
    // 25.1, 25.2, 25.3, 25.4, 25.5, 25.6, 25.7, 25.8, 25.9, 25.10, 25.11, 25.12, 25.13, 25.14, 25.15, 25.16, 25.17, 25.18, 25.19, 25.20
    @Test
    fun `SayableAge Spanish inline locale`() {
        val es = AgeLocale(
            code = "es",
            plural = { n -> if (n == 1) PluralCategory.ONE else PluralCategory.OTHER },
            units = Units(
                day = pluralUnit(mapOf(PluralCategory.ONE to "{n} d\u00EDa", PluralCategory.OTHER to "{n} d\u00EDas")),
                week = pluralUnit(mapOf(PluralCategory.ONE to "{n} semana", PluralCategory.OTHER to "{n} semanas")),
                month = pluralUnit(mapOf(PluralCategory.ONE to "{n} mes", PluralCategory.OTHER to "{n} meses")),
                year = pluralUnit(mapOf(PluralCategory.ONE to "{n} a\u00F1o", PluralCategory.OTHER to "{n} a\u00F1os"))
            ),
            half = "{n} y medio",
            delimiter = ", ",
            justBorn = "Reci\u00E9n nacido",
            stages = Stages(
                newborn = g("Reci\u00E9n nacido", "Reci\u00E9n nacida"),
                infant = s("Beb\u00E9"),
                toddler = g("Ni\u00F1o peque\u00F1o", "Ni\u00F1a peque\u00F1a"),
                child = g("Ni\u00F1o", "Ni\u00F1a"),
                teenager = s("Adolescente"),
                adult = g("Adulto", "Adulta")
            )
        )

        val pt = SayableAge(es)

        assertEquals("Reci\u00E9n nacido", pt.formatAge("2025-06-15", "2025-06-15"))
        assertEquals("1 d\u00EDa", pt.formatAge("2025-06-14", "2025-06-15"))
        assertEquals("3 d\u00EDas", pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals("1 semana", pt.formatAge("2025-06-08", "2025-06-15"))
        assertEquals("1 semana, 1 d\u00EDa", pt.formatAge("2025-06-07", "2025-06-15"))
        assertEquals("2 semanas, 6 d\u00EDas", pt.formatAge("2025-05-26", "2025-06-15"))
        assertEquals("6 meses", pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals("2 a\u00F1os, 1 mes", pt.formatAge("2023-06-15", "2025-07-15"))
        assertEquals("2 a\u00F1os, 6 meses", pt.formatAge("2023-06-15", "2025-12-15"))
        assertEquals("3 y medio a\u00F1os", pt.formatAge("2022-06-15", "2025-12-15"))
        assertEquals("3 a\u00F1os", pt.formatAge("2022-06-15", "2025-06-15"))
        assertEquals("7 a\u00F1os", pt.formatAge("2018-06-15", "2025-06-15"))

        assertEquals("Reci\u00E9n nacido", pt.formatStage("2025-06-15", "2025-06-15"))
        assertEquals("Beb\u00E9", pt.formatStage("2025-01-15", "2025-06-15"))
        assertEquals("Ni\u00F1o peque\u00F1o", pt.formatStage("2024-06-15", "2025-06-15"))
        assertEquals("Ni\u00F1o", pt.formatStage("2022-06-15", "2025-06-15"))
        assertEquals("Adolescente", pt.formatStage("2012-06-15", "2025-06-15"))
        assertEquals("Adulto", pt.formatStage("2007-06-15", "2025-06-15"))

        assertNull(pt.formatAge(""))
        assertNull(pt.formatStage(""))
    }

    // ================================================================
    // Compactness: short
    // ================================================================
    // 26.1, 26.2, 26.3, 26.4, 26.5, 26.6, 26.7, 26.8, 26.9
    @Test
    fun `compact short`() {
        val pt = SayableAge(Locales.EN, Compactness.SHORT)

        assertEquals("3 d", pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals("1 wk", pt.formatAge("2025-06-08", "2025-06-15"))
        assertEquals("1 wk, 1 d", pt.formatAge("2025-06-07", "2025-06-15"))
        assertEquals("6 mo", pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals("2 yr, 1 mo", pt.formatAge("2023-06-15", "2025-07-15"))
        assertEquals("3\u00BD yr", pt.formatAge("2022-06-15", "2025-12-15"))
        assertEquals("7 yr", pt.formatAge("2018-06-15", "2025-06-15"))
        assertEquals("Newborn", pt.formatAge("2025-06-15", "2025-06-15"))
        assertEquals("Infant", pt.formatStage("2025-01-15", "2025-06-15"))
    }

    // ================================================================
    // Compactness: compact
    // ================================================================
    // 27.1, 27.2, 27.3, 27.4, 27.5, 27.6, 27.7, 27.8
    @Test
    fun `compact compact`() {
        val pt = SayableAge(Locales.EN, Compactness.COMPACT)

        assertEquals("3d", pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals("1w", pt.formatAge("2025-06-08", "2025-06-15"))
        assertEquals("1w1d", pt.formatAge("2025-06-07", "2025-06-15"))
        assertEquals("6m", pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals("2y1m", pt.formatAge("2023-06-15", "2025-07-15"))
        assertEquals("3\u00BDy", pt.formatAge("2022-06-15", "2025-12-15"))
        assertEquals("7y", pt.formatAge("2018-06-15", "2025-06-15"))
        assertEquals("Newborn", pt.formatAge("2025-06-15", "2025-06-15"))
    }

    // ================================================================
    // All 168 locales exist and have correct codes
    // ================================================================
    @Test
    fun `all 168 locales exist`() {
        assertEquals(168, Locales.ALL.size)
        val expectedCodes = listOf(
            "af", "ak", "am", "ar", "ay", "az", "bci", "be", "bem", "bg",
            "bi", "bm", "bn", "br", "bs", "ca", "cak", "ceb", "cs", "cy",
            "da", "de", "din", "dje", "dv", "dyu", "dz", "ee", "el", "en",
            "es", "et", "eu", "fa", "fan", "ff", "fi", "fil", "fj", "fon",
            "fr", "ga", "gd", "gl", "gn", "gu", "gv", "ha", "he", "hi",
            "hmn", "hr", "ht", "hu", "hy", "id", "ig", "is", "it", "ja",
            "jv", "ka", "kbp", "kek", "ki", "kk", "kl", "km", "kn", "ko",
            "kpe", "kri", "ktu", "ku", "kw", "ky", "lb", "lg", "ln", "lo",
            "lt", "luo", "lv", "mam", "men", "mfe", "mg", "mi", "mk", "ml",
            "mn", "mnk", "mos", "mr", "ms", "mt", "my", "nb", "nd", "ne",
            "ng", "nl", "nr", "nso", "nus", "ny", "om", "or", "pa", "pis",
            "pl", "pov", "ps", "pt", "qu", "quc", "ro", "ru", "rw", "sar",
            "sd", "sg", "shi", "shn", "si", "sk", "sl", "sn", "snk", "so",
            "sq", "sr", "ss", "st", "su", "suk", "sv", "sw", "ta", "te",
            "tem", "tet", "tg", "th", "ti", "tig", "tk", "tn", "tpi", "tr",
            "ts", "tum", "tzm", "uk", "umb", "ur", "uz", "ve", "vi", "vmw",
            "wo", "xh", "yao", "yo", "yue", "zdj", "zh", "zu"
        )
        for (code in expectedCodes) {
            val locale = Locales.ALL[code]
            assertNotNull(locale, "Locale $code should exist")
            assertEquals(code, locale!!.code, "Locale code should match key")
        }
    }

    // ================================================================
    // Smoke test each locale produces non-null output
    // ================================================================
    @Test
    fun `all locales produce output for basic cases`() {
        for ((code, locale) in Locales.ALL) {
            val pt = SayableAge(locale)

            // Just born
            val justBorn = pt.formatAge("2025-06-15", "2025-06-15")
            assertNotNull(justBorn, "$code: justBorn should not be null")
            assertTrue(justBorn!!.isNotEmpty(), "$code: justBorn should not be empty")

            // Days
            val days = pt.formatAge("2025-06-12", "2025-06-15")
            assertNotNull(days, "$code: days should not be null")

            // Weeks
            val weeks = pt.formatAge("2025-06-07", "2025-06-15")
            assertNotNull(weeks, "$code: weeks should not be null")

            // Months
            val months = pt.formatAge("2025-01-15", "2025-07-15")
            assertNotNull(months, "$code: months should not be null")

            // Years+months
            val yearsMonths = pt.formatAge("2023-06-15", "2025-07-15")
            assertNotNull(yearsMonths, "$code: years+months should not be null")

            // Half-year
            val halfYear = pt.formatAge("2022-06-15", "2025-12-15")
            assertNotNull(halfYear, "$code: half-year should not be null")

            // Integer years
            val intYears = pt.formatAge("2018-06-15", "2025-06-15")
            assertNotNull(intYears, "$code: integer years should not be null")

            // Stage
            val stage = pt.formatStage("2020-01-01", "2025-06-15")
            assertNotNull(stage, "$code: stage should not be null")
        }
    }

    // ================================================================
    // formatStage -- gender support
    // ================================================================
    @Test
    fun `gender null defaults to masculine for gendered locales`() {
        val pt = SayableAge(Locales.ES)
        assertEquals("Reci\u00E9n nacido", pt.formatStage("2025-06-15", "2025-06-15"))
        assertEquals("Ni\u00F1o peque\u00F1o", pt.formatStage("2024-06-15", "2025-06-15"))
        assertEquals("Ni\u00F1o", pt.formatStage("2022-06-15", "2025-06-15"))
        assertEquals("Adulto", pt.formatStage("2007-06-15", "2025-06-15"))
    }

    @Test
    fun `gender m returns masculine`() {
        val pt = SayableAge(Locales.ES)
        assertEquals("Reci\u00E9n nacido", pt.formatStage("2025-06-15", "2025-06-15", "m"))
        assertEquals("Ni\u00F1o peque\u00F1o", pt.formatStage("2024-06-15", "2025-06-15", "m"))
        assertEquals("Ni\u00F1o", pt.formatStage("2022-06-15", "2025-06-15", "m"))
        assertEquals("Adulto", pt.formatStage("2007-06-15", "2025-06-15", "m"))
    }

    @Test
    fun `gender f returns feminine`() {
        val pt = SayableAge(Locales.ES)
        assertEquals("Reci\u00E9n nacida", pt.formatStage("2025-06-15", "2025-06-15", "f"))
        assertEquals("Ni\u00F1a peque\u00F1a", pt.formatStage("2024-06-15", "2025-06-15", "f"))
        assertEquals("Ni\u00F1a", pt.formatStage("2022-06-15", "2025-06-15", "f"))
        assertEquals("Adulta", pt.formatStage("2007-06-15", "2025-06-15", "f"))
    }

    @Test
    fun `gender neutral stages unaffected by gender`() {
        val pt = SayableAge(Locales.ES)
        assertEquals("Beb\u00E9", pt.formatStage("2025-01-15", "2025-06-15", "f"))
        assertEquals("Beb\u00E9", pt.formatStage("2025-01-15", "2025-06-15", "m"))
        assertEquals("Adolescente", pt.formatStage("2012-06-15", "2025-06-15", "f"))
        assertEquals("Adolescente", pt.formatStage("2012-06-15", "2025-06-15", "m"))
    }

    @Test
    fun `gender has no effect on neutral locales`() {
        val pt = SayableAge(Locales.EN)
        assertEquals("Newborn", pt.formatStage("2025-06-15", "2025-06-15", "f"))
        assertEquals("Newborn", pt.formatStage("2025-06-15", "2025-06-15", "m"))
        assertEquals("Adult", pt.formatStage("2007-06-15", "2025-06-15", "f"))
        assertEquals("Adult", pt.formatStage("2007-06-15", "2025-06-15", "m"))
    }

    @Test
    fun `gender French stages`() {
        val pt = SayableAge(Locales.FR)
        assertEquals("Nouveau-n\u00E9", pt.formatStage("2025-06-15", "2025-06-15", "m"))
        assertEquals("Nouveau-n\u00E9e", pt.formatStage("2025-06-15", "2025-06-15", "f"))
        assertEquals("Nourrisson", pt.formatStage("2025-01-15", "2025-06-15", "f"))
        assertEquals("Tout-petit", pt.formatStage("2024-06-15", "2025-06-15", "f"))
        assertEquals("Enfant", pt.formatStage("2022-06-15", "2025-06-15", "f"))
        assertEquals("Adolescent", pt.formatStage("2012-06-15", "2025-06-15", "m"))
        assertEquals("Adolescente", pt.formatStage("2012-06-15", "2025-06-15", "f"))
        assertEquals("Adulte", pt.formatStage("2007-06-15", "2025-06-15", "f"))
    }

    @Test
    fun `gender Italian stages`() {
        val pt = SayableAge(Locales.IT)
        assertEquals("Neonato", pt.formatStage("2025-06-15", "2025-06-15", "m"))
        assertEquals("Neonata", pt.formatStage("2025-06-15", "2025-06-15", "f"))
        assertEquals("Bimbo", pt.formatStage("2024-06-15", "2025-06-15", "m"))
        assertEquals("Bimba", pt.formatStage("2024-06-15", "2025-06-15", "f"))
        assertEquals("Bambino", pt.formatStage("2022-06-15", "2025-06-15", "m"))
        assertEquals("Bambina", pt.formatStage("2022-06-15", "2025-06-15", "f"))
        assertEquals("Adulto", pt.formatStage("2007-06-15", "2025-06-15", "m"))
        assertEquals("Adulta", pt.formatStage("2007-06-15", "2025-06-15", "f"))
    }

    @Test
    fun `gender Arabic all stages`() {
        val pt = SayableAge(Locales.AR)
        assertEquals("\u062D\u062F\u064A\u062B \u0627\u0644\u0648\u0644\u0627\u062F\u0629", pt.formatStage("2025-06-15", "2025-06-15", "m"))
        assertEquals("\u062D\u062F\u064A\u062B\u0629 \u0627\u0644\u0648\u0644\u0627\u062F\u0629", pt.formatStage("2025-06-15", "2025-06-15", "f"))
        assertEquals("\u0631\u0636\u064A\u0639", pt.formatStage("2025-01-15", "2025-06-15", "m"))
        assertEquals("\u0631\u0636\u064A\u0639\u0629", pt.formatStage("2025-01-15", "2025-06-15", "f"))
        assertEquals("\u0637\u0641\u0644 \u0635\u063A\u064A\u0631", pt.formatStage("2024-06-15", "2025-06-15", "m"))
        assertEquals("\u0637\u0641\u0644\u0629 \u0635\u063A\u064A\u0631\u0629", pt.formatStage("2024-06-15", "2025-06-15", "f"))
        assertEquals("\u0637\u0641\u0644", pt.formatStage("2022-06-15", "2025-06-15", "m"))
        assertEquals("\u0637\u0641\u0644\u0629", pt.formatStage("2022-06-15", "2025-06-15", "f"))
        assertEquals("\u0645\u0631\u0627\u0647\u0642", pt.formatStage("2012-06-15", "2025-06-15", "m"))
        assertEquals("\u0645\u0631\u0627\u0647\u0642\u0629", pt.formatStage("2012-06-15", "2025-06-15", "f"))
        assertEquals("\u0628\u0627\u0644\u063A", pt.formatStage("2007-06-15", "2025-06-15", "m"))
        assertEquals("\u0628\u0627\u0644\u063A\u0629", pt.formatStage("2007-06-15", "2025-06-15", "f"))
    }

    @Test
    fun `gender German adult only`() {
        val pt = SayableAge(Locales.DE)
        assertEquals("Erwachsener", pt.formatStage("2007-06-15", "2025-06-15", "m"))
        assertEquals("Erwachsene", pt.formatStage("2007-06-15", "2025-06-15", "f"))
        assertEquals("Neugeborenes", pt.formatStage("2025-06-15", "2025-06-15", "f"))
    }

    @Test
    fun `gender companion method`() {
        assertEquals("Newborn", SayableAge.formatStage("2025-06-15", "2025-06-15", "f"))
        assertEquals("Adult", SayableAge.formatStage("2007-06-15", "2025-06-15", "f"))
    }

    // ================================================================
    // Section 29: Locale-specific edge cases — new plural rules
    // ================================================================

    // 29.1, 29.2, 29.3, 29.4, 29.5, 29.6, 29.7, 29.8, 29.9, 29.10, 29.11, 29.12, 29.13, 29.14
    @Test
    fun `Hebrew locale — dual forms`() {
        val pt = SayableAge(Locales.HE)
        assertEquals("רק נולד", pt.formatAge("2025-06-15", "2025-06-15"))
        assertEquals("יום 1", pt.formatAge("2025-06-14", "2025-06-15"))
        assertEquals("3 ימים", pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals("שבועיים", pt.formatAge("2025-06-01", "2025-06-15"))
        assertEquals("3 שבועות", pt.formatAge("2025-05-25", "2025-06-15"))
        assertEquals("6 חודשים", pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals("3 חודשים", pt.formatAge("2025-03-15", "2025-06-15"))
        assertEquals("שנתיים, חודש 1", pt.formatAge("2023-06-15", "2025-07-15"))
        assertEquals("3 שנים וחצי", pt.formatAge("2022-06-15", "2025-12-15"))
        assertEquals("7 שנים", pt.formatAge("2018-06-15", "2025-06-15"))
        assertEquals("רק נולד", pt.formatStage("2025-06-15", "2025-06-15", "m"))
        assertEquals("רק נולדה", pt.formatStage("2025-06-15", "2025-06-15", "f"))
        assertEquals("מבוגר", pt.formatStage("2007-06-15", "2025-06-15", "m"))
        assertEquals("מבוגרת", pt.formatStage("2007-06-15", "2025-06-15", "f"))
    }

    // 29.15, 29.16, 29.17, 29.18, 29.19, 29.20, 29.21
    @Test
    fun `Macedonian locale — mod10 mod100 rule`() {
        val pt = SayableAge(Locales.MK)
        assertEquals("Новороденче", pt.formatAge("2025-06-15", "2025-06-15"))
        assertEquals("1 ден", pt.formatAge("2025-06-14", "2025-06-15"))
        assertEquals("3 дена", pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals("6 месеци", pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals("2 години, 1 месец", pt.formatAge("2023-06-15", "2025-07-15"))
        assertEquals("3 години и пол", pt.formatAge("2022-06-15", "2025-12-15"))
        assertEquals("7 години", pt.formatAge("2018-06-15", "2025-06-15"))
    }

    // 29.22, 29.23, 29.24, 29.25, 29.26, 29.27
    @Test
    fun `Swahili locale — noun class changes`() {
        val pt = SayableAge(Locales.SW)
        assertEquals("Mzaliwa mpya", pt.formatAge("2025-06-15", "2025-06-15"))
        assertEquals("siku 1", pt.formatAge("2025-06-14", "2025-06-15"))
        assertEquals("siku 3", pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals("miezi 6", pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals("miaka 2, mwezi 1", pt.formatAge("2023-06-15", "2025-07-15"))
        assertEquals("miaka 3 na nusu", pt.formatAge("2022-06-15", "2025-12-15"))
    }

    // 29.28, 29.29, 29.30, 29.31, 29.32, 29.33
    @Test
    fun `Indonesian locale — other only`() {
        val pt = SayableAge(Locales.ID)
        assertEquals("Baru lahir", pt.formatAge("2025-06-15", "2025-06-15"))
        assertEquals("1 hari", pt.formatAge("2025-06-14", "2025-06-15"))
        assertEquals("3 hari", pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals("6 bulan", pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals("3 tahun setengah", pt.formatAge("2022-06-15", "2025-12-15"))
        assertEquals("7 tahun", pt.formatAge("2018-06-15", "2025-06-15"))
    }

    // 29.34, 29.35, 29.36, 29.37, 29.38, 29.39
    @Test
    fun `Amharic locale — Ethiopic delimiter`() {
        val pt = SayableAge(Locales.AM)
        assertEquals("አዲስ የተወለደ", pt.formatAge("2025-06-15", "2025-06-15"))
        assertEquals("1 ቀን", pt.formatAge("2025-06-14", "2025-06-15"))
        assertEquals("3 ቀናት", pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals("1 ሳምንት፣ 1 ቀን", pt.formatAge("2025-06-07", "2025-06-15"))
        assertEquals("6 ወራት", pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals("3 ዓመታት ተኩል", pt.formatAge("2022-06-15", "2025-12-15"))
    }

    // ================================================================
    // Section 30: Locale lookup by code string
    // ================================================================

    // 30.1
    @Test
    fun `getLocale returns en locale`() {
        val loc = Locales.get("en")
        assertNotNull(loc)
        assertEquals("en", loc!!.code)
    }

    // 30.2
    @Test
    fun `getLocale returns fr locale`() {
        val loc = Locales.get("fr")
        assertNotNull(loc)
        assertEquals("fr", loc!!.code)
    }

    // 30.3
    @Test
    fun `getLocale returns null for unknown code`() {
        assertNull(Locales.get("xx"))
    }

    // 30.4
    @Test
    fun `getLocale returns null for empty string`() {
        assertNull(Locales.get(""))
    }

    // 30.5
    @Test
    fun `getLocale is case-sensitive`() {
        assertNull(Locales.get("EN"))
    }

    // ================================================================
    // Weeks and days across month ends
    // ================================================================

    // 31.1
    @Test
    fun `88 days across a 28 day february`() {
        val f = SayableAge(Locales.EN)
        assertEquals("12 weeks, 4 days", f.formatAge("2016-12-31", "2017-03-29"))
    }

    // 31.2
    @Test
    fun `90 days across a year end into`() {
        val f = SayableAge(Locales.EN)
        assertEquals("12 weeks, 6 days", f.formatAge("1991-11-27", "1992-02-25"))
    }

    // 31.3
    @Test
    fun `33 days across a year end`() {
        val f = SayableAge(Locales.EN)
        assertEquals("4 weeks, 5 days", f.formatAge("2020-11-30", "2021-01-02"))
    }

    // 31.4
    @Test
    fun `compact form of 31 1`() {
        val f = SayableAge(Locales.EN, Compactness.COMPACT)
        assertEquals("12w4d", f.formatAge("2016-12-31", "2017-03-29"))
    }

    // ================================================================
    // Half years take their plural form from whole years
    // ================================================================

    // 32.1
    @Test
    fun `polish 3 is few`() {
        val f = SayableAge(Locales.PL)
        assertEquals("3 i p\u00F3\u0142 lata", f.formatAge("2021-06-15", "2025-01-15"))
    }

    // 32.2
    @Test
    fun `polish 5 is many`() {
        val f = SayableAge(Locales.PL, Compactness.SHORT)
        assertEquals("5 i p\u00F3\u0142 lat", f.formatAge("2020-06-15", "2025-12-15"))
    }

    // 32.3
    @Test
    fun `tachelhit 6 is few`() {
        val f = SayableAge(Locales.SHI)
        assertEquals("6 iseggasen d uzgen", f.formatAge("2005-06-08", "2012-06-07"))
    }

    // ================================================================
    // Input validation
    // ================================================================

    // 33.1
    @Test
    fun `february 30 doesnt exist`() {
        val f = SayableAge(Locales.EN)
        assertNull(f.formatAge("2025-02-30", "2032-06-25"))
    }

    // 33.2
    @Test
    fun `month 13`() {
        val f = SayableAge(Locales.EN)
        assertNull(f.formatAge("2025-13-01", "2027-01-31"))
    }

    // 33.3
    @Test
    fun `february 29 in a non leap year`() {
        val f = SayableAge(Locales.EN)
        assertNull(f.formatAge("2023-02-29", "2025-03-01"))
    }

    // 33.4
    @Test
    fun `day 00`() {
        val f = SayableAge(Locales.EN)
        assertNull(f.formatAge("2025-06-00", "2027-02-25"))
    }

    // 33.5
    @Test
    fun `unpadded month and day`() {
        val f = SayableAge(Locales.EN)
        assertNull(f.formatAge("2025-6-1", "2027-02-25"))
    }

    // 33.6
    @Test
    fun `surrounding whitespace`() {
        val f = SayableAge(Locales.EN)
        assertNull(f.formatAge(" 2025-06-01", "2027-02-25"))
    }

    // 33.7
    @Test
    fun `a datetime is not a date`() {
        val f = SayableAge(Locales.EN)
        assertNull(f.formatAge("2025-06-15T10:00:00", "2027-02-25"))
    }

    // 33.8
    @Test
    fun `invalid asof`() {
        val f = SayableAge(Locales.EN)
        assertNull(f.formatAge("2020-01-01", "2025-04-31"))
    }

    // 33.9
    @Test
    fun `formatstage validates too`() {
        val f = SayableAge(Locales.EN)
        assertNull(f.formatStage("2025-02-30", "2027-09-05"))
    }

    // 33.10
    @Test
    fun `february 29 in a leap year is`() {
        val f = SayableAge(Locales.EN)
        assertEquals("2 years", f.formatAge("2024-02-29", "2026-03-01"))
    }
}
