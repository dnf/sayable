"""Groovy plural rule definitions for all 23 patterns."""

from __future__ import annotations

_GROOVY = {
    "other_only": "{ int n -> PluralCategory.OTHER }",
    "one_other": "{ int n -> n == 1 ? PluralCategory.ONE : PluralCategory.OTHER }",
    "one_other_zero_one": "{ int n -> (n == 0 || n == 1) ? PluralCategory.ONE : PluralCategory.OTHER }",
    "cs_sk": """\
{ int n ->
            if (n == 1) return PluralCategory.ONE
            if (n >= 2 && n <= 4) return PluralCategory.FEW
            return PluralCategory.OTHER
        }""",
    "lt": """\
{ int n ->
            int mod10 = n % 10
            int mod100 = n % 100
            if (mod10 == 1 && mod100 != 11) return PluralCategory.ONE
            if (mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19)) return PluralCategory.FEW
            return PluralCategory.OTHER
        }""",
    "ro": """\
{ int n ->
            if (n == 1) return PluralCategory.ONE
            if (n == 0 || (n % 100 >= 1 && n % 100 <= 19)) return PluralCategory.FEW
            return PluralCategory.OTHER
        }""",
    "slavic_bcs": """\
{ int n ->
            int mod10 = n % 10
            int mod100 = n % 100
            if (mod10 == 1 && mod100 != 11) return PluralCategory.ONE
            if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory.FEW
            return PluralCategory.OTHER
        }""",
    "pl": """\
{ int n ->
            if (n == 1) return PluralCategory.ONE
            int mod10 = n % 10
            int mod100 = n % 100
            if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory.FEW
            return PluralCategory.MANY
        }""",
    "ru_uk": """\
{ int n ->
            int mod10 = n % 10
            int mod100 = n % 100
            if (mod10 == 1 && mod100 != 11) return PluralCategory.ONE
            if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory.FEW
            return PluralCategory.MANY
        }""",
    "sl": """\
{ int n ->
            int mod100 = n % 100
            if (mod100 == 1) return PluralCategory.ONE
            if (mod100 == 2) return PluralCategory.TWO
            if (mod100 == 3 || mod100 == 4) return PluralCategory.FEW
            return PluralCategory.OTHER
        }""",
    "ar": """\
{ int n ->
            if (n == 0) return PluralCategory.ZERO
            if (n == 1) return PluralCategory.ONE
            if (n == 2) return PluralCategory.TWO
            if (n % 100 >= 3 && n % 100 <= 10) return PluralCategory.FEW
            if (n % 100 >= 11 && n % 100 <= 99) return PluralCategory.MANY
            return PluralCategory.OTHER
        }""",
    "lv": """\
{ int n ->
            int mod10 = n % 10
            int mod100 = n % 100
            if (mod10 == 0 || (mod100 >= 11 && mod100 <= 19)) return PluralCategory.ZERO
            if (mod10 == 1 && mod100 != 11) return PluralCategory.ONE
            return PluralCategory.OTHER
        }""",
    "he": "{ int n -> n == 1 ? PluralCategory.ONE : n == 2 ? PluralCategory.TWO : PluralCategory.OTHER }",
    "mk": "{ int n -> (n % 10 == 1 && n % 100 != 11) ? PluralCategory.ONE : PluralCategory.OTHER }",
    "cy": """\
{ int n ->
            switch (n) {
                case 0: return PluralCategory.ZERO
                case 1: return PluralCategory.ONE
                case 2: return PluralCategory.TWO
                case 3: return PluralCategory.FEW
                case 6: return PluralCategory.MANY
                default: return PluralCategory.OTHER
            }
        }""",
    "gv": """\
{ int n ->
            int mod10 = n % 10
            int mod100 = n % 100
            if (mod10 == 1) return PluralCategory.ONE
            if (mod10 == 2) return PluralCategory.TWO
            if (mod100 == 0 || mod100 == 20 || mod100 == 40 || mod100 == 60 || mod100 == 80) return PluralCategory.FEW
            return PluralCategory.OTHER
        }""",
    "gd": """\
{ int n ->
            if (n == 1 || n == 11) return PluralCategory.ONE
            if (n == 2 || n == 12) return PluralCategory.TWO
            if ((n >= 3 && n <= 10) || (n >= 13 && n <= 19)) return PluralCategory.FEW
            return PluralCategory.OTHER
        }""",
    "ga": """\
{ int n ->
            if (n == 1) return PluralCategory.ONE
            if (n == 2) return PluralCategory.TWO
            if (n >= 3 && n <= 6) return PluralCategory.FEW
            if (n >= 7 && n <= 10) return PluralCategory.MANY
            return PluralCategory.OTHER
        }""",
    "mt": """\
{ int n ->
            if (n == 1) return PluralCategory.ONE
            if (n == 2) return PluralCategory.TWO
            if (n == 0 || (n % 100 >= 3 && n % 100 <= 10)) return PluralCategory.FEW
            if (n % 100 >= 11 && n % 100 <= 19) return PluralCategory.MANY
            return PluralCategory.OTHER
        }""",
    "br": """\
{ int n ->
            int mod10 = n % 10
            int mod100 = n % 100
            if (mod10 == 1 && mod100 != 11 && mod100 != 71 && mod100 != 91) return PluralCategory.ONE
            if (mod10 == 2 && mod100 != 12 && mod100 != 72 && mod100 != 92) return PluralCategory.TWO
            if ((mod10 == 3 || mod10 == 4 || mod10 == 9) && !(mod100 >= 10 && mod100 <= 19) && !(mod100 >= 70 && mod100 <= 79) && !(mod100 >= 90 && mod100 <= 99)) return PluralCategory.FEW
            if (n != 0 && n % 1000000 == 0) return PluralCategory.MANY
            return PluralCategory.OTHER
        }""",
    "kw": """\
{ int n ->
            if (n == 0) return PluralCategory.ZERO
            if (n == 1) return PluralCategory.ONE
            int mod100 = n % 100
            if (mod100 == 2 || mod100 == 22 || mod100 == 42 || mod100 == 62 || mod100 == 82) return PluralCategory.TWO
            if (mod100 == 3 || mod100 == 23 || mod100 == 43 || mod100 == 63 || mod100 == 83) return PluralCategory.FEW
            if (n != 1 && (mod100 == 1 || mod100 == 21 || mod100 == 41 || mod100 == 61 || mod100 == 81)) return PluralCategory.MANY
            return PluralCategory.OTHER
        }""",
    "shi": """\
{ int n ->
            if (n == 0 || n == 1) return PluralCategory.ONE
            if (n >= 2 && n <= 10) return PluralCategory.FEW
            return PluralCategory.OTHER
        }""",
    "tzm": """\
{ int n ->
            if (n == 0 || n == 1 || (n >= 11 && n <= 99)) return PluralCategory.ONE
            return PluralCategory.OTHER
        }""",
}


def get_groovy_plural(rule: str) -> str:
    """Return the Groovy closure expression for the given plural rule."""
    return _GROOVY[rule]
