package sayableage;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.Map;

import sayableage.locales.Locales;

import static org.junit.jupiter.api.Assertions.*;

class FormatAgeTest {

    @AfterEach
    void resetTimeNow() {
        SayableAge.timeNow = LocalDate::now;
    }

    // ================================================================
    // formatAge -- null/edge cases
    // ================================================================
    // 1.1
    @Test void nullDateOfBirthReturnsNull() {
        assertNull(SayableAge.formatAgeDefault(null, "2025-06-15"));
    }

    // 1.3
    @Test void emptyStringReturnsNull() {
        assertNull(SayableAge.formatAgeDefault("", "2025-06-15"));
    }

    // 1.4
    @Test void futureDobReturnsNull() {
        assertNull(SayableAge.formatAgeDefault("2025-07-01", "2025-06-15"));
    }

    // 1.5
    @Test void exactly500YearsIsAllowed() {
        assertEquals("500 years", SayableAge.formatAgeDefault("1525-06-15", "2025-06-15"));
    }

    // 1.6
    @Test void years501ExceedsMaxAge() {
        assertNull(SayableAge.formatAgeDefault("1524-06-15", "2025-06-15"));
    }

    // 1.7
    @Test void years1000ExceedsMaxAge() {
        assertNull(SayableAge.formatAgeDefault("1025-06-15", "2025-06-15"));
    }

    // ================================================================
    // formatAge -- days tier (0-6)
    // ================================================================
    // 2.1
    @Test void bornToday() {
        assertEquals("Newborn", SayableAge.formatAgeDefault("2025-06-15", "2025-06-15"));
    }

    // 2.2
    @Test void oneDayAgo() {
        assertEquals("1 day", SayableAge.formatAgeDefault("2025-06-14", "2025-06-15"));
    }

    // 2.3
    @Test void threeDaysAgo() {
        assertEquals("3 days", SayableAge.formatAgeDefault("2025-06-12", "2025-06-15"));
    }

    // 2.4
    @Test void sixDaysAgo() {
        assertEquals("6 days", SayableAge.formatAgeDefault("2025-06-09", "2025-06-15"));
    }

    // 2.5
    @Test void sevenDaysBecomesOneWeek() {
        assertEquals("1 week", SayableAge.formatAgeDefault("2025-06-08", "2025-06-15"));
    }

    // ================================================================
    // formatAge -- weeks+days tier (7 days to less than 3 months)
    // ================================================================
    // 3.1
    @Test void sevenDaysIsOneWeek() {
        assertEquals("1 week", SayableAge.formatAgeDefault("2025-06-08", "2025-06-15"));
    }

    // 3.2
    @Test void eightDaysIsOneWeekOneDay() {
        assertEquals("1 week, 1 day", SayableAge.formatAgeDefault("2025-06-07", "2025-06-15"));
    }

    // 3.3
    @Test void nineDaysIsOneWeekTwoDays() {
        assertEquals("1 week, 2 days", SayableAge.formatAgeDefault("2025-06-06", "2025-06-15"));
    }

    // 3.4
    @Test void thirteenDaysIsOneWeekSixDays() {
        assertEquals("1 week, 6 days", SayableAge.formatAgeDefault("2025-06-02", "2025-06-15"));
    }

    // 3.5
    @Test void fourteenDaysIsTwoWeeks() {
        assertEquals("2 weeks", SayableAge.formatAgeDefault("2025-06-01", "2025-06-15"));
    }

    // 3.6
    @Test void fifteenDaysIsTwoWeeksOneDay() {
        assertEquals("2 weeks, 1 day", SayableAge.formatAgeDefault("2025-05-31", "2025-06-15"));
    }

    // 3.7
    @Test void twentyDaysIsTwoWeeksSixDays() {
        assertEquals("2 weeks, 6 days", SayableAge.formatAgeDefault("2025-05-26", "2025-06-15"));
    }

    // 3.8
    @Test void twentyOneDaysIsThreeWeeks() {
        assertEquals("3 weeks", SayableAge.formatAgeDefault("2025-05-25", "2025-06-15"));
    }

    // 3.9
    @Test void atOneCalMonthStillWeeksDays() {
        assertEquals("4 weeks, 3 days", SayableAge.formatAgeDefault("2025-05-15", "2025-06-15"));
    }

    // 3.10
    @Test void atTwoCalMonthsStillWeeksDays() {
        assertEquals("8 weeks, 5 days", SayableAge.formatAgeDefault("2025-04-15", "2025-06-15"));
    }

    // 3.11
    @Test void oneDayBefore3moStillWeeks() {
        assertEquals("13 weeks", SayableAge.formatAgeDefault("2025-03-15", "2025-06-14"));
    }

    // 3.12
    @Test void on3moBirthdaySwitches() {
        assertEquals("3 months", SayableAge.formatAgeDefault("2025-03-15", "2025-06-15"));
    }

    // ================================================================
    // formatAge -- month boundaries: standard months
    // ================================================================
    // 4.1
    @Test void jan1ToApr1Is3mo() {
        assertEquals("3 months", SayableAge.formatAgeDefault("2025-01-01", "2025-04-01"));
    }

