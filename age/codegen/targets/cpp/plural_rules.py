"""C++ plural rule definitions for all 23 patterns."""

from __future__ import annotations

_CPP = {
    "other_only": """\
[](int) -> PluralCategory {
            return PluralCategory::Other;
        }""",
    "one_other": """\
[](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        }""",
    "one_other_zero_one": """\
[](int n) -> PluralCategory {
            if (n == 0 || n == 1) return PluralCategory::One;
            return PluralCategory::Other;
        }""",
    "cs_sk": """\
[](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            if (n >= 2 && n <= 4) return PluralCategory::Few;
            return PluralCategory::Other;
        }""",
    "lt": """\
[](int n) -> PluralCategory {
            int mod10 = n % 10;
            int mod100 = n % 100;
            if (mod10 == 1 && mod100 != 11) return PluralCategory::One;
            if (mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19)) return PluralCategory::Few;
            return PluralCategory::Other;
        }""",
    "ro": """\
[](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            if (n == 0 || (n % 100 >= 1 && n % 100 <= 19)) return PluralCategory::Few;
            return PluralCategory::Other;
        }""",
    "slavic_bcs": """\
[](int n) -> PluralCategory {
            int mod10 = n % 10;
            int mod100 = n % 100;
            if (mod10 == 1 && mod100 != 11) return PluralCategory::One;
            if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory::Few;
            return PluralCategory::Other;
        }""",
    "pl": """\
[](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            int mod10 = n % 10;
            int mod100 = n % 100;
            if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory::Few;
            return PluralCategory::Many;
        }""",
    "ru_uk": """\
[](int n) -> PluralCategory {
            int mod10 = n % 10;
            int mod100 = n % 100;
            if (mod10 == 1 && mod100 != 11) return PluralCategory::One;
            if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory::Few;
            return PluralCategory::Many;
        }""",
    "sl": """\
[](int n) -> PluralCategory {
            int mod100 = n % 100;
            if (mod100 == 1) return PluralCategory::One;
            if (mod100 == 2) return PluralCategory::Two;
            if (mod100 == 3 || mod100 == 4) return PluralCategory::Few;
            return PluralCategory::Other;
        }""",
    "ar": """\
[](int n) -> PluralCategory {
            if (n == 0) return PluralCategory::Zero;
            if (n == 1) return PluralCategory::One;
            if (n == 2) return PluralCategory::Two;
            int mod100 = n % 100;
            if (mod100 >= 3 && mod100 <= 10) return PluralCategory::Few;
            if (mod100 >= 11 && mod100 <= 99) return PluralCategory::Many;
            return PluralCategory::Other;
        }""",
    "lv": """\
[](int n) -> PluralCategory {
            int mod10 = n % 10;
            int mod100 = n % 100;
            if (mod10 == 0 || (mod100 >= 11 && mod100 <= 19)) return PluralCategory::Zero;
            if (mod10 == 1 && mod100 != 11) return PluralCategory::One;
            return PluralCategory::Other;
        }""",
    "he": """\
[](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            if (n == 2) return PluralCategory::Two;
            return PluralCategory::Other;
        }""",
    "mk": """\
[](int n) -> PluralCategory {
            int mod10 = n % 10;
            int mod100 = n % 100;
            if (mod10 == 1 && mod100 != 11) return PluralCategory::One;
            return PluralCategory::Other;
        }""",
    "cy": """\
[](int n) -> PluralCategory {
            if (n == 0) return PluralCategory::Zero;
            if (n == 1) return PluralCategory::One;
            if (n == 2) return PluralCategory::Two;
            if (n == 3) return PluralCategory::Few;
            if (n == 6) return PluralCategory::Many;
            return PluralCategory::Other;
        }""",
    "gv": """\
[](int n) -> PluralCategory {
            int mod10 = n % 10;
            int mod100 = n % 100;
            if (mod10 == 1) return PluralCategory::One;
            if (mod10 == 2) return PluralCategory::Two;
            if (mod100 == 0 || mod100 == 20 || mod100 == 40 || mod100 == 60 || mod100 == 80) return PluralCategory::Few;
            return PluralCategory::Other;
        }""",
    "gd": """\
[](int n) -> PluralCategory {
            if (n == 1 || n == 11) return PluralCategory::One;
            if (n == 2 || n == 12) return PluralCategory::Two;
            if ((n >= 3 && n <= 10) || (n >= 13 && n <= 19)) return PluralCategory::Few;
            return PluralCategory::Other;
        }""",
    "ga": """\
[](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            if (n == 2) return PluralCategory::Two;
            if (n >= 3 && n <= 6) return PluralCategory::Few;
            if (n >= 7 && n <= 10) return PluralCategory::Many;
            return PluralCategory::Other;
        }""",
    "mt": """\
[](int n) -> PluralCategory {
            if (n == 1) return PluralCategory::One;
            if (n == 2) return PluralCategory::Two;
            int mod100 = n % 100;
            if (n == 0 || (mod100 >= 3 && mod100 <= 10)) return PluralCategory::Few;
            if (mod100 >= 11 && mod100 <= 19) return PluralCategory::Many;
            return PluralCategory::Other;
        }""",
    "br": """\
[](int n) -> PluralCategory {
            int mod10 = n % 10;
            int mod100 = n % 100;
            if (mod10 == 1 && mod100 != 11 && mod100 != 71 && mod100 != 91) return PluralCategory::One;
            if (mod10 == 2 && mod100 != 12 && mod100 != 72 && mod100 != 92) return PluralCategory::Two;
            if ((mod10 == 3 || mod10 == 4 || mod10 == 9) && !(mod100 >= 10 && mod100 <= 19) && !(mod100 >= 70 && mod100 <= 79) && !(mod100 >= 90 && mod100 <= 99)) return PluralCategory::Few;
            if (n != 0 && n % 1000000 == 0) return PluralCategory::Many;
            return PluralCategory::Other;
        }""",
    "kw": """\
[](int n) -> PluralCategory {
            if (n == 0) return PluralCategory::Zero;
            if (n == 1) return PluralCategory::One;
            int mod100 = n % 100;
            if (mod100 == 2 || mod100 == 22 || mod100 == 42 || mod100 == 62 || mod100 == 82) return PluralCategory::Two;
            if (mod100 == 3 || mod100 == 23 || mod100 == 43 || mod100 == 63 || mod100 == 83) return PluralCategory::Few;
            if (n != 1 && (mod100 == 1 || mod100 == 21 || mod100 == 41 || mod100 == 61 || mod100 == 81)) return PluralCategory::Many;
            return PluralCategory::Other;
        }""",
    "shi": """\
[](int n) -> PluralCategory {
            if (n == 0 || n == 1) return PluralCategory::One;
            if (n >= 2 && n <= 10) return PluralCategory::Few;
            return PluralCategory::Other;
        }""",
    "tzm": """\
[](int n) -> PluralCategory {
            if (n == 0 || n == 1 || (n >= 11 && n <= 99)) return PluralCategory::One;
            return PluralCategory::Other;
        }""",
}


def get_cpp_plural(rule: str) -> str:
    return _CPP[rule]
