"""Ruby plural rule definitions for all 23 patterns."""

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
    "cy": """\
lambda { |n|
        if n == 0 then :zero
        elsif n == 1 then :one
        elsif n == 2 then :two
        elsif n == 3 then :few
        elsif n == 6 then :many
        else :other
        end
      }""",
    "gv": """\
lambda { |n|
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 1 then :one
        elsif mod10 == 2 then :two
        elsif [0, 20, 40, 60, 80].include?(mod100) then :few
        else :other
        end
      }""",
    "gd": """\
lambda { |n|
        if [1, 11].include?(n) then :one
        elsif [2, 12].include?(n) then :two
        elsif (n >= 3 && n <= 10) || (n >= 13 && n <= 19) then :few
        else :other
        end
      }""",
    "ga": """\
lambda { |n|
        if n == 1 then :one
        elsif n == 2 then :two
        elsif n >= 3 && n <= 6 then :few
        elsif n >= 7 && n <= 10 then :many
        else :other
        end
      }""",
    "mt": """\
lambda { |n|
        if n == 1 then :one
        elsif n == 2 then :two
        else
          mod100 = n % 100
          if n == 0 || (mod100 >= 3 && mod100 <= 10) then :few
          elsif mod100 >= 11 && mod100 <= 19 then :many
          else :other
          end
        end
      }""",
    "br": """\
lambda { |n|
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 1 && mod100 != 11 && mod100 != 71 && mod100 != 91 then :one
        elsif mod10 == 2 && mod100 != 12 && mod100 != 72 && mod100 != 92 then :two
        elsif [3, 4, 9].include?(mod10) && !(mod100 >= 10 && mod100 <= 19) && !(mod100 >= 70 && mod100 <= 79) && !(mod100 >= 90 && mod100 <= 99) then :few
        elsif n != 0 && n % 1000000 == 0 then :many
        else :other
        end
      }""",
    "kw": """\
lambda { |n|
        if n == 0 then :zero
        elsif n == 1 then :one
        else
          mod100 = n % 100
          if [2, 22, 42, 62, 82].include?(mod100) then :two
          elsif [3, 23, 43, 63, 83].include?(mod100) then :few
          elsif n != 1 && [1, 21, 41, 61, 81].include?(mod100) then :many
          else :other
          end
        end
      }""",
    "shi": """\
lambda { |n|
        if [0, 1].include?(n) then :one
        elsif n >= 2 && n <= 10 then :few
        else :other
        end
      }""",
    "tzm": """\
lambda { |n|
        if [0, 1].include?(n) || (n >= 11 && n <= 99) then :one
        else :other
        end
      }""",
}


def get_rb_plural(rule: str) -> str:
    return _RB[rule]
