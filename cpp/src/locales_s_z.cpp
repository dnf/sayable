// -*- coding: utf-8 -*-
#include "parenttime/locales.hpp"

namespace parenttime {
namespace locales {

const AgeLocale& SK() {
    static const AgeLocale loc{
        "sk",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            if (n >= 2 && n <= 4) return PluralCategory::Few;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} deň"}, {PluralCategory::Few, "{n} dni"}, {PluralCategory::Other, "{n} dní"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} týždeň"}, {PluralCategory::Few, "{n} týždne"}, {PluralCategory::Other, "{n} týždňov"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} mesiac"}, {PluralCategory::Few, "{n} mesiace"}, {PluralCategory::Other, "{n} mesiacov"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} rok"}, {PluralCategory::Few, "{n} roky"}, {PluralCategory::Other, "{n} rokov"}})
        },
        "{n}\xC2\xBD", ", ", "Novorodenec",
        StageLabels{"Novorodenec", "Dojča", "Batoľa", "Dieťa", "Tínedžer", "Dospelý"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& SL() {
    static const AgeLocale loc{
        "sl",
        [](int n) -> PluralCategory {
            int mod100 = n % 100;
            if (mod100 == 1) return PluralCategory::One;
            if (mod100 == 2) return PluralCategory::Two;
            if (mod100 == 3 || mod100 == 4) return PluralCategory::Few;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} dan"}, {PluralCategory::Two, "{n} dneva"}, {PluralCategory::Few, "{n} dni"}, {PluralCategory::Other, "{n} dni"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} teden"}, {PluralCategory::Two, "{n} tedna"}, {PluralCategory::Few, "{n} tedne"}, {PluralCategory::Other, "{n} tednov"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} mesec"}, {PluralCategory::Two, "{n} meseca"}, {PluralCategory::Few, "{n} mesece"}, {PluralCategory::Other, "{n} mesecev"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} leto"}, {PluralCategory::Two, "{n} leti"}, {PluralCategory::Few, "{n} leta"}, {PluralCategory::Other, "{n} let"}})
        },
        "{0} in pol", ", ", "Novorojenček",
        StageLabels{"Novorojenček", "Dojenček", "Malček", "Otrok", "Najstnik", "Odrasel"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& SQ() {
    static const AgeLocale loc{
        "sq",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} ditë"}, {PluralCategory::Other, "{n} ditë"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} javë"}, {PluralCategory::Other, "{n} javë"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} muaj"}, {PluralCategory::Other, "{n} muaj"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} vit"}, {PluralCategory::Other, "{n} vjet"}})
        },
        "{0} e gjysmë", ", ", "Sapolindur",
        StageLabels{"Sapolindur", "Foshnjë", "Fëmijë i vogël", "Fëmijë", "Adoleshent", "I rritur"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& SR() {
    static const AgeLocale loc{
        "sr",
        [](int n) -> PluralCategory {
            int mod10 = n % 10;
            int mod100 = n % 100;
            if (mod10 == 1 && mod100 != 11) return PluralCategory::One;
            if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory::Few;
            return PluralCategory::Many;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} дан"}, {PluralCategory::Few, "{n} дана"}, {PluralCategory::Many, "{n} дана"}, {PluralCategory::Other, "{n} дана"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} недеља"}, {PluralCategory::Few, "{n} недеље"}, {PluralCategory::Many, "{n} недеља"}, {PluralCategory::Other, "{n} недеља"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} месец"}, {PluralCategory::Few, "{n} месеца"}, {PluralCategory::Many, "{n} месеци"}, {PluralCategory::Other, "{n} месеци"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} година"}, {PluralCategory::Few, "{n} године"}, {PluralCategory::Many, "{n} година"}, {PluralCategory::Other, "{n} година"}})
        },
        "{0} и по", ", ", "Новорођенче",
        StageLabels{"Новорођенче", "Одојче", "Мало дете", "Дете", "Тинејџер", "Одрасла особа"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& SV() {
    static const AgeLocale loc{
        "sv",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} dag"}, {PluralCategory::Other, "{n} dagar"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} vecka"}, {PluralCategory::Other, "{n} veckor"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} månad"}, {PluralCategory::Other, "{n} månader"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} år"}, {PluralCategory::Other, "{n} år"}})
        },
        "{n}\xC2\xBD", ", ", "Nyfödd",
        StageLabels{"Nyfödd", "Spädbarn", "Litet barn", "Barn", "Tonåring", "Vuxen"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& TA() {
    static const AgeLocale loc{
        "ta",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} நாள்"}, {PluralCategory::Other, "{n} நாட்கள்"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} வாரம்"}, {PluralCategory::Other, "{n} வாரங்கள்"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} மாதம்"}, {PluralCategory::Other, "{n} மாதங்கள்"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} வயது"}, {PluralCategory::Other, "{n} வயது"}})
        },
        "{0}ரை", ", ", "பிறந்த குழந்தை",
        StageLabels{"பிறந்த குழந்தை", "குழந்தை", "சிறு குழந்தை", "சிறுவர்", "இளம்பருவம்", "பெரியவர்"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& TE() {
    static const AgeLocale loc{
        "te",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} రోజు"}, {PluralCategory::Other, "{n} రోజులు"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} వారం"}, {PluralCategory::Other, "{n} వారాలు"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} నెల"}, {PluralCategory::Other, "{n} నెలలు"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} సంవత్సరం"}, {PluralCategory::Other, "{n} సంవత్సరాలు"}})
        },
        "{0}న్నర", ", ", "నవజాత శిశువు",
        StageLabels{"నవజాత శిశువు", "శిశువు", "చిన్న పిల్లవాడు", "పిల్లవాడు", "కౌమారదశ", "వయోజనుడు"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& TH() {
    static const AgeLocale loc{
        "th",
        [](int) -> PluralCategory { return PluralCategory::Other; },
        UnitSet{
            UnitForms::Simple("{n} วัน"),
            UnitForms::Simple("{n} สัปดาห์"),
            UnitForms::Simple("{n} เดือน"),
            UnitForms::Simple("{n} ปี")
        },
        "{0}ครึ่ง", " ", "แรกเกิด",
        StageLabels{"แรกเกิด", "ทารก", "เด็กวัยเตาะแตะ", "เด็ก", "วัยรุ่น", "ผู้ใหญ่"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& TR() {
    static const AgeLocale loc{
        "tr",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} gün"}, {PluralCategory::Other, "{n} gün"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} hafta"}, {PluralCategory::Other, "{n} hafta"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} ay"}, {PluralCategory::Other, "{n} ay"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} yaş"}, {PluralCategory::Other, "{n} yaş"}})
        },
        "{n} buçuk", ", ", "Yeni doğan",
        StageLabels{"Yeni doğan", "Bebek", "Küçük çocuk", "Çocuk", "Ergen", "Yetişkin"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& UK() {
    static const AgeLocale loc{
        "uk",
        [](int n) -> PluralCategory {
            int mod10 = n % 10;
            int mod100 = n % 100;
            if (mod10 == 1 && mod100 != 11) return PluralCategory::One;
            if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory::Few;
            return PluralCategory::Many;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} день"}, {PluralCategory::Few, "{n} дні"}, {PluralCategory::Many, "{n} днів"}, {PluralCategory::Other, "{n} днів"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} тиждень"}, {PluralCategory::Few, "{n} тижні"}, {PluralCategory::Many, "{n} тижнів"}, {PluralCategory::Other, "{n} тижнів"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} місяць"}, {PluralCategory::Few, "{n} місяці"}, {PluralCategory::Many, "{n} місяців"}, {PluralCategory::Other, "{n} місяців"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} рік"}, {PluralCategory::Few, "{n} роки"}, {PluralCategory::Many, "{n} років"}, {PluralCategory::Other, "{n} років"}})
        },
        "{n} з половиною", ", ", "Новонароджений",
        StageLabels{"Новонароджений", "Немовля", "Малюк", "Дитина", "Підліток", "Дорослий"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& UR() {
    static const AgeLocale loc{
        "ur",
        [](int n) -> PluralCategory {
            if (n == 0 || n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} دن"}, {PluralCategory::Other, "{n} دن"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} ہفتہ"}, {PluralCategory::Other, "{n} ہفتے"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} مہینہ"}, {PluralCategory::Other, "{n} مہینے"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} سال"}, {PluralCategory::Other, "{n} سال"}})
        },
        "ساڑھے {n}", "، ", "نومولود",
        StageLabels{"نومولود", "شیرخوار", "چھوٹا بچہ", "بچہ", "نوجوان", "بالغ"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& VI() {
    static const AgeLocale loc{
        "vi",
        [](int) -> PluralCategory { return PluralCategory::Other; },
        UnitSet{
            UnitForms::Simple("{n} ngày"),
            UnitForms::Simple("{n} tuần"),
            UnitForms::Simple("{n} tháng"),
            UnitForms::Simple("{n} tuổi")
        },
        "{0} rưỡi", ", ", "Sơ sinh",
        StageLabels{"Sơ sinh", "Trẻ sơ sinh", "Trẻ mới biết đi", "Trẻ em", "Thiếu niên", "Người lớn"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& ZH() {
    static const AgeLocale loc{
        "zh",
        [](int) -> PluralCategory { return PluralCategory::Other; },
        UnitSet{
            UnitForms::Simple("{n}天"),
            UnitForms::Simple("{n}周"),
            UnitForms::Simple("{n}个月"),
            UnitForms::Simple("{n}岁")
        },
        "{0}半", "", "新生儿",
        StageLabels{"新生儿", "婴儿", "幼儿", "儿童", "青少年", "成人"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

} // namespace locales
} // namespace parenttime
