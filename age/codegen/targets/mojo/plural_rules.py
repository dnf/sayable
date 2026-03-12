"""Mojo plural rule definitions for all 23 patterns."""

from __future__ import annotations

_MOJO_INLINE = {
    "other_only": 'lambda n: "other"',
    "one_other": 'lambda n: "one" if n == 1 else "other"',
    "one_other_zero_one": 'lambda n: "one" if n in (0, 1) else "other"',
}

_MOJO_NAMED = {
    "cs_sk": '''\
fn _plural(n: Int) -> String:
    if n == 1:
        return "one"
    if 2 <= n <= 4:
        return "few"
    return "other"''',
    "lt": '''\
fn _plural(n: Int) -> String:
    var mod10 = n % 10
    var mod100 = n % 100
    if mod10 == 1 and mod100 != 11:
        return "one"
    if 2 <= mod10 <= 9 and (mod100 < 12 or mod100 > 19):
        return "few"
    return "other"''',
    "ro": '''\
fn _plural(n: Int) -> String:
    if n == 1:
        return "one"
    if n == 0 or 1 <= n % 100 <= 19:
        return "few"
    return "other"''',
    "slavic_bcs": '''\
fn _plural(n: Int) -> String:
    var mod10 = n % 10
    var mod100 = n % 100
    if mod10 == 1 and mod100 != 11:
        return "one"
    if 2 <= mod10 <= 4 and (mod100 < 12 or mod100 > 14):
        return "few"
    return "other"''',
    "pl": '''\
fn _plural(n: Int) -> String:
    if n == 1:
        return "one"
    var mod10 = n % 10
    var mod100 = n % 100
    if 2 <= mod10 <= 4 and (mod100 < 12 or mod100 > 14):
        return "few"
    return "many"''',
    "ru_uk": '''\
fn _plural(n: Int) -> String:
    var mod10 = n % 10
    var mod100 = n % 100
    if mod10 == 1 and mod100 != 11:
        return "one"
    if 2 <= mod10 <= 4 and (mod100 < 12 or mod100 > 14):
        return "few"
    return "many"''',
    "sl": '''\
fn _plural(n: Int) -> String:
    var mod100 = n % 100
    if mod100 == 1:
        return "one"
    if mod100 == 2:
        return "two"
    if mod100 == 3 or mod100 == 4:
        return "few"
    return "other"''',
    "ar": '''\
fn _plural(n: Int) -> String:
    if n == 0:
        return "zero"
    if n == 1:
        return "one"
    if n == 2:
        return "two"
    var mod100 = n % 100
    if 3 <= mod100 <= 10:
        return "few"
    if 11 <= mod100 <= 99:
        return "many"
    return "other"''',
    "lv": '''\
fn _plural(n: Int) -> String:
    var mod10 = n % 10
    var mod100 = n % 100
    if mod10 == 0 or 11 <= mod100 <= 19:
        return "zero"
    if mod10 == 1 and mod100 != 11:
        return "one"
    return "other"''',
    "he": '''\
fn _plural(n: Int) -> String:
    if n == 1:
        return "one"
    if n == 2:
        return "two"
    return "other"''',
    "mk": '''\
fn _plural(n: Int) -> String:
    var mod10 = n % 10
    var mod100 = n % 100
    if mod10 == 1 and mod100 != 11:
        return "one"
    return "other"''',
    "cy": '''\
fn _plural(n: Int) -> String:
    if n == 0:
        return "zero"
    if n == 1:
        return "one"
    if n == 2:
        return "two"
    if n == 3:
        return "few"
    if n == 6:
        return "many"
    return "other"''',
    "gv": '''\
fn _plural(n: Int) -> String:
    var mod10 = n % 10
    var mod100 = n % 100
    if mod10 == 1:
        return "one"
    if mod10 == 2:
        return "two"
    if mod100 == 0 or mod100 == 20 or mod100 == 40 or mod100 == 60 or mod100 == 80:
        return "few"
    return "other"''',
    "gd": '''\
fn _plural(n: Int) -> String:
    if n == 1 or n == 11:
        return "one"
    if n == 2 or n == 12:
        return "two"
    if (3 <= n <= 10) or (13 <= n <= 19):
        return "few"
    return "other"''',
    "ga": '''\
fn _plural(n: Int) -> String:
    if n == 1:
        return "one"
    if n == 2:
        return "two"
    if 3 <= n <= 6:
        return "few"
    if 7 <= n <= 10:
        return "many"
    return "other"''',
    "mt": '''\
fn _plural(n: Int) -> String:
    if n == 1:
        return "one"
    if n == 2:
        return "two"
    var mod100 = n % 100
    if n == 0 or 3 <= mod100 <= 10:
        return "few"
    if 11 <= mod100 <= 19:
        return "many"
    return "other"''',
    "br": '''\
fn _plural(n: Int) -> String:
    var mod10 = n % 10
    var mod100 = n % 100
    if mod10 == 1 and mod100 != 11 and mod100 != 71 and mod100 != 91:
        return "one"
    if mod10 == 2 and mod100 != 12 and mod100 != 72 and mod100 != 92:
        return "two"
    if (mod10 == 3 or mod10 == 4 or mod10 == 9) and not (10 <= mod100 <= 19) and not (70 <= mod100 <= 79) and not (90 <= mod100 <= 99):
        return "few"
    if n != 0 and n % 1000000 == 0:
        return "many"
    return "other"''',
    "kw": '''\
fn _plural(n: Int) -> String:
    if n == 0:
        return "zero"
    if n == 1:
        return "one"
    var mod100 = n % 100
    if mod100 == 2 or mod100 == 22 or mod100 == 42 or mod100 == 62 or mod100 == 82:
        return "two"
    if mod100 == 3 or mod100 == 23 or mod100 == 43 or mod100 == 63 or mod100 == 83:
        return "few"
    if n != 1 and (mod100 == 1 or mod100 == 21 or mod100 == 41 or mod100 == 61 or mod100 == 81):
        return "many"
    return "other"''',
    "shi": '''\
fn _plural(n: Int) -> String:
    if n == 0 or n == 1:
        return "one"
    if 2 <= n <= 10:
        return "few"
    return "other"''',
    "tzm": '''\
fn _plural(n: Int) -> String:
    if n == 0 or n == 1 or 11 <= n <= 99:
        return "one"
    return "other"''',
}


def is_simple_plural(rule: str) -> bool:
    """True if this rule can be expressed as an inline lambda."""
    return rule in ("other_only", "one_other", "one_other_zero_one")


def get_mojo_plural(rule: str) -> str:
    """Get Mojo plural expression (inline or function reference)."""
    if rule in _MOJO_INLINE:
        return _MOJO_INLINE[rule]
    return "_plural"


def get_mojo_named_function(rule: str) -> str | None:
    """Get Mojo named function for complex rules."""
    return _MOJO_NAMED.get(rule)
