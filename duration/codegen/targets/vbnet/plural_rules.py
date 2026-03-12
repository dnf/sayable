"""VB.NET plural rule definitions for all 23 patterns."""

from __future__ import annotations

# Simple rules that can be expressed as inline lambdas
_VBNET_SIMPLE = {
    "other_only",
    "one_other",
    "one_other_zero_one",
    "he",
    "mk",
}

_VBNET = {
    "other_only": "Function(n) PluralCategory.Other",
    "one_other": "Function(n) If(n = 1, PluralCategory.One, PluralCategory.Other)",
    "one_other_zero_one": "Function(n) If(n = 0 OrElse n = 1, PluralCategory.One, PluralCategory.Other)",
    "he": "Function(n) If(n = 1, PluralCategory.One, If(n = 2, PluralCategory.Two, PluralCategory.Other))",
    "mk": "Function(n) If(n Mod 10 = 1 AndAlso n Mod 100 <> 11, PluralCategory.One, PluralCategory.Other)",
}

# Complex rules that need named shared methods
_VBNET_NAMED = {
    "cs_sk": """\
    Private Function PluralCsSk(n As Integer) As PluralCategory
        If n = 1 Then Return PluralCategory.One
        If n >= 2 AndAlso n <= 4 Then Return PluralCategory.Few
        Return PluralCategory.Other
    End Function""",
    "lt": """\
    Private Function PluralLt(n As Integer) As PluralCategory
        Dim mod10 As Integer = n Mod 10
        Dim mod100 As Integer = n Mod 100
        If mod10 = 1 AndAlso mod100 <> 11 Then Return PluralCategory.One
        If mod10 >= 2 AndAlso mod10 <= 9 AndAlso (mod100 < 12 OrElse mod100 > 19) Then Return PluralCategory.Few
        Return PluralCategory.Other
    End Function""",
    "ro": """\
    Private Function PluralRo(n As Integer) As PluralCategory
        If n = 1 Then Return PluralCategory.One
        If n = 0 OrElse (n Mod 100 >= 1 AndAlso n Mod 100 <= 19) Then Return PluralCategory.Few
        Return PluralCategory.Other
    End Function""",
    "slavic_bcs": """\
    Private Function PluralSlavicBcs(n As Integer) As PluralCategory
        Dim mod10 As Integer = n Mod 10
        Dim mod100 As Integer = n Mod 100
        If mod10 = 1 AndAlso mod100 <> 11 Then Return PluralCategory.One
        If mod10 >= 2 AndAlso mod10 <= 4 AndAlso (mod100 < 12 OrElse mod100 > 14) Then Return PluralCategory.Few
        Return PluralCategory.Other
    End Function""",
    "pl": """\
    Private Function PluralPl(n As Integer) As PluralCategory
        If n = 1 Then Return PluralCategory.One
        Dim mod10 As Integer = n Mod 10
        Dim mod100 As Integer = n Mod 100
        If mod10 >= 2 AndAlso mod10 <= 4 AndAlso (mod100 < 12 OrElse mod100 > 14) Then Return PluralCategory.Few
        Return PluralCategory.Many
    End Function""",
    "ru_uk": """\
    Private Function PluralRuUk(n As Integer) As PluralCategory
        Dim mod10 As Integer = n Mod 10
        Dim mod100 As Integer = n Mod 100
        If mod10 = 1 AndAlso mod100 <> 11 Then Return PluralCategory.One
        If mod10 >= 2 AndAlso mod10 <= 4 AndAlso (mod100 < 12 OrElse mod100 > 14) Then Return PluralCategory.Few
        Return PluralCategory.Many
    End Function""",
    "sl": """\
    Private Function PluralSl(n As Integer) As PluralCategory
        Dim mod100 As Integer = n Mod 100
        If mod100 = 1 Then Return PluralCategory.One
        If mod100 = 2 Then Return PluralCategory.Two
        If mod100 = 3 OrElse mod100 = 4 Then Return PluralCategory.Few
        Return PluralCategory.Other
    End Function""",
    "ar": """\
    Private Function PluralAr(n As Integer) As PluralCategory
        If n = 0 Then Return PluralCategory.Zero
        If n = 1 Then Return PluralCategory.One
        If n = 2 Then Return PluralCategory.Two
        If n Mod 100 >= 3 AndAlso n Mod 100 <= 10 Then Return PluralCategory.Few
        If n Mod 100 >= 11 AndAlso n Mod 100 <= 99 Then Return PluralCategory.Many
        Return PluralCategory.Other
    End Function""",
    "lv": """\
    Private Function PluralLv(n As Integer) As PluralCategory
        Dim mod10 As Integer = n Mod 10
        Dim mod100 As Integer = n Mod 100
        If mod10 = 0 OrElse (mod100 >= 11 AndAlso mod100 <= 19) Then Return PluralCategory.Zero
        If mod10 = 1 AndAlso mod100 <> 11 Then Return PluralCategory.One
        Return PluralCategory.Other
    End Function""",
    "cy": """\
    Private Function PluralCy(n As Integer) As PluralCategory
        If n = 0 Then Return PluralCategory.Zero
        If n = 1 Then Return PluralCategory.One
        If n = 2 Then Return PluralCategory.Two
        If n = 3 Then Return PluralCategory.Few
        If n = 6 Then Return PluralCategory.Many
        Return PluralCategory.Other
    End Function""",
    "gv": """\
    Private Function PluralGv(n As Integer) As PluralCategory
        Dim mod10 As Integer = n Mod 10
        Dim mod100 As Integer = n Mod 100
        If mod10 = 1 Then Return PluralCategory.One
        If mod10 = 2 Then Return PluralCategory.Two
        If mod100 = 0 OrElse mod100 = 20 OrElse mod100 = 40 OrElse mod100 = 60 OrElse mod100 = 80 Then Return PluralCategory.Few
        Return PluralCategory.Other
    End Function""",
    "gd": """\
    Private Function PluralGd(n As Integer) As PluralCategory
        If n = 1 OrElse n = 11 Then Return PluralCategory.One
        If n = 2 OrElse n = 12 Then Return PluralCategory.Two
        If (n >= 3 AndAlso n <= 10) OrElse (n >= 13 AndAlso n <= 19) Then Return PluralCategory.Few
        Return PluralCategory.Other
    End Function""",
    "ga": """\
    Private Function PluralGa(n As Integer) As PluralCategory
        If n = 1 Then Return PluralCategory.One
        If n = 2 Then Return PluralCategory.Two
        If n >= 3 AndAlso n <= 6 Then Return PluralCategory.Few
        If n >= 7 AndAlso n <= 10 Then Return PluralCategory.Many
        Return PluralCategory.Other
    End Function""",
    "mt": """\
    Private Function PluralMt(n As Integer) As PluralCategory
        If n = 1 Then Return PluralCategory.One
        If n = 2 Then Return PluralCategory.Two
        If n = 0 OrElse (n Mod 100 >= 3 AndAlso n Mod 100 <= 10) Then Return PluralCategory.Few
        If n Mod 100 >= 11 AndAlso n Mod 100 <= 19 Then Return PluralCategory.Many
        Return PluralCategory.Other
    End Function""",
    "br": """\
    Private Function PluralBr(n As Integer) As PluralCategory
        Dim mod10 As Integer = n Mod 10
        Dim mod100 As Integer = n Mod 100
        If mod10 = 1 AndAlso mod100 <> 11 AndAlso mod100 <> 71 AndAlso mod100 <> 91 Then Return PluralCategory.One
        If mod10 = 2 AndAlso mod100 <> 12 AndAlso mod100 <> 72 AndAlso mod100 <> 92 Then Return PluralCategory.Two
        If (mod10 = 3 OrElse mod10 = 4 OrElse mod10 = 9) AndAlso Not (mod100 >= 10 AndAlso mod100 <= 19) AndAlso Not (mod100 >= 70 AndAlso mod100 <= 79) AndAlso Not (mod100 >= 90 AndAlso mod100 <= 99) Then Return PluralCategory.Few
        If n <> 0 AndAlso n Mod 1000000 = 0 Then Return PluralCategory.Many
        Return PluralCategory.Other
    End Function""",
    "kw": """\
    Private Function PluralKw(n As Integer) As PluralCategory
        If n = 0 Then Return PluralCategory.Zero
        If n = 1 Then Return PluralCategory.One
        Dim mod100 As Integer = n Mod 100
        If mod100 = 2 OrElse mod100 = 22 OrElse mod100 = 42 OrElse mod100 = 62 OrElse mod100 = 82 Then Return PluralCategory.Two
        If mod100 = 3 OrElse mod100 = 23 OrElse mod100 = 43 OrElse mod100 = 63 OrElse mod100 = 83 Then Return PluralCategory.Few
        If n <> 1 AndAlso (mod100 = 1 OrElse mod100 = 21 OrElse mod100 = 41 OrElse mod100 = 61 OrElse mod100 = 81) Then Return PluralCategory.Many
        Return PluralCategory.Other
    End Function""",
    "shi": """\
    Private Function PluralShi(n As Integer) As PluralCategory
        If n = 0 OrElse n = 1 Then Return PluralCategory.One
        If n >= 2 AndAlso n <= 10 Then Return PluralCategory.Few
        Return PluralCategory.Other
    End Function""",
    "tzm": """\
    Private Function PluralTzm(n As Integer) As PluralCategory
        If n = 0 OrElse n = 1 OrElse (n >= 11 AndAlso n <= 99) Then Return PluralCategory.One
        Return PluralCategory.Other
    End Function""",
}

