"""Julia plural rule definitions for all 23 patterns.

All rules are emitted as anonymous functions to avoid name collisions
when multiple locale files are included into the same Julia module.
"""

from __future__ import annotations

_JL = {
    "other_only": '_ -> "other"',
    "one_other": 'n -> n == 1 ? "one" : "other"',
    "one_other_zero_one": 'n -> n in (0, 1) ? "one" : "other"',
    "cs_sk": """function(n)
        n == 1 && return "one"
        2 <= n <= 4 && return "few"
        return "other"
    end""",
    "lt": """function(n)
        mod10 = n % 10; mod100 = n % 100
        mod10 == 1 && mod100 != 11 && return "one"
        2 <= mod10 <= 9 && (mod100 < 12 || mod100 > 19) && return "few"
        return "other"
    end""",
    "ro": """function(n)
        n == 1 && return "one"
        (n == 0 || 1 <= n % 100 <= 19) && return "few"
        return "other"
    end""",
    "slavic_bcs": """function(n)
        mod10 = n % 10; mod100 = n % 100
        mod10 == 1 && mod100 != 11 && return "one"
        2 <= mod10 <= 4 && (mod100 < 12 || mod100 > 14) && return "few"
        return "other"
    end""",
    "pl": """function(n)
        n == 1 && return "one"
        mod10 = n % 10; mod100 = n % 100
        2 <= mod10 <= 4 && (mod100 < 12 || mod100 > 14) && return "few"
        return "many"
    end""",
    "ru_uk": """function(n)
        mod10 = n % 10; mod100 = n % 100
        mod10 == 1 && mod100 != 11 && return "one"
        2 <= mod10 <= 4 && (mod100 < 12 || mod100 > 14) && return "few"
        return "many"
    end""",
    "sl": """function(n)
        mod100 = n % 100
        mod100 == 1 && return "one"
        mod100 == 2 && return "two"
        mod100 in (3, 4) && return "few"
        return "other"
    end""",
    "ar": """function(n)
        n == 0 && return "zero"
        n == 1 && return "one"
        n == 2 && return "two"
        mod100 = n % 100
        3 <= mod100 <= 10 && return "few"
        11 <= mod100 <= 99 && return "many"
        return "other"
    end""",
    "lv": """function(n)
        mod10 = n % 10; mod100 = n % 100
        (mod10 == 0 || 11 <= mod100 <= 19) && return "zero"
        mod10 == 1 && mod100 != 11 && return "one"
        return "other"
    end""",
    "he": """function(n)
        n == 1 && return "one"
        n == 2 && return "two"
        return "other"
    end""",
    "mk": """function(n)
        mod10 = n % 10; mod100 = n % 100
        mod10 == 1 && mod100 != 11 && return "one"
        return "other"
    end""",
    "cy": """function(n)
        n == 0 && return "zero"
        n == 1 && return "one"
        n == 2 && return "two"
        n == 3 && return "few"
        n == 6 && return "many"
        return "other"
    end""",
    "gv": """function(n)
        mod10 = n % 10; mod100 = n % 100
        mod10 == 1 && return "one"
        mod10 == 2 && return "two"
        mod100 in (0, 20, 40, 60, 80) && return "few"
        return "other"
    end""",
    "gd": """function(n)
        n in (1, 11) && return "one"
        n in (2, 12) && return "two"
        (3 <= n <= 10 || 13 <= n <= 19) && return "few"
        return "other"
    end""",
    "ga": """function(n)
        n == 1 && return "one"
        n == 2 && return "two"
        3 <= n <= 6 && return "few"
        7 <= n <= 10 && return "many"
        return "other"
    end""",
    "mt": """function(n)
        n == 1 && return "one"
        n == 2 && return "two"
        mod100 = n % 100
        (n == 0 || 3 <= mod100 <= 10) && return "few"
        11 <= mod100 <= 19 && return "many"
        return "other"
    end""",
    "br": """function(n)
        mod10 = n % 10; mod100 = n % 100
        mod10 == 1 && mod100 ∉ (11, 71, 91) && return "one"
        mod10 == 2 && mod100 ∉ (12, 72, 92) && return "two"
        mod10 in (3, 4, 9) && !(10 <= mod100 <= 19) && !(70 <= mod100 <= 79) && !(90 <= mod100 <= 99) && return "few"
        n != 0 && n % 1000000 == 0 && return "many"
        return "other"
    end""",
    "kw": """function(n)
        n == 0 && return "zero"
        n == 1 && return "one"
        mod100 = n % 100
        mod100 in (2, 22, 42, 62, 82) && return "two"
        mod100 in (3, 23, 43, 63, 83) && return "few"
        n != 1 && mod100 in (1, 21, 41, 61, 81) && return "many"
        return "other"
    end""",
    "shi": """function(n)
        n in (0, 1) && return "one"
        2 <= n <= 10 && return "few"
        return "other"
    end""",
    "tzm": """function(n)
        (n in (0, 1) || 11 <= n <= 99) && return "one"
        return "other"
    end""",
}


def get_jl_plural(rule: str) -> str:
    """Get Julia plural expression (always an anonymous function)."""
    return _JL[rule]
