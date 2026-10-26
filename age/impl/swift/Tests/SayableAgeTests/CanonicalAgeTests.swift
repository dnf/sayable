import Testing
@testable import SayableAge

// Canonical tests (age/config/tests.json) not covered one-to-one by FormatAgeTests.swift.
@Suite struct CanonicalAgeTests {
    // 1.1
    @Test func canonical_1_1() {
        #expect(SayableAgeFormatter(Locales.EN).formatAge(nil) == nil)
    }

    // 16.1
    @Test func canonical_16_1() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage(nil) == nil)
    }

    // 16.3
    @Test func canonical_16_3() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage(nil) == nil)
    }

    // 16.4
    @Test func canonical_16_4() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2025-07-01", "2025-06-15") == nil)
    }

    // 16.5
    @Test func canonical_16_5() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("1525-06-15", "2025-06-15") == "Adult")
    }

    // 16.6
    @Test func canonical_16_6() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("1524-06-15", "2025-06-15") == nil)
    }

    // 17.1
    @Test func canonical_17_1() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2025-06-15", "2025-06-15") == "Newborn")
    }

    // 17.2
    @Test func canonical_17_2() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2025-06-14", "2025-06-15") == "Newborn")
    }

    // 17.3
    @Test func canonical_17_3() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2025-05-25", "2025-06-15") == "Newborn")
    }

    // 17.4
    @Test func canonical_17_4() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2025-05-15", "2025-06-15") == "Newborn")
    }

    // 17.5
    @Test func canonical_17_5() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2025-04-16", "2025-06-15") == "Newborn")
    }

    // 17.6
    @Test func canonical_17_6() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2025-04-15", "2025-06-15") == "Infant")
    }

    // 18.1
    @Test func canonical_18_1() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2025-04-15", "2025-06-15") == "Infant")
    }

    // 18.2
    @Test func canonical_18_2() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2024-12-15", "2025-06-15") == "Infant")
    }

    // 18.3
    @Test func canonical_18_3() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2024-07-15", "2025-06-15") == "Infant")
    }

    // 18.4
    @Test func canonical_18_4() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2024-06-15", "2025-06-15") == "Toddler")
    }

    // 19.1
    @Test func canonical_19_1() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2024-06-15", "2025-06-15") == "Toddler")
    }

    // 19.2
    @Test func canonical_19_2() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2024-01-15", "2025-07-15") == "Toddler")
    }

    // 19.3
    @Test func canonical_19_3() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2023-06-15", "2025-06-15") == "Toddler")
    }

    // 19.4
    @Test func canonical_19_4() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2023-06-15", "2026-05-15") == "Toddler")
    }

    // 19.5
    @Test func canonical_19_5() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2022-06-15", "2025-06-15") == "Child")
    }

    // 20.1
    @Test func canonical_20_1() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2022-06-15", "2025-06-15") == "Child")
    }

    // 20.2
    @Test func canonical_20_2() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2021-06-15", "2025-06-15") == "Child")
    }

    // 20.3
    @Test func canonical_20_3() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2019-06-15", "2025-06-15") == "Child")
    }

    // 20.4
    @Test func canonical_20_4() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2016-06-15", "2025-06-15") == "Child")
    }

    // 20.5
    @Test func canonical_20_5() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2013-06-15", "2026-05-15") == "Child")
    }

    // 20.6
    @Test func canonical_20_6() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2012-06-15", "2025-06-15") == "Teenager")
    }

    // 21.1
    @Test func canonical_21_1() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2012-06-15", "2025-06-15") == "Teenager")
    }

    // 21.2
    @Test func canonical_21_2() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2010-06-15", "2025-06-15") == "Teenager")
    }

    // 21.3
    @Test func canonical_21_3() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2008-06-15", "2026-05-15") == "Teenager")
    }

    // 21.4
    @Test func canonical_21_4() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2007-06-15", "2025-06-15") == "Adult")
    }

    // 22.1
    @Test func canonical_22_1() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2007-06-15", "2025-06-15") == "Adult")
    }

    // 22.2
    @Test func canonical_22_2() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2000-06-15", "2025-06-15") == "Adult")
    }

    // 22.3
    @Test func canonical_22_3() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("1980-01-01", "2025-06-15") == "Adult")
    }

    // 24.1
    @Test func canonical_24_1() {
        #expect(SayableAgeFormatter(Locales.EN).formatAge("2025-06-15", "2025-06-15") == "Newborn")
    }

    // 24.2
    @Test func canonical_24_2() {
        #expect(SayableAgeFormatter(Locales.EN).formatAge("2025-06-12", "2025-06-15") == "3 days")
    }

    // 24.3
    @Test func canonical_24_3() {
        #expect(SayableAgeFormatter(Locales.EN).formatAge("2025-06-07", "2025-06-15") == "1 week, 1 day")
    }

    // 24.4
    @Test func canonical_24_4() {
        #expect(SayableAgeFormatter(Locales.EN).formatAge("2025-01-15", "2025-07-15") == "6 months")
    }

    // 24.5
    @Test func canonical_24_5() {
        #expect(SayableAgeFormatter(Locales.EN).formatAge("2023-06-15", "2025-07-15") == "2 years, 1 month")
    }

    // 24.6
    @Test func canonical_24_6() {
        #expect(SayableAgeFormatter(Locales.EN).formatAge("2022-06-15", "2025-12-15") == "3½ years")
    }

    // 24.7
    @Test func canonical_24_7() {
        #expect(SayableAgeFormatter(Locales.EN).formatAge("2018-06-15", "2025-06-15") == "7 years")
    }

    // 24.8
    @Test func canonical_24_8() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2025-06-15", "2025-06-15") == "Newborn")
    }

    // 24.9
    @Test func canonical_24_9() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2025-01-15", "2025-06-15") == "Infant")
    }

    // 24.10
    @Test func canonical_24_10() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2024-06-15", "2025-06-15") == "Toddler")
    }

    // 24.11
    @Test func canonical_24_11() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2022-06-15", "2025-06-15") == "Child")
    }

    // 24.12
    @Test func canonical_24_12() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2012-06-15", "2025-06-15") == "Teenager")
    }

    // 24.13
    @Test func canonical_24_13() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage("2007-06-15", "2025-06-15") == "Adult")
    }

    // 24.14
    @Test func canonical_24_14() {
        #expect(SayableAgeFormatter(Locales.EN).formatAge(nil, "2025-06-15") == nil)
    }

    // 24.15
    @Test func canonical_24_15() {
        #expect(SayableAgeFormatter(Locales.EN).formatStage(nil, "2025-06-15") == nil)
    }

    // 25.1
    @Test func canonical_25_1() {
        #expect(SayableAgeFormatter(Locales.ES).formatAge("2025-06-15", "2025-06-15") == "Recién nacido")
    }

    // 25.2
    @Test func canonical_25_2() {
        #expect(SayableAgeFormatter(Locales.ES).formatAge("2025-06-14", "2025-06-15") == "1 día")
    }

    // 25.3
    @Test func canonical_25_3() {
        #expect(SayableAgeFormatter(Locales.ES).formatAge("2025-06-12", "2025-06-15") == "3 días")
    }

    // 25.4
    @Test func canonical_25_4() {
        #expect(SayableAgeFormatter(Locales.ES).formatAge("2025-06-08", "2025-06-15") == "1 semana")
    }

    // 25.5
    @Test func canonical_25_5() {
        #expect(SayableAgeFormatter(Locales.ES).formatAge("2025-06-07", "2025-06-15") == "1 semana, 1 día")
    }

    // 25.6
    @Test func canonical_25_6() {
        #expect(SayableAgeFormatter(Locales.ES).formatAge("2025-05-26", "2025-06-15") == "2 semanas, 6 días")
    }

    // 25.7
    @Test func canonical_25_7() {
        #expect(SayableAgeFormatter(Locales.ES).formatAge("2025-01-15", "2025-07-15") == "6 meses")
    }

    // 25.8
    @Test func canonical_25_8() {
        #expect(SayableAgeFormatter(Locales.ES).formatAge("2023-06-15", "2025-07-15") == "2 años, 1 mes")
    }

    // 25.9
    @Test func canonical_25_9() {
        #expect(SayableAgeFormatter(Locales.ES).formatAge("2023-06-15", "2025-12-15") == "2 años, 6 meses")
    }

    // 25.10
    @Test func canonical_25_10() {
        #expect(SayableAgeFormatter(Locales.ES).formatAge("2022-06-15", "2025-12-15") == "3 años y medio")
    }

    // 25.11
    @Test func canonical_25_11() {
        #expect(SayableAgeFormatter(Locales.ES).formatAge("2022-06-15", "2025-06-15") == "3 años")
    }

    // 25.12
    @Test func canonical_25_12() {
        #expect(SayableAgeFormatter(Locales.ES).formatAge("2018-06-15", "2025-06-15") == "7 años")
    }

    // 25.13
    @Test func canonical_25_13() {
        #expect(SayableAgeFormatter(Locales.ES).formatStage("2025-06-15", "2025-06-15") == "Recién nacido")
    }

    // 25.14
    @Test func canonical_25_14() {
        #expect(SayableAgeFormatter(Locales.ES).formatStage("2025-01-15", "2025-06-15") == "Bebé")
    }

    // 25.15
    @Test func canonical_25_15() {
        #expect(SayableAgeFormatter(Locales.ES).formatStage("2024-06-15", "2025-06-15") == "Niño pequeño")
    }

    // 25.16
    @Test func canonical_25_16() {
        #expect(SayableAgeFormatter(Locales.ES).formatStage("2022-06-15", "2025-06-15") == "Niño")
    }

    // 25.17
    @Test func canonical_25_17() {
        #expect(SayableAgeFormatter(Locales.ES).formatStage("2012-06-15", "2025-06-15") == "Adolescente")
    }

    // 25.18
    @Test func canonical_25_18() {
        #expect(SayableAgeFormatter(Locales.ES).formatStage("2007-06-15", "2025-06-15") == "Adulto")
    }

    // 25.19
    @Test func canonical_25_19() {
        #expect(SayableAgeFormatter(Locales.ES).formatAge(nil, "2025-06-15") == nil)
    }

    // 25.20
    @Test func canonical_25_20() {
        #expect(SayableAgeFormatter(Locales.ES).formatStage(nil, "2025-06-15") == nil)
    }

    // 26.1
    @Test func canonical_26_1() {
        #expect(SayableAgeFormatter(Locales.EN, compactness: .short).formatAge("2025-06-12", "2025-06-15") == "3 d")
    }

    // 26.2
    @Test func canonical_26_2() {
        #expect(SayableAgeFormatter(Locales.EN, compactness: .short).formatAge("2025-06-08", "2025-06-15") == "1 wk")
    }

    // 26.3
    @Test func canonical_26_3() {
        #expect(SayableAgeFormatter(Locales.EN, compactness: .short).formatAge("2025-06-07", "2025-06-15") == "1 wk, 1 d")
    }

    // 26.4
    @Test func canonical_26_4() {
        #expect(SayableAgeFormatter(Locales.EN, compactness: .short).formatAge("2025-01-15", "2025-07-15") == "6 mo")
    }

    // 26.5
    @Test func canonical_26_5() {
        #expect(SayableAgeFormatter(Locales.EN, compactness: .short).formatAge("2023-06-15", "2025-07-15") == "2 yr, 1 mo")
    }

    // 26.6
    @Test func canonical_26_6() {
        #expect(SayableAgeFormatter(Locales.EN, compactness: .short).formatAge("2022-06-15", "2025-12-15") == "3½ yr")
    }

    // 26.7
    @Test func canonical_26_7() {
        #expect(SayableAgeFormatter(Locales.EN, compactness: .short).formatAge("2018-06-15", "2025-06-15") == "7 yr")
    }

    // 26.8
    @Test func canonical_26_8() {
        #expect(SayableAgeFormatter(Locales.EN, compactness: .short).formatAge("2025-06-15", "2025-06-15") == "Newborn")
    }

    // 26.9
    @Test func canonical_26_9() {
        #expect(SayableAgeFormatter(Locales.EN, compactness: .short).formatStage("2025-01-15", "2025-06-15") == "Infant")
    }

    // 27.1
    @Test func canonical_27_1() {
        #expect(SayableAgeFormatter(Locales.EN, compactness: .compact).formatAge("2025-06-12", "2025-06-15") == "3d")
    }

    // 27.2
    @Test func canonical_27_2() {
        #expect(SayableAgeFormatter(Locales.EN, compactness: .compact).formatAge("2025-06-08", "2025-06-15") == "1w")
    }

    // 27.3
    @Test func canonical_27_3() {
        #expect(SayableAgeFormatter(Locales.EN, compactness: .compact).formatAge("2025-06-07", "2025-06-15") == "1w1d")
    }

    // 27.4
    @Test func canonical_27_4() {
        #expect(SayableAgeFormatter(Locales.EN, compactness: .compact).formatAge("2025-01-15", "2025-07-15") == "6m")
    }

    // 27.5
    @Test func canonical_27_5() {
        #expect(SayableAgeFormatter(Locales.EN, compactness: .compact).formatAge("2023-06-15", "2025-07-15") == "2y1m")
    }

    // 27.6
    @Test func canonical_27_6() {
        #expect(SayableAgeFormatter(Locales.EN, compactness: .compact).formatAge("2022-06-15", "2025-12-15") == "3½y")
    }

    // 27.7
    @Test func canonical_27_7() {
        #expect(SayableAgeFormatter(Locales.EN, compactness: .compact).formatAge("2018-06-15", "2025-06-15") == "7y")
    }

    // 27.8
    @Test func canonical_27_8() {
        #expect(SayableAgeFormatter(Locales.EN, compactness: .compact).formatAge("2025-06-15", "2025-06-15") == "Newborn")
    }

    // 29.1
    @Test func canonical_29_1() {
        #expect(SayableAgeFormatter(Locales.HE).formatAge("2025-06-15", "2025-06-15") == "רק נולד")
    }

    // 29.2
    @Test func canonical_29_2() {
        #expect(SayableAgeFormatter(Locales.HE).formatAge("2025-06-14", "2025-06-15") == "יום")
    }

    // 29.3
    @Test func canonical_29_3() {
        #expect(SayableAgeFormatter(Locales.HE).formatAge("2025-06-12", "2025-06-15") == "3 ימים")
    }

    // 29.4
    @Test func canonical_29_4() {
        #expect(SayableAgeFormatter(Locales.HE).formatAge("2025-06-01", "2025-06-15") == "שבועיים")
    }

    // 29.5
    @Test func canonical_29_5() {
        #expect(SayableAgeFormatter(Locales.HE).formatAge("2025-05-25", "2025-06-15") == "3 שבועות")
    }

    // 29.6
    @Test func canonical_29_6() {
        #expect(SayableAgeFormatter(Locales.HE).formatAge("2025-01-15", "2025-07-15") == "6 חודשים")
    }

    // 29.7
    @Test func canonical_29_7() {
        #expect(SayableAgeFormatter(Locales.HE).formatAge("2025-03-15", "2025-06-15") == "3 חודשים")
    }

    // 29.8
    @Test func canonical_29_8() {
        #expect(SayableAgeFormatter(Locales.HE).formatAge("2023-06-15", "2025-07-15") == "שנתיים, חודש")
    }

    // 29.9
    @Test func canonical_29_9() {
        #expect(SayableAgeFormatter(Locales.HE).formatAge("2022-06-15", "2025-12-15") == "3 שנים וחצי")
    }

    // 29.10
    @Test func canonical_29_10() {
        #expect(SayableAgeFormatter(Locales.HE).formatAge("2018-06-15", "2025-06-15") == "7 שנים")
    }

    // 29.11
    @Test func canonical_29_11() {
        #expect(SayableAgeFormatter(Locales.HE).formatStage("2025-06-15", "2025-06-15", gender: "m") == "רק נולד")
    }

    // 29.12
    @Test func canonical_29_12() {
        #expect(SayableAgeFormatter(Locales.HE).formatStage("2025-06-15", "2025-06-15", gender: "f") == "רק נולדה")
    }

    // 29.13
    @Test func canonical_29_13() {
        #expect(SayableAgeFormatter(Locales.HE).formatStage("2007-06-15", "2025-06-15", gender: "m") == "מבוגר")
    }

    // 29.14
    @Test func canonical_29_14() {
        #expect(SayableAgeFormatter(Locales.HE).formatStage("2007-06-15", "2025-06-15", gender: "f") == "מבוגרת")
    }

    // 29.15
    @Test func canonical_29_15() {
        #expect(SayableAgeFormatter(Locales.MK).formatAge("2025-06-15", "2025-06-15") == "Новороденче")
    }

    // 29.16
    @Test func canonical_29_16() {
        #expect(SayableAgeFormatter(Locales.MK).formatAge("2025-06-14", "2025-06-15") == "1 ден")
    }

    // 29.17
    @Test func canonical_29_17() {
        #expect(SayableAgeFormatter(Locales.MK).formatAge("2025-06-12", "2025-06-15") == "3 дена")
    }

    // 29.18
    @Test func canonical_29_18() {
        #expect(SayableAgeFormatter(Locales.MK).formatAge("2025-01-15", "2025-07-15") == "6 месеци")
    }

    // 29.19
    @Test func canonical_29_19() {
        #expect(SayableAgeFormatter(Locales.MK).formatAge("2023-06-15", "2025-07-15") == "2 години, 1 месец")
    }

    // 29.20
    @Test func canonical_29_20() {
        #expect(SayableAgeFormatter(Locales.MK).formatAge("2022-06-15", "2025-12-15") == "3 години и пол")
    }

    // 29.21
    @Test func canonical_29_21() {
        #expect(SayableAgeFormatter(Locales.MK).formatAge("2018-06-15", "2025-06-15") == "7 години")
    }

    // 29.22
    @Test func canonical_29_22() {
        #expect(SayableAgeFormatter(Locales.SW).formatAge("2025-06-15", "2025-06-15") == "Mzaliwa mpya")
    }

    // 29.23
    @Test func canonical_29_23() {
        #expect(SayableAgeFormatter(Locales.SW).formatAge("2025-06-14", "2025-06-15") == "siku 1")
    }

    // 29.24
    @Test func canonical_29_24() {
        #expect(SayableAgeFormatter(Locales.SW).formatAge("2025-06-12", "2025-06-15") == "siku 3")
    }

    // 29.25
    @Test func canonical_29_25() {
        #expect(SayableAgeFormatter(Locales.SW).formatAge("2025-01-15", "2025-07-15") == "miezi 6")
    }

    // 29.26
    @Test func canonical_29_26() {
        #expect(SayableAgeFormatter(Locales.SW).formatAge("2023-06-15", "2025-07-15") == "miaka 2, mwezi 1")
    }

    // 29.27
    @Test func canonical_29_27() {
        #expect(SayableAgeFormatter(Locales.SW).formatAge("2022-06-15", "2025-12-15") == "miaka 3 na nusu")
    }

    // 29.28
    @Test func canonical_29_28() {
        #expect(SayableAgeFormatter(Locales.ID).formatAge("2025-06-15", "2025-06-15") == "Baru lahir")
    }

    // 29.29
    @Test func canonical_29_29() {
        #expect(SayableAgeFormatter(Locales.ID).formatAge("2025-06-14", "2025-06-15") == "1 hari")
    }

    // 29.30
    @Test func canonical_29_30() {
        #expect(SayableAgeFormatter(Locales.ID).formatAge("2025-06-12", "2025-06-15") == "3 hari")
    }

    // 29.31
    @Test func canonical_29_31() {
        #expect(SayableAgeFormatter(Locales.ID).formatAge("2025-01-15", "2025-07-15") == "6 bulan")
    }

    // 29.32
    @Test func canonical_29_32() {
        #expect(SayableAgeFormatter(Locales.ID).formatAge("2022-06-15", "2025-12-15") == "3 setengah tahun")
    }

    // 29.33
    @Test func canonical_29_33() {
        #expect(SayableAgeFormatter(Locales.ID).formatAge("2018-06-15", "2025-06-15") == "7 tahun")
    }

    // 29.34
    @Test func canonical_29_34() {
        #expect(SayableAgeFormatter(Locales.AM).formatAge("2025-06-15", "2025-06-15") == "አዲስ የተወለደ")
    }

    // 29.35
    @Test func canonical_29_35() {
        #expect(SayableAgeFormatter(Locales.AM).formatAge("2025-06-14", "2025-06-15") == "1 ቀን")
    }

    // 29.36
    @Test func canonical_29_36() {
        #expect(SayableAgeFormatter(Locales.AM).formatAge("2025-06-12", "2025-06-15") == "3 ቀናት")
    }

    // 29.37
    @Test func canonical_29_37() {
        #expect(SayableAgeFormatter(Locales.AM).formatAge("2025-06-07", "2025-06-15") == "1 ሳምንት፣ 1 ቀን")
    }

    // 29.38
    @Test func canonical_29_38() {
        #expect(SayableAgeFormatter(Locales.AM).formatAge("2025-01-15", "2025-07-15") == "6 ወራት")
    }

    // 29.39
    @Test func canonical_29_39() {
        #expect(SayableAgeFormatter(Locales.AM).formatAge("2022-06-15", "2025-12-15") == "3 ዓመታት ተኩል")
    }

    // 30.1
    @Test func canonical_30_1() {
        let loc = Locales.get("en")
        #expect(loc != nil)
        #expect(loc!.code == "en")
    }
    // 30.2
    @Test func canonical_30_2() {
        let loc = Locales.get("fr")
        #expect(loc != nil)
        #expect(loc!.code == "fr")
    }
    // 30.3
    @Test func canonical_30_3() {
        #expect(Locales.get("xx") == nil)
    }
    // 30.4
    @Test func canonical_30_4() {
        #expect(Locales.get("") == nil)
    }
    // 30.5
    @Test func canonical_30_5() {
        #expect(Locales.get("EN") == nil)
    }
}
