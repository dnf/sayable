// -*- coding: utf-8 -*-
#include "parenttime/locales.hpp"

namespace parenttime {
namespace locales {

const AgeLocale& AR() {
    static const AgeLocale loc{
        "ar",
        [](int n) -> PluralCategory {
            if (n == 0) return PluralCategory::Zero;
            if (n == 1) return PluralCategory::One;
            if (n == 2) return PluralCategory::Two;
            int mod100 = n % 100;
            if (mod100 >= 3 && mod100 <= 10) return PluralCategory::Few;
            if (mod100 >= 11 && mod100 <= 99) return PluralCategory::Many;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::Zero, "{n} يوم"}, {PluralCategory::One, "يوم"}, {PluralCategory::Two, "يومان"}, {PluralCategory::Few, "{n} أيام"}, {PluralCategory::Many, "{n} يومًا"}, {PluralCategory::Other, "{n} يوم"}}),
            UnitForms::Plural({{PluralCategory::Zero, "{n} أسبوع"}, {PluralCategory::One, "أسبوع"}, {PluralCategory::Two, "أسبوعان"}, {PluralCategory::Few, "{n} أسابيع"}, {PluralCategory::Many, "{n} أسبوعًا"}, {PluralCategory::Other, "{n} أسبوع"}}),
            UnitForms::Plural({{PluralCategory::Zero, "{n} شهر"}, {PluralCategory::One, "شهر"}, {PluralCategory::Two, "شهران"}, {PluralCategory::Few, "{n} أشهر"}, {PluralCategory::Many, "{n} شهرًا"}, {PluralCategory::Other, "{n} شهر"}}),
            UnitForms::Plural({{PluralCategory::Zero, "{n} سنة"}, {PluralCategory::One, "سنة"}, {PluralCategory::Two, "سنتان"}, {PluralCategory::Few, "{n} سنوات"}, {PluralCategory::Many, "{n} سنة"}, {PluralCategory::Other, "{n} سنة"}})
        },
        "{0} ونصف",
        " و",
        "حديث الولادة",
        StageLabels{"حديث الولادة", "رضيع", "طفل صغير", "طفل", "مراهق", "بالغ"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& BG() {
    static const AgeLocale loc{
        "bg",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} ден"}, {PluralCategory::Other, "{n} дни"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} седмица"}, {PluralCategory::Other, "{n} седмици"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} месец"}, {PluralCategory::Other, "{n} месеца"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} година"}, {PluralCategory::Other, "{n} години"}})
        },
        "{0} и половина", ", ", "Новородено",
        StageLabels{"Новородено", "Бебе", "Малко дете", "Дете", "Тийнейджър", "Възрастен"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& BN() {
    static const AgeLocale loc{
        "bn",
        [](int n) -> PluralCategory {
            if (n == 0 || n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} দিন"}, {PluralCategory::Other, "{n} দিন"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} সপ্তাহ"}, {PluralCategory::Other, "{n} সপ্তাহ"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} মাস"}, {PluralCategory::Other, "{n} মাস"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} বছর"}, {PluralCategory::Other, "{n} বছর"}})
        },
        "সাড়ে {n}", ", ", "নবজাতক",
        StageLabels{"নবজাতক", "শিশু", "ছোট শিশু", "শিশু", "কিশোর", "প্রাপ্তবয়স্ক"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& BS() {
    static const AgeLocale loc{
        "bs",
        [](int n) -> PluralCategory {
            int mod10 = n % 10;
            int mod100 = n % 100;
            if (mod10 == 1 && mod100 != 11) return PluralCategory::One;
            if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory::Few;
            return PluralCategory::Many;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} dan"}, {PluralCategory::Few, "{n} dana"}, {PluralCategory::Many, "{n} dana"}, {PluralCategory::Other, "{n} dana"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} sedmica"}, {PluralCategory::Few, "{n} sedmice"}, {PluralCategory::Many, "{n} sedmica"}, {PluralCategory::Other, "{n} sedmica"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} mjesec"}, {PluralCategory::Few, "{n} mjeseca"}, {PluralCategory::Many, "{n} mjeseci"}, {PluralCategory::Other, "{n} mjeseci"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} godina"}, {PluralCategory::Few, "{n} godine"}, {PluralCategory::Many, "{n} godina"}, {PluralCategory::Other, "{n} godina"}})
        },
        "{0} i po", ", ",
        "Novorođenče",
        StageLabels{"Novorođenče", "Beba", "Malo dijete", "Dijete", "Tinejdžer", "Odrasla osoba"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& CA() {
    static const AgeLocale loc{
        "ca",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} dia"}, {PluralCategory::Other, "{n} dies"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} setmana"}, {PluralCategory::Other, "{n} setmanes"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} mes"}, {PluralCategory::Other, "{n} mesos"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} any"}, {PluralCategory::Other, "{n} anys"}})
        },
        "{n} i mig", ", ", "Nounat",
        StageLabels{"Nounat", "Nadó", "Infant", "Nen", "Adolescent", "Adult"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& CS() {
    static const AgeLocale loc{
        "cs",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            if (n >= 2 && n <= 4) return PluralCategory::Few;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} den"}, {PluralCategory::Few, "{n} dny"}, {PluralCategory::Other, "{n} dní"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} týden"}, {PluralCategory::Few, "{n} týdny"}, {PluralCategory::Other, "{n} týdnů"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} měsíc"}, {PluralCategory::Few, "{n} měsíce"}, {PluralCategory::Other, "{n} měsíců"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} rok"}, {PluralCategory::Few, "{n} roky"}, {PluralCategory::Other, "{n} let"}})
        },
        "{n}\xC2\xBD", ", ", "Novorozenec",
        StageLabels{"Novorozenec", "Kojenec", "Batole", "Dítě", "Teenager", "Dospělý"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& DA() {
    static const AgeLocale loc{
        "da",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} dag"}, {PluralCategory::Other, "{n} dage"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} uge"}, {PluralCategory::Other, "{n} uger"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} måned"}, {PluralCategory::Other, "{n} måneder"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} år"}, {PluralCategory::Other, "{n} år"}})
        },
        "{n}\xC2\xBD", ", ", "Nyfødt",
        StageLabels{"Nyfødt", "Spædbarn", "Småbarn", "Barn", "Teenager", "Voksen"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& DE() {
    static const AgeLocale loc{
        "de",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} Tag"}, {PluralCategory::Other, "{n} Tage"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} Woche"}, {PluralCategory::Other, "{n} Wochen"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} Monat"}, {PluralCategory::Other, "{n} Monate"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} Jahr"}, {PluralCategory::Other, "{n} Jahre"}})
        },
        "{n}\xC2\xBD", ", ", "Neugeboren",
        StageLabels{"Neugeborenes", "Säugling", "Kleinkind", "Kind", "Teenager", "Erwachsener"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& EL() {
    static const AgeLocale loc{
        "el",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} μέρα"}, {PluralCategory::Other, "{n} μέρες"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} εβδομάδα"}, {PluralCategory::Other, "{n} εβδομάδες"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} μήνας"}, {PluralCategory::Other, "{n} μήνες"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} χρόνος"}, {PluralCategory::Other, "{n} χρόνια"}})
        },
        "{0} και μισό", ", ", "Νεογέννητο",
        StageLabels{"Νεογέννητο", "Βρέφος", "Νήπιο", "Παιδί", "Έφηβος", "Ενήλικας"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& EN() {
    static const AgeLocale loc{
        "en",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} day"}, {PluralCategory::Other, "{n} days"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} week"}, {PluralCategory::Other, "{n} weeks"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} month"}, {PluralCategory::Other, "{n} months"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} year"}, {PluralCategory::Other, "{n} years"}})
        },
        "{n}\xC2\xBD", ", ", "Newborn",
        StageLabels{"Newborn", "Infant", "Toddler", "Child", "Teenager", "Adult"},
        CompactnessOverride{
            UnitForms::Simple("{n} d"),
            UnitForms::Simple("{n} wk"),
            UnitForms::Simple("{n} mo"),
            UnitForms::Simple("{n} yr"),
            std::nullopt, std::nullopt, std::nullopt
        },
        CompactnessOverride{
            UnitForms::Simple("{n}d"),
            UnitForms::Simple("{n}w"),
            UnitForms::Simple("{n}m"),
            UnitForms::Simple("{n}y"),
            std::nullopt,
            std::string(""),
            std::nullopt
        },
        nullptr, nullptr
    };
    return loc;
}

