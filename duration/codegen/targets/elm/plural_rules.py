"""Elm plural rule definitions for all 23 patterns.

Rules that need local bindings are stored as tuples of (bindings, body)
where bindings is a list of (name, expr) pairs. Rules without bindings
are stored as simple body strings.
"""

from __future__ import annotations


def _simple(body: str) -> tuple[list[tuple[str, str]], str]:
    return ([], body)


def _with_let(bindings: list[tuple[str, str]], body: str) -> tuple[list[tuple[str, str]], str]:
    return (bindings, body)


_MOD10_100 = [("mod10", "modBy 10 n"), ("mod100", "modBy 100 n")]
_MOD100 = [("mod100", "modBy 100 n")]

_ELM: dict[str, tuple[list[tuple[str, str]], str]] = {
    "other_only": _simple("Other"),
    "one_other": _simple("if n == 1 then One else Other"),
    "one_other_zero_one": _simple("if n == 0 || n == 1 then One else Other"),
    "cs_sk": _simple("if n == 1 then One else if n >= 2 && n <= 4 then Few else Other"),
    "lt": _with_let(_MOD10_100,
        "if mod10 == 1 && mod100 /= 11 then One else if mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19) then Few else Other"),
    "ro": _simple("if n == 1 then One else if n == 0 || (modBy 100 n >= 1 && modBy 100 n <= 19) then Few else Other"),
    "slavic_bcs": _with_let(_MOD10_100,
        "if mod10 == 1 && mod100 /= 11 then One else if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) then Few else Other"),
    "pl": _with_let(_MOD10_100,
        "if n == 1 then One else if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) then Few else Many"),
    "ru_uk": _with_let(_MOD10_100,
        "if mod10 == 1 && mod100 /= 11 then One else if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) then Few else Many"),
    "sl": _with_let(_MOD100,
        "if mod100 == 1 then One else if mod100 == 2 then Two else if mod100 == 3 || mod100 == 4 then Few else Other"),
    "ar": _with_let(_MOD100,
        "if n == 0 then Zero else if n == 1 then One else if n == 2 then Two else if mod100 >= 3 && mod100 <= 10 then Few else if mod100 >= 11 && mod100 <= 99 then Many else Other"),
    "lv": _with_let(_MOD10_100,
        "if mod10 == 0 || (mod100 >= 11 && mod100 <= 19) then Zero else if mod10 == 1 && mod100 /= 11 then One else Other"),
    "he": _simple("if n == 1 then One else if n == 2 then Two else Other"),
    "mk": _with_let(_MOD10_100,
        "if mod10 == 1 && mod100 /= 11 then One else Other"),
    "cy": _simple("if n == 0 then Zero else if n == 1 then One else if n == 2 then Two else if n == 3 then Few else if n == 6 then Many else Other"),
    "gv": _with_let(_MOD10_100,
        "if mod10 == 1 then One else if mod10 == 2 then Two else if mod100 == 0 || mod100 == 20 || mod100 == 40 || mod100 == 60 || mod100 == 80 then Few else Other"),
    "gd": _simple("if n == 1 || n == 11 then One else if n == 2 || n == 12 then Two else if (n >= 3 && n <= 10) || (n >= 13 && n <= 19) then Few else Other"),
    "ga": _simple("if n == 1 then One else if n == 2 then Two else if n >= 3 && n <= 6 then Few else if n >= 7 && n <= 10 then Many else Other"),
    "mt": _with_let(_MOD100,
        "if n == 1 then One else if n == 2 then Two else if n == 0 || (mod100 >= 3 && mod100 <= 10) then Few else if mod100 >= 11 && mod100 <= 19 then Many else Other"),
    "br": _with_let(_MOD10_100,
        "if mod10 == 1 && mod100 /= 11 && mod100 /= 71 && mod100 /= 91 then One else if mod10 == 2 && mod100 /= 12 && mod100 /= 72 && mod100 /= 92 then Two else if (mod10 == 3 || mod10 == 4 || mod10 == 9) && (mod100 < 10 || mod100 > 19) && (mod100 < 70 || mod100 > 79) && (mod100 < 90 || mod100 > 99) then Few else if n /= 0 && modBy 1000000 n == 0 then Many else Other"),
    "kw": _with_let(_MOD100,
        "if n == 0 then Zero else if n == 1 then One else if mod100 == 2 || mod100 == 22 || mod100 == 42 || mod100 == 62 || mod100 == 82 then Two else if mod100 == 3 || mod100 == 23 || mod100 == 43 || mod100 == 63 || mod100 == 83 then Few else if n /= 1 && (mod100 == 1 || mod100 == 21 || mod100 == 41 || mod100 == 61 || mod100 == 81) then Many else Other"),
    "shi": _simple("if n == 0 || n == 1 then One else if n >= 2 && n <= 10 then Few else Other"),
    "tzm": _simple("if n == 0 || n == 1 || (n >= 11 && n <= 99) then One else Other"),
}


def get_elm_plural(rule: str) -> tuple[list[tuple[str, str]], str]:
    """Return (bindings, body) for the given plural rule name."""
    return _ELM[rule]