    // 4.2
    @Test void jan1ToMar31StillWeeks() {
        String result = SayableAge.formatAgeDefault("2025-01-01", "2025-03-31");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // 4.3
    @Test void jun15ToSep15Is3mo() {
        assertEquals("3 months", SayableAge.formatAgeDefault("2025-06-15", "2025-09-15"));
    }

    // 4.4
    @Test void jun15ToSep14StillWeeks() {
        String result = SayableAge.formatAgeDefault("2025-06-15", "2025-09-14");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // 4.5
    @Test void jun15ToDec15Is6mo() {
        assertEquals("6 months", SayableAge.formatAgeDefault("2025-06-15", "2025-12-15"));
    }

    // ================================================================
    // formatAge -- month boundaries: February non-leap
    // ================================================================
    // 5.1
    @Test void jan31ToFeb28NonLeap() {
        assertEquals("4 weeks", SayableAge.formatAgeDefault("2025-01-31", "2025-02-28"));
    }

    // 5.2
    @Test void jan31ToApr30Is3moClamp() {
        assertEquals("3 months", SayableAge.formatAgeDefault("2025-01-31", "2025-04-30"));
    }

    // 5.3
    @Test void jan31ToApr29StillWeeks() {
        String result = SayableAge.formatAgeDefault("2025-01-31", "2025-04-29");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // 5.4
    @Test void feb1ToMay1Is3mo() {
        assertEquals("3 months", SayableAge.formatAgeDefault("2025-02-01", "2025-05-01"));
    }

    // 5.5
    @Test void feb1ToApr30StillWeeks() {
        String result = SayableAge.formatAgeDefault("2025-02-01", "2025-04-30");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // ================================================================
    // formatAge -- month boundaries: February leap year
    // ================================================================
    // 6.1
    @Test void jan31ToFeb29Leap() {
        assertEquals("4 weeks, 1 day", SayableAge.formatAgeDefault("2024-01-31", "2024-02-29"));
    }

    // 6.2
    @Test void jan31ToFeb28Leap() {
        assertEquals("4 weeks", SayableAge.formatAgeDefault("2024-01-31", "2024-02-28"));
    }

    // 6.3
    @Test void jan31ToApr30LeapIs3mo() {
        assertEquals("3 months", SayableAge.formatAgeDefault("2024-01-31", "2024-04-30"));
    }

    // 6.4
    @Test void jan30ToFeb29LeapStillWeeks() {
        String result = SayableAge.formatAgeDefault("2024-01-30", "2024-02-29");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // 6.5
    @Test void jan30ToFeb28LeapStillWeeks() {
        String result = SayableAge.formatAgeDefault("2024-01-30", "2024-02-28");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // ================================================================
    // formatAge -- month boundaries: 30-day months
    // ================================================================
    // 7.1
    @Test void mar31ToJun30Is3moClamped() {
        assertEquals("3 months", SayableAge.formatAgeDefault("2025-03-31", "2025-06-30"));
    }

    // 7.2
    @Test void mar31ToJun29StillWeeks() {
        String result = SayableAge.formatAgeDefault("2025-03-31", "2025-06-29");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // 7.3
    @Test void aug31ToNov30Is3mo() {
        assertEquals("3 months", SayableAge.formatAgeDefault("2025-08-31", "2025-11-30"));
    }

    // 7.4
    @Test void aug31ToNov29StillWeeks() {
        String result = SayableAge.formatAgeDefault("2025-08-31", "2025-11-29");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // ================================================================
    // formatAge -- month boundaries: leap year baby (born Feb 29)
    // ================================================================
    // 8.1
    @Test void feb29ToMay29Is3mo() {
        assertEquals("3 months", SayableAge.formatAgeDefault("2024-02-29", "2024-05-29"));
    }

    // 8.2
    @Test void feb29ToMay28StillWeeks() {
        String result = SayableAge.formatAgeDefault("2024-02-29", "2024-05-28");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // 8.3
    @Test void feb29_2024ToFeb28_2025Is12mo() {
        assertEquals("12 months", SayableAge.formatAgeDefault("2024-02-29", "2025-02-28"));
    }

    // 8.4
    @Test void feb29_2024ToMar1_2025Is12mo() {
        assertEquals("12 months", SayableAge.formatAgeDefault("2024-02-29", "2025-03-01"));
    }

    // ================================================================
    // formatAge -- months tier (3-23)
    // ================================================================
    // 9.1
    @Test void threeMonthsAtTransition() {
        assertEquals("3 months", SayableAge.formatAgeDefault("2025-01-15", "2025-04-15"));
    }

    // 9.2
    @Test void sixMonths() {
        assertEquals("6 months", SayableAge.formatAgeDefault("2025-01-15", "2025-07-15"));
    }

    // 9.3
    @Test void twelveMonthsNotOneYear() {
        assertEquals("12 months", SayableAge.formatAgeDefault("2024-06-15", "2025-06-15"));
    }

    // 9.4
    @Test void twentyThreeMonthsAtUpper() {
        assertEquals("23 months", SayableAge.formatAgeDefault("2024-01-15", "2025-12-15"));
    }

    // 9.5
    @Test void oneDayBeforeBoundary() {
        assertEquals("5 months", SayableAge.formatAgeDefault("2025-01-15", "2025-07-14"));
    }

    // 9.6
    @Test void crossingYearBoundary() {
        assertEquals("5 months", SayableAge.formatAgeDefault("2024-11-10", "2025-04-10"));
    }

    // ================================================================
    // formatAge -- years+months tier (24-35 months)
    // ================================================================
    // 10.1
    @Test void twoYearsAt24mo() {
        assertEquals("2 years", SayableAge.formatAgeDefault("2023-06-15", "2025-06-15"));
    }

    // 10.2
    @Test void twoYearsOneMonth() {
        assertEquals("2 years, 1 month", SayableAge.formatAgeDefault("2023-06-15", "2025-07-15"));
    }

    // 10.3
    @Test void twoYearsSixMonths() {
        assertEquals("2 years, 6 months", SayableAge.formatAgeDefault("2023-06-15", "2025-12-15"));
    }

    // 10.4
    @Test void twoYearsElevenMonths() {
        assertEquals("2 years, 11 months", SayableAge.formatAgeDefault("2023-06-15", "2026-05-15"));
    }

    // 10.5
    @Test void oneDayBefore24mo() {
        assertEquals("23 months", SayableAge.formatAgeDefault("2023-06-15", "2025-06-14"));
    }

    // ================================================================
    // formatAge -- half-year tier (3-6 years)
    // ================================================================
    // 11.1
    @Test void threeYearsExactly() {
        assertEquals("3 years", SayableAge.formatAgeDefault("2022-06-15", "2025-06-15"));
    }

    // 11.2
    @Test void threeYearsFiveMonths() {
        assertEquals("3 years", SayableAge.formatAgeDefault("2022-06-15", "2025-11-15"));
    }

    // 11.3
    @Test void threeAndHalfYearsAt3y6m() {
        assertEquals("3\u00BD years", SayableAge.formatAgeDefault("2022-06-15", "2025-12-15"));
    }

    // 11.4
    @Test void threeAndHalfYearsAt3y11m() {
        assertEquals("3\u00BD years", SayableAge.formatAgeDefault("2022-06-15", "2026-05-15"));
    }

    // 11.5
    @Test void fourYearsExactly() {
        assertEquals("4 years", SayableAge.formatAgeDefault("2021-06-15", "2025-06-15"));
    }

    // 11.6
    @Test void fourAndHalfYears() {
        assertEquals("4\u00BD years", SayableAge.formatAgeDefault("2021-06-15", "2025-12-15"));
    }

    // 11.7
    @Test void fiveYears() {
        assertEquals("5 years", SayableAge.formatAgeDefault("2020-06-15", "2025-06-15"));
    }

    // 11.8
    @Test void fiveAndHalfYearsAt5y8m() {
        assertEquals("5\u00BD years", SayableAge.formatAgeDefault("2020-06-15", "2026-02-15"));
    }

    // 11.9
    @Test void sixYears() {
        assertEquals("6 years", SayableAge.formatAgeDefault("2019-06-15", "2025-06-15"));
    }

    // 11.10
    @Test void sixAndHalfYears() {
        assertEquals("6\u00BD years", SayableAge.formatAgeDefault("2019-06-15", "2025-12-15"));
    }

    // 11.11
    @Test void sixAndHalfYearsAt6y11m() {
        assertEquals("6\u00BD years", SayableAge.formatAgeDefault("2019-06-15", "2026-05-15"));
    }

    // 11.12
    @Test void oneDayBefore3rdBday() {
        assertEquals("2 years, 11 months", SayableAge.formatAgeDefault("2022-06-15", "2025-06-14"));
    }

    // ================================================================
    // formatAge -- integer tier (7+ years)
    // ================================================================
    // 12.1
    @Test void sevenYearsExactly() {
        assertEquals("7 years", SayableAge.formatAgeDefault("2018-06-15", "2025-06-15"));
    }

    // 12.2
    @Test void sevenYearsSixMonthsNoHalf() {
        assertEquals("7 years", SayableAge.formatAgeDefault("2018-03-20", "2025-06-15"));
    }

    // 12.3
    @Test void fortyFiveYears() {
        assertEquals("45 years", SayableAge.formatAgeDefault("1980-01-01", "2025-06-15"));
    }

    // ================================================================
    // formatAge -- cross-year transitions with Feb
    // ================================================================
    // 13.1
    @Test void dec31ToMar31Is3mo() {
        assertEquals("3 months", SayableAge.formatAgeDefault("2024-12-31", "2025-03-31"));
    }

    // 13.2
    @Test void dec31ToMar30StillWeeks() {
        String result = SayableAge.formatAgeDefault("2024-12-31", "2025-03-30");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // 13.3
    @Test void nov30ToFeb28Is3mo() {
        assertEquals("3 months", SayableAge.formatAgeDefault("2024-11-30", "2025-02-28"));
    }

    // 13.4
    @Test void nov30ToFeb27StillWeeks() {
        String result = SayableAge.formatAgeDefault("2024-11-30", "2025-02-27");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // ================================================================
    // formatAge -- born-on-31st progression
    // ================================================================
    // 14.1
    @Test void jan31ToApr30Is3mo() {
        assertEquals("3 months", SayableAge.formatAgeDefault("2025-01-31", "2025-04-30"));
    }

    // 14.2
    @Test void jan31ToMay31Is4mo() {
        assertEquals("4 months", SayableAge.formatAgeDefault("2025-01-31", "2025-05-31"));
    }

    // 14.3
    @Test void jan31ToJun30Is5moClamped() {
        assertEquals("5 months", SayableAge.formatAgeDefault("2025-01-31", "2025-06-30"));
    }

    // 14.4
    @Test void jan31ToJul1Is5mo() {
        assertEquals("5 months", SayableAge.formatAgeDefault("2025-01-31", "2025-07-01"));
    }

    // 14.5
    @Test void jan31ToJul31Is6mo() {
        assertEquals("6 months", SayableAge.formatAgeDefault("2025-01-31", "2025-07-31"));
    }

    // ================================================================
    // formatAge -- default asOf (uses current date)
    // ================================================================
    // 15.1, 15.2
    @Test void defaultAsOfUsesMockedToday() {
        SayableAge.timeNow = () -> LocalDate.of(2025, 6, 15);
        assertEquals("5 years", SayableAge.formatAgeDefault("2020-01-01"));
        assertEquals("5 days", SayableAge.formatAgeDefault("2025-06-10"));
    }

    // ================================================================
    // formatStage -- null/edge cases
    // ================================================================
    // 16.1, 16.3
    @Test void stageEmptyStringReturnsNull() {
        assertNull(SayableAge.formatStageDefault("", "2025-06-15"));
    }

    // 16.4
    @Test void stageFutureDobReturnsNull() {
        assertNull(SayableAge.formatStageDefault("2025-07-01", "2025-06-15"));
    }

    // 16.5
    @Test void stageExactly500YearsReturnsAdult() {
        assertEquals("Adult", SayableAge.formatStageDefault("1525-06-15", "2025-06-15"));
    }

    // 16.6
    @Test void stage501YearsExceedsMaxAge() {
        assertNull(SayableAge.formatStageDefault("1524-06-15", "2025-06-15"));
    }

    // ================================================================
    // formatStage -- newborn
    // ================================================================
    // 17.1
    @Test void stageBornToday() {
        assertEquals("Newborn", SayableAge.formatStageDefault("2025-06-15", "2025-06-15"));
    }

    // 17.2
    @Test void stageOneDayOld() {
        assertEquals("Newborn", SayableAge.formatStageDefault("2025-06-14", "2025-06-15"));
    }

    // 17.3
    @Test void stageThreeWeeksOld() {
        assertEquals("Newborn", SayableAge.formatStageDefault("2025-05-25", "2025-06-15"));
    }

    // 17.4
    @Test void stageOneMonthOld() {
        assertEquals("Newborn", SayableAge.formatStageDefault("2025-05-15", "2025-06-15"));
    }

    // 17.5
    @Test void stageOneMonth29Days() {
        assertEquals("Newborn", SayableAge.formatStageDefault("2025-04-16", "2025-06-15"));
    }

    // 17.6
    @Test void stageExactly2MonthsBecomesInfant() {
        assertEquals("Infant", SayableAge.formatStageDefault("2025-04-15", "2025-06-15"));
    }

    // ================================================================
    // formatStage -- infant
    // ================================================================
    // 18.1
    @Test void stageTwoMonths() {
        assertEquals("Infant", SayableAge.formatStageDefault("2025-04-15", "2025-06-15"));
    }

    // 18.2
    @Test void stageSixMonths() {
        assertEquals("Infant", SayableAge.formatStageDefault("2024-12-15", "2025-06-15"));
    }

    // 18.3
    @Test void stageElevenMonths() {
        assertEquals("Infant", SayableAge.formatStageDefault("2024-07-15", "2025-06-15"));
    }

    // 18.4
    @Test void stageExactly12moBecomesToddler() {
        assertEquals("Toddler", SayableAge.formatStageDefault("2024-06-15", "2025-06-15"));
    }

    // ================================================================
    // formatStage -- toddler
    // ================================================================
    // 19.1
    @Test void stageTwelveMonths() {
        assertEquals("Toddler", SayableAge.formatStageDefault("2024-06-15", "2025-06-15"));
    }

    // 19.2
    @Test void stageEighteenMonths() {
        assertEquals("Toddler", SayableAge.formatStageDefault("2024-01-15", "2025-07-15"));
    }

    // 19.3
    @Test void stageTwentyFourMonths() {
        assertEquals("Toddler", SayableAge.formatStageDefault("2023-06-15", "2025-06-15"));
    }

    // 19.4
    @Test void stageThirtyFiveMonths() {
        assertEquals("Toddler", SayableAge.formatStageDefault("2023-06-15", "2026-05-15"));
    }

    // 19.5
    @Test void stageExactly36moBecomesChild() {
        assertEquals("Child", SayableAge.formatStageDefault("2022-06-15", "2025-06-15"));
    }

    // ================================================================
    // formatStage -- child
    // ================================================================
    // 20.1
    @Test void stageThreeYears() {
        assertEquals("Child", SayableAge.formatStageDefault("2022-06-15", "2025-06-15"));
    }

    // 20.2
    @Test void stageFourYears() {
        assertEquals("Child", SayableAge.formatStageDefault("2021-06-15", "2025-06-15"));
    }

    // 20.3
    @Test void stageSixYears() {
        assertEquals("Child", SayableAge.formatStageDefault("2019-06-15", "2025-06-15"));
    }

    // 20.4
    @Test void stageNineYears() {
        assertEquals("Child", SayableAge.formatStageDefault("2016-06-15", "2025-06-15"));
    }

    // 20.5
    @Test void stage12y11mo() {
        assertEquals("Child", SayableAge.formatStageDefault("2013-06-15", "2026-05-15"));
    }

    // 20.6
    @Test void stageExactly13yBecomesTeenager() {
        assertEquals("Teenager", SayableAge.formatStageDefault("2012-06-15", "2025-06-15"));
    }

    // ================================================================
    // formatStage -- teenager
    // ================================================================
    // 21.1
    @Test void stageThirteenYears() {
        assertEquals("Teenager", SayableAge.formatStageDefault("2012-06-15", "2025-06-15"));
    }

    // 21.2
    @Test void stageFifteenYears() {
        assertEquals("Teenager", SayableAge.formatStageDefault("2010-06-15", "2025-06-15"));
    }

    // 21.3
    @Test void stage17y11mo() {
        assertEquals("Teenager", SayableAge.formatStageDefault("2008-06-15", "2026-05-15"));
    }

    // 21.4
    @Test void stageExactly18yBecomesAdult() {
        assertEquals("Adult", SayableAge.formatStageDefault("2007-06-15", "2025-06-15"));
    }

    // ================================================================
    // formatStage -- adult
    // ================================================================
    // 22.1
    @Test void stageEighteenYears() {
        assertEquals("Adult", SayableAge.formatStageDefault("2007-06-15", "2025-06-15"));
    }

    // 22.2
    @Test void stageTwentyFiveYears() {
        assertEquals("Adult", SayableAge.formatStageDefault("2000-06-15", "2025-06-15"));
    }

    // 22.3
    @Test void stageFortyFiveYears() {
        assertEquals("Adult", SayableAge.formatStageDefault("1980-01-01", "2025-06-15"));
    }

    // ================================================================
    // formatStage -- default asOf
    // ================================================================
    // 23.1, 23.2, 23.3
    @Test void stageDefaultAsOf() {
        SayableAge.timeNow = () -> LocalDate.of(2025, 6, 15);
        assertEquals("Newborn", SayableAge.formatStageDefault("2025-06-15"));
        assertEquals("Child", SayableAge.formatStageDefault("2020-01-01"));
        assertEquals("Adult", SayableAge.formatStageDefault("1980-01-01"));
    }

    // ================================================================
    // SayableAge class with English locale
    // ================================================================
    // 24.1, 24.2, 24.3, 24.4, 24.5, 24.6, 24.7, 24.8, 24.9, 24.10, 24.11, 24.12, 24.13, 24.14, 24.15
    @Test void parentTimeEnglishAllTiers() {
        SayableAge pt = new SayableAge(Locales.EN);
        assertEquals("Newborn", pt.formatAge("2025-06-15", "2025-06-15"));
        assertEquals("3 days", pt.formatAge("2025-06-12", "2025-06-15"));
        assertEquals("1 week, 1 day", pt.formatAge("2025-06-07", "2025-06-15"));
        assertEquals("6 months", pt.formatAge("2025-01-15", "2025-07-15"));
        assertEquals("2 years, 1 month", pt.formatAge("2023-06-15", "2025-07-15"));
        assertEquals("3\u00BD years", pt.formatAge("2022-06-15", "2025-12-15"));
        assertEquals("7 years", pt.formatAge("2018-06-15", "2025-06-15"));

        assertEquals("Newborn", pt.formatStage("2025-06-15", "2025-06-15"));
        assertEquals("Infant", pt.formatStage("2025-01-15", "2025-06-15"));
        assertEquals("Toddler", pt.formatStage("2024-06-15", "2025-06-15"));
        assertEquals("Child", pt.formatStage("2022-06-15", "2025-06-15"));
        assertEquals("Teenager", pt.formatStage("2012-06-15", "2025-06-15"));
        assertEquals("Adult", pt.formatStage("2007-06-15", "2025-06-15"));

        assertNull(pt.formatAge(""));
        assertNull(pt.formatStage(""));
    }

    // ================================================================
    // SayableAge with Spanish locale
    // ================================================================
    // 25.1, 25.2, 25.3, 25.4, 25.5, 25.6, 25.7, 25.8, 25.9, 25.10, 25.11, 25.12, 25.13, 25.14, 25.15, 25.16, 25.17, 25.18, 25.19, 25.20
    @Test void parentTimeSpanishInlineLocale() {
        AgeLocale es = new AgeLocale(
            "es",
            n -> n == 1 ? PluralCategory.ONE : PluralCategory.OTHER,
            new Units(
                UnitForms.pluralUnit(Map.of(PluralCategory.ONE, "{n} d\u00EDa", PluralCategory.OTHER, "{n} d\u00EDas")),
                UnitForms.pluralUnit(Map.of(PluralCategory.ONE, "{n} semana", PluralCategory.OTHER, "{n} semanas")),
                UnitForms.pluralUnit(Map.of(PluralCategory.ONE, "{n} mes", PluralCategory.OTHER, "{n} meses")),
                UnitForms.pluralUnit(Map.of(PluralCategory.ONE, "{n} a\u00F1o", PluralCategory.OTHER, "{n} a\u00F1os"))
            ),
            "{0} y medio",
            ", ",
            "Reci\u00E9n nacido",
            new Stages(
                StageLabel.gendered("Reci\u00E9n nacido", "Reci\u00E9n nacida"),
                StageLabel.neutral("Beb\u00E9"),
                StageLabel.gendered("Ni\u00F1o peque\u00F1o", "Ni\u00F1a peque\u00F1a"),
                StageLabel.gendered("Ni\u00F1o", "Ni\u00F1a"),
                StageLabel.neutral("Adolescente"),
                StageLabel.gendered("Adulto", "Adulta")
            )
        );

        SayableAge pt = new SayableAge(es);

        assertEquals("Reci\u00E9n nacido", pt.formatAge("2025-06-15", "2025-06-15"));
        assertEquals("1 d\u00EDa", pt.formatAge("2025-06-14", "2025-06-15"));
        assertEquals("3 d\u00EDas", pt.formatAge("2025-06-12", "2025-06-15"));
        assertEquals("1 semana", pt.formatAge("2025-06-08", "2025-06-15"));
        assertEquals("1 semana, 1 d\u00EDa", pt.formatAge("2025-06-07", "2025-06-15"));
        assertEquals("2 semanas, 6 d\u00EDas", pt.formatAge("2025-05-26", "2025-06-15"));
        assertEquals("6 meses", pt.formatAge("2025-01-15", "2025-07-15"));
        assertEquals("2 a\u00F1os, 1 mes", pt.formatAge("2023-06-15", "2025-07-15"));
        assertEquals("2 a\u00F1os, 6 meses", pt.formatAge("2023-06-15", "2025-12-15"));
        assertEquals("3 a\u00F1os y medio", pt.formatAge("2022-06-15", "2025-12-15"));
        assertEquals("3 a\u00F1os", pt.formatAge("2022-06-15", "2025-06-15"));
        assertEquals("7 a\u00F1os", pt.formatAge("2018-06-15", "2025-06-15"));

        assertEquals("Reci\u00E9n nacido", pt.formatStage("2025-06-15", "2025-06-15"));
        assertEquals("Beb\u00E9", pt.formatStage("2025-01-15", "2025-06-15"));
        assertEquals("Ni\u00F1o peque\u00F1o", pt.formatStage("2024-06-15", "2025-06-15"));
        assertEquals("Ni\u00F1o", pt.formatStage("2022-06-15", "2025-06-15"));
        assertEquals("Adolescente", pt.formatStage("2012-06-15", "2025-06-15"));
        assertEquals("Adulto", pt.formatStage("2007-06-15", "2025-06-15"));

        assertNull(pt.formatAge(""));
        assertNull(pt.formatStage(""));
    }

    // ================================================================
    // Compactness: short
    // ================================================================
    // 26.1, 26.2, 26.3, 26.4, 26.5, 26.6, 26.7, 26.8, 26.9
    @Test void compactShort() {
        SayableAge pt = new SayableAge(Locales.EN, Compactness.SHORT);

        assertEquals("3 d", pt.formatAge("2025-06-12", "2025-06-15"));
        assertEquals("1 wk", pt.formatAge("2025-06-08", "2025-06-15"));
        assertEquals("1 wk, 1 d", pt.formatAge("2025-06-07", "2025-06-15"));
        assertEquals("6 mo", pt.formatAge("2025-01-15", "2025-07-15"));
        assertEquals("2 yr, 1 mo", pt.formatAge("2023-06-15", "2025-07-15"));
        assertEquals("3\u00BD yr", pt.formatAge("2022-06-15", "2025-12-15"));
        assertEquals("7 yr", pt.formatAge("2018-06-15", "2025-06-15"));
        assertEquals("Newborn", pt.formatAge("2025-06-15", "2025-06-15"));
        assertEquals("Infant", pt.formatStage("2025-01-15", "2025-06-15"));
    }

    // ================================================================
    // Compactness: compact
    // ================================================================
    // 27.1, 27.2, 27.3, 27.4, 27.5, 27.6, 27.7, 27.8
    @Test void compactCompact() {
        SayableAge pt = new SayableAge(Locales.EN, Compactness.COMPACT);

        assertEquals("3d", pt.formatAge("2025-06-12", "2025-06-15"));
        assertEquals("1w", pt.formatAge("2025-06-08", "2025-06-15"));
        assertEquals("1w1d", pt.formatAge("2025-06-07", "2025-06-15"));
        assertEquals("6m", pt.formatAge("2025-01-15", "2025-07-15"));
        assertEquals("2y1m", pt.formatAge("2023-06-15", "2025-07-15"));
        assertEquals("3\u00BDy", pt.formatAge("2022-06-15", "2025-12-15"));
        assertEquals("7y", pt.formatAge("2018-06-15", "2025-06-15"));
        assertEquals("Newborn", pt.formatAge("2025-06-15", "2025-06-15"));
    }

    // ================================================================
    // All 168 locales exist and have correct codes
    // ================================================================
    @Test void all168LocalesExist() {
        assertEquals(168, Locales.ALL.size());
        String[] expectedCodes = {
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
        };
        for (String code : expectedCodes) {
            AgeLocale locale = Locales.ALL.get(code);
            assertNotNull(locale, "Locale " + code + " should exist");
            assertEquals(code, locale.code(), "Locale code should match key");
        }
    }

    // ================================================================
    // Smoke test each locale produces non-null output
    // ================================================================
    @Test void allLocalesProduceOutputForBasicCases() {
        for (var entry : Locales.ALL.entrySet()) {
            String code = entry.getKey();
            AgeLocale locale = entry.getValue();
            SayableAge pt = new SayableAge(locale);

            String justBorn = pt.formatAge("2025-06-15", "2025-06-15");
            assertNotNull(justBorn, code + ": justBorn should not be null");
            assertFalse(justBorn.isEmpty(), code + ": justBorn should not be empty");

            assertNotNull(pt.formatAge("2025-06-12", "2025-06-15"), code + ": days should not be null");
            assertNotNull(pt.formatAge("2025-06-07", "2025-06-15"), code + ": weeks should not be null");
            assertNotNull(pt.formatAge("2025-01-15", "2025-07-15"), code + ": months should not be null");
            assertNotNull(pt.formatAge("2023-06-15", "2025-07-15"), code + ": years+months should not be null");
            assertNotNull(pt.formatAge("2022-06-15", "2025-12-15"), code + ": half-year should not be null");
            assertNotNull(pt.formatAge("2018-06-15", "2025-06-15"), code + ": integer years should not be null");
            assertNotNull(pt.formatStage("2020-01-01", "2025-06-15"), code + ": stage should not be null");
        }
    }

    // ================================================================
    // formatStage -- gender support
    // ================================================================
    @Test void genderNullDefaultsToMasculineForGenderedLocales() {
        SayableAge pt = new SayableAge(Locales.ES);
        assertEquals("Reci\u00E9n nacido", pt.formatStage("2025-06-15", "2025-06-15"));
        assertEquals("Ni\u00F1o peque\u00F1o", pt.formatStage("2024-06-15", "2025-06-15"));
        assertEquals("Ni\u00F1o", pt.formatStage("2022-06-15", "2025-06-15"));
        assertEquals("Adulto", pt.formatStage("2007-06-15", "2025-06-15"));
    }

    @Test void genderMReturnsMasculine() {
        SayableAge pt = new SayableAge(Locales.ES);
        assertEquals("Reci\u00E9n nacido", pt.formatStage("2025-06-15", "2025-06-15", "m"));
        assertEquals("Ni\u00F1o peque\u00F1o", pt.formatStage("2024-06-15", "2025-06-15", "m"));
        assertEquals("Ni\u00F1o", pt.formatStage("2022-06-15", "2025-06-15", "m"));
        assertEquals("Adulto", pt.formatStage("2007-06-15", "2025-06-15", "m"));
    }

    @Test void genderFReturnsFeminine() {
        SayableAge pt = new SayableAge(Locales.ES);
        assertEquals("Reci\u00E9n nacida", pt.formatStage("2025-06-15", "2025-06-15", "f"));
        assertEquals("Ni\u00F1a peque\u00F1a", pt.formatStage("2024-06-15", "2025-06-15", "f"));
        assertEquals("Ni\u00F1a", pt.formatStage("2022-06-15", "2025-06-15", "f"));
        assertEquals("Adulta", pt.formatStage("2007-06-15", "2025-06-15", "f"));
    }

    @Test void genderNeutralStagesUnaffectedByGender() {
        SayableAge pt = new SayableAge(Locales.ES);
        assertEquals("Beb\u00E9", pt.formatStage("2025-01-15", "2025-06-15", "f"));
        assertEquals("Beb\u00E9", pt.formatStage("2025-01-15", "2025-06-15", "m"));
        assertEquals("Adolescente", pt.formatStage("2012-06-15", "2025-06-15", "f"));
        assertEquals("Adolescente", pt.formatStage("2012-06-15", "2025-06-15", "m"));
    }

    @Test void genderHasNoEffectOnNeutralLocales() {
        SayableAge pt = new SayableAge(Locales.EN);
        assertEquals("Newborn", pt.formatStage("2025-06-15", "2025-06-15", "f"));
        assertEquals("Newborn", pt.formatStage("2025-06-15", "2025-06-15", "m"));
        assertEquals("Adult", pt.formatStage("2007-06-15", "2025-06-15", "f"));
        assertEquals("Adult", pt.formatStage("2007-06-15", "2025-06-15", "m"));
    }

    @Test void genderFrenchStages() {
        SayableAge pt = new SayableAge(Locales.FR);
        assertEquals("Nouveau-n\u00E9", pt.formatStage("2025-06-15", "2025-06-15", "m"));
        assertEquals("Nouveau-n\u00E9e", pt.formatStage("2025-06-15", "2025-06-15", "f"));
        assertEquals("Nourrisson", pt.formatStage("2025-01-15", "2025-06-15", "f"));
        assertEquals("Tout-petit", pt.formatStage("2024-06-15", "2025-06-15", "f"));
        assertEquals("Enfant", pt.formatStage("2022-06-15", "2025-06-15", "f"));
        assertEquals("Adolescent", pt.formatStage("2012-06-15", "2025-06-15", "m"));
        assertEquals("Adolescente", pt.formatStage("2012-06-15", "2025-06-15", "f"));
        assertEquals("Adulte", pt.formatStage("2007-06-15", "2025-06-15", "f"));
    }

    @Test void genderItalianStages() {
        SayableAge pt = new SayableAge(Locales.IT);
        assertEquals("Neonato", pt.formatStage("2025-06-15", "2025-06-15", "m"));
        assertEquals("Neonata", pt.formatStage("2025-06-15", "2025-06-15", "f"));
        assertEquals("Bimbo", pt.formatStage("2024-06-15", "2025-06-15", "m"));
        assertEquals("Bimba", pt.formatStage("2024-06-15", "2025-06-15", "f"));
        assertEquals("Bambino", pt.formatStage("2022-06-15", "2025-06-15", "m"));
        assertEquals("Bambina", pt.formatStage("2022-06-15", "2025-06-15", "f"));
        assertEquals("Adulto", pt.formatStage("2007-06-15", "2025-06-15", "m"));
        assertEquals("Adulta", pt.formatStage("2007-06-15", "2025-06-15", "f"));
    }

    @Test void genderArabicAllStages() {
        SayableAge pt = new SayableAge(Locales.AR);
        assertEquals("\u062D\u062F\u064A\u062B \u0627\u0644\u0648\u0644\u0627\u062F\u0629", pt.formatStage("2025-06-15", "2025-06-15", "m"));
        assertEquals("\u062D\u062F\u064A\u062B\u0629 \u0627\u0644\u0648\u0644\u0627\u062F\u0629", pt.formatStage("2025-06-15", "2025-06-15", "f"));
        assertEquals("\u0631\u0636\u064A\u0639", pt.formatStage("2025-01-15", "2025-06-15", "m"));
        assertEquals("\u0631\u0636\u064A\u0639\u0629", pt.formatStage("2025-01-15", "2025-06-15", "f"));
        assertEquals("\u0637\u0641\u0644 \u0635\u063A\u064A\u0631", pt.formatStage("2024-06-15", "2025-06-15", "m"));
        assertEquals("\u0637\u0641\u0644\u0629 \u0635\u063A\u064A\u0631\u0629", pt.formatStage("2024-06-15", "2025-06-15", "f"));
        assertEquals("\u0637\u0641\u0644", pt.formatStage("2022-06-15", "2025-06-15", "m"));
        assertEquals("\u0637\u0641\u0644\u0629", pt.formatStage("2022-06-15", "2025-06-15", "f"));
        assertEquals("\u0645\u0631\u0627\u0647\u0642", pt.formatStage("2012-06-15", "2025-06-15", "m"));
        assertEquals("\u0645\u0631\u0627\u0647\u0642\u0629", pt.formatStage("2012-06-15", "2025-06-15", "f"));
        assertEquals("\u0628\u0627\u0644\u063A", pt.formatStage("2007-06-15", "2025-06-15", "m"));
        assertEquals("\u0628\u0627\u0644\u063A\u0629", pt.formatStage("2007-06-15", "2025-06-15", "f"));
    }

    @Test void genderGermanAdultOnly() {
        SayableAge pt = new SayableAge(Locales.DE);
        assertEquals("Erwachsener", pt.formatStage("2007-06-15", "2025-06-15", "m"));
        assertEquals("Erwachsene", pt.formatStage("2007-06-15", "2025-06-15", "f"));
        assertEquals("Neugeborenes", pt.formatStage("2025-06-15", "2025-06-15", "f"));
    }

    @Test void genderCompanionMethod() {
        assertEquals("Newborn", SayableAge.formatStageDefault("2025-06-15", "2025-06-15", "f"));
        assertEquals("Adult", SayableAge.formatStageDefault("2007-06-15", "2025-06-15", "f"));
    }

    // ================================================================
    // Locale-specific edge cases — new plural rules
    // ================================================================
    // 29.1, 29.2, 29.3, 29.4, 29.5, 29.6, 29.7, 29.8, 29.9, 29.10, 29.11, 29.12, 29.13, 29.14
    @Test void hebrewLocaleDualForms() {
        SayableAge pt = new SayableAge(Locales.HE);
        assertEquals("\u05E8\u05E7 \u05E0\u05D5\u05DC\u05D3", pt.formatAge("2025-06-15", "2025-06-15"));
        assertEquals("\u05D9\u05D5\u05DD", pt.formatAge("2025-06-14", "2025-06-15"));
        assertEquals("3 \u05D9\u05DE\u05D9\u05DD", pt.formatAge("2025-06-12", "2025-06-15"));
        assertEquals("\u05E9\u05D1\u05D5\u05E2\u05D9\u05D9\u05DD", pt.formatAge("2025-06-01", "2025-06-15"));
        assertEquals("3 \u05E9\u05D1\u05D5\u05E2\u05D5\u05EA", pt.formatAge("2025-05-25", "2025-06-15"));
        assertEquals("6 \u05D7\u05D5\u05D3\u05E9\u05D9\u05DD", pt.formatAge("2025-01-15", "2025-07-15"));
        assertEquals("3 \u05D7\u05D5\u05D3\u05E9\u05D9\u05DD", pt.formatAge("2025-03-15", "2025-06-15"));
        assertEquals("\u05E9\u05E0\u05EA\u05D9\u05D9\u05DD, \u05D7\u05D5\u05D3\u05E9", pt.formatAge("2023-06-15", "2025-07-15"));
        assertEquals("3 \u05E9\u05E0\u05D9\u05DD \u05D5\u05D7\u05E6\u05D9", pt.formatAge("2022-06-15", "2025-12-15"));
        assertEquals("7 \u05E9\u05E0\u05D9\u05DD", pt.formatAge("2018-06-15", "2025-06-15"));
        assertEquals("\u05E8\u05E7 \u05E0\u05D5\u05DC\u05D3", pt.formatStage("2025-06-15", "2025-06-15", "m"));
        assertEquals("\u05E8\u05E7 \u05E0\u05D5\u05DC\u05D3\u05D4", pt.formatStage("2025-06-15", "2025-06-15", "f"));
        assertEquals("\u05DE\u05D1\u05D5\u05D2\u05E8", pt.formatStage("2007-06-15", "2025-06-15", "m"));
        assertEquals("\u05DE\u05D1\u05D5\u05D2\u05E8\u05EA", pt.formatStage("2007-06-15", "2025-06-15", "f"));
    }

    // 29.15, 29.16, 29.17, 29.18, 29.19, 29.20, 29.21
    @Test void macedonianLocaleMod10Mod100Rule() {
        SayableAge pt = new SayableAge(Locales.MK);
        assertEquals("\u041D\u043E\u0432\u043E\u0440\u043E\u0434\u0435\u043D\u0447\u0435", pt.formatAge("2025-06-15", "2025-06-15"));
        assertEquals("1 \u0434\u0435\u043D", pt.formatAge("2025-06-14", "2025-06-15"));
        assertEquals("3 \u0434\u0435\u043D\u0430", pt.formatAge("2025-06-12", "2025-06-15"));
        assertEquals("6 \u043C\u0435\u0441\u0435\u0446\u0438", pt.formatAge("2025-01-15", "2025-07-15"));
        assertEquals("2 \u0433\u043E\u0434\u0438\u043D\u0438, 1 \u043C\u0435\u0441\u0435\u0446", pt.formatAge("2023-06-15", "2025-07-15"));
        assertEquals("3 \u0433\u043E\u0434\u0438\u043D\u0438 \u0438 \u043F\u043E\u043B", pt.formatAge("2022-06-15", "2025-12-15"));
        assertEquals("7 \u0433\u043E\u0434\u0438\u043D\u0438", pt.formatAge("2018-06-15", "2025-06-15"));
    }

    // 29.22, 29.23, 29.24, 29.25, 29.26, 29.27
    @Test void swahiliLocaleNounClassChanges() {
        SayableAge pt = new SayableAge(Locales.SW);
        assertEquals("Mzaliwa mpya", pt.formatAge("2025-06-15", "2025-06-15"));
        assertEquals("siku 1", pt.formatAge("2025-06-14", "2025-06-15"));
        assertEquals("siku 3", pt.formatAge("2025-06-12", "2025-06-15"));
        assertEquals("miezi 6", pt.formatAge("2025-01-15", "2025-07-15"));
        assertEquals("miaka 2, mwezi 1", pt.formatAge("2023-06-15", "2025-07-15"));
        assertEquals("miaka 3 na nusu", pt.formatAge("2022-06-15", "2025-12-15"));
    }

    // 29.28, 29.29, 29.30, 29.31, 29.32, 29.33
    @Test void indonesianLocaleOtherOnly() {
        SayableAge pt = new SayableAge(Locales.ID);
        assertEquals("Baru lahir", pt.formatAge("2025-06-15", "2025-06-15"));
        assertEquals("1 hari", pt.formatAge("2025-06-14", "2025-06-15"));
        assertEquals("3 hari", pt.formatAge("2025-06-12", "2025-06-15"));
        assertEquals("6 bulan", pt.formatAge("2025-01-15", "2025-07-15"));
        assertEquals("3 setengah tahun", pt.formatAge("2022-06-15", "2025-12-15"));
        assertEquals("7 tahun", pt.formatAge("2018-06-15", "2025-06-15"));
    }

    // 29.34, 29.35, 29.36, 29.37, 29.38, 29.39
    @Test void amharicLocaleEthiopicDelimiter() {
        SayableAge pt = new SayableAge(Locales.AM);
        assertEquals("\u12A0\u12F2\u1235 \u12E8\u1270\u12C8\u1208\u12F0", pt.formatAge("2025-06-15", "2025-06-15"));
        assertEquals("1 \u1240\u1295", pt.formatAge("2025-06-14", "2025-06-15"));
        assertEquals("3 \u1240\u1293\u1275", pt.formatAge("2025-06-12", "2025-06-15"));
        assertEquals("1 \u1233\u121D\u1295\u1275\u1363 1 \u1240\u1295", pt.formatAge("2025-06-07", "2025-06-15"));
        assertEquals("6 \u12C8\u122B\u1275", pt.formatAge("2025-01-15", "2025-07-15"));
        assertEquals("3 \u12D3\u1218\u1273\u1275 \u1270\u12A9\u120D", pt.formatAge("2022-06-15", "2025-12-15"));
    }

    // ================================================================
    // Locale lookup by code string
    // ================================================================
    // 30.1
    @Test void getLocaleReturnsEnLocale() {
        AgeLocale loc = Locales.get("en");
        assertNotNull(loc);
        assertEquals("en", loc.code());
    }

    // 30.2
    @Test void getLocaleReturnsFrLocale() {
        AgeLocale loc = Locales.get("fr");
        assertNotNull(loc);
        assertEquals("fr", loc.code());
    }

    // 30.3
    @Test void getLocaleReturnsNullForUnknownCode() {
        assertNull(Locales.get("xx"));
    }

    // 30.4
    @Test void getLocaleReturnsNullForEmptyString() {
        assertNull(Locales.get(""));
    }

    // 30.5
    @Test void getLocaleIsCaseSensitive() {
        assertNull(Locales.get("EN"));
    }

    // ================================================================
    // Weeks and days across month ends
    // ================================================================

    // 31.1
    @Test
    void s31_188DaysAcrossA28DayFebruary() {
        SayableAge f = new SayableAge(Locales.EN);
        assertEquals("12 weeks, 4 days", f.formatAge("2016-12-31", "2017-03-29"));
    }

    // 31.2
    @Test
    void s31_290DaysAcrossAYearEndInto() {
        SayableAge f = new SayableAge(Locales.EN);
        assertEquals("12 weeks, 6 days", f.formatAge("1991-11-27", "1992-02-25"));
    }

    // 31.3
    @Test
    void s31_333DaysAcrossAYearEnd() {
        SayableAge f = new SayableAge(Locales.EN);
        assertEquals("4 weeks, 5 days", f.formatAge("2020-11-30", "2021-01-02"));
    }

    // 31.4
    @Test
    void s31_4CompactFormOf311() {
        SayableAge f = new SayableAge(Locales.EN, Compactness.COMPACT);
        assertEquals("12w4d", f.formatAge("2016-12-31", "2017-03-29"));
    }

    // ================================================================
    // Half years take their plural form from whole years
    // ================================================================

    // 32.1
    @Test
    void s32_1Polish3IsFew() {
        SayableAge f = new SayableAge(Locales.PL);
        assertEquals("3 i p\u00F3\u0142 lata", f.formatAge("2021-06-15", "2025-01-15"));
    }

    // 32.2
    @Test
    void s32_2Polish5IsMany() {
        SayableAge f = new SayableAge(Locales.PL, Compactness.SHORT);
        assertEquals("5 i p\u00F3\u0142 lat", f.formatAge("2020-06-15", "2025-12-15"));
    }

    // 32.3
    @Test
    void s32_3Tachelhit6IsFew() {
        SayableAge f = new SayableAge(Locales.SHI);
        assertEquals("6 \u2D49\u2D59\u2D33\u2D33\u2D6F\u2D30\u2D59\u2D4F \u2D37 \u2D53\u2D63\u2D33\u2D4F", f.formatAge("2005-06-08", "2012-06-07"));
    }

    // ================================================================
    // Input validation
    // ================================================================

    // 33.1
    @Test
    void s33_1February30DoesntExist() {
        SayableAge f = new SayableAge(Locales.EN);
        assertNull(f.formatAge("2025-02-30", "2032-06-25"));
    }

    // 33.2
    @Test
    void s33_2Month13() {
        SayableAge f = new SayableAge(Locales.EN);
        assertNull(f.formatAge("2025-13-01", "2027-01-31"));
    }

    // 33.3
    @Test
    void s33_3February29InANonLeapYear() {
        SayableAge f = new SayableAge(Locales.EN);
        assertNull(f.formatAge("2023-02-29", "2025-03-01"));
    }

    // 33.4
    @Test
    void s33_4Day00() {
        SayableAge f = new SayableAge(Locales.EN);
        assertNull(f.formatAge("2025-06-00", "2027-02-25"));
    }

    // 33.5
    @Test
    void s33_5UnpaddedMonthAndDay() {
        SayableAge f = new SayableAge(Locales.EN);
        assertNull(f.formatAge("2025-6-1", "2027-02-25"));
    }

    // 33.6
    @Test
    void s33_6SurroundingWhitespace() {
        SayableAge f = new SayableAge(Locales.EN);
        assertNull(f.formatAge(" 2025-06-01", "2027-02-25"));
    }

    // 33.7
    @Test
    void s33_7ADatetimeIsNotADate() {
        SayableAge f = new SayableAge(Locales.EN);
        assertNull(f.formatAge("2025-06-15T10:00:00", "2027-02-25"));
    }

    // 33.8
    @Test
    void s33_8InvalidAsOf() {
        SayableAge f = new SayableAge(Locales.EN);
        assertNull(f.formatAge("2020-01-01", "2025-04-31"));
    }

    // 33.9
    @Test
    void s33_9FormatStageValidatesToo() {
        SayableAge f = new SayableAge(Locales.EN);
        assertNull(f.formatStage("2025-02-30", "2027-09-05"));
    }

    // 33.10
    @Test
    void s33_10February29InALeapYearIs() {
        SayableAge f = new SayableAge(Locales.EN);
        assertEquals("2 years", f.formatAge("2024-02-29", "2026-03-01"));
    }
}
