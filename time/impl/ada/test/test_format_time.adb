with Ada.Text_IO;          use Ada.Text_IO;
with Sayabletime_Types;    use Sayabletime_Types;
with Sayabletime;
with Sayabletime_Locales;

procedure Test_Format_Time is

   Tests_Passed : Natural := 0;
   Tests_Failed : Natural := 0;

   ---------------------------------------------------------------------------
   --  Test harness helpers
   ---------------------------------------------------------------------------

   procedure Assert_Eq (Name : String; Got : String; Expected : String) is
   begin
      if Got = Expected then
         Tests_Passed := Tests_Passed + 1;
      else
         Put_Line ("FAIL [" & Name & "]: got """ & Got &
                   """, expected """ & Expected & """");
         Tests_Failed := Tests_Failed + 1;
      end if;
   end Assert_Eq;

   procedure Assert_Null (Name : String; Got : String) is
   begin
      if Got'Length = 0 then
         Tests_Passed := Tests_Passed + 1;
      else
         Put_Line ("FAIL [" & Name & "]: expected empty, got """
                   & Got & """");
         Tests_Failed := Tests_Failed + 1;
      end if;
   end Assert_Null;

   ---------------------------------------------------------------------------
   --  1. Null / edge cases
   ---------------------------------------------------------------------------
   procedure Test_Null_Edge_Cases is
      Loc : constant Locale_Access :=
        Sayabletime_Locales.Get_Locale ("en");
   begin
      --  1.1
      Assert_Null ("1.1 null time",
         Sayabletime.Format_Time (Loc.all, Normal, ""));

      --  1.2
      Assert_Null ("1.2 empty time",
         Sayabletime.Format_Time (Loc.all, Normal, ""));

      --  1.3
      Assert_Null ("1.3 invalid time",
         Sayabletime.Format_Time (Loc.all, Normal, "invalid"));

      --  1.4
      Assert_Null ("1.4 out of range",
         Sayabletime.Format_Time (Loc.all, Normal, "25:00"));
   end Test_Null_Edge_Cases;

   ---------------------------------------------------------------------------
   --  2. Clock time (normal compactness)
   ---------------------------------------------------------------------------
   procedure Test_Normal_Clock is
      Loc : constant Locale_Access :=
        Sayabletime_Locales.Get_Locale ("en");
   begin
      --  2.1
      Assert_Eq ("2.1 midnight",
         Sayabletime.Format_Time (Loc.all, Normal, "00:00"),
         "midnight");

      --  2.2
      Assert_Eq ("2.2 noon",
         Sayabletime.Format_Time (Loc.all, Normal, "12:00"),
         "noon");

      --  2.3
      Assert_Eq ("2.3 three o'clock",
         Sayabletime.Format_Time (Loc.all, Normal, "15:00"),
         "three o'clock");

      --  2.4
      Assert_Eq ("2.4 quarter past two",
         Sayabletime.Format_Time (Loc.all, Normal, "14:15"),
         "a quarter past two");

      --  2.5
      Assert_Eq ("2.5 half past nine",
         Sayabletime.Format_Time (Loc.all, Normal, "09:30"),
         "half past nine");

      --  2.6
      Assert_Eq ("2.6 quarter to eleven",
         Sayabletime.Format_Time (Loc.all, Normal, "10:45"),
         "a quarter to eleven");

      --  2.7
      Assert_Eq ("2.7 five past eight",
         Sayabletime.Format_Time (Loc.all, Normal, "08:05"),
         "five past eight");

      --  2.8
      Assert_Eq ("2.8 five to five",
         Sayabletime.Format_Time (Loc.all, Normal, "16:55"),
         "five to five");

      --  2.9
      Assert_Eq ("2.9 rounds to midnight",
         Sayabletime.Format_Time (Loc.all, Normal, "23:58"),
         "midnight");

      --  2.10
      Assert_Eq ("2.10 twenty past seven",
         Sayabletime.Format_Time (Loc.all, Normal, "07:22"),
         "twenty past seven");

      --  2.11
      Assert_Eq ("2.11 ISO datetime",
         Sayabletime.Format_Time
           (Loc.all, Normal, "2025-01-15T14:15:00"),
         "a quarter past two");
   end Test_Normal_Clock;

   ---------------------------------------------------------------------------
   --  3. Clock time (short compactness)
   ---------------------------------------------------------------------------
   procedure Test_Short_Clock is
      Loc : constant Locale_Access :=
        Sayabletime_Locales.Get_Locale ("en");
   begin
      --  3.1
      Assert_Eq ("3.1 short 2:15 PM",
         Sayabletime.Format_Time (Loc.all, Short, "14:15"),
         "2:15 PM");

      --  3.2
      Assert_Eq ("3.2 short 9:30 AM",
         Sayabletime.Format_Time (Loc.all, Short, "09:30"),
         "9:30 AM");

      --  3.3
      Assert_Eq ("3.3 short 12:00 AM",
         Sayabletime.Format_Time (Loc.all, Short, "00:00"),
         "12:00 AM");

      --  3.4
      Assert_Eq ("3.4 short 12:00 PM",
         Sayabletime.Format_Time (Loc.all, Short, "12:00"),
         "12:00 PM");
   end Test_Short_Clock;

   ---------------------------------------------------------------------------
   --  4. Clock time (compact)
   ---------------------------------------------------------------------------
   procedure Test_Compact_Clock is
      Loc : constant Locale_Access :=
        Sayabletime_Locales.Get_Locale ("en");
   begin
      --  4.1
      Assert_Eq ("4.1 compact 2:15p",
         Sayabletime.Format_Time (Loc.all, Compact, "14:15"),
         "2:15p");

      --  4.2
      Assert_Eq ("4.2 compact 9:30a",
         Sayabletime.Format_Time (Loc.all, Compact, "09:30"),
         "9:30a");
   end Test_Compact_Clock;

   ---------------------------------------------------------------------------
   --  5. Locale -- German
   ---------------------------------------------------------------------------
   procedure Test_Locale_German is
      Loc : constant Locale_Access :=
        Sayabletime_Locales.Get_Locale ("de");
   begin
      --  5.1
      Assert_Eq ("5.1 German halb vier",
         Sayabletime.Format_Time (Loc.all, Normal, "15:30"),
         "halb vier");
   end Test_Locale_German;

   ---------------------------------------------------------------------------
   --  6. Locale -- French
   ---------------------------------------------------------------------------
   procedure Test_Locale_French is
      Loc : constant Locale_Access :=
        Sayabletime_Locales.Get_Locale ("fr");
   begin
      --  6.1
      Assert_Eq ("6.1 French trois heures et quart",
         Sayabletime.Format_Time (Loc.all, Normal, "15:15"),
         "trois heures et quart");
   end Test_Locale_French;

   ---------------------------------------------------------------------------
   --  7. Locale -- Japanese
   ---------------------------------------------------------------------------
   procedure Test_Locale_Japanese is
      Loc : constant Locale_Access :=
        Sayabletime_Locales.Get_Locale ("ja");
   begin
      --  7.1
      Assert_Eq ("7.1 Japanese time",
         Sayabletime.Format_Time (Loc.all, Normal, "15:30"),
         Character'Val (16#E4#) & Character'Val (16#B8#)
         & Character'Val (16#89#) & Character'Val (16#E6#)
         & Character'Val (16#99#) & Character'Val (16#82#)
         & Character'Val (16#E5#) & Character'Val (16#8D#)
         & Character'Val (16#8A#));
   end Test_Locale_Japanese;

   ---------------------------------------------------------------------------
   --  8. Locale -- Finnish (dot separator, short)
   ---------------------------------------------------------------------------
   procedure Test_Finnish_Dot_Separator is
      Loc : constant Locale_Access :=
        Sayabletime_Locales.Get_Locale ("fi");
   begin
      --  8.1
      Assert_Eq ("8.1 Finnish dot separator",
         Sayabletime.Format_Time (Loc.all, Short, "14:15"),
         "14.15");
      --  8.2
      Assert_Eq ("8.2 Finnish midnight dot",
         Sayabletime.Format_Time (Loc.all, Short, "00:00"),
         "0.00");
   end Test_Finnish_Dot_Separator;

begin
   Test_Null_Edge_Cases;
   Test_Normal_Clock;
   Test_Short_Clock;
   Test_Compact_Clock;
   Test_Locale_German;
   Test_Locale_French;
   Test_Locale_Japanese;
   Test_Finnish_Dot_Separator;

   Put_Line (Natural'Image (Tests_Passed) & " passed," &
             Natural'Image (Tests_Failed) & " failed");

   if Tests_Failed > 0 then
      raise Program_Error with "Test failures occurred";
   end if;
end Test_Format_Time;
