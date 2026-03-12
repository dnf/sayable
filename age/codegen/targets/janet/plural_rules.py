"""Janet plural rule definitions for all 23 patterns."""

from __future__ import annotations

_JANET = {
    "other_only": '(fn [_n] :other)',
    "one_other": '(fn [n] (if (= n 1) :one :other))',
    "one_other_zero_one": '(fn [n] (if (or (= n 0) (= n 1)) :one :other))',
}

_JANET_NAMED = {
    "cs_sk": '''\
(defn- plural [n]
  (cond
    (= n 1) :one
    (and (>= n 2) (<= n 4)) :few
    :other))''',
    "lt": '''\
(defn- plural [n]
  (let [mod10 (% n 10)
        mod100 (% n 100)]
    (cond
      (and (= mod10 1) (not= mod100 11)) :one
      (and (>= mod10 2) (<= mod10 9)
           (or (< mod100 12) (> mod100 19))) :few
      :other)))''',
    "ro": '''\
(defn- plural [n]
  (cond
    (= n 1) :one
    (or (= n 0) (and (>= (% n 100) 1) (<= (% n 100) 19))) :few
    :other))''',
    "slavic_bcs": '''\
(defn- plural [n]
  (let [mod10 (% n 10)
        mod100 (% n 100)]
    (cond
      (and (= mod10 1) (not= mod100 11)) :one
      (and (>= mod10 2) (<= mod10 4)
           (or (< mod100 12) (> mod100 14))) :few
      :other)))''',
    "pl": '''\
(defn- plural [n]
  (if (= n 1) :one
    (let [mod10 (% n 10)
          mod100 (% n 100)]
      (if (and (>= mod10 2) (<= mod10 4)
               (or (< mod100 12) (> mod100 14)))
        :few
        :many))))''',
    "ru_uk": '''\
(defn- plural [n]
  (let [mod10 (% n 10)
        mod100 (% n 100)]
    (cond
      (and (= mod10 1) (not= mod100 11)) :one
      (and (>= mod10 2) (<= mod10 4)
           (or (< mod100 12) (> mod100 14))) :few
      :many)))''',
    "sl": '''\
(defn- plural [n]
  (let [mod100 (% n 100)]
    (cond
      (= mod100 1) :one
      (= mod100 2) :two
      (or (= mod100 3) (= mod100 4)) :few
      :other)))''',
    "ar": '''\
(defn- plural [n]
  (cond
    (= n 0) :zero
    (= n 1) :one
    (= n 2) :two
    (let [mod100 (% n 100)]
      (cond
        (and (>= mod100 3) (<= mod100 10)) :few
        (and (>= mod100 11) (<= mod100 99)) :many
        :other))))''',
    "lv": '''\
(defn- plural [n]
  (let [mod10 (% n 10)
        mod100 (% n 100)]
    (cond
      (or (= mod10 0) (and (>= mod100 11) (<= mod100 19))) :zero
      (and (= mod10 1) (not= mod100 11)) :one
      :other)))''',
    "he": '''\
(defn- plural [n]
  (cond
    (= n 1) :one
    (= n 2) :two
    :other))''',
    "mk": '''\
(defn- plural [n]
  (let [mod10 (% n 10)
        mod100 (% n 100)]
    (if (and (= mod10 1) (not= mod100 11))
      :one
      :other)))''',
    "cy": '''\
(defn- plural [n]
  (cond
    (= n 0) :zero
    (= n 1) :one
    (= n 2) :two
    (= n 3) :few
    (= n 6) :many
    :other))''',
    "gv": '''\
(defn- plural [n]
  (let [mod10 (% n 10)
        mod100 (% n 100)]
    (cond
      (= mod10 1) :one
      (= mod10 2) :two
      (or (= mod100 0) (= mod100 20) (= mod100 40) (= mod100 60) (= mod100 80)) :few
      :other)))''',
    "gd": '''\
(defn- plural [n]
  (cond
    (or (= n 1) (= n 11)) :one
    (or (= n 2) (= n 12)) :two
    (or (and (>= n 3) (<= n 10)) (and (>= n 13) (<= n 19))) :few
    :other))''',
    "ga": '''\
(defn- plural [n]
  (cond
    (= n 1) :one
    (= n 2) :two
    (and (>= n 3) (<= n 6)) :few
    (and (>= n 7) (<= n 10)) :many
    :other))''',
    "mt": '''\
(defn- plural [n]
  (cond
    (= n 1) :one
    (= n 2) :two
    (let [mod100 (% n 100)]
      (cond
        (or (= n 0) (and (>= mod100 3) (<= mod100 10))) :few
        (and (>= mod100 11) (<= mod100 19)) :many
        :other))))''',
    "br": '''\
(defn- plural [n]
  (let [mod10 (% n 10)
        mod100 (% n 100)]
    (cond
      (and (= mod10 1) (not= mod100 11) (not= mod100 71) (not= mod100 91)) :one
      (and (= mod10 2) (not= mod100 12) (not= mod100 72) (not= mod100 92)) :two
      (and (or (= mod10 3) (= mod10 4) (= mod10 9))
           (not (and (>= mod100 10) (<= mod100 19)))
           (not (and (>= mod100 70) (<= mod100 79)))
           (not (and (>= mod100 90) (<= mod100 99)))) :few
      (and (not= n 0) (= (% n 1000000) 0)) :many
      :other)))''',
    "kw": '''\
(defn- plural [n]
  (let [mod100 (% n 100)]
    (cond
      (= n 0) :zero
      (= n 1) :one
      (or (= mod100 2) (= mod100 22) (= mod100 42) (= mod100 62) (= mod100 82)) :two
      (or (= mod100 3) (= mod100 23) (= mod100 43) (= mod100 63) (= mod100 83)) :few
      (and (not= n 1) (or (= mod100 1) (= mod100 21) (= mod100 41) (= mod100 61) (= mod100 81))) :many
      :other)))''',
    "shi": '''\
(defn- plural [n]
  (cond
    (or (= n 0) (= n 1)) :one
    (and (>= n 2) (<= n 10)) :few
    :other))''',
    "tzm": '''\
(defn- plural [n]
  (if (or (= n 0) (= n 1) (and (>= n 11) (<= n 99)))
    :one
    :other))''',
}


def is_simple_plural(rule: str) -> bool:
    """True if this rule can be expressed as an inline function."""
    return rule in ("other_only", "one_other", "one_other_zero_one")


def get_janet_plural(rule: str) -> str:
    """Get Janet plural expression (inline function or function reference)."""
    if rule in _JANET:
        return _JANET[rule]
    return "plural"


def get_janet_named_function(rule: str) -> str | None:
    """Get Janet named function for complex rules."""
    return _JANET_NAMED.get(rule)
