module ParentTimeLib.Tests.FormatAgeTests

open System
open Xunit
open ParentTimeLib.Types
open ParentTimeLib.Formatter
open ParentTimeLib.Locales

let private formatAge dob asOf =
    formatAgeDefault (Some dob) (Some asOf)

let private formatStage dob asOf =
    formatStageDefault (Some dob) (Some asOf) None

let private formatStageGender dob asOf gender =
    formatStageDefault (Some dob) (Some asOf) (Some gender)

let private assertWeeksPattern (result: string option) =
    Assert.NotNull(result)
    Assert.Contains("week", result.Value)

// ================================================================
// formatAge -- null/edge cases
// ================================================================

// 1.1
[<Fact>]
let ``null dob returns None`` () =
    Assert.Equal(None, formatAgeDefault None (Some "2025-06-15"))

// 1.3
[<Fact>]
let ``empty string returns None`` () =
    Assert.Equal(None, formatAge "" "2025-06-15")

// 1.4
[<Fact>]
let ``future dob returns None`` () =
    Assert.Equal(None, formatAge "2025-07-01" "2025-06-15")

// 1.5
[<Fact>]
let ``exactly 500 years is allowed`` () =
    Assert.Equal(Some "500 years", formatAge "1525-06-15" "2025-06-15")

// 1.6
[<Fact>]
let ``501 years exceeds max age`` () =
    Assert.Equal(None, formatAge "1524-06-15" "2025-06-15")

// 1.7
[<Fact>]
let ``1000 years exceeds max age`` () =
    Assert.Equal(None, formatAge "1025-06-15" "2025-06-15")

// ================================================================
// formatAge -- days tier (0-6)
// ================================================================

// 2.1
[<Fact>]
let ``born today`` () =
    Assert.Equal(Some "Newborn", formatAge "2025-06-15" "2025-06-15")

// 2.2
[<Fact>]
let ``one day ago`` () =
    Assert.Equal(Some "1 day", formatAge "2025-06-14" "2025-06-15")

// 2.3
[<Fact>]
let ``three days`` () =
    Assert.Equal(Some "3 days", formatAge "2025-06-12" "2025-06-15")

// 2.4
[<Fact>]
let ``six days`` () =
    Assert.Equal(Some "6 days", formatAge "2025-06-09" "2025-06-15")

// 2.5
[<Fact>]
let ``seven days becomes one week`` () =
    Assert.Equal(Some "1 week", formatAge "2025-06-08" "2025-06-15")

// ================================================================
// formatAge -- weeks+days tier (7 days to <3 months)
// ================================================================

// 3.1
[<Fact>]
let ``exactly 7 days is 1 week`` () =
    Assert.Equal(Some "1 week", formatAge "2025-06-08" "2025-06-15")

// 3.2
[<Fact>]
let ``8 days is 1 week 1 day`` () =
    Assert.Equal(Some "1 week, 1 day", formatAge "2025-06-07" "2025-06-15")

// 3.3
[<Fact>]
let ``9 days is 1 week 2 days`` () =
    Assert.Equal(Some "1 week, 2 days", formatAge "2025-06-06" "2025-06-15")

// 3.4
[<Fact>]
let ``13 days is 1 week 6 days`` () =
    Assert.Equal(Some "1 week, 6 days", formatAge "2025-06-02" "2025-06-15")

// 3.5
[<Fact>]
let ``14 days is 2 weeks`` () =
    Assert.Equal(Some "2 weeks", formatAge "2025-06-01" "2025-06-15")

// 3.6
[<Fact>]
let ``15 days is 2 weeks 1 day`` () =
    Assert.Equal(Some "2 weeks, 1 day", formatAge "2025-05-31" "2025-06-15")

// 3.7
[<Fact>]
let ``20 days is 2 weeks 6 days`` () =
    Assert.Equal(Some "2 weeks, 6 days", formatAge "2025-05-26" "2025-06-15")

// 3.8
[<Fact>]
let ``21 days is 3 weeks`` () =
    Assert.Equal(Some "3 weeks", formatAge "2025-05-25" "2025-06-15")

// 3.9
[<Fact>]
let ``1 calendar month still weeks`` () =
    Assert.Equal(Some "4 weeks, 3 days", formatAge "2025-05-15" "2025-06-15")

// 3.10
[<Fact>]
let ``2 calendar months still weeks`` () =
    Assert.Equal(Some "8 weeks, 5 days", formatAge "2025-04-15" "2025-06-15")

// 3.11
[<Fact>]
let ``day before 3mo birthday still weeks`` () =
    Assert.Equal(Some "13 weeks", formatAge "2025-03-15" "2025-06-14")

// 3.12
[<Fact>]
let ``on 3mo birthday switches to months`` () =
    Assert.Equal(Some "3 months", formatAge "2025-03-15" "2025-06-15")

// ================================================================
// formatAge -- month boundaries: standard months
// ================================================================

// 4.1
[<Fact>]
let ``Jan1 to Apr1 is 3 months`` () =
    Assert.Equal(Some "3 months", formatAge "2025-01-01" "2025-04-01")

// 4.2
[<Fact>]
let ``Jan1 to Mar31 still weeks`` () =
    assertWeeksPattern (formatAge "2025-01-01" "2025-03-31")

// 4.3
[<Fact>]
let ``Jun15 to Sep15 is 3 months`` () =
    Assert.Equal(Some "3 months", formatAge "2025-06-15" "2025-09-15")

// 4.4
[<Fact>]
let ``Jun15 to Sep14 still weeks`` () =
    assertWeeksPattern (formatAge "2025-06-15" "2025-09-14")

// 4.5
[<Fact>]
let ``Jun15 to Dec15 is 6 months`` () =
    Assert.Equal(Some "6 months", formatAge "2025-06-15" "2025-12-15")

// ================================================================
// formatAge -- month boundaries: February non-leap year
// ================================================================

// 5.1
[<Fact>]
let ``Jan31 to Feb28 is 4 weeks non-leap`` () =
    Assert.Equal(Some "4 weeks", formatAge "2025-01-31" "2025-02-28")

// 5.2
[<Fact>]
let ``Jan31 to Apr30 is 3 months non-leap`` () =
    Assert.Equal(Some "3 months", formatAge "2025-01-31" "2025-04-30")

