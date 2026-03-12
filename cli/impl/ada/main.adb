with Ada.Command_Line;
with Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Fixed;
with Ada.Calendar;
with Parenttime;
with Parenttime_Types;
with Parenttime_Locales;
with Sayabledate;
with Sayabledate_Types;
with Sayabledate_Locales;
with Sayabletime;
with Sayabletime_Types;
with Sayabletime_Locales;
with Sayableduration;
with Sayableduration_Types;
with Sayableduration_Locales;

procedure Main is

   use Ada.Command_Line;
   use Ada.Text_IO;
   use type Parenttime_Types.Locale_Access;
   use type Sayabledate_Types.Locale_Access;
   use type Sayabletime_Types.Locale_Access;
   use type Sayableduration_Types.Locale_Access;

   Version : constant String := "0.5.0";

   --  Locale codes sorted alphabetically (110 locales)
   type Locale_Code_Array is array (Positive range <>) of
     Unbounded_String;
   All_Locales : constant Locale_Code_Array :=
     (To_Unbounded_String ("af"),
      To_Unbounded_String ("ak"),
      To_Unbounded_String ("am"),
      To_Unbounded_String ("ar"),
      To_Unbounded_String ("az"),
      To_Unbounded_String ("bci"),
      To_Unbounded_String ("be"),
      To_Unbounded_String ("bem"),
      To_Unbounded_String ("bg"),
      To_Unbounded_String ("bi"),
      To_Unbounded_String ("bm"),
      To_Unbounded_String ("bn"),
      To_Unbounded_String ("br"),
      To_Unbounded_String ("bs"),
      To_Unbounded_String ("ca"),
      To_Unbounded_String ("ceb"),
      To_Unbounded_String ("cs"),
      To_Unbounded_String ("cy"),
      To_Unbounded_String ("da"),
      To_Unbounded_String ("de"),
      To_Unbounded_String ("din"),
      To_Unbounded_String ("dje"),
      To_Unbounded_String ("dyu"),
      To_Unbounded_String ("ee"),
      To_Unbounded_String ("el"),
      To_Unbounded_String ("en"),
      To_Unbounded_String ("es"),
      To_Unbounded_String ("et"),
      To_Unbounded_String ("eu"),
      To_Unbounded_String ("fa"),
      To_Unbounded_String ("fan"),
      To_Unbounded_String ("ff"),
      To_Unbounded_String ("fi"),
      To_Unbounded_String ("fil"),
      To_Unbounded_String ("fj"),
      To_Unbounded_String ("fon"),
      To_Unbounded_String ("fr"),
      To_Unbounded_String ("ga"),
      To_Unbounded_String ("gd"),
      To_Unbounded_String ("gl"),
      To_Unbounded_String ("gn"),
      To_Unbounded_String ("gu"),
      To_Unbounded_String ("gv"),
      To_Unbounded_String ("ha"),
      To_Unbounded_String ("he"),
      To_Unbounded_String ("hi"),
      To_Unbounded_String ("hr"),
      To_Unbounded_String ("ht"),
      To_Unbounded_String ("hu"),
      To_Unbounded_String ("hy"),
      To_Unbounded_String ("id"),
      To_Unbounded_String ("ig"),
      To_Unbounded_String ("is"),
      To_Unbounded_String ("it"),
      To_Unbounded_String ("ja"),
      To_Unbounded_String ("jv"),
      To_Unbounded_String ("ka"),
      To_Unbounded_String ("kbp"),
      To_Unbounded_String ("kk"),
      To_Unbounded_String ("km"),
      To_Unbounded_String ("kn"),
      To_Unbounded_String ("ko"),
      To_Unbounded_String ("kpe"),
      To_Unbounded_String ("ktu"),
      To_Unbounded_String ("ku"),
      To_Unbounded_String ("kw"),
      To_Unbounded_String ("ky"),
      To_Unbounded_String ("lg"),
      To_Unbounded_String ("ln"),
      To_Unbounded_String ("lo"),
      To_Unbounded_String ("lt"),
      To_Unbounded_String ("lv"),
      To_Unbounded_String ("men"),
      To_Unbounded_String ("mfe"),
      To_Unbounded_String ("mg"),
      To_Unbounded_String ("mi"),
      To_Unbounded_String ("mk"),
      To_Unbounded_String ("ml"),
      To_Unbounded_String ("mn"),
      To_Unbounded_String ("mnk"),
      To_Unbounded_String ("mos"),
      To_Unbounded_String ("mr"),
      To_Unbounded_String ("ms"),
      To_Unbounded_String ("mt"),
      To_Unbounded_String ("my"),
      To_Unbounded_String ("nb"),
      To_Unbounded_String ("nd"),
      To_Unbounded_String ("ne"),
      To_Unbounded_String ("ng"),
      To_Unbounded_String ("nl"),
      To_Unbounded_String ("nso"),
      To_Unbounded_String ("nus"),
      To_Unbounded_String ("ny"),
      To_Unbounded_String ("om"),
      To_Unbounded_String ("or"),
      To_Unbounded_String ("pa"),
      To_Unbounded_String ("pis"),
      To_Unbounded_String ("pl"),
      To_Unbounded_String ("pov"),
      To_Unbounded_String ("ps"),
      To_Unbounded_String ("pt"),
      To_Unbounded_String ("qu"),
      To_Unbounded_String ("ro"),
      To_Unbounded_String ("ru"),
      To_Unbounded_String ("rw"),
      To_Unbounded_String ("sar"),
      To_Unbounded_String ("sd"),
      To_Unbounded_String ("sg"),
      To_Unbounded_String ("shi"),
      To_Unbounded_String ("si"),
      To_Unbounded_String ("sk"),
      To_Unbounded_String ("sl"),
      To_Unbounded_String ("sn"),
      To_Unbounded_String ("snk"),
      To_Unbounded_String ("so"),
      To_Unbounded_String ("sq"),
      To_Unbounded_String ("sr"),
      To_Unbounded_String ("ss"),
      To_Unbounded_String ("st"),
      To_Unbounded_String ("su"),
      To_Unbounded_String ("suk"),
      To_Unbounded_String ("sv"),
      To_Unbounded_String ("sw"),
      To_Unbounded_String ("ta"),
      To_Unbounded_String ("te"),
      To_Unbounded_String ("tem"),
      To_Unbounded_String ("tg"),
      To_Unbounded_String ("th"),
      To_Unbounded_String ("ti"),
      To_Unbounded_String ("tig"),
      To_Unbounded_String ("tk"),
      To_Unbounded_String ("tn"),
      To_Unbounded_String ("tpi"),
      To_Unbounded_String ("tr"),
      To_Unbounded_String ("ts"),
      To_Unbounded_String ("tzm"),
      To_Unbounded_String ("uk"),
      To_Unbounded_String ("umb"),
      To_Unbounded_String ("ur"),
      To_Unbounded_String ("uz"),
      To_Unbounded_String ("vi"),
      To_Unbounded_String ("vmw"),
      To_Unbounded_String ("wo"),
      To_Unbounded_String ("xh"),
      To_Unbounded_String ("yo"),
      To_Unbounded_String ("yue"),
      To_Unbounded_String ("zdj"),
      To_Unbounded_String ("zh"),
      To_Unbounded_String ("zu"));

   --  Parsed arguments
   type Compactness_Kind is (Normal, Short, Compact);

   Max_Positionals : constant := 8;
   type Positional_Array is array (1 .. Max_Positionals) of
     Unbounded_String;

   type Parsed_Args is record
      Command       : Unbounded_String := Null_Unbounded_String;
      Positionals   : Positional_Array;
      Pos_Count     : Natural := 0;
      Locale_Code   : Unbounded_String :=
        To_Unbounded_String ("en");
      As_Of         : Unbounded_String := Null_Unbounded_String;
      Has_As_Of     : Boolean := False;
      Gender        : Unbounded_String := Null_Unbounded_String;
      Compactness   : Compactness_Kind := Normal;
      With_Year     : Boolean := False;
      Parse_Error   : Boolean := False;
   end record;

   procedure Print_Error (Msg : String) is
   begin
      Put_Line (Standard_Error, "error: " & Msg);
      Put_Line (Standard_Error, "Run 'sayable help' for usage.");
   end Print_Error;

   procedure Print_Help is
   begin
      Put_Line ("Usage: sayable <command> [arguments] [options]");
      New_Line;
      Put_Line ("Commands:");
      Put_Line ("  age <dob>              Format an age");
      Put_Line ("  stage <dob>            Get developmental stage");
      Put_Line ("  date <date>            Format a calendar date");
      Put_Line ("  relative <date>        Format a relative date");
      Put_Line ("  time <time>            Format a clock time");
      Put_Line ("  duration <value> [end] Format a duration");
      Put_Line ("  since <start>          Format elapsed time");
      Put_Line ("  until <target>         Format remaining time");
      Put_Line ("  locales                List available locale codes");
      Put_Line ("  version                Show version");
      Put_Line ("  help                   Show this help");
      New_Line;
      Put_Line ("Options:");
      Put_Line ("  -l, --locale <code>    Locale code (default: en)");
      Put_Line ("  -d, --as-of <value>    Reference date/timestamp");
      Put_Line ("      --short            Short compactness");
      Put_Line ("      --compact          Compact compactness");
      Put_Line ("  -g, --gender <m|f>     Gender for stage labels");
      Put_Line ("      --with-year        Include year (date only)");
      Put_Line ("  -h, --help             Show this help");
      Put_Line ("  -v, --version          Show version");
   end Print_Help;

   function Is_Null (S : String) return Boolean is
   begin
      return S = "null";
   end Is_Null;

   function Get_Today return String is
      Now  : constant Ada.Calendar.Time := Ada.Calendar.Clock;
      Year : Ada.Calendar.Year_Number;
      Mon  : Ada.Calendar.Month_Number;
      Day  : Ada.Calendar.Day_Number;
      Secs : Ada.Calendar.Day_Duration;
   begin
      Ada.Calendar.Split (Now, Year, Mon, Day, Secs);
      declare
         Y_Str : constant String :=
           Ada.Strings.Fixed.Trim
             (Integer'Image (Year), Ada.Strings.Left);
         M_Str : constant String :=
           Ada.Strings.Fixed.Trim
             (Integer'Image (Mon), Ada.Strings.Left);
         D_Str : constant String :=
           Ada.Strings.Fixed.Trim
             (Integer'Image (Day), Ada.Strings.Left);
         YS    : constant String (1 .. 4) :=
           (1 .. 4 - Y_Str'Length => '0') & Y_Str;
         MS    : constant String (1 .. 2) :=
           (1 .. 2 - M_Str'Length => '0') & M_Str;
         DS    : constant String (1 .. 2) :=
           (1 .. 2 - D_Str'Length => '0') & D_Str;
      begin
         return YS & "-" & MS & "-" & DS;
      end;
   end Get_Today;

   function Is_Digit (C : Character) return Boolean is
   begin
      return C >= '0' and then C <= '9';
   end Is_Digit;

   function Is_All_Digits (S : String) return Boolean is
   begin
      if S'Length = 0 then
         return False;
      end if;
      for I in S'Range loop
         if not Is_Digit (S (I)) then
            return False;
         end if;
      end loop;
      return True;
   end Is_All_Digits;

   function Is_Negative_Integer (S : String) return Boolean is
   begin
      if S'Length < 2 then
         return False;
      end if;
      if S (S'First) /= '-' then
         return False;
      end if;
      return Is_All_Digits (S (S'First + 1 .. S'Last));
   end Is_Negative_Integer;

   function Parse_Int (S : String) return Integer is
      Neg : Boolean := False;
      Val : Integer := 0;
      Start : Integer;
   begin
      Start := S'First;
      if S (Start) = '-' then
         Neg := True;
         Start := Start + 1;
      end if;
      for I in Start .. S'Last loop
         Val := Val * 10
           + Character'Pos (S (I)) - Character'Pos ('0');
      end loop;
      if Neg then
         return -Val;
      else
         return Val;
      end if;
   end Parse_Int;

   --  Parse ISO 8601 datetime to epoch seconds (relative to 2000-01-01)
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
            if not Is_Digit (Date_Str (Date_Str'First + I)) then
               return R;
            end if;
            Year := Year * 10
              + Character'Pos (Date_Str (Date_Str'First + I))
              - Character'Pos ('0');
         end loop;

         for I in 5 .. 6 loop
            if not Is_Digit (Date_Str (Date_Str'First + I)) then
               return R;
            end if;
            Month := Month * 10
              + Character'Pos (Date_Str (Date_Str'First + I))
              - Character'Pos ('0');
         end loop;

         for I in 8 .. 9 loop
            if not Is_Digit (Date_Str (Date_Str'First + I)) then
               return R;
            end if;
            Day := Day * 10
              + Character'Pos (Date_Str (Date_Str'First + I))
              - Character'Pos ('0');
         end loop;

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
            --  Strip timezone (+)
            declare
               TS : constant String := To_String (Time_Str);
            begin
               Pos_P := Ada.Strings.Fixed.Index (TS, "+");
               if Pos_P > 0 then
                  Time_Str := To_Unbounded_String
                    (TS (TS'First .. Pos_P - 1));
               end if;
            end;

            --  Strip Z
            declare
               TS : constant String := To_String (Time_Str);
            begin
               Pos_Z := Ada.Strings.Fixed.Index (TS, "Z");
               if Pos_Z > 0 then
                  Time_Str := To_Unbounded_String
                    (TS (TS'First .. Pos_Z - 1));
               end if;
            end;

            --  Parse HH:MM[:SS]
            declare
               TS     : constant String := To_String (Time_Str);
               Colon1 : Natural;
            begin
               Colon1 := Ada.Strings.Fixed.Index (TS, ":");
               if Colon1 = 0 then
                  return R;
               end if;

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

               declare
                  Rest   : constant String :=
                    TS (Colon1 + 1 .. TS'Last);
                  Colon2 : Natural;
               begin
                  Colon2 := Ada.Strings.Fixed.Index (Rest, ":");
                  if Colon2 > 0 then
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

                        Dot := Ada.Strings.Fixed.Index
                          (S_Raw, ".");
                        if Dot > 0 then
                           S_Str := To_Unbounded_String
                             (S_Raw (S_Raw'First .. Dot - 1));
                        else
                           S_Str := To_Unbounded_String (S_Raw);
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

   function Parse_Arguments return Parsed_Args is
      Args     : Parsed_Args;
      I        : Integer;
      Stop_Opt : Boolean := False;
      Arg      : Unbounded_String;
   begin
      if Argument_Count = 0 then
         Args.Command := Null_Unbounded_String;
         return Args;
      end if;

      --  Check for global flags as first argument
      declare
         First : constant String := Argument (1);
      begin
         if First = "-h" or else First = "--help"
           or else First = "help"
         then
            Args.Command := To_Unbounded_String ("help");
            return Args;
         end if;
         if First = "-v" or else First = "--version"
           or else First = "version"
         then
            Args.Command := To_Unbounded_String ("version");
            return Args;
         end if;
      end;

      Args.Command := To_Unbounded_String (Argument (1));

      I := 2;
      while I <= Argument_Count loop
         Arg := To_Unbounded_String (Argument (I));
         declare
            A : constant String := To_String (Arg);
         begin
            if A = "--" and then not Stop_Opt then
               Stop_Opt := True;
               I := I + 1;

            elsif not Stop_Opt
              and then A'Length > 0
              and then A (A'First) = '-'
              and then A'Length > 1
            then
               if A = "-l" or else A = "--locale" then
                  if I + 1 > Argument_Count then
                     Print_Error ("'--locale' requires a value");
                     Args.Parse_Error := True;
                     return Args;
                  end if;
                  I := I + 1;
                  Args.Locale_Code :=
                    To_Unbounded_String (Argument (I));

               elsif A = "-d" or else A = "--as-of" then
                  if I + 1 > Argument_Count then
                     Print_Error ("'--as-of' requires a value");
                     Args.Parse_Error := True;
                     return Args;
                  end if;
                  I := I + 1;
                  Args.As_Of :=
                    To_Unbounded_String (Argument (I));
                  Args.Has_As_Of := True;

               elsif A = "-g" or else A = "--gender" then
                  if I + 1 > Argument_Count then
                     Print_Error ("'--gender' requires a value");
                     Args.Parse_Error := True;
                     return Args;
                  end if;
                  I := I + 1;
                  Args.Gender :=
                    To_Unbounded_String (Argument (I));

               elsif A = "--short" then
                  Args.Compactness := Short;

               elsif A = "--compact" then
                  Args.Compactness := Compact;

               elsif A = "--with-year" then
                  Args.With_Year := True;

               elsif A = "-h" or else A = "--help" then
                  Args.Command := To_Unbounded_String ("help");
                  return Args;

               elsif A = "-v" or else A = "--version" then
                  Args.Command := To_Unbounded_String ("version");
                  return Args;

               else
                  Print_Error ("unknown option '" & A & "'");
                  Args.Parse_Error := True;
                  return Args;
               end if;

               I := I + 1;

            else
               if Args.Pos_Count < Max_Positionals then
                  Args.Pos_Count := Args.Pos_Count + 1;
                  Args.Positionals (Args.Pos_Count) :=
                    To_Unbounded_String (A);
               end if;
               I := I + 1;
            end if;
         end;
      end loop;

      return Args;
   end Parse_Arguments;

   function To_Age_Compactness
     (C : Compactness_Kind)
      return Parenttime_Types.Compactness
   is
   begin
      case C is
         when Normal  => return Parenttime_Types.Normal;
         when Short   => return Parenttime_Types.Short;
         when Compact => return Parenttime_Types.Compact;
      end case;
   end To_Age_Compactness;

   function To_Date_Compactness
     (C : Compactness_Kind)
      return Sayabledate_Types.Compactness
   is
   begin
      case C is
         when Normal  => return Sayabledate_Types.Normal;
         when Short   => return Sayabledate_Types.Short;
         when Compact => return Sayabledate_Types.Compact;
      end case;
   end To_Date_Compactness;

   function To_Time_Compactness
     (C : Compactness_Kind)
      return Sayabletime_Types.Compactness
   is
   begin
      case C is
         when Normal  => return Sayabletime_Types.Normal;
         when Short   => return Sayabletime_Types.Short;
         when Compact => return Sayabletime_Types.Compact;
      end case;
   end To_Time_Compactness;

   function To_Duration_Compactness
     (C : Compactness_Kind)
      return Sayableduration_Types.Compactness
   is
   begin
      case C is
         when Normal  => return Sayableduration_Types.Normal;
         when Short   => return Sayableduration_Types.Short;
         when Compact => return Sayableduration_Types.Compact;
      end case;
   end To_Duration_Compactness;

   --  Command handlers
   function Cmd_Age (Args : Parsed_Args) return Integer is
      Loc_Ptr : Parenttime_Types.Locale_Access;
      As_Of   : Unbounded_String;
      Result  : Unbounded_String;
   begin
      if Args.Pos_Count < 1 then
         Print_Error ("age requires a date-of-birth argument");
         return 2;
      end if;

      declare
         DOB : constant String :=
           To_String (Args.Positionals (1));
      begin
         if Is_Null (DOB) then
            return 1;
         end if;

         if DOB'Length = 0 then
            return 1;
         end if;

         Loc_Ptr := Parenttime_Locales.Get_Locale
           (To_String (Args.Locale_Code));
         if Loc_Ptr = null then
            Print_Error
              ("unknown locale '"
               & To_String (Args.Locale_Code) & "'");
            return 2;
         end if;

         if Args.Has_As_Of then
            declare
               AO : constant String := To_String (Args.As_Of);
            begin
               if Is_Null (AO) then
                  return 1;
               end if;
               As_Of := To_Unbounded_String (AO);
            end;
         else
            As_Of := To_Unbounded_String (Get_Today);
         end if;

         Result := To_Unbounded_String
           (Parenttime.Format_Age
              (Loc_Ptr.all,
               To_Age_Compactness (Args.Compactness),
               DOB,
               To_String (As_Of)));

         if Length (Result) = 0 then
            return 1;
         end if;

         Put_Line (To_String (Result));
         return 0;
      end;
   end Cmd_Age;

   function Cmd_Stage (Args : Parsed_Args) return Integer is
      Loc_Ptr : Parenttime_Types.Locale_Access;
      As_Of   : Unbounded_String;
      Result  : Unbounded_String;
   begin
      if Args.Pos_Count < 1 then
         Print_Error ("stage requires a date-of-birth argument");
         return 2;
      end if;

      declare
         DOB : constant String :=
           To_String (Args.Positionals (1));
      begin
         if Is_Null (DOB) then
            return 1;
         end if;

         if DOB'Length = 0 then
            return 1;
         end if;

         Loc_Ptr := Parenttime_Locales.Get_Locale
           (To_String (Args.Locale_Code));
         if Loc_Ptr = null then
            Print_Error
              ("unknown locale '"
               & To_String (Args.Locale_Code) & "'");
            return 2;
         end if;

         if Args.Has_As_Of then
            declare
               AO : constant String := To_String (Args.As_Of);
            begin
               if Is_Null (AO) then
                  return 1;
               end if;
               As_Of := To_Unbounded_String (AO);
            end;
         else
            As_Of := To_Unbounded_String (Get_Today);
         end if;

         Result := To_Unbounded_String
           (Parenttime.Format_Stage
              (Loc_Ptr.all,
               DOB,
               To_String (As_Of),
               To_String (Args.Gender)));

         if Length (Result) = 0 then
            return 1;
         end if;

         Put_Line (To_String (Result));
         return 0;
      end;
   end Cmd_Stage;

   function Cmd_Date (Args : Parsed_Args) return Integer is
      Loc_Ptr : Sayabledate_Types.Locale_Access;
      Result  : Unbounded_String;
   begin
      if Args.Pos_Count < 1 then
         Print_Error ("date requires a date argument");
         return 2;
      end if;

      declare
         Date_Val : constant String :=
           To_String (Args.Positionals (1));
      begin
         if Is_Null (Date_Val) then
            return 1;
         end if;

         if Date_Val'Length = 0 then
            return 1;
         end if;

         Loc_Ptr := Sayabledate_Locales.Get_Locale
           (To_String (Args.Locale_Code));
         if Loc_Ptr = null then
            Print_Error
              ("unknown locale '"
               & To_String (Args.Locale_Code) & "'");
            return 2;
         end if;

         if Args.With_Year then
            Result := To_Unbounded_String
              (Sayabledate.Format_Date_With_Year
                 (Loc_Ptr.all,
                  To_Date_Compactness (Args.Compactness),
                  Date_Val));
         else
            Result := To_Unbounded_String
              (Sayabledate.Format_Date
                 (Loc_Ptr.all,
                  To_Date_Compactness (Args.Compactness),
                  Date_Val));
         end if;

         if Length (Result) = 0 then
            return 1;
         end if;

         Put_Line (To_String (Result));
         return 0;
      end;
   end Cmd_Date;

   function Cmd_Relative (Args : Parsed_Args) return Integer is
      Loc_Ptr : Sayabledate_Types.Locale_Access;
      Result  : Unbounded_String;
   begin
      if Args.Pos_Count < 1 then
         Print_Error ("relative requires a date argument");
         return 2;
      end if;

      declare
         Date_Val : constant String :=
           To_String (Args.Positionals (1));
      begin
         if Is_Null (Date_Val) then
            return 1;
         end if;

         if not Args.Has_As_Of then
            Print_Error ("relative requires --as-of / -d option");
            return 2;
         end if;

         declare
            As_Of : constant String := To_String (Args.As_Of);
         begin
            if Is_Null (As_Of) then
               return 1;
            end if;

            Loc_Ptr := Sayabledate_Locales.Get_Locale
              (To_String (Args.Locale_Code));
            if Loc_Ptr = null then
               Print_Error
                 ("unknown locale '"
                  & To_String (Args.Locale_Code) & "'");
               return 2;
            end if;

            Result := To_Unbounded_String
              (Sayabledate.Format_Relative
                 (Loc_Ptr.all,
                  To_Date_Compactness (Args.Compactness),
                  Date_Val,
                  As_Of));

            if Length (Result) = 0 then
               return 1;
            end if;

            Put_Line (To_String (Result));
            return 0;
         end;
      end;
   end Cmd_Relative;

   function Cmd_Time (Args : Parsed_Args) return Integer is
      Loc_Ptr : Sayabletime_Types.Locale_Access;
      Result  : Unbounded_String;
   begin
      if Args.Pos_Count < 1 then
         Print_Error ("time requires a time argument");
         return 2;
      end if;

      declare
         Time_Val : constant String :=
           To_String (Args.Positionals (1));
      begin
         if Is_Null (Time_Val) then
            return 1;
         end if;

         if Time_Val'Length = 0 then
            return 1;
         end if;

         Loc_Ptr := Sayabletime_Locales.Get_Locale
           (To_String (Args.Locale_Code));
         if Loc_Ptr = null then
            Print_Error
              ("unknown locale '"
               & To_String (Args.Locale_Code) & "'");
            return 2;
         end if;

         Result := To_Unbounded_String
           (Sayabletime.Format_Time
              (Loc_Ptr.all,
               To_Time_Compactness (Args.Compactness),
               Time_Val));

         if Length (Result) = 0 then
            return 1;
         end if;

         Put_Line (To_String (Result));
         return 0;
      end;
   end Cmd_Time;

   function Cmd_Duration (Args : Parsed_Args) return Integer is
      Loc_Ptr : Sayableduration_Types.Locale_Access;
      Result  : Unbounded_String;
   begin
      if Args.Pos_Count < 1 then
         Print_Error ("duration requires a value argument");
         return 2;
      end if;

      declare
         Value : constant String :=
           To_String (Args.Positionals (1));
      begin
         if Is_Null (Value) then
            return 1;
         end if;

         Loc_Ptr := Sayableduration_Locales.Get_Locale
           (To_String (Args.Locale_Code));
         if Loc_Ptr = null then
            Print_Error
              ("unknown locale '"
               & To_String (Args.Locale_Code) & "'");
            return 2;
         end if;

         if Is_All_Digits (Value) then
            --  Seconds mode (non-negative integer)
            Result := To_Unbounded_String
              (Sayableduration.Format_Duration
                 (Loc_Ptr.all,
                  To_Duration_Compactness (Args.Compactness),
                  Parse_Int (Value)));

         elsif Is_Negative_Integer (Value) then
            --  Negative integer: returns null
            Result := To_Unbounded_String
              (Sayableduration.Format_Duration
                 (Loc_Ptr.all,
                  To_Duration_Compactness (Args.Compactness),
                  Parse_Int (Value)));

         else
            --  Timestamp mode: parse both ISO timestamps
            if Args.Pos_Count < 2 then
               Print_Error
                 ("duration with timestamps requires " &
                  "start and end arguments");
               return 2;
            end if;

            declare
               End_Val : constant String :=
                 To_String (Args.Positionals (2));
               S_ISO   : ISO_Result;
               E_ISO   : ISO_Result;
               Diff    : Integer;
            begin
               if Is_Null (End_Val) then
                  return 1;
               end if;

               S_ISO := Parse_ISO (Value);
               E_ISO := Parse_ISO (End_Val);

               if not S_ISO.OK or else not E_ISO.OK then
                  return 1;
               end if;

               Diff := E_ISO.Epoch_Seconds - S_ISO.Epoch_Seconds;
               if Diff < 0 then
                  return 1;
               end if;

               Result := To_Unbounded_String
                 (Sayableduration.Format_Duration
                    (Loc_Ptr.all,
                     To_Duration_Compactness (Args.Compactness),
                     Diff));
            end;
         end if;

         if Length (Result) = 0 then
            return 1;
         end if;

         Put_Line (To_String (Result));
         return 0;
      end;
   end Cmd_Duration;

   function Cmd_Since (Args : Parsed_Args) return Integer is
      Loc_Ptr : Sayableduration_Types.Locale_Access;
      Result  : Unbounded_String;
   begin
      if Args.Pos_Count < 1 then
         Print_Error
           ("since requires a start timestamp argument");
         return 2;
      end if;

      declare
         Start : constant String :=
           To_String (Args.Positionals (1));
      begin
         if Is_Null (Start) then
            return 1;
         end if;

         if not Args.Has_As_Of then
            Print_Error ("since requires --as-of / -d option");
            return 2;
         end if;

         declare
            As_Of : constant String := To_String (Args.As_Of);
         begin
            if Is_Null (As_Of) then
               return 1;
            end if;

            Loc_Ptr := Sayableduration_Locales.Get_Locale
              (To_String (Args.Locale_Code));
            if Loc_Ptr = null then
               Print_Error
                 ("unknown locale '"
                  & To_String (Args.Locale_Code) & "'");
               return 2;
            end if;

            Result := To_Unbounded_String
              (Sayableduration.Format_Since
                 (Loc_Ptr.all,
                  To_Duration_Compactness (Args.Compactness),
                  Start,
                  As_Of));

            if Length (Result) = 0 then
               return 1;
            end if;

            Put_Line (To_String (Result));
            return 0;
         end;
      end;
   end Cmd_Since;

   function Cmd_Until (Args : Parsed_Args) return Integer is
      Loc_Ptr : Sayableduration_Types.Locale_Access;
      Result  : Unbounded_String;
   begin
      if Args.Pos_Count < 1 then
         Print_Error
           ("until requires a target timestamp argument");
         return 2;
      end if;

      declare
         Target : constant String :=
           To_String (Args.Positionals (1));
      begin
         if Is_Null (Target) then
            return 1;
         end if;

         if not Args.Has_As_Of then
            Print_Error ("until requires --as-of / -d option");
            return 2;
         end if;

         declare
            As_Of : constant String := To_String (Args.As_Of);
         begin
            if Is_Null (As_Of) then
               return 1;
            end if;

            Loc_Ptr := Sayableduration_Locales.Get_Locale
              (To_String (Args.Locale_Code));
            if Loc_Ptr = null then
               Print_Error
                 ("unknown locale '"
                  & To_String (Args.Locale_Code) & "'");
               return 2;
            end if;

            Result := To_Unbounded_String
              (Sayableduration.Format_Until
                 (Loc_Ptr.all,
                  To_Duration_Compactness (Args.Compactness),
                  Target,
                  As_Of));

            if Length (Result) = 0 then
               return 1;
            end if;

            Put_Line (To_String (Result));
            return 0;
         end;
      end;
   end Cmd_Until;

   procedure Cmd_Locales is
   begin
      for I in All_Locales'Range loop
         Put_Line (To_String (All_Locales (I)));
      end loop;
   end Cmd_Locales;

   Args    : Parsed_Args;
   Exit_RC : Integer;
   Cmd     : Unbounded_String;

begin
   Args := Parse_Arguments;

   if Args.Parse_Error then
      Set_Exit_Status (Ada.Command_Line.Exit_Status (2));
      return;
   end if;

   Cmd := Args.Command;

   if Length (Cmd) = 0 then
      Print_Help;
      Set_Exit_Status (Ada.Command_Line.Exit_Status (2));
      return;
   end if;

   declare
      C : constant String := To_String (Cmd);
   begin
      if C = "help" then
         Print_Help;
         Set_Exit_Status (Ada.Command_Line.Exit_Status (0));
         return;
      end if;

      if C = "version" then
         Put_Line ("sayable " & Version);
         Set_Exit_Status (Ada.Command_Line.Exit_Status (0));
         return;
      end if;

      if C = "locales" then
         Cmd_Locales;
         Set_Exit_Status (Ada.Command_Line.Exit_Status (0));
         return;
      end if;

      if C = "age" then
         Exit_RC := Cmd_Age (Args);
      elsif C = "stage" then
         Exit_RC := Cmd_Stage (Args);
      elsif C = "date" then
         Exit_RC := Cmd_Date (Args);
      elsif C = "relative" then
         Exit_RC := Cmd_Relative (Args);
      elsif C = "time" then
         Exit_RC := Cmd_Time (Args);
      elsif C = "duration" then
         Exit_RC := Cmd_Duration (Args);
      elsif C = "since" then
         Exit_RC := Cmd_Since (Args);
      elsif C = "until" then
         Exit_RC := Cmd_Until (Args);
      else
         Print_Error ("unknown command '" & C & "'");
         Exit_RC := 2;
      end if;

      Set_Exit_Status (Ada.Command_Line.Exit_Status (Exit_RC));
   end;
end Main;
