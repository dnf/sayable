"""Elixir plural rule definitions for all 23 patterns.

Each rule is written exactly as `mix format` lays it out at column 0, so the
generated locale files are already formatted: multi-clause `fn`s break one
clause per line, and clauses too long for the 98-column limit (at the
locale map's indent) put their body on its own line.
"""

from __future__ import annotations

_EX = {
    "other_only": "fn _ -> :other end",
    "one_other": """\
fn
  1 -> :one
  _ -> :other
end""",
    "one_other_zero_one": """\
fn
  n when n in [0, 1] -> :one
  _ -> :other
end""",
    "cs_sk": """\
fn
  1 -> :one
  n when n >= 2 and n <= 4 -> :few
  _ -> :other
end""",
    "lt": """\
fn
  n when rem(n, 10) == 1 and rem(n, 100) != 11 ->
    :one

  n when rem(n, 10) >= 2 and rem(n, 10) <= 9 and (rem(n, 100) < 12 or rem(n, 100) > 19) ->
    :few

  _ ->
    :other
end""",
    "ro": """\
fn
  1 -> :one
  n when n == 0 or (rem(n, 100) >= 1 and rem(n, 100) <= 19) -> :few
  _ -> :other
end""",
    "slavic_bcs": """\
fn
  n when rem(n, 10) == 1 and rem(n, 100) != 11 ->
    :one

  n when rem(n, 10) >= 2 and rem(n, 10) <= 4 and (rem(n, 100) < 12 or rem(n, 100) > 14) ->
    :few

  _ ->
    :other
end""",
    "pl": """\
fn
  1 ->
    :one

  n when rem(n, 10) >= 2 and rem(n, 10) <= 4 and (rem(n, 100) < 12 or rem(n, 100) > 14) ->
    :few

  _ ->
    :many
end""",
    "ru_uk": """\
fn
  n when rem(n, 10) == 1 and rem(n, 100) != 11 ->
    :one

  n when rem(n, 10) >= 2 and rem(n, 10) <= 4 and (rem(n, 100) < 12 or rem(n, 100) > 14) ->
    :few

  _ ->
    :many
end""",
    "sl": """\
fn
  n when rem(n, 100) == 1 -> :one
  n when rem(n, 100) == 2 -> :two
  n when rem(n, 100) == 3 or rem(n, 100) == 4 -> :few
  _ -> :other
end""",
    "ar": """\
fn
  0 -> :zero
  1 -> :one
  2 -> :two
  n when rem(n, 100) >= 3 and rem(n, 100) <= 10 -> :few
  n when rem(n, 100) >= 11 and rem(n, 100) <= 99 -> :many
  _ -> :other
end""",
    "lv": """\
fn
  n when rem(n, 10) == 0 or (rem(n, 100) >= 11 and rem(n, 100) <= 19) -> :zero
  n when rem(n, 10) == 1 and rem(n, 100) != 11 -> :one
  _ -> :other
end""",
    "he": """\
fn
  1 -> :one
  2 -> :two
  _ -> :other
end""",
    "mk": """\
fn
  n when rem(n, 10) == 1 and rem(n, 100) != 11 -> :one
  _ -> :other
end""",
    "cy": """\
fn
  0 -> :zero
  1 -> :one
  2 -> :two
  3 -> :few
  6 -> :many
  _ -> :other
end""",
    "gv": """\
fn
  n when rem(n, 10) == 1 -> :one
  n when rem(n, 10) == 2 -> :two
  n when rem(n, 100) in [0, 20, 40, 60, 80] -> :few
  _ -> :other
end""",
    "gd": """\
fn
  n when n in [1, 11] -> :one
  n when n in [2, 12] -> :two
  n when (n >= 3 and n <= 10) or (n >= 13 and n <= 19) -> :few
  _ -> :other
end""",
    "ga": """\
fn
  1 -> :one
  2 -> :two
  n when n >= 3 and n <= 6 -> :few
  n when n >= 7 and n <= 10 -> :many
  _ -> :other
end""",
    "mt": """\
fn
  1 -> :one
  2 -> :two
  n when n == 0 or (rem(n, 100) >= 3 and rem(n, 100) <= 10) -> :few
  n when rem(n, 100) >= 11 and rem(n, 100) <= 19 -> :many
  _ -> :other
end""",
    "br": """\
fn
  n
  when rem(n, 10) == 1 and rem(n, 100) != 11 and rem(n, 100) != 71 and rem(n, 100) != 91 ->
    :one

  n
  when rem(n, 10) == 2 and rem(n, 100) != 12 and rem(n, 100) != 72 and rem(n, 100) != 92 ->
    :two

  n
  when rem(n, 10) in [3, 4, 9] and (rem(n, 100) < 10 or rem(n, 100) > 19) and
         (rem(n, 100) < 70 or rem(n, 100) > 79) and (rem(n, 100) < 90 or rem(n, 100) > 99) ->
    :few

  n when n != 0 and rem(n, 1_000_000) == 0 ->
    :many

  _ ->
    :other
end""",
    "kw": """\
fn
  0 -> :zero
  1 -> :one
  n when rem(n, 100) in [2, 22, 42, 62, 82] -> :two
  n when rem(n, 100) in [3, 23, 43, 63, 83] -> :few
  n when n != 1 and rem(n, 100) in [1, 21, 41, 61, 81] -> :many
  _ -> :other
end""",
    "shi": """\
fn
  n when n in [0, 1] -> :one
  n when n >= 2 and n <= 10 -> :few
  _ -> :other
end""",
    "tzm": """\
fn
  n when n in [0, 1] or (n >= 11 and n <= 99) -> :one
  _ -> :other
end""",
}


def get_ex_plural(rule: str, indent: str = "") -> str:
    """Return the Elixir expression for the given plural rule name.

    Lines after the first are indented by ``indent`` (blank lines stay empty),
    so the expression can follow a key at that indent.
    """
    lines = _EX[rule].split("\n")
    return "\n".join([lines[0]] + [indent + line if line else "" for line in lines[1:]])
