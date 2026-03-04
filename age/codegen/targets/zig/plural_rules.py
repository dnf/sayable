"""Zig plural rule definitions for all 23 CLDR cardinal patterns."""

from __future__ import annotations

_ZIG = {
    "other_only": """\
        _ = n;
        return .other;""",
    "one_other": """\
        if (n == 1) return .one;
        return .other;""",
    "one_other_zero_one": """\
        if (n == 0 or n == 1) return .one;
        return .other;""",
    "cs_sk": """\
        if (n == 1) return .one;
        if (n >= 2 and n <= 4) return .few;
        return .other;""",
    "lt": """\
        const mod10 = @mod(n, 10);
        const mod100 = @mod(n, 100);
        if (mod10 == 1 and mod100 != 11) return .one;
        if (mod10 >= 2 and mod10 <= 9 and (mod100 < 12 or mod100 > 19)) return .few;
        return .other;""",
    "ro": """\
        if (n == 1) return .one;
        if (n == 0 or (@mod(n, 100) >= 1 and @mod(n, 100) <= 19)) return .few;
        return .other;""",
    "slavic_bcs": """\
        const mod10 = @mod(n, 10);
        const mod100 = @mod(n, 100);
        if (mod10 == 1 and mod100 != 11) return .one;
        if (mod10 >= 2 and mod10 <= 4 and (mod100 < 12 or mod100 > 14)) return .few;
        return .other;""",
    "pl": """\
        if (n == 1) return .one;
        const mod10 = @mod(n, 10);
        const mod100 = @mod(n, 100);
        if (mod10 >= 2 and mod10 <= 4 and (mod100 < 12 or mod100 > 14)) return .few;
        return .many;""",
    "ru_uk": """\
        const mod10 = @mod(n, 10);
        const mod100 = @mod(n, 100);
        if (mod10 == 1 and mod100 != 11) return .one;
        if (mod10 >= 2 and mod10 <= 4 and (mod100 < 12 or mod100 > 14)) return .few;
        return .many;""",
    "sl": """\
        const mod100 = @mod(n, 100);
        if (mod100 == 1) return .one;
        if (mod100 == 2) return .two;
        if (mod100 == 3 or mod100 == 4) return .few;
        return .other;""",
    "ar": """\
        if (n == 0) return .zero;
        if (n == 1) return .one;
        if (n == 2) return .two;
        const mod100 = @mod(n, 100);
        if (mod100 >= 3 and mod100 <= 10) return .few;
        if (mod100 >= 11 and mod100 <= 99) return .many;
        return .other;""",
    "lv": """\
        const mod10 = @mod(n, 10);
        const mod100 = @mod(n, 100);
        if (mod10 == 0 or (mod100 >= 11 and mod100 <= 19)) return .zero;
        if (mod10 == 1 and mod100 != 11) return .one;
        return .other;""",
    "he": """\
        if (n == 1) return .one;
        if (n == 2) return .two;
        return .other;""",
    "mk": """\
        const mod10 = @mod(n, 10);
        const mod100 = @mod(n, 100);
        if (mod10 == 1 and mod100 != 11) return .one;
        return .other;""",
    "cy": """\
        if (n == 0) return .zero;
        if (n == 1) return .one;
        if (n == 2) return .two;
        if (n == 3) return .few;
        if (n == 6) return .many;
        return .other;""",
    "gv": """\
        const mod10 = @mod(n, 10);
        const mod100 = @mod(n, 100);
        if (mod10 == 1) return .one;
        if (mod10 == 2) return .two;
        if (mod100 == 0 or mod100 == 20 or mod100 == 40 or mod100 == 60 or mod100 == 80) return .few;
        return .other;""",
    "gd": """\
        if (n == 1 or n == 11) return .one;
        if (n == 2 or n == 12) return .two;
        if ((n >= 3 and n <= 10) or (n >= 13 and n <= 19)) return .few;
        return .other;""",
    "ga": """\
        if (n == 1) return .one;
        if (n == 2) return .two;
        if (n >= 3 and n <= 6) return .few;
        if (n >= 7 and n <= 10) return .many;
        return .other;""",
    "mt": """\
        if (n == 1) return .one;
        if (n == 2) return .two;
        const mod100 = @mod(n, 100);
        if (n == 0 or (mod100 >= 3 and mod100 <= 10)) return .few;
        if (mod100 >= 11 and mod100 <= 19) return .many;
        return .other;""",
    "br": """\
        const mod10 = @mod(n, 10);
        const mod100 = @mod(n, 100);
        if (mod10 == 1 and mod100 != 11 and mod100 != 71 and mod100 != 91) return .one;
        if (mod10 == 2 and mod100 != 12 and mod100 != 72 and mod100 != 92) return .two;
        if ((mod10 == 3 or mod10 == 4 or mod10 == 9) and !(mod100 >= 10 and mod100 <= 19) and !(mod100 >= 70 and mod100 <= 79) and !(mod100 >= 90 and mod100 <= 99)) return .few;
        if (n != 0 and @mod(n, 1000000) == 0) return .many;
        return .other;""",
    "kw": """\
        if (n == 0) return .zero;
        if (n == 1) return .one;
        const mod100 = @mod(n, 100);
        if (mod100 == 2 or mod100 == 22 or mod100 == 42 or mod100 == 62 or mod100 == 82) return .two;
        if (mod100 == 3 or mod100 == 23 or mod100 == 43 or mod100 == 63 or mod100 == 83) return .few;
        if (n != 1 and (mod100 == 1 or mod100 == 21 or mod100 == 41 or mod100 == 61 or mod100 == 81)) return .many;
        return .other;""",
    "shi": """\
        if (n == 0 or n == 1) return .one;
        if (n >= 2 and n <= 10) return .few;
        return .other;""",
    "tzm": """\
        if (n == 0 or n == 1 or (n >= 11 and n <= 99)) return .one;
        return .other;""",
}


def get_zig_plural(rule: str) -> str:
    return _ZIG[rule]
