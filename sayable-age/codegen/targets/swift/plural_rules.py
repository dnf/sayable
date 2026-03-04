"""Swift plural rule definitions for all 23 patterns."""

from __future__ import annotations

# Simple rules that can be expressed as inline closures
_SWIFT_SIMPLE = {
    "other_only",
    "one_other",
    "one_other_zero_one",
    "he",
    "mk",
}

_SWIFT = {
    "other_only": "{ _ in .other }",
    "one_other": "{ $0 == 1 ? .one : .other }",
    "one_other_zero_one": "{ ($0 == 0 || $0 == 1) ? .one : .other }",
    "he": "{ $0 == 1 ? .one : $0 == 2 ? .two : .other }",
    "mk": "{ ($0 % 10 == 1 && $0 % 100 != 11) ? .one : .other }",
}

# Complex rules that need named static functions
_SWIFT_NAMED = {
    "cs_sk": """\
    private static func pluralCsSk(_ n: Int) -> PluralCategory {
        if n == 1 { return .one }
        if n >= 2 && n <= 4 { return .few }
        return .other
    }""",
    "lt": """\
    private static func pluralLt(_ n: Int) -> PluralCategory {
        let mod10 = n % 10
        let mod100 = n % 100
        if mod10 == 1 && mod100 != 11 { return .one }
        if mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19) { return .few }
        return .other
    }""",
    "ro": """\
    private static func pluralRo(_ n: Int) -> PluralCategory {
        if n == 1 { return .one }
        if n == 0 || (n % 100 >= 1 && n % 100 <= 19) { return .few }
        return .other
    }""",
    "slavic_bcs": """\
    private static func pluralSlavicBcs(_ n: Int) -> PluralCategory {
        let mod10 = n % 10
        let mod100 = n % 100
        if mod10 == 1 && mod100 != 11 { return .one }
        if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) { return .few }
        return .other
    }""",
    "pl": """\
    private static func pluralPl(_ n: Int) -> PluralCategory {
        if n == 1 { return .one }
        let mod10 = n % 10
        let mod100 = n % 100
        if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) { return .few }
        return .many
    }""",
    "ru_uk": """\
    private static func pluralRuUk(_ n: Int) -> PluralCategory {
        let mod10 = n % 10
        let mod100 = n % 100
        if mod10 == 1 && mod100 != 11 { return .one }
        if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) { return .few }
        return .many
    }""",
    "sl": """\
    private static func pluralSl(_ n: Int) -> PluralCategory {
        let mod100 = n % 100
        if mod100 == 1 { return .one }
        if mod100 == 2 { return .two }
        if mod100 == 3 || mod100 == 4 { return .few }
        return .other
    }""",
    "ar": """\
    private static func pluralAr(_ n: Int) -> PluralCategory {
        if n == 0 { return .zero }
        if n == 1 { return .one }
        if n == 2 { return .two }
        if n % 100 >= 3 && n % 100 <= 10 { return .few }
        if n % 100 >= 11 && n % 100 <= 99 { return .many }
        return .other
    }""",
    "lv": """\
    private static func pluralLv(_ n: Int) -> PluralCategory {
        let mod10 = n % 10
        let mod100 = n % 100
        if mod10 == 0 || (mod100 >= 11 && mod100 <= 19) { return .zero }
        if mod10 == 1 && mod100 != 11 { return .one }
        return .other
    }""",
    "cy": """\
    private static func pluralCy(_ n: Int) -> PluralCategory {
        if n == 0 { return .zero }
        if n == 1 { return .one }
        if n == 2 { return .two }
        if n == 3 { return .few }
        if n == 6 { return .many }
        return .other
    }""",
    "gv": """\
    private static func pluralGv(_ n: Int) -> PluralCategory {
        let mod10 = n % 10
        let mod100 = n % 100
        if mod10 == 1 { return .one }
        if mod10 == 2 { return .two }
        if mod100 == 0 || mod100 == 20 || mod100 == 40 || mod100 == 60 || mod100 == 80 { return .few }
        return .other
    }""",
    "gd": """\
    private static func pluralGd(_ n: Int) -> PluralCategory {
        if n == 1 || n == 11 { return .one }
        if n == 2 || n == 12 { return .two }
        if (n >= 3 && n <= 10) || (n >= 13 && n <= 19) { return .few }
        return .other
    }""",
    "ga": """\
    private static func pluralGa(_ n: Int) -> PluralCategory {
        if n == 1 { return .one }
        if n == 2 { return .two }
        if n >= 3 && n <= 6 { return .few }
        if n >= 7 && n <= 10 { return .many }
        return .other
    }""",
    "mt": """\
    private static func pluralMt(_ n: Int) -> PluralCategory {
        if n == 1 { return .one }
        if n == 2 { return .two }
        if n == 0 || (n % 100 >= 3 && n % 100 <= 10) { return .few }
        if n % 100 >= 11 && n % 100 <= 19 { return .many }
        return .other
    }""",
    "br": """\
    private static func pluralBr(_ n: Int) -> PluralCategory {
        let mod10 = n % 10
        let mod100 = n % 100
        if mod10 == 1 && mod100 != 11 && mod100 != 71 && mod100 != 91 { return .one }
        if mod10 == 2 && mod100 != 12 && mod100 != 72 && mod100 != 92 { return .two }
        if (mod10 == 3 || mod10 == 4 || mod10 == 9) && !(mod100 >= 10 && mod100 <= 19) && !(mod100 >= 70 && mod100 <= 79) && !(mod100 >= 90 && mod100 <= 99) { return .few }
        if n != 0 && n % 1000000 == 0 { return .many }
        return .other
    }""",
    "kw": """\
    private static func pluralKw(_ n: Int) -> PluralCategory {
        if n == 0 { return .zero }
        if n == 1 { return .one }
        let mod100 = n % 100
        if mod100 == 2 || mod100 == 22 || mod100 == 42 || mod100 == 62 || mod100 == 82 { return .two }
        if mod100 == 3 || mod100 == 23 || mod100 == 43 || mod100 == 63 || mod100 == 83 { return .few }
        if n != 1 && (mod100 == 1 || mod100 == 21 || mod100 == 41 || mod100 == 61 || mod100 == 81) { return .many }
        return .other
    }""",
    "shi": """\
    private static func pluralShi(_ n: Int) -> PluralCategory {
        if n == 0 || n == 1 { return .one }
        if n >= 2 && n <= 10 { return .few }
        return .other
    }""",
    "tzm": """\
    private static func pluralTzm(_ n: Int) -> PluralCategory {
        if n == 0 || n == 1 || (n >= 11 && n <= 99) { return .one }
        return .other
    }""",
}