// 5.3
[<Fact>]
let ``Jan31 to Apr29 still weeks non-leap`` () =
    assertWeeksPattern (formatAge "2025-01-31" "2025-04-29")

// 5.4
[<Fact>]
let ``Feb1 to May1 is 3 months`` () =
    Assert.Equal(Some "3 months", formatAge "2025-02-01" "2025-05-01")

// 5.5
[<Fact>]
let ``Feb1 to Apr30 still weeks`` () =
    assertWeeksPattern (formatAge "2025-02-01" "2025-04-30")

// ================================================================
// formatAge -- month boundaries: February leap year
// ================================================================

// 6.1
[<Fact>]
let ``Jan31 to Feb29 leap year`` () =
    Assert.Equal(Some "4 weeks, 1 day", formatAge "2024-01-31" "2024-02-29")

// 6.2
[<Fact>]
let ``Jan31 to Feb28 leap year`` () =
    Assert.Equal(Some "4 weeks", formatAge "2024-01-31" "2024-02-28")

// 6.3
[<Fact>]
let ``Jan31 to Apr30 leap year`` () =
    Assert.Equal(Some "3 months", formatAge "2024-01-31" "2024-04-30")

// 6.4
[<Fact>]
let ``Jan30 to Feb29 leap year still weeks`` () =
    assertWeeksPattern (formatAge "2024-01-30" "2024-02-29")

// 6.5
[<Fact>]
let ``Jan30 to Feb28 leap year still weeks`` () =
    assertWeeksPattern (formatAge "2024-01-30" "2024-02-28")

// ================================================================
// formatAge -- month boundaries: 30-day months
// ================================================================

// 7.1
[<Fact>]
let ``Mar31 to Jun30 is 3 months`` () =
    Assert.Equal(Some "3 months", formatAge "2025-03-31" "2025-06-30")

// 7.2
[<Fact>]
let ``Mar31 to Jun29 still weeks`` () =
    assertWeeksPattern (formatAge "2025-03-31" "2025-06-29")

// 7.3
[<Fact>]
let ``Aug31 to Nov30 is 3 months`` () =
    Assert.Equal(Some "3 months", formatAge "2025-08-31" "2025-11-30")

// 7.4
[<Fact>]
let ``Aug31 to Nov29 still weeks`` () =
    assertWeeksPattern (formatAge "2025-08-31" "2025-11-29")

// ================================================================
// formatAge -- month boundaries: leap year baby (born Feb 29)
// ================================================================

// 8.1
[<Fact>]
let ``Feb29 to May29 is 3 months`` () =
    Assert.Equal(Some "3 months", formatAge "2024-02-29" "2024-05-29")

// 8.2
[<Fact>]
let ``Feb29 to May28 still weeks`` () =
    assertWeeksPattern (formatAge "2024-02-29" "2024-05-28")

// 8.3
[<Fact>]
let ``Feb29 birthday to Feb28 next year`` () =
    Assert.Equal(Some "12 months", formatAge "2024-02-29" "2025-02-28")

// 8.4
[<Fact>]
let ``Feb29 birthday to Mar1 next year`` () =
    Assert.Equal(Some "12 months", formatAge "2024-02-29" "2025-03-01")

// ================================================================
// formatAge -- months tier (3-23 months)
// ================================================================

// 9.1
[<Fact>]
let ``transition to 3 months`` () =
    Assert.Equal(Some "3 months", formatAge "2025-01-15" "2025-04-15")

// 9.2
[<Fact>]
let ``6 months`` () =
    Assert.Equal(Some "6 months", formatAge "2025-01-15" "2025-07-15")

// 9.3
[<Fact>]
let ``12 months not 1 year`` () =
    Assert.Equal(Some "12 months", formatAge "2024-06-15" "2025-06-15")

// 9.4
[<Fact>]
let ``23 months upper boundary`` () =
    Assert.Equal(Some "23 months", formatAge "2024-01-15" "2025-12-15")

// 9.5
[<Fact>]
let ``day before 6 months`` () =
    Assert.Equal(Some "5 months", formatAge "2025-01-15" "2025-07-14")

// 9.6
[<Fact>]
let ``5 months cross year`` () =
    Assert.Equal(Some "5 months", formatAge "2024-11-10" "2025-04-10")

// ================================================================
// formatAge -- years+months tier (24-35 months)
// ================================================================

// 10.1
[<Fact>]
let ``exactly 24 months is 2 years`` () =
    Assert.Equal(Some "2 years", formatAge "2023-06-15" "2025-06-15")

// 10.2
[<Fact>]
let ``2 years 1 month`` () =
    Assert.Equal(Some "2 years, 1 month", formatAge "2023-06-15" "2025-07-15")

// 10.3
[<Fact>]
let ``2 years 6 months`` () =
    Assert.Equal(Some "2 years, 6 months", formatAge "2023-06-15" "2025-12-15")

// 10.4
[<Fact>]
let ``2 years 11 months upper`` () =
    Assert.Equal(Some "2 years, 11 months", formatAge "2023-06-15" "2026-05-15")

// 10.5
[<Fact>]
let ``day before 24 months still 23 months`` () =
    Assert.Equal(Some "23 months", formatAge "2023-06-15" "2025-06-14")

// ================================================================
// formatAge -- half-year tier (3-6 years)
// ================================================================

// 11.1
[<Fact>]
let ``exactly 3 years`` () =
    Assert.Equal(Some "3 years", formatAge "2022-06-15" "2025-06-15")

// 11.2
[<Fact>]
let ``3 years 5 months no half`` () =
    Assert.Equal(Some "3 years", formatAge "2022-06-15" "2025-11-15")

// 11.3
[<Fact>]
let ``3 years 6 months gets half`` () =
    Assert.Equal(Some "3\u00BD years", formatAge "2022-06-15" "2025-12-15")

// 11.4
[<Fact>]
let ``3 years 11 months gets half`` () =
    Assert.Equal(Some "3\u00BD years", formatAge "2022-06-15" "2026-05-15")

// 11.5
[<Fact>]
let ``exactly 4 years`` () =
    Assert.Equal(Some "4 years", formatAge "2021-06-15" "2025-06-15")

// 11.6
[<Fact>]
let ``4.5 years`` () =
    Assert.Equal(Some "4\u00BD years", formatAge "2021-06-15" "2025-12-15")

