with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Fixed;

package body Sayableduration is

   function Is_Digit (C : Character) return Boolean is
   begin
      return C >= '0' and then C <= '9';
   end Is_Digit;

   function Int_To_Str (N : Integer) return String is
      Raw : constant String := Ada.Strings.Fixed.Trim
        (Integer'Image (N), Ada.Strings.Left);
   begin
      return Raw;
   end Int_To_Str;

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

   function Is_Leap_Year (Year : Integer) return Boolean is
   begin
      return Year mod 4 = 0
        and then (Year mod 100 /= 0 or else Year mod 400 = 0);
   end Is_Leap_Year;

   function Days_In_Month
     (Year : Integer; Month : Integer) return Integer
   is
      Month_Days : constant array (1 .. 12) of Integer :=
        (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
   begin
      if Month = 2 and then Is_Leap_Year (Year) then
         return 29;
      else
         return Month_Days (Month);
      end if;
   end Days_In_Month;

   function Days_Since_Epoch
     (Year : Integer; Month : Integer; Day : Integer)
      return Integer
   is
      D : Integer := 0;
      Y : Integer;
      M : Integer;
   begin
      if Year >= 2000 then
         Y := 2000;
         while Y < Year loop
            if Is_Leap_Year (Y) then
               D := D + 366;
            else
               D := D + 365;
            end if;
            Y := Y + 1;
         end loop;
      else
         Y := Year;
         while Y < 2000 loop
            if Is_Leap_Year (Y) then
               D := D - 366;
            else
               D := D - 365;
            end if;
            Y := Y + 1;
         end loop;
      end if;

      M := 1;
      while M < Month loop
         D := D + Days_In_Month (Year, M);
         M := M + 1;
      end loop;

      D := D + Day - 1;
      return D;
   end Days_Since_Epoch;

   type ISO_Result is record
      Epoch_Seconds : Long_Long_Integer := 0;
      OK            : Boolean := False;
   end record;

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

   --  YYYY-MM-DDTHH:MM (one- or two-digit hour), then optional :SS with
   --  optional .fraction, then an optional zone suffix that is ignored.
   function Parse_ISO (S : String) return ISO_Result is
      R      : ISO_Result;
      F      : constant Integer := S'First;
      Pos    : Integer := F + 11;
      Second : Integer := 0;
   begin
      if S'Length < 15 or else S (F + 4) /= '-' or else S (F + 7) /= '-'
        or else S (F + 10) /= 'T'
        or else not All_Digits (S (F .. F + 3))
        or else not All_Digits (S (F + 5 .. F + 6))
        or else not All_Digits (S (F + 8 .. F + 9))
      then
         return R;
      end if;

      while Pos <= S'Last and then Pos - (F + 11) < 2
        and then Is_Digit (S (Pos))
      loop
         Pos := Pos + 1;
      end loop;
      if Pos = F + 11 or else S'Last < Pos + 2 or else S (Pos) /= ':'
        or else not All_Digits (S (Pos + 1 .. Pos + 2))
      then
         return R;
      end if;

      declare
         Year   : constant Integer := Digits_Value (S (F .. F + 3));
         Month  : constant Integer := Digits_Value (S (F + 5 .. F + 6));
         Day    : constant Integer := Digits_Value (S (F + 8 .. F + 9));
         Hour   : constant Integer := Digits_Value (S (F + 11 .. Pos - 1));
         Minute : constant Integer := Digits_Value (S (Pos + 1 .. Pos + 2));
      begin
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

         if (Pos <= S'Last and then not Is_Zone_Suffix (S (Pos .. S'Last)))
           or else Month not in 1 .. 12
           or else Day not in 1 .. Days_In_Month (Year, Month)
           or else Hour > 23 or else Minute > 59 or else Second > 59
         then
            return R;
         end if;

         R.Epoch_Seconds :=
           Long_Long_Integer (Days_Since_Epoch (Year, Month, Day)) * 86400
           + Long_Long_Integer (Hour * 3600 + Minute * 60 + Second);
         R.OK := True;
      end;
      return R;
   end Parse_ISO;

   function Resolve_Unit
     (Count : Integer;
      UF    : Unit_Forms;
      Loc   : Duration_Locale;
      Half  : String) return String
   is
      Base_N     : constant String := Int_To_Str (Count);
      N_Str      : Unbounded_String;
      Tmpl       : Unbounded_String;
      Cat        : Plural_Category;
      Result_Buf : Unbounded_String;
   begin
      if Half'Length > 0
        and then Ada.Strings.Fixed.Index (Half, "{n}") > 0
      then
         N_Str := To_Unbounded_String
           (Replace_First (Half, "{n}", Base_N));
      else
         N_Str := To_Unbounded_String (Base_N);
      end if;

      Tmpl := Null_Unbounded_String;
      if UF.Has_Simple then
         Tmpl := UF.Simple;
      else
         --  Half-marked: force "other" plural
         if Half'Length > 0 then
            Cat := Other;
         else
            Cat := Loc.Plural (Count);
         end if;

         if UF.Has_Form (Cat) then
            Tmpl := UF.Forms (Cat);
         elsif UF.Has_Form (Other) then
            Tmpl := UF.Forms (Other);
         end if;
      end if;

      if Length (Tmpl) = 0 then
         return "";
      end if;

      Result_Buf := To_Unbounded_String
        (Replace_First
           (To_String (Tmpl), "{n}", To_String (N_Str)));

      if Half'Length > 0
        and then Ada.Strings.Fixed.Index (Half, "{0}") > 0
      then
         return Replace_First
           (Half, "{0}", To_String (Result_Buf));
      else
         return To_String (Result_Buf);
      end if;
   end Resolve_Unit;

   --  Build effective locale values based on compactness
   type Effective is record
      Second    : Unit_Forms;
      Minute    : Unit_Forms;
      Hour      : Unit_Forms;
      Day       : Unit_Forms;
      Week      : Unit_Forms;
      Month     : Unit_Forms;
      Year      : Unit_Forms;
      Half      : Unbounded_String;
      Delimiter : Unbounded_String;
      Just_Now  : Unbounded_String;
      Ago       : Unbounded_String;
      In_Future : Unbounded_String;
   end record;

   function Build_Effective
     (Loc  : Duration_Locale;
      Comp : Compactness) return Effective
   is
      E       : Effective;
      Ovr     : Compactness_Override;
      Has_Ovr : Boolean := False;
   begin
      if Comp = Short and then Loc.Has_Short then
         Has_Ovr := True;
         Ovr := Loc.Short_Override;
      elsif Comp = Compact and then Loc.Has_Compact then
         Has_Ovr := True;
         Ovr := Loc.Compact_Override;
      end if;

      --  Units: use override if present
      if Has_Ovr and then Ovr.Has_Units
        and then Ovr.Has_Second
      then
         E.Second := Ovr.Second;
      else
         E.Second := Loc.Units.Second;
      end if;

      if Has_Ovr and then Ovr.Has_Units
        and then Ovr.Has_Minute
      then
         E.Minute := Ovr.Minute;
      else
         E.Minute := Loc.Units.Minute;
      end if;

      if Has_Ovr and then Ovr.Has_Units
        and then Ovr.Has_Hour
      then
         E.Hour := Ovr.Hour;
      else
         E.Hour := Loc.Units.Hour;
      end if;

      if Has_Ovr and then Ovr.Has_Units
        and then Ovr.Has_Day
      then
         E.Day := Ovr.Day;
      else
         E.Day := Loc.Units.Day;
      end if;

      if Has_Ovr and then Ovr.Has_Units
        and then Ovr.Has_Week
      then
         E.Week := Ovr.Week;
      else
         E.Week := Loc.Units.Week;
      end if;

      if Has_Ovr and then Ovr.Has_Units
        and then Ovr.Has_Month
      then
         E.Month := Ovr.Month;
      else
         E.Month := Loc.Units.Month;
      end if;

      if Has_Ovr and then Ovr.Has_Units
        and then Ovr.Has_Year
      then
         E.Year := Ovr.Year;
      else
         E.Year := Loc.Units.Year;
      end if;

      --  Scalar overrides
      if Has_Ovr and then Ovr.Has_Half then
         E.Half := Ovr.Half;
      else
         E.Half := Loc.Half;
      end if;

      if Has_Ovr and then Ovr.Has_Delimiter then
         E.Delimiter := Ovr.Delimiter;
      else
         E.Delimiter := Loc.Delimiter;
      end if;

      E.Just_Now := Loc.Just_Now;

      if Has_Ovr and then Ovr.Has_Ago then
         E.Ago := Ovr.Ago;
      else
         E.Ago := Loc.Ago;
      end if;

      if Has_Ovr and then Ovr.Has_In_Future then
         E.In_Future := Ovr.In_Future;
      else
         E.In_Future := Loc.In_Future;
      end if;

      return E;
   end Build_Effective;

   function Format_Duration_Secs
     (Loc     : Duration_Locale;
      Eff     : Effective;
      Total_L : Long_Long_Integer) return String
   is
      Approx_Months : constant Long_Long_Integer :=
        (Total_L / 86400 * 100 + 1522) / 3044;
      Total_Minutes     : Integer;
      Remainder_Seconds : Integer;
      Total_Hours       : Integer;
      Remainder_Minutes : Integer;
      Total_Days        : Integer;
      Remainder_Hours   : Integer;
      Total_Weeks       : Integer;
      Remainder_Days    : Integer;
      Total_Months      : Integer;
      Total_Years       : Integer;
      Rem_Months        : Integer;
      Part1             : Unbounded_String;
   begin
      if Approx_Months > Max_Duration_Months then
         return "";
      end if;

      --  0 seconds
      if Total_L = 0 then
         return To_String (Eff.Just_Now);
      end if;

      --  1-59 seconds
      if Total_L < 60 then
         return Resolve_Unit (Integer (Total_L), Eff.Second, Loc, "");
      end if;

      Total_Minutes := Integer (Total_L / 60);
      Remainder_Seconds := Integer (Total_L mod 60);

      --  1-4 minutes: minutes + seconds
      if Total_Minutes < 5 then
         Part1 := To_Unbounded_String
           (Resolve_Unit
              (Total_Minutes, Eff.Minute, Loc, ""));
         if Remainder_Seconds > 0 then
            return To_String (Part1)
              & To_String (Eff.Delimiter)
              & Resolve_Unit
                  (Remainder_Seconds, Eff.Second, Loc, "");
         end if;
         return To_String (Part1);
      end if;

      --  5-59 minutes
      if Total_Minutes < 60 then
         return Resolve_Unit
           (Total_Minutes, Eff.Minute, Loc, "");
      end if;

      Total_Hours := Integer (Total_L / 3600);
      Remainder_Minutes := Integer ((Total_L mod 3600) / 60);

      --  1-5 hours: hours + minutes (with half marker)
      if Total_Hours <= 5 then
         if Remainder_Minutes = 30 then
            return Resolve_Unit
              (Total_Hours, Eff.Hour, Loc,
               To_String (Eff.Half));
         end if;

         Part1 := To_Unbounded_String
           (Resolve_Unit (Total_Hours, Eff.Hour, Loc, ""));
         if Remainder_Minutes > 0 then
            return To_String (Part1)
              & To_String (Eff.Delimiter)
              & Resolve_Unit
                  (Remainder_Minutes, Eff.Minute, Loc, "");
         end if;
         return To_String (Part1);
      end if;

      --  6-23 hours
      if Total_Hours < 24 then
         return Resolve_Unit
           (Total_Hours, Eff.Hour, Loc, "");
      end if;

      Total_Days := Integer (Total_L / 86400);
      Remainder_Hours := Integer ((Total_L mod 86400) / 3600);

      --  1-2 days: days + hours (with half marker)
      if Total_Days <= 2 then
         if Remainder_Hours = 12 then
            return Resolve_Unit
              (Total_Days, Eff.Day, Loc,
               To_String (Eff.Half));
         end if;

         Part1 := To_Unbounded_String
           (Resolve_Unit (Total_Days, Eff.Day, Loc, ""));
         if Remainder_Hours > 0 then
            return To_String (Part1)
              & To_String (Eff.Delimiter)
              & Resolve_Unit
                  (Remainder_Hours, Eff.Hour, Loc, "");
         end if;
         return To_String (Part1);
      end if;

      --  3-6 days
      if Total_Days < 7 then
         return Resolve_Unit
           (Total_Days, Eff.Day, Loc, "");
      end if;

      Total_Weeks := Total_Days / 7;
      Remainder_Days := Total_Days mod 7;

      --  1-4 weeks: weeks + days (up to 29 days)
      if Total_Days < 30 then
         Part1 := To_Unbounded_String
           (Resolve_Unit (Total_Weeks, Eff.Week, Loc, ""));
         if Remainder_Days > 0 then
            return To_String (Part1)
              & To_String (Eff.Delimiter)
              & Resolve_Unit
                  (Remainder_Days, Eff.Day, Loc, "");
         end if;
         return To_String (Part1);
      end if;

      --  Approximate months (30.44 days average)
      --  Use integer rounding: (total_days * 100 + 1522) / 3044
      Total_Months := Integer (Approx_Months);

      --  1-11 months
      if Total_Months < 12 then
         if Total_Months = 0 then
            Total_Months := 1;
         end if;
         return Resolve_Unit
           (Total_Months, Eff.Month, Loc, "");
      end if;

      --  12+ months: years + months
      Total_Years := Total_Months / 12;
      Rem_Months := Total_Months mod 12;
      Part1 := To_Unbounded_String
        (Resolve_Unit (Total_Years, Eff.Year, Loc, ""));
      if Rem_Months > 0 then
         return To_String (Part1)
           & To_String (Eff.Delimiter)
           & Resolve_Unit (Rem_Months, Eff.Month, Loc, "");
      end if;
      return To_String (Part1);
   end Format_Duration_Secs;

   function Format_Duration
     (Loc     : Duration_Locale;
      Comp    : Compactness;
      Seconds : Long_Long_Integer) return String
   is
      Eff : Effective;
   begin
      if Seconds < 0 then
         return "";
      end if;

      Eff := Build_Effective (Loc, Comp);
      return Format_Duration_Secs (Loc, Eff, Seconds);
   end Format_Duration;

   function Format_Duration
     (Loc    : Duration_Locale;
      Comp   : Compactness;
      Start  : String;
      Finish : String) return String
   is
      S : ISO_Result;
      E : ISO_Result;
   begin
      S := Parse_ISO (Start);
      E := Parse_ISO (Finish);
      if not S.OK or else not E.OK then
         return "";
      end if;

      return Format_Duration_Secs
        (Loc, Build_Effective (Loc, Comp),
         abs (E.Epoch_Seconds - S.Epoch_Seconds));
   end Format_Duration;

   function Format_Since
     (Loc   : Duration_Locale;
      Comp  : Compactness;
      Start : String;
      As_Of : String) return String
   is
      S    : ISO_Result;
      A    : ISO_Result;
      Diff : Long_Long_Integer;
      Eff  : Effective;
      Dur  : Unbounded_String;
   begin
      if Start'Length = 0 or else As_Of'Length = 0 then
         return "";
      end if;

      S := Parse_ISO (Start);
      A := Parse_ISO (As_Of);
      if not S.OK or else not A.OK then
         return "";
      end if;

      Diff := A.Epoch_Seconds - S.Epoch_Seconds;
      if Diff < 0 then
         return "";
      end if;

      Eff := Build_Effective (Loc, Comp);

      if Diff = 0 then
         return To_String (Eff.Just_Now);
      end if;

      Dur := To_Unbounded_String
        (Format_Duration_Secs (Loc, Eff, Diff));
      if Length (Dur) = 0 then
         return "";
      end if;
      return Replace_First
        (To_String (Eff.Ago), "{0}", To_String (Dur));
   end Format_Since;

   function Format_Until
     (Loc    : Duration_Locale;
      Comp   : Compactness;
      Target : String;
      As_Of  : String) return String
   is
      T    : ISO_Result;
      A    : ISO_Result;
      Diff : Long_Long_Integer;
      Eff  : Effective;
      Dur  : Unbounded_String;
   begin
      if Target'Length = 0 or else As_Of'Length = 0 then
         return "";
      end if;

      T := Parse_ISO (Target);
      A := Parse_ISO (As_Of);
      if not T.OK or else not A.OK then
         return "";
      end if;

      Diff := T.Epoch_Seconds - A.Epoch_Seconds;
      if Diff < 0 then
         return "";
      end if;

      Eff := Build_Effective (Loc, Comp);

      if Diff = 0 then
         return To_String (Eff.Just_Now);
      end if;

      Dur := To_Unbounded_String
        (Format_Duration_Secs (Loc, Eff, Diff));
      if Length (Dur) = 0 then
         return "";
      end if;
      return Replace_First
        (To_String (Eff.In_Future), "{0}", To_String (Dur));
   end Format_Until;

end Sayableduration;
