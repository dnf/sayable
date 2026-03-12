"""Prolog plural rule definitions for all 23 CLDR patterns.

Each rule returns Prolog clause bodies for plural(N, Category) predicates.
"""

from __future__ import annotations

_PL = {
    "other_only": "plural(_, other).",

    "one_other": """plural(1, one) :- !.
plural(_, other).""",

    "one_other_zero_one": """plural(0, one) :- !.
plural(1, one) :- !.
plural(_, other).""",

    "cs_sk": """plural(1, one) :- !.
plural(N, few) :- N >= 2, N =< 4, !.
plural(_, other).""",

    "lt": """plural(N, one) :- Mod10 is N mod 10, Mod100 is N mod 100, Mod10 =:= 1, Mod100 =\\= 11, !.
plural(N, few) :- Mod10 is N mod 10, Mod100 is N mod 100, Mod10 >= 2, Mod10 =< 9, (Mod100 < 12 ; Mod100 > 19), !.
plural(_, other).""",

    "ro": """plural(1, one) :- !.
plural(N, few) :- (N =:= 0 ; (Mod100 is N mod 100, Mod100 >= 1, Mod100 =< 19)), !.
plural(_, other).""",

    "slavic_bcs": """plural(N, one) :- Mod10 is N mod 10, Mod100 is N mod 100, Mod10 =:= 1, Mod100 =\\= 11, !.
plural(N, few) :- Mod10 is N mod 10, Mod100 is N mod 100, Mod10 >= 2, Mod10 =< 4, (Mod100 < 12 ; Mod100 > 14), !.
plural(_, other).""",

    "pl": """plural(1, one) :- !.
plural(N, few) :- Mod10 is N mod 10, Mod100 is N mod 100, Mod10 >= 2, Mod10 =< 4, (Mod100 < 12 ; Mod100 > 14), !.
plural(_, many).""",

    "ru_uk": """plural(N, one) :- Mod10 is N mod 10, Mod100 is N mod 100, Mod10 =:= 1, Mod100 =\\= 11, !.
plural(N, few) :- Mod10 is N mod 10, Mod100 is N mod 100, Mod10 >= 2, Mod10 =< 4, (Mod100 < 12 ; Mod100 > 14), !.
plural(_, many).""",

    "sl": """plural(N, one) :- Mod100 is N mod 100, Mod100 =:= 1, !.
plural(N, two) :- Mod100 is N mod 100, Mod100 =:= 2, !.
plural(N, few) :- Mod100 is N mod 100, (Mod100 =:= 3 ; Mod100 =:= 4), !.
plural(_, other).""",

    "ar": """plural(0, zero) :- !.
plural(1, one) :- !.
plural(2, two) :- !.
plural(N, few) :- Mod100 is N mod 100, Mod100 >= 3, Mod100 =< 10, !.
plural(N, many) :- Mod100 is N mod 100, Mod100 >= 11, Mod100 =< 99, !.
plural(_, other).""",

    "lv": """plural(N, zero) :- Mod10 is N mod 10, Mod100 is N mod 100, (Mod10 =:= 0 ; (Mod100 >= 11, Mod100 =< 19)), !.
plural(N, one) :- Mod10 is N mod 10, Mod100 is N mod 100, Mod10 =:= 1, Mod100 =\\= 11, !.
plural(_, other).""",

    "he": """plural(1, one) :- !.
plural(2, two) :- !.
plural(_, other).""",

    "mk": """plural(N, one) :- Mod10 is N mod 10, Mod100 is N mod 100, Mod10 =:= 1, Mod100 =\\= 11, !.
plural(_, other).""",

    "cy": """plural(0, zero) :- !.
plural(1, one) :- !.
plural(2, two) :- !.
plural(3, few) :- !.
plural(6, many) :- !.
plural(_, other).""",

    "gv": """plural(N, one) :- Mod10 is N mod 10, Mod10 =:= 1, !.
plural(N, two) :- Mod10 is N mod 10, Mod10 =:= 2, !.
plural(N, few) :- Mod100 is N mod 100, member(Mod100, [0, 20, 40, 60, 80]), !.
plural(_, other).""",

    "gd": """plural(N, one) :- (N =:= 1 ; N =:= 11), !.
plural(N, two) :- (N =:= 2 ; N =:= 12), !.
plural(N, few) :- (N >= 3, N =< 10 ; N >= 13, N =< 19), !.
plural(_, other).""",

    "ga": """plural(1, one) :- !.
plural(2, two) :- !.
plural(N, few) :- N >= 3, N =< 6, !.
plural(N, many) :- N >= 7, N =< 10, !.
plural(_, other).""",

    "mt": """plural(1, one) :- !.
plural(2, two) :- !.
plural(N, few) :- Mod100 is N mod 100, (N =:= 0 ; (Mod100 >= 3, Mod100 =< 10)), !.
plural(N, many) :- Mod100 is N mod 100, Mod100 >= 11, Mod100 =< 19, !.
plural(_, other).""",

    "br": """plural(N, one) :- Mod10 is N mod 10, Mod100 is N mod 100, Mod10 =:= 1, \\+ member(Mod100, [11, 71, 91]), !.
plural(N, two) :- Mod10 is N mod 10, Mod100 is N mod 100, Mod10 =:= 2, \\+ member(Mod100, [12, 72, 92]), !.
plural(N, few) :- Mod10 is N mod 10, Mod100 is N mod 100, member(Mod10, [3, 4, 9]), \\+ (Mod100 >= 10, Mod100 =< 19), \\+ (Mod100 >= 70, Mod100 =< 79), \\+ (Mod100 >= 90, Mod100 =< 99), !.
plural(N, many) :- N =\\= 0, 0 is N mod 1000000, !.
plural(_, other).""",

    "kw": """plural(0, zero) :- !.
plural(1, one) :- !.
plural(N, two) :- Mod100 is N mod 100, member(Mod100, [2, 22, 42, 62, 82]), !.
plural(N, few) :- Mod100 is N mod 100, member(Mod100, [3, 23, 43, 63, 83]), !.
plural(N, many) :- N =\\= 1, Mod100 is N mod 100, member(Mod100, [1, 21, 41, 61, 81]), !.
plural(_, other).""",

    "shi": """plural(N, one) :- (N =:= 0 ; N =:= 1), !.
plural(N, few) :- N >= 2, N =< 10, !.
plural(_, other).""",

    "tzm": """plural(N, one) :- (N =:= 0 ; N =:= 1 ; (N >= 11, N =< 99)), !.
plural(_, other).""",
}


def get_pl_plural(rule: str) -> str:
    """Get Prolog plural clauses for a given rule name."""
    return _PL[rule]
