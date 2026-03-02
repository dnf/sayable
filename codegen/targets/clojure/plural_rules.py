"""Clojure plural rule definitions for all 23 patterns."""

from __future__ import annotations

_CLJ = {
    "other_only": "(fn [_] :other)",
    "one_other": "(fn [n] (if (== n 1) :one :other))",
    "one_other_zero_one": "(fn [n] (if (or (== n 0) (== n 1)) :one :other))",
    "cs_sk": "(fn [n] (cond (== n 1) :one (<= 2 n 4) :few :else :other))",
    "lt": "(fn [n] (cond (and (== (mod n 10) 1) (not= (mod n 100) 11)) :one (and (<= 2 (mod n 10) 9) (not (<= 12 (mod n 100) 19))) :few :else :other))",
    "ro": "(fn [n] (cond (== n 1) :one (or (== n 0) (<= 1 (mod n 100) 19)) :few :else :other))",
    "slavic_bcs": "(fn [n] (cond (and (== (mod n 10) 1) (not= (mod n 100) 11)) :one (and (<= 2 (mod n 10) 4) (not (<= 12 (mod n 100) 14))) :few :else :other))",
    "pl": "(fn [n] (cond (== n 1) :one (and (<= 2 (mod n 10) 4) (not (<= 12 (mod n 100) 14))) :few :else :many))",
    "ru_uk": "(fn [n] (cond (and (== (mod n 10) 1) (not= (mod n 100) 11)) :one (and (<= 2 (mod n 10) 4) (not (<= 12 (mod n 100) 14))) :few :else :many))",
    "sl": "(fn [n] (cond (== (mod n 100) 1) :one (== (mod n 100) 2) :two (or (== (mod n 100) 3) (== (mod n 100) 4)) :few :else :other))",
    "ar": "(fn [n] (cond (== n 0) :zero (== n 1) :one (== n 2) :two (<= 3 (mod n 100) 10) :few (<= 11 (mod n 100) 99) :many :else :other))",
    "lv": "(fn [n] (cond (or (== (mod n 10) 0) (<= 11 (mod n 100) 19)) :zero (and (== (mod n 10) 1) (not= (mod n 100) 11)) :one :else :other))",
    "he": "(fn [n] (cond (== n 1) :one (== n 2) :two :else :other))",
    "mk": "(fn [n] (if (and (== (mod n 10) 1) (not= (mod n 100) 11)) :one :other))",
    "cy": "(fn [n] (cond (== n 0) :zero (== n 1) :one (== n 2) :two (== n 3) :few (== n 6) :many :else :other))",
    "gv": "(fn [n] (cond (== (mod n 10) 1) :one (== (mod n 10) 2) :two (or (== (mod n 100) 0) (== (mod n 100) 20) (== (mod n 100) 40) (== (mod n 100) 60) (== (mod n 100) 80)) :few :else :other))",
    "gd": "(fn [n] (cond (or (== n 1) (== n 11)) :one (or (== n 2) (== n 12)) :two (or (<= 3 n 10) (<= 13 n 19)) :few :else :other))",
    "ga": "(fn [n] (cond (== n 1) :one (== n 2) :two (<= 3 n 6) :few (<= 7 n 10) :many :else :other))",
    "mt": "(fn [n] (cond (== n 1) :one (== n 2) :two (or (== n 0) (<= 3 (mod n 100) 10)) :few (<= 11 (mod n 100) 19) :many :else :other))",
    "br": "(fn [n] (cond (and (== (mod n 10) 1) (not= (mod n 100) 11) (not= (mod n 100) 71) (not= (mod n 100) 91)) :one (and (== (mod n 10) 2) (not= (mod n 100) 12) (not= (mod n 100) 72) (not= (mod n 100) 92)) :two (and (or (== (mod n 10) 3) (== (mod n 10) 4) (== (mod n 10) 9)) (not (<= 10 (mod n 100) 19)) (not (<= 70 (mod n 100) 79)) (not (<= 90 (mod n 100) 99))) :few (and (not= n 0) (== (mod n 1000000) 0)) :many :else :other))",
    "kw": "(fn [n] (cond (== n 0) :zero (== n 1) :one (or (== (mod n 100) 2) (== (mod n 100) 22) (== (mod n 100) 42) (== (mod n 100) 62) (== (mod n 100) 82)) :two (or (== (mod n 100) 3) (== (mod n 100) 23) (== (mod n 100) 43) (== (mod n 100) 63) (== (mod n 100) 83)) :few (and (not= n 1) (or (== (mod n 100) 1) (== (mod n 100) 21) (== (mod n 100) 41) (== (mod n 100) 61) (== (mod n 100) 81))) :many :else :other))",
    "shi": "(fn [n] (if (or (== n 0) (== n 1)) :one (if (<= 2 n 10) :few :other)))",
    "tzm": "(fn [n] (if (or (== n 0) (== n 1) (<= 11 n 99)) :one :other))",
}


def get_clj_plural(rule: str) -> str:
    """Return the Clojure expression for the given plural rule name."""
    return _CLJ[rule]
