"""Common Lisp plural rule definitions for all 23 patterns."""

from __future__ import annotations

_LISP_INLINE = {
    "other_only": "(lambda (n) (declare (ignore n)) :other)",
    "one_other": "(lambda (n) (if (= n 1) :one :other))",
    "one_other_zero_one": "(lambda (n) (if (<= n 1) :one :other))",
}

_LISP_NAMED = {
    "cs_sk": """\
(defun plural-cs-sk (n)
  (cond
    ((= n 1) :one)
    ((<= 2 n 4) :few)
    (t :other)))""",
    "lt": """\
(defun plural-lt (n)
  (let ((mod10 (mod n 10))
        (mod100 (mod n 100)))
    (cond
      ((and (= mod10 1) (/= mod100 11)) :one)
      ((and (<= 2 mod10 9) (or (< mod100 12) (> mod100 19))) :few)
      (t :other))))""",
    "ro": """\
(defun plural-ro (n)
  (cond
    ((= n 1) :one)
    ((or (= n 0) (<= 1 (mod n 100) 19)) :few)
    (t :other)))""",
    "slavic_bcs": """\
(defun plural-slavic-bcs (n)
  (let ((mod10 (mod n 10))
        (mod100 (mod n 100)))
    (cond
      ((and (= mod10 1) (/= mod100 11)) :one)
      ((and (<= 2 mod10 4) (or (< mod100 12) (> mod100 14))) :few)
      (t :other))))""",
    "pl": """\
(defun plural-pl (n)
  (cond
    ((= n 1) :one)
    (t (let ((mod10 (mod n 10))
             (mod100 (mod n 100)))
         (if (and (<= 2 mod10 4) (or (< mod100 12) (> mod100 14)))
             :few
             :many)))))""",
    "ru_uk": """\
(defun plural-ru-uk (n)
  (let ((mod10 (mod n 10))
        (mod100 (mod n 100)))
    (cond
      ((and (= mod10 1) (/= mod100 11)) :one)
      ((and (<= 2 mod10 4) (or (< mod100 12) (> mod100 14))) :few)
      (t :many))))""",
    "sl": """\
(defun plural-sl (n)
  (let ((mod100 (mod n 100)))
    (cond
      ((= mod100 1) :one)
      ((= mod100 2) :two)
      ((or (= mod100 3) (= mod100 4)) :few)
      (t :other))))""",
    "ar": """\
(defun plural-ar (n)
  (cond
    ((= n 0) :zero)
    ((= n 1) :one)
    ((= n 2) :two)
    (t (let ((mod100 (mod n 100)))
         (cond
           ((<= 3 mod100 10) :few)
           ((<= 11 mod100 99) :many)
           (t :other))))))""",
    "lv": """\
(defun plural-lv (n)
  (let ((mod10 (mod n 10))
        (mod100 (mod n 100)))
    (cond
      ((or (= mod10 0) (<= 11 mod100 19)) :zero)
      ((and (= mod10 1) (/= mod100 11)) :one)
      (t :other))))""",
    "he": """\
(defun plural-he (n)
  (cond
    ((= n 1) :one)
    ((= n 2) :two)
    (t :other)))""",
    "mk": """\
(defun plural-mk (n)
  (let ((mod10 (mod n 10))
        (mod100 (mod n 100)))
    (if (and (= mod10 1) (/= mod100 11))
        :one
        :other)))""",
    "cy": """\
(defun plural-cy (n)
  (cond
    ((= n 0) :zero)
    ((= n 1) :one)
    ((= n 2) :two)
    ((= n 3) :few)
    ((= n 6) :many)
    (t :other)))""",
    "gv": """\
(defun plural-gv (n)
  (let ((mod10 (mod n 10))
        (mod100 (mod n 100)))
    (cond
      ((= mod10 1) :one)
      ((= mod10 2) :two)
      ((member mod100 '(0 20 40 60 80)) :few)
      (t :other))))""",
    "gd": """\
(defun plural-gd (n)
  (cond
    ((or (= n 1) (= n 11)) :one)
    ((or (= n 2) (= n 12)) :two)
    ((or (<= 3 n 10) (<= 13 n 19)) :few)
    (t :other)))""",
    "ga": """\
(defun plural-ga (n)
  (cond
    ((= n 1) :one)
    ((= n 2) :two)
    ((<= 3 n 6) :few)
    ((<= 7 n 10) :many)
    (t :other)))""",
    "mt": """\
(defun plural-mt (n)
  (cond
    ((= n 1) :one)
    ((= n 2) :two)
    (t (let ((mod100 (mod n 100)))
         (cond
           ((or (= n 0) (<= 3 mod100 10)) :few)
           ((<= 11 mod100 19) :many)
           (t :other))))))""",
    "br": """\
(defun plural-br (n)
  (let ((mod10 (mod n 10))
        (mod100 (mod n 100)))
    (cond
      ((and (= mod10 1) (not (member mod100 '(11 71 91)))) :one)
      ((and (= mod10 2) (not (member mod100 '(12 72 92)))) :two)
      ((and (member mod10 '(3 4 9))
            (not (<= 10 mod100 19))
            (not (<= 70 mod100 79))
            (not (<= 90 mod100 99))) :few)
      ((and (/= n 0) (= (mod n 1000000) 0)) :many)
      (t :other))))""",
    "kw": """\
(defun plural-kw (n)
  (let ((mod100 (mod n 100)))
    (cond
      ((= n 0) :zero)
      ((= n 1) :one)
      ((member mod100 '(2 22 42 62 82)) :two)
      ((member mod100 '(3 23 43 63 83)) :few)
      ((and (/= n 1) (member mod100 '(1 21 41 61 81))) :many)
      (t :other))))""",
    "shi": """\
(defun plural-shi (n)
  (cond
    ((<= n 1) :one)
    ((<= 2 n 10) :few)
    (t :other)))""",
    "tzm": """\
(defun plural-tzm (n)
  (if (or (<= n 1) (<= 11 n 99))
      :one
      :other))""",
}


def is_simple_plural(rule: str) -> bool:
    """True if this rule can be expressed as an inline lambda."""
    return rule in ("other_only", "one_other", "one_other_zero_one")


def get_lisp_plural(rule: str) -> str:
    """Get Lisp plural expression (lambda or function reference)."""
    if rule in _LISP_INLINE:
        return _LISP_INLINE[rule]
    # For named rules, return the function symbol name
    fn_name = f"plural-{rule.replace('_', '-')}"
    return f"#'{fn_name}"


def get_lisp_named_function(rule: str) -> str | None:
    """Get Lisp named function for complex rules."""
    return _LISP_NAMED.get(rule)
