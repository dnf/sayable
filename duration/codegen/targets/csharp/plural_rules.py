"""C# plural rule definitions for all 23 patterns."""

from __future__ import annotations

# Simple rules that can be expressed as inline lambdas
_CSHARP_SIMPLE = {
    "other_only",
    "one_other",
    "one_other_zero_one",
    "he",
    "mk",
}

_CSHARP = {
    "other_only": "n => PluralCategory.Other",
    "one_other": "n => n == 1 ? PluralCategory.One : PluralCategory.Other",
    "one_other_zero_one": "n => (n == 0 || n == 1) ? PluralCategory.One : PluralCategory.Other",
    "he": "n => n == 1 ? PluralCategory.One : n == 2 ? PluralCategory.Two : PluralCategory.Other",
    "mk": "n => (n % 10 == 1 && n % 100 != 11) ? PluralCategory.One : PluralCategory.Other",
}

# Complex rules that need named static methods
_CSHARP_NAMED = {
    "cs_sk": """\
    private static PluralCategory PluralCsSk(int n)
    {
        if (n == 1) return PluralCategory.One;
        if (n >= 2 && n <= 4) return PluralCategory.Few;
        return PluralCategory.Other;
    }""",
    "lt": """\
    private static PluralCategory PluralLt(int n)
    {
        int mod10 = n % 10;
        int mod100 = n % 100;
        if (mod10 == 1 && mod100 != 11) return PluralCategory.One;
        if (mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19)) return PluralCategory.Few;
        return PluralCategory.Other;
    }""",
    "ro": """\
    private static PluralCategory PluralRo(int n)
    {
        if (n == 1) return PluralCategory.One;
        if (n == 0 || (n % 100 >= 1 && n % 100 <= 19)) return PluralCategory.Few;
        return PluralCategory.Other;
    }""",
    "slavic_bcs": """\
    private static PluralCategory PluralSlavicBcs(int n)
    {
        int mod10 = n % 10;
        int mod100 = n % 100;
        if (mod10 == 1 && mod100 != 11) return PluralCategory.One;
        if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory.Few;
        return PluralCategory.Other;
    }""",
    "pl": """\
    private static PluralCategory PluralPl(int n)
    {
        if (n == 1) return PluralCategory.One;
        int mod10 = n % 10;
        int mod100 = n % 100;
        if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory.Few;
        return PluralCategory.Many;
    }""",
    "ru_uk": """\
    private static PluralCategory PluralRuUk(int n)
    {
        int mod10 = n % 10;
        int mod100 = n % 100;
        if (mod10 == 1 && mod100 != 11) return PluralCategory.One;
        if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory.Few;
        return PluralCategory.Many;
    }""",
    "sl": """\
    private static PluralCategory PluralSl(int n)
    {
        int mod100 = n % 100;
        if (mod100 == 1) return PluralCategory.One;
        if (mod100 == 2) return PluralCategory.Two;
        if (mod100 == 3 || mod100 == 4) return PluralCategory.Few;
        return PluralCategory.Other;
    }""",
    "ar": """\
    private static PluralCategory PluralAr(int n)
    {
        if (n == 0) return PluralCategory.Zero;
        if (n == 1) return PluralCategory.One;
        if (n == 2) return PluralCategory.Two;
        if (n % 100 >= 3 && n % 100 <= 10) return PluralCategory.Few;
        if (n % 100 >= 11 && n % 100 <= 99) return PluralCategory.Many;
        return PluralCategory.Other;
    }""",
    "lv": """\
    private static PluralCategory PluralLv(int n)
    {
        int mod10 = n % 10;
        int mod100 = n % 100;
        if (mod10 == 0 || (mod100 >= 11 && mod100 <= 19)) return PluralCategory.Zero;
        if (mod10 == 1 && mod100 != 11) return PluralCategory.One;
        return PluralCategory.Other;
    }""",
    "cy": """\
    private static PluralCategory PluralCy(int n)
    {
        if (n == 0) return PluralCategory.Zero;
        if (n == 1) return PluralCategory.One;
        if (n == 2) return PluralCategory.Two;
        if (n == 3) return PluralCategory.Few;
        if (n == 6) return PluralCategory.Many;
        return PluralCategory.Other;
    }""",
    "gv": """\
    private static PluralCategory PluralGv(int n)
    {
        int mod10 = n % 10;
        int mod100 = n % 100;
        if (mod10 == 1) return PluralCategory.One;
        if (mod10 == 2) return PluralCategory.Two;
        if (mod100 == 0 || mod100 == 20 || mod100 == 40 || mod100 == 60 || mod100 == 80) return PluralCategory.Few;
        return PluralCategory.Other;
    }""",
    "gd": """\
    private static PluralCategory PluralGd(int n)
    {
        if (n == 1 || n == 11) return PluralCategory.One;
        if (n == 2 || n == 12) return PluralCategory.Two;
        if ((n >= 3 && n <= 10) || (n >= 13 && n <= 19)) return PluralCategory.Few;
        return PluralCategory.Other;
    }""",
    "ga": """\
    private static PluralCategory PluralGa(int n)
    {
        if (n == 1) return PluralCategory.One;
        if (n == 2) return PluralCategory.Two;
        if (n >= 3 && n <= 6) return PluralCategory.Few;
        if (n >= 7 && n <= 10) return PluralCategory.Many;
        return PluralCategory.Other;
    }""",
    "mt": """\
    private static PluralCategory PluralMt(int n)
    {
        if (n == 1) return PluralCategory.One;
        if (n == 2) return PluralCategory.Two;
        if (n == 0 || (n % 100 >= 3 && n % 100 <= 10)) return PluralCategory.Few;
        if (n % 100 >= 11 && n % 100 <= 19) return PluralCategory.Many;
        return PluralCategory.Other;
    }""",
    "br": """\
    private static PluralCategory PluralBr(int n)
    {
        int mod10 = n % 10;
        int mod100 = n % 100;
        if (mod10 == 1 && mod100 != 11 && mod100 != 71 && mod100 != 91) return PluralCategory.One;
        if (mod10 == 2 && mod100 != 12 && mod100 != 72 && mod100 != 92) return PluralCategory.Two;
        if ((mod10 == 3 || mod10 == 4 || mod10 == 9) && !(mod100 >= 10 && mod100 <= 19) && !(mod100 >= 70 && mod100 <= 79) && !(mod100 >= 90 && mod100 <= 99)) return PluralCategory.Few;
        if (n != 0 && n % 1000000 == 0) return PluralCategory.Many;
        return PluralCategory.Other;
    }""",
    "kw": """\
    private static PluralCategory PluralKw(int n)
    {
        if (n == 0) return PluralCategory.Zero;
        if (n == 1) return PluralCategory.One;
        int mod100 = n % 100;
        if (mod100 == 2 || mod100 == 22 || mod100 == 42 || mod100 == 62 || mod100 == 82) return PluralCategory.Two;
        if (mod100 == 3 || mod100 == 23 || mod100 == 43 || mod100 == 63 || mod100 == 83) return PluralCategory.Few;
        if (n != 1 && (mod100 == 1 || mod100 == 21 || mod100 == 41 || mod100 == 61 || mod100 == 81)) return PluralCategory.Many;
        return PluralCategory.Other;
    }""",
    "shi": """\
    private static PluralCategory PluralShi(int n)
    {
        if (n == 0 || n == 1) return PluralCategory.One;
        if (n >= 2 && n <= 10) return PluralCategory.Few;
        return PluralCategory.Other;
    }""",
    "tzm": """\
    private static PluralCategory PluralTzm(int n)
    {
        if (n == 0 || n == 1 || (n >= 11 && n <= 99)) return PluralCategory.One;
        return PluralCategory.Other;
    }""",
}

# Mapping from rule name to method name for named rules
_CSHARP_METHOD_NAMES = {
    "cs_sk": "PluralCsSk",
    "lt": "PluralLt",
    "ro": "PluralRo",
    "slavic_bcs": "PluralSlavicBcs",
    "pl": "PluralPl",
    "ru_uk": "PluralRuUk",
    "sl": "PluralSl",
    "ar": "PluralAr",
    "lv": "PluralLv",
    "cy": "PluralCy",
    "gv": "PluralGv",
    "gd": "PluralGd",
    "ga": "PluralGa",
    "mt": "PluralMt",
    "br": "PluralBr",
    "kw": "PluralKw",
    "shi": "PluralShi",
    "tzm": "PluralTzm",
}


def is_simple_plural(rule: str) -> bool:
    """Return True if the rule can be expressed as a single-line lambda."""
    return rule in _CSHARP_SIMPLE


def get_csharp_plural(rule: str) -> str:
    """Return the C# expression for the given plural rule."""
    if rule in _CSHARP:
        return _CSHARP[rule]
    return _CSHARP_METHOD_NAMES[rule]


def get_csharp_named_methods() -> dict[str, str]:
    """Return all named method bodies needed for complex plural rules."""
    return dict(_CSHARP_NAMED)