# Mapping from rule name to method name for named rules
_VBNET_METHOD_NAMES = {
    "cs_sk": "AddressOf PluralCsSk",
    "lt": "AddressOf PluralLt",
    "ro": "AddressOf PluralRo",
    "slavic_bcs": "AddressOf PluralSlavicBcs",
    "pl": "AddressOf PluralPl",
    "ru_uk": "AddressOf PluralRuUk",
    "sl": "AddressOf PluralSl",
    "ar": "AddressOf PluralAr",
    "lv": "AddressOf PluralLv",
    "cy": "AddressOf PluralCy",
    "gv": "AddressOf PluralGv",
    "gd": "AddressOf PluralGd",
    "ga": "AddressOf PluralGa",
    "mt": "AddressOf PluralMt",
    "br": "AddressOf PluralBr",
    "kw": "AddressOf PluralKw",
    "shi": "AddressOf PluralShi",
    "tzm": "AddressOf PluralTzm",
}


def is_simple_plural(rule: str) -> bool:
    """Return True if the rule can be expressed as a single-line lambda."""
    return rule in _VBNET_SIMPLE


def get_vbnet_plural(rule: str) -> str:
    """Return the VB.NET expression for the given plural rule."""
    if rule in _VBNET:
        return _VBNET[rule]
    return _VBNET_METHOD_NAMES[rule]


def get_vbnet_named_methods() -> dict[str, str]:
    """Return all named method bodies needed for complex plural rules."""
    return dict(_VBNET_NAMED)