# Mapping from rule name to function reference for named rules
_SWIFT_FUNC_NAMES = {
    "cs_sk": "pluralCsSk",
    "lt": "pluralLt",
    "ro": "pluralRo",
    "slavic_bcs": "pluralSlavicBcs",
    "pl": "pluralPl",
    "ru_uk": "pluralRuUk",
    "sl": "pluralSl",
    "ar": "pluralAr",
    "lv": "pluralLv",
    "cy": "pluralCy",
    "gv": "pluralGv",
    "gd": "pluralGd",
    "ga": "pluralGa",
    "mt": "pluralMt",
    "br": "pluralBr",
    "kw": "pluralKw",
    "shi": "pluralShi",
    "tzm": "pluralTzm",
}


def is_simple_plural(rule: str) -> bool:
    """Return True if the rule can be expressed as a single-line closure."""
    return rule in _SWIFT_SIMPLE


def get_swift_plural(rule: str) -> str:
    """Return the Swift expression for the given plural rule."""
    if rule in _SWIFT:
        return _SWIFT[rule]
    # Wrap named function in closure to satisfy @Sendable requirement
    return "{ " + _SWIFT_FUNC_NAMES[rule] + "($0) }"


def get_swift_named_methods() -> dict[str, str]:
    """Return all named function bodies needed for complex plural rules."""
    return dict(_SWIFT_NAMED)
