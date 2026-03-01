"""Java plural rule definitions for all 23 patterns."""

from __future__ import annotations

# Simple rules that can be expressed as inline lambdas
_JAVA_SIMPLE = {
    "other_only",
    "one_other",
    "one_other_zero_one",
    "he",
    "mk",
}

_JAVA = {
    "other_only": "n -> PluralCategory.OTHER",
    "one_other": "n -> n == 1 ? PluralCategory.ONE : PluralCategory.OTHER",
    "one_other_zero_one": "n -> (n == 0 || n == 1) ? PluralCategory.ONE : PluralCategory.OTHER",
    "he": "n -> n == 1 ? PluralCategory.ONE : n == 2 ? PluralCategory.TWO : PluralCategory.OTHER",
    "mk": "n -> (n % 10 == 1 && n % 100 != 11) ? PluralCategory.ONE : PluralCategory.OTHER",
}

# Complex rules that need named static methods
_JAVA_NAMED = {
    "cs_sk": """\
    static PluralCategory pluralCsSk(int n) {
        if (n == 1) return PluralCategory.ONE;
        if (n >= 2 && n <= 4) return PluralCategory.FEW;
        return PluralCategory.OTHER;
    }""",
    "lt": """\
    static PluralCategory pluralLt(int n) {
        int mod10 = n % 10;
        int mod100 = n % 100;
        if (mod10 == 1 && mod100 != 11) return PluralCategory.ONE;
        if (mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19)) return PluralCategory.FEW;
        return PluralCategory.OTHER;
    }""",
    "ro": """\
    static PluralCategory pluralRo(int n) {
        if (n == 1) return PluralCategory.ONE;
        if (n == 0 || (n % 100 >= 1 && n % 100 <= 19)) return PluralCategory.FEW;
        return PluralCategory.OTHER;
    }""",
    "slavic_bcs": """\
    static PluralCategory pluralSlavicBcs(int n) {
        int mod10 = n % 10;
        int mod100 = n % 100;
        if (mod10 == 1 && mod100 != 11) return PluralCategory.ONE;
        if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory.FEW;
        return PluralCategory.OTHER;
    }""",
    "pl": """\
    static PluralCategory pluralPl(int n) {
        if (n == 1) return PluralCategory.ONE;
        int mod10 = n % 10;
        int mod100 = n % 100;
        if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory.FEW;
        return PluralCategory.MANY;
    }""",
    "ru_uk": """\
    static PluralCategory pluralRuUk(int n) {
        int mod10 = n % 10;
        int mod100 = n % 100;
        if (mod10 == 1 && mod100 != 11) return PluralCategory.ONE;
        if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory.FEW;
        return PluralCategory.MANY;
    }""",
    "sl": """\
    static PluralCategory pluralSl(int n) {
        int mod100 = n % 100;
        if (mod100 == 1) return PluralCategory.ONE;
        if (mod100 == 2) return PluralCategory.TWO;
        if (mod100 == 3 || mod100 == 4) return PluralCategory.FEW;
        return PluralCategory.OTHER;
    }""",
    "ar": """\
    static PluralCategory pluralAr(int n) {
        if (n == 0) return PluralCategory.ZERO;
        if (n == 1) return PluralCategory.ONE;
        if (n == 2) return PluralCategory.TWO;
        if (n % 100 >= 3 && n % 100 <= 10) return PluralCategory.FEW;
        if (n % 100 >= 11 && n % 100 <= 99) return PluralCategory.MANY;
        return PluralCategory.OTHER;
    }""",
    "lv": """\
    static PluralCategory pluralLv(int n) {
        int mod10 = n % 10;
        int mod100 = n % 100;
        if (mod10 == 0 || (mod100 >= 11 && mod100 <= 19)) return PluralCategory.ZERO;
        if (mod10 == 1 && mod100 != 11) return PluralCategory.ONE;
        return PluralCategory.OTHER;
    }""",
    "cy": """\
    static PluralCategory pluralCy(int n) {
        if (n == 0) return PluralCategory.ZERO;
        if (n == 1) return PluralCategory.ONE;
        if (n == 2) return PluralCategory.TWO;
        if (n == 3) return PluralCategory.FEW;
        if (n == 6) return PluralCategory.MANY;
        return PluralCategory.OTHER;
    }""",
    "gv": """\
    static PluralCategory pluralGv(int n) {
        int mod10 = n % 10;
        int mod100 = n % 100;
        if (mod10 == 1) return PluralCategory.ONE;
        if (mod10 == 2) return PluralCategory.TWO;
        if (mod100 == 0 || mod100 == 20 || mod100 == 40 || mod100 == 60 || mod100 == 80) return PluralCategory.FEW;
        return PluralCategory.OTHER;
    }""",
    "gd": """\
    static PluralCategory pluralGd(int n) {
        if (n == 1 || n == 11) return PluralCategory.ONE;
        if (n == 2 || n == 12) return PluralCategory.TWO;
        if ((n >= 3 && n <= 10) || (n >= 13 && n <= 19)) return PluralCategory.FEW;
        return PluralCategory.OTHER;
    }""",
    "ga": """\
    static PluralCategory pluralGa(int n) {
        if (n == 1) return PluralCategory.ONE;
        if (n == 2) return PluralCategory.TWO;
        if (n >= 3 && n <= 6) return PluralCategory.FEW;
        if (n >= 7 && n <= 10) return PluralCategory.MANY;
        return PluralCategory.OTHER;
    }""",
    "mt": """\
    static PluralCategory pluralMt(int n) {
        if (n == 1) return PluralCategory.ONE;
        if (n == 2) return PluralCategory.TWO;
        if (n == 0 || (n % 100 >= 3 && n % 100 <= 10)) return PluralCategory.FEW;
        if (n % 100 >= 11 && n % 100 <= 19) return PluralCategory.MANY;
        return PluralCategory.OTHER;
    }""",
    "br": """\
    static PluralCategory pluralBr(int n) {
        int mod10 = n % 10;
        int mod100 = n % 100;
        if (mod10 == 1 && mod100 != 11 && mod100 != 71 && mod100 != 91) return PluralCategory.ONE;
        if (mod10 == 2 && mod100 != 12 && mod100 != 72 && mod100 != 92) return PluralCategory.TWO;
        if ((mod10 == 3 || mod10 == 4 || mod10 == 9) && !(mod100 >= 10 && mod100 <= 19) && !(mod100 >= 70 && mod100 <= 79) && !(mod100 >= 90 && mod100 <= 99)) return PluralCategory.FEW;
        if (n != 0 && n % 1000000 == 0) return PluralCategory.MANY;
        return PluralCategory.OTHER;
    }""",
    "kw": """\
    static PluralCategory pluralKw(int n) {
        if (n == 0) return PluralCategory.ZERO;
        if (n == 1) return PluralCategory.ONE;
        int mod100 = n % 100;
        if (mod100 == 2 || mod100 == 22 || mod100 == 42 || mod100 == 62 || mod100 == 82) return PluralCategory.TWO;
        if (mod100 == 3 || mod100 == 23 || mod100 == 43 || mod100 == 63 || mod100 == 83) return PluralCategory.FEW;
        if (n != 1 && (mod100 == 1 || mod100 == 21 || mod100 == 41 || mod100 == 61 || mod100 == 81)) return PluralCategory.MANY;
        return PluralCategory.OTHER;
    }""",
    "shi": """\
    static PluralCategory pluralShi(int n) {
        if (n == 0 || n == 1) return PluralCategory.ONE;
        if (n >= 2 && n <= 10) return PluralCategory.FEW;
        return PluralCategory.OTHER;
    }""",
    "tzm": """\
    static PluralCategory pluralTzm(int n) {
        if (n == 0 || n == 1 || (n >= 11 && n <= 99)) return PluralCategory.ONE;
        return PluralCategory.OTHER;
    }""",
}

