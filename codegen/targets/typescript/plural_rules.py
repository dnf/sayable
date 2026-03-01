"""TypeScript plural rule definitions for all 23 patterns."""

from __future__ import annotations

_TS = {
    "other_only": "() => 'other'",
    "one_other": "(n) => (n === 1 ? 'one' : 'other')",
    "one_other_zero_one": "(n) => (n === 0 || n === 1 ? 'one' : 'other')",
    "cs_sk": """\
(n) => {
    if (n === 1) return 'one';
    if (n >= 2 && n <= 4) return 'few';
    return 'other';
  }""",
    "lt": """\
(n) => {
    const mod10 = n % 10;
    const mod100 = n % 100;
    if (mod10 === 1 && mod100 !== 11) return 'one';
    if (mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19)) return 'few';
    return 'other';
  }""",
    "ro": """\
(n) => {
    if (n === 1) return 'one';
    if (n === 0 || (n % 100 >= 1 && n % 100 <= 19)) return 'few';
    return 'other';
  }""",
    "slavic_bcs": """\
(n) => {
    const mod10 = n % 10;
    const mod100 = n % 100;
    if (mod10 === 1 && mod100 !== 11) return 'one';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'few';
    return 'other';
  }""",
    "pl": """\
(n) => {
    if (n === 1) return 'one';
    const mod10 = n % 10;
    const mod100 = n % 100;
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'few';
    return 'many';
  }""",
    "ru_uk": """\
(n) => {
    const mod10 = n % 10;
    const mod100 = n % 100;
    if (mod10 === 1 && mod100 !== 11) return 'one';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'few';
    return 'many';
  }""",
    "sl": """\
(n) => {
    const mod100 = n % 100;
    if (mod100 === 1) return 'one';
    if (mod100 === 2) return 'two';
    if (mod100 === 3 || mod100 === 4) return 'few';
    return 'other';
  }""",
    "ar": """\
(n) => {
    if (n === 0) return 'zero';
    if (n === 1) return 'one';
    if (n === 2) return 'two';
    const mod100 = n % 100;
    if (mod100 >= 3 && mod100 <= 10) return 'few';
    if (mod100 >= 11 && mod100 <= 99) return 'many';
    return 'other';
  }""",
    "lv": """\
(n) => {
    const mod10 = n % 10;
    const mod100 = n % 100;
    if (mod10 === 0 || (mod100 >= 11 && mod100 <= 19)) return 'zero';
    if (mod10 === 1 && mod100 !== 11) return 'one';
    return 'other';
  }""",
    "he": """\
(n) => {
    if (n === 1) return 'one';
    if (n === 2) return 'two';
    return 'other';
  }""",
    "mk": """\
(n) => {
    const mod10 = n % 10;
    const mod100 = n % 100;
    if (mod10 === 1 && mod100 !== 11) return 'one';
    return 'other';
  }""",
    "cy": """\
(n) => {
    if (n === 0) return 'zero';
    if (n === 1) return 'one';
    if (n === 2) return 'two';
    if (n === 3) return 'few';
    if (n === 6) return 'many';
    return 'other';
  }""",
    "gv": """\
(n) => {
    const mod10 = n % 10;
    const mod100 = n % 100;
    if (mod10 === 1) return 'one';
    if (mod10 === 2) return 'two';
    if (mod100 === 0 || mod100 === 20 || mod100 === 40 || mod100 === 60 || mod100 === 80) return 'few';
    return 'other';
  }""",
    "gd": """\
(n) => {
    if (n === 1 || n === 11) return 'one';
    if (n === 2 || n === 12) return 'two';
    if ((n >= 3 && n <= 10) || (n >= 13 && n <= 19)) return 'few';
    return 'other';
  }""",
    "ga": """\
(n) => {
    if (n === 1) return 'one';
    if (n === 2) return 'two';
    if (n >= 3 && n <= 6) return 'few';
    if (n >= 7 && n <= 10) return 'many';
    return 'other';
  }""",
    "mt": """\
(n) => {
    if (n === 1) return 'one';
    if (n === 2) return 'two';
    const mod100 = n % 100;
    if (n === 0 || (mod100 >= 3 && mod100 <= 10)) return 'few';
    if (mod100 >= 11 && mod100 <= 19) return 'many';
    return 'other';
  }""",
    "br": """\
(n) => {
    const mod10 = n % 10;
    const mod100 = n % 100;
    if (mod10 === 1 && mod100 !== 11 && mod100 !== 71 && mod100 !== 91) return 'one';
    if (mod10 === 2 && mod100 !== 12 && mod100 !== 72 && mod100 !== 92) return 'two';
    if ((mod10 === 3 || mod10 === 4 || mod10 === 9) && !(mod100 >= 10 && mod100 <= 19) && !(mod100 >= 70 && mod100 <= 79) && !(mod100 >= 90 && mod100 <= 99)) return 'few';
    if (n !== 0 && n % 1000000 === 0) return 'many';
    return 'other';
  }""",
    "kw": """\
(n) => {
    if (n === 0) return 'zero';
    if (n === 1) return 'one';
    const mod100 = n % 100;
    if (mod100 === 2 || mod100 === 22 || mod100 === 42 || mod100 === 62 || mod100 === 82) return 'two';
    if (mod100 === 3 || mod100 === 23 || mod100 === 43 || mod100 === 63 || mod100 === 83) return 'few';
    if (n !== 1 && (mod100 === 1 || mod100 === 21 || mod100 === 41 || mod100 === 61 || mod100 === 81)) return 'many';
    return 'other';
  }""",
    "shi": """\
(n) => {
    if (n === 0 || n === 1) return 'one';
    if (n >= 2 && n <= 10) return 'few';
    return 'other';
  }""",
    "tzm": """\
(n) => {
    if (n === 0 || n === 1 || (n >= 11 && n <= 99)) return 'one';
    return 'other';
  }""",
}