// 11.7
[<Fact>]
let ``exactly 5 years`` () =
    Assert.Equal(Some "5 years", formatAge "2020-06-15" "2025-06-15")

// 11.8
[<Fact>]
let ``5 years 8 months gets half`` () =
    Assert.Equal(Some "5\u00BD years", formatAge "2020-06-15" "2026-02-15")

// 11.9
[<Fact>]
let ``exactly 6 years`` () =
    Assert.Equal(Some "6 years", formatAge "2019-06-15" "2025-06-15")

// 11.10
[<Fact>]
let ``6 years 6 months gets half`` () =
    Assert.Equal(Some "6\u00BD years", formatAge "2019-06-15" "2025-12-15")

// 11.11
[<Fact>]
let ``6 years 11 months gets half`` () =
    Assert.Equal(Some "6\u00BD years", formatAge "2019-06-15" "2026-05-15")

// 11.12
[<Fact>]
let ``day before 3rd birthday`` () =
    Assert.Equal(Some "2 years, 11 months", formatAge "2022-06-15" "2025-06-14")

// ================================================================
// formatAge -- integer tier (7+ years)
// ================================================================

// 12.1
[<Fact>]
let ``exactly 7 years`` () =
    Assert.Equal(Some "7 years", formatAge "2018-06-15" "2025-06-15")

// 12.2
[<Fact>]
let ``7 years 3 months no half`` () =
    Assert.Equal(Some "7 years", formatAge "2018-03-20" "2025-06-15")

// 12.3
[<Fact>]
let ``45 years adult`` () =
    Assert.Equal(Some "45 years", formatAge "1980-01-01" "2025-06-15")

// ================================================================
// formatAge -- cross-year transitions with February
// ================================================================

// 13.1
[<Fact>]
let ``Dec31 to Mar31 cross year`` () =
    Assert.Equal(Some "3 months", formatAge "2024-12-31" "2025-03-31")

// 13.2
[<Fact>]
let ``Dec31 to Mar30 still weeks`` () =
    assertWeeksPattern (formatAge "2024-12-31" "2025-03-30")

// 13.3
[<Fact>]
let ``Nov30 to Feb28 cross year`` () =
    Assert.Equal(Some "3 months", formatAge "2024-11-30" "2025-02-28")

// 13.4
[<Fact>]
let ``Nov30 to Feb27 still weeks`` () =
    assertWeeksPattern (formatAge "2024-11-30" "2025-02-27")

// ================================================================
// formatAge -- born-on-31st progression
// ================================================================

// 14.1
[<Fact>]
let ``Jan31 to Apr30 is 3 months`` () =
    Assert.Equal(Some "3 months", formatAge "2025-01-31" "2025-04-30")

// 14.2
[<Fact>]
let ``Jan31 to May31 is 4 months`` () =
    Assert.Equal(Some "4 months", formatAge "2025-01-31" "2025-05-31")

// 14.3
[<Fact>]
let ``Jan31 to Jun30 is 5 months`` () =
    Assert.Equal(Some "5 months", formatAge "2025-01-31" "2025-06-30")

// 14.4
[<Fact>]
let ``Jan31 to Jul1 still 5 months`` () =
    Assert.Equal(Some "5 months", formatAge "2025-01-31" "2025-07-01")

// 14.5
[<Fact>]
let ``Jan31 to Jul31 is 6 months`` () =
    Assert.Equal(Some "6 months", formatAge "2025-01-31" "2025-07-31")

// ================================================================
// formatAge -- default asOf (current date)
// ================================================================

// 15.1
[<Fact>]
let ``default asOf formatAge`` () =
    timeNow <- fun () -> DateTime(2025, 6, 15)
    try
        let pt = ParentTimeFormatter(EN)
        Assert.Equal(Some "5 years", pt.FormatAge(Some "2020-01-01"))
    finally
        timeNow <- fun () -> DateTime.Today

// 15.2
[<Fact>]
let ``default asOf formatAge 5 days`` () =
    timeNow <- fun () -> DateTime(2025, 6, 15)
    try
        let pt = ParentTimeFormatter(EN)
        Assert.Equal(Some "5 days", pt.FormatAge(Some "2025-06-10"))
    finally
        timeNow <- fun () -> DateTime.Today

// ================================================================
// formatStage -- null/edge cases
// ================================================================

// 16.1
[<Fact>]
let ``formatStage null dob returns None`` () =
    Assert.Equal(None, formatStageDefault None (Some "2025-06-15") None)

// 16.3
[<Fact>]
let ``formatStage empty string returns None`` () =
    Assert.Equal(None, formatStage "" "2025-06-15")

// 16.4
[<Fact>]
let ``formatStage future dob returns None`` () =
    Assert.Equal(None, formatStage "2025-07-01" "2025-06-15")

// 16.5
[<Fact>]
let ``formatStage exactly 500 years is Adult`` () =
    Assert.Equal(Some "Adult", formatStage "1525-06-15" "2025-06-15")

// 16.6
[<Fact>]
let ``formatStage 501 years returns None`` () =
    Assert.Equal(None, formatStage "1524-06-15" "2025-06-15")

// ================================================================
// formatStage -- Newborn (0-1 months)
// ================================================================

// 17.1
[<Fact>]
let ``formatStage born today is Newborn`` () =
    Assert.Equal(Some "Newborn", formatStage "2025-06-15" "2025-06-15")

// 17.2
[<Fact>]
let ``formatStage 1 day is Newborn`` () =
    Assert.Equal(Some "Newborn", formatStage "2025-06-14" "2025-06-15")

// 17.3
[<Fact>]
let ``formatStage 3 weeks is Newborn`` () =
    Assert.Equal(Some "Newborn", formatStage "2025-05-25" "2025-06-15")

// 17.4
[<Fact>]
let ``formatStage 1 month is Newborn`` () =
    Assert.Equal(Some "Newborn", formatStage "2025-05-15" "2025-06-15")

// 17.5
[<Fact>]
let ``formatStage 1 month 29 days is Newborn`` () =
    Assert.Equal(Some "Newborn", formatStage "2025-04-16" "2025-06-15")

// 17.6
[<Fact>]
let ``formatStage exactly 2 months is Infant`` () =
    Assert.Equal(Some "Infant", formatStage "2025-04-15" "2025-06-15")

// ================================================================
// formatStage -- Infant (2-11 months)
// ================================================================

