"""Python plural rule definitions for all 14 patterns."""

from __future__ import annotations

_PY = {
    "other_only": 'lambda _n: "other"',
    "one_other": 'lambda n: "one" if n == 1 else "other"',
    "one_other_zero_one": 'lambda n: "one" if n in (0, 1) else "other"',
}

_PY_NAMED = {
    "cs_sk": '''\
def _plural(n: int) -> PluralCategory:
    if n == 1:
        return "one"
    if 2 <= n <= 4:
        return "few"
    return "other"''',
    "lt": '''\
def _plural(n: int) -> PluralCategory:
    mod10 = n % 10
    mod100 = n % 100
    if mod10 == 1 and mod100 != 11:
        return "one"
    if 2 <= mod10 <= 9 and (mod100 < 12 or mod100 > 19):
        return "few"
    return "other"''',
    "ro": '''\
def _plural(n: int) -> PluralCategory:
    if n == 1:
        return "one"
    if n == 0 or 1 <= n % 100 <= 19:
        return "few"
    return "other"''',
    "slavic_bcs": '''\
def _plural(n: int) -> PluralCategory:
    mod10 = n % 10
    mod100 = n % 100
    if mod10 == 1 and mod100 != 11:
        return "one"
    if 2 <= mod10 <= 4 and (mod100 < 12 or mod100 > 14):
        return "few"
    return "other"''',
    "pl": '''\
def _plural(n: int) -> PluralCategory:
    if n == 1:
        return "one"
    mod10 = n % 10
    mod100 = n % 100
    if 2 <= mod10 <= 4 and (mod100 < 12 or mod100 > 14):
        return "few"
    return "many"''',
    "ru_uk": '''\
def _plural(n: int) -> PluralCategory:
    mod10 = n % 10
    mod100 = n % 100
    if mod10 == 1 and mod100 != 11:
        return "one"
    if 2 <= mod10 <= 4 and (mod100 < 12 or mod100 > 14):
        return "few"
    return "many"''',
    "sl": '''\
def _plural(n: int) -> PluralCategory:
    mod100 = n % 100
    if mod100 == 1:
        return "one"
    if mod100 == 2:
        return "two"
    if mod100 in (3, 4):
        return "few"
    return "other"''',
    "ar": '''\
def _plural(n: int) -> PluralCategory:
    if n == 0:
        return "zero"
    if n == 1:
        return "one"
    if n == 2:
        return "two"
    mod100 = n % 100
    if 3 <= mod100 <= 10:
        return "few"
    if 11 <= mod100 <= 99:
        return "many"
    return "other"''',
    "lv": '''\
def _plural(n: int) -> PluralCategory:
    mod10 = n % 10
    mod100 = n % 100
    if mod10 == 0 or 11 <= mod100 <= 19:
        return "zero"
    if mod10 == 1 and mod100 != 11:
        return "one"
    return "other"''',
    "he": '''\
def _plural(n: int) -> PluralCategory:
    if n == 1:
        return "one"
    if n == 2:
        return "two"
    return "other"''',
    "mk": '''\
def _plural(n: int) -> PluralCategory:
    mod10 = n % 10
    mod100 = n % 100
    if mod10 == 1 and mod100 != 11:
        return "one"
    return "other"''',
}


def is_simple_plural(rule: str) -> bool:
    """True if this rule can be expressed as an inline lambda/closure."""
    return rule in ("other_only", "one_other", "one_other_zero_one")


def get_py_plural(rule: str) -> str:
    """Get Python plural expression (lambda or function reference)."""
    if rule in _PY:
        return _PY[rule]
    return "_plural"


def get_py_named_function(rule: str) -> str | None:
    """Get Python named function for complex rules."""
    return _PY_NAMED.get(rule)
