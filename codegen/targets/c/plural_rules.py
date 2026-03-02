"""C plural rule definitions for all 23 CLDR cardinal patterns."""

from __future__ import annotations

_C = {
    "other_only": """\
    (void)n;
    return PT_OTHER;""",
    "one_other": """\
    if (n == 1) return PT_ONE;
    return PT_OTHER;""",
    "one_other_zero_one": """\
    if (n == 0 || n == 1) return PT_ONE;
    return PT_OTHER;""",
    "cs_sk": """\
    if (n == 1) return PT_ONE;
    if (n >= 2 && n <= 4) return PT_FEW;
    return PT_OTHER;""",
    "lt": """\
    int mod10 = n % 10;
    int mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return PT_ONE;
    if (mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19)) return PT_FEW;
    return PT_OTHER;""",
    "ro": """\
    if (n == 1) return PT_ONE;
    if (n == 0 || (n % 100 >= 1 && n % 100 <= 19)) return PT_FEW;
    return PT_OTHER;""",
    "slavic_bcs": """\
    int mod10 = n % 10;
    int mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return PT_ONE;
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PT_FEW;
    return PT_OTHER;""",
    "pl": """\
    if (n == 1) return PT_ONE;
    int mod10 = n % 10;
    int mod100 = n % 100;
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PT_FEW;
    return PT_MANY;""",
    "ru_uk": """\
    int mod10 = n % 10;
    int mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return PT_ONE;
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PT_FEW;
    return PT_MANY;""",
    "sl": """\
    int mod100 = n % 100;
    if (mod100 == 1) return PT_ONE;
    if (mod100 == 2) return PT_TWO;
    if (mod100 == 3 || mod100 == 4) return PT_FEW;
    return PT_OTHER;""",
    "ar": """\
    if (n == 0) return PT_ZERO;
    if (n == 1) return PT_ONE;
    if (n == 2) return PT_TWO;
    int mod100 = n % 100;
    if (mod100 >= 3 && mod100 <= 10) return PT_FEW;
    if (mod100 >= 11 && mod100 <= 99) return PT_MANY;
    return PT_OTHER;""",
    "lv": """\
    int mod10 = n % 10;
    int mod100 = n % 100;
    if (mod10 == 0 || (mod100 >= 11 && mod100 <= 19)) return PT_ZERO;
    if (mod10 == 1 && mod100 != 11) return PT_ONE;
    return PT_OTHER;""",
    "he": """\
    if (n == 1) return PT_ONE;
    if (n == 2) return PT_TWO;
    return PT_OTHER;""",
    "mk": """\
    int mod10 = n % 10;
    int mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return PT_ONE;
    return PT_OTHER;""",
    "cy": """\
    if (n == 0) return PT_ZERO;
    if (n == 1) return PT_ONE;
    if (n == 2) return PT_TWO;
    if (n == 3) return PT_FEW;
    if (n == 6) return PT_MANY;
    return PT_OTHER;""",
    "gv": """\
    int mod10 = n % 10;
    int mod100 = n % 100;
    if (mod10 == 1) return PT_ONE;
    if (mod10 == 2) return PT_TWO;
    if (mod100 == 0 || mod100 == 20 || mod100 == 40 || mod100 == 60 || mod100 == 80) return PT_FEW;
    return PT_OTHER;""",
    "gd": """\
    if (n == 1 || n == 11) return PT_ONE;
    if (n == 2 || n == 12) return PT_TWO;
    if ((n >= 3 && n <= 10) || (n >= 13 && n <= 19)) return PT_FEW;
    return PT_OTHER;""",
    "ga": """\
    if (n == 1) return PT_ONE;
    if (n == 2) return PT_TWO;
    if (n >= 3 && n <= 6) return PT_FEW;
    if (n >= 7 && n <= 10) return PT_MANY;
    return PT_OTHER;""",
    "mt": """\
    if (n == 1) return PT_ONE;
    if (n == 2) return PT_TWO;
    int mod100 = n % 100;
    if (n == 0 || (mod100 >= 3 && mod100 <= 10)) return PT_FEW;
    if (mod100 >= 11 && mod100 <= 19) return PT_MANY;
    return PT_OTHER;""",
    "br": """\
    int mod10 = n % 10;
    int mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11 && mod100 != 71 && mod100 != 91) return PT_ONE;
    if (mod10 == 2 && mod100 != 12 && mod100 != 72 && mod100 != 92) return PT_TWO;
    if ((mod10 == 3 || mod10 == 4 || mod10 == 9) && !(mod100 >= 10 && mod100 <= 19) && !(mod100 >= 70 && mod100 <= 79) && !(mod100 >= 90 && mod100 <= 99)) return PT_FEW;
    if (n != 0 && n % 1000000 == 0) return PT_MANY;
    return PT_OTHER;""",
    "kw": """\
    if (n == 0) return PT_ZERO;
    if (n == 1) return PT_ONE;
    int mod100 = n % 100;
    if (mod100 == 2 || mod100 == 22 || mod100 == 42 || mod100 == 62 || mod100 == 82) return PT_TWO;
    if (mod100 == 3 || mod100 == 23 || mod100 == 43 || mod100 == 63 || mod100 == 83) return PT_FEW;
    if (n != 1 && (mod100 == 1 || mod100 == 21 || mod100 == 41 || mod100 == 61 || mod100 == 81)) return PT_MANY;
    return PT_OTHER;""",
    "shi": """\
    if (n == 0 || n == 1) return PT_ONE;
    if (n >= 2 && n <= 10) return PT_FEW;
    return PT_OTHER;""",
    "tzm": """\
    if (n == 0 || n == 1 || (n >= 11 && n <= 99)) return PT_ONE;
    return PT_OTHER;""",
}


def get_c_plural(rule: str) -> str:
    return _C[rule]
