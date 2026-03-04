"""Go plural rule definitions for all 23 patterns."""

from __future__ import annotations

_GO = {
    "other_only": """\
\tfunc(_ int) sd.PluralCategory {
\t\treturn sd.Other
\t}""",
    "one_other": """\
\tfunc(n int) sd.PluralCategory {
\t\tif n == 1 {
\t\t\treturn sd.One
\t\t}
\t\treturn sd.Other
\t}""",
    "one_other_zero_one": """\
\tfunc(n int) sd.PluralCategory {
\t\tif n == 0 || n == 1 {
\t\t\treturn sd.One
\t\t}
\t\treturn sd.Other
\t}""",
    "cs_sk": """\
\tfunc(n int) sd.PluralCategory {
\t\tif n == 1 {
\t\t\treturn sd.One
\t\t}
\t\tif n >= 2 && n <= 4 {
\t\t\treturn sd.Few
\t\t}
\t\treturn sd.Other
\t}""",
    "lt": """\
\tfunc(n int) sd.PluralCategory {
\t\tmod10 := n % 10
\t\tmod100 := n % 100
\t\tif mod10 == 1 && mod100 != 11 {
\t\t\treturn sd.One
\t\t}
\t\tif mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19) {
\t\t\treturn sd.Few
\t\t}
\t\treturn sd.Other
\t}""",
    "ro": """\
\tfunc(n int) sd.PluralCategory {
\t\tif n == 1 {
\t\t\treturn sd.One
\t\t}
\t\tif n == 0 || (n%100 >= 1 && n%100 <= 19) {
\t\t\treturn sd.Few
\t\t}
\t\treturn sd.Other
\t}""",
    "slavic_bcs": """\
\tfunc(n int) sd.PluralCategory {
\t\tmod10 := n % 10
\t\tmod100 := n % 100
\t\tif mod10 == 1 && mod100 != 11 {
\t\t\treturn sd.One
\t\t}
\t\tif mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) {
\t\t\treturn sd.Few
\t\t}
\t\treturn sd.Other
\t}""",
    "pl": """\
\tfunc(n int) sd.PluralCategory {
\t\tif n == 1 {
\t\t\treturn sd.One
\t\t}
\t\tmod10 := n % 10
\t\tmod100 := n % 100
\t\tif mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) {
\t\t\treturn sd.Few
\t\t}
\t\treturn sd.Many
\t}""",
    "ru_uk": """\
\tfunc(n int) sd.PluralCategory {
\t\tmod10 := n % 10
\t\tmod100 := n % 100
\t\tif mod10 == 1 && mod100 != 11 {
\t\t\treturn sd.One
\t\t}
\t\tif mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) {
\t\t\treturn sd.Few
\t\t}
\t\treturn sd.Many
\t}""",
    "sl": """\
\tfunc(n int) sd.PluralCategory {
\t\tmod100 := n % 100
\t\tif mod100 == 1 {
\t\t\treturn sd.One
\t\t}
\t\tif mod100 == 2 {
\t\t\treturn sd.Two
\t\t}
\t\tif mod100 == 3 || mod100 == 4 {
\t\t\treturn sd.Few
\t\t}
\t\treturn sd.Other
\t}""",
    "ar": """\
\tfunc(n int) sd.PluralCategory {
\t\tif n == 0 {
\t\t\treturn sd.Zero
\t\t}
\t\tif n == 1 {
\t\t\treturn sd.One
\t\t}
\t\tif n == 2 {
\t\t\treturn sd.Two
\t\t}
\t\tmod100 := n % 100
\t\tif mod100 >= 3 && mod100 <= 10 {
\t\t\treturn sd.Few
\t\t}
\t\tif mod100 >= 11 && mod100 <= 99 {
\t\t\treturn sd.Many
\t\t}
\t\treturn sd.Other
\t}""",
    "lv": """\
\tfunc(n int) sd.PluralCategory {
\t\tmod10 := n % 10
\t\tmod100 := n % 100
\t\tif mod10 == 0 || (mod100 >= 11 && mod100 <= 19) {
\t\t\treturn sd.Zero
\t\t}
\t\tif mod10 == 1 && mod100 != 11 {
\t\t\treturn sd.One
\t\t}
\t\treturn sd.Other
\t}""",
    "he": """\
\tfunc(n int) sd.PluralCategory {
\t\tif n == 1 {
\t\t\treturn sd.One
\t\t}
\t\tif n == 2 {
\t\t\treturn sd.Two
\t\t}
\t\treturn sd.Other
\t}""",
    "mk": """\
\tfunc(n int) sd.PluralCategory {
\t\tmod10 := n % 10
\t\tmod100 := n % 100
\t\tif mod10 == 1 && mod100 != 11 {
\t\t\treturn sd.One
\t\t}
\t\treturn sd.Other
\t}""",
    "cy": """\
\tfunc(n int) sd.PluralCategory {
\t\tif n == 0 {
\t\t\treturn sd.Zero
\t\t}
\t\tif n == 1 {
\t\t\treturn sd.One
\t\t}
\t\tif n == 2 {
\t\t\treturn sd.Two
\t\t}
\t\tif n == 3 {
\t\t\treturn sd.Few
\t\t}
\t\tif n == 6 {
\t\t\treturn sd.Many
\t\t}
\t\treturn sd.Other
\t}""",
    "gv": """\
\tfunc(n int) sd.PluralCategory {
\t\tmod10 := n % 10
\t\tmod100 := n % 100
\t\tif mod10 == 1 {
\t\t\treturn sd.One
\t\t}
\t\tif mod10 == 2 {
\t\t\treturn sd.Two
\t\t}
\t\tif mod100 == 0 || mod100 == 20 || mod100 == 40 || mod100 == 60 || mod100 == 80 {
\t\t\treturn sd.Few
\t\t}
\t\treturn sd.Other
\t}""",
    "gd": """\
\tfunc(n int) sd.PluralCategory {
\t\tif n == 1 || n == 11 {
\t\t\treturn sd.One
\t\t}
\t\tif n == 2 || n == 12 {
\t\t\treturn sd.Two
\t\t}
\t\tif (n >= 3 && n <= 10) || (n >= 13 && n <= 19) {
\t\t\treturn sd.Few
\t\t}
\t\treturn sd.Other
\t}""",
    "ga": """\
\tfunc(n int) sd.PluralCategory {
\t\tif n == 1 {
\t\t\treturn sd.One
\t\t}
\t\tif n == 2 {
\t\t\treturn sd.Two
\t\t}
\t\tif n >= 3 && n <= 6 {
\t\t\treturn sd.Few
\t\t}
\t\tif n >= 7 && n <= 10 {
\t\t\treturn sd.Many
\t\t}
\t\treturn sd.Other
\t}""",
    "mt": """\
\tfunc(n int) sd.PluralCategory {
\t\tif n == 1 {
\t\t\treturn sd.One
\t\t}
\t\tif n == 2 {
\t\t\treturn sd.Two
\t\t}
\t\tmod100 := n % 100
\t\tif n == 0 || (mod100 >= 3 && mod100 <= 10) {
\t\t\treturn sd.Few
\t\t}
\t\tif mod100 >= 11 && mod100 <= 19 {
\t\t\treturn sd.Many
\t\t}
\t\treturn sd.Other
\t}""",
    "br": """\
\tfunc(n int) sd.PluralCategory {
\t\tmod10 := n % 10
\t\tmod100 := n % 100
\t\tif mod10 == 1 && mod100 != 11 && mod100 != 71 && mod100 != 91 {
\t\t\treturn sd.One
\t\t}
\t\tif mod10 == 2 && mod100 != 12 && mod100 != 72 && mod100 != 92 {
\t\t\treturn sd.Two
\t\t}
\t\tif (mod10 == 3 || mod10 == 4 || mod10 == 9) && (mod100 < 10 || mod100 > 19) && (mod100 < 70 || mod100 > 79) && (mod100 < 90 || mod100 > 99) {
\t\t\treturn sd.Few
\t\t}
\t\tif n != 0 && n%1000000 == 0 {
\t\t\treturn sd.Many
\t\t}
\t\treturn sd.Other
\t}""",
    "kw": """\
\tfunc(n int) sd.PluralCategory {
\t\tif n == 0 {
\t\t\treturn sd.Zero
\t\t}
\t\tif n == 1 {
\t\t\treturn sd.One
\t\t}
\t\tmod100 := n % 100
\t\tif mod100 == 2 || mod100 == 22 || mod100 == 42 || mod100 == 62 || mod100 == 82 {
\t\t\treturn sd.Two
\t\t}
\t\tif mod100 == 3 || mod100 == 23 || mod100 == 43 || mod100 == 63 || mod100 == 83 {
\t\t\treturn sd.Few
\t\t}
\t\tif n != 1 && (mod100 == 1 || mod100 == 21 || mod100 == 41 || mod100 == 61 || mod100 == 81) {
\t\t\treturn sd.Many
\t\t}
\t\treturn sd.Other
\t}""",
    "shi": """\
\tfunc(n int) sd.PluralCategory {
\t\tif n == 0 || n == 1 {
\t\t\treturn sd.One
\t\t}
\t\tif n >= 2 && n <= 10 {
\t\t\treturn sd.Few
\t\t}
\t\treturn sd.Other
\t}""",
    "tzm": """\
\tfunc(n int) sd.PluralCategory {
\t\tif n == 0 || n == 1 || (n >= 11 && n <= 99) {
\t\t\treturn sd.One
\t\t}
\t\treturn sd.Other
\t}""",
}


def get_go_plural(rule: str) -> str:
    return _GO[rule]
