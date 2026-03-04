with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Strings.Fixed;
with Parenttime_Types;     use Parenttime_Types;
with Parenttime;
with Parenttime_Locales;

procedure Test_Format_Age is

   Tests_Passed : Natural := 0;
   Tests_Failed : Natural := 0;

   Half : constant String := Character'Val (16#C2#) & Character'Val (16#BD#);

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
         Put_Line ("FAIL [" & Name & "]: expected empty, got """ & Got & """");
         Tests_Failed := Tests_Failed + 1;
      end if;
   end Assert_Null;

   procedure Assert_Contains (Name : String; Got : String; Substr : String) is
   begin
      if Ada.Strings.Fixed.Index (Got, Substr) > 0 then
         Tests_Passed := Tests_Passed + 1;
      else
         Put_Line ("FAIL [" & Name & "]: """ & Got &
                   """ does not contain """ & Substr & """");
         Tests_Failed := Tests_Failed + 1;
      end if;
   end Assert_Contains;

   procedure Assert_True (Name : String; Cond : Boolean) is
   begin
      if Cond then
         Tests_Passed := Tests_Passed + 1;
      else
         Put_Line ("FAIL [" & Name & "]: condition was false");
         Tests_Failed := Tests_Failed + 1;
      end if;
   end Assert_True;

   ---------------------------------------------------------------------------
   --  formatAge --  null/edge cases
   ---------------------------------------------------------------------------
   procedure Test_Null_Edge_Cases is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  1.1, 1.3
      Assert_Null ("empty string",
         Parenttime.Format_Age (Loc.all, Normal, "", "2025-06-15"));

      --  1.4
      Assert_Null ("future dob",
         Parenttime.Format_Age (Loc.all, Normal, "2025-07-01", "2025-06-15"));

      --  1.5
      Assert_Eq ("exactly 500 years",
         Parenttime.Format_Age (Loc.all, Normal, "1525-06-15", "2025-06-15"),
         "500 years");

      --  1.6
      Assert_Null ("501 years exceeds max",
         Parenttime.Format_Age (Loc.all, Normal, "1524-06-15", "2025-06-15"));

      --  1.7
      Assert_Null ("1000 years exceeds max",
         Parenttime.Format_Age (Loc.all, Normal, "1025-06-15", "2025-06-15"));
   end Test_Null_Edge_Cases;

   ---------------------------------------------------------------------------
   --  formatAge --  days tier (0-6)
   ---------------------------------------------------------------------------
   procedure Test_Days_Tier is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  2.1
      Assert_Eq ("born today",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-15", "2025-06-15"),
         "Newborn");

      --  2.2
      Assert_Eq ("1 day",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-14", "2025-06-15"),
         "1 day");

      --  2.3
      Assert_Eq ("3 days",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-12", "2025-06-15"),
         "3 days");

      --  2.4
      Assert_Eq ("6 days",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-09", "2025-06-15"),
         "6 days");

      --  2.5
      Assert_Eq ("7 days -> 1 week",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-08", "2025-06-15"),
         "1 week");
   end Test_Days_Tier;

   ---------------------------------------------------------------------------
   --  formatAge --  weeks+days tier
   ---------------------------------------------------------------------------
   procedure Test_Weeks_Days_Tier is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  3.1
      Assert_Eq ("7 days",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-08", "2025-06-15"),
         "1 week");

      --  3.2
      Assert_Eq ("8 days",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-07", "2025-06-15"),
         "1 week, 1 day");

      --  3.3
      Assert_Eq ("9 days",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-06", "2025-06-15"),
         "1 week, 2 days");

      --  3.4
      Assert_Eq ("13 days",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-02", "2025-06-15"),
         "1 week, 6 days");

      --  3.5
      Assert_Eq ("14 days",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-01", "2025-06-15"),
         "2 weeks");

      --  3.6
      Assert_Eq ("15 days",
         Parenttime.Format_Age (Loc.all, Normal, "2025-05-31", "2025-06-15"),
         "2 weeks, 1 day");

      --  3.7
      Assert_Eq ("20 days",
         Parenttime.Format_Age (Loc.all, Normal, "2025-05-26", "2025-06-15"),
         "2 weeks, 6 days");

      --  3.8
      Assert_Eq ("21 days",
         Parenttime.Format_Age (Loc.all, Normal, "2025-05-25", "2025-06-15"),
         "3 weeks");

      --  3.9
      Assert_Eq ("1 cal month still weeks",
         Parenttime.Format_Age (Loc.all, Normal, "2025-05-15", "2025-06-15"),
         "4 weeks, 3 days");

      --  3.10
      Assert_Eq ("2 cal months still weeks",
         Parenttime.Format_Age (Loc.all, Normal, "2025-04-15", "2025-06-15"),
         "8 weeks, 5 days");

      --  3.11
      Assert_Eq ("day before 3mo still weeks",
         Parenttime.Format_Age (Loc.all, Normal, "2025-03-15", "2025-06-14"),
         "13 weeks");

      --  3.12
      Assert_Eq ("on 3mo birthday",
         Parenttime.Format_Age (Loc.all, Normal, "2025-03-15", "2025-06-15"),
         "3 months");
   end Test_Weeks_Days_Tier;

   ---------------------------------------------------------------------------
   --  formatAge --  month boundaries: standard months
   ---------------------------------------------------------------------------
   procedure Test_Month_Boundary_Standard is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  4.1
      Assert_Eq ("Jan1->Apr1=3mo",
         Parenttime.Format_Age (Loc.all, Normal, "2025-01-01", "2025-04-01"),
         "3 months");

      --  4.2
      Assert_Contains ("Jan1->Mar31 still weeks",
         Parenttime.Format_Age (Loc.all, Normal, "2025-01-01", "2025-03-31"),
         "weeks");

      --  4.3
      Assert_Eq ("Jun15->Sep15=3mo",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-15", "2025-09-15"),
         "3 months");

      --  4.4
      Assert_Contains ("Jun15->Sep14 still weeks",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-15", "2025-09-14"),
         "weeks");

      --  4.5
      Assert_Eq ("Jun15->Dec15=6mo",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-15", "2025-12-15"),
         "6 months");
   end Test_Month_Boundary_Standard;

   ---------------------------------------------------------------------------
   --  formatAge --  month boundaries: February non-leap
   ---------------------------------------------------------------------------
   procedure Test_Month_Boundary_Feb_Non_Leap is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  5.1
      Assert_Eq ("Jan31->Feb28 non-leap",
         Parenttime.Format_Age (Loc.all, Normal, "2025-01-31", "2025-02-28"),
         "4 weeks");

      --  5.2
      Assert_Eq ("Jan31->Apr30=3mo",
         Parenttime.Format_Age (Loc.all, Normal, "2025-01-31", "2025-04-30"),
         "3 months");

      --  5.3
      Assert_Contains ("Jan31->Apr29 still weeks",
         Parenttime.Format_Age (Loc.all, Normal, "2025-01-31", "2025-04-29"),
         "weeks");

      --  5.4
      Assert_Eq ("Feb1->May1=3mo",
         Parenttime.Format_Age (Loc.all, Normal, "2025-02-01", "2025-05-01"),
         "3 months");

      --  5.5
      Assert_Contains ("Feb1->Apr30 still weeks",
         Parenttime.Format_Age (Loc.all, Normal, "2025-02-01", "2025-04-30"),
         "weeks");
   end Test_Month_Boundary_Feb_Non_Leap;

   ---------------------------------------------------------------------------
   --  formatAge --  month boundaries: February leap year
   ---------------------------------------------------------------------------
   procedure Test_Month_Boundary_Feb_Leap is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  6.1
      Assert_Eq ("Jan31->Feb29 leap",
         Parenttime.Format_Age (Loc.all, Normal, "2024-01-31", "2024-02-29"),
         "4 weeks, 1 day");

      --  6.2
      Assert_Eq ("Jan31->Feb28 leap",
         Parenttime.Format_Age (Loc.all, Normal, "2024-01-31", "2024-02-28"),
         "4 weeks");

      --  6.3
      Assert_Eq ("Jan31->Apr30 leap=3mo",
         Parenttime.Format_Age (Loc.all, Normal, "2024-01-31", "2024-04-30"),
         "3 months");

      --  6.4
      Assert_Contains ("Jan30->Feb29 leap still weeks",
         Parenttime.Format_Age (Loc.all, Normal, "2024-01-30", "2024-02-29"),
         "weeks");

      --  6.5
      Assert_Contains ("Jan30->Feb28 leap still weeks",
         Parenttime.Format_Age (Loc.all, Normal, "2024-01-30", "2024-02-28"),
         "weeks");
   end Test_Month_Boundary_Feb_Leap;

   ---------------------------------------------------------------------------
   --  formatAge --  month boundaries: 30-day months
   ---------------------------------------------------------------------------
   procedure Test_Month_Boundary_30day is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  7.1
      Assert_Eq ("Mar31->Jun30=3mo",
         Parenttime.Format_Age (Loc.all, Normal, "2025-03-31", "2025-06-30"),
         "3 months");

      --  7.2
      Assert_Contains ("Mar31->Jun29 still weeks",
         Parenttime.Format_Age (Loc.all, Normal, "2025-03-31", "2025-06-29"),
         "weeks");

      --  7.3
      Assert_Eq ("Aug31->Nov30=3mo",
         Parenttime.Format_Age (Loc.all, Normal, "2025-08-31", "2025-11-30"),
         "3 months");

      --  7.4
      Assert_Contains ("Aug31->Nov29 still weeks",
         Parenttime.Format_Age (Loc.all, Normal, "2025-08-31", "2025-11-29"),
         "weeks");
   end Test_Month_Boundary_30day;

   ---------------------------------------------------------------------------
   --  formatAge --  leap year baby (born Feb 29)
   ---------------------------------------------------------------------------
   procedure Test_Leap_Year_Baby is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  8.1
      Assert_Eq ("Feb29->May29=3mo",
         Parenttime.Format_Age (Loc.all, Normal, "2024-02-29", "2024-05-29"),
         "3 months");

      --  8.2
      Assert_Contains ("Feb29->May28 still weeks",
         Parenttime.Format_Age (Loc.all, Normal, "2024-02-29", "2024-05-28"),
         "weeks");

      --  8.3
      Assert_Eq ("Feb29->Feb28 next yr=12mo",
         Parenttime.Format_Age (Loc.all, Normal, "2024-02-29", "2025-02-28"),
         "12 months");

      --  8.4
      Assert_Eq ("Feb29->Mar1 next yr=12mo",
         Parenttime.Format_Age (Loc.all, Normal, "2024-02-29", "2025-03-01"),
         "12 months");
   end Test_Leap_Year_Baby;

   ---------------------------------------------------------------------------
   --  formatAge --  months tier (3-23)
   ---------------------------------------------------------------------------
   procedure Test_Months_Tier is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  9.1
      Assert_Eq ("3 months at transition",
         Parenttime.Format_Age (Loc.all, Normal, "2025-01-15", "2025-04-15"),
         "3 months");

      --  9.2
      Assert_Eq ("6 months",
         Parenttime.Format_Age (Loc.all, Normal, "2025-01-15", "2025-07-15"),
         "6 months");

      --  9.3
      Assert_Eq ("12 months (not 1 year)",
         Parenttime.Format_Age (Loc.all, Normal, "2024-06-15", "2025-06-15"),
         "12 months");

      --  9.4
      Assert_Eq ("23 months upper",
         Parenttime.Format_Age (Loc.all, Normal, "2024-01-15", "2025-12-15"),
         "23 months");

      --  9.5
      Assert_Eq ("day before boundary",
         Parenttime.Format_Age (Loc.all, Normal, "2025-01-15", "2025-07-14"),
         "5 months");

      --  9.6
      Assert_Eq ("cross year boundary",
         Parenttime.Format_Age (Loc.all, Normal, "2024-11-10", "2025-04-10"),
         "5 months");
   end Test_Months_Tier;

   ---------------------------------------------------------------------------
   --  formatAge --  years+months tier (24-35 months)
   ---------------------------------------------------------------------------
   procedure Test_Years_Months_Tier is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  10.1
      Assert_Eq ("2 years at 24mo",
         Parenttime.Format_Age (Loc.all, Normal, "2023-06-15", "2025-06-15"),
         "2 years");

      --  10.2
      Assert_Eq ("2 years 1 month",
         Parenttime.Format_Age (Loc.all, Normal, "2023-06-15", "2025-07-15"),
         "2 years, 1 month");

      --  10.3
      Assert_Eq ("2 years 6 months",
         Parenttime.Format_Age (Loc.all, Normal, "2023-06-15", "2025-12-15"),
         "2 years, 6 months");

      --  10.4
      Assert_Eq ("2 years 11 months",
         Parenttime.Format_Age (Loc.all, Normal, "2023-06-15", "2026-05-15"),
         "2 years, 11 months");

      --  10.5
      Assert_Eq ("day before 24mo",
         Parenttime.Format_Age (Loc.all, Normal, "2023-06-15", "2025-06-14"),
         "23 months");
   end Test_Years_Months_Tier;

   ---------------------------------------------------------------------------
   --  formatAge --  half-year tier (3-6 years)
   ---------------------------------------------------------------------------
   procedure Test_Half_Year_Tier is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  11.1
      Assert_Eq ("3 years exactly",
         Parenttime.Format_Age (Loc.all, Normal, "2022-06-15", "2025-06-15"),
         "3 years");

      --  11.2
      Assert_Eq ("3 years 5 months",
         Parenttime.Format_Age (Loc.all, Normal, "2022-06-15", "2025-11-15"),
         "3 years");

      --  11.3
      Assert_Eq ("3.5 years at 3y6m",
         Parenttime.Format_Age (Loc.all, Normal, "2022-06-15", "2025-12-15"),
         "3" & Half & " years");

      --  11.4
      Assert_Eq ("3.5 years at 3y11m",
         Parenttime.Format_Age (Loc.all, Normal, "2022-06-15", "2026-05-15"),
         "3" & Half & " years");

      --  11.5
      Assert_Eq ("4 years exactly",
         Parenttime.Format_Age (Loc.all, Normal, "2021-06-15", "2025-06-15"),
         "4 years");

      --  11.6
      Assert_Eq ("4.5 years",
         Parenttime.Format_Age (Loc.all, Normal, "2021-06-15", "2025-12-15"),
         "4" & Half & " years");

      --  11.7
      Assert_Eq ("5 years",
         Parenttime.Format_Age (Loc.all, Normal, "2020-06-15", "2025-06-15"),
         "5 years");

      --  11.8
      Assert_Eq ("5.5 years at 5y8m",
         Parenttime.Format_Age (Loc.all, Normal, "2020-06-15", "2026-02-15"),
         "5" & Half & " years");

      --  11.9
      Assert_Eq ("6 years",
         Parenttime.Format_Age (Loc.all, Normal, "2019-06-15", "2025-06-15"),
         "6 years");

      --  11.10
      Assert_Eq ("6.5 years",
         Parenttime.Format_Age (Loc.all, Normal, "2019-06-15", "2025-12-15"),
         "6" & Half & " years");

      --  11.11
      Assert_Eq ("6.5 years at 6y11m",
         Parenttime.Format_Age (Loc.all, Normal, "2019-06-15", "2026-05-15"),
         "6" & Half & " years");

      --  11.12
      Assert_Eq ("day before 3rd bday",
         Parenttime.Format_Age (Loc.all, Normal, "2022-06-15", "2025-06-14"),
         "2 years, 11 months");
   end Test_Half_Year_Tier;

   ---------------------------------------------------------------------------
   --  formatAge --  integer tier (7+ years)
   ---------------------------------------------------------------------------
   procedure Test_Integer_Tier is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  12.1
      Assert_Eq ("7 years exactly",
         Parenttime.Format_Age (Loc.all, Normal, "2018-06-15", "2025-06-15"),
         "7 years");

      --  12.2
      Assert_Eq ("7y3m no half",
         Parenttime.Format_Age (Loc.all, Normal, "2018-03-20", "2025-06-15"),
         "7 years");

      --  12.3
      Assert_Eq ("45 years",
         Parenttime.Format_Age (Loc.all, Normal, "1980-01-01", "2025-06-15"),
         "45 years");
   end Test_Integer_Tier;

   ---------------------------------------------------------------------------
   --  formatAge --  cross-year with Feb
   ---------------------------------------------------------------------------
   procedure Test_Cross_Year_Feb is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  13.1
      Assert_Eq ("Dec31->Mar31=3mo",
         Parenttime.Format_Age (Loc.all, Normal, "2024-12-31", "2025-03-31"),
         "3 months");

      --  13.2
      Assert_Contains ("Dec31->Mar30 still weeks",
         Parenttime.Format_Age (Loc.all, Normal, "2024-12-31", "2025-03-30"),
         "weeks");

      --  13.3
      Assert_Eq ("Nov30->Feb28=3mo",
         Parenttime.Format_Age (Loc.all, Normal, "2024-11-30", "2025-02-28"),
         "3 months");

      --  13.4
      Assert_Contains ("Nov30->Feb27 still weeks",
         Parenttime.Format_Age (Loc.all, Normal, "2024-11-30", "2025-02-27"),
         "weeks");
   end Test_Cross_Year_Feb;

   ---------------------------------------------------------------------------
   --  formatAge --  born-on-31st progression
   ---------------------------------------------------------------------------
   procedure Test_Born_On_31st is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  14.1
      Assert_Eq ("Jan31->Apr30=3mo",
         Parenttime.Format_Age (Loc.all, Normal, "2025-01-31", "2025-04-30"),
         "3 months");

      --  14.2
      Assert_Eq ("Jan31->May31=4mo",
         Parenttime.Format_Age (Loc.all, Normal, "2025-01-31", "2025-05-31"),
         "4 months");

      --  14.3
      Assert_Eq ("Jan31->Jun30=5mo",
         Parenttime.Format_Age (Loc.all, Normal, "2025-01-31", "2025-06-30"),
         "5 months");

      --  14.4
      Assert_Eq ("Jan31->Jul1=5mo",
         Parenttime.Format_Age (Loc.all, Normal, "2025-01-31", "2025-07-01"),
         "5 months");

      --  14.5
      Assert_Eq ("Jan31->Jul31=6mo",
         Parenttime.Format_Age (Loc.all, Normal, "2025-01-31", "2025-07-31"),
         "6 months");
   end Test_Born_On_31st;

   ---------------------------------------------------------------------------
   --  formatStage --  null/edge cases
   ---------------------------------------------------------------------------
   procedure Test_Stage_Null_Edge_Cases is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  16.1, 16.3
      Assert_Null ("stage empty",
         Parenttime.Format_Stage (Loc.all, "", "2025-06-15"));

      --  16.4
      Assert_Null ("stage future",
         Parenttime.Format_Stage (Loc.all, "2025-07-01", "2025-06-15"));

      --  16.5
      Assert_Eq ("stage 500 years",
         Parenttime.Format_Stage (Loc.all, "1525-06-15", "2025-06-15"),
         "Adult");

      --  16.6
      Assert_Null ("stage 501 years",
         Parenttime.Format_Stage (Loc.all, "1524-06-15", "2025-06-15"));
   end Test_Stage_Null_Edge_Cases;

   ---------------------------------------------------------------------------
   --  formatStage --  Newborn (0-1 months)
   ---------------------------------------------------------------------------
   procedure Test_Stage_Newborn is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  17.1
      Assert_Eq ("stage born today",
         Parenttime.Format_Stage (Loc.all, "2025-06-15", "2025-06-15"),
         "Newborn");

      --  17.2
      Assert_Eq ("stage 1 day",
         Parenttime.Format_Stage (Loc.all, "2025-06-14", "2025-06-15"),
         "Newborn");

      --  17.3
      Assert_Eq ("stage 3 weeks",
         Parenttime.Format_Stage (Loc.all, "2025-05-25", "2025-06-15"),
         "Newborn");

      --  17.4
      Assert_Eq ("stage 1 month",
         Parenttime.Format_Stage (Loc.all, "2025-05-15", "2025-06-15"),
         "Newborn");

      --  17.5
      Assert_Eq ("stage 1mo 29d",
         Parenttime.Format_Stage (Loc.all, "2025-04-16", "2025-06-15"),
         "Newborn");

      --  17.6
      Assert_Eq ("stage 2mo -> Infant",
         Parenttime.Format_Stage (Loc.all, "2025-04-15", "2025-06-15"),
         "Infant");
   end Test_Stage_Newborn;

   ---------------------------------------------------------------------------
   --  formatStage --  Infant (2-11 months)
   ---------------------------------------------------------------------------
   procedure Test_Stage_Infant is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  18.1
      Assert_Eq ("stage 2 months",
         Parenttime.Format_Stage (Loc.all, "2025-04-15", "2025-06-15"),
         "Infant");

      --  18.2
      Assert_Eq ("stage 6 months",
         Parenttime.Format_Stage (Loc.all, "2024-12-15", "2025-06-15"),
         "Infant");

      --  18.3
      Assert_Eq ("stage 11 months",
         Parenttime.Format_Stage (Loc.all, "2024-07-15", "2025-06-15"),
         "Infant");

      --  18.4
      Assert_Eq ("stage 12mo -> Toddler",
         Parenttime.Format_Stage (Loc.all, "2024-06-15", "2025-06-15"),
         "Toddler");
   end Test_Stage_Infant;

   ---------------------------------------------------------------------------
   --  formatStage --  Toddler (12-35 months)
   ---------------------------------------------------------------------------
   procedure Test_Stage_Toddler is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  19.1
      Assert_Eq ("stage 12 months",
         Parenttime.Format_Stage (Loc.all, "2024-06-15", "2025-06-15"),
         "Toddler");

      --  19.2
      Assert_Eq ("stage 18 months",
         Parenttime.Format_Stage (Loc.all, "2024-01-15", "2025-07-15"),
         "Toddler");

      --  19.3
      Assert_Eq ("stage 24 months",
         Parenttime.Format_Stage (Loc.all, "2023-06-15", "2025-06-15"),
         "Toddler");

      --  19.4
      Assert_Eq ("stage 35 months",
         Parenttime.Format_Stage (Loc.all, "2023-06-15", "2026-05-15"),
         "Toddler");

      --  19.5
      Assert_Eq ("stage 36mo -> Child",
         Parenttime.Format_Stage (Loc.all, "2022-06-15", "2025-06-15"),
         "Child");
   end Test_Stage_Toddler;

   ---------------------------------------------------------------------------
   --  formatStage --  Child (36-155 months)
   ---------------------------------------------------------------------------
   procedure Test_Stage_Child is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  20.1
      Assert_Eq ("stage 3 years",
         Parenttime.Format_Stage (Loc.all, "2022-06-15", "2025-06-15"),
         "Child");

      --  20.2
      Assert_Eq ("stage 4 years",
         Parenttime.Format_Stage (Loc.all, "2021-06-15", "2025-06-15"),
         "Child");

      --  20.3
      Assert_Eq ("stage 6 years",
         Parenttime.Format_Stage (Loc.all, "2019-06-15", "2025-06-15"),
         "Child");

      --  20.4
      Assert_Eq ("stage 9 years",
         Parenttime.Format_Stage (Loc.all, "2016-06-15", "2025-06-15"),
         "Child");

      --  20.5
      Assert_Eq ("stage 12y11m",
         Parenttime.Format_Stage (Loc.all, "2013-06-15", "2026-05-15"),
         "Child");

      --  20.6
      Assert_Eq ("stage 13y -> Teenager",
         Parenttime.Format_Stage (Loc.all, "2012-06-15", "2025-06-15"),
         "Teenager");
   end Test_Stage_Child;

   ---------------------------------------------------------------------------
   --  formatStage --  Teenager (156-215 months)
   ---------------------------------------------------------------------------
   procedure Test_Stage_Teenager is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  21.1
      Assert_Eq ("stage 13 years",
         Parenttime.Format_Stage (Loc.all, "2012-06-15", "2025-06-15"),
         "Teenager");

      --  21.2
      Assert_Eq ("stage 15 years",
         Parenttime.Format_Stage (Loc.all, "2010-06-15", "2025-06-15"),
         "Teenager");

      --  21.3
      Assert_Eq ("stage 17y11m",
         Parenttime.Format_Stage (Loc.all, "2008-06-15", "2026-05-15"),
         "Teenager");

      --  21.4
      Assert_Eq ("stage 18y -> Adult",
         Parenttime.Format_Stage (Loc.all, "2007-06-15", "2025-06-15"),
         "Adult");
   end Test_Stage_Teenager;

   ---------------------------------------------------------------------------
   --  formatStage --  Adult (216+ months)
   ---------------------------------------------------------------------------
   procedure Test_Stage_Adult is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  22.1
      Assert_Eq ("stage 18 years",
         Parenttime.Format_Stage (Loc.all, "2007-06-15", "2025-06-15"),
         "Adult");

      --  22.2
      Assert_Eq ("stage 25 years",
         Parenttime.Format_Stage (Loc.all, "2000-06-15", "2025-06-15"),
         "Adult");

      --  22.3
      Assert_Eq ("stage 45 years",
         Parenttime.Format_Stage (Loc.all, "1980-01-01", "2025-06-15"),
         "Adult");
   end Test_Stage_Adult;

   ---------------------------------------------------------------------------
   --  formatStage --  gender support (Spanish)
   ---------------------------------------------------------------------------
   procedure Test_Stage_Gender_Spanish is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("es");

      E_Acute : constant String :=
        Character'Val (16#C3#) & Character'Val (16#A9#);
      N_Tilde : constant String :=
        Character'Val (16#C3#) & Character'Val (16#B1#);
   begin
      --  25.13
      Assert_Eq ("ES stage newborn m",
         Parenttime.Format_Stage (Loc.all, "2025-06-15", "2025-06-15"),
         "Reci" & E_Acute & "n nacido");

      --  25.15
      Assert_Eq ("ES stage toddler m",
         Parenttime.Format_Stage (Loc.all, "2024-06-15", "2025-06-15"),
         "Ni" & N_Tilde & "o peque" & N_Tilde & "o");

      --  25.16
      Assert_Eq ("ES stage child m",
         Parenttime.Format_Stage (Loc.all, "2022-06-15", "2025-06-15"),
         "Ni" & N_Tilde & "o");

      --  25.18
      Assert_Eq ("ES stage adult m",
         Parenttime.Format_Stage (Loc.all, "2007-06-15", "2025-06-15"),
         "Adulto");

      --  Feminine forms
      Assert_Eq ("ES stage newborn f",
         Parenttime.Format_Stage (Loc.all, "2025-06-15", "2025-06-15", "f"),
         "Reci" & E_Acute & "n nacida");

      --  25.14
      Assert_Eq ("ES stage infant f",
         Parenttime.Format_Stage (Loc.all, "2025-01-15", "2025-06-15", "f"),
         "Beb" & E_Acute);

      --  25.17
      Assert_Eq ("ES stage teenager f",
         Parenttime.Format_Stage (Loc.all, "2012-06-15", "2025-06-15", "f"),
         "Adolescente");

      Assert_Eq ("ES stage adult f",
         Parenttime.Format_Stage (Loc.all, "2007-06-15", "2025-06-15", "f"),
         "Adulta");
   end Test_Stage_Gender_Spanish;

   ---------------------------------------------------------------------------
   --  formatStage --  gender-neutral locale
   ---------------------------------------------------------------------------
   procedure Test_Stage_Gender_Neutral is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      Assert_Eq ("EN stage newborn f",
         Parenttime.Format_Stage (Loc.all, "2025-06-15", "2025-06-15", "f"),
         "Newborn");

      Assert_Eq ("EN stage adult f",
         Parenttime.Format_Stage (Loc.all, "2007-06-15", "2025-06-15", "f"),
         "Adult");
   end Test_Stage_Gender_Neutral;

   ---------------------------------------------------------------------------
   --  SayableAge with English locale
   ---------------------------------------------------------------------------
   procedure Test_Parenttime_English is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  24.1
      Assert_Eq ("PT Newborn",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-15", "2025-06-15"),
         "Newborn");

      --  24.2
      Assert_Eq ("PT 3 days",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-12", "2025-06-15"),
         "3 days");

      --  24.3
      Assert_Eq ("PT 1w1d",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-07", "2025-06-15"),
         "1 week, 1 day");

      --  24.4
      Assert_Eq ("PT 6 months",
         Parenttime.Format_Age (Loc.all, Normal, "2025-01-15", "2025-07-15"),
         "6 months");

      --  24.5
      Assert_Eq ("PT 2y1mo",
         Parenttime.Format_Age (Loc.all, Normal, "2023-06-15", "2025-07-15"),
         "2 years, 1 month");

      --  24.6
      Assert_Eq ("PT 3.5y",
         Parenttime.Format_Age (Loc.all, Normal, "2022-06-15", "2025-12-15"),
         "3" & Half & " years");

      --  24.7
      Assert_Eq ("PT 7 years",
         Parenttime.Format_Age (Loc.all, Normal, "2018-06-15", "2025-06-15"),
         "7 years");

      --  24.8
      Assert_Eq ("PT stage Newborn",
         Parenttime.Format_Stage (Loc.all, "2025-06-15", "2025-06-15"),
         "Newborn");

      --  24.9
      Assert_Eq ("PT stage Infant",
         Parenttime.Format_Stage (Loc.all, "2025-01-15", "2025-06-15"),
         "Infant");

      --  24.10
      Assert_Eq ("PT stage Toddler",
         Parenttime.Format_Stage (Loc.all, "2024-06-15", "2025-06-15"),
         "Toddler");

      --  24.11
      Assert_Eq ("PT stage Child",
         Parenttime.Format_Stage (Loc.all, "2022-06-15", "2025-06-15"),
         "Child");

      --  24.12
      Assert_Eq ("PT stage Teenager",
         Parenttime.Format_Stage (Loc.all, "2012-06-15", "2025-06-15"),
         "Teenager");

      --  24.13
      Assert_Eq ("PT stage Adult",
         Parenttime.Format_Stage (Loc.all, "2007-06-15", "2025-06-15"),
         "Adult");

      --  24.14
      Assert_Null ("PT null age",
         Parenttime.Format_Age (Loc.all, Normal, "", "2025-06-15"));

      --  24.15
      Assert_Null ("PT null stage",
         Parenttime.Format_Stage (Loc.all, "", "2025-06-15"));
   end Test_Parenttime_English;

   ---------------------------------------------------------------------------
   --  SayableAge with Spanish locale
   ---------------------------------------------------------------------------
   procedure Test_Parenttime_Spanish is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("es");

      E_Acute : constant String :=
        Character'Val (16#C3#) & Character'Val (16#A9#);
      I_Acute : constant String :=
        Character'Val (16#C3#) & Character'Val (16#AD#);
      N_Tilde : constant String :=
        Character'Val (16#C3#) & Character'Val (16#B1#);
   begin
      --  25.1
      Assert_Eq ("ES justBorn",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-15", "2025-06-15"),
         "Reci" & E_Acute & "n nacido");

      --  25.2
      Assert_Eq ("ES singular day",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-14", "2025-06-15"),
         "1 d" & I_Acute & "a");

      --  25.3
      Assert_Eq ("ES plural days",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-12", "2025-06-15"),
         "3 d" & I_Acute & "as");

      --  25.4
      Assert_Eq ("ES singular week",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-08", "2025-06-15"),
         "1 semana");

      --  25.5
      Assert_Eq ("ES weeks+days",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-07", "2025-06-15"),
         "1 semana, 1 d" & I_Acute & "a");

      --  25.6
      Assert_Eq ("ES plural weeks+days",
         Parenttime.Format_Age (Loc.all, Normal, "2025-05-26", "2025-06-15"),
         "2 semanas, 6 d" & I_Acute & "as");

      --  25.7
      Assert_Eq ("ES months",
         Parenttime.Format_Age (Loc.all, Normal, "2025-01-15", "2025-07-15"),
         "6 meses");

      --  25.8
      Assert_Eq ("ES singular month compound",
         Parenttime.Format_Age (Loc.all, Normal, "2023-06-15", "2025-07-15"),
         "2 a" & N_Tilde & "os, 1 mes");

      --  25.9
      Assert_Eq ("ES years+months",
         Parenttime.Format_Age (Loc.all, Normal, "2023-06-15", "2025-12-15"),
         "2 a" & N_Tilde & "os, 6 meses");

      --  25.10
      Assert_Eq ("ES half marker",
         Parenttime.Format_Age (Loc.all, Normal, "2022-06-15", "2025-12-15"),
         "3 y medio a" & N_Tilde & "os");

      --  25.11
      Assert_Eq ("ES integer years",
         Parenttime.Format_Age (Loc.all, Normal, "2022-06-15", "2025-06-15"),
         "3 a" & N_Tilde & "os");

      --  25.12
      Assert_Eq ("ES 7+ years",
         Parenttime.Format_Age (Loc.all, Normal, "2018-06-15", "2025-06-15"),
         "7 a" & N_Tilde & "os");

      --  25.19
      Assert_Null ("ES null",
         Parenttime.Format_Age (Loc.all, Normal, "", "2025-06-15"));

      --  25.20
      Assert_Null ("ES null stage",
         Parenttime.Format_Stage (Loc.all, "", "2025-06-15"));
   end Test_Parenttime_Spanish;

   ---------------------------------------------------------------------------
   --  Compactness: short
   ---------------------------------------------------------------------------
   procedure Test_Compact_Short is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  26.1
      Assert_Eq ("short days",
         Parenttime.Format_Age (Loc.all, Short, "2025-06-12", "2025-06-15"),
         "3 d");

      --  26.2
      Assert_Eq ("short weeks",
         Parenttime.Format_Age (Loc.all, Short, "2025-06-08", "2025-06-15"),
         "1 wk");

      --  26.3
      Assert_Eq ("short weeks+days",
         Parenttime.Format_Age (Loc.all, Short, "2025-06-07", "2025-06-15"),
         "1 wk, 1 d");

      --  26.4
      Assert_Eq ("short months",
         Parenttime.Format_Age (Loc.all, Short, "2025-01-15", "2025-07-15"),
         "6 mo");

      --  26.5
      Assert_Eq ("short years+months",
         Parenttime.Format_Age (Loc.all, Short, "2023-06-15", "2025-07-15"),
         "2 yr, 1 mo");

      --  26.6
      Assert_Eq ("short half years",
         Parenttime.Format_Age (Loc.all, Short, "2022-06-15", "2025-12-15"),
         "3" & Half & " yr");

      --  26.7
      Assert_Eq ("short integer years",
         Parenttime.Format_Age (Loc.all, Short, "2018-06-15", "2025-06-15"),
         "7 yr");

      --  26.8
      Assert_Eq ("short justBorn",
         Parenttime.Format_Age (Loc.all, Short, "2025-06-15", "2025-06-15"),
         "Newborn");

      --  26.9
      Assert_Eq ("short stages unchanged",
         Parenttime.Format_Stage (Loc.all, "2025-01-15", "2025-06-15"),
         "Infant");
   end Test_Compact_Short;

   ---------------------------------------------------------------------------
   --  Compactness: compact
   ---------------------------------------------------------------------------
   procedure Test_Compact_Compact is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("en");
   begin
      --  27.1
      Assert_Eq ("compact days",
         Parenttime.Format_Age (Loc.all, Compact, "2025-06-12", "2025-06-15"),
         "3d");

      --  27.2
      Assert_Eq ("compact weeks",
         Parenttime.Format_Age (Loc.all, Compact, "2025-06-08", "2025-06-15"),
         "1w");

      --  27.3
      Assert_Eq ("compact weeks+days",
         Parenttime.Format_Age (Loc.all, Compact, "2025-06-07", "2025-06-15"),
         "1w1d");

      --  27.4
      Assert_Eq ("compact months",
         Parenttime.Format_Age (Loc.all, Compact, "2025-01-15", "2025-07-15"),
         "6m");

      --  27.5
      Assert_Eq ("compact years+months",
         Parenttime.Format_Age (Loc.all, Compact, "2023-06-15", "2025-07-15"),
         "2y1m");

      --  27.6
      Assert_Eq ("compact half years",
         Parenttime.Format_Age (Loc.all, Compact, "2022-06-15", "2025-12-15"),
         "3" & Half & "y");

      --  27.7
      Assert_Eq ("compact integer years",
         Parenttime.Format_Age (Loc.all, Compact, "2018-06-15", "2025-06-15"),
         "7y");

      --  27.8
      Assert_Eq ("compact justBorn",
         Parenttime.Format_Age (Loc.all, Compact, "2025-06-15", "2025-06-15"),
         "Newborn");
   end Test_Compact_Compact;

   ---------------------------------------------------------------------------
   --  Locale-specific: Hebrew
   ---------------------------------------------------------------------------
   procedure Test_Locale_Hebrew is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("he");
   begin

      --  29.1 justBorn
      Assert_Contains ("he justBorn",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-15", "2025-06-15"),
         Character'Val (16#D7#) & "");

      --  29.2 1 day one
      Assert_Contains ("he 1 day one",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-14", "2025-06-15"),
         "1");

      --  29.3 3 days other
      Assert_Contains ("he 3 days other",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-12", "2025-06-15"),
         "3");

      --  29.4 2 weeks dual
      Assert_True ("he 2 weeks dual not empty",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-01", "2025-06-15")'Length > 0);

      --  29.5 3 weeks other
      Assert_Contains ("he 3 weeks other",
         Parenttime.Format_Age (Loc.all, Normal, "2025-05-25", "2025-06-15"),
         "3");

      --  29.6 6 months
      Assert_Contains ("he 6 months",
         Parenttime.Format_Age (Loc.all, Normal, "2025-01-15", "2025-07-15"),
         "6");

      --  29.7 3 months
      Assert_Contains ("he 3 months",
         Parenttime.Format_Age (Loc.all, Normal, "2025-03-15", "2025-06-15"),
         "3");

      --  29.8 2y dual + 1m one
      Assert_True ("he 2y1m not empty",
         Parenttime.Format_Age (Loc.all, Normal, "2023-06-15", "2025-07-15")'Length > 0);

      --  29.9 3.5 years half
      Assert_Contains ("he 3.5y half",
         Parenttime.Format_Age (Loc.all, Normal, "2022-06-15", "2025-12-15"),
         "3");

      --  29.10 7+ years
      Assert_Contains ("he 7y other",
         Parenttime.Format_Age (Loc.all, Normal, "2018-06-15", "2025-06-15"),
         "7");

      --  29.11 stage m newborn
      Assert_True ("he stage m newborn",
         Parenttime.Format_Stage (Loc.all, "2025-06-15", "2025-06-15", "m")'Length > 0);

      --  29.12 stage f newborn
      Assert_True ("he stage f newborn",
         Parenttime.Format_Stage (Loc.all, "2025-06-15", "2025-06-15", "f")'Length > 0);

      --  29.13 stage m adult
      Assert_True ("he stage m adult",
         Parenttime.Format_Stage (Loc.all, "2007-06-15", "2025-06-15", "m")'Length > 0);

      --  29.14 stage f adult
      Assert_True ("he stage f adult",
         Parenttime.Format_Stage (Loc.all, "2007-06-15", "2025-06-15", "f")'Length > 0);
   end Test_Locale_Hebrew;

   ---------------------------------------------------------------------------
   --  Locale-specific: Macedonian
   ---------------------------------------------------------------------------
   procedure Test_Locale_Macedonian is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("mk");
   begin
      --  29.15 justBorn
      Assert_True ("mk justBorn not empty",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-15", "2025-06-15")'Length > 0);

      --  29.16 1 day one
      Assert_Contains ("mk 1 day one",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-14", "2025-06-15"),
         "1");

      --  29.17 3 days other
      Assert_Contains ("mk 3 days other",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-12", "2025-06-15"),
         "3");

      --  29.18 6 months other
      Assert_Contains ("mk 6 months",
         Parenttime.Format_Age (Loc.all, Normal, "2025-01-15", "2025-07-15"),
         "6");

      --  29.19 2y1m
      Assert_Contains ("mk 2y1m",
         Parenttime.Format_Age (Loc.all, Normal, "2023-06-15", "2025-07-15"),
         "2");

      --  29.20 3.5y half
      Assert_Contains ("mk 3.5y half",
         Parenttime.Format_Age (Loc.all, Normal, "2022-06-15", "2025-12-15"),
         "3");

      --  29.21 7+ years
      Assert_Contains ("mk 7y",
         Parenttime.Format_Age (Loc.all, Normal, "2018-06-15", "2025-06-15"),
         "7");
   end Test_Locale_Macedonian;

   ---------------------------------------------------------------------------
   --  Locale-specific: Swahili
   ---------------------------------------------------------------------------
   procedure Test_Locale_Swahili is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("sw");
   begin
      --  29.22 justBorn
      Assert_Eq ("sw justBorn",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-15", "2025-06-15"),
         "Mzaliwa mpya");

      --  29.23 1 day
      Assert_Eq ("sw 1 day",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-14", "2025-06-15"),
         "siku 1");

      --  29.24 3 days
      Assert_Eq ("sw 3 days",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-12", "2025-06-15"),
         "siku 3");

      --  29.25 6 months
      Assert_Eq ("sw 6 months",
         Parenttime.Format_Age (Loc.all, Normal, "2025-01-15", "2025-07-15"),
         "miezi 6");

      --  29.26 2y 1m
      Assert_Eq ("sw 2y 1m",
         Parenttime.Format_Age (Loc.all, Normal, "2023-06-15", "2025-07-15"),
         "miaka 2, mwezi 1");

      --  29.27 3.5y half
      Assert_Eq ("sw 3.5y half",
         Parenttime.Format_Age (Loc.all, Normal, "2022-06-15", "2025-12-15"),
         "miaka 3 na nusu");
   end Test_Locale_Swahili;

   ---------------------------------------------------------------------------
   --  Locale-specific: Indonesian
   ---------------------------------------------------------------------------
   procedure Test_Locale_Indonesian is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("id");
   begin
      --  29.28 justBorn
      Assert_Eq ("id justBorn",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-15", "2025-06-15"),
         "Baru lahir");

      --  29.29 1 day
      Assert_Eq ("id 1 day",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-14", "2025-06-15"),
         "1 hari");

      --  29.30 3 days
      Assert_Eq ("id 3 days",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-12", "2025-06-15"),
         "3 hari");

      --  29.31 6 months
      Assert_Eq ("id 6 months",
         Parenttime.Format_Age (Loc.all, Normal, "2025-01-15", "2025-07-15"),
         "6 bulan");

      --  29.32 3.5y half
      Assert_Eq ("id 3.5y half",
         Parenttime.Format_Age (Loc.all, Normal, "2022-06-15", "2025-12-15"),
         "3 tahun setengah");

      --  29.33 7y
      Assert_Eq ("id 7y",
         Parenttime.Format_Age (Loc.all, Normal, "2018-06-15", "2025-06-15"),
         "7 tahun");
   end Test_Locale_Indonesian;

   ---------------------------------------------------------------------------
   --  Locale-specific: Amharic
   ---------------------------------------------------------------------------
   procedure Test_Locale_Amharic is
      Loc : constant Locale_Access := Parenttime_Locales.Get_Locale ("am");
   begin
      --  29.34 justBorn
      Assert_True ("am justBorn not empty",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-15", "2025-06-15")'Length > 0);

      --  29.35 1 day
      Assert_Contains ("am 1 day",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-14", "2025-06-15"),
         "1");

      --  29.36 3 days
      Assert_Contains ("am 3 days",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-12", "2025-06-15"),
         "3");

      --  29.37 1w1d ethiopic delimiter
      Assert_Contains ("am 1w1d",
         Parenttime.Format_Age (Loc.all, Normal, "2025-06-07", "2025-06-15"),
         "1");

      --  29.38 6 months
      Assert_Contains ("am 6 months",
         Parenttime.Format_Age (Loc.all, Normal, "2025-01-15", "2025-07-15"),
         "6");

      --  29.39 3.5y half
      Assert_Contains ("am 3.5y half",
         Parenttime.Format_Age (Loc.all, Normal, "2022-06-15", "2025-12-15"),
         "3");
   end Test_Locale_Amharic;

   ---------------------------------------------------------------------------
   --  Locale lookup by code string
   ---------------------------------------------------------------------------
   procedure Test_Locale_Lookup is
      Loc : Locale_Access;
   begin
      --  30.1
      Loc := Parenttime_Locales.Get_Locale ("en");
      Assert_True ("get(en) not null", Loc /= null);
      Assert_Eq ("get(en) code",
         Ada.Strings.Unbounded.To_String (Loc.all.Code), "en");

      --  30.2
      Loc := Parenttime_Locales.Get_Locale ("fr");
      Assert_True ("get(fr) not null", Loc /= null);
      Assert_Eq ("get(fr) code",
         Ada.Strings.Unbounded.To_String (Loc.all.Code), "fr");

      --  30.3
      Loc := Parenttime_Locales.Get_Locale ("xx");
      Assert_True ("get(xx) null", Loc = null);

      --  30.4
      Loc := Parenttime_Locales.Get_Locale ("");
      Assert_True ("get empty null", Loc = null);

      --  30.5
      Loc := Parenttime_Locales.Get_Locale ("EN");
      Assert_True ("get(EN) null", Loc = null);
   end Test_Locale_Lookup;

begin
   Test_Null_Edge_Cases;
   Test_Days_Tier;
   Test_Weeks_Days_Tier;
   Test_Month_Boundary_Standard;
   Test_Month_Boundary_Feb_Non_Leap;
   Test_Month_Boundary_Feb_Leap;
   Test_Month_Boundary_30day;
   Test_Leap_Year_Baby;
   Test_Months_Tier;
   Test_Years_Months_Tier;
   Test_Half_Year_Tier;
   Test_Integer_Tier;
   Test_Cross_Year_Feb;
   Test_Born_On_31st;
   Test_Stage_Null_Edge_Cases;
   Test_Stage_Newborn;
   Test_Stage_Infant;
   Test_Stage_Toddler;
   Test_Stage_Child;
   Test_Stage_Teenager;
   Test_Stage_Adult;
   Test_Stage_Gender_Spanish;
   Test_Stage_Gender_Neutral;
   Test_Parenttime_English;
   Test_Parenttime_Spanish;
   Test_Compact_Short;
   Test_Compact_Compact;
   Test_Locale_Hebrew;
   Test_Locale_Macedonian;
   Test_Locale_Swahili;
   Test_Locale_Indonesian;
   Test_Locale_Amharic;
   Test_Locale_Lookup;

   New_Line;
   Put_Line ("=== Results ===");
   Put_Line ("Passed:" & Natural'Image (Tests_Passed));
   Put_Line ("Failed:" & Natural'Image (Tests_Failed));
   Put_Line ("Total: " & Natural'Image (Tests_Passed + Tests_Failed));

   if Tests_Failed > 0 then
      raise Program_Error with "Tests failed";
   end if;
end Test_Format_Age;
