with Ada.Text_IO;          use Ada.Text_IO;
with Ada.Calendar;
with Ada.Strings.Unbounded;
with Ada.Strings.Fixed;
with Sayableage_Types;     use Sayableage_Types;
with Sayableage;
with Sayableage_Locales;

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
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  1.1, 1.3
      Assert_Null ("empty string",
         Sayableage.Format_Age (Loc.all, Normal, "", "2025-06-15"));

      --  1.4
      Assert_Null ("future dob",
         Sayableage.Format_Age (Loc.all, Normal, "2025-07-01", "2025-06-15"));

      --  1.5
      Assert_Eq ("exactly 500 years",
         Sayableage.Format_Age (Loc.all, Normal, "1525-06-15", "2025-06-15"),
         "500 years");

      --  1.6
      Assert_Null ("501 years exceeds max",
         Sayableage.Format_Age (Loc.all, Normal, "1524-06-15", "2025-06-15"));

      --  1.7
      Assert_Null ("1000 years exceeds max",
         Sayableage.Format_Age (Loc.all, Normal, "1025-06-15", "2025-06-15"));
   end Test_Null_Edge_Cases;

   ---------------------------------------------------------------------------
   --  formatAge --  days tier (0-6)
   ---------------------------------------------------------------------------
   procedure Test_Days_Tier is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  2.1
      Assert_Eq ("born today",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-15", "2025-06-15"),
         "Newborn");

      --  2.2
      Assert_Eq ("1 day",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-14", "2025-06-15"),
         "1 day");

      --  2.3
      Assert_Eq ("3 days",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-12", "2025-06-15"),
         "3 days");

      --  2.4
      Assert_Eq ("6 days",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-09", "2025-06-15"),
         "6 days");

      --  2.5
      Assert_Eq ("7 days -> 1 week",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-08", "2025-06-15"),
         "1 week");
   end Test_Days_Tier;

   ---------------------------------------------------------------------------
   --  formatAge --  weeks+days tier
   ---------------------------------------------------------------------------
   procedure Test_Weeks_Days_Tier is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  3.1
      Assert_Eq ("7 days",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-08", "2025-06-15"),
         "1 week");

      --  3.2
      Assert_Eq ("8 days",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-07", "2025-06-15"),
         "1 week, 1 day");

      --  3.3
      Assert_Eq ("9 days",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-06", "2025-06-15"),
         "1 week, 2 days");

      --  3.4
      Assert_Eq ("13 days",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-02", "2025-06-15"),
         "1 week, 6 days");

      --  3.5
      Assert_Eq ("14 days",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-01", "2025-06-15"),
         "2 weeks");

      --  3.6
      Assert_Eq ("15 days",
         Sayableage.Format_Age (Loc.all, Normal, "2025-05-31", "2025-06-15"),
         "2 weeks, 1 day");

      --  3.7
      Assert_Eq ("20 days",
         Sayableage.Format_Age (Loc.all, Normal, "2025-05-26", "2025-06-15"),
         "2 weeks, 6 days");

      --  3.8
      Assert_Eq ("21 days",
         Sayableage.Format_Age (Loc.all, Normal, "2025-05-25", "2025-06-15"),
         "3 weeks");

      --  3.9
      Assert_Eq ("1 cal month still weeks",
         Sayableage.Format_Age (Loc.all, Normal, "2025-05-15", "2025-06-15"),
         "4 weeks, 3 days");

      --  3.10
      Assert_Eq ("2 cal months still weeks",
         Sayableage.Format_Age (Loc.all, Normal, "2025-04-15", "2025-06-15"),
         "8 weeks, 5 days");

      --  3.11
      Assert_Eq ("day before 3mo still weeks",
         Sayableage.Format_Age (Loc.all, Normal, "2025-03-15", "2025-06-14"),
         "13 weeks");

      --  3.12
      Assert_Eq ("on 3mo birthday",
         Sayableage.Format_Age (Loc.all, Normal, "2025-03-15", "2025-06-15"),
         "3 months");
   end Test_Weeks_Days_Tier;

   ---------------------------------------------------------------------------
   --  formatAge --  month boundaries: standard months
   ---------------------------------------------------------------------------
   procedure Test_Month_Boundary_Standard is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  4.1
      Assert_Eq ("Jan1->Apr1=3mo",
         Sayableage.Format_Age (Loc.all, Normal, "2025-01-01", "2025-04-01"),
         "3 months");

      --  4.2
      Assert_Contains ("Jan1->Mar31 still weeks",
         Sayableage.Format_Age (Loc.all, Normal, "2025-01-01", "2025-03-31"),
         "weeks");

      --  4.3
      Assert_Eq ("Jun15->Sep15=3mo",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-15", "2025-09-15"),
         "3 months");

      --  4.4
      Assert_Contains ("Jun15->Sep14 still weeks",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-15", "2025-09-14"),
         "weeks");

      --  4.5
      Assert_Eq ("Jun15->Dec15=6mo",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-15", "2025-12-15"),
         "6 months");
   end Test_Month_Boundary_Standard;

   ---------------------------------------------------------------------------
   --  formatAge --  month boundaries: February non-leap
   ---------------------------------------------------------------------------
   procedure Test_Month_Boundary_Feb_Non_Leap is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  5.1
      Assert_Eq ("Jan31->Feb28 non-leap",
         Sayableage.Format_Age (Loc.all, Normal, "2025-01-31", "2025-02-28"),
         "4 weeks");

      --  5.2
      Assert_Eq ("Jan31->Apr30=3mo",
         Sayableage.Format_Age (Loc.all, Normal, "2025-01-31", "2025-04-30"),
         "3 months");

      --  5.3
      Assert_Contains ("Jan31->Apr29 still weeks",
         Sayableage.Format_Age (Loc.all, Normal, "2025-01-31", "2025-04-29"),
         "weeks");

      --  5.4
      Assert_Eq ("Feb1->May1=3mo",
         Sayableage.Format_Age (Loc.all, Normal, "2025-02-01", "2025-05-01"),
         "3 months");

      --  5.5
      Assert_Contains ("Feb1->Apr30 still weeks",
         Sayableage.Format_Age (Loc.all, Normal, "2025-02-01", "2025-04-30"),
         "weeks");
   end Test_Month_Boundary_Feb_Non_Leap;

   ---------------------------------------------------------------------------
   --  formatAge --  month boundaries: February leap year
   ---------------------------------------------------------------------------
   procedure Test_Month_Boundary_Feb_Leap is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  6.1
      Assert_Eq ("Jan31->Feb29 leap",
         Sayableage.Format_Age (Loc.all, Normal, "2024-01-31", "2024-02-29"),
         "4 weeks, 1 day");

      --  6.2
      Assert_Eq ("Jan31->Feb28 leap",
         Sayableage.Format_Age (Loc.all, Normal, "2024-01-31", "2024-02-28"),
         "4 weeks");

      --  6.3
      Assert_Eq ("Jan31->Apr30 leap=3mo",
         Sayableage.Format_Age (Loc.all, Normal, "2024-01-31", "2024-04-30"),
         "3 months");

      --  6.4
      Assert_Contains ("Jan30->Feb29 leap still weeks",
         Sayableage.Format_Age (Loc.all, Normal, "2024-01-30", "2024-02-29"),
         "weeks");

      --  6.5
      Assert_Contains ("Jan30->Feb28 leap still weeks",
         Sayableage.Format_Age (Loc.all, Normal, "2024-01-30", "2024-02-28"),
         "weeks");
   end Test_Month_Boundary_Feb_Leap;

   ---------------------------------------------------------------------------
   --  formatAge --  month boundaries: 30-day months
   ---------------------------------------------------------------------------
   procedure Test_Month_Boundary_30day is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  7.1
      Assert_Eq ("Mar31->Jun30=3mo",
         Sayableage.Format_Age (Loc.all, Normal, "2025-03-31", "2025-06-30"),
         "3 months");

      --  7.2
      Assert_Contains ("Mar31->Jun29 still weeks",
         Sayableage.Format_Age (Loc.all, Normal, "2025-03-31", "2025-06-29"),
         "weeks");

      --  7.3
      Assert_Eq ("Aug31->Nov30=3mo",
         Sayableage.Format_Age (Loc.all, Normal, "2025-08-31", "2025-11-30"),
         "3 months");

      --  7.4
      Assert_Contains ("Aug31->Nov29 still weeks",
         Sayableage.Format_Age (Loc.all, Normal, "2025-08-31", "2025-11-29"),
         "weeks");
   end Test_Month_Boundary_30day;

   ---------------------------------------------------------------------------
   --  formatAge --  leap year baby (born Feb 29)
   ---------------------------------------------------------------------------
   procedure Test_Leap_Year_Baby is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  8.1
      Assert_Eq ("Feb29->May29=3mo",
         Sayableage.Format_Age (Loc.all, Normal, "2024-02-29", "2024-05-29"),
         "3 months");

      --  8.2
      Assert_Contains ("Feb29->May28 still weeks",
         Sayableage.Format_Age (Loc.all, Normal, "2024-02-29", "2024-05-28"),
         "weeks");

      --  8.3
      Assert_Eq ("Feb29->Feb28 next yr=12mo",
         Sayableage.Format_Age (Loc.all, Normal, "2024-02-29", "2025-02-28"),
         "12 months");

      --  8.4
      Assert_Eq ("Feb29->Mar1 next yr=12mo",
         Sayableage.Format_Age (Loc.all, Normal, "2024-02-29", "2025-03-01"),
         "12 months");
   end Test_Leap_Year_Baby;

   ---------------------------------------------------------------------------
   --  formatAge --  months tier (3-23)
   ---------------------------------------------------------------------------
   procedure Test_Months_Tier is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  9.1
      Assert_Eq ("3 months at transition",
         Sayableage.Format_Age (Loc.all, Normal, "2025-01-15", "2025-04-15"),
         "3 months");

      --  9.2
      Assert_Eq ("6 months",
         Sayableage.Format_Age (Loc.all, Normal, "2025-01-15", "2025-07-15"),
         "6 months");

      --  9.3
      Assert_Eq ("12 months (not 1 year)",
         Sayableage.Format_Age (Loc.all, Normal, "2024-06-15", "2025-06-15"),
         "12 months");

      --  9.4
      Assert_Eq ("23 months upper",
         Sayableage.Format_Age (Loc.all, Normal, "2024-01-15", "2025-12-15"),
         "23 months");

      --  9.5
      Assert_Eq ("day before boundary",
         Sayableage.Format_Age (Loc.all, Normal, "2025-01-15", "2025-07-14"),
         "5 months");

      --  9.6
      Assert_Eq ("cross year boundary",
         Sayableage.Format_Age (Loc.all, Normal, "2024-11-10", "2025-04-10"),
         "5 months");
   end Test_Months_Tier;

   ---------------------------------------------------------------------------
   --  formatAge --  years+months tier (24-35 months)
   ---------------------------------------------------------------------------
   procedure Test_Years_Months_Tier is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  10.1
      Assert_Eq ("2 years at 24mo",
         Sayableage.Format_Age (Loc.all, Normal, "2023-06-15", "2025-06-15"),
         "2 years");

      --  10.2
      Assert_Eq ("2 years 1 month",
         Sayableage.Format_Age (Loc.all, Normal, "2023-06-15", "2025-07-15"),
         "2 years, 1 month");

      --  10.3
      Assert_Eq ("2 years 6 months",
         Sayableage.Format_Age (Loc.all, Normal, "2023-06-15", "2025-12-15"),
         "2 years, 6 months");

      --  10.4
      Assert_Eq ("2 years 11 months",
         Sayableage.Format_Age (Loc.all, Normal, "2023-06-15", "2026-05-15"),
         "2 years, 11 months");

      --  10.5
      Assert_Eq ("day before 24mo",
         Sayableage.Format_Age (Loc.all, Normal, "2023-06-15", "2025-06-14"),
         "23 months");
   end Test_Years_Months_Tier;

   ---------------------------------------------------------------------------
   --  formatAge --  half-year tier (3-6 years)
   ---------------------------------------------------------------------------
   procedure Test_Half_Year_Tier is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  11.1
      Assert_Eq ("3 years exactly",
         Sayableage.Format_Age (Loc.all, Normal, "2022-06-15", "2025-06-15"),
         "3 years");

      --  11.2
      Assert_Eq ("3 years 5 months",
         Sayableage.Format_Age (Loc.all, Normal, "2022-06-15", "2025-11-15"),
         "3 years");

      --  11.3
      Assert_Eq ("3.5 years at 3y6m",
         Sayableage.Format_Age (Loc.all, Normal, "2022-06-15", "2025-12-15"),
         "3" & Half & " years");

      --  11.4
      Assert_Eq ("3.5 years at 3y11m",
         Sayableage.Format_Age (Loc.all, Normal, "2022-06-15", "2026-05-15"),
         "3" & Half & " years");

      --  11.5
      Assert_Eq ("4 years exactly",
         Sayableage.Format_Age (Loc.all, Normal, "2021-06-15", "2025-06-15"),
         "4 years");

      --  11.6
      Assert_Eq ("4.5 years",
         Sayableage.Format_Age (Loc.all, Normal, "2021-06-15", "2025-12-15"),
         "4" & Half & " years");

      --  11.7
      Assert_Eq ("5 years",
         Sayableage.Format_Age (Loc.all, Normal, "2020-06-15", "2025-06-15"),
         "5 years");

      --  11.8
      Assert_Eq ("5.5 years at 5y8m",
         Sayableage.Format_Age (Loc.all, Normal, "2020-06-15", "2026-02-15"),
         "5" & Half & " years");

      --  11.9
      Assert_Eq ("6 years",
         Sayableage.Format_Age (Loc.all, Normal, "2019-06-15", "2025-06-15"),
         "6 years");

      --  11.10
      Assert_Eq ("6.5 years",
         Sayableage.Format_Age (Loc.all, Normal, "2019-06-15", "2025-12-15"),
         "6" & Half & " years");

      --  11.11
      Assert_Eq ("6.5 years at 6y11m",
         Sayableage.Format_Age (Loc.all, Normal, "2019-06-15", "2026-05-15"),
         "6" & Half & " years");

      --  11.12
      Assert_Eq ("day before 3rd bday",
         Sayableage.Format_Age (Loc.all, Normal, "2022-06-15", "2025-06-14"),
         "2 years, 11 months");
   end Test_Half_Year_Tier;

   ---------------------------------------------------------------------------
   --  formatAge --  integer tier (7+ years)
   ---------------------------------------------------------------------------
   procedure Test_Integer_Tier is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  12.1
      Assert_Eq ("7 years exactly",
         Sayableage.Format_Age (Loc.all, Normal, "2018-06-15", "2025-06-15"),
         "7 years");

      --  12.2
      Assert_Eq ("7y3m no half",
         Sayableage.Format_Age (Loc.all, Normal, "2018-03-20", "2025-06-15"),
         "7 years");

      --  12.3
      Assert_Eq ("45 years",
         Sayableage.Format_Age (Loc.all, Normal, "1980-01-01", "2025-06-15"),
         "45 years");
   end Test_Integer_Tier;

   ---------------------------------------------------------------------------
   --  formatAge --  cross-year with Feb
   ---------------------------------------------------------------------------
   procedure Test_Cross_Year_Feb is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  13.1
      Assert_Eq ("Dec31->Mar31=3mo",
         Sayableage.Format_Age (Loc.all, Normal, "2024-12-31", "2025-03-31"),
         "3 months");

      --  13.2
      Assert_Contains ("Dec31->Mar30 still weeks",
         Sayableage.Format_Age (Loc.all, Normal, "2024-12-31", "2025-03-30"),
         "weeks");

      --  13.3
      Assert_Eq ("Nov30->Feb28=3mo",
         Sayableage.Format_Age (Loc.all, Normal, "2024-11-30", "2025-02-28"),
         "3 months");

      --  13.4
      Assert_Contains ("Nov30->Feb27 still weeks",
         Sayableage.Format_Age (Loc.all, Normal, "2024-11-30", "2025-02-27"),
         "weeks");
   end Test_Cross_Year_Feb;

   ---------------------------------------------------------------------------
   --  formatAge --  born-on-31st progression
   ---------------------------------------------------------------------------
   procedure Test_Born_On_31st is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  14.1
      Assert_Eq ("Jan31->Apr30=3mo",
         Sayableage.Format_Age (Loc.all, Normal, "2025-01-31", "2025-04-30"),
         "3 months");

      --  14.2
      Assert_Eq ("Jan31->May31=4mo",
         Sayableage.Format_Age (Loc.all, Normal, "2025-01-31", "2025-05-31"),
         "4 months");

      --  14.3
      Assert_Eq ("Jan31->Jun30=5mo",
         Sayableage.Format_Age (Loc.all, Normal, "2025-01-31", "2025-06-30"),
         "5 months");

      --  14.4
      Assert_Eq ("Jan31->Jul1=5mo",
         Sayableage.Format_Age (Loc.all, Normal, "2025-01-31", "2025-07-01"),
         "5 months");

      --  14.5
      Assert_Eq ("Jan31->Jul31=6mo",
         Sayableage.Format_Age (Loc.all, Normal, "2025-01-31", "2025-07-31"),
         "6 months");
   end Test_Born_On_31st;

   ---------------------------------------------------------------------------
   --  formatStage --  null/edge cases
   ---------------------------------------------------------------------------
   procedure Test_Stage_Null_Edge_Cases is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  16.1, 16.3
      Assert_Null ("stage empty",
         Sayableage.Format_Stage (Loc.all, "", "2025-06-15"));

      --  16.4
      Assert_Null ("stage future",
         Sayableage.Format_Stage (Loc.all, "2025-07-01", "2025-06-15"));

      --  16.5
      Assert_Eq ("stage 500 years",
         Sayableage.Format_Stage (Loc.all, "1525-06-15", "2025-06-15"),
         "Adult");

      --  16.6
      Assert_Null ("stage 501 years",
         Sayableage.Format_Stage (Loc.all, "1524-06-15", "2025-06-15"));
   end Test_Stage_Null_Edge_Cases;

   ---------------------------------------------------------------------------
   --  formatStage --  Newborn (0-1 months)
   ---------------------------------------------------------------------------
   procedure Test_Stage_Newborn is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  17.1
      Assert_Eq ("stage born today",
         Sayableage.Format_Stage (Loc.all, "2025-06-15", "2025-06-15"),
         "Newborn");

      --  17.2
      Assert_Eq ("stage 1 day",
         Sayableage.Format_Stage (Loc.all, "2025-06-14", "2025-06-15"),
         "Newborn");

      --  17.3
      Assert_Eq ("stage 3 weeks",
         Sayableage.Format_Stage (Loc.all, "2025-05-25", "2025-06-15"),
         "Newborn");

      --  17.4
      Assert_Eq ("stage 1 month",
         Sayableage.Format_Stage (Loc.all, "2025-05-15", "2025-06-15"),
         "Newborn");

      --  17.5
      Assert_Eq ("stage 1mo 29d",
         Sayableage.Format_Stage (Loc.all, "2025-04-16", "2025-06-15"),
         "Newborn");

      --  17.6
      Assert_Eq ("stage 2mo -> Infant",
         Sayableage.Format_Stage (Loc.all, "2025-04-15", "2025-06-15"),
         "Infant");
   end Test_Stage_Newborn;

   ---------------------------------------------------------------------------
   --  formatStage --  Infant (2-11 months)
   ---------------------------------------------------------------------------
   procedure Test_Stage_Infant is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  18.1
      Assert_Eq ("stage 2 months",
         Sayableage.Format_Stage (Loc.all, "2025-04-15", "2025-06-15"),
         "Infant");

      --  18.2
      Assert_Eq ("stage 6 months",
         Sayableage.Format_Stage (Loc.all, "2024-12-15", "2025-06-15"),
         "Infant");

      --  18.3
      Assert_Eq ("stage 11 months",
         Sayableage.Format_Stage (Loc.all, "2024-07-15", "2025-06-15"),
         "Infant");

      --  18.4
      Assert_Eq ("stage 12mo -> Toddler",
         Sayableage.Format_Stage (Loc.all, "2024-06-15", "2025-06-15"),
         "Toddler");
   end Test_Stage_Infant;

   ---------------------------------------------------------------------------
   --  formatStage --  Toddler (12-35 months)
   ---------------------------------------------------------------------------
   procedure Test_Stage_Toddler is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  19.1
      Assert_Eq ("stage 12 months",
         Sayableage.Format_Stage (Loc.all, "2024-06-15", "2025-06-15"),
         "Toddler");

      --  19.2
      Assert_Eq ("stage 18 months",
         Sayableage.Format_Stage (Loc.all, "2024-01-15", "2025-07-15"),
         "Toddler");

      --  19.3
      Assert_Eq ("stage 24 months",
         Sayableage.Format_Stage (Loc.all, "2023-06-15", "2025-06-15"),
         "Toddler");

      --  19.4
      Assert_Eq ("stage 35 months",
         Sayableage.Format_Stage (Loc.all, "2023-06-15", "2026-05-15"),
         "Toddler");

      --  19.5
      Assert_Eq ("stage 36mo -> Child",
         Sayableage.Format_Stage (Loc.all, "2022-06-15", "2025-06-15"),
         "Child");
   end Test_Stage_Toddler;

   ---------------------------------------------------------------------------
   --  formatStage --  Child (36-155 months)
   ---------------------------------------------------------------------------
   procedure Test_Stage_Child is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  20.1
      Assert_Eq ("stage 3 years",
         Sayableage.Format_Stage (Loc.all, "2022-06-15", "2025-06-15"),
         "Child");

      --  20.2
      Assert_Eq ("stage 4 years",
         Sayableage.Format_Stage (Loc.all, "2021-06-15", "2025-06-15"),
         "Child");

      --  20.3
      Assert_Eq ("stage 6 years",
         Sayableage.Format_Stage (Loc.all, "2019-06-15", "2025-06-15"),
         "Child");

      --  20.4
      Assert_Eq ("stage 9 years",
         Sayableage.Format_Stage (Loc.all, "2016-06-15", "2025-06-15"),
         "Child");

      --  20.5
      Assert_Eq ("stage 12y11m",
         Sayableage.Format_Stage (Loc.all, "2013-06-15", "2026-05-15"),
         "Child");

      --  20.6
      Assert_Eq ("stage 13y -> Teenager",
         Sayableage.Format_Stage (Loc.all, "2012-06-15", "2025-06-15"),
         "Teenager");
   end Test_Stage_Child;

   ---------------------------------------------------------------------------
   --  formatStage --  Teenager (156-215 months)
   ---------------------------------------------------------------------------
   procedure Test_Stage_Teenager is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  21.1
      Assert_Eq ("stage 13 years",
         Sayableage.Format_Stage (Loc.all, "2012-06-15", "2025-06-15"),
         "Teenager");

      --  21.2
      Assert_Eq ("stage 15 years",
         Sayableage.Format_Stage (Loc.all, "2010-06-15", "2025-06-15"),
         "Teenager");

      --  21.3
      Assert_Eq ("stage 17y11m",
         Sayableage.Format_Stage (Loc.all, "2008-06-15", "2026-05-15"),
         "Teenager");

      --  21.4
      Assert_Eq ("stage 18y -> Adult",
         Sayableage.Format_Stage (Loc.all, "2007-06-15", "2025-06-15"),
         "Adult");
   end Test_Stage_Teenager;

   ---------------------------------------------------------------------------
   --  formatStage --  Adult (216+ months)
   ---------------------------------------------------------------------------
   --  Default asOf (15.1, 15.2, 23.1, 23.2, 23.3): dateOfBirth is derived
   --  from the local current date because the library reads the clock.
   ---------------------------------------------------------------------------

   function Date_Offset (Years_Back : Natural; Days_Back : Natural)
     return String
   is
      use Ada.Calendar;
      Now   : constant Time := Clock;
      Y     : Year_Number;
      M     : Month_Number;
      D     : Day_Number;
      Secs  : Day_Duration;
      Back  : Time;
      function Pad (N : Integer; W : Positive) return String is
         Img : constant String := Integer'Image (N);
         Raw : constant String := Img (Img'First + 1 .. Img'Last);
      begin
         return (1 .. W - Raw'Length => '0') & Raw;
      end Pad;
   begin
      Split (Now, Y, M, D, Secs);
      Y := Y - Years_Back;
      if M = 2 and then D = 29 and then Years_Back > 0 then
         D := 28;
      end if;
      Back := Time_Of (Y, M, D, 43_200.0);
      Back := Back - Duration (Days_Back) * 86_400.0;
      Split (Back, Y, M, D, Secs);
      return Pad (Y, 4) & "-" & Pad (M, 2) & "-" & Pad (D, 2);
   end Date_Offset;

   procedure Test_Default_As_Of is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      Assert_Eq ("default asOf 5 years",
         Sayableage.Format_Age (Loc.all, Normal, Date_Offset (5, 0), ""),
         "5 years");  --  15.1
      Assert_Eq ("default asOf 5 days",
         Sayableage.Format_Age (Loc.all, Normal, Date_Offset (0, 5), ""),
         "5 days");  --  15.2
      Assert_Eq ("default stage newborn",
         Sayableage.Format_Stage (Loc.all, Date_Offset (0, 0), ""),
         "Newborn");  --  23.1
      Assert_Eq ("default stage child",
         Sayableage.Format_Stage (Loc.all, Date_Offset (5, 0), ""),
         "Child");  --  23.2
      Assert_Eq ("default stage adult",
         Sayableage.Format_Stage (Loc.all, Date_Offset (45, 0), ""),
         "Adult");  --  23.3
   end Test_Default_As_Of;

   ---------------------------------------------------------------------------
   procedure Test_Stage_Adult is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  22.1
      Assert_Eq ("stage 18 years",
         Sayableage.Format_Stage (Loc.all, "2007-06-15", "2025-06-15"),
         "Adult");

      --  22.2
      Assert_Eq ("stage 25 years",
         Sayableage.Format_Stage (Loc.all, "2000-06-15", "2025-06-15"),
         "Adult");

      --  22.3
      Assert_Eq ("stage 45 years",
         Sayableage.Format_Stage (Loc.all, "1980-01-01", "2025-06-15"),
         "Adult");

   end Test_Stage_Adult;

   ---------------------------------------------------------------------------
   --  formatStage --  gender support (Spanish)
   ---------------------------------------------------------------------------
   procedure Test_Stage_Gender_Spanish is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("es");

      E_Acute : constant String :=
        Character'Val (16#C3#) & Character'Val (16#A9#);
      N_Tilde : constant String :=
        Character'Val (16#C3#) & Character'Val (16#B1#);
   begin
      --  25.13
      Assert_Eq ("ES stage newborn m",
         Sayableage.Format_Stage (Loc.all, "2025-06-15", "2025-06-15"),
         "Reci" & E_Acute & "n nacido");

      --  25.15
      Assert_Eq ("ES stage toddler m",
         Sayableage.Format_Stage (Loc.all, "2024-06-15", "2025-06-15"),
         "Ni" & N_Tilde & "o peque" & N_Tilde & "o");

      --  25.16
      Assert_Eq ("ES stage child m",
         Sayableage.Format_Stage (Loc.all, "2022-06-15", "2025-06-15"),
         "Ni" & N_Tilde & "o");

      --  25.18
      Assert_Eq ("ES stage adult m",
         Sayableage.Format_Stage (Loc.all, "2007-06-15", "2025-06-15"),
         "Adulto");

      --  Feminine forms
      Assert_Eq ("ES stage newborn f",
         Sayableage.Format_Stage (Loc.all, "2025-06-15", "2025-06-15", "f"),
         "Reci" & E_Acute & "n nacida");

      --  25.14
      Assert_Eq ("ES stage infant f",
         Sayableage.Format_Stage (Loc.all, "2025-01-15", "2025-06-15", "f"),
         "Beb" & E_Acute);

      --  25.17
      Assert_Eq ("ES stage teenager f",
         Sayableage.Format_Stage (Loc.all, "2012-06-15", "2025-06-15", "f"),
         "Adolescente");

      Assert_Eq ("ES stage adult f",
         Sayableage.Format_Stage (Loc.all, "2007-06-15", "2025-06-15", "f"),
         "Adulta");
   end Test_Stage_Gender_Spanish;

   ---------------------------------------------------------------------------
   --  formatStage --  gender-neutral locale
   ---------------------------------------------------------------------------
   procedure Test_Stage_Gender_Neutral is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      Assert_Eq ("EN stage newborn f",
         Sayableage.Format_Stage (Loc.all, "2025-06-15", "2025-06-15", "f"),
         "Newborn");

      Assert_Eq ("EN stage adult f",
         Sayableage.Format_Stage (Loc.all, "2007-06-15", "2025-06-15", "f"),
         "Adult");
   end Test_Stage_Gender_Neutral;

   ---------------------------------------------------------------------------
   --  SayableAge with English locale
   ---------------------------------------------------------------------------
   procedure Test_Sayableage_English is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  24.1
      Assert_Eq ("PT Newborn",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-15", "2025-06-15"),
         "Newborn");

      --  24.2
      Assert_Eq ("PT 3 days",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-12", "2025-06-15"),
         "3 days");

      --  24.3
      Assert_Eq ("PT 1w1d",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-07", "2025-06-15"),
         "1 week, 1 day");

      --  24.4
      Assert_Eq ("PT 6 months",
         Sayableage.Format_Age (Loc.all, Normal, "2025-01-15", "2025-07-15"),
         "6 months");

      --  24.5
      Assert_Eq ("PT 2y1mo",
         Sayableage.Format_Age (Loc.all, Normal, "2023-06-15", "2025-07-15"),
         "2 years, 1 month");

      --  24.6
      Assert_Eq ("PT 3.5y",
         Sayableage.Format_Age (Loc.all, Normal, "2022-06-15", "2025-12-15"),
         "3" & Half & " years");

      --  24.7
      Assert_Eq ("PT 7 years",
         Sayableage.Format_Age (Loc.all, Normal, "2018-06-15", "2025-06-15"),
         "7 years");

      --  24.8
      Assert_Eq ("PT stage Newborn",
         Sayableage.Format_Stage (Loc.all, "2025-06-15", "2025-06-15"),
         "Newborn");

      --  24.9
      Assert_Eq ("PT stage Infant",
         Sayableage.Format_Stage (Loc.all, "2025-01-15", "2025-06-15"),
         "Infant");

      --  24.10
      Assert_Eq ("PT stage Toddler",
         Sayableage.Format_Stage (Loc.all, "2024-06-15", "2025-06-15"),
         "Toddler");

      --  24.11
      Assert_Eq ("PT stage Child",
         Sayableage.Format_Stage (Loc.all, "2022-06-15", "2025-06-15"),
         "Child");

      --  24.12
      Assert_Eq ("PT stage Teenager",
         Sayableage.Format_Stage (Loc.all, "2012-06-15", "2025-06-15"),
         "Teenager");

      --  24.13
      Assert_Eq ("PT stage Adult",
         Sayableage.Format_Stage (Loc.all, "2007-06-15", "2025-06-15"),
         "Adult");

      --  24.14
      Assert_Null ("PT null age",
         Sayableage.Format_Age (Loc.all, Normal, "", "2025-06-15"));

      --  24.15
      Assert_Null ("PT null stage",
         Sayableage.Format_Stage (Loc.all, "", "2025-06-15"));
   end Test_Sayableage_English;

   ---------------------------------------------------------------------------
   --  SayableAge with Spanish locale
   ---------------------------------------------------------------------------
   procedure Test_Sayableage_Spanish is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("es");

      E_Acute : constant String :=
        Character'Val (16#C3#) & Character'Val (16#A9#);
      I_Acute : constant String :=
        Character'Val (16#C3#) & Character'Val (16#AD#);
      N_Tilde : constant String :=
        Character'Val (16#C3#) & Character'Val (16#B1#);
   begin
      --  25.1
      Assert_Eq ("ES justBorn",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-15", "2025-06-15"),
         "Reci" & E_Acute & "n nacido");

      --  25.2
      Assert_Eq ("ES singular day",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-14", "2025-06-15"),
         "1 d" & I_Acute & "a");

      --  25.3
      Assert_Eq ("ES plural days",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-12", "2025-06-15"),
         "3 d" & I_Acute & "as");

      --  25.4
      Assert_Eq ("ES singular week",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-08", "2025-06-15"),
         "1 semana");

      --  25.5
      Assert_Eq ("ES weeks+days",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-07", "2025-06-15"),
         "1 semana, 1 d" & I_Acute & "a");

      --  25.6
      Assert_Eq ("ES plural weeks+days",
         Sayableage.Format_Age (Loc.all, Normal, "2025-05-26", "2025-06-15"),
         "2 semanas, 6 d" & I_Acute & "as");

      --  25.7
      Assert_Eq ("ES months",
         Sayableage.Format_Age (Loc.all, Normal, "2025-01-15", "2025-07-15"),
         "6 meses");

      --  25.8
      Assert_Eq ("ES singular month compound",
         Sayableage.Format_Age (Loc.all, Normal, "2023-06-15", "2025-07-15"),
         "2 a" & N_Tilde & "os, 1 mes");

      --  25.9
      Assert_Eq ("ES years+months",
         Sayableage.Format_Age (Loc.all, Normal, "2023-06-15", "2025-12-15"),
         "2 a" & N_Tilde & "os, 6 meses");

      --  25.10
      Assert_Eq ("ES half marker",
         Sayableage.Format_Age (Loc.all, Normal, "2022-06-15", "2025-12-15"),
         "3 a" & N_Tilde & "os y medio");

      --  25.11
      Assert_Eq ("ES integer years",
         Sayableage.Format_Age (Loc.all, Normal, "2022-06-15", "2025-06-15"),
         "3 a" & N_Tilde & "os");

      --  25.12
      Assert_Eq ("ES 7+ years",
         Sayableage.Format_Age (Loc.all, Normal, "2018-06-15", "2025-06-15"),
         "7 a" & N_Tilde & "os");

      --  25.19
      Assert_Null ("ES null",
         Sayableage.Format_Age (Loc.all, Normal, "", "2025-06-15"));

      --  25.20
      Assert_Null ("ES null stage",
         Sayableage.Format_Stage (Loc.all, "", "2025-06-15"));
   end Test_Sayableage_Spanish;

   ---------------------------------------------------------------------------
   --  Compactness: short
   ---------------------------------------------------------------------------
   procedure Test_Compact_Short is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  26.1
      Assert_Eq ("short days",
         Sayableage.Format_Age (Loc.all, Short, "2025-06-12", "2025-06-15"),
         "3 d");

      --  26.2
      Assert_Eq ("short weeks",
         Sayableage.Format_Age (Loc.all, Short, "2025-06-08", "2025-06-15"),
         "1 wk");

      --  26.3
      Assert_Eq ("short weeks+days",
         Sayableage.Format_Age (Loc.all, Short, "2025-06-07", "2025-06-15"),
         "1 wk, 1 d");

      --  26.4
      Assert_Eq ("short months",
         Sayableage.Format_Age (Loc.all, Short, "2025-01-15", "2025-07-15"),
         "6 mo");

      --  26.5
      Assert_Eq ("short years+months",
         Sayableage.Format_Age (Loc.all, Short, "2023-06-15", "2025-07-15"),
         "2 yr, 1 mo");

      --  26.6
      Assert_Eq ("short half years",
         Sayableage.Format_Age (Loc.all, Short, "2022-06-15", "2025-12-15"),
         "3" & Half & " yr");

      --  26.7
      Assert_Eq ("short integer years",
         Sayableage.Format_Age (Loc.all, Short, "2018-06-15", "2025-06-15"),
         "7 yr");

      --  26.8
      Assert_Eq ("short justBorn",
         Sayableage.Format_Age (Loc.all, Short, "2025-06-15", "2025-06-15"),
         "Newborn");

      --  26.9
      Assert_Eq ("short stages unchanged",
         Sayableage.Format_Stage (Loc.all, "2025-01-15", "2025-06-15"),
         "Infant");
   end Test_Compact_Short;

   ---------------------------------------------------------------------------
   --  Compactness: compact
   ---------------------------------------------------------------------------
   procedure Test_Compact_Compact is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  27.1
      Assert_Eq ("compact days",
         Sayableage.Format_Age (Loc.all, Compact, "2025-06-12", "2025-06-15"),
         "3d");

      --  27.2
      Assert_Eq ("compact weeks",
         Sayableage.Format_Age (Loc.all, Compact, "2025-06-08", "2025-06-15"),
         "1w");

      --  27.3
      Assert_Eq ("compact weeks+days",
         Sayableage.Format_Age (Loc.all, Compact, "2025-06-07", "2025-06-15"),
         "1w1d");

      --  27.4
      Assert_Eq ("compact months",
         Sayableage.Format_Age (Loc.all, Compact, "2025-01-15", "2025-07-15"),
         "6m");

      --  27.5
      Assert_Eq ("compact years+months",
         Sayableage.Format_Age (Loc.all, Compact, "2023-06-15", "2025-07-15"),
         "2y1m");

      --  27.6
      Assert_Eq ("compact half years",
         Sayableage.Format_Age (Loc.all, Compact, "2022-06-15", "2025-12-15"),
         "3" & Half & "y");

      --  27.7
      Assert_Eq ("compact integer years",
         Sayableage.Format_Age (Loc.all, Compact, "2018-06-15", "2025-06-15"),
         "7y");

      --  27.8
      Assert_Eq ("compact justBorn",
         Sayableage.Format_Age (Loc.all, Compact, "2025-06-15", "2025-06-15"),
         "Newborn");
   end Test_Compact_Compact;

   ---------------------------------------------------------------------------
   --  Locale-specific: Hebrew
   ---------------------------------------------------------------------------
   procedure Test_Locale_Hebrew is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("he");
   begin

      --  29.1 justBorn
      Assert_Contains ("he justBorn",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-15", "2025-06-15"),
         Character'Val (16#D7#) & "");

      --  29.2 1 day one
      Assert_Eq ("he 1 day one",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-14", "2025-06-15"),
         Character'Val (16#D7#) & Character'Val (16#99#) & Character'Val (16#D7#) & Character'Val (16#95#) & Character'Val (16#D7#) & Character'Val (16#9D#));

      --  29.3 3 days other
      Assert_Contains ("he 3 days other",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-12", "2025-06-15"),
         "3");

      --  29.4 2 weeks dual
      Assert_True ("he 2 weeks dual not empty",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-01", "2025-06-15")'Length > 0);

      --  29.5 3 weeks other
      Assert_Contains ("he 3 weeks other",
         Sayableage.Format_Age (Loc.all, Normal, "2025-05-25", "2025-06-15"),
         "3");

      --  29.6 6 months
      Assert_Contains ("he 6 months",
         Sayableage.Format_Age (Loc.all, Normal, "2025-01-15", "2025-07-15"),
         "6");

      --  29.7 3 months
      Assert_Contains ("he 3 months",
         Sayableage.Format_Age (Loc.all, Normal, "2025-03-15", "2025-06-15"),
         "3");

      --  29.8 2y dual + 1m one
      Assert_Eq ("he 2y1m dual + one",
         Sayableage.Format_Age (Loc.all, Normal, "2023-06-15", "2025-07-15"),
         Character'Val (16#D7#) & Character'Val (16#A9#) & Character'Val (16#D7#) & Character'Val (16#A0#) & Character'Val (16#D7#) & Character'Val (16#AA#) & Character'Val (16#D7#) & Character'Val (16#99#) & Character'Val (16#D7#) & Character'Val (16#99#) & Character'Val (16#D7#) & Character'Val (16#9D#) & ", " & Character'Val (16#D7#) & Character'Val (16#97#) & Character'Val (16#D7#) & Character'Val (16#95#) & Character'Val (16#D7#) & Character'Val (16#93#) & Character'Val (16#D7#) & Character'Val (16#A9#));

      --  29.9 3.5 years half
      Assert_Contains ("he 3.5y half",
         Sayableage.Format_Age (Loc.all, Normal, "2022-06-15", "2025-12-15"),
         "3");

      --  29.10 7+ years
      Assert_Contains ("he 7y other",
         Sayableage.Format_Age (Loc.all, Normal, "2018-06-15", "2025-06-15"),
         "7");

      --  29.11 stage m newborn
      Assert_True ("he stage m newborn",
         Sayableage.Format_Stage (Loc.all, "2025-06-15", "2025-06-15", "m")'Length > 0);

      --  29.12 stage f newborn
      Assert_True ("he stage f newborn",
         Sayableage.Format_Stage (Loc.all, "2025-06-15", "2025-06-15", "f")'Length > 0);

      --  29.13 stage m adult
      Assert_True ("he stage m adult",
         Sayableage.Format_Stage (Loc.all, "2007-06-15", "2025-06-15", "m")'Length > 0);

      --  29.14 stage f adult
      Assert_True ("he stage f adult",
         Sayableage.Format_Stage (Loc.all, "2007-06-15", "2025-06-15", "f")'Length > 0);
   end Test_Locale_Hebrew;

   ---------------------------------------------------------------------------
   --  Locale-specific: Macedonian
   ---------------------------------------------------------------------------
   procedure Test_Locale_Macedonian is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("mk");
   begin
      --  29.15 justBorn
      Assert_True ("mk justBorn not empty",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-15", "2025-06-15")'Length > 0);

      --  29.16 1 day one
      Assert_Contains ("mk 1 day one",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-14", "2025-06-15"),
         "1");

      --  29.17 3 days other
      Assert_Contains ("mk 3 days other",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-12", "2025-06-15"),
         "3");

      --  29.18 6 months other
      Assert_Contains ("mk 6 months",
         Sayableage.Format_Age (Loc.all, Normal, "2025-01-15", "2025-07-15"),
         "6");

      --  29.19 2y1m
      Assert_Contains ("mk 2y1m",
         Sayableage.Format_Age (Loc.all, Normal, "2023-06-15", "2025-07-15"),
         "2");

      --  29.20 3.5y half
      Assert_Contains ("mk 3.5y half",
         Sayableage.Format_Age (Loc.all, Normal, "2022-06-15", "2025-12-15"),
         "3");

      --  29.21 7+ years
      Assert_Contains ("mk 7y",
         Sayableage.Format_Age (Loc.all, Normal, "2018-06-15", "2025-06-15"),
         "7");
   end Test_Locale_Macedonian;

   ---------------------------------------------------------------------------
   --  Locale-specific: Swahili
   ---------------------------------------------------------------------------
   procedure Test_Locale_Swahili is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("sw");
   begin
      --  29.22 justBorn
      Assert_Eq ("sw justBorn",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-15", "2025-06-15"),
         "Mzaliwa mpya");

      --  29.23 1 day
      Assert_Eq ("sw 1 day",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-14", "2025-06-15"),
         "siku 1");

      --  29.24 3 days
      Assert_Eq ("sw 3 days",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-12", "2025-06-15"),
         "siku 3");

      --  29.25 6 months
      Assert_Eq ("sw 6 months",
         Sayableage.Format_Age (Loc.all, Normal, "2025-01-15", "2025-07-15"),
         "miezi 6");

      --  29.26 2y 1m
      Assert_Eq ("sw 2y 1m",
         Sayableage.Format_Age (Loc.all, Normal, "2023-06-15", "2025-07-15"),
         "miaka 2, mwezi 1");

      --  29.27 3.5y half
      Assert_Eq ("sw 3.5y half",
         Sayableage.Format_Age (Loc.all, Normal, "2022-06-15", "2025-12-15"),
         "miaka 3 na nusu");
   end Test_Locale_Swahili;

   ---------------------------------------------------------------------------
   --  Locale-specific: Indonesian
   ---------------------------------------------------------------------------
   procedure Test_Locale_Indonesian is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("id");
   begin
      --  29.28 justBorn
      Assert_Eq ("id justBorn",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-15", "2025-06-15"),
         "Baru lahir");

      --  29.29 1 day
      Assert_Eq ("id 1 day",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-14", "2025-06-15"),
         "1 hari");

      --  29.30 3 days
      Assert_Eq ("id 3 days",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-12", "2025-06-15"),
         "3 hari");

      --  29.31 6 months
      Assert_Eq ("id 6 months",
         Sayableage.Format_Age (Loc.all, Normal, "2025-01-15", "2025-07-15"),
         "6 bulan");

      --  29.32 3.5y half
      Assert_Eq ("id 3.5y half",
         Sayableage.Format_Age (Loc.all, Normal, "2022-06-15", "2025-12-15"),
         "3 setengah tahun");

      --  29.33 7y
      Assert_Eq ("id 7y",
         Sayableage.Format_Age (Loc.all, Normal, "2018-06-15", "2025-06-15"),
         "7 tahun");
   end Test_Locale_Indonesian;

   ---------------------------------------------------------------------------
   --  Locale-specific: Amharic
   ---------------------------------------------------------------------------
   procedure Test_Locale_Amharic is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("am");
   begin
      --  29.34 justBorn
      Assert_True ("am justBorn not empty",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-15", "2025-06-15")'Length > 0);

      --  29.35 1 day
      Assert_Contains ("am 1 day",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-14", "2025-06-15"),
         "1");

      --  29.36 3 days
      Assert_Contains ("am 3 days",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-12", "2025-06-15"),
         "3");

      --  29.37 1w1d ethiopic delimiter
      Assert_Contains ("am 1w1d",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-07", "2025-06-15"),
         "1");

      --  29.38 6 months
      Assert_Contains ("am 6 months",
         Sayableage.Format_Age (Loc.all, Normal, "2025-01-15", "2025-07-15"),
         "6");

      --  29.39 3.5y half
      Assert_Contains ("am 3.5y half",
         Sayableage.Format_Age (Loc.all, Normal, "2022-06-15", "2025-12-15"),
         "3");
   end Test_Locale_Amharic;

   ---------------------------------------------------------------------------
   --  Locale lookup by code string
   ---------------------------------------------------------------------------
   procedure Test_Locale_Lookup is
      Loc : Locale_Access;
   begin
      --  30.1
      Loc := Sayableage_Locales.Get_Locale ("en");
      Assert_True ("get(en) not null", Loc /= null);
      Assert_Eq ("get(en) code",
         Ada.Strings.Unbounded.To_String (Loc.all.Code), "en");

      --  30.2
      Loc := Sayableage_Locales.Get_Locale ("fr");
      Assert_True ("get(fr) not null", Loc /= null);
      Assert_Eq ("get(fr) code",
         Ada.Strings.Unbounded.To_String (Loc.all.Code), "fr");

      --  30.3
      Loc := Sayableage_Locales.Get_Locale ("xx");
      Assert_True ("get(xx) null", Loc = null);

      --  30.4
      Loc := Sayableage_Locales.Get_Locale ("");
      Assert_True ("get empty null", Loc = null);

      --  30.5
      Loc := Sayableage_Locales.Get_Locale ("EN");
      Assert_True ("get(EN) null", Loc = null);
   end Test_Locale_Lookup;

   ---------------------------------------------------------------------------
   --  Weeks and days across month ends
   ---------------------------------------------------------------------------
   procedure Test_Weeks_Days_Across_Month_Ends is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  31.1
      Assert_Eq ("88 days across February",
         Sayableage.Format_Age (Loc.all, Normal, "2016-12-31", "2017-03-29"),
         "12 weeks, 4 days");

      --  31.2
      Assert_Eq ("90 days into a leap year",
         Sayableage.Format_Age (Loc.all, Normal, "1991-11-27", "1992-02-25"),
         "12 weeks, 6 days");

      --  31.3
      Assert_Eq ("33 days across a year end",
         Sayableage.Format_Age (Loc.all, Normal, "2020-11-30", "2021-01-02"),
         "4 weeks, 5 days");

      --  31.4
      Assert_Eq ("compact 88 days",
         Sayableage.Format_Age (Loc.all, Compact, "2016-12-31", "2017-03-29"),
         "12w4d");
   end Test_Weeks_Days_Across_Month_Ends;

   ---------------------------------------------------------------------------
   --  Half years take their plural form from whole years
   ---------------------------------------------------------------------------
   procedure Test_Half_Year_Plural is
      Pl  : constant Locale_Access := Sayableage_Locales.Get_Locale ("pl");
      Shi : constant Locale_Access := Sayableage_Locales.Get_Locale ("shi");
      Pol : constant String := "p" & Character'Val (16#C3#)
        & Character'Val (16#B3#) & Character'Val (16#C5#)
        & Character'Val (16#82#);
   begin
      --  32.1
      Assert_Eq ("pl 3.5 years few",
         Sayableage.Format_Age (Pl.all, Normal, "2021-06-15", "2025-01-15"),
         "3 i " & Pol & " lata");

      --  32.2
      Assert_Eq ("pl short 5.5 years many",
         Sayableage.Format_Age (Pl.all, Short, "2020-06-15", "2025-12-15"),
         "5 i " & Pol & " lat");

      --  32.3
      Assert_Eq ("shi 6 years few",
         Sayableage.Format_Age (Shi.all, Normal, "2005-06-08", "2012-06-07"),
         "6 " &
         Character'Val (16#E2#) &
         Character'Val (16#B5#) &
         Character'Val (16#89#) &
         Character'Val (16#E2#) &
         Character'Val (16#B5#) &
         Character'Val (16#99#) &
         Character'Val (16#E2#) &
         Character'Val (16#B4#) &
         Character'Val (16#B3#) &
         Character'Val (16#E2#) &
         Character'Val (16#B4#) &
         Character'Val (16#B3#) &
         Character'Val (16#E2#) &
         Character'Val (16#B5#) &
         Character'Val (16#AF#) &
         Character'Val (16#E2#) &
         Character'Val (16#B4#) &
         Character'Val (16#B0#) &
         Character'Val (16#E2#) &
         Character'Val (16#B5#) &
         Character'Val (16#99#) &
         Character'Val (16#E2#) &
         Character'Val (16#B5#) &
         Character'Val (16#8F#) &
         " " &
         Character'Val (16#E2#) &
         Character'Val (16#B4#) &
         Character'Val (16#B7#) &
         " " &
         Character'Val (16#E2#) &
         Character'Val (16#B5#) &
         Character'Val (16#93#) &
         Character'Val (16#E2#) &
         Character'Val (16#B5#) &
         Character'Val (16#A3#) &
         Character'Val (16#E2#) &
         Character'Val (16#B4#) &
         Character'Val (16#B3#) &
         Character'Val (16#E2#) &
         Character'Val (16#B5#) &
         Character'Val (16#8F#));
   end Test_Half_Year_Plural;

   ---------------------------------------------------------------------------
   --  Input validation
   ---------------------------------------------------------------------------
   procedure Test_Input_Validation is
      Loc : constant Locale_Access := Sayableage_Locales.Get_Locale ("en");
   begin
      --  33.1
      Assert_Null ("February 30",
         Sayableage.Format_Age (Loc.all, Normal, "2025-02-30", "2032-06-25"));

      --  33.2
      Assert_Null ("month 13",
         Sayableage.Format_Age (Loc.all, Normal, "2025-13-01", "2027-01-31"));

      --  33.3
      Assert_Null ("February 29 non-leap",
         Sayableage.Format_Age (Loc.all, Normal, "2023-02-29", "2025-03-01"));

      --  33.4
      Assert_Null ("day 00",
         Sayableage.Format_Age (Loc.all, Normal, "2025-06-00", "2027-02-25"));

      --  33.5
      Assert_Null ("unpadded",
         Sayableage.Format_Age (Loc.all, Normal, "2025-6-1", "2027-02-25"));

      --  33.6
      Assert_Null ("surrounding whitespace",
         Sayableage.Format_Age (Loc.all, Normal, " 2025-06-01", "2027-02-25"));

      --  33.7
      Assert_Null ("datetime is not a date",
         Sayableage.Format_Age
           (Loc.all, Normal, "2025-06-15T10:00:00", "2027-02-25"));

      --  33.8
      Assert_Null ("invalid asOf",
         Sayableage.Format_Age (Loc.all, Normal, "2020-01-01", "2025-04-31"));

      --  33.9
      Assert_Null ("formatStage validates",
         Sayableage.Format_Stage (Loc.all, "2025-02-30", "2027-09-05"));

      --  33.10
      Assert_Eq ("February 29 leap year",
         Sayableage.Format_Age (Loc.all, Normal, "2024-02-29", "2026-03-01"),
         "2 years");
   end Test_Input_Validation;

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
   Test_Default_As_Of;
   Test_Stage_Gender_Spanish;
   Test_Stage_Gender_Neutral;
   Test_Sayableage_English;
   Test_Sayableage_Spanish;
   Test_Compact_Short;
   Test_Compact_Compact;
   Test_Locale_Hebrew;
   Test_Locale_Macedonian;
   Test_Locale_Swahili;
   Test_Locale_Indonesian;
   Test_Locale_Amharic;
   Test_Locale_Lookup;
   Test_Weeks_Days_Across_Month_Ends;
   Test_Half_Year_Plural;
   Test_Input_Validation;

   New_Line;
   Put_Line ("=== Results ===");
   Put_Line ("Passed:" & Natural'Image (Tests_Passed));
   Put_Line ("Failed:" & Natural'Image (Tests_Failed));
   Put_Line ("Total: " & Natural'Image (Tests_Passed + Tests_Failed));

   if Tests_Failed > 0 then
      raise Program_Error with "Tests failed";
   end if;
end Test_Format_Age;
