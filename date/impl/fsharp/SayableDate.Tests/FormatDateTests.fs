module SayableDateLib.Tests.FormatDateTests

open Xunit
open SayableDateLib.Types
open SayableDateLib.Formatter
open SayableDateLib.Locales

// ================================================================
// Null / edge cases
// ================================================================

// 1.1
[<Fact>]
let ``null date returns None`` () =
    Assert.Equal(None, formatDateDefault None)

// 1.2
[<Fact>]
let ``empty string returns None`` () =
    Assert.Equal(None, formatDateDefault (Some ""))

// 1.3
[<Fact>]
let ``invalid string returns None`` () =
    Assert.Equal(None, formatDateDefault (Some "invalid"))

// 1.4
[<Fact>]
let ``formatRelative null asOf returns None`` () =
    Assert.Equal(None, formatRelativeDefault (Some "2025-03-15") None)

// 1.5
[<Fact>]
let ``formatRelative null date returns None`` () =
    Assert.Equal(None, formatRelativeDefault None (Some "2025-03-15"))

// ================================================================
// format_date -- normal compactness (English)
// ================================================================

// 2.1
[<Fact>]
let ``March 15th`` () =
    Assert.Equal(Some "March 15th", formatDateDefault (Some "2025-03-15"))

// 2.2
[<Fact>]
let ``January 1st`` () =
    Assert.Equal(Some "January 1st", formatDateDefault (Some "2025-01-01"))

// 2.3
[<Fact>]
let ``May 22nd`` () =
    Assert.Equal(Some "May 22nd", formatDateDefault (Some "2025-05-22"))

// 2.4
[<Fact>]
let ``July 3rd`` () =
    Assert.Equal(Some "July 3rd", formatDateDefault (Some "2025-07-03"))

// 2.5
[<Fact>]
let ``December 31st`` () =
    Assert.Equal(Some "December 31st", formatDateDefault (Some "2025-12-31"))

// 2.6
[<Fact>]
let ``June 11th`` () =
    Assert.Equal(Some "June 11th", formatDateDefault (Some "2025-06-11"))

// 2.7
[<Fact>]
let ``ISO datetime input`` () =
    Assert.Equal(Some "March 15th", formatDateDefault (Some "2025-03-15T14:30:00"))

// ================================================================
// format_date -- short compactness (English)
// ================================================================

// 3.1
[<Fact>]
let ``short Mar 15`` () =
    let sd = SayableDateFormatter(EN, Short)
    Assert.Equal(Some "Mar 15", sd.FormatDate(Some "2025-03-15"))

// 3.2
[<Fact>]
let ``short Jan 1`` () =
    let sd = SayableDateFormatter(EN, Short)
    Assert.Equal(Some "Jan 1", sd.FormatDate(Some "2025-01-01"))

// 3.3
[<Fact>]
let ``short Dec 25`` () =
    let sd = SayableDateFormatter(EN, Short)
    Assert.Equal(Some "Dec 25", sd.FormatDate(Some "2025-12-25"))

// ================================================================
// format_date -- compact (English)
// ================================================================

// 4.1
[<Fact>]
let ``compact 3/15`` () =
    let sd = SayableDateFormatter(EN, Compact)
    Assert.Equal(Some "3/15", sd.FormatDate(Some "2025-03-15"))

// 4.2
[<Fact>]
let ``compact 1/1`` () =
    let sd = SayableDateFormatter(EN, Compact)
    Assert.Equal(Some "1/1", sd.FormatDate(Some "2025-01-01"))

// ================================================================
// format_relative -- proximity tiers (English)
// ================================================================

// 5.1
[<Fact>]
let ``today`` () =
    Assert.Equal(Some "today", formatRelativeDefault (Some "2025-03-15") (Some "2025-03-15"))

// 5.2
[<Fact>]
let ``tomorrow`` () =
    Assert.Equal(Some "tomorrow", formatRelativeDefault (Some "2025-03-16") (Some "2025-03-15"))

// 5.3
[<Fact>]
let ``yesterday`` () =
    Assert.Equal(Some "yesterday", formatRelativeDefault (Some "2025-03-14") (Some "2025-03-15"))

