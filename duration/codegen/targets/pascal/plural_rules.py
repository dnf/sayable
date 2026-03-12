"""Pascal plural rule definitions for all 23 patterns.

Each rule returns a Pascal function body that takes an integer `n`
and returns a TPluralCategory value.
"""

from __future__ import annotations

_PAS = {
    "other_only": """\
begin
  Result := pcOther;
end;""",
    "one_other": """\
begin
  if n = 1 then
    Result := pcOne
  else
    Result := pcOther;
end;""",
    "one_other_zero_one": """\
begin
  if (n = 0) or (n = 1) then
    Result := pcOne
  else
    Result := pcOther;
end;""",
    "cs_sk": """\
begin
  if n = 1 then
    Result := pcOne
  else if (n >= 2) and (n <= 4) then
    Result := pcFew
  else
    Result := pcOther;
end;""",
    "lt": """\
var
  mod10, mod100: Integer;
begin
  mod10 := n mod 10;
  mod100 := n mod 100;
  if (mod10 = 1) and (mod100 <> 11) then
    Result := pcOne
  else if (mod10 >= 2) and (mod10 <= 9) and ((mod100 < 12) or (mod100 > 19)) then
    Result := pcFew
  else
    Result := pcOther;
end;""",
    "ro": """\
begin
  if n = 1 then
    Result := pcOne
  else if (n = 0) or ((n mod 100 >= 1) and (n mod 100 <= 19)) then
    Result := pcFew
  else
    Result := pcOther;
end;""",
    "slavic_bcs": """\
var
  mod10, mod100: Integer;
begin
  mod10 := n mod 10;
  mod100 := n mod 100;
  if (mod10 = 1) and (mod100 <> 11) then
    Result := pcOne
  else if (mod10 >= 2) and (mod10 <= 4) and ((mod100 < 12) or (mod100 > 14)) then
    Result := pcFew
  else
    Result := pcOther;
end;""",
    "pl": """\
var
  mod10, mod100: Integer;
begin
  if n = 1 then
    Result := pcOne
  else begin
    mod10 := n mod 10;
    mod100 := n mod 100;
    if (mod10 >= 2) and (mod10 <= 4) and ((mod100 < 12) or (mod100 > 14)) then
      Result := pcFew
    else
      Result := pcMany;
  end;
end;""",
    "ru_uk": """\
var
  mod10, mod100: Integer;
begin
  mod10 := n mod 10;
  mod100 := n mod 100;
  if (mod10 = 1) and (mod100 <> 11) then
    Result := pcOne
  else if (mod10 >= 2) and (mod10 <= 4) and ((mod100 < 12) or (mod100 > 14)) then
    Result := pcFew
  else
    Result := pcMany;
end;""",
    "sl": """\
var
  mod100: Integer;
begin
  mod100 := n mod 100;
  if mod100 = 1 then
    Result := pcOne
  else if mod100 = 2 then
    Result := pcTwo
  else if (mod100 = 3) or (mod100 = 4) then
    Result := pcFew
  else
    Result := pcOther;
end;""",
    "ar": """\
var
  mod100: Integer;
begin
  if n = 0 then
    Result := pcZero
  else if n = 1 then
    Result := pcOne
  else if n = 2 then
    Result := pcTwo
  else begin
    mod100 := n mod 100;
    if (mod100 >= 3) and (mod100 <= 10) then
      Result := pcFew
    else if (mod100 >= 11) and (mod100 <= 99) then
      Result := pcMany
    else
      Result := pcOther;
  end;
end;""",
    "lv": """\
var
  mod10, mod100: Integer;
begin
  mod10 := n mod 10;
  mod100 := n mod 100;
  if (mod10 = 0) or ((mod100 >= 11) and (mod100 <= 19)) then
    Result := pcZero
  else if (mod10 = 1) and (mod100 <> 11) then
    Result := pcOne
  else
    Result := pcOther;
end;""",
    "he": """\
begin
  if n = 1 then
    Result := pcOne
  else if n = 2 then
    Result := pcTwo
  else
    Result := pcOther;
end;""",
    "mk": """\
var
  mod10, mod100: Integer;
begin
  mod10 := n mod 10;
  mod100 := n mod 100;
  if (mod10 = 1) and (mod100 <> 11) then
    Result := pcOne
  else
    Result := pcOther;
end;""",
    "cy": """\
begin
  if n = 0 then
    Result := pcZero
  else if n = 1 then
    Result := pcOne
  else if n = 2 then
    Result := pcTwo
  else if n = 3 then
    Result := pcFew
  else if n = 6 then
    Result := pcMany
  else
    Result := pcOther;
end;""",
    "gv": """\
var
  mod10, mod100: Integer;
begin
  mod10 := n mod 10;
  mod100 := n mod 100;
  if mod10 = 1 then
    Result := pcOne
  else if mod10 = 2 then
    Result := pcTwo
  else if (mod100 = 0) or (mod100 = 20) or (mod100 = 40) or (mod100 = 60) or (mod100 = 80) then
    Result := pcFew
  else
    Result := pcOther;
end;""",
    "gd": """\
begin
  if (n = 1) or (n = 11) then
    Result := pcOne
  else if (n = 2) or (n = 12) then
    Result := pcTwo
  else if ((n >= 3) and (n <= 10)) or ((n >= 13) and (n <= 19)) then
    Result := pcFew
  else
    Result := pcOther;
end;""",
    "ga": """\
begin
  if n = 1 then
    Result := pcOne
  else if n = 2 then
    Result := pcTwo
  else if (n >= 3) and (n <= 6) then
    Result := pcFew
  else if (n >= 7) and (n <= 10) then
    Result := pcMany
  else
    Result := pcOther;
end;""",
    "mt": """\
var
  mod100: Integer;
begin
  if n = 1 then
    Result := pcOne
  else if n = 2 then
    Result := pcTwo
  else begin
    mod100 := n mod 100;
    if (n = 0) or ((mod100 >= 3) and (mod100 <= 10)) then
      Result := pcFew
    else if (mod100 >= 11) and (mod100 <= 19) then
      Result := pcMany
    else
      Result := pcOther;
  end;
end;""",
    "br": """\
var
  mod10, mod100: Integer;
begin
  mod10 := n mod 10;
  mod100 := n mod 100;
  if (mod10 = 1) and (mod100 <> 11) and (mod100 <> 71) and (mod100 <> 91) then
    Result := pcOne
  else if (mod10 = 2) and (mod100 <> 12) and (mod100 <> 72) and (mod100 <> 92) then
    Result := pcTwo
  else if ((mod10 = 3) or (mod10 = 4) or (mod10 = 9)) and not ((mod100 >= 10) and (mod100 <= 19)) and not ((mod100 >= 70) and (mod100 <= 79)) and not ((mod100 >= 90) and (mod100 <= 99)) then
    Result := pcFew
  else if (n <> 0) and (n mod 1000000 = 0) then
    Result := pcMany
  else
    Result := pcOther;
end;""",
    "kw": """\
var
  mod100: Integer;
begin
  if n = 0 then
    Result := pcZero
  else if n = 1 then
    Result := pcOne
  else begin
    mod100 := n mod 100;
    if (mod100 = 2) or (mod100 = 22) or (mod100 = 42) or (mod100 = 62) or (mod100 = 82) then
      Result := pcTwo
    else if (mod100 = 3) or (mod100 = 23) or (mod100 = 43) or (mod100 = 63) or (mod100 = 83) then
      Result := pcFew
    else if (n <> 1) and ((mod100 = 1) or (mod100 = 21) or (mod100 = 41) or (mod100 = 61) or (mod100 = 81)) then
      Result := pcMany
    else
      Result := pcOther;
  end;
end;""",
    "shi": """\
begin
  if (n = 0) or (n = 1) then
    Result := pcOne
  else if (n >= 2) and (n <= 10) then
    Result := pcFew
  else
    Result := pcOther;
end;""",
    "tzm": """\
begin
  if (n = 0) or (n = 1) or ((n >= 11) and (n <= 99)) then
    Result := pcOne
  else
    Result := pcOther;
end;""",
}


def get_pas_plural(rule: str) -> str:
    """Get Pascal plural function body."""
    return _PAS[rule]
