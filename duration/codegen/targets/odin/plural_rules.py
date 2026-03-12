"""Odin plural rule definitions for all 23 CLDR cardinal patterns."""

from __future__ import annotations

_ODIN = {
    "other_only": """\
        return .Other""",
    "one_other": """\
        if n == 1 do return .One
        return .Other""",
    "one_other_zero_one": """\
        if n == 0 || n == 1 do return .One
        return .Other""",
    "cs_sk": """\
        if n == 1 do return .One
        if n >= 2 && n <= 4 do return .Few
        return .Other""",
    "lt": """\
        mod10 := n %% 10
        mod100 := n %% 100
        if mod10 == 1 && mod100 != 11 do return .One
        if mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19) do return .Few
        return .Other""",
    "ro": """\
        if n == 1 do return .One
        if n == 0 || (n %% 100 >= 1 && n %% 100 <= 19) do return .Few
        return .Other""",
    "slavic_bcs": """\
        mod10 := n %% 10
        mod100 := n %% 100
        if mod10 == 1 && mod100 != 11 do return .One
        if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) do return .Few
        return .Other""",
    "pl": """\
        if n == 1 do return .One
        mod10 := n %% 10
        mod100 := n %% 100
        if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) do return .Few
        return .Many""",
    "ru_uk": """\
        mod10 := n %% 10
        mod100 := n %% 100
        if mod10 == 1 && mod100 != 11 do return .One
        if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) do return .Few
        return .Many""",
    "sl": """\
        mod100 := n %% 100
        if mod100 == 1 do return .One
        if mod100 == 2 do return .Two
        if mod100 == 3 || mod100 == 4 do return .Few
        return .Other""",
    "ar": """\
        if n == 0 do return .Zero
        if n == 1 do return .One
        if n == 2 do return .Two
        mod100 := n %% 100
        if mod100 >= 3 && mod100 <= 10 do return .Few
        if mod100 >= 11 && mod100 <= 99 do return .Many
        return .Other""",
    "lv": """\
        mod10 := n %% 10
        mod100 := n %% 100
        if mod10 == 0 || (mod100 >= 11 && mod100 <= 19) do return .Zero
        if mod10 == 1 && mod100 != 11 do return .One
        return .Other""",
    "he": """\
        if n == 1 do return .One
        if n == 2 do return .Two
        return .Other""",
    "mk": """\
        mod10 := n %% 10
        mod100 := n %% 100
        if mod10 == 1 && mod100 != 11 do return .One
        return .Other""",
    "cy": """\
        if n == 0 do return .Zero
        if n == 1 do return .One
        if n == 2 do return .Two
        if n == 3 do return .Few
        if n == 6 do return .Many
        return .Other""",
    "gv": """\
        mod10 := n %% 10
        mod100 := n %% 100
        if mod10 == 1 do return .One
        if mod10 == 2 do return .Two
        if mod100 == 0 || mod100 == 20 || mod100 == 40 || mod100 == 60 || mod100 == 80 do return .Few
        return .Other""",
    "gd": """\
        if n == 1 || n == 11 do return .One
        if n == 2 || n == 12 do return .Two
        if (n >= 3 && n <= 10) || (n >= 13 && n <= 19) do return .Few
        return .Other""",
    "ga": """\
        if n == 1 do return .One
        if n == 2 do return .Two
        if n >= 3 && n <= 6 do return .Few
        if n >= 7 && n <= 10 do return .Many
        return .Other""",
    "mt": """\
        if n == 1 do return .One
        if n == 2 do return .Two
        mod100 := n %% 100
        if n == 0 || (mod100 >= 3 && mod100 <= 10) do return .Few
        if mod100 >= 11 && mod100 <= 19 do return .Many
        return .Other""",
    "br": """\
        mod10 := n %% 10
        mod100 := n %% 100
        if mod10 == 1 && mod100 != 11 && mod100 != 71 && mod100 != 91 do return .One
        if mod10 == 2 && mod100 != 12 && mod100 != 72 && mod100 != 92 do return .Two
        if (mod10 == 3 || mod10 == 4 || mod10 == 9) && (mod100 < 10 || mod100 > 19) && (mod100 < 70 || mod100 > 79) && (mod100 < 90 || mod100 > 99) do return .Few
        if n != 0 && n %% 1000000 == 0 do return .Many
        return .Other""",
    "kw": """\
        if n == 0 do return .Zero
        if n == 1 do return .One
        mod100 := n %% 100
        if mod100 == 2 || mod100 == 22 || mod100 == 42 || mod100 == 62 || mod100 == 82 do return .Two
        if mod100 == 3 || mod100 == 23 || mod100 == 43 || mod100 == 63 || mod100 == 83 do return .Few
        if n != 1 && (mod100 == 1 || mod100 == 21 || mod100 == 41 || mod100 == 61 || mod100 == 81) do return .Many
        return .Other""",
    "shi": """\
        if n == 0 || n == 1 do return .One
        if n >= 2 && n <= 10 do return .Few
        return .Other""",
    "tzm": """\
        if n == 0 || n == 1 || (n >= 11 && n <= 99) do return .One
        return .Other""",
}


def get_odin_plural(rule: str) -> str:
    return _ODIN[rule]