_TS_NAMED = {
    "cs_sk": """\
function plural(n: number): PluralCategory {
  if (n === 1) return 'one';
  if (n >= 2 && n <= 4) return 'few';
  return 'other';
}""",
    "lt": """\
function plural(n: number): PluralCategory {
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod10 === 1 && mod100 !== 11) return 'one';
  if (mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19)) return 'few';
  return 'other';
}""",
    "ro": """\
function plural(n: number): PluralCategory {
  if (n === 1) return 'one';
  if (n === 0 || (n % 100 >= 1 && n % 100 <= 19)) return 'few';
  return 'other';
}""",
    "slavic_bcs": """\
function plural(n: number): PluralCategory {
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod10 === 1 && mod100 !== 11) return 'one';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'few';
  return 'other';
}""",
    "pl": """\
function plural(n: number): PluralCategory {
  if (n === 1) return 'one';
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'few';
  return 'many';
}""",
    "ru_uk": """\
function plural(n: number): PluralCategory {
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod10 === 1 && mod100 !== 11) return 'one';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'few';
  return 'many';
}""",
    "sl": """\
function plural(n: number): PluralCategory {
  const mod100 = n % 100;
  if (mod100 === 1) return 'one';
  if (mod100 === 2) return 'two';
  if (mod100 === 3 || mod100 === 4) return 'few';
  return 'other';
}""",
    "ar": """\
function plural(n: number): PluralCategory {
  if (n === 0) return 'zero';
  if (n === 1) return 'one';
  if (n === 2) return 'two';
  const mod100 = n % 100;
  if (mod100 >= 3 && mod100 <= 10) return 'few';
  if (mod100 >= 11 && mod100 <= 99) return 'many';
  return 'other';
}""",
    "lv": """\
function plural(n: number): PluralCategory {
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod10 === 0 || (mod100 >= 11 && mod100 <= 19)) return 'zero';
  if (mod10 === 1 && mod100 !== 11) return 'one';
  return 'other';
}""",
    "he": """\
function plural(n: number): PluralCategory {
  if (n === 1) return 'one';
  if (n === 2) return 'two';
  return 'other';
}""",
    "mk": """\
function plural(n: number): PluralCategory {
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod10 === 1 && mod100 !== 11) return 'one';
  return 'other';
}""",
    "cy": """\
function plural(n: number): PluralCategory {
  if (n === 0) return 'zero';
  if (n === 1) return 'one';
  if (n === 2) return 'two';
  if (n === 3) return 'few';
  if (n === 6) return 'many';
  return 'other';
}""",
    "gv": """\
function plural(n: number): PluralCategory {
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod10 === 1) return 'one';
  if (mod10 === 2) return 'two';
  if (mod100 === 0 || mod100 === 20 || mod100 === 40 || mod100 === 60 || mod100 === 80) return 'few';
  return 'other';
}""",
    "gd": """\
function plural(n: number): PluralCategory {
  if (n === 1 || n === 11) return 'one';
  if (n === 2 || n === 12) return 'two';
  if ((n >= 3 && n <= 10) || (n >= 13 && n <= 19)) return 'few';
  return 'other';
}""",
    "ga": """\
function plural(n: number): PluralCategory {
  if (n === 1) return 'one';
  if (n === 2) return 'two';
  if (n >= 3 && n <= 6) return 'few';
  if (n >= 7 && n <= 10) return 'many';
  return 'other';
}""",
    "mt": """\
function plural(n: number): PluralCategory {
  if (n === 1) return 'one';
  if (n === 2) return 'two';
  const mod100 = n % 100;
  if (n === 0 || (mod100 >= 3 && mod100 <= 10)) return 'few';
  if (mod100 >= 11 && mod100 <= 19) return 'many';
  return 'other';
}""",
    "br": """\
function plural(n: number): PluralCategory {
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod10 === 1 && mod100 !== 11 && mod100 !== 71 && mod100 !== 91) return 'one';
  if (mod10 === 2 && mod100 !== 12 && mod100 !== 72 && mod100 !== 92) return 'two';
  if ((mod10 === 3 || mod10 === 4 || mod10 === 9) && !(mod100 >= 10 && mod100 <= 19) && !(mod100 >= 70 && mod100 <= 79) && !(mod100 >= 90 && mod100 <= 99)) return 'few';
  if (n !== 0 && n % 1000000 === 0) return 'many';
  return 'other';
}""",
    "kw": """\
function plural(n: number): PluralCategory {
  if (n === 0) return 'zero';
  if (n === 1) return 'one';
  const mod100 = n % 100;
  if (mod100 === 2 || mod100 === 22 || mod100 === 42 || mod100 === 62 || mod100 === 82) return 'two';
  if (mod100 === 3 || mod100 === 23 || mod100 === 43 || mod100 === 63 || mod100 === 83) return 'few';
  if (n !== 1 && (mod100 === 1 || mod100 === 21 || mod100 === 41 || mod100 === 61 || mod100 === 81)) return 'many';
  return 'other';
}""",
    "shi": """\
function plural(n: number): PluralCategory {
  if (n === 0 || n === 1) return 'one';
  if (n >= 2 && n <= 10) return 'few';
  return 'other';
}""",
    "tzm": """\
function plural(n: number): PluralCategory {
  if (n === 0 || n === 1 || (n >= 11 && n <= 99)) return 'one';
  return 'other';
}""",
}


def is_simple_plural(rule: str) -> bool:
    """True if this rule can be expressed as an inline lambda/closure."""
    return rule in ("other_only", "one_other", "one_other_zero_one")


def get_ts_plural(rule: str) -> str:
    """Get TypeScript plural inline expression for simple rules."""
    return _TS[rule]


def get_ts_named_function(rule: str) -> str | None:
    """Get the named function declaration for complex TS rules."""
    return _TS_NAMED.get(rule)
