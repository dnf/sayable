with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Fixed;

package body Sayableage is

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

   function Julian_Day (Year, Month, Day : Integer) return Integer is
      A : constant Integer := (14 - Month) / 12;
      Y : constant Integer := Year + 4800 - A;
      M : constant Integer := Month + 12 * A - 3;
   begin
      return Day + (153 * M + 2) / 5 + 365 * Y + Y / 4 - Y / 100
        + Y / 400 - 32045;
   end Julian_Day;

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

   function Parse_Date (S : String) return Parse_Result is
      R : Parse_Result;
   begin
      if S'Length /= 10 then
         return R;
      end if;
      if S (S'First + 4) /= '-' or else S (S'First + 7) /= '-' then
         return R;
      end if;
      for I in 0 .. 3 loop
         if not Is_Digit (S (S'First + I)) then
            return R;
         end if;
         R.Year := R.Year * 10
           + Character'Pos (S (S'First + I)) - Character'Pos ('0');
      end loop;
      for I in 5 .. 6 loop
         if not Is_Digit (S (S'First + I)) then
            return R;
         end if;
         R.Month := R.Month * 10
           + Character'Pos (S (S'First + I)) - Character'Pos ('0');
      end loop;
      for I in 8 .. 9 loop
         if not Is_Digit (S (S'First + I)) then
            return R;
         end if;
         R.Day := R.Day * 10
           + Character'Pos (S (S'First + I)) - Character'Pos ('0');
      end loop;
      R.OK := R.Month in 1 .. 12
        and then R.Day in 1 .. Days_In_Month (R.Year, R.Month);
      return R;
   end Parse_Date;

   function Int_To_Str (N : Integer) return String is
      Raw : constant String := Ada.Strings.Fixed.Trim
        (Integer'Image (N), Ada.Strings.Left);
   begin
      return Raw;
   end Int_To_Str;

   function Replace_First
     (Tmpl : String; Marker : String; Replacement : String) return String
   is
      Pos : constant Natural := Ada.Strings.Fixed.Index (Tmpl, Marker);
   begin
      if Pos = 0 then
         return Tmpl;
      end if;
      return Tmpl (Tmpl'First .. Pos - 1) & Replacement
        & Tmpl (Pos + Marker'Length .. Tmpl'Last);
   end Replace_First;

   function Resolve_Unit
     (Count : Integer;
      UF    : Unit_Forms;
      Loc   : Locale;
      Half  : String) return String
   is
      Base_N  : constant String := Int_To_Str (Count);
      N_Str   : Unbounded_String;
      Tmpl    : Unbounded_String;
      Cat     : Plural_Category;
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
         Cat := Loc.Plural (Count);
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
        (Replace_First (To_String (Tmpl), "{n}", To_String (N_Str)));

      if Half'Length > 0
        and then Ada.Strings.Fixed.Index (Half, "{0}") > 0
      then
         return Replace_First (Half, "{0}", To_String (Result_Buf));
      else
         return To_String (Result_Buf);
      end if;
   end Resolve_Unit;

   function Format_Age
     (Loc   : Locale;
      Comp  : Compactness;
      DOB   : String;
      As_Of : String) return String
   is
      DOB_P, Ref_P : Parse_Result;
      Diff_Days    : Integer;
      Months       : Integer;
      Last_Day     : Integer;
      Clamped      : Integer;
      Weeks        : Integer;
      Days_Rem     : Integer;
      Years        : Integer;
      Rem_Months   : Integer;
      Day_UF       : Unit_Forms;
      Week_UF      : Unit_Forms;
      Month_UF     : Unit_Forms;
      Year_UF      : Unit_Forms;
      Half_Str     : Unbounded_String;
      Delim_Str    : Unbounded_String;
      JB_Str       : Unbounded_String;
      Ovr          : Compactness_Override;
      Part1, Part2 : Unbounded_String;
   begin
      if DOB'Length = 0 then
         return "";
      end if;
      DOB_P := Parse_Date (DOB);
      if not DOB_P.OK then
         return "";
      end if;
      if As_Of'Length = 0 then
         return "";
      end if;
      Ref_P := Parse_Date (As_Of);
      if not Ref_P.OK then
         return "";
      end if;

      Diff_Days := Julian_Day (Ref_P.Year, Ref_P.Month, Ref_P.Day)
        - Julian_Day (DOB_P.Year, DOB_P.Month, DOB_P.Day);
      if Diff_Days < 0 then
         return "";
      end if;

      Last_Day := Days_In_Month (Ref_P.Year, Ref_P.Month);
      Clamped := Integer'Min (DOB_P.Day, Last_Day);
      Months := (Ref_P.Year - DOB_P.Year) * 12
        + (Ref_P.Month - DOB_P.Month);
      if Ref_P.Day < Clamped then
         Months := Months - 1;
      end if;
      if Months > Max_Age_Months then
         return "";
      end if;

      Day_UF   := Loc.Units.Day;
      Week_UF  := Loc.Units.Week;
      Month_UF := Loc.Units.Month;
      Year_UF  := Loc.Units.Year;
      Half_Str := Loc.Half;
      Delim_Str := Loc.Delimiter;
      JB_Str   := Loc.Just_Born;

      if Comp = Short and then Loc.Has_Short then
         Ovr := Loc.Short_Override;
         if Ovr.Has_Day then
            Day_UF := Ovr.Day;
         end if;
         if Ovr.Has_Week then
            Week_UF := Ovr.Week;
         end if;
         if Ovr.Has_Month then
            Month_UF := Ovr.Month;
         end if;
         if Ovr.Has_Year then
            Year_UF := Ovr.Year;
         end if;
         if Ovr.Has_Half then
            Half_Str := Ovr.Half;
         end if;
         if Ovr.Has_Delimiter then
            Delim_Str := Ovr.Delimiter;
         end if;
         if Ovr.Has_Just_Born then
            JB_Str := Ovr.Just_Born;
         end if;
      elsif Comp = Compact and then Loc.Has_Compact then
         Ovr := Loc.Compact_Override;
         if Ovr.Has_Day then
            Day_UF := Ovr.Day;
         end if;
         if Ovr.Has_Week then
            Week_UF := Ovr.Week;
         end if;
         if Ovr.Has_Month then
            Month_UF := Ovr.Month;
         end if;
         if Ovr.Has_Year then
            Year_UF := Ovr.Year;
         end if;
         if Ovr.Has_Half then
            Half_Str := Ovr.Half;
         end if;
         if Ovr.Has_Delimiter then
            Delim_Str := Ovr.Delimiter;
         end if;
         if Ovr.Has_Just_Born then
            JB_Str := Ovr.Just_Born;
         end if;
      end if;

      --  Tier 1: 0 days
      if Diff_Days = 0 then
         return To_String (JB_Str);
      end if;

      --  Tier 1b: 1-6 days
      if Diff_Days < 7 then
         return Resolve_Unit (Diff_Days, Day_UF, Loc, "");
      end if;

      --  Tier 2: weeks + days until 3 calendar months
      if Months < 3 then
         Weeks := Diff_Days / 7;
         Days_Rem := Diff_Days mod 7;
         Part1 := To_Unbounded_String
           (Resolve_Unit (Weeks, Week_UF, Loc, ""));
         if Days_Rem > 0 then
            Part2 := To_Unbounded_String
              (Resolve_Unit (Days_Rem, Day_UF, Loc, ""));
            return To_String (Part1) & To_String (Delim_Str)
              & To_String (Part2);
         else
            return To_String (Part1);
         end if;
      end if;

      --  Tier 3: 3-23 months
      if Months < 24 then
         return Resolve_Unit (Months, Month_UF, Loc, "");
      end if;

      --  Tier 4: 24-35 months -> years + months
      if Months < 36 then
         Years := Months / 12;
         Rem_Months := Months mod 12;
         if Rem_Months = 0 then
            return Resolve_Unit (Years, Year_UF, Loc, "");
         else
            Part1 := To_Unbounded_String
              (Resolve_Unit (Years, Year_UF, Loc, ""));
            Part2 := To_Unbounded_String
              (Resolve_Unit (Rem_Months, Month_UF, Loc, ""));
            return To_String (Part1) & To_String (Delim_Str)
              & To_String (Part2);
         end if;
      end if;

      --  Tier 5: 3-6 years -> years with half marker
      if Months < 84 then
         Years := Months / 12;
         Rem_Months := Months mod 12;
         if Rem_Months >= 6 then
            return Resolve_Unit
              (Years, Year_UF, Loc, To_String (Half_Str));
         else
            return Resolve_Unit (Years, Year_UF, Loc, "");
         end if;
      end if;

      --  Tier 6: 7+ years
      Years := Months / 12;
      return Resolve_Unit (Years, Year_UF, Loc, "");
   end Format_Age;

   function Format_Stage
     (Loc    : Locale;
      DOB    : String;
      As_Of  : String;
      Gender : String := "") return String
   is
      DOB_P, Ref_P : Parse_Result;
      Diff_Days    : Integer;
      Months_Val   : Integer;
      Last_Day     : Integer;
      Clamped      : Integer;
      Stage        : Stage_Label;
      G            : Character := ' ';
   begin
      if DOB'Length = 0 then
         return "";
      end if;
      DOB_P := Parse_Date (DOB);
      if not DOB_P.OK then
         return "";
      end if;
      if As_Of'Length = 0 then
         return "";
      end if;
      Ref_P := Parse_Date (As_Of);
      if not Ref_P.OK then
         return "";
      end if;

      Diff_Days := Julian_Day (Ref_P.Year, Ref_P.Month, Ref_P.Day)
        - Julian_Day (DOB_P.Year, DOB_P.Month, DOB_P.Day);
      if Diff_Days < 0 then
         return "";
      end if;

      Last_Day := Days_In_Month (Ref_P.Year, Ref_P.Month);
      Clamped := Integer'Min (DOB_P.Day, Last_Day);
      Months_Val := (Ref_P.Year - DOB_P.Year) * 12
        + (Ref_P.Month - DOB_P.Month);
      if Ref_P.Day < Clamped then
         Months_Val := Months_Val - 1;
      end if;
      if Months_Val > Max_Age_Months then
         return "";
      end if;

      if Months_Val < 2 then
         Stage := Loc.Stage_Labels.Newborn;
      elsif Months_Val < 12 then
         Stage := Loc.Stage_Labels.Infant;
      elsif Months_Val < 36 then
         Stage := Loc.Stage_Labels.Toddler;
      elsif Months_Val < 156 then
         Stage := Loc.Stage_Labels.Child;
      elsif Months_Val < 216 then
         Stage := Loc.Stage_Labels.Teenager;
      else
         Stage := Loc.Stage_Labels.Adult;
      end if;

      if Gender'Length > 0 then
         G := Gender (Gender'First);
      end if;

      if G = 'f' and then Length (Stage.F_Label) > 0 then
         return To_String (Stage.F_Label);
      else
         return To_String (Stage.Label);
      end if;
   end Format_Stage;

end Sayableage;