// 18.1
[<Fact>]
let ``formatStage 2 months is Infant`` () =
    Assert.Equal(Some "Infant", formatStage "2025-04-15" "2025-06-15")

// 18.2
[<Fact>]
let ``formatStage 6 months is Infant`` () =
    Assert.Equal(Some "Infant", formatStage "2024-12-15" "2025-06-15")

// 18.3
[<Fact>]
let ``formatStage 11 months is Infant`` () =
    Assert.Equal(Some "Infant", formatStage "2024-07-15" "2025-06-15")

// 18.4
[<Fact>]
let ``formatStage 12 months is Toddler`` () =
    Assert.Equal(Some "Toddler", formatStage "2024-06-15" "2025-06-15")

// ================================================================
// formatStage -- Toddler (12-35 months)
// ================================================================

// 19.1
[<Fact>]
let ``formatStage 12 months is Toddler transition`` () =
    Assert.Equal(Some "Toddler", formatStage "2024-06-15" "2025-06-15")

// 19.2
[<Fact>]
let ``formatStage 18 months is Toddler`` () =
    Assert.Equal(Some "Toddler", formatStage "2024-01-15" "2025-07-15")

// 19.3
[<Fact>]
let ``formatStage 24 months is Toddler`` () =
    Assert.Equal(Some "Toddler", formatStage "2023-06-15" "2025-06-15")

// 19.4
[<Fact>]
let ``formatStage 35 months is Toddler`` () =
    Assert.Equal(Some "Toddler", formatStage "2023-06-15" "2026-05-15")

// 19.5
[<Fact>]
let ``formatStage 36 months is Child`` () =
    Assert.Equal(Some "Child", formatStage "2022-06-15" "2025-06-15")

// ================================================================
// formatStage -- Child (36-155 months)
// ================================================================

// 20.1
[<Fact>]
let ``formatStage 3 years is Child`` () =
    Assert.Equal(Some "Child", formatStage "2022-06-15" "2025-06-15")

// 20.2
[<Fact>]
let ``formatStage 4 years is Child`` () =
    Assert.Equal(Some "Child", formatStage "2021-06-15" "2025-06-15")

// 20.3
[<Fact>]
let ``formatStage 6 years is Child`` () =
    Assert.Equal(Some "Child", formatStage "2019-06-15" "2025-06-15")

// 20.4
[<Fact>]
let ``formatStage 9 years is Child`` () =
    Assert.Equal(Some "Child", formatStage "2016-06-15" "2025-06-15")

// 20.5
[<Fact>]
let ``formatStage 12 years 11 months is Child`` () =
    Assert.Equal(Some "Child", formatStage "2013-06-15" "2026-05-15")

// 20.6
[<Fact>]
let ``formatStage 13 years is Teenager`` () =
    Assert.Equal(Some "Teenager", formatStage "2012-06-15" "2025-06-15")

// ================================================================
// formatStage -- Teenager (156-215 months)
// ================================================================

// 21.1
[<Fact>]
let ``formatStage 13 years is Teenager transition`` () =
    Assert.Equal(Some "Teenager", formatStage "2012-06-15" "2025-06-15")

// 21.2
[<Fact>]
let ``formatStage 15 years is Teenager`` () =
    Assert.Equal(Some "Teenager", formatStage "2010-06-15" "2025-06-15")

// 21.3
[<Fact>]
let ``formatStage 17 years 11 months is Teenager`` () =
    Assert.Equal(Some "Teenager", formatStage "2008-06-15" "2026-05-15")

// 21.4
[<Fact>]
let ``formatStage 18 years is Adult`` () =
    Assert.Equal(Some "Adult", formatStage "2007-06-15" "2025-06-15")

// ================================================================
// formatStage -- Adult (216+ months)
// ================================================================

// 22.1
[<Fact>]
let ``formatStage 18 years is Adult transition`` () =
    Assert.Equal(Some "Adult", formatStage "2007-06-15" "2025-06-15")

// 22.2
[<Fact>]
let ``formatStage 25 years is Adult`` () =
    Assert.Equal(Some "Adult", formatStage "2000-06-15" "2025-06-15")

// 22.3
[<Fact>]
let ``formatStage 45 years is Adult`` () =
    Assert.Equal(Some "Adult", formatStage "1980-01-01" "2025-06-15")

// ================================================================
// formatStage -- default asOf
// ================================================================

// 23.1
[<Fact>]
let ``formatStage default asOf Newborn`` () =
    timeNow <- fun () -> DateTime(2025, 6, 15)
    try
        let pt = ParentTimeFormatter(EN)
        Assert.Equal(Some "Newborn", pt.FormatStage(Some "2025-06-15"))
    finally
        timeNow <- fun () -> DateTime.Today

// 23.2
[<Fact>]
let ``formatStage default asOf Child`` () =
    timeNow <- fun () -> DateTime(2025, 6, 15)
    try
        let pt = ParentTimeFormatter(EN)
        Assert.Equal(Some "Child", pt.FormatStage(Some "2020-01-01"))
    finally
        timeNow <- fun () -> DateTime.Today

// 23.3
[<Fact>]
let ``formatStage default asOf Adult`` () =
    timeNow <- fun () -> DateTime(2025, 6, 15)
    try
        let pt = ParentTimeFormatter(EN)
        Assert.Equal(Some "Adult", pt.FormatStage(Some "1980-01-01"))
    finally
        timeNow <- fun () -> DateTime.Today

// ================================================================
// ParentTime class -- English locale delegation
// ================================================================

// 24.1
[<Fact>]
let ``class formatAge Newborn`` () =
    let pt = ParentTimeFormatter(EN)
    Assert.Equal(Some "Newborn", pt.FormatAge(Some "2025-06-15", Some "2025-06-15"))

// 24.2
[<Fact>]
let ``class formatAge 3 days`` () =
    let pt = ParentTimeFormatter(EN)
    Assert.Equal(Some "3 days", pt.FormatAge(Some "2025-06-12", Some "2025-06-15"))

// 24.3
[<Fact>]
let ``class formatAge 1 week 1 day`` () =
    let pt = ParentTimeFormatter(EN)
    Assert.Equal(Some "1 week, 1 day", pt.FormatAge(Some "2025-06-07", Some "2025-06-15"))

