with Ada.Text_IO;             use Ada.Text_IO;
with Sayableduration_Types;   use Sayableduration_Types;
with Sayableduration;
with Sayableduration_Locales;

procedure Test_Format_Duration is

   Tests_Passed : Natural := 0;
   Tests_Failed : Natural := 0;

   Half : constant String :=
     Character'Val (16#C2#) & Character'Val (16#BD#);

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
        Sayableduration_Locales.Get_Locale ("en");
   begin
      --  1.2
      Assert_Null ("1.2 negative seconds",
         Sayableduration.Format_Duration (Loc.all, Normal, -1));

      --  1.3
      Assert_Null ("1.3 format_since null start",
         Sayableduration.Format_Since
           (Loc.all, Normal, "", "2025-01-15T10:00:00"));

      --  1.4
      Assert_Null ("1.4 format_until null target",
         Sayableduration.Format_Until
           (Loc.all, Normal, "", "2025-01-15T10:00:00"));

      --  1.5
      Assert_Null ("1.5 format_since asOf before start",
         Sayableduration.Format_Since
           (Loc.all, Normal,
            "2025-01-15T10:00:00", "2025-01-15T09:00:00"));

      --  1.6
      Assert_Null ("1.6 format_until target in past",
         Sayableduration.Format_Until
           (Loc.all, Normal,
            "2025-01-15T09:00:00", "2025-01-15T10:00:00"));
   end Test_Null_Edge_Cases;

   ---------------------------------------------------------------------------
   --  2. Duration -- seconds tier (0-59s)
   ---------------------------------------------------------------------------
   procedure Test_Seconds_Tier is
      Loc : constant Locale_Access :=
        Sayableduration_Locales.Get_Locale ("en");
   begin
      --  2.1
      Assert_Eq ("2.1 zero seconds",
         Sayableduration.Format_Duration (Loc.all, Normal, 0),
         "just now");

      --  2.2
      Assert_Eq ("2.2 one second",
         Sayableduration.Format_Duration (Loc.all, Normal, 1),
         "1 second");

      --  2.3
      Assert_Eq ("2.3 45 seconds",
         Sayableduration.Format_Duration (Loc.all, Normal, 45),
         "45 seconds");

      --  2.4
      Assert_Eq ("2.4 59 seconds",
         Sayableduration.Format_Duration (Loc.all, Normal, 59),
         "59 seconds");
   end Test_Seconds_Tier;

   ---------------------------------------------------------------------------
   --  3. Duration -- minutes + seconds tier (1-4 min)
   ---------------------------------------------------------------------------
   procedure Test_Minutes_Seconds_Tier is
      Loc : constant Locale_Access :=
        Sayableduration_Locales.Get_Locale ("en");
   begin
      --  3.1
      Assert_Eq ("3.1 one minute",
         Sayableduration.Format_Duration (Loc.all, Normal, 60),
         "1 minute");

      --  3.2
      Assert_Eq ("3.2 1 minute 30 seconds",
         Sayableduration.Format_Duration (Loc.all, Normal, 90),
         "1 minute, 30 seconds");

      --  3.3
      Assert_Eq ("3.3 4 minutes",
         Sayableduration.Format_Duration (Loc.all, Normal, 240),
         "4 minutes");

      --  3.4
      Assert_Eq ("3.4 4 minutes 30 seconds",
         Sayableduration.Format_Duration (Loc.all, Normal, 270),
         "4 minutes, 30 seconds");
   end Test_Minutes_Seconds_Tier;

   ---------------------------------------------------------------------------
   --  4. Duration -- minutes tier (5-59 min)
   ---------------------------------------------------------------------------
   procedure Test_Minutes_Tier is
      Loc : constant Locale_Access :=
        Sayableduration_Locales.Get_Locale ("en");
   begin
      --  4.1
      Assert_Eq ("4.1 five minutes",
         Sayableduration.Format_Duration (Loc.all, Normal, 300),
         "5 minutes");

      --  4.2
      Assert_Eq ("4.2 25 minutes",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 1500),
         "25 minutes");

      --  4.3
      Assert_Eq ("4.3 59 minutes",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 3540),
         "59 minutes");
   end Test_Minutes_Tier;

   ---------------------------------------------------------------------------
   --  5. Duration -- hours + minutes tier (1-5 hr)
   ---------------------------------------------------------------------------
   procedure Test_Hours_Minutes_Tier is
      Loc : constant Locale_Access :=
        Sayableduration_Locales.Get_Locale ("en");
   begin
      --  5.1
      Assert_Eq ("5.1 one hour",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 3600),
         "1 hour");

      --  5.2
      Assert_Eq ("5.2 1.5 hours half",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 5400),
         "1" & Half & " hours");

      --  5.3
      Assert_Eq ("5.3 2 hours 15 minutes",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 8100),
         "2 hours, 15 minutes");

      --  5.4
      Assert_Eq ("5.4 5 hours",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 18000),
         "5 hours");
   end Test_Hours_Minutes_Tier;

   ---------------------------------------------------------------------------
   --  6. Duration -- hours tier (6-23 hr)
   ---------------------------------------------------------------------------
   procedure Test_Hours_Tier is
      Loc : constant Locale_Access :=
        Sayableduration_Locales.Get_Locale ("en");
   begin
      --  6.1
      Assert_Eq ("6.1 8 hours",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 28800),
         "8 hours");

      --  6.2
      Assert_Eq ("6.2 23 hours",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 82800),
         "23 hours");
   end Test_Hours_Tier;

   ---------------------------------------------------------------------------
   --  7. Duration -- days tier
   ---------------------------------------------------------------------------
   procedure Test_Days_Tier is
      Loc : constant Locale_Access :=
        Sayableduration_Locales.Get_Locale ("en");
   begin
      --  7.1
      Assert_Eq ("7.1 one day",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 86400),
         "1 day");

      --  7.2
      Assert_Eq ("7.2 1 day 3 hours",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 97200),
         "1 day, 3 hours");

      --  7.3
      Assert_Eq ("7.3 1.5 days half",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 129600),
         "1" & Half & " days");

      --  7.4
      Assert_Eq ("7.4 5 days",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 432000),
         "5 days");

      --  7.5
      Assert_Eq ("7.5 2 days",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 172800),
         "2 days");
   end Test_Days_Tier;

   ---------------------------------------------------------------------------
   --  8. Duration -- weeks tier
   ---------------------------------------------------------------------------
   procedure Test_Weeks_Tier is
      Loc : constant Locale_Access :=
        Sayableduration_Locales.Get_Locale ("en");
   begin
      --  8.1
      Assert_Eq ("8.1 one week",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 604800),
         "1 week");

      --  8.2
      Assert_Eq ("8.2 2 weeks 1 day",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 1296000),
         "2 weeks, 1 day");

      --  8.3
      Assert_Eq ("8.3 4 weeks",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 2419200),
         "4 weeks");
   end Test_Weeks_Tier;

   ---------------------------------------------------------------------------
   --  9. Duration -- months and years tier
   ---------------------------------------------------------------------------
   procedure Test_Months_Years_Tier is
      Loc : constant Locale_Access :=
        Sayableduration_Locales.Get_Locale ("en");
   begin
      --  9.1
      Assert_Eq ("9.1 one month",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 2678400),
         "1 month");

      --  9.2
      Assert_Eq ("9.2 3 months",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 7884000),
         "3 months");

      --  9.3
      Assert_Eq ("9.3 1 year",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 31536000),
         "1 year");

      --  9.4
      Assert_Eq ("9.4 1 year 3 months",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 39420000),
         "1 year, 3 months");
   end Test_Months_Years_Tier;

   ---------------------------------------------------------------------------
   --  10. Duration from ISO timestamps
   ---------------------------------------------------------------------------
   procedure Test_ISO_Timestamps is
      Loc : constant Locale_Access :=
        Sayableduration_Locales.Get_Locale ("en");
   begin
      --  10.1
      Assert_Eq ("10.1 ISO 1.5 hours",
         Sayableduration.Format_Duration
           (Loc.all, Normal,
            "2025-01-15T10:00:00", "2025-01-15T11:30:00"),
         "1" & Half & " hours");

      --  10.2
      Assert_Eq ("10.2 ISO 45 minutes",
         Sayableduration.Format_Duration
           (Loc.all, Normal,
            "2025-01-15T10:00:00", "2025-01-15T10:45:00"),
         "45 minutes");
   end Test_ISO_Timestamps;

   ---------------------------------------------------------------------------
   --  11. Relative time -- since
   ---------------------------------------------------------------------------
   procedure Test_Format_Since is
      Loc : constant Locale_Access :=
        Sayableduration_Locales.Get_Locale ("en");
   begin
      --  11.1
      Assert_Eq ("11.1 since just now",
         Sayableduration.Format_Since
           (Loc.all, Normal,
            "2025-01-15T10:00:00", "2025-01-15T10:00:00"),
         "just now");

      --  11.2
      Assert_Eq ("11.2 30 seconds ago",
         Sayableduration.Format_Since
           (Loc.all, Normal,
            "2025-01-15T10:00:00", "2025-01-15T10:00:30"),
         "30 seconds ago");

      --  11.3
      Assert_Eq ("11.3 45 minutes ago",
         Sayableduration.Format_Duration
           (Loc.all, Normal,
            "2025-01-15T10:00:00", "2025-01-15T10:45:00"),
         "45 minutes");

      --  11.4
      Assert_Eq ("11.4 3 hours ago",
         Sayableduration.Format_Since
           (Loc.all, Normal,
            "2025-01-15T10:00:00", "2025-01-15T13:00:00"),
         "3 hours ago");
   end Test_Format_Since;

   ---------------------------------------------------------------------------
   --  12. Relative time -- until
   ---------------------------------------------------------------------------
   procedure Test_Format_Until is
      Loc : constant Locale_Access :=
        Sayableduration_Locales.Get_Locale ("en");
   begin
      --  12.1
      Assert_Eq ("12.1 until just now",
         Sayableduration.Format_Until
           (Loc.all, Normal,
            "2025-01-15T10:00:00", "2025-01-15T10:00:00"),
         "just now");

      --  12.2
      Assert_Eq ("12.2 in 20 minutes",
         Sayableduration.Format_Until
           (Loc.all, Normal,
            "2025-01-15T10:20:00", "2025-01-15T10:00:00"),
         "in 20 minutes");

      --  12.3
      Assert_Eq ("12.3 in 3 hours",
         Sayableduration.Format_Until
           (Loc.all, Normal,
            "2025-01-15T13:00:00", "2025-01-15T10:00:00"),
         "in 3 hours");
   end Test_Format_Until;

   ---------------------------------------------------------------------------
   --  13. Locale -- German
   ---------------------------------------------------------------------------
   procedure Test_Locale_German is
      Loc : constant Locale_Access :=
        Sayableduration_Locales.Get_Locale ("de");
   begin
      --  13.1
      Assert_Eq ("13.1 German 1 hour",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 3600),
         "1 Stunde");

      --  13.2
      Assert_Eq ("13.2 German ago",
         Sayableduration.Format_Since
           (Loc.all, Normal,
            "2025-01-15T10:00:00", "2025-01-15T10:05:00"),
         "vor 5 Minuten");
   end Test_Locale_German;

   ---------------------------------------------------------------------------
   --  14. Locale -- French
   ---------------------------------------------------------------------------
   procedure Test_Locale_French is
      Loc : constant Locale_Access :=
        Sayableduration_Locales.Get_Locale ("fr");
   begin
      --  14.1
      Assert_Eq ("14.1 French 2 hours",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 7200),
         "2 heures");
   end Test_Locale_French;

   ---------------------------------------------------------------------------
   --  15. Locale -- Japanese
   ---------------------------------------------------------------------------
   procedure Test_Locale_Japanese is
      Loc : constant Locale_Access :=
        Sayableduration_Locales.Get_Locale ("ja");
   begin
      --  15.1
      Assert_Eq ("15.1 Japanese 2 minutes",
         Sayableduration.Format_Duration
           (Loc.all, Normal, 120),
         "2" & Character'Val (16#E5#) & Character'Val (16#88#)
         & Character'Val (16#86#));

      --  15.2
      Assert_Eq ("15.2 Japanese 1 hour ago",
         Sayableduration.Format_Since
           (Loc.all, Normal,
            "2025-01-15T10:00:00", "2025-01-15T11:00:00"),
         "1" & Character'Val (16#E6#) & Character'Val (16#99#)
         & Character'Val (16#82#)
         & Character'Val (16#E9#) & Character'Val (16#96#)
         & Character'Val (16#93#)
         & Character'Val (16#E5#) & Character'Val (16#89#)
         & Character'Val (16#8D#));
   end Test_Locale_Japanese;

   ---------------------------------------------------------------------------
   --  16. Short compactness
   ---------------------------------------------------------------------------
   procedure Test_Short_Compactness is
      Loc : constant Locale_Access :=
        Sayableduration_Locales.Get_Locale ("en");
   begin
      --  16.1
      Assert_Eq ("16.1 short 1 hour",
         Sayableduration.Format_Duration
           (Loc.all, Short, 3600),
         "1h");

      --  16.2
      Assert_Eq ("16.2 short 1m 30s",
         Sayableduration.Format_Duration
           (Loc.all, Short, 90),
         "1m, 30s");
   end Test_Short_Compactness;

   ---------------------------------------------------------------------------
   --  17. Compact compactness
   ---------------------------------------------------------------------------
   procedure Test_Compact_Compactness is
      Loc : constant Locale_Access :=
        Sayableduration_Locales.Get_Locale ("en");
   begin
      --  17.1
      Assert_Eq ("17.1 compact 1 hour",
         Sayableduration.Format_Duration
           (Loc.all, Compact, 3600),
         "1h");

      --  17.2
      Assert_Eq ("17.2 compact 1m30s",
         Sayableduration.Format_Duration
           (Loc.all, Compact, 90),
         "1m30s");
   end Test_Compact_Compactness;

   ---------------------------------------------------------------------------
   --  18. Short compactness -- relative time
   ---------------------------------------------------------------------------
   procedure Test_Short_Relative is
   begin
      --  18.1
      Assert_Eq ("18.1 days and hours both kept",
         Sayableduration.Format_Since
           (Sayableduration_Locales.Get_Locale ("men").all,
            Normal, "2025-01-20T01:32:11", "2025-01-22T15:39:16"),
         "l" & Character'Val (16#C9#) & Character'Val (16#94#) & "h" & Character'Val (16#C9#) & Character'Val (16#94#) & "nga 2, awa 14 taa gb" & Character'Val (16#C9#) & Character'Val (16#94#) & "y" & Character'Val (16#C9#) & Character'Val (16#94#));
   end Test_Short_Relative;

   ---------------------------------------------------------------------------
   --  19. Range (500-year ceiling)
   ---------------------------------------------------------------------------
   procedure Test_Range_Ceiling is
   begin
      --  19.1
      Assert_Eq ("19.1 500 Julian years: 6000 months, the ceiling",
         Sayableduration.Format_Duration
           (Sayableduration_Locales.Get_Locale ("en").all,
            Normal, 15778800000),
         "500 years");
      --  19.2
      Assert_Null ("19.2 over 6000 months",
         Sayableduration.Format_Duration
           (Sayableduration_Locales.Get_Locale ("en").all,
            Normal, 15800000000));
      --  19.3
      Assert_Null ("19.3 well beyond the ceiling (and 32-bit range)",
         Sayableduration.Format_Duration
           (Sayableduration_Locales.Get_Locale ("en").all,
            Normal, 99999999999));
      --  19.4
      Assert_Null ("19.4 525 years ago",
         Sayableduration.Format_Since
           (Sayableduration_Locales.Get_Locale ("en").all,
            Normal, "1500-01-01T00:00:00", "2025-01-01T00:00:00"));
      --  19.5
      Assert_Null ("19.5 575 years from now",
         Sayableduration.Format_Until
           (Sayableduration_Locales.Get_Locale ("en").all,
            Normal, "2600-01-01T00:00:00", "2025-01-01T00:00:00"));
   end Test_Range_Ceiling;

   ---------------------------------------------------------------------------
   --  20. Timestamp validation
   ---------------------------------------------------------------------------
   procedure Test_Timestamp_Validation is
   begin
      --  20.1
      Assert_Eq ("20.1 seconds are optional",
         Sayableduration.Format_Duration
           (Sayableduration_Locales.Get_Locale ("en").all,
            Normal, "2025-01-15T10:00", "2025-01-15T11:30:00"),
         "1" & Character'Val (16#C2#) & Character'Val (16#BD#) & " hours");
      --  20.2
      Assert_Null ("20.2 minutes are required",
         Sayableduration.Format_Duration
           (Sayableduration_Locales.Get_Locale ("en").all,
            Normal, "2025-01-15T10", "2025-01-15T11:30:00"));
      --  20.3
      Assert_Null ("20.3 unpadded date",
         Sayableduration.Format_Duration
           (Sayableduration_Locales.Get_Locale ("en").all,
            Normal, "2025-1-5T10:00:00", "2025-01-15T11:30:00"));
      --  20.4
      Assert_Null ("20.4 impossible date",
         Sayableduration.Format_Duration
           (Sayableduration_Locales.Get_Locale ("en").all,
            Normal, "2025-02-30T10:00:00", "2025-03-15T11:30:00"));
      --  20.5
      Assert_Null ("20.5 hour out of range",
         Sayableduration.Format_Since
           (Sayableduration_Locales.Get_Locale ("en").all,
            Normal, "2025-01-15T10:00:00", "2025-01-15T25:00:00"));
   end Test_Timestamp_Validation;

begin
   Test_Null_Edge_Cases;
   Test_Seconds_Tier;
   Test_Minutes_Seconds_Tier;
   Test_Minutes_Tier;
   Test_Hours_Minutes_Tier;
   Test_Hours_Tier;
   Test_Days_Tier;
   Test_Weeks_Tier;
   Test_Months_Years_Tier;
   Test_ISO_Timestamps;
   Test_Format_Since;
   Test_Format_Until;
   Test_Locale_German;
   Test_Locale_French;
   Test_Locale_Japanese;
   Test_Short_Compactness;
   Test_Compact_Compactness;
   Test_Short_Relative;
   Test_Range_Ceiling;
   Test_Timestamp_Validation;

   Put_Line (Natural'Image (Tests_Passed) & " passed," &
             Natural'Image (Tests_Failed) & " failed");

   if Tests_Failed > 0 then
      raise Program_Error with "Test failures occurred";
   end if;
end Test_Format_Duration;