// 5.4
[<Fact>]
let ``day after tomorrow`` () =
    Assert.Equal(Some "the day after tomorrow", formatRelativeDefault (Some "2025-03-17") (Some "2025-03-15"))

// 5.5
[<Fact>]
let ``day before yesterday`` () =
    Assert.Equal(Some "the day before yesterday", formatRelativeDefault (Some "2025-03-13") (Some "2025-03-15"))

// 5.6
[<Fact>]
let ``this Wednesday`` () =
    Assert.Equal(Some "this Wednesday", formatRelativeDefault (Some "2025-03-19") (Some "2025-03-15"))

// 5.7
[<Fact>]
let ``this Thursday`` () =
    Assert.Equal(Some "this Thursday", formatRelativeDefault (Some "2025-03-20") (Some "2025-03-15"))

// 5.8
[<Fact>]
let ``last Tuesday`` () =
    Assert.Equal(Some "last Tuesday", formatRelativeDefault (Some "2025-03-11") (Some "2025-03-15"))

// 5.9
[<Fact>]
let ``next Saturday`` () =
    Assert.Equal(Some "next Saturday", formatRelativeDefault (Some "2025-03-22") (Some "2025-03-15"))

// 5.10
[<Fact>]
let ``next Thursday`` () =
    Assert.Equal(Some "next Thursday", formatRelativeDefault (Some "2025-03-27") (Some "2025-03-15"))

// 5.11
[<Fact>]
let ``calendar fallback same year`` () =
    Assert.Equal(Some "March 1st", formatRelativeDefault (Some "2025-03-01") (Some "2025-03-15"))

// 5.12
[<Fact>]
let ``calendar fallback future same year`` () =
    Assert.Equal(Some "April 10th", formatRelativeDefault (Some "2025-04-10") (Some "2025-03-15"))

// 5.13
[<Fact>]
let ``different year includes year`` () =
    Assert.Equal(Some "January 5th, 2026", formatRelativeDefault (Some "2026-01-05") (Some "2025-03-15"))

// 5.14
[<Fact>]
let ``past year includes year`` () =
    Assert.Equal(Some "December 25th, 2024", formatRelativeDefault (Some "2024-12-25") (Some "2025-03-15"))

// ================================================================
// format_relative -- compact skips weekday tiers
// ================================================================

// 6.1
[<Fact>]
let ``compact today`` () =
    let sd = SayableDateFormatter(EN, Compact)
    Assert.Equal(Some "today", sd.FormatRelative(Some "2025-03-15", Some "2025-03-15"))

// 6.2
[<Fact>]
let ``compact tomorrow`` () =
    let sd = SayableDateFormatter(EN, Compact)
    Assert.Equal(Some "tomorrow", sd.FormatRelative(Some "2025-03-16", Some "2025-03-15"))

// 6.3
[<Fact>]
let ``compact goes straight to numeric`` () =
    let sd = SayableDateFormatter(EN, Compact)
    Assert.Equal(Some "3/19", sd.FormatRelative(Some "2025-03-19", Some "2025-03-15"))

// 6.4
[<Fact>]
let ``compact different year`` () =
    let sd = SayableDateFormatter(EN, Compact)
    Assert.Equal(Some "1/5/26", sd.FormatRelative(Some "2026-01-05", Some "2025-03-15"))

// ================================================================
// Locale -- German
// ================================================================

// 7.1
[<Fact>]
let ``German format_date`` () =
    let sd = SayableDateFormatter(DE)
    Assert.Equal(Some "15. M\u00E4rz", sd.FormatDate(Some "2025-03-15"))

// 7.2
[<Fact>]
let ``German morgen`` () =
    let sd = SayableDateFormatter(DE)
    Assert.Equal(Some "morgen", sd.FormatRelative(Some "2025-03-16", Some "2025-03-15"))

// 7.3
[<Fact>]
let ``German uebermorgen`` () =
    let sd = SayableDateFormatter(DE)
    Assert.Equal(Some "\u00FCbermorgen", sd.FormatRelative(Some "2025-03-17", Some "2025-03-15"))

// 7.4
[<Fact>]
let ``German diesen Mittwoch`` () =
    let sd = SayableDateFormatter(DE)
    Assert.Equal(Some "diesen Mittwoch", sd.FormatRelative(Some "2025-03-19", Some "2025-03-15"))

