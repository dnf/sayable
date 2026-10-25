with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Fixed;

package body Sayabletime is

   function Is_Digit (C : Character) return Boolean is
   begin
      return C >= '0' and then C <= '9';
   end Is_Digit;

   type Time_Parse_Result is record
      Hour   : Integer := -1;
      Minute : Integer := -1;
      OK     : Boolean := False;
   end record;

   function Is_Leap_Year (Year : Integer) return Boolean is
   begin
      return Year mod 4 = 0
        and then (Year mod 100 /= 0 or else Year mod 400 = 0);
   end Is_Leap_Year;

   function Days_In_Month (Year : Integer; Month : Integer) return Integer is
      Month_Days : constant array (1 .. 12) of Integer :=
        (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
   begin
      if Month = 2 and then Is_Leap_Year (Year) then
         return 29;
      else
         return Month_Days (Month);
      end if;
   end Days_In_Month;

   function Digits_Value (S : String) return Integer is
      V : Integer := 0;
   begin
      for C of S loop
         V := V * 10 + Character'Pos (C) - Character'Pos ('0');
      end loop;
      return V;
   end Digits_Value;

   function All_Digits (S : String) return Boolean is
   begin
      for C of S loop
         if not Is_Digit (C) then
            return False;
         end if;
      end loop;
      return True;
   end All_Digits;

   --  YYYY-MM-DD naming a real calendar day.
   function Is_Real_Date (S : String) return Boolean is
      F : constant Integer := S'First;
   begin
      if S'Length /= 10 or else S (F + 4) /= '-' or else S (F + 7) /= '-'
        or else not All_Digits (S (F .. F + 3))
        or else not All_Digits (S (F + 5 .. F + 6))
        or else not All_Digits (S (F + 8 .. F + 9))
      then
         return False;
      end if;
      declare
         Year  : constant Integer := Digits_Value (S (F .. F + 3));
         Month : constant Integer := Digits_Value (S (F + 5 .. F + 6));
         Day   : constant Integer := Digits_Value (S (F + 8 .. F + 9));
      begin
         return Month in 1 .. 12
           and then Day in 1 .. Days_In_Month (Year, Month);
      end;
   end Is_Real_Date;

   --  Z or +HH:MM / -HH:MM (validated, never applied).
   function Is_Zone_Suffix (S : String) return Boolean is
      F : constant Integer := S'First;
   begin
      return S = "Z"
        or else (S'Length = 6
                 and then (S (F) = '+' or else S (F) = '-')
                 and then All_Digits (S (F + 1 .. F + 2))
                 and then S (F + 3) = ':'
                 and then All_Digits (S (F + 4 .. F + 5)));
   end Is_Zone_Suffix;

   --  H:MM or HH:MM, then optional :SS with optional .fraction, then
   --  an optional zone suffix.
   function Parse_Clock (S : String) return Time_Parse_Result is
      R      : Time_Parse_Result;
      Pos    : Integer := S'First;
      Second : Integer := 0;
   begin
      while Pos <= S'Last and then Pos - S'First < 2
        and then Is_Digit (S (Pos))
      loop
         Pos := Pos + 1;
      end loop;
      if Pos = S'First or else S'Last < Pos + 2 or else S (Pos) /= ':'
        or else not All_Digits (S (Pos + 1 .. Pos + 2))
      then
         return R;
      end if;
      R.Hour := Digits_Value (S (S'First .. Pos - 1));
      R.Minute := Digits_Value (S (Pos + 1 .. Pos + 2));
      Pos := Pos + 3;

      if Pos + 2 <= S'Last and then S (Pos) = ':'
        and then All_Digits (S (Pos + 1 .. Pos + 2))
      then
         Second := Digits_Value (S (Pos + 1 .. Pos + 2));
         Pos := Pos + 3;
         if Pos + 1 <= S'Last and then S (Pos) = '.'
           and then Is_Digit (S (Pos + 1))
         then
            Pos := Pos + 1;
            while Pos <= S'Last and then Is_Digit (S (Pos)) loop
               Pos := Pos + 1;
            end loop;
         end if;
      end if;

      if Pos <= S'Last and then not Is_Zone_Suffix (S (Pos .. S'Last)) then
         return R;
      end if;

      R.OK := R.Hour <= 23 and then R.Minute <= 59 and then Second <= 59;
      return R;
   end Parse_Clock;

   --  A clock time alone, or after the T of an ISO datetime whose date
   --  part is a real calendar day.
   function Parse_Time (S : String) return Time_Parse_Result is
      Pos_T : constant Natural := Ada.Strings.Fixed.Index (S, "T");
      R     : Time_Parse_Result;
   begin
      if Pos_T = 0 then
         return Parse_Clock (S);
      end if;
      if not Is_Real_Date (S (S'First .. Pos_T - 1)) then
         return R;
      end if;
      return Parse_Clock (S (Pos_T + 1 .. S'Last));
   end Parse_Time;

   function Round_To_5 (M : Integer) return Integer is
   begin
      return ((M + 2) / 5) * 5;
   end Round_To_5;

   function Int_To_Str (N : Integer) return String is
      Raw : constant String := Ada.Strings.Fixed.Trim
        (Integer'Image (N), Ada.Strings.Left);
   begin
      return Raw;
   end Int_To_Str;

   function Zfill_2 (N : Integer) return String is
      Raw : constant String := Int_To_Str (N);
   begin
      if Raw'Length < 2 then
         return "0" & Raw;
      else
         return Raw;
      end if;
   end Zfill_2;

   function Replace_First
     (Tmpl : String; Marker : String; Replacement : String)
      return String
   is
      Pos : constant Natural :=
        Ada.Strings.Fixed.Index (Tmpl, Marker);
   begin
      if Pos = 0 then
         return Tmpl;
      end if;
      return Tmpl (Tmpl'First .. Pos - 1) & Replacement
        & Tmpl (Pos + Marker'Length .. Tmpl'Last);
   end Replace_First;

   function Find_Pattern
     (Clk     : Clock_Config;
      Rounded : Integer) return String
   is
   begin
      --  Find exact match
      for I in 1 .. Clk.Pattern_Count loop
         if Clk.Pattern_Keys (I) = Rounded then
            return To_String (Clk.Pattern_Vals (I));
         end if;
      end loop;

      --  Fall back to 0 pattern
      for I in 1 .. Clk.Pattern_Count loop
         if Clk.Pattern_Keys (I) = 0 then
            return To_String (Clk.Pattern_Vals (I));
         end if;
      end loop;

      return "{h}";
   end Find_Pattern;

   function Format_Natural
     (Loc  : Time_Locale;
      Hour : Integer;
      Min  : Integer) return String
   is
      Clk     : constant Clock_Config := Loc.Clock;
      Rounded : Integer;
      H       : Integer;
      H12     : Integer;
      Next_12 : Integer;
      Pattern : Unbounded_String;
   begin
      Rounded := Round_To_5 (Min);
      H := Hour;

      if Rounded = 60 then
         Rounded := 0;
         H := (H + 1) mod 24;
      end if;

      if Rounded = 0 then
         if H = 0 then
            return To_String (Clk.Midnight);
         end if;

         if H = 12 then
            return To_String (Clk.Noon);
         end if;
      end if;

      H12 := H mod 12;
      Next_12 := (H + 1) mod 12;

      Pattern := To_Unbounded_String
        (Find_Pattern (Clk, Rounded));

      declare
         Step1 : constant String :=
           Replace_First
             (To_String (Pattern), "{h}",
              To_String (Clk.Hours (H12)));
      begin
         return Replace_First
           (Step1, "{next_h}",
            To_String (Clk.Hours (Next_12)));
      end;
   end Format_Natural;

   function Format_Digital
     (SC   : Short_Clock_Config;
      Hour : Integer;
      Min  : Integer) return String
   is
      Fmt    : constant String := To_String (SC.Format);
      H12    : Integer;
      Am_Pm  : Unbounded_String;
      Result : Unbounded_String;
   begin
      if SC.Use_24h then
         Result := To_Unbounded_String
           (Replace_First (Fmt, "{h}", Int_To_Str (Hour)));
         Result := To_Unbounded_String
           (Replace_First
              (To_String (Result), "{mm}",
               Zfill_2 (Min)));
         return To_String (Result);
      end if;

      H12 := Hour mod 12;
      if H12 = 0 then
         H12 := 12;
      end if;

      if SC.Has_Am_Pm then
         if Hour < 12 then
            Am_Pm := SC.Am_Str;
         else
            Am_Pm := SC.Pm_Str;
         end if;
      else
         if Hour < 12 then
            Am_Pm := To_Unbounded_String ("AM");
         else
            Am_Pm := To_Unbounded_String ("PM");
         end if;
      end if;

      Result := To_Unbounded_String
        (Replace_First (Fmt, "{h}", Int_To_Str (H12)));
      Result := To_Unbounded_String
        (Replace_First
           (To_String (Result), "{mm}", Zfill_2 (Min)));
      Result := To_Unbounded_String
        (Replace_First
           (To_String (Result), "{ampm}",
            To_String (Am_Pm)));
      return To_String (Result);
   end Format_Digital;

   function Format_Time
     (Loc  : Time_Locale;
      Comp : Compactness;
      Time : String) return String
   is
      Parsed : Time_Parse_Result;
   begin
      if Time'Length = 0 then
         return "";
      end if;

      Parsed := Parse_Time (Time);
      if not Parsed.OK then
         return "";
      end if;

      if Comp = Short and then Loc.Has_Short then
         return Format_Digital
           (Loc.Short_Clock, Parsed.Hour, Parsed.Minute);
      end if;

      if Comp = Compact and then Loc.Has_Compact then
         return Format_Digital
           (Loc.Compact_Clock, Parsed.Hour, Parsed.Minute);
      end if;

      return Format_Natural (Loc, Parsed.Hour, Parsed.Minute);
   end Format_Time;

end Sayabletime;
