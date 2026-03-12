import Testing
@testable import SayableDate

@Suite struct FormatDateTests {

    // ================================================================
    // Null / edge cases
    // ================================================================
    // 1.1
    @Test func nullDateReturnsNil() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatDate(nil) == nil)
    }

    // 1.2
    @Test func emptyStringReturnsNil() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatDate("") == nil)
    }

    // 1.3
    @Test func invalidDateReturnsNil() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatDate("invalid") == nil)
    }

    // 1.4
    @Test func nullAsOfReturnsNil() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatRelative("2025-03-15", asOf: nil) == nil)
    }

    // 1.5
    @Test func nullDateForRelativeReturnsNil() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatRelative(nil, asOf: "2025-03-15") == nil)
    }

    // ================================================================
    // format_date -- normal compactness (English)
    // ================================================================
    // 2.1
    @Test func formatDateMarch15th() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatDate("2025-03-15") == "March 15th")
    }

    // 2.2
    @Test func formatDateJanuary1st() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatDate("2025-01-01") == "January 1st")
    }

    // 2.3
    @Test func formatDateMay22nd() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatDate("2025-05-22") == "May 22nd")
    }

    // 2.4
    @Test func formatDateJuly3rd() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatDate("2025-07-03") == "July 3rd")
    }

    // 2.5
    @Test func formatDateDecember31st() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatDate("2025-12-31") == "December 31st")
    }

    // 2.6
    @Test func formatDateJune11th() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatDate("2025-06-11") == "June 11th")
    }

    // 2.7
    @Test func formatDateIsoDatetime() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatDate("2025-03-15T14:30:00") == "March 15th")
    }

    // ================================================================
    // format_date -- short compactness (English)
    // ================================================================
    // 3.1
    @Test func shortMarch15() {
        let sd = SayableDateFormatter(Locales.EN, compactness: .short)
        #expect(sd.formatDate("2025-03-15") == "Mar 15")
    }

    // 3.2
    @Test func shortJanuary1() {
        let sd = SayableDateFormatter(Locales.EN, compactness: .short)
        #expect(sd.formatDate("2025-01-01") == "Jan 1")
    }

    // 3.3
    @Test func shortDecember25() {
        let sd = SayableDateFormatter(Locales.EN, compactness: .short)
        #expect(sd.formatDate("2025-12-25") == "Dec 25")
    }

    // ================================================================
    // format_date -- compact (English)
    // ================================================================
    // 4.1
    @Test func compactMarch15() {
        let sd = SayableDateFormatter(Locales.EN, compactness: .compact)
        #expect(sd.formatDate("2025-03-15") == "3/15")
    }

    // 4.2
    @Test func compactJanuary1() {
        let sd = SayableDateFormatter(Locales.EN, compactness: .compact)
        #expect(sd.formatDate("2025-01-01") == "1/1")
    }

    // ================================================================
    // format_relative -- proximity tiers (English)
    // ================================================================
    // 5.1
    @Test func relativeToday() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatRelative("2025-03-15", asOf: "2025-03-15") == "today")
    }

    // 5.2
    @Test func relativeTomorrow() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatRelative("2025-03-16", asOf: "2025-03-15") == "tomorrow")
    }

    // 5.3
    @Test func relativeYesterday() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatRelative("2025-03-14", asOf: "2025-03-15") == "yesterday")
    }

    // 5.4
    @Test func relativeDayAfterTomorrow() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatRelative("2025-03-17", asOf: "2025-03-15") == "the day after tomorrow")
    }

    // 5.5
    @Test func relativeDayBeforeYesterday() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatRelative("2025-03-13", asOf: "2025-03-15") == "the day before yesterday")
    }

    // 5.6
    @Test func relativeThisWednesday() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatRelative("2025-03-19", asOf: "2025-03-15") == "this Wednesday")
    }

    // 5.7
    @Test func relativeThisThursday() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatRelative("2025-03-20", asOf: "2025-03-15") == "this Thursday")
    }

    // 5.8
    @Test func relativeLastTuesday() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatRelative("2025-03-11", asOf: "2025-03-15") == "last Tuesday")
    }

    // 5.9
    @Test func relativeNextSaturday() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatRelative("2025-03-22", asOf: "2025-03-15") == "next Saturday")
    }

    // 5.10
    @Test func relativeNextThursday() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatRelative("2025-03-27", asOf: "2025-03-15") == "next Thursday")
    }

    // 5.11
    @Test func relativeCalendarFallbackSameYear() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatRelative("2025-03-01", asOf: "2025-03-15") == "March 1st")
    }

    // 5.12
    @Test func relativeCalendarFallbackFutureSameYear() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatRelative("2025-04-10", asOf: "2025-03-15") == "April 10th")
    }

    // 5.13
    @Test func relativeDifferentYearFuture() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatRelative("2026-01-05", asOf: "2025-03-15") == "January 5th, 2026")
    }

    // 5.14
    @Test func relativeDifferentYearPast() {
        let sd = SayableDateFormatter(Locales.EN)
        #expect(sd.formatRelative("2024-12-25", asOf: "2025-03-15") == "December 25th, 2024")
    }

    // ================================================================
    // format_relative -- compact skips weekday tiers
    // ================================================================
    // 6.1
    @Test func compactRelativeToday() {
        let sd = SayableDateFormatter(Locales.EN, compactness: .compact)
        #expect(sd.formatRelative("2025-03-15", asOf: "2025-03-15") == "today")
    }

    // 6.2
    @Test func compactRelativeTomorrow() {
        let sd = SayableDateFormatter(Locales.EN, compactness: .compact)
        #expect(sd.formatRelative("2025-03-16", asOf: "2025-03-15") == "tomorrow")
    }

    // 6.3
    @Test func compactRelativeSkipsWeekday() {
        let sd = SayableDateFormatter(Locales.EN, compactness: .compact)
        #expect(sd.formatRelative("2025-03-19", asOf: "2025-03-15") == "3/19")
    }

    // 6.4
    @Test func compactRelativeDifferentYear() {
        let sd = SayableDateFormatter(Locales.EN, compactness: .compact)
        #expect(sd.formatRelative("2026-01-05", asOf: "2025-03-15") == "1/5/26")
    }

    // ================================================================
    // Locale -- German
    // ================================================================
    // 7.1
    @Test func germanFormatDate() {
        let sd = SayableDateFormatter(Locales.DE)
        #expect(sd.formatDate("2025-03-15") == "15. M\u{00E4}rz")
    }

    // 7.2
    @Test func germanRelativeTomorrow() {
        let sd = SayableDateFormatter(Locales.DE)
        #expect(sd.formatRelative("2025-03-16", asOf: "2025-03-15") == "morgen")
    }

    // 7.3
    @Test func germanRelativeDayAfterTomorrow() {
        let sd = SayableDateFormatter(Locales.DE)
        #expect(sd.formatRelative("2025-03-17", asOf: "2025-03-15") == "\u{00FC}bermorgen")
    }

    // 7.4
    @Test func germanRelativeThisWednesday() {
        let sd = SayableDateFormatter(Locales.DE)
        #expect(sd.formatRelative("2025-03-19", asOf: "2025-03-15") == "diesen Mittwoch")
    }

    // ================================================================
    // Locale -- French
    // ================================================================
    // 8.1
    @Test func frenchFormatDate1erMars() {
        let sd = SayableDateFormatter(Locales.FR)
        #expect(sd.formatDate("2025-03-01") == "1er mars")
    }

    // 8.2
    @Test func frenchFormatDate15Mars() {
        let sd = SayableDateFormatter(Locales.FR)
        #expect(sd.formatDate("2025-03-15") == "15 mars")
    }

    // 8.3
    @Test func frenchRelativeTomorrow() {
        let sd = SayableDateFormatter(Locales.FR)
        #expect(sd.formatRelative("2025-03-16", asOf: "2025-03-15") == "demain")
    }

    // ================================================================
    // Locale -- Japanese
    // ================================================================
    // 9.1
    @Test func japaneseFormatDate() {
        let sd = SayableDateFormatter(Locales.JA)
        #expect(sd.formatDate("2025-03-15") == "3\u{6708}15\u{65E5}")
    }

    // 9.2
    @Test func japaneseRelativeTomorrow() {
        let sd = SayableDateFormatter(Locales.JA)
        #expect(sd.formatRelative("2025-03-16", asOf: "2025-03-15") == "\u{660E}\u{65E5}")
    }

    // 9.3
    @Test func japaneseRelativeThisWednesday() {
        let sd = SayableDateFormatter(Locales.JA)
        #expect(sd.formatRelative("2025-03-19", asOf: "2025-03-15") == "\u{4ECA}\u{5EA6}\u{306E}\u{6C34}\u{66DC}\u{65E5}")
    }

    // ================================================================
    // Locale -- Russian (genitive months)
    // ================================================================
    // 10.1
    @Test func russianFormatDateGenitiveMonth() {
        let sd = SayableDateFormatter(Locales.RU)
        #expect(sd.formatDate("2025-03-15") == "15 \u{043C}\u{0430}\u{0440}\u{0442}\u{0430}")
    }

    // 10.2
    @Test func russianRelativeTomorrow() {
        let sd = SayableDateFormatter(Locales.RU)
        #expect(sd.formatRelative("2025-03-16", asOf: "2025-03-15") == "\u{0437}\u{0430}\u{0432}\u{0442}\u{0440}\u{0430}")
    }

    // ================================================================
    // Locale -- Arabic
    // ================================================================
    // 11.1
    @Test func arabicFormatDate() {
        let sd = SayableDateFormatter(Locales.AR)
        #expect(sd.formatDate("2025-03-15") == "15 \u{0645}\u{0627}\u{0631}\u{0633}")
    }

    // 11.2
    @Test func arabicRelativeTomorrow() {
        let sd = SayableDateFormatter(Locales.AR)
        #expect(sd.formatRelative("2025-03-16", asOf: "2025-03-15") == "\u{063A}\u{062F}\u{0627}\u{064B}")
    }

    // ================================================================
    // Locale -- Spanish
    // ================================================================
    // 12.1
    @Test func spanishFormatDate() {
        let sd = SayableDateFormatter(Locales.ES)
        #expect(sd.formatDate("2025-03-15") == "15 de marzo")
    }

    // 12.2
    @Test func spanishRelativeDayAfterTomorrow() {
        let sd = SayableDateFormatter(Locales.ES)
        #expect(sd.formatRelative("2025-03-17", asOf: "2025-03-15") == "pasado ma\u{00F1}ana")
    }
}