// 24.4
[<Fact>]
let ``class formatAge 6 months`` () =
    let pt = ParentTimeFormatter(EN)
    Assert.Equal(Some "6 months", pt.FormatAge(Some "2025-01-15", Some "2025-07-15"))

// 24.5
[<Fact>]
let ``class formatAge 2 years 1 month`` () =
    let pt = ParentTimeFormatter(EN)
    Assert.Equal(Some "2 years, 1 month", pt.FormatAge(Some "2023-06-15", Some "2025-07-15"))

// 24.6
[<Fact>]
let ``class formatAge 3.5 years`` () =
    let pt = ParentTimeFormatter(EN)
    Assert.Equal(Some "3\u00BD years", pt.FormatAge(Some "2022-06-15", Some "2025-12-15"))

// 24.7
[<Fact>]
let ``class formatAge 7 years`` () =
    let pt = ParentTimeFormatter(EN)
    Assert.Equal(Some "7 years", pt.FormatAge(Some "2018-06-15", Some "2025-06-15"))

// 24.8
[<Fact>]
let ``class formatStage Newborn`` () =
    let pt = ParentTimeFormatter(EN)
    Assert.Equal(Some "Newborn", pt.FormatStage(Some "2025-06-15", Some "2025-06-15"))

// 24.9
[<Fact>]
let ``class formatStage Infant`` () =
    let pt = ParentTimeFormatter(EN)
    Assert.Equal(Some "Infant", pt.FormatStage(Some "2025-01-15", Some "2025-06-15"))

// 24.10
[<Fact>]
let ``class formatStage Toddler`` () =
    let pt = ParentTimeFormatter(EN)
    Assert.Equal(Some "Toddler", pt.FormatStage(Some "2024-06-15", Some "2025-06-15"))

// 24.11
[<Fact>]
let ``class formatStage Child`` () =
    let pt = ParentTimeFormatter(EN)
    Assert.Equal(Some "Child", pt.FormatStage(Some "2022-06-15", Some "2025-06-15"))

// 24.12
[<Fact>]
let ``class formatStage Teenager`` () =
    let pt = ParentTimeFormatter(EN)
    Assert.Equal(Some "Teenager", pt.FormatStage(Some "2012-06-15", Some "2025-06-15"))

// 24.13
[<Fact>]
let ``class formatStage Adult`` () =
    let pt = ParentTimeFormatter(EN)
    Assert.Equal(Some "Adult", pt.FormatStage(Some "2007-06-15", Some "2025-06-15"))

// 24.14
[<Fact>]
let ``class formatAge null`` () =
    let pt = ParentTimeFormatter(EN)
    Assert.Equal(None, pt.FormatAge(None, Some "2025-06-15"))

// 24.15
[<Fact>]
let ``class formatStage null`` () =
    let pt = ParentTimeFormatter(EN)
    Assert.Equal(None, pt.FormatStage(None, Some "2025-06-15"))

// ================================================================
// i18n -- Spanish locale
// ================================================================

// 25.1
[<Fact>]
let ``Spanish justBorn`` () =
    let pt = ParentTimeFormatter(ES)
    Assert.Equal(Some "Reci\u00E9n nacido", pt.FormatAge(Some "2025-06-15", Some "2025-06-15"))

// 25.2
[<Fact>]
let ``Spanish 1 day`` () =
    let pt = ParentTimeFormatter(ES)
    Assert.Equal(Some "1 d\u00EDa", pt.FormatAge(Some "2025-06-14", Some "2025-06-15"))

// 25.3
[<Fact>]
let ``Spanish 3 days`` () =
    let pt = ParentTimeFormatter(ES)
    Assert.Equal(Some "3 d\u00EDas", pt.FormatAge(Some "2025-06-12", Some "2025-06-15"))

// 25.4
[<Fact>]
let ``Spanish 1 week`` () =
    let pt = ParentTimeFormatter(ES)
    Assert.Equal(Some "1 semana", pt.FormatAge(Some "2025-06-08", Some "2025-06-15"))

// 25.5
[<Fact>]
let ``Spanish 1 week 1 day`` () =
    let pt = ParentTimeFormatter(ES)
    Assert.Equal(Some "1 semana, 1 d\u00EDa", pt.FormatAge(Some "2025-06-07", Some "2025-06-15"))

// 25.6
[<Fact>]
let ``Spanish 2 weeks 6 days`` () =
    let pt = ParentTimeFormatter(ES)
    Assert.Equal(Some "2 semanas, 6 d\u00EDas", pt.FormatAge(Some "2025-05-26", Some "2025-06-15"))

// 25.7
[<Fact>]
let ``Spanish 6 months`` () =
    let pt = ParentTimeFormatter(ES)
    Assert.Equal(Some "6 meses", pt.FormatAge(Some "2025-01-15", Some "2025-07-15"))

// 25.8
[<Fact>]
let ``Spanish 2 years 1 month`` () =
    let pt = ParentTimeFormatter(ES)
    Assert.Equal(Some "2 a\u00F1os, 1 mes", pt.FormatAge(Some "2023-06-15", Some "2025-07-15"))

// 25.9
[<Fact>]
let ``Spanish 2 years 6 months`` () =
    let pt = ParentTimeFormatter(ES)
    Assert.Equal(Some "2 a\u00F1os, 6 meses", pt.FormatAge(Some "2023-06-15", Some "2025-12-15"))

// 25.10
[<Fact>]
let ``Spanish 3.5 years`` () =
    let pt = ParentTimeFormatter(ES)
    Assert.Equal(Some "3 y medio a\u00F1os", pt.FormatAge(Some "2022-06-15", Some "2025-12-15"))

// 25.11
[<Fact>]
let ``Spanish 3 years no half`` () =
    let pt = ParentTimeFormatter(ES)
    Assert.Equal(Some "3 a\u00F1os", pt.FormatAge(Some "2022-06-15", Some "2025-06-15"))

// 25.12
[<Fact>]
let ``Spanish 7 years`` () =
    let pt = ParentTimeFormatter(ES)
    Assert.Equal(Some "7 a\u00F1os", pt.FormatAge(Some "2018-06-15", Some "2025-06-15"))

// 25.13
[<Fact>]
let ``Spanish stage Newborn`` () =
    let pt = ParentTimeFormatter(ES)
    Assert.Equal(Some "Reci\u00E9n nacido", pt.FormatStage(Some "2025-06-15", Some "2025-06-15"))

