"""Nim plural rule definitions for all 23 patterns."""

from __future__ import annotations

_NIM_INLINE = {
    "other_only": 'proc(n: int): PluralCategory = pcOther',
    "one_other": 'proc(n: int): PluralCategory = (if n == 1: pcOne else: pcOther)',
    "one_other_zero_one": 'proc(n: int): PluralCategory = (if n in {0, 1}: pcOne else: pcOther)',
}

_NIM_NAMED = {
    "cs_sk": '''\
proc plural(n: int): PluralCategory =
  if n == 1: pcOne
  elif n in 2..4: pcFew
  else: pcOther''',
    "lt": '''\
proc plural(n: int): PluralCategory =
  let mod10 = n mod 10
  let mod100 = n mod 100
  if mod10 == 1 and mod100 != 11: pcOne
  elif mod10 in 2..9 and (mod100 < 12 or mod100 > 19): pcFew
  else: pcOther''',
    "ro": '''\
proc plural(n: int): PluralCategory =
  if n == 1: pcOne
  elif n == 0 or n mod 100 in 1..19: pcFew
  else: pcOther''',
    "slavic_bcs": '''\
proc plural(n: int): PluralCategory =
  let mod10 = n mod 10
  let mod100 = n mod 100
  if mod10 == 1 and mod100 != 11: pcOne
  elif mod10 in 2..4 and (mod100 < 12 or mod100 > 14): pcFew
  else: pcOther''',
    "pl": '''\
proc plural(n: int): PluralCategory =
  if n == 1: pcOne
  else:
    let mod10 = n mod 10
    let mod100 = n mod 100
    if mod10 in 2..4 and (mod100 < 12 or mod100 > 14): pcFew
    else: pcMany''',
    "ru_uk": '''\
proc plural(n: int): PluralCategory =
  let mod10 = n mod 10
  let mod100 = n mod 100
  if mod10 == 1 and mod100 != 11: pcOne
  elif mod10 in 2..4 and (mod100 < 12 or mod100 > 14): pcFew
  else: pcMany''',
    "sl": '''\
proc plural(n: int): PluralCategory =
  let mod100 = n mod 100
  if mod100 == 1: pcOne
  elif mod100 == 2: pcTwo
  elif mod100 in {3, 4}: pcFew
  else: pcOther''',
    "ar": '''\
proc plural(n: int): PluralCategory =
  if n == 0: pcZero
  elif n == 1: pcOne
  elif n == 2: pcTwo
  else:
    let mod100 = n mod 100
    if mod100 in 3..10: pcFew
    elif mod100 in 11..99: pcMany
    else: pcOther''',
    "lv": '''\
proc plural(n: int): PluralCategory =
  let mod10 = n mod 10
  let mod100 = n mod 100
  if mod10 == 0 or mod100 in 11..19: pcZero
  elif mod10 == 1 and mod100 != 11: pcOne
  else: pcOther''',
    "he": '''\
proc plural(n: int): PluralCategory =
  if n == 1: pcOne
  elif n == 2: pcTwo
  else: pcOther''',
    "mk": '''\
proc plural(n: int): PluralCategory =
  let mod10 = n mod 10
  let mod100 = n mod 100
  if mod10 == 1 and mod100 != 11: pcOne
  else: pcOther''',
    "cy": '''\
proc plural(n: int): PluralCategory =
  if n == 0: pcZero
  elif n == 1: pcOne
  elif n == 2: pcTwo
  elif n == 3: pcFew
  elif n == 6: pcMany
  else: pcOther''',
    "gv": '''\
proc plural(n: int): PluralCategory =
  let mod10 = n mod 10
  let mod100 = n mod 100
  if mod10 == 1: pcOne
  elif mod10 == 2: pcTwo
  elif mod100 in {0, 20, 40, 60, 80}: pcFew
  else: pcOther''',
    "gd": '''\
proc plural(n: int): PluralCategory =
  if n in {1, 11}: pcOne
  elif n in {2, 12}: pcTwo
  elif n in 3..10 or n in 13..19: pcFew
  else: pcOther''',
    "ga": '''\
proc plural(n: int): PluralCategory =
  if n == 1: pcOne
  elif n == 2: pcTwo
  elif n in 3..6: pcFew
  elif n in 7..10: pcMany
  else: pcOther''',
    "mt": '''\
proc plural(n: int): PluralCategory =
  if n == 1: pcOne
  elif n == 2: pcTwo
  else:
    let mod100 = n mod 100
    if n == 0 or mod100 in 3..10: pcFew
    elif mod100 in 11..19: pcMany
    else: pcOther''',
    "br": '''\
proc plural(n: int): PluralCategory =
  let mod10 = n mod 10
  let mod100 = n mod 100
  if mod10 == 1 and mod100 notin {11, 71, 91}: pcOne
  elif mod10 == 2 and mod100 notin {12, 72, 92}: pcTwo
  elif mod10 in {3, 4, 9} and mod100 notin 10..19 and mod100 notin 70..79 and mod100 notin 90..99: pcFew
  elif n != 0 and n mod 1000000 == 0: pcMany
  else: pcOther''',
    "kw": '''\
proc plural(n: int): PluralCategory =
  if n == 0: pcZero
  elif n == 1: pcOne
  else:
    let mod100 = n mod 100
    if mod100 in {2, 22, 42, 62, 82}: pcTwo
    elif mod100 in {3, 23, 43, 63, 83}: pcFew
    elif n != 1 and mod100 in {1, 21, 41, 61, 81}: pcMany
    else: pcOther''',
    "shi": '''\
proc plural(n: int): PluralCategory =
  if n in {0, 1}: pcOne
  elif n in 2..10: pcFew
  else: pcOther''',
    "tzm": '''\
proc plural(n: int): PluralCategory =
  if n in {0, 1} or n in 11..99: pcOne
  else: pcOther''',
}


def is_simple_plural(rule: str) -> bool:
    """True if this rule can be expressed as an inline proc."""
    return rule in ("other_only", "one_other", "one_other_zero_one")


def get_nim_plural(rule: str) -> str:
    """Get Nim plural expression (inline proc or function reference)."""
    if rule in _NIM_INLINE:
        return _NIM_INLINE[rule]
    return "plural"


def get_nim_named_function(rule: str) -> str | None:
    """Get Nim named function for complex rules."""
    return _NIM_NAMED.get(rule)