// ================================================================
// Locale -- French
// ================================================================

// 8.1
[<Fact>]
let ``French 1er mars`` () =
    let sd = SayableDateFormatter(FR)
    Assert.Equal(Some "1er mars", sd.FormatDate(Some "2025-03-01"))

// 8.2
[<Fact>]
let ``French 15 mars`` () =
    let sd = SayableDateFormatter(FR)
    Assert.Equal(Some "15 mars", sd.FormatDate(Some "2025-03-15"))

// 8.3
[<Fact>]
let ``French demain`` () =
    let sd = SayableDateFormatter(FR)
    Assert.Equal(Some "demain", sd.FormatRelative(Some "2025-03-16", Some "2025-03-15"))

// ================================================================
// Locale -- Japanese
// ================================================================

// 9.1
[<Fact>]
let ``Japanese format_date`` () =
    let sd = SayableDateFormatter(JA)
    Assert.Equal(Some "3\u670815\u65E5", sd.FormatDate(Some "2025-03-15"))

// 9.2
[<Fact>]
let ``Japanese ashita`` () =
    let sd = SayableDateFormatter(JA)
    Assert.Equal(Some "\u660E\u65E5", sd.FormatRelative(Some "2025-03-16", Some "2025-03-15"))

// 9.3
[<Fact>]
let ``Japanese kondo no suiyoubi`` () =
    let sd = SayableDateFormatter(JA)
    Assert.Equal(Some "\u4ECA\u5EA6\u306E\u6C34\u66DC\u65E5", sd.FormatRelative(Some "2025-03-19", Some "2025-03-15"))

// ================================================================
// Locale -- Russian (genitive months)
// ================================================================

// 10.1
[<Fact>]
let ``Russian genitive month`` () =
    let sd = SayableDateFormatter(RU)
    Assert.Equal(Some "15 \u043C\u0430\u0440\u0442\u0430", sd.FormatDate(Some "2025-03-15"))

// 10.2
[<Fact>]
let ``Russian zavtra`` () =
    let sd = SayableDateFormatter(RU)
    Assert.Equal(Some "\u0437\u0430\u0432\u0442\u0440\u0430", sd.FormatRelative(Some "2025-03-16", Some "2025-03-15"))

// ================================================================
// Locale -- Arabic
// ================================================================

// 11.1
[<Fact>]
let ``Arabic format_date`` () =
    let sd = SayableDateFormatter(AR)
    Assert.Equal(Some "15 \u0645\u0627\u0631\u0633", sd.FormatDate(Some "2025-03-15"))

// 11.2
[<Fact>]
let ``Arabic ghadan`` () =
    let sd = SayableDateFormatter(AR)
    Assert.Equal(Some "\u063A\u062F\u0627\u064B", sd.FormatRelative(Some "2025-03-16", Some "2025-03-15"))

// ================================================================
// Locale -- Spanish
// ================================================================

// 12.1
[<Fact>]
let ``Spanish format_date`` () =
    let sd = SayableDateFormatter(ES)
    Assert.Equal(Some "15 de marzo", sd.FormatDate(Some "2025-03-15"))

// 12.2
[<Fact>]
let ``Spanish pasado manana`` () =
    let sd = SayableDateFormatter(ES)
    Assert.Equal(Some "pasado ma\u00F1ana", sd.FormatRelative(Some "2025-03-17", Some "2025-03-15"))

// ================================================================
// format_date_with_year
// ================================================================

// 13.1
[<Fact>]
let ``format date with year en normal 2018-02-04`` () =
    let f = SayableDateFormatter(EN)
    Assert.Equal(Some "February 4th, 2018", f.FormatDateWithYear(Some "2018-02-04"))

// 13.2
[<Fact>]
let ``format date with year en short 2025-03-15`` () =
    let f = SayableDateFormatter(EN, Short)
    Assert.Equal(Some "Mar 15, 2025", f.FormatDateWithYear(Some "2025-03-15"))

// 13.3
[<Fact>]
let ``format date with year en compact 1997-01-21`` () =
    let f = SayableDateFormatter(EN, Compact)
    Assert.Equal(Some "1/21/97", f.FormatDateWithYear(Some "1997-01-21"))