// 25.14
[<Fact>]
let ``Spanish stage Infant`` () =
    let pt = ParentTimeFormatter(ES)
    Assert.Equal(Some "Beb\u00E9", pt.FormatStage(Some "2025-01-15", Some "2025-06-15"))

// 25.15
[<Fact>]
let ``Spanish stage Toddler`` () =
    let pt = ParentTimeFormatter(ES)
    Assert.Equal(Some "Ni\u00F1o peque\u00F1o", pt.FormatStage(Some "2024-06-15", Some "2025-06-15"))

// 25.16
[<Fact>]
let ``Spanish stage Child`` () =
    let pt = ParentTimeFormatter(ES)
    Assert.Equal(Some "Ni\u00F1o", pt.FormatStage(Some "2022-06-15", Some "2025-06-15"))

// 25.17
[<Fact>]
let ``Spanish stage Teenager`` () =
    let pt = ParentTimeFormatter(ES)
    Assert.Equal(Some "Adolescente", pt.FormatStage(Some "2012-06-15", Some "2025-06-15"))

// 25.18
[<Fact>]
let ``Spanish stage Adult`` () =
    let pt = ParentTimeFormatter(ES)
    Assert.Equal(Some "Adulto", pt.FormatStage(Some "2007-06-15", Some "2025-06-15"))

// 25.19
[<Fact>]
let ``Spanish formatAge null`` () =
    let pt = ParentTimeFormatter(ES)
    Assert.Equal(None, pt.FormatAge(None, Some "2025-06-15"))

// 25.20
[<Fact>]
let ``Spanish formatStage null`` () =
    let pt = ParentTimeFormatter(ES)
    Assert.Equal(None, pt.FormatStage(None, Some "2025-06-15"))

// ================================================================
// Compactness -- short
// ================================================================

// 26.1
[<Fact>]
let ``short 3 days`` () =
    let pt = ParentTimeFormatter(EN, Short)
    Assert.Equal(Some "3 d", pt.FormatAge(Some "2025-06-12", Some "2025-06-15"))

// 26.2
[<Fact>]
let ``short 1 week`` () =
    let pt = ParentTimeFormatter(EN, Short)
    Assert.Equal(Some "1 wk", pt.FormatAge(Some "2025-06-08", Some "2025-06-15"))

// 26.3
[<Fact>]
let ``short 1 wk 1 d`` () =
    let pt = ParentTimeFormatter(EN, Short)
    Assert.Equal(Some "1 wk, 1 d", pt.FormatAge(Some "2025-06-07", Some "2025-06-15"))

// 26.4
[<Fact>]
let ``short 6 months`` () =
    let pt = ParentTimeFormatter(EN, Short)
    Assert.Equal(Some "6 mo", pt.FormatAge(Some "2025-01-15", Some "2025-07-15"))

// 26.5
[<Fact>]
let ``short 2 yr 1 mo`` () =
    let pt = ParentTimeFormatter(EN, Short)
    Assert.Equal(Some "2 yr, 1 mo", pt.FormatAge(Some "2023-06-15", Some "2025-07-15"))

// 26.6
[<Fact>]
let ``short 3.5 years`` () =
    let pt = ParentTimeFormatter(EN, Short)
    Assert.Equal(Some "3\u00BD yr", pt.FormatAge(Some "2022-06-15", Some "2025-12-15"))

// 26.7
[<Fact>]
let ``short 7 years`` () =
    let pt = ParentTimeFormatter(EN, Short)
    Assert.Equal(Some "7 yr", pt.FormatAge(Some "2018-06-15", Some "2025-06-15"))

// 26.8
[<Fact>]
let ``short justBorn unchanged`` () =
    let pt = ParentTimeFormatter(EN, Short)
    Assert.Equal(Some "Newborn", pt.FormatAge(Some "2025-06-15", Some "2025-06-15"))

// 26.9
[<Fact>]
let ``short stages unchanged`` () =
    let pt = ParentTimeFormatter(EN, Short)
    Assert.Equal(Some "Infant", pt.FormatStage(Some "2025-01-15", Some "2025-06-15"))

// ================================================================
// Compactness -- compact
// ================================================================

// 27.1
[<Fact>]
let ``compact 3 days`` () =
    let pt = ParentTimeFormatter(EN, Compact)
    Assert.Equal(Some "3d", pt.FormatAge(Some "2025-06-12", Some "2025-06-15"))

// 27.2
[<Fact>]
let ``compact 1 week`` () =
    let pt = ParentTimeFormatter(EN, Compact)
    Assert.Equal(Some "1w", pt.FormatAge(Some "2025-06-08", Some "2025-06-15"))

// 27.3
[<Fact>]
let ``compact no delimiter`` () =
    let pt = ParentTimeFormatter(EN, Compact)
    Assert.Equal(Some "1w1d", pt.FormatAge(Some "2025-06-07", Some "2025-06-15"))

// 27.4
[<Fact>]
let ``compact 6 months`` () =
    let pt = ParentTimeFormatter(EN, Compact)
    Assert.Equal(Some "6m", pt.FormatAge(Some "2025-01-15", Some "2025-07-15"))

// 27.5
[<Fact>]
let ``compact 2y1m no delimiter`` () =
    let pt = ParentTimeFormatter(EN, Compact)
    Assert.Equal(Some "2y1m", pt.FormatAge(Some "2023-06-15", Some "2025-07-15"))

// 27.6
[<Fact>]
let ``compact 3.5 years`` () =
    let pt = ParentTimeFormatter(EN, Compact)
    Assert.Equal(Some "3\u00BDy", pt.FormatAge(Some "2022-06-15", Some "2025-12-15"))

// 27.7
[<Fact>]
let ``compact 7 years`` () =
    let pt = ParentTimeFormatter(EN, Compact)
    Assert.Equal(Some "7y", pt.FormatAge(Some "2018-06-15", Some "2025-06-15"))

// 27.8
[<Fact>]
let ``compact justBorn unchanged`` () =
    let pt = ParentTimeFormatter(EN, Compact)
    Assert.Equal(Some "Newborn", pt.FormatAge(Some "2025-06-15", Some "2025-06-15"))

// ================================================================
// Locale-specific edge cases -- Hebrew (he) dual forms
// ================================================================

