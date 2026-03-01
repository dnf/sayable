// -*- coding: utf-8 -*-
#include "parenttime/locales.hpp"

namespace parenttime {
namespace locales {

const AgeLocale& LT() {
    static const AgeLocale loc{
        "lt",
        [](int n) -> PluralCategory {
            int mod10 = n % 10;
            int mod100 = n % 100;
            if (mod10 == 1 && mod100 != 11) return PluralCategory::One;
            if (mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19)) return PluralCategory::Few;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} diena"}, {PluralCategory::Few, "{n} dienos"}, {PluralCategory::Other, "{n} dienų"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} savaitė"}, {PluralCategory::Few, "{n} savaitės"}, {PluralCategory::Other, "{n} savaičių"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} mėnuo"}, {PluralCategory::Few, "{n} mėnesiai"}, {PluralCategory::Other, "{n} mėnesių"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} metai"}, {PluralCategory::Few, "{n} metai"}, {PluralCategory::Other, "{n} metų"}})
        },
        "{n}\xC2\xBD", ", ", "Naujagimis",
        StageLabels{{"Naujagimis", "Naujagimė"}, {"Kūdikis", "Kūdikė"}, {"Mažylis", "Mažylė"}, {"Vaikas", ""}, {"Paauglys", "Paauglė"}, {"Suaugęs", "Suaugusi"}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& LV() {
    static const AgeLocale loc{
        "lv",
        [](int n) -> PluralCategory {
            int mod10 = n % 10;
            int mod100 = n % 100;
            if (mod10 == 0 || (mod100 >= 11 && mod100 <= 19)) return PluralCategory::Zero;
            if (mod10 == 1 && mod100 != 11) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::Zero, "{n} dienu"}, {PluralCategory::One, "{n} diena"}, {PluralCategory::Other, "{n} dienas"}}),
            UnitForms::Plural({{PluralCategory::Zero, "{n} nedēļu"}, {PluralCategory::One, "{n} nedēļa"}, {PluralCategory::Other, "{n} nedēļas"}}),
            UnitForms::Plural({{PluralCategory::Zero, "{n} mēnešu"}, {PluralCategory::One, "{n} mēnesis"}, {PluralCategory::Other, "{n} mēneši"}}),
            UnitForms::Plural({{PluralCategory::Zero, "{n} gadu"}, {PluralCategory::One, "{n} gads"}, {PluralCategory::Other, "{n} gadi"}})
        },
        "{n}\xC2\xBD", ", ", "Jaundzimušais",
        StageLabels{{"Jaundzimušais", "Jaundzimušā"}, {"Zīdainis", "Zīdaine"}, {"Mazulis", "Mazule"}, {"Bērns", ""}, {"Pusaudzis", "Pusaudze"}, {"Pieaugušais", "Pieaugusī"}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& MR() {
    static const AgeLocale loc{
        "mr",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} दिवस"}, {PluralCategory::Other, "{n} दिवस"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} आठवडा"}, {PluralCategory::Other, "{n} आठवडे"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} महिना"}, {PluralCategory::Other, "{n} महिने"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} वर्ष"}, {PluralCategory::Other, "{n} वर्षे"}})
        },
        "साडे {n}", ", ", "नवजात",
        StageLabels{{"नवजात", ""}, {"अर्भक", ""}, {"बाळ", ""}, {"मूल", ""}, {"किशोर", "किशोरी"}, {"प्रौढ", ""}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& MS() {
    static const AgeLocale loc{
        "ms",
        [](int) -> PluralCategory { return PluralCategory::Other; },
        UnitSet{
            UnitForms::Simple("{n} hari"),
            UnitForms::Simple("{n} minggu"),
            UnitForms::Simple("{n} bulan"),
            UnitForms::Simple("{n} tahun")
        },
        "{0} setengah", ", ", "Baru lahir",
        StageLabels{{"Baru lahir", ""}, {"Bayi", ""}, {"Kanak-kanak kecil", ""}, {"Kanak-kanak", ""}, {"Remaja", ""}, {"Dewasa", ""}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& NB() {
    static const AgeLocale loc{
        "nb",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} dag"}, {PluralCategory::Other, "{n} dager"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} uke"}, {PluralCategory::Other, "{n} uker"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} måned"}, {PluralCategory::Other, "{n} måneder"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} år"}, {PluralCategory::Other, "{n} år"}})
        },
        "{n}\xC2\xBD", ", ", "Nyfødt",
        StageLabels{{"Nyfødt", ""}, {"Spedbarn", ""}, {"Småbarn", ""}, {"Barn", ""}, {"Tenåring", ""}, {"Voksen", ""}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& NL() {
    static const AgeLocale loc{
        "nl",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} dag"}, {PluralCategory::Other, "{n} dagen"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} week"}, {PluralCategory::Other, "{n} weken"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} maand"}, {PluralCategory::Other, "{n} maanden"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} jaar"}, {PluralCategory::Other, "{n} jaar"}})
        },
        "{n}\xC2\xBD", ", ", "Pasgeboren",
        StageLabels{{"Pasgeborene", ""}, {"Baby", ""}, {"Peuter", ""}, {"Kind", ""}, {"Tiener", ""}, {"Volwassene", ""}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& PA() {
    static const AgeLocale loc{
        "pa",
        [](int n) -> PluralCategory {
            if (n == 0 || n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} ਦਿਨ"}, {PluralCategory::Other, "{n} ਦਿਨ"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} ਹਫ਼ਤਾ"}, {PluralCategory::Other, "{n} ਹਫ਼ਤੇ"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} ਮਹੀਨਾ"}, {PluralCategory::Other, "{n} ਮਹੀਨੇ"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} ਸਾਲ"}, {PluralCategory::Other, "{n} ਸਾਲ"}})
        },
        "ਸਾਢੇ {n}", ", ", "ਨਵਜੰਮਿਆ",
        StageLabels{{"ਨਵਜੰਮਿਆ", "ਨਵਜੰਮੀ"}, {"ਸ਼ਿਸ਼ੂ", ""}, {"ਛੋਟਾ ਬੱਚਾ", "ਛੋਟੀ ਬੱਚੀ"}, {"ਬੱਚਾ", "ਬੱਚੀ"}, {"ਕਿਸ਼ੋਰ", "ਕਿਸ਼ੋਰੀ"}, {"ਬਾਲਗ", ""}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& PL() {
    static const AgeLocale loc{
        "pl",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            int mod10 = n % 10;
            int mod100 = n % 100;
            if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory::Few;
            return PluralCategory::Many;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} dzień"}, {PluralCategory::Few, "{n} dni"}, {PluralCategory::Many, "{n} dni"}, {PluralCategory::Other, "{n} dni"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} tydzień"}, {PluralCategory::Few, "{n} tygodnie"}, {PluralCategory::Many, "{n} tygodni"}, {PluralCategory::Other, "{n} tygodni"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} miesiąc"}, {PluralCategory::Few, "{n} miesiące"}, {PluralCategory::Many, "{n} miesięcy"}, {PluralCategory::Other, "{n} miesięcy"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} rok"}, {PluralCategory::Few, "{n} lata"}, {PluralCategory::Many, "{n} lat"}, {PluralCategory::Other, "{n} lat"}})
        },
        "{n} i pół", ", ", "Noworodek",
        StageLabels{{"Noworodek", ""}, {"Niemowlę", ""}, {"Maluch", ""}, {"Dziecko", ""}, {"Nastolatek", "Nastolatka"}, {"Dorosły", "Dorosła"}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& PT() {
    static const AgeLocale loc{
        "pt",
        [](int n) -> PluralCategory {
            if (n == 0 || n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} dia"}, {PluralCategory::Other, "{n} dias"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} semana"}, {PluralCategory::Other, "{n} semanas"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} mês"}, {PluralCategory::Other, "{n} meses"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} ano"}, {PluralCategory::Other, "{n} anos"}})
        },
        "{0} e meio", ", ", "Recém-nascido",
        StageLabels{{"Recém-nascido", "Recém-nascida"}, {"Bebê", ""}, {"Criança pequena", ""}, {"Criança", ""}, {"Adolescente", ""}, {"Adulto", "Adulta"}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& RO() {
    static const AgeLocale loc{
        "ro",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            int mod100 = n % 100;
            if (n == 0 || (mod100 >= 1 && mod100 <= 19)) return PluralCategory::Few;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} zi"}, {PluralCategory::Few, "{n} zile"}, {PluralCategory::Other, "{n} de zile"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} săptămână"}, {PluralCategory::Few, "{n} săptămâni"}, {PluralCategory::Other, "{n} de săptămâni"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} lună"}, {PluralCategory::Few, "{n} luni"}, {PluralCategory::Other, "{n} de luni"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} an"}, {PluralCategory::Few, "{n} ani"}, {PluralCategory::Other, "{n} de ani"}})
        },
        "{0} și jumătate", ", ", "Nou-născut",
        StageLabels{{"Nou-născut", "Nou-născută"}, {"Sugar", ""}, {"Copil mic", ""}, {"Copil", ""}, {"Adolescent", "Adolescentă"}, {"Adult", "Adultă"}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& RU() {
    static const AgeLocale loc{
        "ru",
        [](int n) -> PluralCategory {
            int mod10 = n % 10;
            int mod100 = n % 100;
            if (mod10 == 1 && mod100 != 11) return PluralCategory::One;
            if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory::Few;
            return PluralCategory::Many;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} день"}, {PluralCategory::Few, "{n} дня"}, {PluralCategory::Many, "{n} дней"}, {PluralCategory::Other, "{n} дней"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} неделя"}, {PluralCategory::Few, "{n} недели"}, {PluralCategory::Many, "{n} недель"}, {PluralCategory::Other, "{n} недель"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} месяц"}, {PluralCategory::Few, "{n} месяца"}, {PluralCategory::Many, "{n} месяцев"}, {PluralCategory::Other, "{n} месяцев"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} год"}, {PluralCategory::Few, "{n} года"}, {PluralCategory::Many, "{n} лет"}, {PluralCategory::Other, "{n} лет"}})
        },
        "{n} с половиной", ", ", "Новорождённый",
        StageLabels{{"Новорождённый", "Новорождённая"}, {"Младенец", ""}, {"Малыш", "Малышка"}, {"Ребёнок", ""}, {"Подросток", ""}, {"Взрослый", "Взрослая"}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

} // namespace locales
} // namespace parenttime
