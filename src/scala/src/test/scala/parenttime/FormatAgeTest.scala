package parenttime

import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNotNull
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import java.time.LocalDate

class FormatAgeTest:

    @AfterEach
    def resetTimeNow(): Unit =
        timeNow = () => LocalDate.now()

    // ================================================================
    // formatAge -- null/edge cases
    // ================================================================
    @Test
    def emptyStringReturnsNone(): Unit =
        assertEquals(None, ParentTime.formatAge("", "2025-06-15"))

    @Test
    def futureDobReturnsNone(): Unit =
        assertEquals(None, ParentTime.formatAge("2025-07-01", "2025-06-15"))

    @Test
    def exactly500YearsIsAllowed(): Unit =
        assertEquals(Some("500 years"), ParentTime.formatAge("1525-06-15", "2025-06-15"))

    @Test
    def y501ExceedsMaxAge(): Unit =
        assertEquals(None, ParentTime.formatAge("1524-06-15", "2025-06-15"))

    @Test
    def y1000ExceedsMaxAge(): Unit =
        assertEquals(None, ParentTime.formatAge("1025-06-15", "2025-06-15"))

    // ================================================================
    // formatAge -- days tier (0-6)
    // ================================================================
    @Test
    def bornToday(): Unit =
        assertEquals(Some("Newborn"), ParentTime.formatAge("2025-06-15", "2025-06-15"))

    @Test
    def oneDayAgo(): Unit =
        assertEquals(Some("1 day"), ParentTime.formatAge("2025-06-14", "2025-06-15"))

    @Test
    def threeDaysAgo(): Unit =
        assertEquals(Some("3 days"), ParentTime.formatAge("2025-06-12", "2025-06-15"))

    @Test
    def sixDaysAgo(): Unit =
        assertEquals(Some("6 days"), ParentTime.formatAge("2025-06-09", "2025-06-15"))

    @Test
    def sevenDaysBecomes1Week(): Unit =
        assertEquals(Some("1 week"), ParentTime.formatAge("2025-06-08", "2025-06-15"))

    // ================================================================
    // formatAge -- weeks+days tier (7 days to less than 3 months)
    // ================================================================
    @Test
    def sevenDaysIs1Week(): Unit =
        assertEquals(Some("1 week"), ParentTime.formatAge("2025-06-08", "2025-06-15"))

    @Test
    def eightDaysIs1Week1Day(): Unit =
        assertEquals(Some("1 week, 1 day"), ParentTime.formatAge("2025-06-07", "2025-06-15"))

    @Test
    def nineDaysIs1Week2Days(): Unit =
        assertEquals(Some("1 week, 2 days"), ParentTime.formatAge("2025-06-06", "2025-06-15"))

    @Test
    def thirteenDaysIs1Week6Days(): Unit =
        assertEquals(Some("1 week, 6 days"), ParentTime.formatAge("2025-06-02", "2025-06-15"))

    @Test
    def fourteenDaysIs2Weeks(): Unit =
        assertEquals(Some("2 weeks"), ParentTime.formatAge("2025-06-01", "2025-06-15"))

    @Test
    def fifteenDaysIs2Weeks1Day(): Unit =
        assertEquals(Some("2 weeks, 1 day"), ParentTime.formatAge("2025-05-31", "2025-06-15"))

    @Test
    def twentyDaysIs2Weeks6Days(): Unit =
        assertEquals(Some("2 weeks, 6 days"), ParentTime.formatAge("2025-05-26", "2025-06-15"))

    @Test
    def twentyOneDaysIs3Weeks(): Unit =
        assertEquals(Some("3 weeks"), ParentTime.formatAge("2025-05-25", "2025-06-15"))

    @Test
    def at1CalMonthStillWeeksDays(): Unit =
        assertEquals(Some("4 weeks, 3 days"), ParentTime.formatAge("2025-05-15", "2025-06-15"))

    @Test
    def at2CalMonthsStillWeeksDays(): Unit =
        assertEquals(Some("8 weeks, 5 days"), ParentTime.formatAge("2025-04-15", "2025-06-15"))

    @Test
    def oneDayBefore3moStillWeeks(): Unit =
        assertEquals(Some("13 weeks"), ParentTime.formatAge("2025-03-15", "2025-06-14"))

    @Test
    def on3moBirthdaySwitches(): Unit =
        assertEquals(Some("3 months"), ParentTime.formatAge("2025-03-15", "2025-06-15"))

    // ================================================================
    // formatAge -- month boundaries: standard months
    // ================================================================
    @Test
    def jan1ToApr1Is3mo(): Unit =
        assertEquals(Some("3 months"), ParentTime.formatAge("2025-01-01", "2025-04-01"))

    @Test
    def jan1ToMar31StillWeeks(): Unit =
        val result = ParentTime.formatAge("2025-01-01", "2025-03-31")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    @Test
    def jun15ToSep15Is3mo(): Unit =
        assertEquals(Some("3 months"), ParentTime.formatAge("2025-06-15", "2025-09-15"))

    @Test
    def jun15ToSep14StillWeeks(): Unit =
        val result = ParentTime.formatAge("2025-06-15", "2025-09-14")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    @Test
    def jun15ToDec15Is6mo(): Unit =
        assertEquals(Some("6 months"), ParentTime.formatAge("2025-06-15", "2025-12-15"))

    // ================================================================
    // formatAge -- month boundaries: February non-leap
    // ================================================================
    @Test
    def jan31ToFeb28NonLeap(): Unit =
        assertEquals(Some("4 weeks"), ParentTime.formatAge("2025-01-31", "2025-02-28"))

    @Test
    def jan31ToApr30Is3moClamp(): Unit =
        assertEquals(Some("3 months"), ParentTime.formatAge("2025-01-31", "2025-04-30"))

    @Test
    def jan31ToApr29StillWeeks(): Unit =
        val result = ParentTime.formatAge("2025-01-31", "2025-04-29")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    @Test
    def feb1ToMay1Is3mo(): Unit =
        assertEquals(Some("3 months"), ParentTime.formatAge("2025-02-01", "2025-05-01"))

    @Test
    def feb1ToApr30StillWeeks(): Unit =
        val result = ParentTime.formatAge("2025-02-01", "2025-04-30")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    // ================================================================
    // formatAge -- month boundaries: February leap year
    // ================================================================
    @Test
    def jan31ToFeb29Leap(): Unit =
        assertEquals(Some("4 weeks, 1 day"), ParentTime.formatAge("2024-01-31", "2024-02-29"))

    @Test
    def jan31ToFeb28Leap(): Unit =
        assertEquals(Some("4 weeks"), ParentTime.formatAge("2024-01-31", "2024-02-28"))

    @Test
    def jan31ToApr30LeapIs3mo(): Unit =
        assertEquals(Some("3 months"), ParentTime.formatAge("2024-01-31", "2024-04-30"))

    @Test
    def jan30ToFeb29LeapStillWeeks(): Unit =
        val result = ParentTime.formatAge("2024-01-30", "2024-02-29")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    @Test
    def jan30ToFeb28LeapStillWeeks(): Unit =
        val result = ParentTime.formatAge("2024-01-30", "2024-02-28")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    // ================================================================
    // formatAge -- month boundaries: 30-day months
    // ================================================================
    @Test
    def mar31ToJun30Is3moClamped(): Unit =
        assertEquals(Some("3 months"), ParentTime.formatAge("2025-03-31", "2025-06-30"))

    @Test
    def mar31ToJun29StillWeeks(): Unit =
        val result = ParentTime.formatAge("2025-03-31", "2025-06-29")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    @Test
    def aug31ToNov30Is3mo(): Unit =
        assertEquals(Some("3 months"), ParentTime.formatAge("2025-08-31", "2025-11-30"))

    @Test
    def aug31ToNov29StillWeeks(): Unit =
        val result = ParentTime.formatAge("2025-08-31", "2025-11-29")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    // ================================================================
    // formatAge -- month boundaries: leap year baby (born Feb 29)
    // ================================================================
    @Test
    def feb29ToMay29Is3mo(): Unit =
        assertEquals(Some("3 months"), ParentTime.formatAge("2024-02-29", "2024-05-29"))

    @Test
    def feb29ToMay28StillWeeks(): Unit =
        val result = ParentTime.formatAge("2024-02-29", "2024-05-28")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    @Test
    def feb29_2024ToFeb28_2025Is12mo(): Unit =
        assertEquals(Some("12 months"), ParentTime.formatAge("2024-02-29", "2025-02-28"))

    @Test
    def feb29_2024ToMar1_2025Is12mo(): Unit =
        assertEquals(Some("12 months"), ParentTime.formatAge("2024-02-29", "2025-03-01"))

    // ================================================================
    // formatAge -- months tier (3-23)
    // ================================================================
    @Test
    def threeMonthsAtTransition(): Unit =
        assertEquals(Some("3 months"), ParentTime.formatAge("2025-01-15", "2025-04-15"))

    @Test
    def sixMonths(): Unit =
        assertEquals(Some("6 months"), ParentTime.formatAge("2025-01-15", "2025-07-15"))

    @Test
    def twelveMonthsNot1Year(): Unit =
        assertEquals(Some("12 months"), ParentTime.formatAge("2024-06-15", "2025-06-15"))

    @Test
    def twentyThreeMonthsAtUpper(): Unit =
        assertEquals(Some("23 months"), ParentTime.formatAge("2024-01-15", "2025-12-15"))

    @Test
    def oneDayBeforeBoundary(): Unit =
        assertEquals(Some("5 months"), ParentTime.formatAge("2025-01-15", "2025-07-14"))

    @Test
    def crossingYearBoundary(): Unit =
        assertEquals(Some("5 months"), ParentTime.formatAge("2024-11-10", "2025-04-10"))

    // ================================================================
    // formatAge -- years+months tier (24-35 months)
    // ================================================================
    @Test
    def twoYearsAt24mo(): Unit =
        assertEquals(Some("2 years"), ParentTime.formatAge("2023-06-15", "2025-06-15"))

    @Test
    def twoYears1Month(): Unit =
        assertEquals(Some("2 years, 1 month"), ParentTime.formatAge("2023-06-15", "2025-07-15"))

    @Test
    def twoYears6Months(): Unit =
        assertEquals(Some("2 years, 6 months"), ParentTime.formatAge("2023-06-15", "2025-12-15"))

    @Test
    def twoYears11Months(): Unit =
        assertEquals(Some("2 years, 11 months"), ParentTime.formatAge("2023-06-15", "2026-05-15"))

    @Test
    def oneDayBefore24mo(): Unit =
        assertEquals(Some("23 months"), ParentTime.formatAge("2023-06-15", "2025-06-14"))

    // ================================================================
    // formatAge -- half-year tier (3-6 years)
    // ================================================================
    @Test
    def threeYearsExactly(): Unit =
        assertEquals(Some("3 years"), ParentTime.formatAge("2022-06-15", "2025-06-15"))

    @Test
    def threeYears5Months(): Unit =
        assertEquals(Some("3 years"), ParentTime.formatAge("2022-06-15", "2025-11-15"))

    @Test
    def threeAndHalfYearsAt3y6m(): Unit =
        assertEquals(Some("3\u00BD years"), ParentTime.formatAge("2022-06-15", "2025-12-15"))

    @Test
    def threeAndHalfYearsAt3y11m(): Unit =
        assertEquals(Some("3\u00BD years"), ParentTime.formatAge("2022-06-15", "2026-05-15"))

    @Test
    def fourYearsExactly(): Unit =
        assertEquals(Some("4 years"), ParentTime.formatAge("2021-06-15", "2025-06-15"))

    @Test
    def fourAndHalfYears(): Unit =
        assertEquals(Some("4\u00BD years"), ParentTime.formatAge("2021-06-15", "2025-12-15"))

    @Test
    def fiveYears(): Unit =
        assertEquals(Some("5 years"), ParentTime.formatAge("2020-06-15", "2025-06-15"))

    @Test
    def fiveAndHalfYearsAt5y8m(): Unit =
        assertEquals(Some("5\u00BD years"), ParentTime.formatAge("2020-06-15", "2026-02-15"))

    @Test
    def sixYears(): Unit =
        assertEquals(Some("6 years"), ParentTime.formatAge("2019-06-15", "2025-06-15"))

    @Test
    def sixAndHalfYears(): Unit =
        assertEquals(Some("6\u00BD years"), ParentTime.formatAge("2019-06-15", "2025-12-15"))

    @Test
    def sixAndHalfYearsAt6y11m(): Unit =
        assertEquals(Some("6\u00BD years"), ParentTime.formatAge("2019-06-15", "2026-05-15"))

    @Test
    def oneDayBefore3rdBday(): Unit =
        assertEquals(Some("2 years, 11 months"), ParentTime.formatAge("2022-06-15", "2025-06-14"))

    // ================================================================
    // formatAge -- integer tier (7+ years)
    // ================================================================
    @Test
    def sevenYearsExactly(): Unit =
        assertEquals(Some("7 years"), ParentTime.formatAge("2018-06-15", "2025-06-15"))

    @Test
    def sevenYears6MonthsNoHalf(): Unit =
        assertEquals(Some("7 years"), ParentTime.formatAge("2018-03-20", "2025-06-15"))

    @Test
    def fortyFiveYears(): Unit =
        assertEquals(Some("45 years"), ParentTime.formatAge("1980-01-01", "2025-06-15"))

    // ================================================================
    // formatAge -- cross-year transitions with Feb
    // ================================================================
    @Test
    def dec31ToMar31Is3mo(): Unit =
        assertEquals(Some("3 months"), ParentTime.formatAge("2024-12-31", "2025-03-31"))

    @Test
    def dec31ToMar30StillWeeks(): Unit =
        val result = ParentTime.formatAge("2024-12-31", "2025-03-30")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    @Test
    def nov30ToFeb28Is3mo(): Unit =
        assertEquals(Some("3 months"), ParentTime.formatAge("2024-11-30", "2025-02-28"))

    @Test
    def nov30ToFeb27StillWeeks(): Unit =
        val result = ParentTime.formatAge("2024-11-30", "2025-02-27")
        assertNotNull(result)
        assertTrue(result.get.contains("weeks"))

    // ================================================================
    // formatAge -- born-on-31st progression
    // ================================================================
    @Test
    def jan31ToApr30Is3mo(): Unit =
        assertEquals(Some("3 months"), ParentTime.formatAge("2025-01-31", "2025-04-30"))

    @Test
    def jan31ToMay31Is4mo(): Unit =
        assertEquals(Some("4 months"), ParentTime.formatAge("2025-01-31", "2025-05-31"))

    @Test
    def jan31ToJun30Is5moClamped(): Unit =
        assertEquals(Some("5 months"), ParentTime.formatAge("2025-01-31", "2025-06-30"))

    @Test
    def jan31ToJul1Is5mo(): Unit =
        assertEquals(Some("5 months"), ParentTime.formatAge("2025-01-31", "2025-07-01"))

    @Test
    def jan31ToJul31Is6mo(): Unit =
        assertEquals(Some("6 months"), ParentTime.formatAge("2025-01-31", "2025-07-31"))

    // ================================================================
    // formatAge -- default asOf (uses current date)
    // ================================================================
    @Test
    def defaultAsOfUsesMockedToday(): Unit =
        timeNow = () => LocalDate.of(2025, 6, 15)
        assertEquals(Some("5 years"), ParentTime.formatAge("2020-01-01"))
        assertEquals(Some("5 days"), ParentTime.formatAge("2025-06-10"))

    // ================================================================
    // formatStage -- null/edge cases
    // ================================================================
    @Test
    def stageEmptyStringReturnsNone(): Unit =
        assertEquals(None, ParentTime.formatStage("", "2025-06-15"))

    @Test
    def stageFutureDobReturnsNone(): Unit =
        assertEquals(None, ParentTime.formatStage("2025-07-01", "2025-06-15"))

    @Test
    def stageExactly500YearsReturnsAdult(): Unit =
        assertEquals(Some("Adult"), ParentTime.formatStage("1525-06-15", "2025-06-15"))

    @Test
    def stage501YearsExceedsMaxAge(): Unit =
        assertEquals(None, ParentTime.formatStage("1524-06-15", "2025-06-15"))

    // ================================================================
    // formatStage -- newborn
    // ================================================================
    @Test
    def stageBornToday(): Unit =
        assertEquals(Some("Newborn"), ParentTime.formatStage("2025-06-15", "2025-06-15"))

    @Test
    def stage1DayOld(): Unit =
        assertEquals(Some("Newborn"), ParentTime.formatStage("2025-06-14", "2025-06-15"))

    @Test
    def stage3WeeksOld(): Unit =
        assertEquals(Some("Newborn"), ParentTime.formatStage("2025-05-25", "2025-06-15"))

    @Test
    def stage1MonthOld(): Unit =
        assertEquals(Some("Newborn"), ParentTime.formatStage("2025-05-15", "2025-06-15"))

    @Test
    def stage1Month29Days(): Unit =
        assertEquals(Some("Newborn"), ParentTime.formatStage("2025-04-16", "2025-06-15"))

    @Test
    def stageExactly2MonthsBecomesInfant(): Unit =
        assertEquals(Some("Infant"), ParentTime.formatStage("2025-04-15", "2025-06-15"))

    // ================================================================
    // formatStage -- infant
    // ================================================================
    @Test
    def stage2Months(): Unit =
        assertEquals(Some("Infant"), ParentTime.formatStage("2025-04-15", "2025-06-15"))

    @Test
    def stage6Months(): Unit =
        assertEquals(Some("Infant"), ParentTime.formatStage("2024-12-15", "2025-06-15"))

    @Test
    def stage11Months(): Unit =
        assertEquals(Some("Infant"), ParentTime.formatStage("2024-07-15", "2025-06-15"))

    @Test
    def stageExactly12moBecomesToddler(): Unit =
        assertEquals(Some("Toddler"), ParentTime.formatStage("2024-06-15", "2025-06-15"))

    // ================================================================
    // formatStage -- toddler
    // ================================================================
    @Test
    def stage12Months(): Unit =
        assertEquals(Some("Toddler"), ParentTime.formatStage("2024-06-15", "2025-06-15"))

    @Test
    def stage18Months(): Unit =
        assertEquals(Some("Toddler"), ParentTime.formatStage("2024-01-15", "2025-07-15"))

    @Test
    def stage24Months(): Unit =
        assertEquals(Some("Toddler"), ParentTime.formatStage("2023-06-15", "2025-06-15"))

    @Test
    def stage35Months(): Unit =
        assertEquals(Some("Toddler"), ParentTime.formatStage("2023-06-15", "2026-05-15"))

    @Test
    def stageExactly36moBecomesChild(): Unit =
        assertEquals(Some("Child"), ParentTime.formatStage("2022-06-15", "2025-06-15"))

    // ================================================================
    // formatStage -- child
    // ================================================================
    @Test
    def stage3Years(): Unit =
        assertEquals(Some("Child"), ParentTime.formatStage("2022-06-15", "2025-06-15"))

    @Test
    def stage4Years(): Unit =
        assertEquals(Some("Child"), ParentTime.formatStage("2021-06-15", "2025-06-15"))

    @Test
    def stage6YearsChild(): Unit =
        assertEquals(Some("Child"), ParentTime.formatStage("2019-06-15", "2025-06-15"))

    @Test
    def stage9Years(): Unit =
        assertEquals(Some("Child"), ParentTime.formatStage("2016-06-15", "2025-06-15"))

    @Test
    def stage12y11mo(): Unit =
        assertEquals(Some("Child"), ParentTime.formatStage("2013-06-15", "2026-05-15"))

    @Test
    def stageExactly13yBecomesTeenager(): Unit =
        assertEquals(Some("Teenager"), ParentTime.formatStage("2012-06-15", "2025-06-15"))

    // ================================================================
    // formatStage -- teenager
    // ================================================================
    @Test
    def stage13Years(): Unit =
        assertEquals(Some("Teenager"), ParentTime.formatStage("2012-06-15", "2025-06-15"))

    @Test
    def stage15Years(): Unit =
        assertEquals(Some("Teenager"), ParentTime.formatStage("2010-06-15", "2025-06-15"))

    @Test
    def stage17y11mo(): Unit =
        assertEquals(Some("Teenager"), ParentTime.formatStage("2008-06-15", "2026-05-15"))

    @Test
    def stageExactly18yBecomesAdult(): Unit =
        assertEquals(Some("Adult"), ParentTime.formatStage("2007-06-15", "2025-06-15"))

    // ================================================================
    // formatStage -- adult
    // ================================================================
    @Test
    def stage18Years(): Unit =
        assertEquals(Some("Adult"), ParentTime.formatStage("2007-06-15", "2025-06-15"))

    @Test
    def stage25Years(): Unit =
        assertEquals(Some("Adult"), ParentTime.formatStage("2000-06-15", "2025-06-15"))

    @Test
    def stage45Years(): Unit =
        assertEquals(Some("Adult"), ParentTime.formatStage("1980-01-01", "2025-06-15"))

    // ================================================================
    // formatStage -- default asOf
    // ================================================================
    @Test
    def stageDefaultAsOf(): Unit =
        timeNow = () => LocalDate.of(2025, 6, 15)
        assertEquals(Some("Newborn"), ParentTime.formatStage("2025-06-15"))
        assertEquals(Some("Child"), ParentTime.formatStage("2020-01-01"))
        assertEquals(Some("Adult"), ParentTime.formatStage("1980-01-01"))

    // ================================================================
    // ParentTime class with English locale
    // ================================================================
    @Test
    def parentTimeEnglishAllTiers(): Unit =
        val pt = new ParentTime(Locales.EN)
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
    // ParentTime with Spanish locale
    // ================================================================
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

        val pt = new ParentTime(es)

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
    @Test
    def compactShort(): Unit =
        val pt = new ParentTime(Locales.EN, Compactness.SHORT)

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
    @Test
    def compactCompact(): Unit =
        val pt = new ParentTime(Locales.EN, Compactness.COMPACT)

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
            val pt = new ParentTime(locale)

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
        val pt = new ParentTime(Locales.ES)
        assertEquals(Some("Reci\u00E9n nacido"), pt.formatStage("2025-06-15", "2025-06-15"))
        assertEquals(Some("Ni\u00F1o peque\u00F1o"), pt.formatStage("2024-06-15", "2025-06-15"))
        assertEquals(Some("Ni\u00F1o"), pt.formatStage("2022-06-15", "2025-06-15"))
        assertEquals(Some("Adulto"), pt.formatStage("2007-06-15", "2025-06-15"))

    @Test
    def genderMReturnsMasculine(): Unit =
        val pt = new ParentTime(Locales.ES)
        assertEquals(Some("Reci\u00E9n nacido"), pt.formatStage("2025-06-15", "2025-06-15", "m"))
        assertEquals(Some("Ni\u00F1o peque\u00F1o"), pt.formatStage("2024-06-15", "2025-06-15", "m"))
        assertEquals(Some("Ni\u00F1o"), pt.formatStage("2022-06-15", "2025-06-15", "m"))
        assertEquals(Some("Adulto"), pt.formatStage("2007-06-15", "2025-06-15", "m"))

    @Test
    def genderFReturnsFeminine(): Unit =
        val pt = new ParentTime(Locales.ES)
        assertEquals(Some("Reci\u00E9n nacida"), pt.formatStage("2025-06-15", "2025-06-15", "f"))
        assertEquals(Some("Ni\u00F1a peque\u00F1a"), pt.formatStage("2024-06-15", "2025-06-15", "f"))
        assertEquals(Some("Ni\u00F1a"), pt.formatStage("2022-06-15", "2025-06-15", "f"))
        assertEquals(Some("Adulta"), pt.formatStage("2007-06-15", "2025-06-15", "f"))

    @Test
    def genderNeutralStagesUnaffectedByGender(): Unit =
        val pt = new ParentTime(Locales.ES)
        assertEquals(Some("Beb\u00E9"), pt.formatStage("2025-01-15", "2025-06-15", "f"))
        assertEquals(Some("Beb\u00E9"), pt.formatStage("2025-01-15", "2025-06-15", "m"))
        assertEquals(Some("Adolescente"), pt.formatStage("2012-06-15", "2025-06-15", "f"))
        assertEquals(Some("Adolescente"), pt.formatStage("2012-06-15", "2025-06-15", "m"))

    @Test
    def genderHasNoEffectOnNeutralLocales(): Unit =
        val pt = new ParentTime(Locales.EN)
        assertEquals(Some("Newborn"), pt.formatStage("2025-06-15", "2025-06-15", "f"))
        assertEquals(Some("Newborn"), pt.formatStage("2025-06-15", "2025-06-15", "m"))
        assertEquals(Some("Adult"), pt.formatStage("2007-06-15", "2025-06-15", "f"))
        assertEquals(Some("Adult"), pt.formatStage("2007-06-15", "2025-06-15", "m"))

    @Test
    def genderFrenchStages(): Unit =
        val pt = new ParentTime(Locales.FR)
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
        val pt = new ParentTime(Locales.IT)
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
        val pt = new ParentTime(Locales.AR)
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
        val pt = new ParentTime(Locales.DE)
        assertEquals(Some("Erwachsener"), pt.formatStage("2007-06-15", "2025-06-15", "m"))
        assertEquals(Some("Erwachsene"), pt.formatStage("2007-06-15", "2025-06-15", "f"))
        assertEquals(Some("Neugeborenes"), pt.formatStage("2025-06-15", "2025-06-15", "f"))

    @Test
    def genderCompanionMethod(): Unit =
        assertEquals(Some("Newborn"), ParentTime.formatStage("2025-06-15", "2025-06-15", "f"))
        assertEquals(Some("Adult"), ParentTime.formatStage("2007-06-15", "2025-06-15", "f"))

    // ================================================================
    // Section 29: Locale-specific edge cases — new plural rules
    // ================================================================

    @Test
    def hebrewLocaleDualForms(): Unit =
        val pt = new ParentTime(Locales.HE)
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

    @Test
    def macedonianLocaleMod10Mod100Rule(): Unit =
        val pt = new ParentTime(Locales.MK)
        assertEquals(Some("\u041D\u043E\u0432\u043E\u0440\u043E\u0434\u0435\u043D\u0447\u0435"), pt.formatAge("2025-06-15", "2025-06-15"))
        assertEquals(Some("1 \u0434\u0435\u043D"), pt.formatAge("2025-06-14", "2025-06-15"))
        assertEquals(Some("3 \u0434\u0435\u043D\u0430"), pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals(Some("6 \u043C\u0435\u0441\u0435\u0446\u0438"), pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals(Some("2 \u0433\u043E\u0434\u0438\u043D\u0438, 1 \u043C\u0435\u0441\u0435\u0446"), pt.formatAge("2023-06-15", "2025-07-15"))
        assertEquals(Some("3 \u0433\u043E\u0434\u0438\u043D\u0438 \u0438 \u043F\u043E\u043B"), pt.formatAge("2022-06-15", "2025-12-15"))
        assertEquals(Some("7 \u0433\u043E\u0434\u0438\u043D\u0438"), pt.formatAge("2018-06-15", "2025-06-15"))

    @Test
    def swahiliLocaleNounClassChanges(): Unit =
        val pt = new ParentTime(Locales.SW)
        assertEquals(Some("Mzaliwa mpya"), pt.formatAge("2025-06-15", "2025-06-15"))
        assertEquals(Some("siku 1"), pt.formatAge("2025-06-14", "2025-06-15"))
        assertEquals(Some("siku 3"), pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals(Some("miezi 6"), pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals(Some("miaka 2, mwezi 1"), pt.formatAge("2023-06-15", "2025-07-15"))
        assertEquals(Some("miaka 3 na nusu"), pt.formatAge("2022-06-15", "2025-12-15"))

    @Test
    def indonesianLocaleOtherOnly(): Unit =
        val pt = new ParentTime(Locales.ID)
        assertEquals(Some("Baru lahir"), pt.formatAge("2025-06-15", "2025-06-15"))
        assertEquals(Some("1 hari"), pt.formatAge("2025-06-14", "2025-06-15"))
        assertEquals(Some("3 hari"), pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals(Some("6 bulan"), pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals(Some("3 tahun setengah"), pt.formatAge("2022-06-15", "2025-12-15"))
        assertEquals(Some("7 tahun"), pt.formatAge("2018-06-15", "2025-06-15"))

    @Test
    def amharicLocaleEthiopicDelimiter(): Unit =
        val pt = new ParentTime(Locales.AM)
        assertEquals(Some("\u12A0\u12F2\u1235 \u12E8\u1270\u12C8\u1208\u12F0"), pt.formatAge("2025-06-15", "2025-06-15"))
        assertEquals(Some("1 \u1240\u1295"), pt.formatAge("2025-06-14", "2025-06-15"))
        assertEquals(Some("3 \u1240\u1293\u1275"), pt.formatAge("2025-06-12", "2025-06-15"))
        assertEquals(Some("1 \u1233\u121D\u1295\u1275\u1363 1 \u1240\u1295"), pt.formatAge("2025-06-07", "2025-06-15"))
        assertEquals(Some("6 \u12C8\u122B\u1275"), pt.formatAge("2025-01-15", "2025-07-15"))
        assertEquals(Some("3 \u12D3\u1218\u1273\u1275 \u1270\u12A9\u120D"), pt.formatAge("2022-06-15", "2025-12-15"))

    // ================================================================
    // Section 30: Locale lookup by code string
    // ================================================================

    @Test
    def getLocaleReturnsEnLocale(): Unit =
        val loc = Locales.get("en")
        assertTrue(loc.isDefined)
        assertEquals("en", loc.get.code)

    @Test
    def getLocaleReturnsFrLocale(): Unit =
        val loc = Locales.get("fr")
        assertTrue(loc.isDefined)
        assertEquals("fr", loc.get.code)

    @Test
    def getLocaleReturnsNoneForUnknownCode(): Unit =
        assertEquals(None, Locales.get("xx"))

    @Test
    def getLocaleReturnsNoneForEmptyString(): Unit =
        assertEquals(None, Locales.get(""))

    @Test
    def getLocaleIsCaseSensitive(): Unit =
        assertEquals(None, Locales.get("EN"))
