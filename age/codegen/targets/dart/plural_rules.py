"""Dart plural rule definitions for all 23 patterns."""

from __future__ import annotations

_DART = {
    "other_only": """\
  (int n) {
    return PluralCategory.other;
  }""",
    "one_other": """\
  (int n) {
    if (n == 1) return PluralCategory.one;
    return PluralCategory.other;
  }""",
    "one_other_zero_one": """\
  (int n) {
    if (n == 0 || n == 1) return PluralCategory.one;
    return PluralCategory.other;
  }""",
    "cs_sk": """\
  (int n) {
    if (n == 1) return PluralCategory.one;
    if (n >= 2 && n <= 4) return PluralCategory.few;
    return PluralCategory.other;
  }""",
    "lt": """\
  (int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return PluralCategory.one;
    if (mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19)) return PluralCategory.few;
    return PluralCategory.other;
  }""",
    "ro": """\
  (int n) {
    if (n == 1) return PluralCategory.one;
    if (n == 0 || (n % 100 >= 1 && n % 100 <= 19)) return PluralCategory.few;
    return PluralCategory.other;
  }""",
    "slavic_bcs": """\
  (int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return PluralCategory.one;
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory.few;
    return PluralCategory.other;
  }""",
    "pl": """\
  (int n) {
    if (n == 1) return PluralCategory.one;
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory.few;
    return PluralCategory.many;
  }""",
    "ru_uk": """\
  (int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return PluralCategory.one;
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return PluralCategory.few;
    return PluralCategory.many;
  }""",
    "sl": """\
  (int n) {
    final mod100 = n % 100;
    if (mod100 == 1) return PluralCategory.one;
    if (mod100 == 2) return PluralCategory.two;
    if (mod100 == 3 || mod100 == 4) return PluralCategory.few;
    return PluralCategory.other;
  }""",
    "ar": """\
  (int n) {
    if (n == 0) return PluralCategory.zero;
    if (n == 1) return PluralCategory.one;
    if (n == 2) return PluralCategory.two;
    final mod100 = n % 100;
    if (mod100 >= 3 && mod100 <= 10) return PluralCategory.few;
    if (mod100 >= 11 && mod100 <= 99) return PluralCategory.many;
    return PluralCategory.other;
  }""",
    "lv": """\
  (int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 0 || (mod100 >= 11 && mod100 <= 19)) return PluralCategory.zero;
    if (mod10 == 1 && mod100 != 11) return PluralCategory.one;
    return PluralCategory.other;
  }""",
    "he": """\
  (int n) {
    if (n == 1) return PluralCategory.one;
    if (n == 2) return PluralCategory.two;
    return PluralCategory.other;
  }""",
    "mk": """\
  (int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return PluralCategory.one;
    return PluralCategory.other;
  }""",
    "cy": """\
  (int n) {
    if (n == 0) return PluralCategory.zero;
    if (n == 1) return PluralCategory.one;
    if (n == 2) return PluralCategory.two;
    if (n == 3) return PluralCategory.few;
    if (n == 6) return PluralCategory.many;
    return PluralCategory.other;
  }""",
    "gv": """\
  (int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1) return PluralCategory.one;
    if (mod10 == 2) return PluralCategory.two;
    if (mod100 == 0 || mod100 == 20 || mod100 == 40 || mod100 == 60 || mod100 == 80) return PluralCategory.few;
    return PluralCategory.other;
  }""",
    "gd": """\
  (int n) {
    if (n == 1 || n == 11) return PluralCategory.one;
    if (n == 2 || n == 12) return PluralCategory.two;
    if ((n >= 3 && n <= 10) || (n >= 13 && n <= 19)) return PluralCategory.few;
    return PluralCategory.other;
  }""",
    "ga": """\
  (int n) {
    if (n == 1) return PluralCategory.one;
    if (n == 2) return PluralCategory.two;
    if (n >= 3 && n <= 6) return PluralCategory.few;
    if (n >= 7 && n <= 10) return PluralCategory.many;
    return PluralCategory.other;
  }""",
    "mt": """\
  (int n) {
    if (n == 1) return PluralCategory.one;
    if (n == 2) return PluralCategory.two;
    final mod100 = n % 100;
    if (n == 0 || (mod100 >= 3 && mod100 <= 10)) return PluralCategory.few;
    if (mod100 >= 11 && mod100 <= 19) return PluralCategory.many;
    return PluralCategory.other;
  }""",
    "br": """\
  (int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11 && mod100 != 71 && mod100 != 91) return PluralCategory.one;
    if (mod10 == 2 && mod100 != 12 && mod100 != 72 && mod100 != 92) return PluralCategory.two;
    if ((mod10 == 3 || mod10 == 4 || mod10 == 9) && (mod100 < 10 || mod100 > 19) && (mod100 < 70 || mod100 > 79) && (mod100 < 90 || mod100 > 99)) return PluralCategory.few;
    if (n != 0 && n % 1000000 == 0) return PluralCategory.many;
    return PluralCategory.other;
  }""",
    "kw": """\
  (int n) {
    if (n == 0) return PluralCategory.zero;
    if (n == 1) return PluralCategory.one;
    final mod100 = n % 100;
    if (mod100 == 2 || mod100 == 22 || mod100 == 42 || mod100 == 62 || mod100 == 82) return PluralCategory.two;
    if (mod100 == 3 || mod100 == 23 || mod100 == 43 || mod100 == 63 || mod100 == 83) return PluralCategory.few;
    if (n != 1 && (mod100 == 1 || mod100 == 21 || mod100 == 41 || mod100 == 61 || mod100 == 81)) return PluralCategory.many;
    return PluralCategory.other;
  }""",
    "shi": """\
  (int n) {
    if (n == 0 || n == 1) return PluralCategory.one;
    if (n >= 2 && n <= 10) return PluralCategory.few;
    return PluralCategory.other;
  }""",
    "tzm": """\
  (int n) {
    if (n == 0 || n == 1 || (n >= 11 && n <= 99)) return PluralCategory.one;
    return PluralCategory.other;
  }""",
}


def get_dart_plural(rule: str) -> str:
    return _DART[rule]
