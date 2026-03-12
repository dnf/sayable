"""Crystal plural rule definitions for all 23 patterns."""

from __future__ import annotations

_CR = {
    "other_only": "->(n : Int32) { PluralCategory::Other }",
    "one_other": "->(n : Int32) { n == 1 ? PluralCategory::One : PluralCategory::Other }",
    "one_other_zero_one": "->(n : Int32) { (n == 0 || n == 1) ? PluralCategory::One : PluralCategory::Other }",
    "cs_sk": """\
->(n : Int32) {
        if n == 1
          PluralCategory::One
        elsif n >= 2 && n <= 4
          PluralCategory::Few
        else
          PluralCategory::Other
        end
      }""",
    "lt": """\
->(n : Int32) {
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 1 && mod100 != 11
          PluralCategory::One
        elsif mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19)
          PluralCategory::Few
        else
          PluralCategory::Other
        end
      }""",
    "ro": """\
->(n : Int32) {
        if n == 1
          PluralCategory::One
        elsif n == 0 || (n % 100 >= 1 && n % 100 <= 19)
          PluralCategory::Few
        else
          PluralCategory::Other
        end
      }""",
    "slavic_bcs": """\
->(n : Int32) {
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 1 && mod100 != 11
          PluralCategory::One
        elsif mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)
          PluralCategory::Few
        else
          PluralCategory::Other
        end
      }""",
    "pl": """\
->(n : Int32) {
        if n == 1
          PluralCategory::One
        else
          mod10 = n % 10
          mod100 = n % 100
          if mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)
            PluralCategory::Few
          else
            PluralCategory::Many
          end
        end
      }""",
    "ru_uk": """\
->(n : Int32) {
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 1 && mod100 != 11
          PluralCategory::One
        elsif mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)
          PluralCategory::Few
        else
          PluralCategory::Many
        end
      }""",
    "sl": """\
->(n : Int32) {
        mod100 = n % 100
        if mod100 == 1
          PluralCategory::One
        elsif mod100 == 2
          PluralCategory::Two
        elsif mod100 == 3 || mod100 == 4
          PluralCategory::Few
        else
          PluralCategory::Other
        end
      }""",
    "ar": """\
->(n : Int32) {
        if n == 0
          PluralCategory::Zero
        elsif n == 1
          PluralCategory::One
        elsif n == 2
          PluralCategory::Two
        else
          mod100 = n % 100
          if mod100 >= 3 && mod100 <= 10
            PluralCategory::Few
          elsif mod100 >= 11 && mod100 <= 99
            PluralCategory::Many
          else
            PluralCategory::Other
          end
        end
      }""",
    "lv": """\
->(n : Int32) {
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 0 || (mod100 >= 11 && mod100 <= 19)
          PluralCategory::Zero
        elsif mod10 == 1 && mod100 != 11
          PluralCategory::One
        else
          PluralCategory::Other
        end
      }""",
    "he": """\
->(n : Int32) {
        if n == 1
          PluralCategory::One
        elsif n == 2
          PluralCategory::Two
        else
          PluralCategory::Other
        end
      }""",
    "mk": """\
->(n : Int32) {
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 1 && mod100 != 11
          PluralCategory::One
        else
          PluralCategory::Other
        end
      }""",
    "cy": """\
->(n : Int32) {
        if n == 0
          PluralCategory::Zero
        elsif n == 1
          PluralCategory::One
        elsif n == 2
          PluralCategory::Two
        elsif n == 3
          PluralCategory::Few
        elsif n == 6
          PluralCategory::Many
        else
          PluralCategory::Other
        end
      }""",
    "gv": """\
->(n : Int32) {
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 1
          PluralCategory::One
        elsif mod10 == 2
          PluralCategory::Two
        elsif {0, 20, 40, 60, 80}.includes?(mod100)
          PluralCategory::Few
        else
          PluralCategory::Other
        end
      }""",
    "gd": """\
->(n : Int32) {
        if n == 1 || n == 11
          PluralCategory::One
        elsif n == 2 || n == 12
          PluralCategory::Two
        elsif (n >= 3 && n <= 10) || (n >= 13 && n <= 19)
          PluralCategory::Few
        else
          PluralCategory::Other
        end
      }""",
    "ga": """\
->(n : Int32) {
        if n == 1
          PluralCategory::One
        elsif n == 2
          PluralCategory::Two
        elsif n >= 3 && n <= 6
          PluralCategory::Few
        elsif n >= 7 && n <= 10
          PluralCategory::Many
        else
          PluralCategory::Other
        end
      }""",
    "mt": """\
->(n : Int32) {
        if n == 1
          PluralCategory::One
        elsif n == 2
          PluralCategory::Two
        else
          mod100 = n % 100
          if n == 0 || (mod100 >= 3 && mod100 <= 10)
            PluralCategory::Few
          elsif mod100 >= 11 && mod100 <= 19
            PluralCategory::Many
          else
            PluralCategory::Other
          end
        end
      }""",
    "br": """\
->(n : Int32) {
        mod10 = n % 10
        mod100 = n % 100
        if mod10 == 1 && mod100 != 11 && mod100 != 71 && mod100 != 91
          PluralCategory::One
        elsif mod10 == 2 && mod100 != 12 && mod100 != 72 && mod100 != 92
          PluralCategory::Two
        elsif {3, 4, 9}.includes?(mod10) && !(mod100 >= 10 && mod100 <= 19) && !(mod100 >= 70 && mod100 <= 79) && !(mod100 >= 90 && mod100 <= 99)
          PluralCategory::Few
        elsif n != 0 && n % 1000000 == 0
          PluralCategory::Many
        else
          PluralCategory::Other
        end
      }""",
    "kw": """\
->(n : Int32) {
        if n == 0
          PluralCategory::Zero
        elsif n == 1
          PluralCategory::One
        else
          mod100 = n % 100
          if {2, 22, 42, 62, 82}.includes?(mod100)
            PluralCategory::Two
          elsif {3, 23, 43, 63, 83}.includes?(mod100)
            PluralCategory::Few
          elsif n != 1 && {1, 21, 41, 61, 81}.includes?(mod100)
            PluralCategory::Many
          else
            PluralCategory::Other
          end
        end
      }""",
    "shi": """\
->(n : Int32) {
        if n == 0 || n == 1
          PluralCategory::One
        elsif n >= 2 && n <= 10
          PluralCategory::Few
        else
          PluralCategory::Other
        end
      }""",
    "tzm": """\
->(n : Int32) {
        if n == 0 || n == 1 || (n >= 11 && n <= 99)
          PluralCategory::One
        else
          PluralCategory::Other
        end
      }""",
}


def get_cr_plural(rule: str) -> str:
    return _CR[rule]
