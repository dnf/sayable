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
      Epoch_Seconds : Integer := 0;
      OK            : Boolean := False;
   end record;

   function Parse_ISO (S : String) return ISO_Result is
      R     : ISO_Result;
      Pos_T : Natural;
   begin
      if S'Length = 0 then
         return R;
      end if;

      Pos_T := Ada.Strings.Fixed.Index (S, "T");
      if Pos_T = 0 then
         return R;
      end if;

      --  Parse date part
      declare
         Date_Str : constant String :=
           S (S'First .. Pos_T - 1);
         Year     : Integer := 0;
         Month    : Integer := 0;
         Day      : Integer := 0;
      begin
         if Date_Str'Length < 10 then
            return R;
         end if;

         if Date_Str (Date_Str'First + 4) /= '-'
           or else Date_Str (Date_Str'First + 7) /= '-'
         then
            return R;
         end if;

         for I in 0 .. 3 loop
            if not Is_Digit (Date_Str (Date_Str'First + I))
            then
               return R;
            end if;
            Year := Year * 10
              + Character'Pos
                  (Date_Str (Date_Str'First + I))
              - Character'Pos ('0');
         end loop;

         for I in 5 .. 6 loop
            if not Is_Digit (Date_Str (Date_Str'First + I))
            then
               return R;
            end if;
            Month := Month * 10
              + Character'Pos
                  (Date_Str (Date_Str'First + I))
              - Character'Pos ('0');
         end loop;

         for I in 8 .. 9 loop
            if not Is_Digit (Date_Str (Date_Str'First + I))
            then
               return R;
            end if;
            Day := Day * 10
              + Character'Pos
                  (Date_Str (Date_Str'First + I))
              - Character'Pos ('0');
         end loop;

         --  Parse time part
         declare
            Time_Raw : constant String :=
              S (Pos_T + 1 .. S'Last);
            Time_Str : Unbounded_String :=
              To_Unbounded_String (Time_Raw);
            Pos_P    : Natural;
            Pos_Z    : Natural;
            Hour     : Integer := 0;
            Minute   : Integer := 0;
            Second   : Integer := 0;
         begin
            --  Strip timezone
            declare
               TS : constant String := To_String (Time_Str);
            begin
               Pos_P := Ada.Strings.Fixed.Index (TS, "+");
               if Pos_P > 0 then
                  Time_Str := To_Unbounded_String
                    (TS (TS'First .. Pos_P - 1));
               end if;
            end;

            declare
               TS : constant String := To_String (Time_Str);
            begin
               Pos_Z := Ada.Strings.Fixed.Index (TS, "Z");
               if Pos_Z > 0 then
                  Time_Str := To_Unbounded_String
                    (TS (TS'First .. Pos_Z - 1));
               end if;
            end;

            --  Split by colons
            declare
               TS     : constant String :=
                 To_String (Time_Str);
               Colon1 : Natural;
               Colon2 : Natural;
            begin
               Colon1 := Ada.Strings.Fixed.Index (TS, ":");
               if Colon1 = 0 then
                  return R;
               end if;

               --  Hour
               declare
                  H_Str : constant String :=
                    TS (TS'First .. Colon1 - 1);
               begin
                  for I in H_Str'Range loop
                     if not Is_Digit (H_Str (I)) then
                        return R;
                     end if;
                     Hour := Hour * 10
                       + Character'Pos (H_Str (I))
                       - Character'Pos ('0');
                  end loop;
               end;

               --  Minute and optional second
               declare
                  Rest : constant String :=
                    TS (Colon1 + 1 .. TS'Last);
               begin
                  Colon2 := Ada.Strings.Fixed.Index
                    (Rest, ":");
                  if Colon2 > 0 then
                     --  Has seconds
                     declare
                        M_Str : constant String :=
                          Rest (Rest'First .. Colon2 - 1);
                        S_Raw : constant String :=
                          Rest (Colon2 + 1 .. Rest'Last);
                        S_Str : Unbounded_String;
                        Dot   : Natural;
                     begin
                        for I in M_Str'Range loop
                           if not Is_Digit (M_Str (I)) then
                              return R;
                           end if;
                           Minute := Minute * 10
                             + Character'Pos (M_Str (I))
                             - Character'Pos ('0');
                        end loop;

                        --  Strip fractional seconds
                        Dot := Ada.Strings.Fixed.Index
                          (S_Raw, ".");
                        if Dot > 0 then
                           S_Str := To_Unbounded_String
                             (S_Raw
                                (S_Raw'First .. Dot - 1));
                        else
                           S_Str := To_Unbounded_String
                             (S_Raw);
                        end if;

                        declare
                           SS : constant String :=
                             To_String (S_Str);
                        begin
                           for I in SS'Range loop
                              if not Is_Digit (SS (I)) then
                                 return R;
                              end if;
                              Second := Second * 10
                                + Character'Pos (SS (I))
                                - Character'Pos ('0');
                           end loop;
                        end;
                     end;
                  else
                     --  No seconds
                     for I in Rest'Range loop
                        if not Is_Digit (Rest (I)) then
                           return R;
                        end if;
                        Minute := Minute * 10
                          + Character'Pos (Rest (I))
                          - Character'Pos ('0');
                     end loop;
                  end if;
               end;
            end;

            R.Epoch_Seconds :=
              Days_Since_Epoch (Year, Month, Day) * 86400
              + Hour * 3600 + Minute * 60 + Second;
            R.OK := True;
         end;
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
     (Loc   : Duration_Locale;
      Eff   : Effective;
      Total : Integer) return String
   is
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
      --  0 seconds
      if Total = 0 then
         return To_String (Eff.Just_Now);
      end if;

      --  1-59 seconds
      if Total < 60 then
         return Resolve_Unit (Total, Eff.Second, Loc, "");
      end if;

      Total_Minutes := Total / 60;
      Remainder_Seconds := Total mod 60;

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

      Total_Hours := Total / 3600;
      Remainder_Minutes := (Total mod 3600) / 60;

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

      Total_Days := Total / 86400;
      Remainder_Hours := (Total mod 86400) / 3600;

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
      Total_Months :=
        (Total_Days * 100 + 1522) / 3044;

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
      Seconds : Integer) return String
   is
      Eff : Effective;
   begin
      if Seconds < 0 then
         return "";
      end if;

      Eff := Build_Effective (Loc, Comp);
      return Format_Duration_Secs (Loc, Eff, Seconds);
   end Format_Duration;

   function Format_Since
     (Loc   : Duration_Locale;
      Comp  : Compactness;
      Start : String;
      As_Of : String) return String
   is
      S    : ISO_Result;
      A    : ISO_Result;
      Diff : Integer;
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
      Diff : Integer;
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
      return Replace_First
        (To_String (Eff.In_Future), "{0}", To_String (Dur));
   end Format_Until;

end Sayableduration;