# Mapping from rule name to method name for named rules
_JAVA_METHOD_NAMES = {
    "cs_sk": "Locales::pluralCsSk",
    "lt": "Locales::pluralLt",
    "ro": "Locales::pluralRo",
    "slavic_bcs": "Locales::pluralSlavicBcs",
    "pl": "Locales::pluralPl",
    "ru_uk": "Locales::pluralRuUk",
    "sl": "Locales::pluralSl",
    "ar": "Locales::pluralAr",
    "lv": "Locales::pluralLv",
    "cy": "Locales::pluralCy",
    "gv": "Locales::pluralGv",
    "gd": "Locales::pluralGd",
    "ga": "Locales::pluralGa",
    "mt": "Locales::pluralMt",
    "br": "Locales::pluralBr",
    "kw": "Locales::pluralKw",
    "shi": "Locales::pluralShi",
    "tzm": "Locales::pluralTzm",
}


def is_simple_plural(rule: str) -> bool:
    """Return True if the rule can be expressed as a single-line lambda."""
    return rule in _JAVA_SIMPLE


def get_java_plural(rule: str) -> str:
    """Return the Java expression for the given plural rule."""
    if rule in _JAVA:
        return _JAVA[rule]
    return _JAVA_METHOD_NAMES[rule]


def get_java_named_methods() -> dict[str, str]:
    """Return all named method bodies needed for complex plural rules."""
    return dict(_JAVA_NAMED)
