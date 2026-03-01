"""Go plural rule definitions for all 14 patterns."""

from __future__ import annotations

_GO = {
    "other_only": """\
\tfunc(_ int) PluralCategory {
\t\treturn Other
\t}""",
    "one_other": """\
\tfunc(n int) PluralCategory {
\t\tif n == 1 {
\t\t\treturn One
\t\t}
\t\treturn Other
\t}""",
    "one_other_zero_one": """\
\tfunc(n int) PluralCategory {
\t\tif n == 0 || n == 1 {
\t\t\treturn One
\t\t}
\t\treturn Other
\t}""",
    "cs_sk": """\
\tfunc(n int) PluralCategory {
\t\tif n == 1 {
\t\t\treturn One
\t\t}
\t\tif n >= 2 && n <= 4 {
\t\t\treturn Few
\t\t}
\t\treturn Other
\t}""",
    "lt": """\
\tfunc(n int) PluralCategory {
\t\tmod10 := n % 10
\t\tmod100 := n % 100
\t\tif mod10 == 1 && mod100 != 11 {
\t\t\treturn One
\t\t}
\t\tif mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19) {
\t\t\treturn Few
\t\t}
\t\treturn Other
\t}""",
    "ro": """\
\tfunc(n int) PluralCategory {
\t\tif n == 1 {
\t\t\treturn One
\t\t}
\t\tif n == 0 || (n%100 >= 1 && n%100 <= 19) {
\t\t\treturn Few
\t\t}
\t\treturn Other
\t}""",
    "slavic_bcs": """\
\tfunc(n int) PluralCategory {
\t\tmod10 := n % 10
\t\tmod100 := n % 100
\t\tif mod10 == 1 && mod100 != 11 {
\t\t\treturn One
\t\t}
\t\tif mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) {
\t\t\treturn Few
\t\t}
\t\treturn Other
\t}""",
    "pl": """\
\tfunc(n int) PluralCategory {
\t\tif n == 1 {
\t\t\treturn One
\t\t}
\t\tmod10 := n % 10
\t\tmod100 := n % 100
\t\tif mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) {
\t\t\treturn Few
\t\t}
\t\treturn Many
\t}""",
    "ru_uk": """\
\tfunc(n int) PluralCategory {
\t\tmod10 := n % 10
\t\tmod100 := n % 100
\t\tif mod10 == 1 && mod100 != 11 {
\t\t\treturn One
\t\t}
\t\tif mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) {
\t\t\treturn Few
\t\t}
\t\treturn Many
\t}""",
    "sl": """\
\tfunc(n int) PluralCategory {
\t\tmod100 := n % 100
\t\tif mod100 == 1 {
\t\t\treturn One
\t\t}
\t\tif mod100 == 2 {
\t\t\treturn Two
\t\t}
\t\tif mod100 == 3 || mod100 == 4 {
\t\t\treturn Few
\t\t}
\t\treturn Other
\t}""",
    "ar": """\
\tfunc(n int) PluralCategory {
\t\tif n == 0 {
\t\t\treturn Zero
\t\t}
\t\tif n == 1 {
\t\t\treturn One
\t\t}
\t\tif n == 2 {
\t\t\treturn Two
\t\t}
\t\tmod100 := n % 100
\t\tif mod100 >= 3 && mod100 <= 10 {
\t\t\treturn Few
\t\t}
\t\tif mod100 >= 11 && mod100 <= 99 {
\t\t\treturn Many
\t\t}
\t\treturn Other
\t}""",
    "lv": """\
\tfunc(n int) PluralCategory {
\t\tmod10 := n % 10
\t\tmod100 := n % 100
\t\tif mod10 == 0 || (mod100 >= 11 && mod100 <= 19) {
\t\t\treturn Zero
\t\t}
\t\tif mod10 == 1 && mod100 != 11 {
\t\t\treturn One
\t\t}
\t\treturn Other
\t}""",
    "he": """\
\tfunc(n int) PluralCategory {
\t\tif n == 1 {
\t\t\treturn One
\t\t}
\t\tif n == 2 {
\t\t\treturn Two
\t\t}
\t\treturn Other
\t}""",
    "mk": """\
\tfunc(n int) PluralCategory {
\t\tmod10 := n % 10
\t\tmod100 := n % 100
\t\tif mod10 == 1 && mod100 != 11 {
\t\t\treturn One
\t\t}
\t\treturn Other
\t}""",
}


def get_go_plural(rule: str) -> str:
    return _GO[rule]
