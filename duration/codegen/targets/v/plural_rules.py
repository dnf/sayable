"""V plural rule definitions for all 23 CLDR patterns.

Each rule returns a V function body string that maps an integer n
to the appropriate PluralCategory.
"""

from __future__ import annotations

_V = {
    "other_only": "fn (_ int) PluralCategory {\n\treturn .other\n}",
    "one_other": "fn (n int) PluralCategory {\n\tif n == 1 {\n\t\treturn .one\n\t}\n\treturn .other\n}",
    "one_other_zero_one": "fn (n int) PluralCategory {\n\tif n == 0 || n == 1 {\n\t\treturn .one\n\t}\n\treturn .other\n}",
    "cs_sk": """fn (n int) PluralCategory {
\tif n == 1 {
\t\treturn .one
\t}
\tif n >= 2 && n <= 4 {
\t\treturn .few
\t}
\treturn .other
}""",
    "lt": """fn (n int) PluralCategory {
\tmod10 := n % 10
\tmod100 := n % 100
\tif mod10 == 1 && mod100 != 11 {
\t\treturn .one
\t}
\tif mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19) {
\t\treturn .few
\t}
\treturn .other
}""",
    "ro": """fn (n int) PluralCategory {
\tif n == 1 {
\t\treturn .one
\t}
\tif n == 0 || (n % 100 >= 1 && n % 100 <= 19) {
\t\treturn .few
\t}
\treturn .other
}""",
    "slavic_bcs": """fn (n int) PluralCategory {
\tmod10 := n % 10
\tmod100 := n % 100
\tif mod10 == 1 && mod100 != 11 {
\t\treturn .one
\t}
\tif mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) {
\t\treturn .few
\t}
\treturn .other
}""",
    "pl": """fn (n int) PluralCategory {
\tif n == 1 {
\t\treturn .one
\t}
\tmod10 := n % 10
\tmod100 := n % 100
\tif mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) {
\t\treturn .few
\t}
\treturn .many
}""",
    "ru_uk": """fn (n int) PluralCategory {
\tmod10 := n % 10
\tmod100 := n % 100
\tif mod10 == 1 && mod100 != 11 {
\t\treturn .one
\t}
\tif mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) {
\t\treturn .few
\t}
\treturn .many
}""",
    "sl": """fn (n int) PluralCategory {
\tmod100 := n % 100
\tif mod100 == 1 {
\t\treturn .one
\t}
\tif mod100 == 2 {
\t\treturn .two
\t}
\tif mod100 == 3 || mod100 == 4 {
\t\treturn .few
\t}
\treturn .other
}""",
    "ar": """fn (n int) PluralCategory {
\tif n == 0 {
\t\treturn .zero
\t}
\tif n == 1 {
\t\treturn .one
\t}
\tif n == 2 {
\t\treturn .two
\t}
\tmod100 := n % 100
\tif mod100 >= 3 && mod100 <= 10 {
\t\treturn .few
\t}
\tif mod100 >= 11 && mod100 <= 99 {
\t\treturn .many
\t}
\treturn .other
}""",
    "lv": """fn (n int) PluralCategory {
\tmod10 := n % 10
\tmod100 := n % 100
\tif mod10 == 0 || (mod100 >= 11 && mod100 <= 19) {
\t\treturn .zero
\t}
\tif mod10 == 1 && mod100 != 11 {
\t\treturn .one
\t}
\treturn .other
}""",
    "he": """fn (n int) PluralCategory {
\tif n == 1 {
\t\treturn .one
\t}
\tif n == 2 {
\t\treturn .two
\t}
\treturn .other
}""",
    "mk": """fn (n int) PluralCategory {
\tmod10 := n % 10
\tmod100 := n % 100
\tif mod10 == 1 && mod100 != 11 {
\t\treturn .one
\t}
\treturn .other
}""",
    "cy": """fn (n int) PluralCategory {
\tif n == 0 {
\t\treturn .zero
\t}
\tif n == 1 {
\t\treturn .one
\t}
\tif n == 2 {
\t\treturn .two
\t}
\tif n == 3 {
\t\treturn .few
\t}
\tif n == 6 {
\t\treturn .many
\t}
\treturn .other
}""",
    "gv": """fn (n int) PluralCategory {
\tmod10 := n % 10
\tmod100 := n % 100
\tif mod10 == 1 {
\t\treturn .one
\t}
\tif mod10 == 2 {
\t\treturn .two
\t}
\tif mod100 == 0 || mod100 == 20 || mod100 == 40 || mod100 == 60 || mod100 == 80 {
\t\treturn .few
\t}
\treturn .other
}""",
    "gd": """fn (n int) PluralCategory {
\tif n == 1 || n == 11 {
\t\treturn .one
\t}
\tif n == 2 || n == 12 {
\t\treturn .two
\t}
\tif (n >= 3 && n <= 10) || (n >= 13 && n <= 19) {
\t\treturn .few
\t}
\treturn .other
}""",
    "ga": """fn (n int) PluralCategory {
\tif n == 1 {
\t\treturn .one
\t}
\tif n == 2 {
\t\treturn .two
\t}
\tif n >= 3 && n <= 6 {
\t\treturn .few
\t}
\tif n >= 7 && n <= 10 {
\t\treturn .many
\t}
\treturn .other
}""",
    "mt": """fn (n int) PluralCategory {
\tif n == 1 {
\t\treturn .one
\t}
\tif n == 2 {
\t\treturn .two
\t}
\tmod100 := n % 100
\tif n == 0 || (mod100 >= 3 && mod100 <= 10) {
\t\treturn .few
\t}
\tif mod100 >= 11 && mod100 <= 19 {
\t\treturn .many
\t}
\treturn .other
}""",
    "br": """fn (n int) PluralCategory {
\tmod10 := n % 10
\tmod100 := n % 100
\tif mod10 == 1 && mod100 != 11 && mod100 != 71 && mod100 != 91 {
\t\treturn .one
\t}
\tif mod10 == 2 && mod100 != 12 && mod100 != 72 && mod100 != 92 {
\t\treturn .two
\t}
\tif (mod10 == 3 || mod10 == 4 || mod10 == 9) && (mod100 < 10 || mod100 > 19) && (mod100 < 70 || mod100 > 79) && (mod100 < 90 || mod100 > 99) {
\t\treturn .few
\t}
\tif n != 0 && n % 1000000 == 0 {
\t\treturn .many
\t}
\treturn .other
}""",
    "kw": """fn (n int) PluralCategory {
\tif n == 0 {
\t\treturn .zero
\t}
\tif n == 1 {
\t\treturn .one
\t}
\tmod100 := n % 100
\tif mod100 == 2 || mod100 == 22 || mod100 == 42 || mod100 == 62 || mod100 == 82 {
\t\treturn .two
\t}
\tif mod100 == 3 || mod100 == 23 || mod100 == 43 || mod100 == 63 || mod100 == 83 {
\t\treturn .few
\t}
\tif n != 1 && (mod100 == 1 || mod100 == 21 || mod100 == 41 || mod100 == 61 || mod100 == 81) {
\t\treturn .many
\t}
\treturn .other
}""",
    "shi": """fn (n int) PluralCategory {
\tif n == 0 || n == 1 {
\t\treturn .one
\t}
\tif n >= 2 && n <= 10 {
\t\treturn .few
\t}
\treturn .other
}""",
    "tzm": """fn (n int) PluralCategory {
\tif n == 0 || n == 1 || (n >= 11 && n <= 99) {
\t\treturn .one
\t}
\treturn .other
}""",
}


def get_v_plural(rule: str) -> str:
    """Get V plural function body for the given rule name."""
    return _V[rule]