// 29.1
[<Fact>]
let ``Hebrew justBorn`` () =
    let pt = ParentTimeFormatter(HE)
    Assert.Equal(Some "\u05E8\u05E7 \u05E0\u05D5\u05DC\u05D3", pt.FormatAge(Some "2025-06-15", Some "2025-06-15"))

// 29.2
[<Fact>]
let ``Hebrew 1 day`` () =
    let pt = ParentTimeFormatter(HE)
    Assert.Equal(Some "\u05D9\u05D5\u05DD 1", pt.FormatAge(Some "2025-06-14", Some "2025-06-15"))

// 29.3
[<Fact>]
let ``Hebrew 3 days`` () =
    let pt = ParentTimeFormatter(HE)
    Assert.Equal(Some "3 \u05D9\u05DE\u05D9\u05DD", pt.FormatAge(Some "2025-06-12", Some "2025-06-15"))

// 29.4
[<Fact>]
let ``Hebrew 2 weeks dual`` () =
    let pt = ParentTimeFormatter(HE)
    Assert.Equal(Some "\u05E9\u05D1\u05D5\u05E2\u05D9\u05D9\u05DD", pt.FormatAge(Some "2025-06-01", Some "2025-06-15"))

// 29.5
[<Fact>]
let ``Hebrew 3 weeks other`` () =
    let pt = ParentTimeFormatter(HE)
    Assert.Equal(Some "3 \u05E9\u05D1\u05D5\u05E2\u05D5\u05EA", pt.FormatAge(Some "2025-05-25", Some "2025-06-15"))

// 29.6
[<Fact>]
let ``Hebrew 6 months other`` () =
    let pt = ParentTimeFormatter(HE)
    Assert.Equal(Some "6 \u05D7\u05D5\u05D3\u05E9\u05D9\u05DD", pt.FormatAge(Some "2025-01-15", Some "2025-07-15"))

// 29.7
[<Fact>]
let ``Hebrew 3 months`` () =
    let pt = ParentTimeFormatter(HE)
    Assert.Equal(Some "3 \u05D7\u05D5\u05D3\u05E9\u05D9\u05DD", pt.FormatAge(Some "2025-03-15", Some "2025-06-15"))

// 29.8
[<Fact>]
let ``Hebrew 2 years dual 1 month`` () =
    let pt = ParentTimeFormatter(HE)
    Assert.Equal(Some "\u05E9\u05E0\u05EA\u05D9\u05D9\u05DD, \u05D7\u05D5\u05D3\u05E9 1", pt.FormatAge(Some "2023-06-15", Some "2025-07-15"))

// 29.9
[<Fact>]
let ``Hebrew 3.5 years`` () =
    let pt = ParentTimeFormatter(HE)
    Assert.Equal(Some "3 \u05E9\u05E0\u05D9\u05DD \u05D5\u05D7\u05E6\u05D9", pt.FormatAge(Some "2022-06-15", Some "2025-12-15"))

// 29.10
[<Fact>]
let ``Hebrew 7 years`` () =
    let pt = ParentTimeFormatter(HE)
    Assert.Equal(Some "7 \u05E9\u05E0\u05D9\u05DD", pt.FormatAge(Some "2018-06-15", Some "2025-06-15"))

// 29.11
[<Fact>]
let ``Hebrew masculine newborn`` () =
    let pt = ParentTimeFormatter(HE)
    Assert.Equal(Some "\u05E8\u05E7 \u05E0\u05D5\u05DC\u05D3", pt.FormatStage(Some "2025-06-15", Some "2025-06-15", Some "m"))

// 29.12
[<Fact>]
let ``Hebrew feminine newborn`` () =
    let pt = ParentTimeFormatter(HE)
    Assert.Equal(Some "\u05E8\u05E7 \u05E0\u05D5\u05DC\u05D3\u05D4", pt.FormatStage(Some "2025-06-15", Some "2025-06-15", Some "f"))

// 29.13
[<Fact>]
let ``Hebrew masculine adult`` () =
    let pt = ParentTimeFormatter(HE)
    Assert.Equal(Some "\u05DE\u05D1\u05D5\u05D2\u05E8", pt.FormatStage(Some "2007-06-15", Some "2025-06-15", Some "m"))

// 29.14
[<Fact>]
let ``Hebrew feminine adult`` () =
    let pt = ParentTimeFormatter(HE)
    Assert.Equal(Some "\u05DE\u05D1\u05D5\u05D2\u05E8\u05EA", pt.FormatStage(Some "2007-06-15", Some "2025-06-15", Some "f"))

// ================================================================
// Locale-specific -- Macedonian (mk) mod10/mod100
// ================================================================

// 29.15
[<Fact>]
let ``Macedonian justBorn`` () =
    let pt = ParentTimeFormatter(MK)
    Assert.Equal(Some "\u041D\u043E\u0432\u043E\u0440\u043E\u0434\u0435\u043D\u0447\u0435", pt.FormatAge(Some "2025-06-15", Some "2025-06-15"))

// 29.16
[<Fact>]
let ``Macedonian 1 day`` () =
    let pt = ParentTimeFormatter(MK)
    Assert.Equal(Some "1 \u0434\u0435\u043D", pt.FormatAge(Some "2025-06-14", Some "2025-06-15"))

// 29.17
[<Fact>]
let ``Macedonian 3 days`` () =
    let pt = ParentTimeFormatter(MK)
    Assert.Equal(Some "3 \u0434\u0435\u043D\u0430", pt.FormatAge(Some "2025-06-12", Some "2025-06-15"))

// 29.18
[<Fact>]
let ``Macedonian 6 months`` () =
    let pt = ParentTimeFormatter(MK)
    Assert.Equal(Some "6 \u043C\u0435\u0441\u0435\u0446\u0438", pt.FormatAge(Some "2025-01-15", Some "2025-07-15"))

// 29.19
[<Fact>]
let ``Macedonian 2 years 1 month`` () =
    let pt = ParentTimeFormatter(MK)
    Assert.Equal(Some "2 \u0433\u043E\u0434\u0438\u043D\u0438, 1 \u043C\u0435\u0441\u0435\u0446", pt.FormatAge(Some "2023-06-15", Some "2025-07-15"))

// 29.20
[<Fact>]
let ``Macedonian 3.5 years`` () =
    let pt = ParentTimeFormatter(MK)
    Assert.Equal(Some "3 \u0433\u043E\u0434\u0438\u043D\u0438 \u0438 \u043F\u043E\u043B", pt.FormatAge(Some "2022-06-15", Some "2025-12-15"))

