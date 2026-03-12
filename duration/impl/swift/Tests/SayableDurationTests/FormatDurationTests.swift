import Testing
@testable import SayableDuration

@Suite struct FormatDurationTests {

    // ================================================================
    // Null / edge cases
    // ================================================================
    // 1.1
    @Test func nullSecondsReturnsNil() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(nil) == nil)
    }

    // 1.2
    @Test func negativeSecondsReturnsNil() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(-1) == nil)
    }

    // 1.3
    @Test func nullStartForSinceReturnsNil() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatSince(start: nil, asOf: "2025-01-15T10:00:00") == nil)
    }

    // 1.4
    @Test func nullTargetForUntilReturnsNil() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatUntil(target: nil, asOf: "2025-01-15T10:00:00") == nil)
    }

    // 1.5
    @Test func sinceAsOfBeforeStartReturnsNil() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatSince(start: "2025-01-15T10:00:00", asOf: "2025-01-15T09:00:00") == nil)
    }

    // 1.6
    @Test func untilTargetInPastReturnsNil() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatUntil(target: "2025-01-15T09:00:00", asOf: "2025-01-15T10:00:00") == nil)
    }

    // ================================================================
    // Duration -- seconds tier (0-59s)
    // ================================================================
    // 2.1
    @Test func zeroSecondsIsJustNow() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(0) == "just now")
    }

    // 2.2
    @Test func oneSecond() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(1) == "1 second")
    }

    // 2.3
    @Test func fortyFiveSeconds() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(45) == "45 seconds")
    }

    // 2.4
    @Test func fiftyNineSeconds() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(59) == "59 seconds")
    }

    // ================================================================
    // Duration -- minutes + seconds tier (1-4 min)
    // ================================================================
    // 3.1
    @Test func oneMinute() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(60) == "1 minute")
    }

    // 3.2
    @Test func oneMinuteThirtySeconds() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(90) == "1 minute, 30 seconds")
    }

    // 3.3
    @Test func fourMinutes() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(240) == "4 minutes")
    }

    // 3.4
    @Test func fourMinutesThirtySeconds() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(270) == "4 minutes, 30 seconds")
    }

    // ================================================================
    // Duration -- minutes tier (5-59 min)
    // ================================================================
    // 4.1
    @Test func fiveMinutes() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(300) == "5 minutes")
    }

    // 4.2
    @Test func twentyFiveMinutes() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(1500) == "25 minutes")
    }

    // 4.3
    @Test func fiftyNineMinutes() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(3540) == "59 minutes")
    }

    // ================================================================
    // Duration -- hours + minutes tier (1-5 hr)
    // ================================================================
    // 5.1
    @Test func oneHour() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(3600) == "1 hour")
    }

    // 5.2
    @Test func oneAndHalfHours() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(5400) == "1\u{00BD} hours")
    }

    // 5.3
    @Test func twoHoursFifteenMinutes() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(8100) == "2 hours, 15 minutes")
    }

    // 5.4
    @Test func fiveHours() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(18000) == "5 hours")
    }

    // ================================================================
    // Duration -- hours tier (6-23 hr)
    // ================================================================
    // 6.1
    @Test func eightHours() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(28800) == "8 hours")
    }

    // 6.2
    @Test func twentyThreeHours() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(82800) == "23 hours")
    }

    // ================================================================
    // Duration -- days tier
    // ================================================================
    // 7.1
    @Test func oneDay() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(86400) == "1 day")
    }

    // 7.2
    @Test func oneDayThreeHours() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(97200) == "1 day, 3 hours")
    }

    // 7.3
    @Test func oneAndHalfDays() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(129600) == "1\u{00BD} days")
    }

    // 7.4
    @Test func fiveDays() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(432000) == "5 days")
    }

    // 7.5
    @Test func twoDays() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(172800) == "2 days")
    }

    // ================================================================
    // Duration -- weeks tier
    // ================================================================
    // 8.1
    @Test func oneWeek() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(604800) == "1 week")
    }

    // 8.2
    @Test func twoWeeksOneDay() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(1296000) == "2 weeks, 1 day")
    }

    // 8.3
    @Test func fourWeeks() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(2419200) == "4 weeks")
    }

    // ================================================================
    // Duration -- months and years tier
    // ================================================================
    // 9.1
    @Test func oneMonth() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(2678400) == "1 month")
    }

    // 9.2
    @Test func threeMonths() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(7884000) == "3 months")
    }

    // 9.3
    @Test func oneYear() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(31536000) == "1 year")
    }

    // 9.4
    @Test func oneYearThreeMonths() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(39420000) == "1 year, 3 months")
    }

    // ================================================================
    // Duration from ISO timestamps
    // ================================================================
    // 10.1
    @Test func isoTimestampsOneAndHalfHours() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(start: "2025-01-15T10:00:00", end: "2025-01-15T11:30:00") == "1\u{00BD} hours")
    }

    // 10.2
    @Test func isoTimestampsFortyFiveMinutes() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatDuration(start: "2025-01-15T10:00:00", end: "2025-01-15T10:45:00") == "45 minutes")
    }

    // ================================================================
    // Relative time -- since
    // ================================================================
    // 11.1
    @Test func sinceJustNow() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatSince(start: "2025-01-15T10:00:00", asOf: "2025-01-15T10:00:00") == "just now")
    }

    // 11.2
    @Test func sinceThirtySecondsAgo() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatSince(start: "2025-01-15T10:00:00", asOf: "2025-01-15T10:00:30") == "30 seconds ago")
    }

    // 11.3
    @Test func sinceFortyFiveMinutesAgo() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatSince(start: "2025-01-15T10:00:00", asOf: "2025-01-15T10:45:00") == "45 minutes ago")
    }

    // 11.4
    @Test func sinceThreeHoursAgo() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatSince(start: "2025-01-15T10:00:00", asOf: "2025-01-15T13:00:00") == "3 hours ago")
    }

    // ================================================================
    // Relative time -- until
    // ================================================================
    // 12.1
    @Test func untilJustNow() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatUntil(target: "2025-01-15T10:00:00", asOf: "2025-01-15T10:00:00") == "just now")
    }

    // 12.2
    @Test func untilTwentyMinutes() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatUntil(target: "2025-01-15T10:20:00", asOf: "2025-01-15T10:00:00") == "in 20 minutes")
    }

    // 12.3
    @Test func untilThreeHours() {
        let sd = SayableDurationFormatter(Locales.EN)
        #expect(sd.formatUntil(target: "2025-01-15T13:00:00", asOf: "2025-01-15T10:00:00") == "in 3 hours")
    }

    // ================================================================
    // Locale -- German
    // ================================================================
    // 13.1
    @Test func germanOneHour() {
        let sd = SayableDurationFormatter(Locales.DE)
        #expect(sd.formatDuration(3600) == "1 Stunde")
    }

    // 13.2
    @Test func germanFiveMinutesAgo() {
        let sd = SayableDurationFormatter(Locales.DE)
        #expect(sd.formatSince(start: "2025-01-15T10:00:00", asOf: "2025-01-15T10:05:00") == "vor 5 Minuten")
    }

    // ================================================================
    // Locale -- French
    // ================================================================
    // 14.1
    @Test func frenchTwoHours() {
        let sd = SayableDurationFormatter(Locales.FR)
        #expect(sd.formatDuration(7200) == "2 heures")
    }

    // ================================================================
    // Locale -- Japanese
    // ================================================================
    // 15.1
    @Test func japaneseTwoMinutes() {
        let sd = SayableDurationFormatter(Locales.JA)
        #expect(sd.formatDuration(120) == "2\u{5206}")
    }

    // 15.2
    @Test func japaneseOneHourAgo() {
        let sd = SayableDurationFormatter(Locales.JA)
        #expect(sd.formatSince(start: "2025-01-15T10:00:00", asOf: "2025-01-15T11:00:00") == "1\u{6642}\u{9593}\u{524D}")
    }

    // ================================================================
    // Short compactness -- duration
    // ================================================================
    // 16.1
    @Test func shortOneHour() {
        let sd = SayableDurationFormatter(Locales.EN, compactness: .short)
        #expect(sd.formatDuration(3600) == "1h")
    }

    // 16.2
    @Test func shortOneMinuteThirtySeconds() {
        let sd = SayableDurationFormatter(Locales.EN, compactness: .short)
        #expect(sd.formatDuration(90) == "1m, 30s")
    }

    // ================================================================
    // Compact compactness -- duration
    // ================================================================
    // 17.1
    @Test func compactOneHour() {
        let sd = SayableDurationFormatter(Locales.EN, compactness: .compact)
        #expect(sd.formatDuration(3600) == "1h")
    }

    // 17.2
    @Test func compactOneMinuteThirtySeconds() {
        let sd = SayableDurationFormatter(Locales.EN, compactness: .compact)
        #expect(sd.formatDuration(90) == "1m30s")
    }
}
