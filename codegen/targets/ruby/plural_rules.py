"""Ruby plural rule definitions for all 14 patterns."""

from __future__ import annotations

_RB = {
    "other_only": "->(n) { :other }",
    "one_other": "->(n) { n == 1 ? :one : :other }",
    "one_other_zero_one": "->(n) { [0, 1].include?(n) ? :one : :other }",
    "cs_sk": """\
lambda { |n|
        if n == 1 then :one
        elsif n >= 2 && n <= 4 then :few
        else :other
        end
      }""",
    "lt": """\
lambda { |n|
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 1 && mod100 != 11 then :one
        elsif mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19) then :few
        else :other
        end
      }""",
    "ro": """\
lambda { |n|
        if n == 1 then :one
        elsif n == 0 || (n % 100 >= 1 && n % 100 <= 19) then :few
        else :other
        end
      }""",
    "slavic_bcs": """\
lambda { |n|
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 1 && mod100 != 11 then :one
        elsif mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) then :few
        else :other
        end
      }""",
    "pl": """\
lambda { |n|
        if n == 1 then :one
        else
          mod10 = n % 10
          mod100 = n % 100
          if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) then :few
          else :many
          end
        end
      }""",
    "ru_uk": """\
lambda { |n|
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 1 && mod100 != 11 then :one
        elsif mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14) then :few
        else :many
        end
      }""",
    "sl": """\
lambda { |n|
        mod100 = n % 100
        if mod100 == 1 then :one
        elsif mod100 == 2 then :two
        elsif mod100 == 3 || mod100 == 4 then :few
        else :other
        end
      }""",
    "ar": """\
lambda { |n|
        if n == 0 then :zero
        elsif n == 1 then :one
        elsif n == 2 then :two
        else
          mod100 = n % 100
          if mod100 >= 3 && mod100 <= 10 then :few
          elsif mod100 >= 11 && mod100 <= 99 then :many
          else :other
          end
        end
      }""",
    "lv": """\
lambda { |n|
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 0 || (mod100 >= 11 && mod100 <= 19) then :zero
        elsif mod10 == 1 && mod100 != 11 then :one
        else :other
        end
      }""",
    "he": """\
lambda { |n|
        if n == 1 then :one
        elsif n == 2 then :two
        else :other
        end
      }""",
    "mk": """\
lambda { |n|
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 1 && mod100 != 11 then :one
        else :other
        end
      }""",
}


def get_rb_plural(rule: str) -> str:
    return _RB[rule]
