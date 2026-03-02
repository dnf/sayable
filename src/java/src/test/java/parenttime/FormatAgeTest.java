package parenttime;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class FormatAgeTest {

    @AfterEach
    void resetTimeNow() {
        ParentTime.timeNow = LocalDate::now;
    }

    // ================================================================
    // formatAge -- null/edge cases
    // ================================================================
    // 1.3
    @Test void emptyStringReturnsNull() {
        assertNull(ParentTime.formatAgeDefault("", "2025-06-15"));
    }

    // 1.4
    @Test void futureDobReturnsNull() {
        assertNull(ParentTime.formatAgeDefault("2025-07-01", "2025-06-15"));
    }

    // 1.5
    @Test void exactly500YearsIsAllowed() {
        assertEquals("500 years", ParentTime.formatAgeDefault("1525-06-15", "2025-06-15"));
    }

    // 1.6
    @Test void years501ExceedsMaxAge() {
        assertNull(ParentTime.formatAgeDefault("1524-06-15", "2025-06-15"));
    }

    // 1.7
    @Test void years1000ExceedsMaxAge() {
        assertNull(ParentTime.formatAgeDefault("1025-06-15", "2025-06-15"));
    }

    // ================================================================
    // formatAge -- days tier (0-6)
    // ================================================================
    // 2.1
    @Test void bornToday() {
        assertEquals("Newborn", ParentTime.formatAgeDefault("2025-06-15", "2025-06-15"));
    }

    // 2.2
    @Test void oneDayAgo() {
        assertEquals("1 day", ParentTime.formatAgeDefault("2025-06-14", "2025-06-15"));
    }

    // 2.3
    @Test void threeDaysAgo() {
        assertEquals("3 days", ParentTime.formatAgeDefault("2025-06-12", "2025-06-15"));
    }

    // 2.4
    @Test void sixDaysAgo() {
        assertEquals("6 days", ParentTime.formatAgeDefault("2025-06-09", "2025-06-15"));
    }

    // 2.5
    @Test void sevenDaysBecomesOneWeek() {
        assertEquals("1 week", ParentTime.formatAgeDefault("2025-06-08", "2025-06-15"));
    }

    // ================================================================
    // formatAge -- weeks+days tier (7 days to less than 3 months)
    // ================================================================
    // 3.1
    @Test void sevenDaysIsOneWeek() {
        assertEquals("1 week", ParentTime.formatAgeDefault("2025-06-08", "2025-06-15"));
    }

    // 3.2
    @Test void eightDaysIsOneWeekOneDay() {
        assertEquals("1 week, 1 day", ParentTime.formatAgeDefault("2025-06-07", "2025-06-15"));
    }

    // 3.3
    @Test void nineDaysIsOneWeekTwoDays() {
        assertEquals("1 week, 2 days", ParentTime.formatAgeDefault("2025-06-06", "2025-06-15"));
    }

    // 3.4
    @Test void thirteenDaysIsOneWeekSixDays() {
        assertEquals("1 week, 6 days", ParentTime.formatAgeDefault("2025-06-02", "2025-06-15"));
    }

    // 3.5
    @Test void fourteenDaysIsTwoWeeks() {
        assertEquals("2 weeks", ParentTime.formatAgeDefault("2025-06-01", "2025-06-15"));
    }

    // 3.6
    @Test void fifteenDaysIsTwoWeeksOneDay() {
        assertEquals("2 weeks, 1 day", ParentTime.formatAgeDefault("2025-05-31", "2025-06-15"));
    }

    // 3.7
    @Test void twentyDaysIsTwoWeeksSixDays() {
        assertEquals("2 weeks, 6 days", ParentTime.formatAgeDefault("2025-05-26", "2025-06-15"));
    }

    // 3.8
    @Test void twentyOneDaysIsThreeWeeks() {
        assertEquals("3 weeks", ParentTime.formatAgeDefault("2025-05-25", "2025-06-15"));
    }

    // 3.9
    @Test void atOneCalMonthStillWeeksDays() {
        assertEquals("4 weeks, 3 days", ParentTime.formatAgeDefault("2025-05-15", "2025-06-15"));
    }

    // 3.10
    @Test void atTwoCalMonthsStillWeeksDays() {
        assertEquals("8 weeks, 5 days", ParentTime.formatAgeDefault("2025-04-15", "2025-06-15"));
    }

    // 3.11
    @Test void oneDayBefore3moStillWeeks() {
        assertEquals("13 weeks", ParentTime.formatAgeDefault("2025-03-15", "2025-06-14"));
    }

    // 3.12
    @Test void on3moBirthdaySwitches() {
        assertEquals("3 months", ParentTime.formatAgeDefault("2025-03-15", "2025-06-15"));
    }

    // ================================================================
    // formatAge -- month boundaries: standard months
    // ================================================================
    // 4.1
    @Test void jan1ToApr1Is3mo() {
        assertEquals("3 months", ParentTime.formatAgeDefault("2025-01-01", "2025-04-01"));
    }

    // 4.2
    @Test void jan1ToMar31StillWeeks() {
        String result = ParentTime.formatAgeDefault("2025-01-01", "2025-03-31");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // 4.3
    @Test void jun15ToSep15Is3mo() {
        assertEquals("3 months", ParentTime.formatAgeDefault("2025-06-15", "2025-09-15"));
    }

    // 4.4
    @Test void jun15ToSep14StillWeeks() {
        String result = ParentTime.formatAgeDefault("2025-06-15", "2025-09-14");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // 4.5
    @Test void jun15ToDec15Is6mo() {
        assertEquals("6 months", ParentTime.formatAgeDefault("2025-06-15", "2025-12-15"));
    }

    // ================================================================
    // formatAge -- month boundaries: February non-leap
    // ================================================================
    // 5.1
    @Test void jan31ToFeb28NonLeap() {
        assertEquals("4 weeks", ParentTime.formatAgeDefault("2025-01-31", "2025-02-28"));
    }

    // 5.2
    @Test void jan31ToApr30Is3moClamp() {
        assertEquals("3 months", ParentTime.formatAgeDefault("2025-01-31", "2025-04-30"));
    }

    // 5.3
    @Test void jan31ToApr29StillWeeks() {
        String result = ParentTime.formatAgeDefault("2025-01-31", "2025-04-29");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // 5.4
    @Test void feb1ToMay1Is3mo() {
        assertEquals("3 months", ParentTime.formatAgeDefault("2025-02-01", "2025-05-01"));
    }

    // 5.5
    @Test void feb1ToApr30StillWeeks() {
        String result = ParentTime.formatAgeDefault("2025-02-01", "2025-04-30");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // ================================================================
    // formatAge -- month boundaries: February leap year
    // ================================================================
    // 6.1
    @Test void jan31ToFeb29Leap() {
        assertEquals("4 weeks, 1 day", ParentTime.formatAgeDefault("2024-01-31", "2024-02-29"));
    }

    // 6.2
    @Test void jan31ToFeb28Leap() {
        assertEquals("4 weeks", ParentTime.formatAgeDefault("2024-01-31", "2024-02-28"));
    }

    // 6.3
    @Test void jan31ToApr30LeapIs3mo() {
        assertEquals("3 months", ParentTime.formatAgeDefault("2024-01-31", "2024-04-30"));
    }

    // 6.4
    @Test void jan30ToFeb29LeapStillWeeks() {
        String result = ParentTime.formatAgeDefault("2024-01-30", "2024-02-29");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // 6.5
    @Test void jan30ToFeb28LeapStillWeeks() {
        String result = ParentTime.formatAgeDefault("2024-01-30", "2024-02-28");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // ================================================================
    // formatAge -- month boundaries: 30-day months
    // ================================================================
    // 7.1
    @Test void mar31ToJun30Is3moClamped() {
        assertEquals("3 months", ParentTime.formatAgeDefault("2025-03-31", "2025-06-30"));
    }

    // 7.2
    @Test void mar31ToJun29StillWeeks() {
        String result = ParentTime.formatAgeDefault("2025-03-31", "2025-06-29");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // 7.3
    @Test void aug31ToNov30Is3mo() {
        assertEquals("3 months", ParentTime.formatAgeDefault("2025-08-31", "2025-11-30"));
    }

    // 7.4
    @Test void aug31ToNov29StillWeeks() {
        String result = ParentTime.formatAgeDefault("2025-08-31", "2025-11-29");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // ================================================================
    // formatAge -- month boundaries: leap year baby (born Feb 29)
    // ================================================================
    // 8.1
    @Test void feb29ToMay29Is3mo() {
        assertEquals("3 months", ParentTime.formatAgeDefault("2024-02-29", "2024-05-29"));
    }

    // 8.2
    @Test void feb29ToMay28StillWeeks() {
        String result = ParentTime.formatAgeDefault("2024-02-29", "2024-05-28");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // 8.3
    @Test void feb29_2024ToFeb28_2025Is12mo() {
        assertEquals("12 months", ParentTime.formatAgeDefault("2024-02-29", "2025-02-28"));
    }

    // 8.4
    @Test void feb29_2024ToMar1_2025Is12mo() {
        assertEquals("12 months", ParentTime.formatAgeDefault("2024-02-29", "2025-03-01"));
    }

    // ================================================================
    // formatAge -- months tier (3-23)
    // ================================================================
    // 9.1
    @Test void threeMonthsAtTransition() {
        assertEquals("3 months", ParentTime.formatAgeDefault("2025-01-15", "2025-04-15"));
    }

    // 9.2
    @Test void sixMonths() {
        assertEquals("6 months", ParentTime.formatAgeDefault("2025-01-15", "2025-07-15"));
    }

    // 9.3
    @Test void twelveMonthsNotOneYear() {
        assertEquals("12 months", ParentTime.formatAgeDefault("2024-06-15", "2025-06-15"));
    }

    // 9.4
    @Test void twentyThreeMonthsAtUpper() {
        assertEquals("23 months", ParentTime.formatAgeDefault("2024-01-15", "2025-12-15"));
    }

    // 9.5
    @Test void oneDayBeforeBoundary() {
        assertEquals("5 months", ParentTime.formatAgeDefault("2025-01-15", "2025-07-14"));
    }

    // 9.6
    @Test void crossingYearBoundary() {
        assertEquals("5 months", ParentTime.formatAgeDefault("2024-11-10", "2025-04-10"));
    }

    // ================================================================
    // formatAge -- years+months tier (24-35 months)
    // ================================================================
    // 10.1
    @Test void twoYearsAt24mo() {
        assertEquals("2 years", ParentTime.formatAgeDefault("2023-06-15", "2025-06-15"));
    }

    // 10.2
    @Test void twoYearsOneMonth() {
        assertEquals("2 years, 1 month", ParentTime.formatAgeDefault("2023-06-15", "2025-07-15"));
    }

    // 10.3
    @Test void twoYearsSixMonths() {
        assertEquals("2 years, 6 months", ParentTime.formatAgeDefault("2023-06-15", "2025-12-15"));
    }

    // 10.4
    @Test void twoYearsElevenMonths() {
        assertEquals("2 years, 11 months", ParentTime.formatAgeDefault("2023-06-15", "2026-05-15"));
    }

    // 10.5
    @Test void oneDayBefore24mo() {
        assertEquals("23 months", ParentTime.formatAgeDefault("2023-06-15", "2025-06-14"));
    }

    // ================================================================
    // formatAge -- half-year tier (3-6 years)
    // ================================================================
    // 11.1
    @Test void threeYearsExactly() {
        assertEquals("3 years", ParentTime.formatAgeDefault("2022-06-15", "2025-06-15"));
    }

    // 11.2
    @Test void threeYearsFiveMonths() {
        assertEquals("3 years", ParentTime.formatAgeDefault("2022-06-15", "2025-11-15"));
    }

    // 11.3
    @Test void threeAndHalfYearsAt3y6m() {
        assertEquals("3\u00BD years", ParentTime.formatAgeDefault("2022-06-15", "2025-12-15"));
    }

    // 11.4
    @Test void threeAndHalfYearsAt3y11m() {
        assertEquals("3\u00BD years", ParentTime.formatAgeDefault("2022-06-15", "2026-05-15"));
    }

    // 11.5
    @Test void fourYearsExactly() {
        assertEquals("4 years", ParentTime.formatAgeDefault("2021-06-15", "2025-06-15"));
    }

    // 11.6
    @Test void fourAndHalfYears() {
        assertEquals("4\u00BD years", ParentTime.formatAgeDefault("2021-06-15", "2025-12-15"));
    }

    // 11.7
    @Test void fiveYears() {
        assertEquals("5 years", ParentTime.formatAgeDefault("2020-06-15", "2025-06-15"));
    }

    // 11.8
    @Test void fiveAndHalfYearsAt5y8m() {
        assertEquals("5\u00BD years", ParentTime.formatAgeDefault("2020-06-15", "2026-02-15"));
    }

    // 11.9
    @Test void sixYears() {
        assertEquals("6 years", ParentTime.formatAgeDefault("2019-06-15", "2025-06-15"));
    }

    // 11.10
    @Test void sixAndHalfYears() {
        assertEquals("6\u00BD years", ParentTime.formatAgeDefault("2019-06-15", "2025-12-15"));
    }

    // 11.11
    @Test void sixAndHalfYearsAt6y11m() {
        assertEquals("6\u00BD years", ParentTime.formatAgeDefault("2019-06-15", "2026-05-15"));
    }

    // 11.12
    @Test void oneDayBefore3rdBday() {
        assertEquals("2 years, 11 months", ParentTime.formatAgeDefault("2022-06-15", "2025-06-14"));
    }

    // ================================================================
    // formatAge -- integer tier (7+ years)
    // ================================================================
    // 12.1
    @Test void sevenYearsExactly() {
        assertEquals("7 years", ParentTime.formatAgeDefault("2018-06-15", "2025-06-15"));
    }

    // 12.2
    @Test void sevenYearsSixMonthsNoHalf() {
        assertEquals("7 years", ParentTime.formatAgeDefault("2018-03-20", "2025-06-15"));
    }

    // 12.3
    @Test void fortyFiveYears() {
        assertEquals("45 years", ParentTime.formatAgeDefault("1980-01-01", "2025-06-15"));
    }

    // ================================================================
    // formatAge -- cross-year transitions with Feb
    // ================================================================
    // 13.1
    @Test void dec31ToMar31Is3mo() {
        assertEquals("3 months", ParentTime.formatAgeDefault("2024-12-31", "2025-03-31"));
    }

    // 13.2
    @Test void dec31ToMar30StillWeeks() {
        String result = ParentTime.formatAgeDefault("2024-12-31", "2025-03-30");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // 13.3
    @Test void nov30ToFeb28Is3mo() {
        assertEquals("3 months", ParentTime.formatAgeDefault("2024-11-30", "2025-02-28"));
    }

    // 13.4
    @Test void nov30ToFeb27StillWeeks() {
        String result = ParentTime.formatAgeDefault("2024-11-30", "2025-02-27");
        assertNotNull(result);
        assertTrue(result.contains("weeks"));
    }

    // ================================================================
    // formatAge -- born-on-31st progression
    // ================================================================
    // 14.1
    @Test void jan31ToApr30Is3mo() {
        assertEquals("3 months", ParentTime.formatAgeDefault("2025-01-31", "2025-04-30"));
    }

    // 14.2
    @Test void jan31ToMay31Is4mo() {
        assertEquals("4 months", ParentTime.formatAgeDefault("2025-01-31", "2025-05-31"));
    }

    // 14.3
    @Test void jan31ToJun30Is5moClamped() {
        assertEquals("5 months", ParentTime.formatAgeDefault("2025-01-31", "2025-06-30"));
    }

    // 14.4
    @Test void jan31ToJul1Is5mo() {
        assertEquals("5 months", ParentTime.formatAgeDefault("2025-01-31", "2025-07-01"));
    }

    // 14.5
    @Test void jan31ToJul31Is6mo() {
        assertEquals("6 months", ParentTime.formatAgeDefault("2025-01-31", "2025-07-31"));
    }

    // ================================================================
    // formatAge -- default asOf (uses current date)
    // ================================================================
    // 15.1, 15.2
    @Test void defaultAsOfUsesMockedToday() {
        ParentTime.timeNow = () -> LocalDate.of(2025, 6, 15);
        assertEquals("5 years", ParentTime.formatAgeDefault("2020-01-01"));
        assertEquals("5 days", ParentTime.formatAgeDefault("2025-06-10"));
    }

    // ================================================================
    // formatStage -- null/edge cases
    // ================================================================
    // 16.1, 16.3
    @Test void stageEmptyStringReturnsNull() {
        assertNull(ParentTime.formatStageDefault("", "2025-06-15"));
    }

    // 16.4
    @Test void stageFutureDobReturnsNull() {
        assertNull(ParentTime.formatStageDefault("2025-07-01", "2025-06-15"));
    }

    // 16.5
    @Test void stageExactly500YearsReturnsAdult() {
        assertEquals("Adult", ParentTime.formatStageDefault("1525-06-15", "2025-06-15"));
    }

    // 16.6
    @Test void stage501YearsExceedsMaxAge() {
        assertNull(ParentTime.formatStageDefault("1524-06-15", "2025-06-15"));
    }

    // ================================================================
    // formatStage -- newborn
    // ================================================================
    // 17.1
    @Test void stageBornToday() {
        assertEquals("Newborn", ParentTime.formatStageDefault("2025-06-15", "2025-06-15"));
    }

    // 17.2
    @Test void stageOneDayOld() {
        assertEquals("Newborn", ParentTime.formatStageDefault("2025-06-14", "2025-06-15"));
    }

    // 17.3
    @Test void stageThreeWeeksOld() {
        assertEquals("Newborn", ParentTime.formatStageDefault("2025-05-25", "2025-06-15"));
    }

    // 17.4
    @Test void stageOneMonthOld() {
        assertEquals("Newborn", ParentTime.formatStageDefault("2025-05-15", "2025-06-15"));
    }

    // 17.5
    @Test void stageOneMonth29Days() {
        assertEquals("Newborn", ParentTime.formatStageDefault("2025-04-16", "2025-06-15"));
    }

    // 17.6
    @Test void stageExactly2MonthsBecomesInfant() {
        assertEquals("Infant", ParentTime.formatStageDefault("2025-04-15", "2025-06-15"));
    }

    // ================================================================
    // formatStage -- infant
    // ================================================================
    // 18.1
    @Test void stageTwoMonths() {
        assertEquals("Infant", ParentTime.formatStageDefault("2025-04-15", "2025-06-15"));
    }

    // 18.2
    @Test void stageSixMonths() {
        assertEquals("Infant", ParentTime.formatStageDefault("2024-12-15", "2025-06-15"));
    }

    // 18.3
    @Test void stageElevenMonths() {
        assertEquals("Infant", ParentTime.formatStageDefault("2024-07-15", "2025-06-15"));
    }

    // 18.4
    @Test void stageExactly12moBecomesToddler() {
        assertEquals("Toddler", ParentTime.formatStageDefault("2024-06-15", "2025-06-15"));
    }

    // ================================================================
    // formatStage -- toddler
    // ================================================================
    // 19.1
    @Test void stageTwelveMonths() {
        assertEquals("Toddler", ParentTime.formatStageDefault("2024-06-15", "2025-06-15"));
    }

    // 19.2
    @Test void stageEighteenMonths() {
        assertEquals("Toddler", ParentTime.formatStageDefault("2024-01-15", "2025-07-15"));
    }

    // 19.3
    @Test void stageTwentyFourMonths() {
        assertEquals("Toddler", ParentTime.formatStageDefault("2023-06-15", "2025-06-15"));
    }

    // 19.4
    @Test void stageThirtyFiveMonths() {
        assertEquals("Toddler", ParentTime.formatStageDefault("2023-06-15", "2026-05-15"));
    }

    // 19.5
    @Test void stageExactly36moBecomesChild() {
        assertEquals("Child", ParentTime.formatStageDefault("2022-06-15", "2025-06-15"));
    }

    // ================================================================
    // formatStage -- child
    // ================================================================
    // 20.1
    @Test void stageThreeYears() {
        assertEquals("Child", ParentTime.formatStageDefault("2022-06-15", "2025-06-15"));
    }

    // 20.2
    @Test void stageFourYears() {
        assertEquals("Child", ParentTime.formatStageDefault("2021-06-15", "2025-06-15"));
    }

    // 20.3
    @Test void stageSixYears() {
        assertEquals("Child", ParentTime.formatStageDefault("2019-06-15", "2025-06-15"));
    }

    // 20.4
    @Test void stageNineYears() {
        assertEquals("Child", ParentTime.formatStageDefault("2016-06-15", "2025-06-15"));
    }

    // 20.5
    @Test void stage12y11mo() {
        assertEquals("Child", ParentTime.formatStageDefault("2013-06-15", "2026-05-15"));
    }

    // 20.6
    @Test void stageExactly13yBecomesTeenager() {
        assertEquals("Teenager", ParentTime.formatStageDefault("2012-06-15", "2025-06-15"));
    }

    // ================================================================
    // formatStage -- teenager
    // ================================================================
    // 21.1
    @Test void stageThirteenYears() {
        assertEquals("Teenager", ParentTime.formatStageDefault("2012-06-15", "2025-06-15"));
    }

    // 21.2
    @Test void stageFifteenYears() {
        assertEquals("Teenager", ParentTime.formatStageDefault("2010-06-15", "2025-06-15"));
    }

    // 21.3
    @Test void stage17y11mo() {
        assertEquals("Teenager", ParentTime.formatStageDefault("2008-06-15", "2026-05-15"));
    }

    // 21.4
    @Test void stageExactly18yBecomesAdult() {
        assertEquals("Adult", ParentTime.formatStageDefault("2007-06-15", "2025-06-15"));
    }

    // ================================================================
    // formatStage -- adult
    // ================================================================
    // 22.1
    @Test void stageEighteenYears() {
        assertEquals("Adult", ParentTime.formatStageDefault("2007-06-15", "2025-06-15"));
    }

    // 22.2
    @Test void stageTwentyFiveYears() {
        assertEquals("Adult", ParentTime.formatStageDefault("2000-06-15", "2025-06-15"));
    }

    // 22.3
    @Test void stageFortyFiveYears() {
        assertEquals("Adult", ParentTime.formatStageDefault("1980-01-01", "2025-06-15"));
    }

    // ================================================================
    // formatStage -- default asOf
    // ================================================================
    // 23.1, 23.2, 23.3
    @Test void stageDefaultAsOf() {
        ParentTime.timeNow = () -> LocalDate.of(2025, 6, 15);
        assertEquals("Newborn", ParentTime.formatStageDefault("2025-06-15"));
        assertEquals("Child", ParentTime.formatStageDefault("2020-01-01"));
        assertEquals("Adult", ParentTime.formatStageDefault("1980-01-01"));
    }

    // ================================================================
    // ParentTime class with English locale
    // ================================================================
    // 24.1, 24.2, 24.3, 24.4, 24.5, 24.6, 24.7, 24.8, 24.9, 24.10, 24.11, 24.12, 24.13, 24.14, 24.15
    @Test void parentTimeEnglishAllTiers() {
        ParentTime pt = new ParentTime(Locales.EN);
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
    // ParentTime with Spanish locale
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
            "{n} y medio",
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

        ParentTime pt = new ParentTime(es);

        assertEquals("Reci\u00E9n nacido", pt.formatAge("2025-06-15", "2025-06-15"));
        assertEquals("1 d\u00EDa", pt.formatAge("2025-06-14", "2025-06-15"));
        assertEquals("3 d\u00EDas", pt.formatAge("2025-06-12", "2025-06-15"));
        assertEquals("1 semana", pt.formatAge("2025-06-08", "2025-06-15"));
        assertEquals("1 semana, 1 d\u00EDa", pt.formatAge("2025-06-07", "2025-06-15"));
        assertEquals("2 semanas, 6 d\u00EDas", pt.formatAge("2025-05-26", "2025-06-15"));
        assertEquals("6 meses", pt.formatAge("2025-01-15", "2025-07-15"));
        assertEquals("2 a\u00F1os, 1 mes", pt.formatAge("2023-06-15", "2025-07-15"));
        assertEquals("2 a\u00F1os, 6 meses", pt.formatAge("2023-06-15", "2025-12-15"));
        assertEquals("3 y medio a\u00F1os", pt.formatAge("2022-06-15", "2025-12-15"));
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
        ParentTime pt = new ParentTime(Locales.EN, Compactness.SHORT);

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
        ParentTime pt = new ParentTime(Locales.EN, Compactness.COMPACT);

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
    // All 71 locales exist and have correct codes
    // ================================================================
    @Test void all71LocalesExist() {
        assertEquals(71, Locales.ALL.size());
        String[] expectedCodes = {
            "am", "ar", "az", "bg", "bn", "br", "bs", "ca", "cs", "cy",
            "da", "de", "el", "en", "es", "et", "eu", "fa", "fi", "fil",
            "fr", "ga", "gd", "gu", "gv", "he", "hi", "hr", "hu", "id",
            "it", "ja", "jv", "ka", "kk", "km", "ko", "kw", "lt", "lv",
            "mk", "mr", "ms", "mt", "my", "nb", "ne", "nl", "pa", "pl",
            "pt", "ro", "ru", "shi", "si", "sk", "sl", "sq", "sr", "sv",
            "sw", "ta", "te", "th", "tr", "tzm", "uk", "ur", "uz", "vi",
            "zh"
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
            ParentTime pt = new ParentTime(locale);

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
        ParentTime pt = new ParentTime(Locales.ES);
        assertEquals("Reci\u00E9n nacido", pt.formatStage("2025-06-15", "2025-06-15"));
        assertEquals("Ni\u00F1o peque\u00F1o", pt.formatStage("2024-06-15", "2025-06-15"));
        assertEquals("Ni\u00F1o", pt.formatStage("2022-06-15", "2025-06-15"));
        assertEquals("Adulto", pt.formatStage("2007-06-15", "2025-06-15"));
    }

    @Test void genderMReturnsMasculine() {
        ParentTime pt = new ParentTime(Locales.ES);
        assertEquals("Reci\u00E9n nacido", pt.formatStage("2025-06-15", "2025-06-15", "m"));
        assertEquals("Ni\u00F1o peque\u00F1o", pt.formatStage("2024-06-15", "2025-06-15", "m"));
        assertEquals("Ni\u00F1o", pt.formatStage("2022-06-15", "2025-06-15", "m"));
        assertEquals("Adulto", pt.formatStage("2007-06-15", "2025-06-15", "m"));
    }

    @Test void genderFReturnsFeminine() {
        ParentTime pt = new ParentTime(Locales.ES);
        assertEquals("Reci\u00E9n nacida", pt.formatStage("2025-06-15", "2025-06-15", "f"));
        assertEquals("Ni\u00F1a peque\u00F1a", pt.formatStage("2024-06-15", "2025-06-15", "f"));
        assertEquals("Ni\u00F1a", pt.formatStage("2022-06-15", "2025-06-15", "f"));
        assertEquals("Adulta", pt.formatStage("2007-06-15", "2025-06-15", "f"));
    }

    @Test void genderNeutralStagesUnaffectedByGender() {
        ParentTime pt = new ParentTime(Locales.ES);
        assertEquals("Beb\u00E9", pt.formatStage("2025-01-15", "2025-06-15", "f"));
        assertEquals("Beb\u00E9", pt.formatStage("2025-01-15", "2025-06-15", "m"));
        assertEquals("Adolescente", pt.formatStage("2012-06-15", "2025-06-15", "f"));
        assertEquals("Adolescente", pt.formatStage("2012-06-15", "2025-06-15", "m"));
    }

    @Test void genderHasNoEffectOnNeutralLocales() {
        ParentTime pt = new ParentTime(Locales.EN);
        assertEquals("Newborn", pt.formatStage("2025-06-15", "2025-06-15", "f"));
        assertEquals("Newborn", pt.formatStage("2025-06-15", "2025-06-15", "m"));
        assertEquals("Adult", pt.formatStage("2007-06-15", "2025-06-15", "f"));
        assertEquals("Adult", pt.formatStage("2007-06-15", "2025-06-15", "m"));
    }

    @Test void genderFrenchStages() {
        ParentTime pt = new ParentTime(Locales.FR);
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
        ParentTime pt = new ParentTime(Locales.IT);
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
        ParentTime pt = new ParentTime(Locales.AR);
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
        ParentTime pt = new ParentTime(Locales.DE);
        assertEquals("Erwachsener", pt.formatStage("2007-06-15", "2025-06-15", "m"));
        assertEquals("Erwachsene", pt.formatStage("2007-06-15", "2025-06-15", "f"));
        assertEquals("Neugeborenes", pt.formatStage("2025-06-15", "2025-06-15", "f"));
    }

    @Test void genderCompanionMethod() {
        assertEquals("Newborn", ParentTime.formatStageDefault("2025-06-15", "2025-06-15", "f"));
        assertEquals("Adult", ParentTime.formatStageDefault("2007-06-15", "2025-06-15", "f"));
    }

    // ================================================================
    // Locale-specific edge cases — new plural rules
    // ================================================================
    // 29.1, 29.2, 29.3, 29.4, 29.5, 29.6, 29.7, 29.8, 29.9, 29.10, 29.11, 29.12, 29.13, 29.14
    @Test void hebrewLocaleDualForms() {
        ParentTime pt = new ParentTime(Locales.HE);
        assertEquals("\u05E8\u05E7 \u05E0\u05D5\u05DC\u05D3", pt.formatAge("2025-06-15", "2025-06-15"));
        assertEquals("\u05D9\u05D5\u05DD 1", pt.formatAge("2025-06-14", "2025-06-15"));
        assertEquals("3 \u05D9\u05DE\u05D9\u05DD", pt.formatAge("2025-06-12", "2025-06-15"));
        assertEquals("\u05E9\u05D1\u05D5\u05E2\u05D9\u05D9\u05DD", pt.formatAge("2025-06-01", "2025-06-15"));
        assertEquals("3 \u05E9\u05D1\u05D5\u05E2\u05D5\u05EA", pt.formatAge("2025-05-25", "2025-06-15"));
        assertEquals("6 \u05D7\u05D5\u05D3\u05E9\u05D9\u05DD", pt.formatAge("2025-01-15", "2025-07-15"));
        assertEquals("3 \u05D7\u05D5\u05D3\u05E9\u05D9\u05DD", pt.formatAge("2025-03-15", "2025-06-15"));
        assertEquals("\u05E9\u05E0\u05EA\u05D9\u05D9\u05DD, \u05D7\u05D5\u05D3\u05E9 1", pt.formatAge("2023-06-15", "2025-07-15"));
        assertEquals("3 \u05E9\u05E0\u05D9\u05DD \u05D5\u05D7\u05E6\u05D9", pt.formatAge("2022-06-15", "2025-12-15"));
        assertEquals("7 \u05E9\u05E0\u05D9\u05DD", pt.formatAge("2018-06-15", "2025-06-15"));
        assertEquals("\u05E8\u05E7 \u05E0\u05D5\u05DC\u05D3", pt.formatStage("2025-06-15", "2025-06-15", "m"));
        assertEquals("\u05E8\u05E7 \u05E0\u05D5\u05DC\u05D3\u05D4", pt.formatStage("2025-06-15", "2025-06-15", "f"));
        assertEquals("\u05DE\u05D1\u05D5\u05D2\u05E8", pt.formatStage("2007-06-15", "2025-06-15", "m"));
        assertEquals("\u05DE\u05D1\u05D5\u05D2\u05E8\u05EA", pt.formatStage("2007-06-15", "2025-06-15", "f"));
    }

    // 29.15, 29.16, 29.17, 29.18, 29.19, 29.20, 29.21
    @Test void macedonianLocaleMod10Mod100Rule() {
        ParentTime pt = new ParentTime(Locales.MK);
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
        ParentTime pt = new ParentTime(Locales.SW);
        assertEquals("Mzaliwa mpya", pt.formatAge("2025-06-15", "2025-06-15"));
        assertEquals("siku 1", pt.formatAge("2025-06-14", "2025-06-15"));
        assertEquals("siku 3", pt.formatAge("2025-06-12", "2025-06-15"));
        assertEquals("miezi 6", pt.formatAge("2025-01-15", "2025-07-15"));
        assertEquals("miaka 2, mwezi 1", pt.formatAge("2023-06-15", "2025-07-15"));
        assertEquals("miaka 3 na nusu", pt.formatAge("2022-06-15", "2025-12-15"));
    }

    // 29.28, 29.29, 29.30, 29.31, 29.32, 29.33
    @Test void indonesianLocaleOtherOnly() {
        ParentTime pt = new ParentTime(Locales.ID);
        assertEquals("Baru lahir", pt.formatAge("2025-06-15", "2025-06-15"));
        assertEquals("1 hari", pt.formatAge("2025-06-14", "2025-06-15"));
        assertEquals("3 hari", pt.formatAge("2025-06-12", "2025-06-15"));
        assertEquals("6 bulan", pt.formatAge("2025-01-15", "2025-07-15"));
        assertEquals("3 tahun setengah", pt.formatAge("2022-06-15", "2025-12-15"));
        assertEquals("7 tahun", pt.formatAge("2018-06-15", "2025-06-15"));
    }

    // 29.34, 29.35, 29.36, 29.37, 29.38, 29.39
    @Test void amharicLocaleEthiopicDelimiter() {
        ParentTime pt = new ParentTime(Locales.AM);
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
}
