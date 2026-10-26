import Testing
@testable import SayableTime

@Suite struct FormatTimeTests {

    // ================================================================
    // Null / edge cases
    // ================================================================
    // 1.1
    @Test func nullTimeReturnsNil() {
        let st = SayableTimeFormatter(Locales.EN)
        #expect(st.formatTime(nil) == nil)
    }

    // 1.2
    @Test func emptyStringReturnsNil() {
        let st = SayableTimeFormatter(Locales.EN)
        #expect(st.formatTime("") == nil)
    }

    // 1.3
    @Test func invalidTimeReturnsNil() {
        let st = SayableTimeFormatter(Locales.EN)
        #expect(st.formatTime("invalid") == nil)
    }

    // 1.4
    @Test func outOfRangeHourReturnsNil() {
        let st = SayableTimeFormatter(Locales.EN)
        #expect(st.formatTime("25:00") == nil)
    }

    // ================================================================
    // Clock time (normal compactness)
    // ================================================================
    // 2.1
    @Test func midnight() {
        let st = SayableTimeFormatter(Locales.EN)
        #expect(st.formatTime("00:00") == "midnight")
    }

    // 2.2
    @Test func noon() {
        let st = SayableTimeFormatter(Locales.EN)
        #expect(st.formatTime("12:00") == "noon")
    }

    // 2.3
    @Test func threeOClock() {
        let st = SayableTimeFormatter(Locales.EN)
        #expect(st.formatTime("15:00") == "three o'clock")
    }

    // 2.4
    @Test func quarterPastTwo() {
        let st = SayableTimeFormatter(Locales.EN)
        #expect(st.formatTime("14:15") == "a quarter past two")
    }

    // 2.5
    @Test func halfPastNine() {
        let st = SayableTimeFormatter(Locales.EN)
        #expect(st.formatTime("09:30") == "half past nine")
    }

    // 2.6
    @Test func quarterToEleven() {
        let st = SayableTimeFormatter(Locales.EN)
        #expect(st.formatTime("10:45") == "a quarter to eleven")
    }

    // 2.7
    @Test func fivePastEight() {
        let st = SayableTimeFormatter(Locales.EN)
        #expect(st.formatTime("08:05") == "five past eight")
    }

    // 2.8
    @Test func fiveToFive() {
        let st = SayableTimeFormatter(Locales.EN)
        #expect(st.formatTime("16:55") == "five to five")
    }

    // 2.9
    @Test func roundsToMidnight() {
        let st = SayableTimeFormatter(Locales.EN)
        #expect(st.formatTime("23:58") == "midnight")
    }

    // 2.10
    @Test func twentyPastSeven() {
        let st = SayableTimeFormatter(Locales.EN)
        #expect(st.formatTime("07:22") == "twenty past seven")
    }

    // 2.11
    @Test func isoDatetimeInput() {
        let st = SayableTimeFormatter(Locales.EN)
        #expect(st.formatTime("2025-01-15T14:15:00") == "a quarter past two")
    }

    // ================================================================
    // Clock time (short compactness)
    // ================================================================
    // 3.1
    @Test func shortPm() {
        let st = SayableTimeFormatter(Locales.EN, compactness: .short)
        #expect(st.formatTime("14:15") == "2:15 PM")
    }

    // 3.2
    @Test func shortAm() {
        let st = SayableTimeFormatter(Locales.EN, compactness: .short)
        #expect(st.formatTime("09:30") == "9:30 AM")
    }

    // 3.3
    @Test func shortMidnightIs12Am() {
        let st = SayableTimeFormatter(Locales.EN, compactness: .short)
        #expect(st.formatTime("00:00") == "12:00 AM")
    }

    // 3.4
    @Test func shortNoonIs12Pm() {
        let st = SayableTimeFormatter(Locales.EN, compactness: .short)
        #expect(st.formatTime("12:00") == "12:00 PM")
    }

    // ================================================================
    // Clock time (compact)
    // ================================================================
    // 4.1
    @Test func compactPm() {
        let st = SayableTimeFormatter(Locales.EN, compactness: .compact)
        #expect(st.formatTime("14:15") == "2:15p")
    }

    // 4.2
    @Test func compactAm() {
        let st = SayableTimeFormatter(Locales.EN, compactness: .compact)
        #expect(st.formatTime("09:30") == "9:30a")
    }

