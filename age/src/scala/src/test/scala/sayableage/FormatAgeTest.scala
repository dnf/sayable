package sayableage

import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNotNull
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import java.time.LocalDate
import sayableage.locales.Locales

class FormatAgeTest:

    @AfterEach
    def resetTimeNow(): Unit =
        timeNow = () => LocalDate.now()

    // ================================================================
    // formatAge -- null/edge cases
    // ================================================================
    // 1.3
    @Test
    def emptyStringReturnsNone(): Unit =
        assertEquals(None, SayableAge.formatAge("", "2025-06-15"))

    // 1.4
    @Test
    def futureDobReturnsNone(): Unit =
        assertEquals(None, SayableAge.formatAge("2025-07-01", "2025-06-15"))

    // 1.5
    @Test
    def exactly500YearsIsAllowed(): Unit =
        assertEquals(Some("500 years"), SayableAge.formatAge("1525-06-15", "2025-06-15"))

    // 1.6
    @Test
    def y501ExceedsMaxAge(): Unit =
        assertEquals(None, SayableAge.formatAge("1524-06-15", "2025-06-15"))

    // 1.7
    @Test
    def y1000ExceedsMaxAge(): Unit =
        assertEquals(None, SayableAge.formatAge("1025-06-15", "2025-06-15"))

    // ================================================================
    // formatAge -- days tier (0-6)
    // ================================================================
    // 2.1
    @Test
    def bornToday(): Unit =
        assertEquals(Some("Newborn"), SayableAge.formatAge("2025-06-15", "2025-06-15"))

    // 2.2
    @Test
    def oneDayAgo(): Unit =
        assertEquals(Some("1 day"), SayableAge.formatAge("2025-06-14", "2025-06-15"))

    // 2.3
    @Test
    def threeDaysAgo(): Unit =
        assertEquals(Some("3 days"), SayableAge.formatAge("2025-06-12", "2025-06-15"))

    // 2.4
    @Test
    def sixDaysAgo(): Unit =
        assertEquals(Some("6 days"), SayableAge.formatAge("2025-06-09", "2025-06-15"))

    // 2.5
    @Test
    def sevenDaysBecomes1Week(): Unit =
        assertEquals(Some("1 week"), SayableAge.formatAge("2025-06-08", "2025-06-15"))

    // ================================================================
    // formatAge -- weeks+days tier (7 days to less than 3 months)
    // ================================================================
    // 3.1
    @Test
    def sevenDaysIs1Week(): Unit =
        assertEquals(Some("1 week"), SayableAge.formatAge("2025-06-08", "2025-06-15"))

    // 3.2
    @Test
    def eightDaysIs1Week1Day(): Unit =
        assertEquals(Some("1 week, 1 day"), SayableAge.formatAge("2025-06-07", "2025-06-15"))

    // 3.3
    @Test
    def nineDaysIs1Week2Days(): Unit =
        assertEquals(Some("1 week, 2 days"), SayableAge.formatAge("2025-06-06", "2025-06-15"))

    // 3.4
    @Test
    def thirteenDaysIs1Week6Days(): Unit =
        assertEquals(Some("1 week, 6 days"), SayableAge.formatAge("2025-06-02", "2025-06-15"))

    // 3.5
    @Test
    def fourteenDaysIs2Weeks(): Unit =
        assertEquals(Some("2 weeks"), SayableAge.formatAge("2025-06-01", "2025-06-15"))

    // 3.6
    @Test
    def fifteenDaysIs2Weeks1Day(): Unit =
        assertEquals(Some("2 weeks, 1 day"), SayableAge.formatAge("2025-05-31", "2025-06-15"))

    // 3.7
    @Test
    def twentyDaysIs2Weeks6Days(): Unit =
        assertEquals(Some("2 weeks, 6 days"), SayableAge.formatAge("2025-05-26", "2025-06-15"))

    // 3.8
    @Test
    def twentyOneDaysIs3Weeks(): Unit =
        assertEquals(Some("3 weeks"), SayableAge.formatAge("2025-05-25", "2025-06-15"))

    // 3.9
    @Test
    def at1CalMonthStillWeeksDays(): Unit =
        assertEquals(Some("4 weeks, 3 days"), SayableAge.formatAge("2025-05-15", "2025-06-15"))

    // 3.10
    @Test
    def at2CalMonthsStillWeeksDays(): Unit =
        assertEquals(Some("8 weeks, 5 days"), SayableAge.formatAge("2025-04-15", "2025-06-15"))

    // 3.11
    @Test
    def oneDayBefore3moStillWeeks(): Unit =
        assertEquals(Some("13 weeks"), SayableAge.formatAge("2025-03-15", "2025-06-14"))

    // 3.12
    @Test
    def on3moBirthdaySwitches(): Unit =
        assertEquals(Some("3 months"), SayableAge.formatAge("2025-03-15", "2025-06-15"))

    // ================================================================
    // formatAge -- month boundaries: standard months
    // ================================================================
    // 4.1
    @Test
    def jan1ToApr1Is3mo(): Unit =
        assertEquals(Some("3 months"), SayableAge.formatAge("2025-01-01", "2025-04-01"))

    // 4.2
    @Test
    def jan1ToMar31StillWeeks(): Unit =
        val result = SayableAge.formatAge("2025-01-01", "2025-03-31")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    // 4.3
    @Test
    def jun15ToSep15Is3mo(): Unit =
        assertEquals(Some("3 months"), SayableAge.formatAge("2025-06-15", "2025-09-15"))

    // 4.4
    @Test
    def jun15ToSep14StillWeeks(): Unit =
        val result = SayableAge.formatAge("2025-06-15", "2025-09-14")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    // 4.5
    @Test
    def jun15ToDec15Is6mo(): Unit =
        assertEquals(Some("6 months"), SayableAge.formatAge("2025-06-15", "2025-12-15"))

    // ================================================================
    // formatAge -- month boundaries: February non-leap
    // ================================================================
    // 5.1
    @Test
    def jan31ToFeb28NonLeap(): Unit =
        assertEquals(Some("4 weeks"), SayableAge.formatAge("2025-01-31", "2025-02-28"))

    // 5.2
    @Test
    def jan31ToApr30Is3moClamp(): Unit =
        assertEquals(Some("3 months"), SayableAge.formatAge("2025-01-31", "2025-04-30"))

    // 5.3
    @Test
    def jan31ToApr29StillWeeks(): Unit =
        val result = SayableAge.formatAge("2025-01-31", "2025-04-29")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    // 5.4
    @Test
    def feb1ToMay1Is3mo(): Unit =
        assertEquals(Some("3 months"), SayableAge.formatAge("2025-02-01", "2025-05-01"))

    // 5.5
    @Test
    def feb1ToApr30StillWeeks(): Unit =
        val result = SayableAge.formatAge("2025-02-01", "2025-04-30")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    // ================================================================
    // formatAge -- month boundaries: February leap year
    // ================================================================
    // 6.1
    @Test
    def jan31ToFeb29Leap(): Unit =
        assertEquals(Some("4 weeks, 1 day"), SayableAge.formatAge("2024-01-31", "2024-02-29"))

    // 6.2
    @Test
    def jan31ToFeb28Leap(): Unit =
        assertEquals(Some("4 weeks"), SayableAge.formatAge("2024-01-31", "2024-02-28"))

    // 6.3
    @Test
    def jan31ToApr30LeapIs3mo(): Unit =
        assertEquals(Some("3 months"), SayableAge.formatAge("2024-01-31", "2024-04-30"))

    // 6.4
    @Test
    def jan30ToFeb29LeapStillWeeks(): Unit =
        val result = SayableAge.formatAge("2024-01-30", "2024-02-29")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    // 6.5
    @Test
    def jan30ToFeb28LeapStillWeeks(): Unit =
        val result = SayableAge.formatAge("2024-01-30", "2024-02-28")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    // ================================================================
    // formatAge -- month boundaries: 30-day months
    // ================================================================
    // 7.1
    @Test
    def mar31ToJun30Is3moClamped(): Unit =
        assertEquals(Some("3 months"), SayableAge.formatAge("2025-03-31", "2025-06-30"))

    // 7.2
    @Test
    def mar31ToJun29StillWeeks(): Unit =
        val result = SayableAge.formatAge("2025-03-31", "2025-06-29")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    // 7.3
    @Test
    def aug31ToNov30Is3mo(): Unit =
        assertEquals(Some("3 months"), SayableAge.formatAge("2025-08-31", "2025-11-30"))

    // 7.4
    @Test
    def aug31ToNov29StillWeeks(): Unit =
        val result = SayableAge.formatAge("2025-08-31", "2025-11-29")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    // ================================================================
    // formatAge -- month boundaries: leap year baby (born Feb 29)
    // ================================================================
    // 8.1
    @Test
    def feb29ToMay29Is3mo(): Unit =
        assertEquals(Some("3 months"), SayableAge.formatAge("2024-02-29", "2024-05-29"))

    // 8.2
    @Test
    def feb29ToMay28StillWeeks(): Unit =
        val result = SayableAge.formatAge("2024-02-29", "2024-05-28")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    // 8.3
    @Test
    def feb29_2024ToFeb28_2025Is12mo(): Unit =
        assertEquals(Some("12 months"), SayableAge.formatAge("2024-02-29", "2025-02-28"))

    // 8.4
    @Test
    def feb29_2024ToMar1_2025Is12mo(): Unit =
        assertEquals(Some("12 months"), SayableAge.formatAge("2024-02-29", "2025-03-01"))

    // ================================================================
    // formatAge -- months tier (3-23)
    // ================================================================
    // 9.1
    @Test
    def threeMonthsAtTransition(): Unit =
        assertEquals(Some("3 months"), SayableAge.formatAge("2025-01-15", "2025-04-15"))

    // 9.2
    @Test
    def sixMonths(): Unit =
        assertEquals(Some("6 months"), SayableAge.formatAge("2025-01-15", "2025-07-15"))

    // 9.3
    @Test
    def twelveMonthsNot1Year(): Unit =
        assertEquals(Some("12 months"), SayableAge.formatAge("2024-06-15", "2025-06-15"))

    // 9.4
    @Test
    def twentyThreeMonthsAtUpper(): Unit =
        assertEquals(Some("23 months"), SayableAge.formatAge("2024-01-15", "2025-12-15"))

    // 9.5
    @Test
    def oneDayBeforeBoundary(): Unit =
        assertEquals(Some("5 months"), SayableAge.formatAge("2025-01-15", "2025-07-14"))

    // 9.6
    @Test
    def crossingYearBoundary(): Unit =
        assertEquals(Some("5 months"), SayableAge.formatAge("2024-11-10", "2025-04-10"))

    // ================================================================
    // formatAge -- years+months tier (24-35 months)
    // ================================================================
    // 10.1
    @Test
    def twoYearsAt24mo(): Unit =
        assertEquals(Some("2 years"), SayableAge.formatAge("2023-06-15", "2025-06-15"))

    // 10.2
    @Test
    def twoYears1Month(): Unit =
        assertEquals(Some("2 years, 1 month"), SayableAge.formatAge("2023-06-15", "2025-07-15"))

    // 10.3
    @Test
    def twoYears6Months(): Unit =
        assertEquals(Some("2 years, 6 months"), SayableAge.formatAge("2023-06-15", "2025-12-15"))

    // 10.4
    @Test
    def twoYears11Months(): Unit =
        assertEquals(Some("2 years, 11 months"), SayableAge.formatAge("2023-06-15", "2026-05-15"))

    // 10.5
    @Test
    def oneDayBefore24mo(): Unit =
        assertEquals(Some("23 months"), SayableAge.formatAge("2023-06-15", "2025-06-14"))

    // ================================================================
    // formatAge -- half-year tier (3-6 years)
    // ================================================================
    // 11.1
    @Test
    def threeYearsExactly(): Unit =
        assertEquals(Some("3 years"), SayableAge.formatAge("2022-06-15", "2025-06-15"))

    // 11.2
    @Test
    def threeYears5Months(): Unit =
        assertEquals(Some("3 years"), SayableAge.formatAge("2022-06-15", "2025-11-15"))

    // 11.3
    @Test
    def threeAndHalfYearsAt3y6m(): Unit =
        assertEquals(Some("3\u00BD years"), SayableAge.formatAge("2022-06-15", "2025-12-15"))

    // 11.4
    @Test
    def threeAndHalfYearsAt3y11m(): Unit =
        assertEquals(Some("3\u00BD years"), SayableAge.formatAge("2022-06-15", "2026-05-15"))

    // 11.5
    @Test
    def fourYearsExactly(): Unit =
        assertEquals(Some("4 years"), SayableAge.formatAge("2021-06-15", "2025-06-15"))

    // 11.6
    @Test
    def fourAndHalfYears(): Unit =
        assertEquals(Some("4\u00BD years"), SayableAge.formatAge("2021-06-15", "2025-12-15"))

    // 11.7
    @Test
    def fiveYears(): Unit =
        assertEquals(Some("5 years"), SayableAge.formatAge("2020-06-15", "2025-06-15"))

    // 11.8
    @Test
    def fiveAndHalfYearsAt5y8m(): Unit =
        assertEquals(Some("5\u00BD years"), SayableAge.formatAge("2020-06-15", "2026-02-15"))

    // 11.9
    @Test
    def sixYears(): Unit =
        assertEquals(Some("6 years"), SayableAge.formatAge("2019-06-15", "2025-06-15"))

    // 11.10
    @Test
    def sixAndHalfYears(): Unit =
        assertEquals(Some("6\u00BD years"), SayableAge.formatAge("2019-06-15", "2025-12-15"))

    // 11.11
    @Test
    def sixAndHalfYearsAt6y11m(): Unit =
        assertEquals(Some("6\u00BD years"), SayableAge.formatAge("2019-06-15", "2026-05-15"))

    // 11.12
    @Test
    def oneDayBefore3rdBday(): Unit =
        assertEquals(Some("2 years, 11 months"), SayableAge.formatAge("2022-06-15", "2025-06-14"))

    // ================================================================
    // formatAge -- integer tier (7+ years)
    // ================================================================
    // 12.1
    @Test
    def sevenYearsExactly(): Unit =
        assertEquals(Some("7 years"), SayableAge.formatAge("2018-06-15", "2025-06-15"))

    // 12.2
    @Test
    def sevenYears6MonthsNoHalf(): Unit =
        assertEquals(Some("7 years"), SayableAge.formatAge("2018-03-20", "2025-06-15"))

    // 12.3
    @Test
    def fortyFiveYears(): Unit =
        assertEquals(Some("45 years"), SayableAge.formatAge("1980-01-01", "2025-06-15"))

    // ================================================================
    // formatAge -- cross-year transitions with Feb
    // ================================================================
    // 13.1
    @Test
    def dec31ToMar31Is3mo(): Unit =
        assertEquals(Some("3 months"), SayableAge.formatAge("2024-12-31", "2025-03-31"))

    // 13.2
    @Test
    def dec31ToMar30StillWeeks(): Unit =
        val result = SayableAge.formatAge("2024-12-31", "2025-03-30")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    // 13.3
    @Test
    def nov30ToFeb28Is3mo(): Unit =
        assertEquals(Some("3 months"), SayableAge.formatAge("2024-11-30", "2025-02-28"))

    // 13.4
    @Test
    def nov30ToFeb27StillWeeks(): Unit =
        val result = SayableAge.formatAge("2024-11-30", "2025-02-27")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    // ================================================================
    // formatAge -- born-on-31st progression
    // ================================================================
    // 14.1
    @Test
    def jan31ToApr30Is3mo(): Unit =
        assertEquals(Some("3 months"), SayableAge.formatAge("2025-01-31", "2025-04-30"))

    // 14.2
    @Test
    def jan31ToMay31Is4mo(): Unit =
        assertEquals(Some("4 months"), SayableAge.formatAge("2025-01-31", "2025-05-31"))

    // 14.3
    @Test
    def jan31ToJun30Is5moClamped(): Unit =
        assertEquals(Some("5 months"), SayableAge.formatAge("2025-01-31", "2025-06-30"))

    // 14.4
    @Test
    def jan31ToJul1Is5mo(): Unit =
        assertEquals(Some("5 months"), SayableAge.formatAge("2025-01-31", "2025-07-01"))

    // 14.5
    @Test
    def jan31ToJul31Is6mo(): Unit =
        assertEquals(Some("6 months"), SayableAge.formatAge("2025-01-31", "2025-07-31"))

    // ================================================================
    // formatAge -- default asOf (uses current date)
    // ================================================================
    // 15.1, 15.2
    @Test
    def defaultAsOfUsesMockedToday(): Unit =
        timeNow = () => LocalDate.of(2025, 6, 15)
        assertEquals(Some("5 years"), SayableAge.formatAge("2020-01-01"))
        assertEquals(Some("5 days"), SayableAge.formatAge("2025-06-10"))

    // ================================================================
    // formatStage -- null/edge cases
    // ================================================================
    // 16.1, 16.3
    @Test
    def stageEmptyStringReturnsNone(): Unit =
        assertEquals(None, SayableAge.formatStage("", "2025-06-15"))

    // 16.4
    @Test
    def stageFutureDobReturnsNone(): Unit =
        assertEquals(None, SayableAge.formatStage("2025-07-01", "2025-06-15"))

    // 16.5
    @Test
    def stageExactly500YearsReturnsAdult(): Unit =
        assertEquals(Some("Adult"), SayableAge.formatStage("1525-06-15", "2025-06-15"))

    // 16.6
    @Test
    def stage501YearsExceedsMaxAge(): Unit =
        assertEquals(None, SayableAge.formatStage("1524-06-15", "2025-06-15"))

    // ================================================================
    // formatStage -- newborn
    // ================================================================
    // 17.1
    @Test
    def stageBornToday(): Unit =
        assertEquals(Some("Newborn"), SayableAge.formatStage("2025-06-15", "2025-06-15"))

    // 17.2
    @Test
    def stage1DayOld(): Unit =
        assertEquals(Some("Newborn"), SayableAge.formatStage("2025-06-14", "2025-06-15"))

    // 17.3
    @Test
    def stage3WeeksOld(): Unit =
        assertEquals(Some("Newborn"), SayableAge.formatStage("2025-05-25", "2025-06-15"))

    // 17.4
    @Test
    def stage1MonthOld(): Unit =
        assertEquals(Some("Newborn"), SayableAge.formatStage("2025-05-15", "2025-06-15"))

    // 17.5
    @Test
    def stage1Month29Days(): Unit =
        assertEquals(Some("Newborn"), SayableAge.formatStage("2025-04-16", "2025-06-15"))

    // 17.6
    @Test
    def stageExactly2MonthsBecomesInfant(): Unit =
        assertEquals(Some("Infant"), SayableAge.formatStage("2025-04-15", "2025-06-15"))

    // ================================================================
    // formatStage -- infant
    // ================================================================
    // 18.1
    @Test
    def stage2Months(): Unit =
        assertEquals(Some("Infant"), SayableAge.formatStage("2025-04-15", "2025-06-15"))

    // 18.2
    @Test
    def stage6Months(): Unit =
        assertEquals(Some("Infant"), SayableAge.formatStage("2024-12-15", "2025-06-15"))

    // 18.3
    @Test
    def stage11Months(): Unit =
        assertEquals(Some("Infant"), SayableAge.formatStage("2024-07-15", "2025-06-15"))

    // 18.4
    @Test
    def stageExactly12moBecomesToddler(): Unit =
        assertEquals(Some("Toddler"), SayableAge.formatStage("2024-06-15", "2025-06-15"))

    // ================================================================
    // formatStage -- toddler
    // ================================================================
    // 19.1
    @Test
    def stage12Months(): Unit =
        assertEquals(Some("Toddler"), SayableAge.formatStage("2024-06-15", "2025-06-15"))

    // 19.2
    @Test
    def stage18Months(): Unit =
        assertEquals(Some("Toddler"), SayableAge.formatStage("2024-01-15", "2025-07-15"))

    // 19.3
    @Test
    def stage24Months(): Unit =
        assertEquals(Some("Toddler"), SayableAge.formatStage("2023-06-15", "2025-06-15"))

    // 19.4
    @Test
    def stage35Months(): Unit =
        assertEquals(Some("Toddler"), SayableAge.formatStage("2023-06-15", "2026-05-15"))

    // 19.5
    @Test
    def stageExactly36moBecomesChild(): Unit =
        assertEquals(Some("Child"), SayableAge.formatStage("2022-06-15", "2025-06-15"))

    // ================================================================
    // formatStage -- child
    // ================================================================
    // 20.1
    @Test
    def stage3Years(): Unit =
        assertEquals(Some("Child"), SayableAge.formatStage("2022-06-15", "2025-06-15"))

    // 20.2
    @Test
    def stage4Years(): Unit =
        assertEquals(Some("Child"), SayableAge.formatStage("2021-06-15", "2025-06-15"))

    // 20.3
    @Test
    def stage6YearsChild(): Unit =
        assertEquals(Some("Child"), SayableAge.formatStage("2019-06-15", "2025-06-15"))

    // 20.4
    @Test
    def stage9Years(): Unit =
        assertEquals(Some("Child"), SayableAge.formatStage("2016-06-15", "2025-06-15"))

    // 20.5
    @Test
    def stage12y11mo(): Unit =
        assertEquals(Some("Child"), SayableAge.formatStage("2013-06-15", "2026-05-15"))

    // 20.6
    @Test
    def stageExactly13yBecomesTeenager(): Unit =
        assertEquals(Some("Teenager"), SayableAge.formatStage("2012-06-15", "2025-06-15"))

    // ================================================================
    // formatStage -- teenager
    // ================================================================
    // 21.1
    @Test
    def stage13Years(): Unit =
        assertEquals(Some("Teenager"), SayableAge.formatStage("2012-06-15", "2025-06-15"))

    // 21.2
    @Test
    def stage15Years(): Unit =
        assertEquals(Some("Teenager"), SayableAge.formatStage("2010-06-15", "2025-06-15"))

    // 21.3
    @Test
    def stage17y11mo(): Unit =
        assertEquals(Some("Teenager"), SayableAge.formatStage("2008-06-15", "2026-05-15"))

    // 21.4
    @Test
    def stageExactly18yBecomesAdult(): Unit =
        assertEquals(Some("Adult"), SayableAge.formatStage("2007-06-15", "2025-06-15"))

    // ================================================================
    // formatStage -- adult
    // ================================================================
    // 22.1
    @Test
    def stage18Years(): Unit =
        assertEquals(Some("Adult"), SayableAge.formatStage("2007-06-15", "2025-06-15"))

    // 22.2
    @Test
    def stage25Years(): Unit =
        assertEquals(Some("Adult"), SayableAge.formatStage("2000-06-15", "2025-06-15"))

    // 22.3
    @Test
    def stage45Years(): Unit =
        assertEquals(Some("Adult"), SayableAge.formatStage("1980-01-01", "2025-06-15"))

    // ================================================================
    // formatStage -- default asOf
    // ================================================================
    // 23.1, 23.2, 23.3
    @Test
    def stageDefaultAsOf(): Unit =
        timeNow = () => LocalDate.of(2025, 6, 15)
        assertEquals(Some("Newborn"), SayableAge.formatStage("2025-06-15"))
        assertEquals(Some("Child"), SayableAge.formatStage("2020-01-01"))
        assertEquals(Some("Adult"), SayableAge.formatStage("1980-01-01"))

    // ================================================================
    // SayableAge class with English locale
    // ================================================================
    // 24.1, 24.2, 24.3, 24.4, 24.5, 24.6, 24.7, 24.8, 24.9, 24.10, 24.11, 24.12, 24.13, 24.14, 24.15
    @Test
    def parentTimeEnglishAllTiers(): Unit =
        val pt = new SayableAge(Locales.EN)
        assertEquals(Some("Newborn"), pt.formatAge("2025-06-15", "2025-06-15"))
        assertEquals(Some("3 days"), pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals(Some("1 week, 1 day"), pt.formatAge("2025-06-07", "2025-06-15"))
        assertEquals(Some("6 months"), pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals(Some("2 years, 1 month"), pt.formatAge("2023-06-15", "2025-07-15"))
        assertEquals(Some("3\u00BD years"), pt.formatAge("2022-06-15", "2025-12-15"))
        assertEquals(Some("7 years"), pt.formatAge("2018-06-15", "2025-06-15"))

        assertEquals(Some("Newborn"), pt.formatStage("2025-06-15", "2025-06-15"))
        assertEquals(Some("Infant"), pt.formatStage("2025-01-15", "2025-06-15"))
        assertEquals(Some("Toddler"), pt.formatStage("2024-06-15", "2025-06-15"))
        assertEquals(Some("Child"), pt.formatStage("2022-06-15", "2025-06-15"))
        assertEquals(Some("Teenager"), pt.formatStage("2012-06-15", "2025-06-15"))
        assertEquals(Some("Adult"), pt.formatStage("2007-06-15", "2025-06-15"))

        assertEquals(None, pt.formatAge(""))
        assertEquals(None, pt.formatStage(""))

    // ================================================================
    // SayableAge with Spanish locale
    // ================================================================
    // 25.1, 25.2, 25.3, 25.4, 25.5, 25.6, 25.7, 25.8, 25.9, 25.10, 25.11, 25.12, 25.13, 25.14, 25.15, 25.16, 25.17, 25.18, 25.19, 25.20
    @Test
    def parentTimeSpanishInlineLocale(): Unit =
        val es = AgeLocale(
            code = "es",
            plural = n => if (n == 1) PluralCategory.ONE else PluralCategory.OTHER,
            units = Units(
                day = pluralUnit(Map(PluralCategory.ONE -> "{n} d\u00EDa", PluralCategory.OTHER -> "{n} d\u00EDas")),
                week = pluralUnit(Map(PluralCategory.ONE -> "{n} semana", PluralCategory.OTHER -> "{n} semanas")),
                month = pluralUnit(Map(PluralCategory.ONE -> "{n} mes", PluralCategory.OTHER -> "{n} meses")),
                year = pluralUnit(Map(PluralCategory.ONE -> "{n} a\u00F1o", PluralCategory.OTHER -> "{n} a\u00F1os"))
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

        val pt = new SayableAge(es)

        assertEquals(Some("Reci\u00E9n nacido"), pt.formatAge("2025-06-15", "2025-06-15"))
        assertEquals(Some("1 d\u00EDa"), pt.formatAge("2025-06-14", "2025-06-15"))
        assertEquals(Some("3 d\u00EDas"), pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals(Some("1 semana"), pt.formatAge("2025-06-08", "2025-06-15"))
        assertEquals(Some("1 semana, 1 d\u00EDa"), pt.formatAge("2025-06-07", "2025-06-15"))
        assertEquals(Some("2 semanas, 6 d\u00EDas"), pt.formatAge("2025-05-26", "2025-06-15"))
        assertEquals(Some("6 meses"), pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals(Some("2 a\u00F1os, 1 mes"), pt.formatAge("2023-06-15", "2025-07-15"))
        assertEquals(Some("2 a\u00F1os, 6 meses"), pt.formatAge("2023-06-15", "2025-12-15"))
        assertEquals(Some("3 y medio a\u00F1os"), pt.formatAge("2022-06-15", "2025-12-15"))
        assertEquals(Some("3 a\u00F1os"), pt.formatAge("2022-06-15", "2025-06-15"))
        assertEquals(Some("7 a\u00F1os"), pt.formatAge("2018-06-15", "2025-06-15"))

        assertEquals(Some("Reci\u00E9n nacido"), pt.formatStage("2025-06-15", "2025-06-15"))
        assertEquals(Some("Beb\u00E9"), pt.formatStage("2025-01-15", "2025-06-15"))
        assertEquals(Some("Ni\u00F1o peque\u00F1o"), pt.formatStage("2024-06-15", "2025-06-15"))
        assertEquals(Some("Ni\u00F1o"), pt.formatStage("2022-06-15", "2025-06-15"))
        assertEquals(Some("Adolescente"), pt.formatStage("2012-06-15", "2025-06-15"))
        assertEquals(Some("Adulto"), pt.formatStage("2007-06-15", "2025-06-15"))

        assertEquals(None, pt.formatAge(""))
        assertEquals(None, pt.formatStage(""))

    // ================================================================
    // Compactness: short
    // ================================================================
    // 26.1, 26.2, 26.3, 26.4, 26.5, 26.6, 26.7, 26.8, 26.9
    @Test
    def compactShort(): Unit =
        val pt = new SayableAge(Locales.EN, Compactness.SHORT)

        assertEquals(Some("3 d"), pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals(Some("1 wk"), pt.formatAge("2025-06-08", "2025-06-15"))
        assertEquals(Some("1 wk, 1 d"), pt.formatAge("2025-06-07", "2025-06-15"))
        assertEquals(Some("6 mo"), pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals(Some("2 yr, 1 mo"), pt.formatAge("2023-06-15", "2025-07-15"))
        assertEquals(Some("3\u00BD yr"), pt.formatAge("2022-06-15", "2025-12-15"))
        assertEquals(Some("7 yr"), pt.formatAge("2018-06-15", "2025-06-15"))
        assertEquals(Some("Newborn"), pt.formatAge("2025-06-15", "2025-06-15"))
        assertEquals(Some("Infant"), pt.formatStage("2025-01-15", "2025-06-15"))

    // ================================================================
    // Compactness: compact
    // ================================================================
    // 27.1, 27.2, 27.3, 27.4, 27.5, 27.6, 27.7, 27.8
    @Test
    def compactCompact(): Unit =
        val pt = new SayableAge(Locales.EN, Compactness.COMPACT)

        assertEquals(Some("3d"), pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals(Some("1w"), pt.formatAge("2025-06-08", "2025-06-15"))
        assertEquals(Some("1w1d"), pt.formatAge("2025-06-07", "2025-06-15"))
        assertEquals(Some("6m"), pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals(Some("2y1m"), pt.formatAge("2023-06-15", "2025-07-15"))
        assertEquals(Some("3\u00BDy"), pt.formatAge("2022-06-15", "2025-12-15"))
        assertEquals(Some("7y"), pt.formatAge("2018-06-15", "2025-06-15"))
        assertEquals(Some("Newborn"), pt.formatAge("2025-06-15", "2025-06-15"))

    // ================================================================
    // All 71 locales exist and have correct codes
    // ================================================================
    @Test
    def all71LocalesExist(): Unit =
        assertEquals(71, Locales.ALL.size)
        val expectedCodes = List(
            "am", "ar", "az", "bg", "bn", "br", "bs", "ca", "cs", "cy",
            "da", "de", "el", "en", "es", "et", "eu", "fa", "fi", "fil",
            "fr", "ga", "gd", "gu", "gv", "he", "hi", "hr", "hu", "id",
            "it", "ja", "jv", "ka", "kk", "km", "ko", "kw", "lt", "lv",
            "mk", "mr", "ms", "mt", "my", "nb", "ne", "nl", "pa", "pl",
            "pt", "ro", "ru", "shi", "si", "sk", "sl", "sq", "sr", "sv",
            "sw", "ta", "te", "th", "tr", "tzm", "uk", "ur", "uz", "vi",
            "zh"
        )
        for (code <- expectedCodes)
            val locale = Locales.ALL.get(code)
            assertTrue(locale.isDefined, s"Locale $code should exist")
            assertEquals(code, locale.get.code, s"Locale code should match key")

    // ================================================================
    // Smoke test each locale produces non-null output
    // ================================================================
    @Test
    def allLocalesProduceOutputForBasicCases(): Unit =
        for ((code, locale) <- Locales.ALL)
            val pt = new SayableAge(locale)

            val justBorn = pt.formatAge("2025-06-15", "2025-06-15")
            assertTrue(justBorn.isDefined, s"$code: justBorn should not be None")
            assertTrue(justBorn.get.nonEmpty, s"$code: justBorn should not be empty")

            val days = pt.formatAge("2025-06-12", "2025-06-15")
            assertTrue(days.isDefined, s"$code: days should not be None")

            val weeks = pt.formatAge("2025-06-07", "2025-06-15")
            assertTrue(weeks.isDefined, s"$code: weeks should not be None")

            val months = pt.formatAge("2025-01-15", "2025-07-15")
            assertTrue(months.isDefined, s"$code: months should not be None")

            val yearsMonths = pt.formatAge("2023-06-15", "2025-07-15")
            assertTrue(yearsMonths.isDefined, s"$code: years+months should not be None")

            val halfYear = pt.formatAge("2022-06-15", "2025-12-15")
            assertTrue(halfYear.isDefined, s"$code: half-year should not be None")

            val intYears = pt.formatAge("2018-06-15", "2025-06-15")
            assertTrue(intYears.isDefined, s"$code: integer years should not be None")

            val stage = pt.formatStage("2020-01-01", "2025-06-15")
            assertTrue(stage.isDefined, s"$code: stage should not be None")

    // ================================================================
    // formatStage -- gender support
    // ================================================================
    @Test
    def genderNullDefaultsToMasculineForGenderedLocales(): Unit =
        val pt = new SayableAge(Locales.ES)
        assertEquals(Some("Reci\u00E9n nacido"), pt.formatStage("2025-06-15", "2025-06-15"))
        assertEquals(Some("Ni\u00F1o peque\u00F1o"), pt.formatStage("2024-06-15", "2025-06-15"))
        assertEquals(Some("Ni\u00F1o"), pt.formatStage("2022-06-15", "2025-06-15"))
        assertEquals(Some("Adulto"), pt.formatStage("2007-06-15", "2025-06-15"))

    @Test
    def genderMReturnsMasculine(): Unit =
        val pt = new SayableAge(Locales.ES)
        assertEquals(Some("Reci\u00E9n nacido"), pt.formatStage("2025-06-15", "2025-06-15", "m"))
        assertEquals(Some("Ni\u00F1o peque\u00F1o"), pt.formatStage("2024-06-15", "2025-06-15", "m"))
        assertEquals(Some("Ni\u00F1o"), pt.formatStage("2022-06-15", "2025-06-15", "m"))
        assertEquals(Some("Adulto"), pt.formatStage("2007-06-15", "2025-06-15", "m"))

    @Test
    def genderFReturnsFeminine(): Unit =
        val pt = new SayableAge(Locales.ES)
        assertEquals(Some("Reci\u00E9n nacida"), pt.formatStage("2025-06-15", "2025-06-15", "f"))
        assertEquals(Some("Ni\u00F1a peque\u00F1a"), pt.formatStage("2024-06-15", "2025-06-15", "f"))
        assertEquals(Some("Ni\u00F1a"), pt.formatStage("2022-06-15", "2025-06-15", "f"))
        assertEquals(Some("Adulta"), pt.formatStage("2007-06-15", "2025-06-15", "f"))

    @Test
    def genderNeutralStagesUnaffectedByGender(): Unit =
        val pt = new SayableAge(Locales.ES)
        assertEquals(Some("Beb\u00E9"), pt.formatStage("2025-01-15", "2025-06-15", "f"))
        assertEquals(Some("Beb\u00E9"), pt.formatStage("2025-01-15", "2025-06-15", "m"))
        assertEquals(Some("Adolescente"), pt.formatStage("2012-06-15", "2025-06-15", "f"))
        assertEquals(Some("Adolescente"), pt.formatStage("2012-06-15", "2025-06-15", "m"))

    @Test
    def genderHasNoEffectOnNeutralLocales(): Unit =
        val pt = new SayableAge(Locales.EN)
        assertEquals(Some("Newborn"), pt.formatStage("2025-06-15", "2025-06-15", "f"))
        assertEquals(Some("Newborn"), pt.formatStage("2025-06-15", "2025-06-15", "m"))
        assertEquals(Some("Adult"), pt.formatStage("2007-06-15", "2025-06-15", "f"))
        assertEquals(Some("Adult"), pt.formatStage("2007-06-15", "2025-06-15", "m"))

    @Test
    def genderFrenchStages(): Unit =
        val pt = new SayableAge(Locales.FR)
        assertEquals(Some("Nouveau-n\u00E9"), pt.formatStage("2025-06-15", "2025-06-15", "m"))
        assertEquals(Some("Nouveau-n\u00E9e"), pt.formatStage("2025-06-15", "2025-06-15", "f"))
        assertEquals(Some("Nourrisson"), pt.formatStage("2025-01-15", "2025-06-15", "f"))
        assertEquals(Some("Tout-petit"), pt.formatStage("2024-06-15", "2025-06-15", "f"))
        assertEquals(Some("Enfant"), pt.formatStage("2022-06-15", "2025-06-15", "f"))
        assertEquals(Some("Adolescent"), pt.formatStage("2012-06-15", "2025-06-15", "m"))
        assertEquals(Some("Adolescente"), pt.formatStage("2012-06-15", "2025-06-15", "f"))
        assertEquals(Some("Adulte"), pt.formatStage("2007-06-15", "2025-06-15", "f"))

    @Test
    def genderItalianStages(): Unit =
        val pt = new SayableAge(Locales.IT)
        assertEquals(Some("Neonato"), pt.formatStage("2025-06-15", "2025-06-15", "m"))
        assertEquals(Some("Neonata"), pt.formatStage("2025-06-15", "2025-06-15", "f"))
        assertEquals(Some("Bimbo"), pt.formatStage("2024-06-15", "2025-06-15", "m"))
        assertEquals(Some("Bimba"), pt.formatStage("2024-06-15", "2025-06-15", "f"))
        assertEquals(Some("Bambino"), pt.formatStage("2022-06-15", "2025-06-15", "m"))
        assertEquals(Some("Bambina"), pt.formatStage("2022-06-15", "2025-06-15", "f"))
        assertEquals(Some("Adulto"), pt.formatStage("2007-06-15", "2025-06-15", "m"))
        assertEquals(Some("Adulta"), pt.formatStage("2007-06-15", "2025-06-15", "f"))

    @Test
    def genderArabicAllStages(): Unit =
        val pt = new SayableAge(Locales.AR)
        assertEquals(Some("\u062D\u062F\u064A\u062B \u0627\u0644\u0648\u0644\u0627\u062F\u0629"), pt.formatStage("2025-06-15", "2025-06-15", "m"))
        assertEquals(Some("\u062D\u062F\u064A\u062B\u0629 \u0627\u0644\u0648\u0644\u0627\u062F\u0629"), pt.formatStage("2025-06-15", "2025-06-15", "f"))
        assertEquals(Some("\u0631\u0636\u064A\u0639"), pt.formatStage("2025-01-15", "2025-06-15", "m"))
        assertEquals(Some("\u0631\u0636\u064A\u0639\u0629"), pt.formatStage("2025-01-15", "2025-06-15", "f"))
        assertEquals(Some("\u0637\u0641\u0644 \u0635\u063A\u064A\u0631"), pt.formatStage("2024-06-15", "2025-06-15", "m"))
        assertEquals(Some("\u0637\u0641\u0644\u0629 \u0635\u063A\u064A\u0631\u0629"), pt.formatStage("2024-06-15", "2025-06-15", "f"))
        assertEquals(Some("\u0637\u0641\u0644"), pt.formatStage("2022-06-15", "2025-06-15", "m"))
        assertEquals(Some("\u0637\u0641\u0644\u0629"), pt.formatStage("2022-06-15", "2025-06-15", "f"))
        assertEquals(Some("\u0645\u0631\u0627\u0647\u0642"), pt.formatStage("2012-06-15", "2025-06-15", "m"))
        assertEquals(Some("\u0645\u0631\u0627\u0647\u0642\u0629"), pt.formatStage("2012-06-15", "2025-06-15", "f"))
        assertEquals(Some("\u0628\u0627\u0644\u063A"), pt.formatStage("2007-06-15", "2025-06-15", "m"))
        assertEquals(Some("\u0628\u0627\u0644\u063A\u0629"), pt.formatStage("2007-06-15", "2025-06-15", "f"))

    @Test
    def genderGermanAdultOnly(): Unit =
        val pt = new SayableAge(Locales.DE)
        assertEquals(Some("Erwachsener"), pt.formatStage("2007-06-15", "2025-06-15", "m"))
        assertEquals(Some("Erwachsene"), pt.formatStage("2007-06-15", "2025-06-15", "f"))
        assertEquals(Some("Neugeborenes"), pt.formatStage("2025-06-15", "2025-06-15", "f"))

    @Test
    def genderCompanionMethod(): Unit =
        assertEquals(Some("Newborn"), SayableAge.formatStage("2025-06-15", "2025-06-15", "f"))
        assertEquals(Some("Adult"), SayableAge.formatStage("2007-06-15", "2025-06-15", "f"))

    // ================================================================
    // Section 29: Locale-specific edge cases — new plural rules
    // ================================================================

    // 29.1, 29.2, 29.3, 29.4, 29.5, 29.6, 29.7, 29.8, 29.9, 29.10, 29.11, 29.12, 29.13, 29.14
    @Test
    def hebrewLocaleDualForms(): Unit =
        val pt = new SayableAge(Locales.HE)
        assertEquals(Some("\u05E8\u05E7 \u05E0\u05D5\u05DC\u05D3"), pt.formatAge("2025-06-15", "2025-06-15"))
        assertEquals(Some("\u05D9\u05D5\u05DD 1"), pt.formatAge("2025-06-14", "2025-06-15"))
        assertEquals(Some("3 \u05D9\u05DE\u05D9\u05DD"), pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals(Some("\u05E9\u05D1\u05D5\u05E2\u05D9\u05D9\u05DD"), pt.formatAge("2025-06-01", "2025-06-15"))
        assertEquals(Some("3 \u05E9\u05D1\u05D5\u05E2\u05D5\u05EA"), pt.formatAge("2025-05-25", "2025-06-15"))
        assertEquals(Some("6 \u05D7\u05D5\u05D3\u05E9\u05D9\u05DD"), pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals(Some("3 \u05D7\u05D5\u05D3\u05E9\u05D9\u05DD"), pt.formatAge("2025-03-15", "2025-06-15"))
        assertEquals(Some("\u05E9\u05E0\u05EA\u05D9\u05D9\u05DD, \u05D7\u05D5\u05D3\u05E9 1"), pt.formatAge("2023-06-15", "2025-07-15"))
        assertEquals(Some("3 \u05E9\u05E0\u05D9\u05DD \u05D5\u05D7\u05E6\u05D9"), pt.formatAge("2022-06-15", "2025-12-15"))
        assertEquals(Some("7 \u05E9\u05E0\u05D9\u05DD"), pt.formatAge("2018-06-15", "2025-06-15"))
        assertEquals(Some("\u05E8\u05E7 \u05E0\u05D5\u05DC\u05D3"), pt.formatStage("2025-06-15", "2025-06-15", "m"))
        assertEquals(Some("\u05E8\u05E7 \u05E0\u05D5\u05DC\u05D3\u05D4"), pt.formatStage("2025-06-15", "2025-06-15", "f"))
        assertEquals(Some("\u05DE\u05D1\u05D5\u05D2\u05E8"), pt.formatStage("2007-06-15", "2025-06-15", "m"))
        assertEquals(Some("\u05DE\u05D1\u05D5\u05D2\u05E8\u05EA"), pt.formatStage("2007-06-15", "2025-06-15", "f"))

    // 29.15, 29.16, 29.17, 29.18, 29.19, 29.20, 29.21
    @Test
    def macedonianLocaleMod10Mod100Rule(): Unit =
        val pt = new SayableAge(Locales.MK)
        assertEquals(Some("\u041D\u043E\u0432\u043E\u0440\u043E\u0434\u0435\u043D\u0447\u0435"), pt.formatAge("2025-06-15", "2025-06-15"))
        assertEquals(Some("1 \u0434\u0435\u043D"), pt.formatAge("2025-06-14", "2025-06-15"))
        assertEquals(Some("3 \u0434\u0435\u043D\u0430"), pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals(Some("6 \u043C\u0435\u0441\u0435\u0446\u0438"), pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals(Some("2 \u0433\u043E\u0434\u0438\u043D\u0438, 1 \u043C\u0435\u0441\u0435\u0446"), pt.formatAge("2023-06-15", "2025-07-15"))
        assertEquals(Some("3 \u0433\u043E\u0434\u0438\u043D\u0438 \u0438 \u043F\u043E\u043B"), pt.formatAge("2022-06-15", "2025-12-15"))
        assertEquals(Some("7 \u0433\u043E\u0434\u0438\u043D\u0438"), pt.formatAge("2018-06-15", "2025-06-15"))

    // 29.22, 29.23, 29.24, 29.25, 29.26, 29.27
    @Test
    def swahiliLocaleNounClassChanges(): Unit =
        val pt = new SayableAge(Locales.SW)
        assertEquals(Some("Mzaliwa mpya"), pt.formatAge("2025-06-15", "2025-06-15"))
        assertEquals(Some("siku 1"), pt.formatAge("2025-06-14", "2025-06-15"))
        assertEquals(Some("siku 3"), pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals(Some("miezi 6"), pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals(Some("miaka 2, mwezi 1"), pt.formatAge("2023-06-15", "2025-07-15"))
        assertEquals(Some("miaka 3 na nusu"), pt.formatAge("2022-06-15", "2025-12-15"))

    // 29.28, 29.29, 29.30, 29.31, 29.32, 29.33
    @Test
    def indonesianLocaleOtherOnly(): Unit =
        val pt = new SayableAge(Locales.ID)
        assertEquals(Some("Baru lahir"), pt.formatAge("2025-06-15", "2025-06-15"))
        assertEquals(Some("1 hari"), pt.formatAge("2025-06-14", "2025-06-15"))
        assertEquals(Some("3 hari"), pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals(Some("6 bulan"), pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals(Some("3 tahun setengah"), pt.formatAge("2022-06-15", "2025-12-15"))
        assertEquals(Some("7 tahun"), pt.formatAge("2018-06-15", "2025-06-15"))

    // 29.34, 29.35, 29.36, 29.37, 29.38, 29.39
    @Test
    def amharicLocaleEthiopicDelimiter(): Unit =
        val pt = new SayableAge(Locales.AM)
        assertEquals(Some("\u12A0\u12F2\u1235 \u12E8\u1270\u12C8\u1208\u12F0"), pt.formatAge("2025-06-15", "2025-06-15"))
        assertEquals(Some("1 \u1240\u1295"), pt.formatAge("2025-06-14", "2025-06-15"))
        assertEquals(Some("3 \u1240\u1293\u1275"), pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals(Some("1 \u1233\u121D\u1295\u1275\u1363 1 \u1240\u1295"), pt.formatAge("2025-06-07", "2025-06-15"))
        assertEquals(Some("6 \u12C8\u122B\u1275"), pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals(Some("3 \u12D3\u1218\u1273\u1275 \u1270\u12A9\u120D"), pt.formatAge("2022-06-15", "2025-12-15"))

    // ================================================================
    // Section 30: Locale lookup by code string
    // ================================================================

    // 30.1
    @Test
    def getLocaleReturnsEnLocale(): Unit =
        val loc = Locales.get("en")
        assertTrue(loc.isDefined)
        assertEquals("en", loc.get.code)

    // 30.2
    @Test
    def getLocaleReturnsFrLocale(): Unit =
        val loc = Locales.get("fr")
        assertTrue(loc.isDefined)
        assertEquals("fr", loc.get.code)

    // 30.3
    @Test
    def getLocaleReturnsNoneForUnknownCode(): Unit =
        assertEquals(None, Locales.get("xx"))

    // 30.4
    @Test
    def getLocaleReturnsNoneForEmptyString(): Unit =
        assertEquals(None, Locales.get(""))

    // 30.5
    @Test
    def getLocaleIsCaseSensitive(): Unit =
        assertEquals(None, Locales.get("EN"))
