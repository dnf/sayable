"""F# plural rule definitions for all 23 patterns."""

from __future__ import annotations

# Simple rules that can be expressed as inline lambdas
_FSHARP_SIMPLE = {
    "other_only",
    "one_other",
    "one_other_zero_one",
    "he",
    "mk",
}

_FSHARP = {
    "other_only": "(fun _ -> Other)",
    "one_other": "(fun n -> if n = 1 then One else Other)",
    "one_other_zero_one": "(fun n -> if n = 0 || n = 1 then One else Other)",
    "he": "(fun n -> if n = 1 then One elif n = 2 then Two else Other)",
    "mk": "(fun n -> if n % 10 = 1 && n % 100 <> 11 then One else Other)",
}

# Complex rules that need named functions
_FSHARP_NAMED = {
    "cs_sk": """\
    let private pluralCsSk (n: int) : PluralCategory =
        if n = 1 then One
        elif n >= 2 && n <= 4 then Few
        else Other""",
    "lt": """\
    let private pluralLt (n: int) : PluralCategory =
        let mod10 = n % 10
        let mod100 = n % 100
        if mod10 = 1 && mod100 <> 11 then One
        elif mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19) then Few
        else Other""",
    "ro": """\
    let private pluralRo (n: int) : PluralCategory =
        if n = 1 then One
        elif n = 0 || (n % 100 >= 1 && n % 100 <= 19) then Few
        else Other""",
    "slavic_bcs": """\
    let private pluralSlavicBcs (n: int) : PluralCategory =
        let mod10 = n % 10
        let mod100 = n % 100
        if mod10 = 1 && mod100 <> 11 then One
        elif mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) then Few
        else Other""",
    "pl": """\
    let private pluralPl (n: int) : PluralCategory =
        if n = 1 then One
        else
            let mod10 = n % 10
            let mod100 = n % 100
            if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) then Few
            else Many""",
    "ru_uk": """\
    let private pluralRuUk (n: int) : PluralCategory =
        let mod10 = n % 10
        let mod100 = n % 100
        if mod10 = 1 && mod100 <> 11 then One
        elif mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) then Few
        else Many""",
    "sl": """\
    let private pluralSl (n: int) : PluralCategory =
        let mod100 = n % 100
        if mod100 = 1 then One
        elif mod100 = 2 then Two
        elif mod100 = 3 || mod100 = 4 then Few
        else Other""",
    "ar": """\
    let private pluralAr (n: int) : PluralCategory =
        if n = 0 then Zero
        elif n = 1 then One
        elif n = 2 then Two
        elif n % 100 >= 3 && n % 100 <= 10 then Few
        elif n % 100 >= 11 && n % 100 <= 99 then Many
        else Other""",
    "lv": """\
    let private pluralLv (n: int) : PluralCategory =
        let mod10 = n % 10
        let mod100 = n % 100
        if mod10 = 0 || (mod100 >= 11 && mod100 <= 19) then Zero
        elif mod10 = 1 && mod100 <> 11 then One
        else Other""",
    "cy": """\
    let private pluralCy (n: int) : PluralCategory =
        if n = 0 then Zero
        elif n = 1 then One
        elif n = 2 then Two
        elif n = 3 then Few
        elif n = 6 then Many
        else Other""",
    "gv": """\
    let private pluralGv (n: int) : PluralCategory =
        let mod10 = n % 10
        let mod100 = n % 100
        if mod10 = 1 then One
        elif mod10 = 2 then Two
        elif mod100 = 0 || mod100 = 20 || mod100 = 40 || mod100 = 60 || mod100 = 80 then Few
        else Other""",
    "gd": """\
    let private pluralGd (n: int) : PluralCategory =
        if n = 1 || n = 11 then One
        elif n = 2 || n = 12 then Two
        elif (n >= 3 && n <= 10) || (n >= 13 && n <= 19) then Few
        else Other""",
    "ga": """\
    let private pluralGa (n: int) : PluralCategory =
        if n = 1 then One
        elif n = 2 then Two
        elif n >= 3 && n <= 6 then Few
        elif n >= 7 && n <= 10 then Many
        else Other""",
    "mt": """\
    let private pluralMt (n: int) : PluralCategory =
        if n = 1 then One
        elif n = 2 then Two
        elif n = 0 || (n % 100 >= 3 && n % 100 <= 10) then Few
        elif n % 100 >= 11 && n % 100 <= 19 then Many
        else Other""",
    "br": """\
    let private pluralBr (n: int) : PluralCategory =
        let mod10 = n % 10
        let mod100 = n % 100
        if mod10 = 1 && mod100 <> 11 && mod100 <> 71 && mod100 <> 91 then One
        elif mod10 = 2 && mod100 <> 12 && mod100 <> 72 && mod100 <> 92 then Two
        elif (mod10 = 3 || mod10 = 4 || mod10 = 9) && not (mod100 >= 10 && mod100 <= 19) && not (mod100 >= 70 && mod100 <= 79) && not (mod100 >= 90 && mod100 <= 99) then Few
        elif n <> 0 && n % 1000000 = 0 then Many
        else Other""",
    "kw": """\
    let private pluralKw (n: int) : PluralCategory =
        if n = 0 then Zero
        elif n = 1 then One
        else
            let mod100 = n % 100
            if mod100 = 2 || mod100 = 22 || mod100 = 42 || mod100 = 62 || mod100 = 82 then Two
            elif mod100 = 3 || mod100 = 23 || mod100 = 43 || mod100 = 63 || mod100 = 83 then Few
            elif n <> 1 && (mod100 = 1 || mod100 = 21 || mod100 = 41 || mod100 = 61 || mod100 = 81) then Many
            else Other""",
    "shi": """\
    let private pluralShi (n: int) : PluralCategory =
        if n = 0 || n = 1 then One
        elif n >= 2 && n <= 10 then Few
        else Other""",
    "tzm": """\
    let private pluralTzm (n: int) : PluralCategory =
        if n = 0 || n = 1 || (n >= 11 && n <= 99) then One
        else Other""",
}

# Mapping from rule name to function name for named rules
_FSHARP_FUNCTION_NAMES = {
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
    """Return True if the rule can be expressed as a single-line lambda."""
    return rule in _FSHARP_SIMPLE


def get_fsharp_plural(rule: str) -> str:
    """Return the F# expression for the given plural rule."""
    if rule in _FSHARP:
        return _FSHARP[rule]
    return _FSHARP_FUNCTION_NAMES[rule]


def get_fsharp_named_functions() -> dict[str, str]:
    """Return all named function bodies needed for complex plural rules."""
    return dict(_FSHARP_NAMED)