    // ================================================================
    // Locale -- German
    // ================================================================
    // 5.1
    @Test func germanHalbVier() {
        let st = SayableTimeFormatter(Locales.DE)
        #expect(st.formatTime("15:30") == "halb vier")
    }

    // ================================================================
    // Locale -- French
    // ================================================================
    // 6.1
    @Test func frenchTroisHeuresEtQuart() {
        let st = SayableTimeFormatter(Locales.FR)
        #expect(st.formatTime("15:15") == "trois heures et quart")
    }

    // 6.2
    @Test func frenchSingularHour() {
        let st = SayableTimeFormatter(Locales.FR)
        #expect(st.formatTime("13:00") == "une heure")
    }

    // 6.3
    @Test func frenchHalfPastSingularHour() {
        let st = SayableTimeFormatter(Locales.FR)
        #expect(st.formatTime("13:30") == "une heure et demie")
    }

    // 6.4
    @Test func frenchQuarterTo() {
        let st = SayableTimeFormatter(Locales.FR)
        #expect(st.formatTime("14:45") == "trois heures moins le quart")
    }

    // 6.5
    @Test func frenchTenTo() {
        let st = SayableTimeFormatter(Locales.FR)
        #expect(st.formatTime("14:50") == "trois heures moins dix")
    }

    // ================================================================
    // Locale -- Japanese
    // ================================================================
    // 7.1
    @Test func japaneseSanjiHan() {
        let st = SayableTimeFormatter(Locales.JA)
        #expect(st.formatTime("15:30") == "\u{4E09}\u{6642}\u{534A}")
    }

    // ================================================================
    // Locale -- Finnish (dot separator, short)
    // ================================================================
    // 8.1
    @Test func finnishDotSeparator() {
        let st = SayableTimeFormatter(Locales.FI, compactness: .short)
        #expect(st.formatTime("14:15") == "14.15")
    }

    // 8.2
    @Test func finnishMidnightDot() {
        let st = SayableTimeFormatter(Locales.FI, compactness: .short)
        #expect(st.formatTime("00:00") == "0.00")
    }

    // ================================================================
    // Minutes in short and compact modes
    // ================================================================
    // 9.1
    @Test func canonical9_1() {
        #expect(SayableTimeFormatter(Locales.get("en")!, compactness: .short).formatTime("18:01") == "6:01 PM")
    }

    // 9.2
    @Test func canonical9_2() {
        #expect(SayableTimeFormatter(Locales.get("en")!, compactness: .compact).formatTime("19:05") == "7:05p")
    }


    // ================================================================
    // Input validation
    // ================================================================
    // 10.1
    @Test func canonical10_1() {
        #expect(SayableTimeFormatter(Locales.get("en")!).formatTime("9:30") == "half past nine")
    }

    // 10.2
    @Test func canonical10_2() {
        #expect(SayableTimeFormatter(Locales.get("en")!).formatTime("09:30") == "half past nine")
    }

    // 10.3
    @Test func canonical10_3() {
        #expect(SayableTimeFormatter(Locales.get("en")!).formatTime(" 9:30") == nil)
    }

    // 10.4
    @Test func canonical10_4() {
        #expect(SayableTimeFormatter(Locales.get("en")!).formatTime("9:30 ") == nil)
    }

    // 10.5
    @Test func canonical10_5() {
        #expect(SayableTimeFormatter(Locales.get("en")!).formatTime("9:5") == nil)
    }

    // 10.6
    @Test func canonical10_6() {
        #expect(SayableTimeFormatter(Locales.get("en")!).formatTime("24:00") == nil)
    }

    // 10.7
    @Test func canonical10_7() {
        #expect(SayableTimeFormatter(Locales.get("en")!).formatTime("14:15:30") == "a quarter past two")
    }

    // 10.8
    @Test func canonical10_8() {
        #expect(SayableTimeFormatter(Locales.get("en")!).formatTime("2025-01-15T14:15:00Z") == "a quarter past two")
    }

    // 10.9
    @Test func canonical10_9() {
        #expect(SayableTimeFormatter(Locales.get("en")!).formatTime("2025-02-30T14:15:00") == nil)
    }
}
