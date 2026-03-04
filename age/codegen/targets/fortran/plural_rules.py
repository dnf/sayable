"""Fortran plural rule definitions for all 23 CLDR cardinal patterns."""

from __future__ import annotations

_FORTRAN = {
    "other_only": """\
    if (n >= 0) then
      pt_cat = PT_OTHER
    else
      pt_cat = PT_OTHER
    end if""",
    "one_other": """\
    if (n == 1) then
      pt_cat = PT_ONE
    else
      pt_cat = PT_OTHER
    end if""",
    "one_other_zero_one": """\
    if (n == 0 .or. n == 1) then
      pt_cat = PT_ONE
    else
      pt_cat = PT_OTHER
    end if""",
    "cs_sk": """\
    if (n == 1) then
      pt_cat = PT_ONE
    else if (n >= 2 .and. n <= 4) then
      pt_cat = PT_FEW
    else
      pt_cat = PT_OTHER
    end if""",
    "lt": """\
    mod10 = mod(n, 10)
    mod100 = mod(n, 100)
    if (mod10 == 1 .and. mod100 /= 11) then
      pt_cat = PT_ONE
    else if (mod10 >= 2 .and. mod10 <= 9 .and. (mod100 < 12 .or. mod100 > 19)) then
      pt_cat = PT_FEW
    else
      pt_cat = PT_OTHER
    end if""",
    "ro": """\
    if (n == 1) then
      pt_cat = PT_ONE
    else if (n == 0 .or. (mod(n, 100) >= 1 .and. mod(n, 100) <= 19)) then
      pt_cat = PT_FEW
    else
      pt_cat = PT_OTHER
    end if""",
    "slavic_bcs": """\
    mod10 = mod(n, 10)
    mod100 = mod(n, 100)
    if (mod10 == 1 .and. mod100 /= 11) then
      pt_cat = PT_ONE
    else if (mod10 >= 2 .and. mod10 <= 4 .and. (mod100 < 12 .or. mod100 > 14)) then
      pt_cat = PT_FEW
    else
      pt_cat = PT_OTHER
    end if""",
    "pl": """\
    mod10 = mod(n, 10)
    mod100 = mod(n, 100)
    if (n == 1) then
      pt_cat = PT_ONE
    else if (mod10 >= 2 .and. mod10 <= 4 .and. (mod100 < 12 .or. mod100 > 14)) then
      pt_cat = PT_FEW
    else
      pt_cat = PT_MANY
    end if""",
    "ru_uk": """\
    mod10 = mod(n, 10)
    mod100 = mod(n, 100)
    if (mod10 == 1 .and. mod100 /= 11) then
      pt_cat = PT_ONE
    else if (mod10 >= 2 .and. mod10 <= 4 .and. (mod100 < 12 .or. mod100 > 14)) then
      pt_cat = PT_FEW
    else
      pt_cat = PT_MANY
    end if""",
    "sl": """\
    mod100 = mod(n, 100)
    if (mod100 == 1) then
      pt_cat = PT_ONE
    else if (mod100 == 2) then
      pt_cat = PT_TWO
    else if (mod100 == 3 .or. mod100 == 4) then
      pt_cat = PT_FEW
    else
      pt_cat = PT_OTHER
    end if""",
    "ar": """\
    if (n == 0) then
      pt_cat = PT_ZERO
    else if (n == 1) then
      pt_cat = PT_ONE
    else if (n == 2) then
      pt_cat = PT_TWO
    else
      mod100 = mod(n, 100)
      if (mod100 >= 3 .and. mod100 <= 10) then
        pt_cat = PT_FEW
      else if (mod100 >= 11 .and. mod100 <= 99) then
        pt_cat = PT_MANY
      else
        pt_cat = PT_OTHER
      end if
    end if""",
    "lv": """\
    mod10 = mod(n, 10)
    mod100 = mod(n, 100)
    if (mod10 == 0 .or. (mod100 >= 11 .and. mod100 <= 19)) then
      pt_cat = PT_ZERO
    else if (mod10 == 1 .and. mod100 /= 11) then
      pt_cat = PT_ONE
    else
      pt_cat = PT_OTHER
    end if""",
    "he": """\
    if (n == 1) then
      pt_cat = PT_ONE
    else if (n == 2) then
      pt_cat = PT_TWO
    else
      pt_cat = PT_OTHER
    end if""",
    "mk": """\
    mod10 = mod(n, 10)
    mod100 = mod(n, 100)
    if (mod10 == 1 .and. mod100 /= 11) then
      pt_cat = PT_ONE
    else
      pt_cat = PT_OTHER
    end if""",
    "cy": """\
    if (n == 0) then
      pt_cat = PT_ZERO
    else if (n == 1) then
      pt_cat = PT_ONE
    else if (n == 2) then
      pt_cat = PT_TWO
    else if (n == 3) then
      pt_cat = PT_FEW
    else if (n == 6) then
      pt_cat = PT_MANY
    else
      pt_cat = PT_OTHER
    end if""",
    "gv": """\
    mod10 = mod(n, 10)
    mod100 = mod(n, 100)
    if (mod10 == 1) then
      pt_cat = PT_ONE
    else if (mod10 == 2) then
      pt_cat = PT_TWO
    else if (mod100 == 0 .or. mod100 == 20 .or. mod100 == 40 .or. mod100 == 60 .or. mod100 == 80) then
      pt_cat = PT_FEW
    else
      pt_cat = PT_OTHER
    end if""",
    "gd": """\
    if (n == 1 .or. n == 11) then
      pt_cat = PT_ONE
    else if (n == 2 .or. n == 12) then
      pt_cat = PT_TWO
    else if ((n >= 3 .and. n <= 10) .or. (n >= 13 .and. n <= 19)) then
      pt_cat = PT_FEW
    else
      pt_cat = PT_OTHER
    end if""",
    "ga": """\
    if (n == 1) then
      pt_cat = PT_ONE
    else if (n == 2) then
      pt_cat = PT_TWO
    else if (n >= 3 .and. n <= 6) then
      pt_cat = PT_FEW
    else if (n >= 7 .and. n <= 10) then
      pt_cat = PT_MANY
    else
      pt_cat = PT_OTHER
    end if""",
    "mt": """\
    if (n == 1) then
      pt_cat = PT_ONE
    else if (n == 2) then
      pt_cat = PT_TWO
    else
      mod100 = mod(n, 100)
      if (n == 0 .or. (mod100 >= 3 .and. mod100 <= 10)) then
        pt_cat = PT_FEW
      else if (mod100 >= 11 .and. mod100 <= 19) then
        pt_cat = PT_MANY
      else
        pt_cat = PT_OTHER
      end if
    end if""",
    "br": """\
    mod10 = mod(n, 10)
    mod100 = mod(n, 100)
    if (mod10 == 1 .and. mod100 /= 11 .and. mod100 /= 71 .and. mod100 /= 91) then
      pt_cat = PT_ONE
    else if (mod10 == 2 .and. mod100 /= 12 .and. mod100 /= 72 .and. mod100 /= 92) then
      pt_cat = PT_TWO
    else if ((mod10 == 3 .or. mod10 == 4 .or. mod10 == 9) .and. &
             .not. (mod100 >= 10 .and. mod100 <= 19) .and. &
             .not. (mod100 >= 70 .and. mod100 <= 79) .and. &
             .not. (mod100 >= 90 .and. mod100 <= 99)) then
      pt_cat = PT_FEW
    else if (n /= 0 .and. mod(n, 1000000) == 0) then
      pt_cat = PT_MANY
    else
      pt_cat = PT_OTHER
    end if""",
    "kw": """\
    mod100 = mod(n, 100)
    if (n == 0) then
      pt_cat = PT_ZERO
    else if (n == 1) then
      pt_cat = PT_ONE
    else if (mod100 == 2 .or. mod100 == 22 .or. mod100 == 42 .or. mod100 == 62 .or. mod100 == 82) then
      pt_cat = PT_TWO
    else if (mod100 == 3 .or. mod100 == 23 .or. mod100 == 43 .or. mod100 == 63 .or. mod100 == 83) then
      pt_cat = PT_FEW
    else if (n /= 1 .and. (mod100 == 1 .or. mod100 == 21 .or. mod100 == 41 .or. &
             mod100 == 61 .or. mod100 == 81)) then
      pt_cat = PT_MANY
    else
      pt_cat = PT_OTHER
    end if""",
    "shi": """\
    if (n == 0 .or. n == 1) then
      pt_cat = PT_ONE
    else if (n >= 2 .and. n <= 10) then
      pt_cat = PT_FEW
    else
      pt_cat = PT_OTHER
    end if""",
    "tzm": """\
    if (n == 0 .or. n == 1 .or. (n >= 11 .and. n <= 99)) then
      pt_cat = PT_ONE
    else
      pt_cat = PT_OTHER
    end if""",
}


def get_fortran_plural(rule: str) -> str:
    return _FORTRAN[rule]
