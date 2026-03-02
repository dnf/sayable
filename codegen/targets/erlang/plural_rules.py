"""Erlang plural rule definitions for all 23 patterns."""

from __future__ import annotations

_ERL = {
    "other_only": "fun(_) -> other end",
    "one_other": "fun(1) -> one; (_) -> other end",
    "one_other_zero_one": "fun(N) when N =:= 0; N =:= 1 -> one; (_) -> other end",
    "cs_sk": "fun(1) -> one; (N) when N >= 2, N =< 4 -> few; (_) -> other end",
    "lt": "fun(N) when N rem 10 =:= 1, N rem 100 =/= 11 -> one; (N) when N rem 10 >= 2, N rem 10 =< 9, (N rem 100 < 12 orelse N rem 100 > 19) -> few; (_) -> other end",
    "ro": "fun(1) -> one; (N) when N =:= 0; N rem 100 >= 1, N rem 100 =< 19 -> few; (_) -> other end",
    "slavic_bcs": "fun(N) when N rem 10 =:= 1, N rem 100 =/= 11 -> one; (N) when N rem 10 >= 2, N rem 10 =< 4, (N rem 100 < 12 orelse N rem 100 > 14) -> few; (_) -> other end",
    "pl": "fun(1) -> one; (N) when N rem 10 >= 2, N rem 10 =< 4, (N rem 100 < 12 orelse N rem 100 > 14) -> few; (_) -> many end",
    "ru_uk": "fun(N) when N rem 10 =:= 1, N rem 100 =/= 11 -> one; (N) when N rem 10 >= 2, N rem 10 =< 4, (N rem 100 < 12 orelse N rem 100 > 14) -> few; (_) -> many end",
    "sl": "fun(N) when N rem 100 =:= 1 -> one; (N) when N rem 100 =:= 2 -> two; (N) when N rem 100 =:= 3; N rem 100 =:= 4 -> few; (_) -> other end",
    "ar": "fun(0) -> zero; (1) -> one; (2) -> two; (N) when N rem 100 >= 3, N rem 100 =< 10 -> few; (N) when N rem 100 >= 11, N rem 100 =< 99 -> many; (_) -> other end",
    "lv": "fun(N) when N rem 10 =:= 0; N rem 100 >= 11, N rem 100 =< 19 -> zero; (N) when N rem 10 =:= 1, N rem 100 =/= 11 -> one; (_) -> other end",
    "he": "fun(1) -> one; (2) -> two; (_) -> other end",
    "mk": "fun(N) when N rem 10 =:= 1, N rem 100 =/= 11 -> one; (_) -> other end",
    "cy": "fun(0) -> zero; (1) -> one; (2) -> two; (3) -> few; (6) -> many; (_) -> other end",
    "gv": "fun(N) when N rem 10 =:= 1 -> one; (N) when N rem 10 =:= 2 -> two; (N) when N rem 100 =:= 0; N rem 100 =:= 20; N rem 100 =:= 40; N rem 100 =:= 60; N rem 100 =:= 80 -> few; (_) -> other end",
    "gd": "fun(N) when N =:= 1; N =:= 11 -> one; (N) when N =:= 2; N =:= 12 -> two; (N) when N >= 3, N =< 10 -> few; (N) when N >= 13, N =< 19 -> few; (_) -> other end",
    "ga": "fun(1) -> one; (2) -> two; (N) when N >= 3, N =< 6 -> few; (N) when N >= 7, N =< 10 -> many; (_) -> other end",
    "mt": "fun(1) -> one; (2) -> two; (N) when N =:= 0; N rem 100 >= 3, N rem 100 =< 10 -> few; (N) when N rem 100 >= 11, N rem 100 =< 19 -> many; (_) -> other end",
    "br": "fun(N) when N rem 10 =:= 1, N rem 100 =/= 11, N rem 100 =/= 71, N rem 100 =/= 91 -> one; (N) when N rem 10 =:= 2, N rem 100 =/= 12, N rem 100 =/= 72, N rem 100 =/= 92 -> two; (N) when (N rem 10 =:= 3 orelse N rem 10 =:= 4 orelse N rem 10 =:= 9), (N rem 100 < 10 orelse N rem 100 > 19), (N rem 100 < 70 orelse N rem 100 > 79), (N rem 100 < 90 orelse N rem 100 > 99) -> few; (N) when N =/= 0, N rem 1000000 =:= 0 -> many; (_) -> other end",
    "kw": "fun(0) -> zero; (1) -> one; (N) when N rem 100 =:= 2; N rem 100 =:= 22; N rem 100 =:= 42; N rem 100 =:= 62; N rem 100 =:= 82 -> two; (N) when N rem 100 =:= 3; N rem 100 =:= 23; N rem 100 =:= 43; N rem 100 =:= 63; N rem 100 =:= 83 -> few; (N) when N =/= 1, (N rem 100 =:= 1 orelse N rem 100 =:= 21 orelse N rem 100 =:= 41 orelse N rem 100 =:= 61 orelse N rem 100 =:= 81) -> many; (_) -> other end",
    "shi": "fun(N) when N =:= 0; N =:= 1 -> one; (N) when N >= 2, N =< 10 -> few; (_) -> other end",
    "tzm": "fun(N) when N =:= 0; N =:= 1; N >= 11, N =< 99 -> one; (_) -> other end",
}


def get_erl_plural(rule: str) -> str:
    """Return the Erlang expression for the given plural rule name."""
    return _ERL[rule]
