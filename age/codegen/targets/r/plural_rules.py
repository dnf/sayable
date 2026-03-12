"""R plural rule definitions for all 23 patterns."""

from __future__ import annotations

_R = {
    "other_only": 'function(n) "other"',
    "one_other": 'function(n) if (n == 1) "one" else "other"',
    "one_other_zero_one": 'function(n) if (n == 0 || n == 1) "one" else "other"',
}

_R_NAMED = {
    "cs_sk": '''\
plural <- function(n) {
  if (n == 1) return("one")
  if (n >= 2 && n <= 4) return("few")
  "other"
}''',
    "lt": '''\
plural <- function(n) {
  mod10 <- n %% 10
  mod100 <- n %% 100
  if (mod10 == 1 && mod100 != 11) return("one")
  if (mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19)) return("few")
  "other"
}''',
    "ro": '''\
plural <- function(n) {
  if (n == 1) return("one")
  if (n == 0 || (n %% 100 >= 1 && n %% 100 <= 19)) return("few")
  "other"
}''',
    "slavic_bcs": '''\
plural <- function(n) {
  mod10 <- n %% 10
  mod100 <- n %% 100
  if (mod10 == 1 && mod100 != 11) return("one")
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return("few")
  "other"
}''',
    "pl": '''\
plural <- function(n) {
  if (n == 1) return("one")
  mod10 <- n %% 10
  mod100 <- n %% 100
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return("few")
  "many"
}''',
    "ru_uk": '''\
plural <- function(n) {
  mod10 <- n %% 10
  mod100 <- n %% 100
  if (mod10 == 1 && mod100 != 11) return("one")
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return("few")
  "many"
}''',
    "sl": '''\
plural <- function(n) {
  mod100 <- n %% 100
  if (mod100 == 1) return("one")
  if (mod100 == 2) return("two")
  if (mod100 == 3 || mod100 == 4) return("few")
  "other"
}''',
    "ar": '''\
plural <- function(n) {
  if (n == 0) return("zero")
  if (n == 1) return("one")
  if (n == 2) return("two")
  mod100 <- n %% 100
  if (mod100 >= 3 && mod100 <= 10) return("few")
  if (mod100 >= 11 && mod100 <= 99) return("many")
  "other"
}''',
    "lv": '''\
plural <- function(n) {
  mod10 <- n %% 10
  mod100 <- n %% 100
  if (mod10 == 0 || (mod100 >= 11 && mod100 <= 19)) return("zero")
  if (mod10 == 1 && mod100 != 11) return("one")
  "other"
}''',
    "he": '''\
plural <- function(n) {
  if (n == 1) return("one")
  if (n == 2) return("two")
  "other"
}''',
    "mk": '''\
plural <- function(n) {
  mod10 <- n %% 10
  mod100 <- n %% 100
  if (mod10 == 1 && mod100 != 11) return("one")
  "other"
}''',
    "cy": '''\
plural <- function(n) {
  if (n == 0) return("zero")
  if (n == 1) return("one")
  if (n == 2) return("two")
  if (n == 3) return("few")
  if (n == 6) return("many")
  "other"
}''',
    "gv": '''\
plural <- function(n) {
  mod10 <- n %% 10
  mod100 <- n %% 100
  if (mod10 == 1) return("one")
  if (mod10 == 2) return("two")
  if (mod100 == 0 || mod100 == 20 || mod100 == 40 || mod100 == 60 || mod100 == 80) return("few")
  "other"
}''',
    "gd": '''\
plural <- function(n) {
  if (n == 1 || n == 11) return("one")
  if (n == 2 || n == 12) return("two")
  if ((n >= 3 && n <= 10) || (n >= 13 && n <= 19)) return("few")
  "other"
}''',
    "ga": '''\
plural <- function(n) {
  if (n == 1) return("one")
  if (n == 2) return("two")
  if (n >= 3 && n <= 6) return("few")
  if (n >= 7 && n <= 10) return("many")
  "other"
}''',
    "mt": '''\
plural <- function(n) {
  if (n == 1) return("one")
  if (n == 2) return("two")
  mod100 <- n %% 100
  if (n == 0 || (mod100 >= 3 && mod100 <= 10)) return("few")
  if (mod100 >= 11 && mod100 <= 19) return("many")
  "other"
}''',
    "br": '''\
plural <- function(n) {
  mod10 <- n %% 10
  mod100 <- n %% 100
  if (mod10 == 1 && mod100 != 11 && mod100 != 71 && mod100 != 91) return("one")
  if (mod10 == 2 && mod100 != 12 && mod100 != 72 && mod100 != 92) return("two")
  if ((mod10 == 3 || mod10 == 4 || mod10 == 9) && !(mod100 >= 10 && mod100 <= 19) && !(mod100 >= 70 && mod100 <= 79) && !(mod100 >= 90 && mod100 <= 99)) return("few")
  if (n != 0 && n %% 1000000 == 0) return("many")
  "other"
}''',
    "kw": '''\
plural <- function(n) {
  if (n == 0) return("zero")
  if (n == 1) return("one")
  mod100 <- n %% 100
  if (mod100 == 2 || mod100 == 22 || mod100 == 42 || mod100 == 62 || mod100 == 82) return("two")
  if (mod100 == 3 || mod100 == 23 || mod100 == 43 || mod100 == 63 || mod100 == 83) return("few")
  if (n != 1 && (mod100 == 1 || mod100 == 21 || mod100 == 41 || mod100 == 61 || mod100 == 81)) return("many")
  "other"
}''',
    "shi": '''\
plural <- function(n) {
  if (n == 0 || n == 1) return("one")
  if (n >= 2 && n <= 10) return("few")
  "other"
}''',
    "tzm": '''\
plural <- function(n) {
  if (n == 0 || n == 1 || (n >= 11 && n <= 99)) return("one")
  "other"
}''',
}


def is_simple_plural(rule: str) -> bool:
    """True if this rule can be expressed as an inline function."""
    return rule in ("other_only", "one_other", "one_other_zero_one")


def get_r_plural(rule: str) -> str:
    """Get R plural expression (inline function or function reference)."""
    if rule in _R:
        return _R[rule]
    return "plural"


def get_r_named_function(rule: str) -> str | None:
    """Get R named function for complex rules."""
    return _R_NAMED.get(rule)
