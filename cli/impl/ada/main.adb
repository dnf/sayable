with Ada.Command_Line;
with Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Fixed;
with Ada.Calendar;
with Ada.Exceptions;
with GNAT.OS_Lib;
with Sayableage;
with Sayableage_Types;
with Sayableage_Locales;
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
   use type Sayableage_Types.Locale_Access;
   use type Sayabledate_Types.Locale_Access;
   use type Sayabletime_Types.Locale_Access;
   use type Sayableduration_Types.Locale_Access;

   Version : constant String := "0.5.0";

   --  Locale codes sorted alphabetically (168 locales)
   type Locale_Code_Array is array (Positive range <>) of
     Unbounded_String;
   All_Locales : constant Locale_Code_Array :=
     (To_Unbounded_String ("af"),
      To_Unbounded_String ("ak"),
      To_Unbounded_String ("am"),
      To_Unbounded_String ("ar"),
      To_Unbounded_String ("ay"),
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
      To_Unbounded_String ("cak"),
      To_Unbounded_String ("ceb"),
      To_Unbounded_String ("cs"),
      To_Unbounded_String ("cy"),
      To_Unbounded_String ("da"),
      To_Unbounded_String ("de"),
      To_Unbounded_String ("din"),
      To_Unbounded_String ("dje"),
      To_Unbounded_String ("dv"),
      To_Unbounded_String ("dyu"),
      To_Unbounded_String ("dz"),
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
      To_Unbounded_String ("hmn"),
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
      To_Unbounded_String ("kek"),
      To_Unbounded_String ("ki"),
      To_Unbounded_String ("kk"),
      To_Unbounded_String ("kl"),
      To_Unbounded_String ("km"),
      To_Unbounded_String ("kn"),
      To_Unbounded_String ("ko"),
      To_Unbounded_String ("kpe"),
      To_Unbounded_String ("kri"),
      To_Unbounded_String ("ktu"),
      To_Unbounded_String ("ku"),
      To_Unbounded_String ("kw"),
      To_Unbounded_String ("ky"),
      To_Unbounded_String ("lb"),
      To_Unbounded_String ("lg"),
      To_Unbounded_String ("ln"),
      To_Unbounded_String ("lo"),
      To_Unbounded_String ("lt"),
      To_Unbounded_String ("luo"),
      To_Unbounded_String ("lv"),
      To_Unbounded_String ("mam"),
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
      To_Unbounded_String ("nr"),
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
      To_Unbounded_String ("quc"),
      To_Unbounded_String ("ro"),
      To_Unbounded_String ("ru"),
      To_Unbounded_String ("rw"),
      To_Unbounded_String ("sar"),
      To_Unbounded_String ("sd"),
      To_Unbounded_String ("sg"),
      To_Unbounded_String ("shi"),
      To_Unbounded_String ("shn"),
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
      To_Unbounded_String ("tet"),
      To_Unbounded_String ("tg"),
      To_Unbounded_String ("th"),
      To_Unbounded_String ("ti"),
      To_Unbounded_String ("tig"),
      To_Unbounded_String ("tk"),
      To_Unbounded_String ("tn"),
      To_Unbounded_String ("tpi"),
      To_Unbounded_String ("tr"),
      To_Unbounded_String ("ts"),
      To_Unbounded_String ("tum"),
      To_Unbounded_String ("tzm"),
      To_Unbounded_String ("uk"),
      To_Unbounded_String ("umb"),
      To_Unbounded_String ("ur"),
      To_Unbounded_String ("uz"),
      To_Unbounded_String ("ve"),
      To_Unbounded_String ("vi"),
      To_Unbounded_String ("vmw"),
      To_Unbounded_String ("wo"),
      To_Unbounded_String ("xh"),
      To_Unbounded_String ("yao"),
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

   --  A request's arguments: the process command line, or one REPL line.
   type Arg_List is array (Positive range <>) of Unbounded_String;

   --  Commands write stdout text here so a REPL can answer with it on
   --  one line; one-shot mode prints it unchanged.
   Output : Unbounded_String;

   procedure Emit (Line : String) is
   begin
      Append (Output, Line & ASCII.LF);
   end Emit;

   procedure Print_Error (Msg : String) is
   begin
      Put_Line (Standard_Error, "error: " & Msg);
      Put_Line (Standard_Error, "Run 'sayable help' for usage.");
   end Print_Error;

   procedure Print_Help is
   begin
      Emit ("Usage: sayable <command> [arguments] [options]");
      Emit ("");
      Emit ("Commands:");
      Emit ("  age <dob>              Format an age");
      Emit ("  stage <dob>            Get developmental stage");
      Emit ("  date <date>            Format a calendar date");
      Emit ("  relative <date>        Format a relative date");
      Emit ("  time <time>            Format a clock time");
      Emit ("  duration <value> [end] Format a duration");
      Emit ("  since <start>          Format elapsed time");
      Emit ("  until <target>         Format remaining time");
      Emit ("  locales                List available locale codes");
      Emit ("  version                Show version");
      Emit ("  help                   Show this help");
      Emit ("");
      Emit ("Options:");
      Emit ("  -l, --locale <code>    Locale code (default: en)");
      Emit ("  -d, --as-of <value>    Reference date/timestamp");
      Emit ("      --short            Short compactness");
      Emit ("      --compact          Compact compactness");
      Emit ("  -g, --gender <m|f>     Gender for stage labels");
      Emit ("      --with-year        Include year (date only)");
      Emit ("  -h, --help             Show this help");
      Emit ("  -v, --version          Show version");
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

   --  Longer digit strings are far beyond the 500-year ceiling, so
   --  they saturate instead of overflowing.
   Max_Exact_Digits : constant := 18;

   function Parse_Seconds (S : String) return Long_Long_Integer is
      Neg   : constant Boolean := S (S'First) = '-';
      Start : Integer := (if Neg then S'First + 1 else S'First);
      Val   : Long_Long_Integer := 0;
   begin
      while Start < S'Last and then S (Start) = '0' loop
         Start := Start + 1;
      end loop;
      if S'Last - Start + 1 > Max_Exact_Digits then
         Val := Long_Long_Integer'Last;
      else
         for I in Start .. S'Last loop
            Val := Val * 10
              + Long_Long_Integer
                  (Character'Pos (S (I)) - Character'Pos ('0'));
         end loop;
      end if;
      return (if Neg then -Val else Val);
   end Parse_Seconds;

   function Parse_Arguments (Argv : Arg_List) return Parsed_Args is
      Args     : Parsed_Args;
      I        : Integer;
      Stop_Opt : Boolean := False;
      Arg      : Unbounded_String;
   begin
      if Argv'Length = 0 then
         Args.Command := Null_Unbounded_String;
         return Args;
      end if;

      --  Check for global flags as first argument
      declare
         First : constant String := To_String (Argv (1));
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

      Args.Command := To_Unbounded_String (To_String (Argv (1)));

      I := 2;
      while I <= Argv'Last loop
         Arg := To_Unbounded_String (To_String (Argv (I)));
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
                  if I + 1 > Argv'Last then
                     Print_Error ("'--locale' requires a value");
                     Args.Parse_Error := True;
                     return Args;
                  end if;
                  I := I + 1;
                  Args.Locale_Code :=
                    To_Unbounded_String (To_String (Argv (I)));

               elsif A = "-d" or else A = "--as-of" then
                  if I + 1 > Argv'Last then
                     Print_Error ("'--as-of' requires a value");
                     Args.Parse_Error := True;
                     return Args;
                  end if;
                  I := I + 1;
                  Args.As_Of :=
                    To_Unbounded_String (To_String (Argv (I)));
                  Args.Has_As_Of := True;

               elsif A = "-g" or else A = "--gender" then
                  if I + 1 > Argv'Last then
                     Print_Error ("'--gender' requires a value");
                     Args.Parse_Error := True;
                     return Args;
                  end if;
                  I := I + 1;
                  Args.Gender :=
                    To_Unbounded_String (To_String (Argv (I)));

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
      return Sayableage_Types.Compactness
   is
   begin
      case C is
         when Normal  => return Sayableage_Types.Normal;
         when Short   => return Sayableage_Types.Short;
         when Compact => return Sayableage_Types.Compact;
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
      Loc_Ptr : Sayableage_Types.Locale_Access;
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

         Loc_Ptr := Sayableage_Locales.Get_Locale
           (To_String (Args.Locale_Code));
         if Loc_Ptr = null then
            Print_Error
              ("unknown locale '"
               & To_String (Args.Locale_Code) & "'");
            return 2;
         end if;

         --  A null or empty as-of means today, as in the reference.
         if Args.Has_As_Of and then not Is_Null (To_String (Args.As_Of))
           and then Length (Args.As_Of) > 0
         then
            As_Of := Args.As_Of;
         else
            As_Of := To_Unbounded_String (Get_Today);
         end if;

         Result := To_Unbounded_String
           (Sayableage.Format_Age
              (Loc_Ptr.all,
               To_Age_Compactness (Args.Compactness),
               DOB,
               To_String (As_Of)));

         if Length (Result) = 0 then
            return 1;
         end if;

         Emit (To_String (Result));
         return 0;
      end;
   end Cmd_Age;

   function Cmd_Stage (Args : Parsed_Args) return Integer is
      Loc_Ptr : Sayableage_Types.Locale_Access;
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

         Loc_Ptr := Sayableage_Locales.Get_Locale
           (To_String (Args.Locale_Code));
         if Loc_Ptr = null then
            Print_Error
              ("unknown locale '"
               & To_String (Args.Locale_Code) & "'");
            return 2;
         end if;

         --  A null or empty as-of means today, as in the reference.
         if Args.Has_As_Of and then not Is_Null (To_String (Args.As_Of))
           and then Length (Args.As_Of) > 0
         then
            As_Of := Args.As_Of;
         else
            As_Of := To_Unbounded_String (Get_Today);
         end if;

         Result := To_Unbounded_String
           (Sayableage.Format_Stage
              (Loc_Ptr.all,
               DOB,
               To_String (As_Of),
               To_String (Args.Gender)));

         if Length (Result) = 0 then
            return 1;
         end if;

         Emit (To_String (Result));
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

         Emit (To_String (Result));
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

            Emit (To_String (Result));
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

         Emit (To_String (Result));
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

         if Is_All_Digits (Value) or else Is_Negative_Integer (Value) then
            --  Seconds mode (negative seconds have no value)
            Result := To_Unbounded_String
              (Sayableduration.Format_Duration
                 (Loc_Ptr.all,
                  To_Duration_Compactness (Args.Compactness),
                  Parse_Seconds (Value)));

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
            begin
               if Is_Null (End_Val) then
                  return 1;
               end if;

               Result := To_Unbounded_String
                 (Sayableduration.Format_Duration
                    (Loc_Ptr.all,
                     To_Duration_Compactness (Args.Compactness),
                     Value, End_Val));
            end;
         end if;

         if Length (Result) = 0 then
            return 1;
         end if;

         Emit (To_String (Result));
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

            Emit (To_String (Result));
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

            Emit (To_String (Result));
            return 0;
         end;
      end;
   end Cmd_Until;

   procedure Cmd_Locales is
   begin
      for I in All_Locales'Range loop
         Emit (To_String (All_Locales (I)));
      end loop;
   end Cmd_Locales;

   --  Runs one request: returns its exit code, leaving its stdout text
   --  in Output.
   function Run (Argv : Arg_List) return Integer is
      Args : constant Parsed_Args := Parse_Arguments (Argv);
   begin
      Output := Null_Unbounded_String;

      if Args.Parse_Error then
         return 2;
      end if;

      declare
         C : constant String := To_String (Args.Command);
      begin
         if C'Length = 0 then
            Print_Help;
            return 2;
         elsif C = "help" then
            Print_Help;
            return 0;
         elsif C = "version" then
            Emit ("sayable " & Version);
            return 0;
         elsif C = "locales" then
            Cmd_Locales;
            return 0;
         elsif C = "age" then
            return Cmd_Age (Args);
         elsif C = "stage" then
            return Cmd_Stage (Args);
         elsif C = "date" then
            return Cmd_Date (Args);
         elsif C = "relative" then
            return Cmd_Relative (Args);
         elsif C = "time" then
            return Cmd_Time (Args);
         elsif C = "duration" then
            return Cmd_Duration (Args);
         elsif C = "since" then
            return Cmd_Since (Args);
         elsif C = "until" then
            return Cmd_Until (Args);
         else
            Print_Error ("unknown command '" & C & "'");
            return 2;
         end if;
      end;
   end Run;

   function Command_Line_Args return Arg_List is
      Argv : Arg_List (1 .. Argument_Count);
   begin
      for I in Argv'Range loop
         Argv (I) := To_Unbounded_String (Argument (I));
      end loop;
      return Argv;
   end Command_Line_Args;

   --  Splits on every tab, keeping empty fields: "age" & TAB is
   --  ("age", "").
   function Split_Request (Line : String) return Arg_List is
      Field_Count : constant Positive :=
        Ada.Strings.Fixed.Count (Line, (1 => ASCII.HT)) + 1;
      Argv        : Arg_List (1 .. Field_Count);
      Field_Start : Positive := Line'First;
      Field       : Positive := 1;
   begin
      for I in Line'Range loop
         if Line (I) = ASCII.HT then
            Argv (Field) := To_Unbounded_String (Line (Field_Start .. I - 1));
            Field := Field + 1;
            Field_Start := I + 1;
         end if;
      end loop;
      Argv (Field) := To_Unbounded_String (Line (Field_Start .. Line'Last));
      return Argv;
   end Split_Request;

   --  Formats Output as a response's output field: trailing newline
   --  dropped, inner newlines turned into tabs.
   function Output_Field return String is
      Text : String := To_String (Output);
      Last : Natural := Text'Last;
   begin
      while Last >= Text'First and then Text (Last) = ASCII.LF loop
         Last := Last - 1;
      end loop;
      for I in Text'First .. Last loop
         if Text (I) = ASCII.LF then
            Text (I) := ASCII.HT;
         end if;
      end loop;
      return Text (Text'First .. Last);
   end Output_Field;

   --  Writes Output line by line: Text_IO tracks line ends itself, and a
   --  raw newline inside Put would leave it adding a spurious one at exit.
   procedure Print_Output is
      Text       : constant String := To_String (Output);
      Line_Start : Positive := Text'First;
   begin
      for I in Text'Range loop
         if Text (I) = ASCII.LF then
            Put_Line (Text (Line_Start .. I - 1));
            Line_Start := I + 1;
         end if;
      end loop;
   end Print_Output;

   function Exit_Code_Image (Code : Integer) return String is
   begin
      return Ada.Strings.Fixed.Trim (Integer'Image (Code), Ada.Strings.Left);
   end Exit_Code_Image;

   --  Reads stdin with raw reads rather than Text_IO: Text_IO.Get_Line
   --  and End_Of_File may read ahead past a line terminator, which would
   --  block on a request the driver only sends after seeing our answer.
   Read_Buffer : String (1 .. 4096);
   Read_Pos    : Positive := 1;
   Read_Last   : Natural := 0;

   procedure Read_Request
     (Line : out Unbounded_String; Found : out Boolean)
   is
   begin
      Line := Null_Unbounded_String;
      Found := False;
      loop
         if Read_Pos > Read_Last then
            declare
               --  Read returns -1 on error, 0 at end of input.
               Bytes_Read : constant Integer := GNAT.OS_Lib.Read
                 (GNAT.OS_Lib.Standin, Read_Buffer'Address,
                  Read_Buffer'Length);
            begin
               Read_Last := Integer'Max (Bytes_Read, 0);
            end;
            Read_Pos := 1;
            exit when Read_Last = 0;
         end if;
         Found := True;
         declare
            C : constant Character := Read_Buffer (Read_Pos);
         begin
            Read_Pos := Read_Pos + 1;
            exit when C = ASCII.LF;
            Append (Line, C);
         end;
      end loop;
      if Length (Line) > 0 and then Element (Line, Length (Line)) = ASCII.CR
      then
         Delete (Line, Length (Line), Length (Line));
      end if;
   end Read_Request;

   function Answer (Line : String) return String is
      Code : Integer;
   begin
      Code := Run (Split_Request (Line));
      return Exit_Code_Image (Code) & ASCII.HT & Output_Field;
   exception
      --  A crashed one-shot run exits 1; the REPL reports it and keeps
      --  serving.
      when E : others =>
         Put_Line (Standard_Error, Ada.Exceptions.Exception_Information (E));
         return "1" & ASCII.HT;
   end Answer;

   procedure Repl is
      Line  : Unbounded_String;
      Found : Boolean;
   begin
      loop
         Read_Request (Line, Found);
         exit when not Found;
         Put_Line (Answer (To_String (Line)));
         Flush;
      end loop;
   end Repl;

   Exit_RC : Integer;

begin
   if Argument_Count = 1 and then Argument (1) = "--repl" then
      Repl;
      return;
   end if;

   Exit_RC := Run (Command_Line_Args);
   Print_Output;
   Set_Exit_Status (Ada.Command_Line.Exit_Status (Exit_RC));
end Main;
