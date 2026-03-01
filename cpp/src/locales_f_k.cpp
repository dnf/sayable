// -*- coding: utf-8 -*-
#include "parenttime/locales.hpp"

namespace parenttime {
namespace locales {

const AgeLocale& FA() {
    static const AgeLocale loc{
        "fa",
        [](int n) -> PluralCategory {
            if (n == 0 || n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} روز"}, {PluralCategory::Other, "{n} روز"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} هفته"}, {PluralCategory::Other, "{n} هفته"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} ماه"}, {PluralCategory::Other, "{n} ماه"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} سال"}, {PluralCategory::Other, "{n} سال"}})
        },
        "{0} و نیم", " و ", "نوزاد",
        StageLabels{{"نوزاد", ""}, {"شیرخوار", ""}, {"نوپا", ""}, {"کودک", ""}, {"نوجوان", ""}, {"بزرگسال", ""}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& FI() {
    static const AgeLocale loc{
        "fi",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} päivä"}, {PluralCategory::Other, "{n} päivää"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} viikko"}, {PluralCategory::Other, "{n} viikkoa"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} kuukausi"}, {PluralCategory::Other, "{n} kuukautta"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} vuosi"}, {PluralCategory::Other, "{n} vuotta"}})
        },
        "{n} ja puoli", ", ", "Vastasyntynyt",
        StageLabels{{"Vastasyntynyt", ""}, {"Vauva", ""}, {"Taapero", ""}, {"Lapsi", ""}, {"Teini", ""}, {"Aikuinen", ""}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& FR() {
    static const AgeLocale loc{
        "fr",
        [](int n) -> PluralCategory {
            if (n == 0 || n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} jour"}, {PluralCategory::Other, "{n} jours"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} semaine"}, {PluralCategory::Other, "{n} semaines"}}),
            UnitForms::Simple("{n} mois"),
            UnitForms::Plural({{PluralCategory::One, "{n} an"}, {PluralCategory::Other, "{n} ans"}})
        },
        "{0} et demi", ", ", "Nouveau-né",
        StageLabels{{"Nouveau-né", "Nouveau-née"}, {"Nourrisson", ""}, {"Tout-petit", ""}, {"Enfant", ""}, {"Adolescent", "Adolescente"}, {"Adulte", ""}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& GA() {
    static const AgeLocale loc{
        "ga",
        [](int) -> PluralCategory { return PluralCategory::Other; },
        UnitSet{
            UnitForms::Simple("{n} lá"),
            UnitForms::Simple("{n} seachtain"),
            UnitForms::Simple("{n} mí"),
            UnitForms::Simple("{n} bliain")
        },
        "{0} go leith", ", ", "Nuabheirthe",
        StageLabels{{"Nuabheirthe", ""}, {"Naíonán", ""}, {"Lapadán", ""}, {"Páiste", ""}, {"Déagóir", ""}, {"Duine fásta", ""}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& GU() {
    static const AgeLocale loc{
        "gu",
        [](int n) -> PluralCategory {
            if (n == 0 || n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} દિવસ"}, {PluralCategory::Other, "{n} દિવસ"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} અઠવાડિયું"}, {PluralCategory::Other, "{n} અઠવાડિયા"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} મહિનો"}, {PluralCategory::Other, "{n} મહિના"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} વર્ષ"}, {PluralCategory::Other, "{n} વર્ષ"}})
        },
        "સાડે {n}", ", ", "નવજાત",
        StageLabels{{"નવજાત", ""}, {"શિશુ", ""}, {"નાનું બાળક", ""}, {"બાળક", ""}, {"કિશોર", "કિશોરી"}, {"પુખ્ત", ""}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& HI() {
    static const AgeLocale loc{
        "hi",
        [](int n) -> PluralCategory {
            if (n == 0 || n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} दिन"}, {PluralCategory::Other, "{n} दिन"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} सप्ताह"}, {PluralCategory::Other, "{n} सप्ताह"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} महीना"}, {PluralCategory::Other, "{n} महीने"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} साल"}, {PluralCategory::Other, "{n} साल"}})
        },
        "साढ़े {n}", ", ", "नवजात",
        StageLabels{{"नवजात", ""}, {"शिशु", ""}, {"छोटा बच्चा", "छोटी बच्ची"}, {"बच्चा", "बच्ची"}, {"किशोर", "किशोरी"}, {"वयस्क", ""}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& HR() {
    static const AgeLocale loc{
        "hr",
        [](int n) -> PluralCategory {
            int mod10 = n % 10;
            int mod100 = n % 100;
            if (mod10 == 1 && mod100 != 11) return PluralCategory::One;
            if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory::Few;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} dan"}, {PluralCategory::Few, "{n} dana"}, {PluralCategory::Many, "{n} dana"}, {PluralCategory::Other, "{n} dana"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} tjedan"}, {PluralCategory::Few, "{n} tjedna"}, {PluralCategory::Many, "{n} tjedana"}, {PluralCategory::Other, "{n} tjedana"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} mjesec"}, {PluralCategory::Few, "{n} mjeseca"}, {PluralCategory::Many, "{n} mjeseci"}, {PluralCategory::Other, "{n} mjeseci"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} godina"}, {PluralCategory::Few, "{n} godine"}, {PluralCategory::Many, "{n} godina"}, {PluralCategory::Other, "{n} godina"}})
        },
        "{0} i pol", ", ", "Novorođenče",
        StageLabels{{"Novorođenče", ""}, {"Dojenče", ""}, {"Malo dijete", ""}, {"Dijete", ""}, {"Tinejdžer", ""}, {"Odrasla osoba", ""}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& HU() {
    static const AgeLocale loc{
        "hu",
        [](int) -> PluralCategory { return PluralCategory::Other; },
        UnitSet{
            UnitForms::Simple("{n} nap"),
            UnitForms::Simple("{n} hét"),
            UnitForms::Simple("{n} hónap"),
            UnitForms::Simple("{n} év")
        },
        "{n} és fél", ", ", "Újszülött",
        StageLabels{{"Újszülött", ""}, {"Csecsemő", ""}, {"Kisgyermek", ""}, {"Gyermek", ""}, {"Tinédzser", ""}, {"Felnőtt", ""}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& IT() {
    static const AgeLocale loc{
        "it",
        [](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        },
        UnitSet{
            UnitForms::Plural({{PluralCategory::One, "{n} giorno"}, {PluralCategory::Other, "{n} giorni"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} settimana"}, {PluralCategory::Other, "{n} settimane"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} mese"}, {PluralCategory::Other, "{n} mesi"}}),
            UnitForms::Plural({{PluralCategory::One, "{n} anno"}, {PluralCategory::Other, "{n} anni"}})
        },
        "{0} e mezzo", ", ", "Neonato",
        StageLabels{{"Neonato", "Neonata"}, {"Lattante", ""}, {"Bimbo", "Bimba"}, {"Bambino", "Bambina"}, {"Adolescente", ""}, {"Adulto", "Adulta"}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& JA() {
    static const AgeLocale loc{
        "ja",
        [](int) -> PluralCategory { return PluralCategory::Other; },
        UnitSet{
            UnitForms::Simple("{n}日"),
            UnitForms::Simple("{n}週"),
            UnitForms::Simple("{n}ヶ月"),
            UnitForms::Simple("{n}歳")
        },
        "{0}半", "", "新生児",
        StageLabels{{"新生児", ""}, {"乳児", ""}, {"幼児", ""}, {"児童", ""}, {"青少年", ""}, {"成人", ""}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& JV() {
    static const AgeLocale loc{
        "jv",
        [](int) -> PluralCategory { return PluralCategory::Other; },
        UnitSet{
            UnitForms::Simple("{n} dina"),
            UnitForms::Simple("{n} minggu"),
            UnitForms::Simple("{n} wulan"),
            UnitForms::Simple("{n} taun")
        },
        "{0} setengah", ", ", "Bayi anyar",
        StageLabels{{"Bayi anyar", ""}, {"Bayi", ""}, {"Balita", ""}, {"Bocah", ""}, {"Remaja", ""}, {"Diwasa", ""}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

const AgeLocale& KO() {
    static const AgeLocale loc{
        "ko",
        [](int) -> PluralCategory { return PluralCategory::Other; },
        UnitSet{
            UnitForms::Simple("{n}일"),
            UnitForms::Simple("{n}주"),
            UnitForms::Simple("{n}개월"),
            UnitForms::Simple("{n}살")
        },
        "{0} 반", " ", "신생아",
        StageLabels{{"신생아", ""}, {"영아", ""}, {"유아", ""}, {"아동", ""}, {"청소년", ""}, {"성인", ""}},
        std::nullopt, std::nullopt, nullptr, nullptr
    };
    return loc;
}

} // namespace locales
} // namespace parenttime