const AgeLocale& ES() {
    static const AgeLocale loc{
        "es",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} día"}, {PluralCategory::Other, "{n} días"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} semana"}, {PluralCategory::Other, "{n} semanas"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} mes"}, {PluralCategory::Other, "{n} meses"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} año"}, {PluralCategory::Other, "{n} años"}})
        },
        "{n} y medio", ", ", "Recién nacido",
        StageLabels{"Recién nacido", "Bebé", "Niño pequeño", "Niño", "Adolescente", "Adulto"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& ET() {
    static const AgeLocale loc{
        "et",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} päev"}, {PluralCategory::Other, "{n} päeva"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} nädal"}, {PluralCategory::Other, "{n} nädalat"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} kuu"}, {PluralCategory::Other, "{n} kuud"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} aasta"}, {PluralCategory::Other, "{n} aastat"}})
        },
        "{n}\xC2\xBD", ", ", "Vastsündinu",
        StageLabels{"Vastsündinu", "Imik", "Väikelaps", "Laps", "Teismeline", "Täiskasvanu"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& EU() {
    static const AgeLocale loc{
        "eu",
        [](int) -> PluralCategory { return PluralCategory::Other; },
        UnitSet{
            UnitForms::Simple("{n} egun"),
            UnitForms::Simple("{n} aste"),
            UnitForms::Simple("{n} hilabete"),
            UnitForms::Simple("{n} urte")
        },
        "{0} eta erdi", ", ", "Jaioberria",
        StageLabels{"Jaioberria", "Haurra", "Haur txikia", "Umea", "Nerabea", "Heldua"},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

} // namespace locales
} // namespace parenttime
