with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Strings.Unbounded;
with Sayabledate_Types;    use Sayabledate_Types;
with Sayabledate;
with Sayabledate_Locales;

procedure Test_Format_Date is

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
        Sayabledate_Locales.Get_Locale ("en");
   begin
      --  1.1
      Assert_Null ("1.1 null date",
         Sayabledate.Format_Date (Loc.all, Normal, ""));

      --  1.2
      Assert_Null ("1.2 empty date",
         Sayabledate.Format_Date (Loc.all, Normal, ""));

      --  1.3
      Assert_Null ("1.3 invalid date",
         Sayabledate.Format_Date (Loc.all, Normal, "invalid"));

      --  1.4
      Assert_Null ("1.4 relative null asOf",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-03-15", ""));

      --  1.5
      Assert_Null ("1.5 relative null date",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "", "2025-03-15"));
   end Test_Null_Edge_Cases;

   ---------------------------------------------------------------------------
   --  2. format_date -- normal compactness (English)
   ---------------------------------------------------------------------------
   procedure Test_Format_Date_Normal is
      Loc : constant Locale_Access :=
        Sayabledate_Locales.Get_Locale ("en");
   begin
      --  2.1
      Assert_Eq ("2.1 March 15th",
         Sayabledate.Format_Date (Loc.all, Normal, "2025-03-15"),
         "March 15th");

      --  2.2
      Assert_Eq ("2.2 January 1st",
         Sayabledate.Format_Date (Loc.all, Normal, "2025-01-01"),
         "January 1st");

      --  2.3
      Assert_Eq ("2.3 May 22nd",
         Sayabledate.Format_Date (Loc.all, Normal, "2025-05-22"),
         "May 22nd");

      --  2.4
      Assert_Eq ("2.4 July 3rd",
         Sayabledate.Format_Date (Loc.all, Normal, "2025-07-03"),
         "July 3rd");

      --  2.5
      Assert_Eq ("2.5 December 31st",
         Sayabledate.Format_Date (Loc.all, Normal, "2025-12-31"),
         "December 31st");

      --  2.6
      Assert_Eq ("2.6 June 11th",
         Sayabledate.Format_Date (Loc.all, Normal, "2025-06-11"),
         "June 11th");

      --  2.7
      Assert_Eq ("2.7 ISO datetime",
         Sayabledate.Format_Date
           (Loc.all, Normal, "2025-03-15T14:30:00"),
         "March 15th");
   end Test_Format_Date_Normal;

   ---------------------------------------------------------------------------
   --  3. format_date -- short compactness (English)
   ---------------------------------------------------------------------------
   procedure Test_Format_Date_Short is
      Loc : constant Locale_Access :=
        Sayabledate_Locales.Get_Locale ("en");
   begin
      --  3.1
      Assert_Eq ("3.1 short Mar 15",
         Sayabledate.Format_Date (Loc.all, Short, "2025-03-15"),
         "Mar 15");

      --  3.2
      Assert_Eq ("3.2 short Jan 1",
         Sayabledate.Format_Date (Loc.all, Short, "2025-01-01"),
         "Jan 1");

      --  3.3
      Assert_Eq ("3.3 short Dec 25",
         Sayabledate.Format_Date (Loc.all, Short, "2025-12-25"),
         "Dec 25");
   end Test_Format_Date_Short;

   ---------------------------------------------------------------------------
   --  4. format_date -- compact (English)
   ---------------------------------------------------------------------------
   procedure Test_Format_Date_Compact is
      Loc : constant Locale_Access :=
        Sayabledate_Locales.Get_Locale ("en");
   begin
      --  4.1
      Assert_Eq ("4.1 compact 3/15",
         Sayabledate.Format_Date (Loc.all, Compact, "2025-03-15"),
         "3/15");

      --  4.2
      Assert_Eq ("4.2 compact 1/1",
         Sayabledate.Format_Date (Loc.all, Compact, "2025-01-01"),
         "1/1");
   end Test_Format_Date_Compact;

   ---------------------------------------------------------------------------
   --  5. format_relative -- proximity tiers (English)
   ---------------------------------------------------------------------------
   procedure Test_Relative_Proximity is
      Loc : constant Locale_Access :=
        Sayabledate_Locales.Get_Locale ("en");
   begin
      --  5.1
      Assert_Eq ("5.1 today",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-03-15", "2025-03-15"),
         "today");

      --  5.2
      Assert_Eq ("5.2 tomorrow",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-03-16", "2025-03-15"),
         "tomorrow");

      --  5.3
      Assert_Eq ("5.3 yesterday",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-03-14", "2025-03-15"),
         "yesterday");

      --  5.4
      Assert_Eq ("5.4 day after tomorrow",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-03-17", "2025-03-15"),
         "the day after tomorrow");

      --  5.5
      Assert_Eq ("5.5 day before yesterday",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-03-13", "2025-03-15"),
         "the day before yesterday");

      --  5.6
      Assert_Eq ("5.6 this Wednesday",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-03-19", "2025-03-15"),
         "this Wednesday");

      --  5.7
      Assert_Eq ("5.7 this Thursday",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-03-20", "2025-03-15"),
         "this Thursday");

      --  5.8
      Assert_Eq ("5.8 last Tuesday",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-03-11", "2025-03-15"),
         "last Tuesday");

      --  5.9
      Assert_Eq ("5.9 next Saturday",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-03-22", "2025-03-15"),
         "next Saturday");

      --  5.10
      Assert_Eq ("5.10 next Thursday",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-03-27", "2025-03-15"),
         "next Thursday");

      --  5.11
      Assert_Eq ("5.11 calendar fallback same year",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-03-01", "2025-03-15"),
         "March 1st");

      --  5.12
      Assert_Eq ("5.12 calendar fallback future",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-04-10", "2025-03-15"),
         "April 10th");

      --  5.13
      Assert_Eq ("5.13 different year future",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2026-01-05", "2025-03-15"),
         "January 5th, 2026");

      --  5.14
      Assert_Eq ("5.14 past year",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2024-12-25", "2025-03-15"),
         "December 25th, 2024");
   end Test_Relative_Proximity;

   ---------------------------------------------------------------------------
   --  6. format_relative -- compact skips weekday tiers
   ---------------------------------------------------------------------------
   procedure Test_Relative_Compact is
      Loc : constant Locale_Access :=
        Sayabledate_Locales.Get_Locale ("en");
   begin
      --  6.1
      Assert_Eq ("6.1 compact today",
         Sayabledate.Format_Relative
           (Loc.all, Compact, "2025-03-15", "2025-03-15"),
         "today");

      --  6.2
      Assert_Eq ("6.2 compact tomorrow",
         Sayabledate.Format_Relative
           (Loc.all, Compact, "2025-03-16", "2025-03-15"),
         "tomorrow");

      --  6.3
      Assert_Eq ("6.3 compact numeric",
         Sayabledate.Format_Relative
           (Loc.all, Compact, "2025-03-19", "2025-03-15"),
         "3/19");

      --  6.4
      Assert_Eq ("6.4 compact different year",
         Sayabledate.Format_Relative
           (Loc.all, Compact, "2026-01-05", "2025-03-15"),
         "1/5/26");
   end Test_Relative_Compact;

   ---------------------------------------------------------------------------
   --  7. Locale -- German
   ---------------------------------------------------------------------------
   procedure Test_Locale_German is
      Loc : constant Locale_Access :=
        Sayabledate_Locales.Get_Locale ("de");
   begin
      --  7.1
      Assert_Eq ("7.1 German date",
         Sayabledate.Format_Date (Loc.all, Normal, "2025-03-15"),
         "15. M" & Character'Val (16#C3#)
         & Character'Val (16#A4#) & "rz");

      --  7.2
      Assert_Eq ("7.2 German tomorrow",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-03-16", "2025-03-15"),
         "morgen");

      --  7.3
      Assert_Eq ("7.3 German day after tomorrow",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-03-17", "2025-03-15"),
         "" & Character'Val (16#C3#) & Character'Val (16#BC#)
         & "bermorgen");

      --  7.4
      Assert_Eq ("7.4 German this weekday",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-03-19", "2025-03-15"),
         "diesen Mittwoch");
   end Test_Locale_German;

   ---------------------------------------------------------------------------
   --  8. Locale -- French
   ---------------------------------------------------------------------------
   procedure Test_Locale_French is
      Loc : constant Locale_Access :=
        Sayabledate_Locales.Get_Locale ("fr");
   begin
      --  8.1
      Assert_Eq ("8.1 French 1er mars",
         Sayabledate.Format_Date (Loc.all, Normal, "2025-03-01"),
         "1er mars");

      --  8.2
      Assert_Eq ("8.2 French 15 mars",
         Sayabledate.Format_Date (Loc.all, Normal, "2025-03-15"),
         "15 mars");

      --  8.3
      Assert_Eq ("8.3 French demain",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-03-16", "2025-03-15"),
         "demain");
   end Test_Locale_French;

   ---------------------------------------------------------------------------
   --  9. Locale -- Japanese
   ---------------------------------------------------------------------------
   procedure Test_Locale_Japanese is
      Loc : constant Locale_Access :=
        Sayabledate_Locales.Get_Locale ("ja");
   begin
      --  9.1
      Assert_Eq ("9.1 Japanese date",
         Sayabledate.Format_Date (Loc.all, Normal, "2025-03-15"),
         "3" & Character'Val (16#E6#) & Character'Val (16#9C#)
         & Character'Val (16#88#) & "15"
         & Character'Val (16#E6#) & Character'Val (16#97#)
         & Character'Val (16#A5#));

      --  9.2
      Assert_Eq ("9.2 Japanese tomorrow",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-03-16", "2025-03-15"),
         Character'Val (16#E6#) & Character'Val (16#98#)
         & Character'Val (16#8E#) & Character'Val (16#E6#)
         & Character'Val (16#97#) & Character'Val (16#A5#));

      --  9.3
      Assert_Eq ("9.3 Japanese this weekday",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-03-19", "2025-03-15"),
         Character'Val (16#E4#) & Character'Val (16#BB#)
         & Character'Val (16#8A#) & Character'Val (16#E5#)
         & Character'Val (16#BA#) & Character'Val (16#A6#)
         & Character'Val (16#E3#) & Character'Val (16#81#)
         & Character'Val (16#AE#)
         & Character'Val (16#E6#) & Character'Val (16#B0#)
         & Character'Val (16#B4#) & Character'Val (16#E6#)
         & Character'Val (16#9B#) & Character'Val (16#9C#)
         & Character'Val (16#E6#) & Character'Val (16#97#)
         & Character'Val (16#A5#));
   end Test_Locale_Japanese;

   ---------------------------------------------------------------------------
   --  10. Locale -- Russian (genitive months)
   ---------------------------------------------------------------------------
   procedure Test_Locale_Russian is
      Loc : constant Locale_Access :=
        Sayabledate_Locales.Get_Locale ("ru");
   begin
      --  10.1
      Assert_Eq ("10.1 Russian genitive date",
         Sayabledate.Format_Date (Loc.all, Normal, "2025-03-15"),
         "15 " & Character'Val (16#D0#) & Character'Val (16#BC#)
         & Character'Val (16#D0#) & Character'Val (16#B0#)
         & Character'Val (16#D1#) & Character'Val (16#80#)
         & Character'Val (16#D1#) & Character'Val (16#82#)
         & Character'Val (16#D0#) & Character'Val (16#B0#));

      --  10.2
      Assert_Eq ("10.2 Russian tomorrow",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-03-16", "2025-03-15"),
         Character'Val (16#D0#) & Character'Val (16#B7#)
         & Character'Val (16#D0#) & Character'Val (16#B0#)
         & Character'Val (16#D0#) & Character'Val (16#B2#)
         & Character'Val (16#D1#) & Character'Val (16#82#)
         & Character'Val (16#D1#) & Character'Val (16#80#)
         & Character'Val (16#D0#) & Character'Val (16#B0#));
   end Test_Locale_Russian;

   ---------------------------------------------------------------------------
   --  11. Locale -- Arabic
   ---------------------------------------------------------------------------
   procedure Test_Locale_Arabic is
      Loc : constant Locale_Access :=
        Sayabledate_Locales.Get_Locale ("ar");
   begin
      --  11.1
      Assert_Eq ("11.1 Arabic date",
         Sayabledate.Format_Date (Loc.all, Normal, "2025-03-15"),
         "15 " & Character'Val (16#D9#) & Character'Val (16#85#)
         & Character'Val (16#D8#) & Character'Val (16#A7#)
         & Character'Val (16#D8#) & Character'Val (16#B1#)
         & Character'Val (16#D8#) & Character'Val (16#B3#));

      --  11.2
      Assert_Eq ("11.2 Arabic tomorrow",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-03-16", "2025-03-15"),
         Character'Val (16#D8#) & Character'Val (16#BA#)
         & Character'Val (16#D8#) & Character'Val (16#AF#)
         & Character'Val (16#D8#) & Character'Val (16#A7#)
         & Character'Val (16#D9#) & Character'Val (16#8B#));
   end Test_Locale_Arabic;

   ---------------------------------------------------------------------------
   --  12. Locale -- Spanish
   ---------------------------------------------------------------------------
   procedure Test_Locale_Spanish is
      Loc : constant Locale_Access :=
        Sayabledate_Locales.Get_Locale ("es");
   begin
      --  12.1
      Assert_Eq ("12.1 Spanish date",
         Sayabledate.Format_Date (Loc.all, Normal, "2025-03-15"),
         "15 de marzo");

      --  12.2
      Assert_Eq ("12.2 Spanish pasado manana",
         Sayabledate.Format_Relative
           (Loc.all, Normal, "2025-03-17", "2025-03-15"),
         "pasado ma" & Character'Val (16#C3#)
         & Character'Val (16#B1#) & "ana");
   end Test_Locale_Spanish;

begin
   Test_Null_Edge_Cases;
   Test_Format_Date_Normal;
   Test_Format_Date_Short;
   Test_Format_Date_Compact;
   Test_Relative_Proximity;
   Test_Relative_Compact;
   Test_Locale_German;
   Test_Locale_French;
   Test_Locale_Japanese;
   Test_Locale_Russian;
   Test_Locale_Arabic;
   Test_Locale_Spanish;

   Put_Line (Natural'Image (Tests_Passed) & " passed," &
             Natural'Image (Tests_Failed) & " failed");

   if Tests_Failed > 0 then
      raise Program_Error with "Test failures occurred";
   end if;
end Test_Format_Date;
