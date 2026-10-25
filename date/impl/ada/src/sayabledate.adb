with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Fixed;

package body Sayabledate is

   type Parse_Result is record
      Year  : Integer := 0;
      Month : Integer := 0;
      Day   : Integer := 0;
      OK    : Boolean := False;
   end record;

   function Is_Digit (C : Character) return Boolean is
   begin
      return C >= '0' and then C <= '9';
   end Is_Digit;

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

   --  A date alone, or a date followed by T and a time (only the date
   --  part is read).
   function Is_Date_Or_Datetime (S : String) return Boolean is
   begin
      return S'Length = 10
        or else (S'Length > 10 and then S (S'First + 10) = 'T');
   end Is_Date_Or_Datetime;

   function Parse_Date_Str (S : String) return Parse_Result is
      R : Parse_Result;
   begin
      if not Is_Date_Or_Datetime (S) then
         return R;
      end if;

      declare
         DS : constant String := S (S'First .. S'First + 9);
      begin
         if DS (DS'First + 4) /= '-'
           or else DS (DS'First + 7) /= '-'
         then
            return R;
         end if;

         for I in 0 .. 3 loop
            if not Is_Digit (DS (DS'First + I)) then
               return R;
            end if;
            R.Year := R.Year * 10
              + Character'Pos (DS (DS'First + I))
              - Character'Pos ('0');
         end loop;

         for I in 5 .. 6 loop
            if not Is_Digit (DS (DS'First + I)) then
               return R;
            end if;
            R.Month := R.Month * 10
              + Character'Pos (DS (DS'First + I))
              - Character'Pos ('0');
         end loop;

         for I in 8 .. 9 loop
            if not Is_Digit (DS (DS'First + I)) then
               return R;
            end if;
            R.Day := R.Day * 10
              + Character'Pos (DS (DS'First + I))
              - Character'Pos ('0');
         end loop;
      end;

      R.OK := R.Month in 1 .. 12
        and then R.Day in 1 .. Days_In_Month (R.Year, R.Month);
      return R;
   end Parse_Date_Str;

   function Julian_Day (Year, Month, Day : Integer) return Integer is
      A : constant Integer := (14 - Month) / 12;
      Y : constant Integer := Year + 4800 - A;
      M : constant Integer := Month + 12 * A - 3;
   begin
      return Day + (153 * M + 2) / 5 + 365 * Y + Y / 4 - Y / 100
        + Y / 400 - 32045;
   end Julian_Day;

   function Weekday (Year, Month, Day : Integer) return Integer is
      JDN : constant Integer := Julian_Day (Year, Month, Day);
   begin
      --  0=Sunday, 1=Monday, ..., 6=Saturday
      return (JDN + 1) mod 7;
   end Weekday;

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

   --  Pick effective values based on compactness override
   type Effective_Locale is record
      Months                  : String_Array_12;
      Months_In_Date          : String_Array_12;
      Has_Months_In_Date      : Boolean;
      Weekdays                : String_Array_7;
      Day_Format              : Unbounded_String;
      Day_Format_Exception_Count : Natural;
      Day_Format_Exception_Keys : Exception_Keys;
      Day_Format_Exception_Vals : Exception_Vals;
      Date_Pattern            : Unbounded_String;
      Date_Pattern_With_Year  : Unbounded_String;
      Today                   : Unbounded_String;
      Tomorrow                : Unbounded_String;
      Yesterday               : Unbounded_String;
   end record;

   function Build_Effective
     (Loc  : Date_Locale;
      Comp : Compactness) return Effective_Locale
   is
      E   : Effective_Locale;
      Ovr : Compactness_Override;
      Has_Ovr : Boolean := False;
   begin
      if Comp = Short and then Loc.Has_Short then
         Has_Ovr := True;
         Ovr := Loc.Short_Override;
      elsif Comp = Compact and then Loc.Has_Compact then
         Has_Ovr := True;
         Ovr := Loc.Compact_Override;
      end if;

      --  Months
      if Has_Ovr and then Ovr.Has_Months then
         E.Months := Ovr.Months;
      else
         E.Months := Loc.Months;
      end if;

      --  Months in date
      if Has_Ovr and then Ovr.Has_Months_In_Date then
         E.Has_Months_In_Date := True;
         E.Months_In_Date := Ovr.Months_In_Date;
      else
         E.Has_Months_In_Date := Loc.Has_Months_In_Date;
         E.Months_In_Date := Loc.Months_In_Date;
      end if;

      --  Weekdays
      if Has_Ovr and then Ovr.Has_Weekdays then
         E.Weekdays := Ovr.Weekdays;
      else
         E.Weekdays := Loc.Weekdays;
      end if;

      --  Day format
      if Has_Ovr and then Ovr.Has_Day_Format then
         E.Day_Format := Ovr.Day_Format;
         --  When override sets day_format but not exceptions,
         --  clear exceptions
         if Ovr.Has_Day_Format_Exceptions then
            E.Day_Format_Exception_Count :=
              Ovr.Day_Format_Exception_Count;
            E.Day_Format_Exception_Keys :=
              Ovr.Day_Format_Exception_Keys;
            E.Day_Format_Exception_Vals :=
              Ovr.Day_Format_Exception_Vals;
         else
            E.Day_Format_Exception_Count := 0;
         end if;
      else
         E.Day_Format := Loc.Day_Format;
         E.Day_Format_Exception_Count :=
           Loc.Day_Format_Exception_Count;
         E.Day_Format_Exception_Keys :=
           Loc.Day_Format_Exception_Keys;
         E.Day_Format_Exception_Vals :=
           Loc.Day_Format_Exception_Vals;
      end if;

      --  Patterns
      if Has_Ovr and then Ovr.Has_Date_Pattern then
         E.Date_Pattern := Ovr.Date_Pattern;
      else
         E.Date_Pattern := Loc.Date_Pattern;
      end if;

      if Has_Ovr and then Ovr.Has_Date_Pattern_With_Year then
         E.Date_Pattern_With_Year := Ovr.Date_Pattern_With_Year;
      else
         E.Date_Pattern_With_Year := Loc.Date_Pattern_With_Year;
      end if;

      --  Proximity strings
      if Has_Ovr and then Ovr.Has_Today then
         E.Today := Ovr.Today;
      else
         E.Today := Loc.Today;
      end if;

      if Has_Ovr and then Ovr.Has_Tomorrow then
         E.Tomorrow := Ovr.Tomorrow;
      else
         E.Tomorrow := Loc.Tomorrow;
      end if;

      if Has_Ovr and then Ovr.Has_Yesterday then
         E.Yesterday := Ovr.Yesterday;
      else
         E.Yesterday := Loc.Yesterday;
      end if;

      return E;
   end Build_Effective;

   function Find_Exception_Eff
     (E       : Effective_Locale;
      Day_Str : String) return String
   is
   begin
      for I in 1 .. E.Day_Format_Exception_Count loop
         if To_String (E.Day_Format_Exception_Keys (I)) = Day_Str
         then
            return To_String (E.Day_Format_Exception_Vals (I));
         end if;
      end loop;
      return "";
   end Find_Exception_Eff;

   function Format_Absolute
     (E            : Effective_Locale;
      Year         : Integer;
      Month        : Integer;
      Day          : Integer;
      Include_Year : Boolean) return String
   is
      Day_Str       : constant String := Int_To_Str (Day);
      Exc_Fmt       : constant String :=
        Find_Exception_Eff (E, Day_Str);
      Fmt           : Unbounded_String;
      Formatted_Day : Unbounded_String;
      Month_Name    : Unbounded_String;
      Pattern       : Unbounded_String;
      Result_Str    : Unbounded_String;
   begin
      if Exc_Fmt'Length > 0 then
         Fmt := To_Unbounded_String (Exc_Fmt);
      else
         Fmt := E.Day_Format;
      end if;

      Formatted_Day := To_Unbounded_String
        (Replace_First (To_String (Fmt), "{n}", Day_Str));

      if E.Has_Months_In_Date then
         Month_Name := E.Months_In_Date (Month);
      else
         Month_Name := E.Months (Month);
      end if;

      if Include_Year then
         Pattern := E.Date_Pattern_With_Year;
      else
         Pattern := E.Date_Pattern;
      end if;

      Result_Str := To_Unbounded_String
        (Replace_First
           (To_String (Pattern), "{month}",
            To_String (Month_Name)));
      Result_Str := To_Unbounded_String
        (Replace_First
           (To_String (Result_Str), "{day}",
            To_String (Formatted_Day)));
      Result_Str := To_Unbounded_String
        (Replace_First
           (To_String (Result_Str), "{d}", Day_Str));
      Result_Str := To_Unbounded_String
        (Replace_First
           (To_String (Result_Str), "{m}",
            Int_To_Str (Month)));

      if Include_Year then
         Result_Str := To_Unbounded_String
           (Replace_First
              (To_String (Result_Str), "{year}",
               Int_To_Str (Year)));
         Result_Str := To_Unbounded_String
           (Replace_First
              (To_String (Result_Str), "{yy}",
               Zfill_2 (Year mod 100)));
      end if;

      return To_String (Result_Str);
   end Format_Absolute;

   function Format_Date
     (Loc  : Date_Locale;
      Comp : Compactness;
      Date : String) return String
   is
      Parsed : Parse_Result;
      E      : Effective_Locale;
   begin
      if Date'Length = 0 then
         return "";
      end if;

      Parsed := Parse_Date_Str (Date);
      if not Parsed.OK then
         return "";
      end if;

      E := Build_Effective (Loc, Comp);
      return Format_Absolute
        (E, Parsed.Year, Parsed.Month, Parsed.Day,
         Include_Year => False);
   end Format_Date;

   function Format_Date_With_Year
     (Loc  : Date_Locale;
      Comp : Compactness;
      Date : String) return String
   is
      Parsed : Parse_Result;
      E      : Effective_Locale;
   begin
      if Date'Length = 0 then
         return "";
      end if;

      Parsed := Parse_Date_Str (Date);
      if not Parsed.OK then
         return "";
      end if;

      E := Build_Effective (Loc, Comp);
      return Format_Absolute
        (E, Parsed.Year, Parsed.Month, Parsed.Day,
         Include_Year => True);
   end Format_Date_With_Year;

   function Format_Relative
     (Loc   : Date_Locale;
      Comp  : Compactness;
      Date  : String;
      As_Of : String) return String
   is
      Date_P, Asof_P : Parse_Result;
      Date_JDN       : Integer;
      Asof_JDN       : Integer;
      Diff           : Integer;
      E              : Effective_Locale;
      DOW            : Integer;
      Weekday_Name   : Unbounded_String;
      Is_Compact     : Boolean;
   begin
      if Date'Length = 0 or else As_Of'Length = 0 then
         return "";
      end if;

      Date_P := Parse_Date_Str (Date);
      Asof_P := Parse_Date_Str (As_Of);
      if not Date_P.OK or else not Asof_P.OK then
         return "";
      end if;

      Date_JDN := Julian_Day
        (Date_P.Year, Date_P.Month, Date_P.Day);
      Asof_JDN := Julian_Day
        (Asof_P.Year, Asof_P.Month, Asof_P.Day);
      Diff := Date_JDN - Asof_JDN;

      E := Build_Effective (Loc, Comp);

      --  Today
      if Diff = 0 then
         return To_String (E.Today);
      end if;

      --  Tomorrow
      if Diff = 1 then
         return To_String (E.Tomorrow);
      end if;

      --  Yesterday
      if Diff = -1 then
         return To_String (E.Yesterday);
      end if;

      Is_Compact := Comp = Compact;

      --  Day after tomorrow
      if Diff = 2
        and then Loc.Has_Day_After_Tomorrow
        and then not Is_Compact
      then
         return To_String (Loc.Day_After_Tomorrow);
      end if;

      --  Day before yesterday
      if Diff = -2
        and then Loc.Has_Day_Before_Yesterday
        and then not Is_Compact
      then
         return To_String (Loc.Day_Before_Yesterday);
      end if;

      --  Compact: skip weekday references
      if Is_Compact then
         return Format_Absolute
           (E, Date_P.Year, Date_P.Month, Date_P.Day,
            Include_Year => Date_P.Year /= Asof_P.Year);
      end if;

      --  This weekday (+2 to +6)
      if Diff >= 2 and then Diff <= 6
        and then Loc.Has_This_Weekday
      then
         DOW := Weekday
           (Date_P.Year, Date_P.Month, Date_P.Day);
         Weekday_Name := E.Weekdays (DOW + 1);
         return Replace_First
           (To_String (Loc.This_Weekday),
            "{weekday}", To_String (Weekday_Name));
      end if;

      --  Last weekday (-2 to -6)
      if Diff >= -6 and then Diff <= -2
        and then Loc.Has_Last_Weekday
      then
         DOW := Weekday
           (Date_P.Year, Date_P.Month, Date_P.Day);
         Weekday_Name := E.Weekdays (DOW + 1);
         return Replace_First
           (To_String (Loc.Last_Weekday),
            "{weekday}", To_String (Weekday_Name));
      end if;

      --  Next weekday (+7 to +13)
      if Diff >= 7 and then Diff <= 13
        and then Loc.Has_Next_Weekday
      then
         DOW := Weekday
           (Date_P.Year, Date_P.Month, Date_P.Day);
         Weekday_Name := E.Weekdays (DOW + 1);
         return Replace_First
           (To_String (Loc.Next_Weekday),
            "{weekday}", To_String (Weekday_Name));
      end if;

      --  Calendar fallback
      return Format_Absolute
        (E, Date_P.Year, Date_P.Month, Date_P.Day,
         Include_Year => Date_P.Year /= Asof_P.Year);
   end Format_Relative;

end Sayabledate;
