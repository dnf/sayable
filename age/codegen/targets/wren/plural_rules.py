"""Wren plural rule definitions for all 23 patterns."""

from __future__ import annotations

_WREN = {
    "other_only": 'Fn.new {|n| "other" }',
    "one_other": 'Fn.new {|n| n == 1 ? "one" : "other" }',
    "one_other_zero_one": 'Fn.new {|n| (n == 0 || n == 1) ? "one" : "other" }',
}

_WREN_NAMED = {
    "cs_sk": '''\
class Plural {
  static call(n) {
    if (n == 1) return "one"
    if (n >= 2 && n <= 4) return "few"
    return "other"
  }
}''',
    "lt": '''\
class Plural {
  static call(n) {
    var mod10 = n % 10
    var mod100 = n % 100
    if (mod10 == 1 && mod100 != 11) return "one"
    if (mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19)) return "few"
    return "other"
  }
}''',
    "ro": '''\
class Plural {
  static call(n) {
    if (n == 1) return "one"
    if (n == 0 || (n % 100 >= 1 && n % 100 <= 19)) return "few"
    return "other"
  }
}''',
    "slavic_bcs": '''\
class Plural {
  static call(n) {
    var mod10 = n % 10
    var mod100 = n % 100
    if (mod10 == 1 && mod100 != 11) return "one"
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return "few"
    return "other"
  }
}''',
    "pl": '''\
class Plural {
  static call(n) {
    if (n == 1) return "one"
    var mod10 = n % 10
    var mod100 = n % 100
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return "few"
    return "many"
  }
}''',
    "ru_uk": '''\
class Plural {
  static call(n) {
    var mod10 = n % 10
    var mod100 = n % 100
    if (mod10 == 1 && mod100 != 11) return "one"
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return "few"
    return "many"
  }
}''',
    "sl": '''\
class Plural {
  static call(n) {
    var mod100 = n % 100
    if (mod100 == 1) return "one"
    if (mod100 == 2) return "two"
    if (mod100 == 3 || mod100 == 4) return "few"
    return "other"
  }
}''',
    "ar": '''\
class Plural {
  static call(n) {
    if (n == 0) return "zero"
    if (n == 1) return "one"
    if (n == 2) return "two"
    var mod100 = n % 100
    if (mod100 >= 3 && mod100 <= 10) return "few"
    if (mod100 >= 11 && mod100 <= 99) return "many"
    return "other"
  }
}''',
    "lv": '''\
class Plural {
  static call(n) {
    var mod10 = n % 10
    var mod100 = n % 100
    if (mod10 == 0 || (mod100 >= 11 && mod100 <= 19)) return "zero"
    if (mod10 == 1 && mod100 != 11) return "one"
    return "other"
  }
}''',
    "he": '''\
class Plural {
  static call(n) {
    if (n == 1) return "one"
    if (n == 2) return "two"
    return "other"
  }
}''',
    "mk": '''\
class Plural {
  static call(n) {
    var mod10 = n % 10
    var mod100 = n % 100
    if (mod10 == 1 && mod100 != 11) return "one"
    return "other"
  }
}''',
    "cy": '''\
class Plural {
  static call(n) {
    if (n == 0) return "zero"
    if (n == 1) return "one"
    if (n == 2) return "two"
    if (n == 3) return "few"
    if (n == 6) return "many"
    return "other"
  }
}''',
    "gv": '''\
class Plural {
  static call(n) {
    var mod10 = n % 10
    var mod100 = n % 100
    if (mod10 == 1) return "one"
    if (mod10 == 2) return "two"
    if (mod100 == 0 || mod100 == 20 || mod100 == 40 || mod100 == 60 || mod100 == 80) return "few"
    return "other"
  }
}''',
    "gd": '''\
class Plural {
  static call(n) {
    if (n == 1 || n == 11) return "one"
    if (n == 2 || n == 12) return "two"
    if ((n >= 3 && n <= 10) || (n >= 13 && n <= 19)) return "few"
    return "other"
  }
}''',
    "ga": '''\
class Plural {
  static call(n) {
    if (n == 1) return "one"
    if (n == 2) return "two"
    if (n >= 3 && n <= 6) return "few"
    if (n >= 7 && n <= 10) return "many"
    return "other"
  }
}''',
    "mt": '''\
class Plural {
  static call(n) {
    if (n == 1) return "one"
    if (n == 2) return "two"
    var mod100 = n % 100
    if (n == 0 || (mod100 >= 3 && mod100 <= 10)) return "few"
    if (mod100 >= 11 && mod100 <= 19) return "many"
    return "other"
  }
}''',
    "br": '''\
class Plural {
  static call(n) {
    var mod10 = n % 10
    var mod100 = n % 100
    if (mod10 == 1 && mod100 != 11 && mod100 != 71 && mod100 != 91) return "one"
    if (mod10 == 2 && mod100 != 12 && mod100 != 72 && mod100 != 92) return "two"
    if ((mod10 == 3 || mod10 == 4 || mod10 == 9) && !(mod100 >= 10 && mod100 <= 19) && !(mod100 >= 70 && mod100 <= 79) && !(mod100 >= 90 && mod100 <= 99)) return "few"
    if (n != 0 && n % 1000000 == 0) return "many"
    return "other"
  }
}''',
    "kw": '''\
class Plural {
  static call(n) {
    if (n == 0) return "zero"
    if (n == 1) return "one"
    var mod100 = n % 100
    if (mod100 == 2 || mod100 == 22 || mod100 == 42 || mod100 == 62 || mod100 == 82) return "two"
    if (mod100 == 3 || mod100 == 23 || mod100 == 43 || mod100 == 63 || mod100 == 83) return "few"
    if (n != 1 && (mod100 == 1 || mod100 == 21 || mod100 == 41 || mod100 == 61 || mod100 == 81)) return "many"
    return "other"
  }
}''',
    "shi": '''\
class Plural {
  static call(n) {
    if (n == 0 || n == 1) return "one"
    if (n >= 2 && n <= 10) return "few"
    return "other"
  }
}''',
    "tzm": '''\
class Plural {
  static call(n) {
    if (n == 0 || n == 1 || (n >= 11 && n <= 99)) return "one"
    return "other"
  }
}''',
}


def is_simple_plural(rule: str) -> bool:
    """True if this rule can be expressed as an inline Fn."""
    return rule in ("other_only", "one_other", "one_other_zero_one")


def get_wren_plural(rule: str) -> str:
    """Get Wren plural expression (inline Fn or class method reference)."""
    if rule in _WREN:
        return _WREN[rule]
    return 'Fn.new {|n| Plural.call(n) }'


def get_wren_named_class(rule: str) -> str | None:
    """Get Wren named Plural class for complex rules."""
    return _WREN_NAMED.get(rule)
