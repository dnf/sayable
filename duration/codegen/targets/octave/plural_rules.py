"""Octave plural rule definitions for all 23 patterns."""

from __future__ import annotations

_OCTAVE = {
    "other_only": '@(n) "other"',
    "one_other": '@(n) ifelse(n == 1, "one", "other")',
    "one_other_zero_one": '@(n) ifelse(n == 0 || n == 1, "one", "other")',
}

_OCTAVE_NAMED = {
    "cs_sk": '''\
function cat = plural(n)
  if (n == 1)
    cat = "one";
  elseif (n >= 2 && n <= 4)
    cat = "few";
  else
    cat = "other";
  endif
endfunction''',
    "lt": '''\
function cat = plural(n)
  mod10 = mod(n, 10);
  mod100 = mod(n, 100);
  if (mod10 == 1 && mod100 != 11)
    cat = "one";
  elseif (mod10 >= 2 && mod10 <= 9 && (mod100 < 12 || mod100 > 19))
    cat = "few";
  else
    cat = "other";
  endif
endfunction''',
    "ro": '''\
function cat = plural(n)
  if (n == 1)
    cat = "one";
  elseif (n == 0 || (mod(n, 100) >= 1 && mod(n, 100) <= 19))
    cat = "few";
  else
    cat = "other";
  endif
endfunction''',
    "slavic_bcs": '''\
function cat = plural(n)
  mod10 = mod(n, 10);
  mod100 = mod(n, 100);
  if (mod10 == 1 && mod100 != 11)
    cat = "one";
  elseif (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14))
    cat = "few";
  else
    cat = "other";
  endif
endfunction''',
    "pl": '''\
function cat = plural(n)
  if (n == 1)
    cat = "one";
  else
    mod10 = mod(n, 10);
    mod100 = mod(n, 100);
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14))
      cat = "few";
    else
      cat = "many";
    endif
  endif
endfunction''',
    "ru_uk": '''\
function cat = plural(n)
  mod10 = mod(n, 10);
  mod100 = mod(n, 100);
  if (mod10 == 1 && mod100 != 11)
    cat = "one";
  elseif (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14))
    cat = "few";
  else
    cat = "many";
  endif
endfunction''',
    "sl": '''\
function cat = plural(n)
  mod100 = mod(n, 100);
  if (mod100 == 1)
    cat = "one";
  elseif (mod100 == 2)
    cat = "two";
  elseif (mod100 == 3 || mod100 == 4)
    cat = "few";
  else
    cat = "other";
  endif
endfunction''',
    "ar": '''\
function cat = plural(n)
  if (n == 0)
    cat = "zero";
  elseif (n == 1)
    cat = "one";
  elseif (n == 2)
    cat = "two";
  else
    mod100 = mod(n, 100);
    if (mod100 >= 3 && mod100 <= 10)
      cat = "few";
    elseif (mod100 >= 11 && mod100 <= 99)
      cat = "many";
    else
      cat = "other";
    endif
  endif
endfunction''',
    "lv": '''\
function cat = plural(n)
  mod10 = mod(n, 10);
  mod100 = mod(n, 100);
  if (mod10 == 0 || (mod100 >= 11 && mod100 <= 19))
    cat = "zero";
  elseif (mod10 == 1 && mod100 != 11)
    cat = "one";
  else
    cat = "other";
  endif
endfunction''',
    "he": '''\
function cat = plural(n)
  if (n == 1)
    cat = "one";
  elseif (n == 2)
    cat = "two";
  else
    cat = "other";
  endif
endfunction''',
    "mk": '''\
function cat = plural(n)
  mod10 = mod(n, 10);
  mod100 = mod(n, 100);
  if (mod10 == 1 && mod100 != 11)
    cat = "one";
  else
    cat = "other";
  endif
endfunction''',
    "cy": '''\
function cat = plural(n)
  if (n == 0)
    cat = "zero";
  elseif (n == 1)
    cat = "one";
  elseif (n == 2)
    cat = "two";
  elseif (n == 3)
    cat = "few";
  elseif (n == 6)
    cat = "many";
  else
    cat = "other";
  endif
endfunction''',
    "gv": '''\
function cat = plural(n)
  mod10 = mod(n, 10);
  mod100 = mod(n, 100);
  if (mod10 == 1)
    cat = "one";
  elseif (mod10 == 2)
    cat = "two";
  elseif (mod100 == 0 || mod100 == 20 || mod100 == 40 || mod100 == 60 || mod100 == 80)
    cat = "few";
  else
    cat = "other";
  endif
endfunction''',
    "gd": '''\
function cat = plural(n)
  if (n == 1 || n == 11)
    cat = "one";
  elseif (n == 2 || n == 12)
    cat = "two";
  elseif ((n >= 3 && n <= 10) || (n >= 13 && n <= 19))
    cat = "few";
  else
    cat = "other";
  endif
endfunction''',
    "ga": '''\
function cat = plural(n)
  if (n == 1)
    cat = "one";
  elseif (n == 2)
    cat = "two";
  elseif (n >= 3 && n <= 6)
    cat = "few";
  elseif (n >= 7 && n <= 10)
    cat = "many";
  else
    cat = "other";
  endif
endfunction''',
    "mt": '''\
function cat = plural(n)
  if (n == 1)
    cat = "one";
  elseif (n == 2)
    cat = "two";
  else
    mod100 = mod(n, 100);
    if (n == 0 || (mod100 >= 3 && mod100 <= 10))
      cat = "few";
    elseif (mod100 >= 11 && mod100 <= 19)
      cat = "many";
    else
      cat = "other";
    endif
  endif
endfunction''',
    "br": '''\
function cat = plural(n)
  mod10 = mod(n, 10);
  mod100 = mod(n, 100);
  if (mod10 == 1 && mod100 != 11 && mod100 != 71 && mod100 != 91)
    cat = "one";
  elseif (mod10 == 2 && mod100 != 12 && mod100 != 72 && mod100 != 92)
    cat = "two";
  elseif ((mod10 == 3 || mod10 == 4 || mod10 == 9) && !(mod100 >= 10 && mod100 <= 19) && !(mod100 >= 70 && mod100 <= 79) && !(mod100 >= 90 && mod100 <= 99))
    cat = "few";
  elseif (n != 0 && mod(n, 1000000) == 0)
    cat = "many";
  else
    cat = "other";
  endif
endfunction''',
    "kw": '''\
function cat = plural(n)
  if (n == 0)
    cat = "zero";
  elseif (n == 1)
    cat = "one";
  else
    mod100 = mod(n, 100);
    if (mod100 == 2 || mod100 == 22 || mod100 == 42 || mod100 == 62 || mod100 == 82)
      cat = "two";
    elseif (mod100 == 3 || mod100 == 23 || mod100 == 43 || mod100 == 63 || mod100 == 83)
      cat = "few";
    elseif (n != 1 && (mod100 == 1 || mod100 == 21 || mod100 == 41 || mod100 == 61 || mod100 == 81))
      cat = "many";
    else
      cat = "other";
    endif
  endif
endfunction''',
    "shi": '''\
function cat = plural(n)
  if (n == 0 || n == 1)
    cat = "one";
  elseif (n >= 2 && n <= 10)
    cat = "few";
  else
    cat = "other";
  endif
endfunction''',
    "tzm": '''\
function cat = plural(n)
  if (n == 0 || n == 1 || (n >= 11 && n <= 99))
    cat = "one";
  else
    cat = "other";
  endif
endfunction''',
}


def is_simple_plural(rule: str) -> bool:
    """True if this rule can be expressed as an inline anonymous function."""
    return rule in ("other_only", "one_other", "one_other_zero_one")


def get_octave_plural(rule: str) -> str:
    """Get Octave plural expression (inline function or function handle)."""
    if rule in _OCTAVE:
        return _OCTAVE[rule]
    return "@plural"


def get_octave_named_function(rule: str) -> str | None:
    """Get Octave named function for complex rules."""
    return _OCTAVE_NAMED.get(rule)