// 29.21
[<Fact>]
let ``Macedonian 7 years`` () =
    let pt = ParentTimeFormatter(MK)
    Assert.Equal(Some "7 \u0433\u043E\u0434\u0438\u043D\u0438", pt.FormatAge(Some "2018-06-15", Some "2025-06-15"))

// ================================================================
// Locale-specific -- Swahili (sw)
// ================================================================

// 29.22
[<Fact>]
let ``Swahili justBorn`` () =
    let pt = ParentTimeFormatter(SW)
    Assert.Equal(Some "Mzaliwa mpya", pt.FormatAge(Some "2025-06-15", Some "2025-06-15"))

// 29.23
[<Fact>]
let ``Swahili 1 day`` () =
    let pt = ParentTimeFormatter(SW)
    Assert.Equal(Some "siku 1", pt.FormatAge(Some "2025-06-14", Some "2025-06-15"))

// 29.24
[<Fact>]
let ``Swahili 3 days`` () =
    let pt = ParentTimeFormatter(SW)
    Assert.Equal(Some "siku 3", pt.FormatAge(Some "2025-06-12", Some "2025-06-15"))

// 29.25
[<Fact>]
let ``Swahili 6 months`` () =
    let pt = ParentTimeFormatter(SW)
    Assert.Equal(Some "miezi 6", pt.FormatAge(Some "2025-01-15", Some "2025-07-15"))

// 29.26
[<Fact>]
let ``Swahili 2 years 1 month`` () =
    let pt = ParentTimeFormatter(SW)
    Assert.Equal(Some "miaka 2, mwezi 1", pt.FormatAge(Some "2023-06-15", Some "2025-07-15"))

// 29.27
[<Fact>]
let ``Swahili 3.5 years`` () =
    let pt = ParentTimeFormatter(SW)
    Assert.Equal(Some "miaka 3 na nusu", pt.FormatAge(Some "2022-06-15", Some "2025-12-15"))

// ================================================================
// Locale-specific -- Indonesian (id) other_only
// ================================================================

// 29.28
[<Fact>]
let ``Indonesian justBorn`` () =
    let pt = ParentTimeFormatter(ID)
    Assert.Equal(Some "Baru lahir", pt.FormatAge(Some "2025-06-15", Some "2025-06-15"))

// 29.29
[<Fact>]
let ``Indonesian 1 day`` () =
    let pt = ParentTimeFormatter(ID)
    Assert.Equal(Some "1 hari", pt.FormatAge(Some "2025-06-14", Some "2025-06-15"))

// 29.30
[<Fact>]
let ``Indonesian 3 days`` () =
    let pt = ParentTimeFormatter(ID)
    Assert.Equal(Some "3 hari", pt.FormatAge(Some "2025-06-12", Some "2025-06-15"))

// 29.31
[<Fact>]
let ``Indonesian 6 months`` () =
    let pt = ParentTimeFormatter(ID)
    Assert.Equal(Some "6 bulan", pt.FormatAge(Some "2025-01-15", Some "2025-07-15"))

// 29.32
[<Fact>]
let ``Indonesian 3.5 years`` () =
    let pt = ParentTimeFormatter(ID)
    Assert.Equal(Some "3 tahun setengah", pt.FormatAge(Some "2022-06-15", Some "2025-12-15"))

// 29.33
[<Fact>]
let ``Indonesian 7 years`` () =
    let pt = ParentTimeFormatter(ID)
    Assert.Equal(Some "7 tahun", pt.FormatAge(Some "2018-06-15", Some "2025-06-15"))

// ================================================================
// Locale-specific -- Amharic (am) one_other_zero_one
// ================================================================

// 29.34
[<Fact>]
let ``Amharic justBorn`` () =
    let pt = ParentTimeFormatter(AM)
    Assert.Equal(Some "\u12A0\u12F2\u1235 \u12E8\u1270\u12C8\u1208\u12F0", pt.FormatAge(Some "2025-06-15", Some "2025-06-15"))

// 29.35
[<Fact>]
let ``Amharic 1 day`` () =
    let pt = ParentTimeFormatter(AM)
    Assert.Equal(Some "1 \u1240\u1295", pt.FormatAge(Some "2025-06-14", Some "2025-06-15"))

// 29.36
[<Fact>]
let ``Amharic 3 days`` () =
    let pt = ParentTimeFormatter(AM)
    Assert.Equal(Some "3 \u1240\u1293\u1275", pt.FormatAge(Some "2025-06-12", Some "2025-06-15"))

// 29.37
[<Fact>]
let ``Amharic 1w1d Ethiopic delimiter`` () =
    let pt = ParentTimeFormatter(AM)
    Assert.Equal(Some "1 \u1233\u121D\u1295\u1275\u1363 1 \u1240\u1295", pt.FormatAge(Some "2025-06-07", Some "2025-06-15"))

// 29.38
[<Fact>]
let ``Amharic 6 months`` () =
    let pt = ParentTimeFormatter(AM)
    Assert.Equal(Some "6 \u12C8\u122B\u1275", pt.FormatAge(Some "2025-01-15", Some "2025-07-15"))

// 29.39
[<Fact>]
let ``Amharic 3.5 years`` () =
    let pt = ParentTimeFormatter(AM)
    Assert.Equal(Some "3 \u12D3\u1218\u1273\u1275 \u1270\u12A9\u120D", pt.FormatAge(Some "2022-06-15", Some "2025-12-15"))

// ================================================================
// Locale lookup by code string
// ================================================================

// 30.1
[<Fact>]
let ``getLocale en returns locale`` () =
    let locale = get "en"
    Assert.True(locale.IsSome)
    Assert.Equal("en", locale.Value.Code)

// 30.2
[<Fact>]
let ``getLocale fr returns locale`` () =
    let locale = get "fr"
    Assert.True(locale.IsSome)
    Assert.Equal("fr", locale.Value.Code)

// 30.3
[<Fact>]
let ``getLocale unknown returns None`` () =
    Assert.Equal(None, get "xx")

// 30.4
[<Fact>]
let ``getLocale empty returns None`` () =
    Assert.Equal(None, get "")

// 30.5
[<Fact>]
let ``getLocale case sensitive`` () =
    Assert.Equal(None, get "EN")
