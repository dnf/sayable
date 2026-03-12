"""Pharo Smalltalk plural rule definitions for all 23 patterns."""

from __future__ import annotations

_ST = {
    "other_only": "[ :n | #other ]",
    "one_other": "[ :n | n = 1 ifTrue: [ #one ] ifFalse: [ #other ] ]",
    "one_other_zero_one": "[ :n | (n = 0 or: [ n = 1 ]) ifTrue: [ #one ] ifFalse: [ #other ] ]",
    "cs_sk": """\
[ :n |
\t\t\tn = 1
\t\t\t\tifTrue: [ #one ]
\t\t\t\tifFalse: [ (n >= 2 and: [ n <= 4 ])
\t\t\t\t\tifTrue: [ #few ]
\t\t\t\t\tifFalse: [ #other ] ] ]""",
    "lt": """\
[ :n |
\t\t\t| mod10 mod100 |
\t\t\tmod10 := n \\\\ 10.
\t\t\tmod100 := n \\\\ 100.
\t\t\t(mod10 = 1 and: [ mod100 ~= 11 ])
\t\t\t\tifTrue: [ #one ]
\t\t\t\tifFalse: [ (mod10 >= 2 and: [ mod10 <= 9 and: [ mod100 < 12 or: [ mod100 > 19 ] ] ])
\t\t\t\t\tifTrue: [ #few ]
\t\t\t\t\tifFalse: [ #other ] ] ]""",
    "ro": """\
[ :n |
\t\t\tn = 1
\t\t\t\tifTrue: [ #one ]
\t\t\t\tifFalse: [ (n = 0 or: [ n \\\\ 100 >= 1 and: [ n \\\\ 100 <= 19 ] ])
\t\t\t\t\tifTrue: [ #few ]
\t\t\t\t\tifFalse: [ #other ] ] ]""",
    "slavic_bcs": """\
[ :n |
\t\t\t| mod10 mod100 |
\t\t\tmod10 := n \\\\ 10.
\t\t\tmod100 := n \\\\ 100.
\t\t\t(mod10 = 1 and: [ mod100 ~= 11 ])
\t\t\t\tifTrue: [ #one ]
\t\t\t\tifFalse: [ (mod10 >= 2 and: [ mod10 <= 4 and: [ mod100 < 12 or: [ mod100 > 14 ] ] ])
\t\t\t\t\tifTrue: [ #few ]
\t\t\t\t\tifFalse: [ #other ] ] ]""",
    "pl": """\
[ :n |
\t\t\tn = 1
\t\t\t\tifTrue: [ #one ]
\t\t\t\tifFalse: [
\t\t\t\t\t| mod10 mod100 |
\t\t\t\t\tmod10 := n \\\\ 10.
\t\t\t\t\tmod100 := n \\\\ 100.
\t\t\t\t\t(mod10 >= 2 and: [ mod10 <= 4 and: [ mod100 < 12 or: [ mod100 > 14 ] ] ])
\t\t\t\t\t\tifTrue: [ #few ]
\t\t\t\t\t\tifFalse: [ #many ] ] ]""",
    "ru_uk": """\
[ :n |
\t\t\t| mod10 mod100 |
\t\t\tmod10 := n \\\\ 10.
\t\t\tmod100 := n \\\\ 100.
\t\t\t(mod10 = 1 and: [ mod100 ~= 11 ])
\t\t\t\tifTrue: [ #one ]
\t\t\t\tifFalse: [ (mod10 >= 2 and: [ mod10 <= 4 and: [ mod100 < 12 or: [ mod100 > 14 ] ] ])
\t\t\t\t\tifTrue: [ #few ]
\t\t\t\t\tifFalse: [ #many ] ] ]""",
    "sl": """\
[ :n |
\t\t\t| mod100 |
\t\t\tmod100 := n \\\\ 100.
\t\t\tmod100 = 1
\t\t\t\tifTrue: [ #one ]
\t\t\t\tifFalse: [ mod100 = 2
\t\t\t\t\tifTrue: [ #two ]
\t\t\t\t\tifFalse: [ (mod100 = 3 or: [ mod100 = 4 ])
\t\t\t\t\t\tifTrue: [ #few ]
\t\t\t\t\t\tifFalse: [ #other ] ] ] ]""",
    "ar": """\
[ :n |
\t\t\tn = 0
\t\t\t\tifTrue: [ #zero ]
\t\t\t\tifFalse: [ n = 1
\t\t\t\t\tifTrue: [ #one ]
\t\t\t\t\tifFalse: [ n = 2
\t\t\t\t\t\tifTrue: [ #two ]
\t\t\t\t\t\tifFalse: [
\t\t\t\t\t\t\t| mod100 |
\t\t\t\t\t\t\tmod100 := n \\\\ 100.
\t\t\t\t\t\t\t(mod100 >= 3 and: [ mod100 <= 10 ])
\t\t\t\t\t\t\t\tifTrue: [ #few ]
\t\t\t\t\t\t\t\tifFalse: [ (mod100 >= 11 and: [ mod100 <= 99 ])
\t\t\t\t\t\t\t\t\tifTrue: [ #many ]
\t\t\t\t\t\t\t\t\tifFalse: [ #other ] ] ] ] ] ]""",
    "lv": """\
[ :n |
\t\t\t| mod10 mod100 |
\t\t\tmod10 := n \\\\ 10.
\t\t\tmod100 := n \\\\ 100.
\t\t\t(mod10 = 0 or: [ mod100 >= 11 and: [ mod100 <= 19 ] ])
\t\t\t\tifTrue: [ #zero ]
\t\t\t\tifFalse: [ (mod10 = 1 and: [ mod100 ~= 11 ])
\t\t\t\t\tifTrue: [ #one ]
\t\t\t\t\tifFalse: [ #other ] ] ]""",
    "he": """\
[ :n |
\t\t\tn = 1
\t\t\t\tifTrue: [ #one ]
\t\t\t\tifFalse: [ n = 2
\t\t\t\t\tifTrue: [ #two ]
\t\t\t\t\tifFalse: [ #other ] ] ]""",
    "mk": """\
[ :n |
\t\t\t| mod10 mod100 |
\t\t\tmod10 := n \\\\ 10.
\t\t\tmod100 := n \\\\ 100.
\t\t\t(mod10 = 1 and: [ mod100 ~= 11 ])
\t\t\t\tifTrue: [ #one ]
\t\t\t\tifFalse: [ #other ] ]""",
    "cy": """\
[ :n |
\t\t\tn = 0
\t\t\t\tifTrue: [ #zero ]
\t\t\t\tifFalse: [ n = 1
\t\t\t\t\tifTrue: [ #one ]
\t\t\t\t\tifFalse: [ n = 2
\t\t\t\t\t\tifTrue: [ #two ]
\t\t\t\t\t\tifFalse: [ n = 3
\t\t\t\t\t\t\tifTrue: [ #few ]
\t\t\t\t\t\t\tifFalse: [ n = 6
\t\t\t\t\t\t\t\tifTrue: [ #many ]
\t\t\t\t\t\t\t\tifFalse: [ #other ] ] ] ] ] ]""",
    "gv": """\
[ :n |
\t\t\t| mod10 mod100 |
\t\t\tmod10 := n \\\\ 10.
\t\t\tmod100 := n \\\\ 100.
\t\t\tmod10 = 1
\t\t\t\tifTrue: [ #one ]
\t\t\t\tifFalse: [ mod10 = 2
\t\t\t\t\tifTrue: [ #two ]
\t\t\t\t\tifFalse: [ (#(0 20 40 60 80) includes: mod100)
\t\t\t\t\t\tifTrue: [ #few ]
\t\t\t\t\t\tifFalse: [ #other ] ] ] ]""",
    "gd": """\
[ :n |
\t\t\t(#(1 11) includes: n)
\t\t\t\tifTrue: [ #one ]
\t\t\t\tifFalse: [ (#(2 12) includes: n)
\t\t\t\t\tifTrue: [ #two ]
\t\t\t\t\tifFalse: [ ((n >= 3 and: [ n <= 10 ]) or: [ n >= 13 and: [ n <= 19 ] ])
\t\t\t\t\t\tifTrue: [ #few ]
\t\t\t\t\t\tifFalse: [ #other ] ] ] ]""",
    "ga": """\
[ :n |
\t\t\tn = 1
\t\t\t\tifTrue: [ #one ]
\t\t\t\tifFalse: [ n = 2
\t\t\t\t\tifTrue: [ #two ]
\t\t\t\t\tifFalse: [ (n >= 3 and: [ n <= 6 ])
\t\t\t\t\t\tifTrue: [ #few ]
\t\t\t\t\t\tifFalse: [ (n >= 7 and: [ n <= 10 ])
\t\t\t\t\t\t\tifTrue: [ #many ]
\t\t\t\t\t\t\tifFalse: [ #other ] ] ] ] ]""",
    "mt": """\
[ :n |
\t\t\tn = 1
\t\t\t\tifTrue: [ #one ]
\t\t\t\tifFalse: [ n = 2
\t\t\t\t\tifTrue: [ #two ]
\t\t\t\t\tifFalse: [
\t\t\t\t\t\t| mod100 |
\t\t\t\t\t\tmod100 := n \\\\ 100.
\t\t\t\t\t\t(n = 0 or: [ mod100 >= 3 and: [ mod100 <= 10 ] ])
\t\t\t\t\t\t\tifTrue: [ #few ]
\t\t\t\t\t\t\tifFalse: [ (mod100 >= 11 and: [ mod100 <= 19 ])
\t\t\t\t\t\t\t\tifTrue: [ #many ]
\t\t\t\t\t\t\t\tifFalse: [ #other ] ] ] ] ]""",
    "br": """\
[ :n |
\t\t\t| mod10 mod100 |
\t\t\tmod10 := n \\\\ 10.
\t\t\tmod100 := n \\\\ 100.
\t\t\t(mod10 = 1 and: [ mod100 ~= 11 and: [ mod100 ~= 71 and: [ mod100 ~= 91 ] ] ])
\t\t\t\tifTrue: [ #one ]
\t\t\t\tifFalse: [ (mod10 = 2 and: [ mod100 ~= 12 and: [ mod100 ~= 72 and: [ mod100 ~= 92 ] ] ])
\t\t\t\t\tifTrue: [ #two ]
\t\t\t\t\tifFalse: [ ((#(3 4 9) includes: mod10) and: [ (mod100 >= 10 and: [ mod100 <= 19 ]) not and: [ (mod100 >= 70 and: [ mod100 <= 79 ]) not and: [ (mod100 >= 90 and: [ mod100 <= 99 ]) not ] ] ])
\t\t\t\t\t\tifTrue: [ #few ]
\t\t\t\t\t\tifFalse: [ (n ~= 0 and: [ n \\\\ 1000000 = 0 ])
\t\t\t\t\t\t\tifTrue: [ #many ]
\t\t\t\t\t\t\tifFalse: [ #other ] ] ] ] ]""",
    "kw": """\
[ :n |
\t\t\tn = 0
\t\t\t\tifTrue: [ #zero ]
\t\t\t\tifFalse: [ n = 1
\t\t\t\t\tifTrue: [ #one ]
\t\t\t\t\tifFalse: [
\t\t\t\t\t\t| mod100 |
\t\t\t\t\t\tmod100 := n \\\\ 100.
\t\t\t\t\t\t(#(2 22 42 62 82) includes: mod100)
\t\t\t\t\t\t\tifTrue: [ #two ]
\t\t\t\t\t\t\tifFalse: [ (#(3 23 43 63 83) includes: mod100)
\t\t\t\t\t\t\t\tifTrue: [ #few ]
\t\t\t\t\t\t\t\tifFalse: [ (n ~= 1 and: [ #(1 21 41 61 81) includes: mod100 ])
\t\t\t\t\t\t\t\t\tifTrue: [ #many ]
\t\t\t\t\t\t\t\t\tifFalse: [ #other ] ] ] ] ] ]""",
    "shi": """\
[ :n |
\t\t\t(n = 0 or: [ n = 1 ])
\t\t\t\tifTrue: [ #one ]
\t\t\t\tifFalse: [ (n >= 2 and: [ n <= 10 ])
\t\t\t\t\tifTrue: [ #few ]
\t\t\t\t\tifFalse: [ #other ] ] ]""",
    "tzm": """\
[ :n |
\t\t\t((n = 0 or: [ n = 1 ]) or: [ n >= 11 and: [ n <= 99 ] ])
\t\t\t\tifTrue: [ #one ]
\t\t\t\tifFalse: [ #other ] ]""",
}


def get_st_plural(rule: str) -> str:
    return _ST[rule]