// 13.4
[<Fact>]
let ``two digit year keeps its leading zero`` () =
    let f = SayableDateFormatter(TG, Compact)
    Assert.Equal(Some "20/5/07", f.FormatDateWithYear(Some "2007-05-20"))

// 13.5
[<Fact>]
let ``format date with year fi short 1996-06-21`` () =
    let f = SayableDateFormatter(FI, Short)
    Assert.Equal(Some "21. kes\u00E4kuuta 1996", f.FormatDateWithYear(Some "1996-06-21"))

// ================================================================
// Short month names (locales that keep the full genitive)
// ================================================================

// 14.1
[<Fact>]
let ``short month names locales that keep the sk short 2031-02-15`` () =
    let f = SayableDateFormatter(SK, Short)
    Assert.Equal(Some "15. febru\u00E1ra", f.FormatDate(Some "2031-02-15"))

// 14.2
[<Fact>]
let ``short month names locales that keep the cs short 2025-12-10`` () =
    let f = SayableDateFormatter(CS, Short)
    Assert.Equal(Some "10. prosince", f.FormatDate(Some "2025-12-10"))

// 14.3
[<Fact>]
let ``short month names locales that keep the uk short 2025-11-05`` () =
    let f = SayableDateFormatter(UK, Short)
    Assert.Equal(Some "5 \u043B\u0438\u0441\u0442\u043E\u043F\u0430\u0434\u0430", f.FormatDate(Some "2025-11-05"))

// 14.4
[<Fact>]
let ``short month names locales that keep the fi short 1998-08-08`` () =
    let f = SayableDateFormatter(FI, Short)
    Assert.Equal(Some "8. elokuuta", f.FormatRelative(Some "1998-08-08", Some "1998-08-15"))

// ================================================================
// format_relative — short phrases
// ================================================================

// 15.1
[<Fact>]
let ``day after tomorrow kw short 2035-12-04`` () =
    let f = SayableDateFormatter(KW, Short)
    Assert.Equal(Some "an Mth ma", f.FormatRelative(Some "2035-12-04", Some "2035-12-02"))

// 15.2
[<Fact>]
let ``day before yesterday mam short`` () =
    let f = SayableDateFormatter(MAM, Short)
    Assert.Equal(Some "Dom nchi'j", f.FormatRelative(Some "2000-01-23", Some "2000-01-25"))

// 15.3
[<Fact>]
let ``day after tomorrow kek short 2014-10-24`` () =
    let f = SayableDateFormatter(KEK, Short)
    Assert.Equal(Some "a'in Vie", f.FormatRelative(Some "2014-10-24", Some "2014-10-22"))

// ================================================================
// Input validation
// ================================================================

// 16.1
[<Fact>]
let ``february 30 doesnt exist`` () =
    let f = SayableDateFormatter(EN)
    Assert.Equal(None, f.FormatDate(Some "2025-02-30"))

// 16.2
[<Fact>]
let ``month 13`` () =
    let f = SayableDateFormatter(EN)
    Assert.Equal(None, f.FormatDate(Some "2025-13-01"))

// 16.3
[<Fact>]
let ``unpadded month and day`` () =
    let f = SayableDateFormatter(EN)
    Assert.Equal(None, f.FormatDate(Some "2025-6-1"))

// 16.4
[<Fact>]
let ``surrounding whitespace`` () =
    let f = SayableDateFormatter(EN)
    Assert.Equal(None, f.FormatDate(Some " 2025-06-01"))

// 16.5
[<Fact>]
let ``an iso datetime only the date part`` () =
    let f = SayableDateFormatter(EN)
    Assert.Equal(Some "June 1st", f.FormatDate(Some "2025-06-01T10:00:00"))

// 16.6
[<Fact>]
let ``february 29 in a non leap year`` () =
    let f = SayableDateFormatter(EN)
    Assert.Equal(None, f.FormatDateWithYear(Some "2023-02-29"))

// 16.7
[<Fact>]
let ``invalid asof`` () =
    let f = SayableDateFormatter(EN)
    Assert.Equal(None, f.FormatRelative(Some "2025-03-16", Some "2025-04-31"))
