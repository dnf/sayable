"""Gleam plural rule definitions for all 23 patterns."""

from __future__ import annotations

_GLEAM = {
    "other_only": "fn(_) { types.Other }",
    "one_other": "fn(n) { case n { 1 -> types.One _ -> types.Other } }",
    "one_other_zero_one": "fn(n) { case n { 0 | 1 -> types.One _ -> types.Other } }",
    "cs_sk": "fn(n) { case n { 1 -> types.One 2 | 3 | 4 -> types.Few _ -> types.Other } }",
    "lt": "fn(n) { case n % 10 == 1 && n % 100 != 11 { True -> types.One _ -> case n % 10 >= 2 && n % 10 <= 9 && { n % 100 < 12 || n % 100 > 19 } { True -> types.Few _ -> types.Other } } }",
    "ro": "fn(n) { case n { 1 -> types.One _ -> case n == 0 || { n % 100 >= 1 && n % 100 <= 19 } { True -> types.Few _ -> types.Other } } }",
    "slavic_bcs": "fn(n) { case n % 10 == 1 && n % 100 != 11 { True -> types.One _ -> case n % 10 >= 2 && n % 10 <= 4 && { n % 100 < 12 || n % 100 > 14 } { True -> types.Few _ -> types.Other } } }",
    "pl": "fn(n) { case n { 1 -> types.One _ -> case n % 10 >= 2 && n % 10 <= 4 && { n % 100 < 12 || n % 100 > 14 } { True -> types.Few _ -> types.Many } } }",
    "ru_uk": "fn(n) { case n % 10 == 1 && n % 100 != 11 { True -> types.One _ -> case n % 10 >= 2 && n % 10 <= 4 && { n % 100 < 12 || n % 100 > 14 } { True -> types.Few _ -> types.Many } } }",
    "sl": "fn(n) { case n % 100 { 1 -> types.One 2 -> types.Two 3 | 4 -> types.Few _ -> types.Other } }",
    "ar": "fn(n) { case n { 0 -> types.Zero 1 -> types.One 2 -> types.Two _ -> case n % 100 >= 3 && n % 100 <= 10 { True -> types.Few _ -> case n % 100 >= 11 && n % 100 <= 99 { True -> types.Many _ -> types.Other } } } }",
    "lv": "fn(n) { case n % 10 == 0 || { n % 100 >= 11 && n % 100 <= 19 } { True -> types.Zero _ -> case n % 10 == 1 && n % 100 != 11 { True -> types.One _ -> types.Other } } }",
    "he": "fn(n) { case n { 1 -> types.One 2 -> types.Two _ -> types.Other } }",
    "mk": "fn(n) { case n % 10 == 1 && n % 100 != 11 { True -> types.One _ -> types.Other } }",
    "cy": "fn(n) { case n { 0 -> types.Zero 1 -> types.One 2 -> types.Two 3 -> types.Few 6 -> types.Many _ -> types.Other } }",
    "gv": "fn(n) { case n % 10 { 1 -> types.One 2 -> types.Two _ -> case n % 100 == 0 || n % 100 == 20 || n % 100 == 40 || n % 100 == 60 || n % 100 == 80 { True -> types.Few _ -> types.Other } } }",
    "gd": "fn(n) { case n { 1 | 11 -> types.One 2 | 12 -> types.Two _ -> case { n >= 3 && n <= 10 } || { n >= 13 && n <= 19 } { True -> types.Few _ -> types.Other } } }",
    "ga": "fn(n) { case n { 1 -> types.One 2 -> types.Two _ -> case n >= 3 && n <= 6 { True -> types.Few _ -> case n >= 7 && n <= 10 { True -> types.Many _ -> types.Other } } } }",
    "mt": "fn(n) { case n { 1 -> types.One 2 -> types.Two _ -> case n == 0 || { n % 100 >= 3 && n % 100 <= 10 } { True -> types.Few _ -> case n % 100 >= 11 && n % 100 <= 19 { True -> types.Many _ -> types.Other } } } }",
    "br": "fn(n) { case n % 10 == 1 && n % 100 != 11 && n % 100 != 71 && n % 100 != 91 { True -> types.One _ -> case n % 10 == 2 && n % 100 != 12 && n % 100 != 72 && n % 100 != 92 { True -> types.Two _ -> case { n % 10 == 3 || n % 10 == 4 || n % 10 == 9 } && { n % 100 < 10 || n % 100 > 19 } && { n % 100 < 70 || n % 100 > 79 } && { n % 100 < 90 || n % 100 > 99 } { True -> types.Few _ -> case n != 0 && n % 1_000_000 == 0 { True -> types.Many _ -> types.Other } } } } }",
    "kw": "fn(n) { case n { 0 -> types.Zero 1 -> types.One _ -> case n % 100 == 2 || n % 100 == 22 || n % 100 == 42 || n % 100 == 62 || n % 100 == 82 { True -> types.Two _ -> case n % 100 == 3 || n % 100 == 23 || n % 100 == 43 || n % 100 == 63 || n % 100 == 83 { True -> types.Few _ -> case n != 1 && { n % 100 == 1 || n % 100 == 21 || n % 100 == 41 || n % 100 == 61 || n % 100 == 81 } { True -> types.Many _ -> types.Other } } } } }",
    "shi": "fn(n) { case n { 0 | 1 -> types.One _ -> case n >= 2 && n <= 10 { True -> types.Few _ -> types.Other } } }",
    "tzm": "fn(n) { case n { 0 | 1 -> types.One _ -> case n >= 11 && n <= 99 { True -> types.One _ -> types.Other } } }",
}


def get_gleam_plural(rule: str) -> str:
    """Return the Gleam expression for the given plural rule name."""
    return _GLEAM[rule]
