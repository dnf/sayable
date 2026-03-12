"""Racket plural rule definitions for all 23 patterns.

All rules are emitted as Racket lambda expressions.
"""

from __future__ import annotations

_RKT = {
    "other_only": '(lambda (n) "other")',
    "one_other": '(lambda (n) (if (= n 1) "one" "other"))',
    "one_other_zero_one": '(lambda (n) (if (or (= n 0) (= n 1)) "one" "other"))',
    "cs_sk": """(lambda (n)
      (cond
        [(= n 1) "one"]
        [(and (>= n 2) (<= n 4)) "few"]
        [else "other"]))""",
    "lt": """(lambda (n)
      (let ([mod10 (remainder n 10)]
            [mod100 (remainder n 100)])
        (cond
          [(and (= mod10 1) (not (= mod100 11))) "one"]
          [(and (>= mod10 2) (<= mod10 9) (or (< mod100 12) (> mod100 19))) "few"]
          [else "other"])))""",
    "ro": """(lambda (n)
      (cond
        [(= n 1) "one"]
        [(or (= n 0) (and (>= (remainder n 100) 1) (<= (remainder n 100) 19))) "few"]
        [else "other"]))""",
    "slavic_bcs": """(lambda (n)
      (let ([mod10 (remainder n 10)]
            [mod100 (remainder n 100)])
        (cond
          [(and (= mod10 1) (not (= mod100 11))) "one"]
          [(and (>= mod10 2) (<= mod10 4) (or (< mod100 12) (> mod100 14))) "few"]
          [else "other"])))""",
    "pl": """(lambda (n)
      (cond
        [(= n 1) "one"]
        [(let ([mod10 (remainder n 10)]
               [mod100 (remainder n 100)])
           (and (>= mod10 2) (<= mod10 4) (or (< mod100 12) (> mod100 14)))) "few"]
        [else "many"]))""",
    "ru_uk": """(lambda (n)
      (let ([mod10 (remainder n 10)]
            [mod100 (remainder n 100)])
        (cond
          [(and (= mod10 1) (not (= mod100 11))) "one"]
          [(and (>= mod10 2) (<= mod10 4) (or (< mod100 12) (> mod100 14))) "few"]
          [else "many"])))""",
    "sl": """(lambda (n)
      (let ([mod100 (remainder n 100)])
        (cond
          [(= mod100 1) "one"]
          [(= mod100 2) "two"]
          [(or (= mod100 3) (= mod100 4)) "few"]
          [else "other"])))""",
    "ar": """(lambda (n)
      (cond
        [(= n 0) "zero"]
        [(= n 1) "one"]
        [(= n 2) "two"]
        [(and (>= (remainder n 100) 3) (<= (remainder n 100) 10)) "few"]
        [(and (>= (remainder n 100) 11) (<= (remainder n 100) 99)) "many"]
        [else "other"]))""",
    "lv": """(lambda (n)
      (let ([mod10 (remainder n 10)]
            [mod100 (remainder n 100)])
        (cond
          [(or (= mod10 0) (and (>= mod100 11) (<= mod100 19))) "zero"]
          [(and (= mod10 1) (not (= mod100 11))) "one"]
          [else "other"])))""",
    "he": """(lambda (n)
      (cond
        [(= n 1) "one"]
        [(= n 2) "two"]
        [else "other"]))""",
    "mk": """(lambda (n)
      (let ([mod10 (remainder n 10)]
            [mod100 (remainder n 100)])
        (cond
          [(and (= mod10 1) (not (= mod100 11))) "one"]
          [else "other"])))""",
    "cy": """(lambda (n)
      (cond
        [(= n 0) "zero"]
        [(= n 1) "one"]
        [(= n 2) "two"]
        [(= n 3) "few"]
        [(= n 6) "many"]
        [else "other"]))""",
    "gv": """(lambda (n)
      (let ([mod10 (remainder n 10)]
            [mod100 (remainder n 100)])
        (cond
          [(= mod10 1) "one"]
          [(= mod10 2) "two"]
          [(member mod100 '(0 20 40 60 80)) "few"]
          [else "other"])))""",
    "gd": """(lambda (n)
      (cond
        [(or (= n 1) (= n 11)) "one"]
        [(or (= n 2) (= n 12)) "two"]
        [(or (and (>= n 3) (<= n 10)) (and (>= n 13) (<= n 19))) "few"]
        [else "other"]))""",
    "ga": """(lambda (n)
      (cond
        [(= n 1) "one"]
        [(= n 2) "two"]
        [(and (>= n 3) (<= n 6)) "few"]
        [(and (>= n 7) (<= n 10)) "many"]
        [else "other"]))""",
    "mt": """(lambda (n)
      (cond
        [(= n 1) "one"]
        [(= n 2) "two"]
        [(or (= n 0) (and (>= (remainder n 100) 3) (<= (remainder n 100) 10))) "few"]
        [(and (>= (remainder n 100) 11) (<= (remainder n 100) 19)) "many"]
        [else "other"]))""",
    "br": """(lambda (n)
      (let ([mod10 (remainder n 10)]
            [mod100 (remainder n 100)])
        (cond
          [(and (= mod10 1) (not (member mod100 '(11 71 91)))) "one"]
          [(and (= mod10 2) (not (member mod100 '(12 72 92)))) "two"]
          [(and (member mod10 '(3 4 9))
                (not (and (>= mod100 10) (<= mod100 19)))
                (not (and (>= mod100 70) (<= mod100 79)))
                (not (and (>= mod100 90) (<= mod100 99)))) "few"]
          [(and (not (= n 0)) (= (remainder n 1000000) 0)) "many"]
          [else "other"])))""",
    "kw": """(lambda (n)
      (let ([mod100 (remainder n 100)])
        (cond
          [(= n 0) "zero"]
          [(= n 1) "one"]
          [(member mod100 '(2 22 42 62 82)) "two"]
          [(member mod100 '(3 23 43 63 83)) "few"]
          [(and (not (= n 1)) (member mod100 '(1 21 41 61 81))) "many"]
          [else "other"])))""",
    "shi": """(lambda (n)
      (cond
        [(or (= n 0) (= n 1)) "one"]
        [(and (>= n 2) (<= n 10)) "few"]
        [else "other"]))""",
    "tzm": """(lambda (n)
      (cond
        [(or (or (= n 0) (= n 1)) (and (>= n 11) (<= n 99))) "one"]
        [else "other"]))""",
}


def get_rkt_plural(rule: str) -> str:
    """Get Racket plural expression."""
    return _RKT[rule]
