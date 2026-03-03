"""Ada plural rule definitions for all 23 CLDR cardinal patterns."""

from __future__ import annotations

_ADA = {
    "other_only": """\
      pragma Unreferenced (N);
      return Other;""",
    "one_other": """\
      if N = 1 then
         return One;
      else
         return Other;
      end if;""",
    "one_other_zero_one": """\
      if N = 0 or else N = 1 then
         return One;
      else
         return Other;
      end if;""",
    "cs_sk": """\
      if N = 1 then
         return One;
      elsif N >= 2 and then N <= 4 then
         return Few;
      else
         return Other;
      end if;""",
    "lt": """\
      declare
         Mod10  : constant Natural := N mod 10;
         Mod100 : constant Natural := N mod 100;
      begin
         if Mod10 = 1 and then Mod100 /= 11 then
            return One;
         elsif Mod10 >= 2 and then Mod10 <= 9
           and then (Mod100 < 12 or else Mod100 > 19)
         then
            return Few;
         else
            return Other;
         end if;
      end;""",
    "ro": """\
      if N = 1 then
         return One;
      elsif N = 0 or else (N mod 100 >= 1 and then N mod 100 <= 19) then
         return Few;
      else
         return Other;
      end if;""",
    "slavic_bcs": """\
      declare
         Mod10  : constant Natural := N mod 10;
         Mod100 : constant Natural := N mod 100;
      begin
         if Mod10 = 1 and then Mod100 /= 11 then
            return One;
         elsif Mod10 >= 2 and then Mod10 <= 4
           and then (Mod100 < 12 or else Mod100 > 14)
         then
            return Few;
         else
            return Other;
         end if;
      end;""",
    "pl": """\
      declare
         Mod10  : constant Natural := N mod 10;
         Mod100 : constant Natural := N mod 100;
      begin
         if N = 1 then
            return One;
         elsif Mod10 >= 2 and then Mod10 <= 4
           and then (Mod100 < 12 or else Mod100 > 14)
         then
            return Few;
         else
            return Many;
         end if;
      end;""",
    "ru_uk": """\
      declare
         Mod10  : constant Natural := N mod 10;
         Mod100 : constant Natural := N mod 100;
      begin
         if Mod10 = 1 and then Mod100 /= 11 then
            return One;
         elsif Mod10 >= 2 and then Mod10 <= 4
           and then (Mod100 < 12 or else Mod100 > 14)
         then
            return Few;
         else
            return Many;
         end if;
      end;""",
    "sl": """\
      declare
         Mod100 : constant Natural := N mod 100;
      begin
         if Mod100 = 1 then
            return One;
         elsif Mod100 = 2 then
            return Two;
         elsif Mod100 = 3 or else Mod100 = 4 then
            return Few;
         else
            return Other;
         end if;
      end;""",
    "ar": """\
      if N = 0 then
         return Zero;
      elsif N = 1 then
         return One;
      elsif N = 2 then
         return Two;
      else
         declare
            Mod100 : constant Natural := N mod 100;
         begin
            if Mod100 >= 3 and then Mod100 <= 10 then
               return Few;
            elsif Mod100 >= 11 and then Mod100 <= 99 then
               return Many;
            else
               return Other;
            end if;
         end;
      end if;""",
    "lv": """\
      declare
         Mod10  : constant Natural := N mod 10;
         Mod100 : constant Natural := N mod 100;
      begin
         if Mod10 = 0 or else (Mod100 >= 11 and then Mod100 <= 19) then
            return Zero;
         elsif Mod10 = 1 and then Mod100 /= 11 then
            return One;
         else
            return Other;
         end if;
      end;""",
    "he": """\
      if N = 1 then
         return One;
      elsif N = 2 then
         return Two;
      else
         return Other;
      end if;""",
    "mk": """\
      declare
         Mod10  : constant Natural := N mod 10;
         Mod100 : constant Natural := N mod 100;
      begin
         if Mod10 = 1 and then Mod100 /= 11 then
            return One;
         else
            return Other;
         end if;
      end;""",
    "cy": """\
      if N = 0 then
         return Zero;
      elsif N = 1 then
         return One;
      elsif N = 2 then
         return Two;
      elsif N = 3 then
         return Few;
      elsif N = 6 then
         return Many;
      else
         return Other;
      end if;""",
    "gv": """\
      declare
         Mod10  : constant Natural := N mod 10;
         Mod100 : constant Natural := N mod 100;
      begin
         if Mod10 = 1 then
            return One;
         elsif Mod10 = 2 then
            return Two;
         elsif Mod100 = 0 or else Mod100 = 20 or else Mod100 = 40
           or else Mod100 = 60 or else Mod100 = 80
         then
            return Few;
         else
            return Other;
         end if;
      end;""",
    "gd": """\
      if N = 1 or else N = 11 then
         return One;
      elsif N = 2 or else N = 12 then
         return Two;
      elsif (N >= 3 and then N <= 10)
        or else (N >= 13 and then N <= 19)
      then
         return Few;
      else
         return Other;
      end if;""",
    "ga": """\
      if N = 1 then
         return One;
      elsif N = 2 then
         return Two;
      elsif N >= 3 and then N <= 6 then
         return Few;
      elsif N >= 7 and then N <= 10 then
         return Many;
      else
         return Other;
      end if;""",
    "mt": """\
      if N = 1 then
         return One;
      elsif N = 2 then
         return Two;
      else
         declare
            Mod100 : constant Natural := N mod 100;
         begin
            if N = 0 or else (Mod100 >= 3 and then Mod100 <= 10) then
               return Few;
            elsif Mod100 >= 11 and then Mod100 <= 19 then
               return Many;
            else
               return Other;
            end if;
         end;
      end if;""",
    "br": """\
      declare
         Mod10  : constant Natural := N mod 10;
         Mod100 : constant Natural := N mod 100;
      begin
         if Mod10 = 1 and then Mod100 /= 11
           and then Mod100 /= 71 and then Mod100 /= 91
         then
            return One;
         elsif Mod10 = 2 and then Mod100 /= 12
           and then Mod100 /= 72 and then Mod100 /= 92
         then
            return Two;
         elsif (Mod10 = 3 or else Mod10 = 4 or else Mod10 = 9)
           and then not (Mod100 >= 10 and then Mod100 <= 19)
           and then not (Mod100 >= 70 and then Mod100 <= 79)
           and then not (Mod100 >= 90 and then Mod100 <= 99)
         then
            return Few;
         elsif N /= 0 and then N mod 1_000_000 = 0 then
            return Many;
         else
            return Other;
         end if;
      end;""",
    "kw": """\
      declare
         Mod100 : constant Natural := N mod 100;
      begin
         if N = 0 then
            return Zero;
         elsif N = 1 then
            return One;
         elsif Mod100 = 2 or else Mod100 = 22 or else Mod100 = 42
           or else Mod100 = 62 or else Mod100 = 82
         then
            return Two;
         elsif Mod100 = 3 or else Mod100 = 23 or else Mod100 = 43
           or else Mod100 = 63 or else Mod100 = 83
         then
            return Few;
         elsif Mod100 = 1 or else Mod100 = 21
           or else Mod100 = 41 or else Mod100 = 61 or else Mod100 = 81
         then
            return Many;
         else
            return Other;
         end if;
      end;""",
    "shi": """\
      if N = 0 or else N = 1 then
         return One;
      elsif N >= 2 and then N <= 10 then
         return Few;
      else
         return Other;
      end if;""",
    "tzm": """\
      if N = 0 or else N = 1 or else (N >= 11 and then N <= 99) then
         return One;
      else
         return Other;
      end if;""",
}


def get_ada_plural(rule: str) -> str:
    return _ADA[rule]
