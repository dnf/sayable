"""TypeScript plural rule definitions for all 12 patterns."""

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
