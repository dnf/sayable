module SayableDurationLib.Tests.FormatDurationTests

open Xunit
open SayableDurationLib.Types
open SayableDurationLib.Formatter
open SayableDurationLib.Locales

// ================================================================
// Null / edge cases
// ================================================================

// 1.1
[<Fact>]
let ``null seconds returns None`` () =
    Assert.Equal(None, formatDurationSecondsDefault -999)

// 1.2
[<Fact>]
let ``negative seconds returns None`` () =
    Assert.Equal(None, formatDurationSecondsDefault -1)

// 1.3
[<Fact>]
let ``formatSince null start returns None`` () =
    Assert.Equal(None, formatSinceDefault None (Some "2025-01-15T10:00:00"))

// 1.4
[<Fact>]
let ``formatUntil null target returns None`` () =
    Assert.Equal(None, formatUntilDefault None (Some "2025-01-15T10:00:00"))

// 1.5
[<Fact>]
let ``formatSince asOf before start returns None`` () =
    Assert.Equal(None, formatSinceDefault (Some "2025-01-15T10:00:00") (Some "2025-01-15T09:00:00"))

// 1.6
[<Fact>]
let ``formatUntil target in the past returns None`` () =
    Assert.Equal(None, formatUntilDefault (Some "2025-01-15T09:00:00") (Some "2025-01-15T10:00:00"))

// ================================================================
// Duration -- seconds tier (0-59s)
// ================================================================

// 2.1
[<Fact>]
let ``0 seconds is just now`` () =
    Assert.Equal(Some "just now", formatDurationSecondsDefault 0)

// 2.2
[<Fact>]
let ``1 second`` () =
    Assert.Equal(Some "1 second", formatDurationSecondsDefault 1)

// 2.3
[<Fact>]
let ``45 seconds`` () =
    Assert.Equal(Some "45 seconds", formatDurationSecondsDefault 45)

// 2.4
[<Fact>]
let ``59 seconds`` () =
    Assert.Equal(Some "59 seconds", formatDurationSecondsDefault 59)

// ================================================================
// Duration -- minutes + seconds tier (1-4 min)
// ================================================================

// 3.1
[<Fact>]
let ``60 seconds is 1 minute`` () =
    Assert.Equal(Some "1 minute", formatDurationSecondsDefault 60)

// 3.2
[<Fact>]
let ``90 seconds is 1 minute 30 seconds`` () =
    Assert.Equal(Some "1 minute, 30 seconds", formatDurationSecondsDefault 90)

// 3.3
[<Fact>]
let ``240 seconds is 4 minutes`` () =
    Assert.Equal(Some "4 minutes", formatDurationSecondsDefault 240)

// 3.4
[<Fact>]
let ``270 seconds is 4 minutes 30 seconds`` () =
    Assert.Equal(Some "4 minutes, 30 seconds", formatDurationSecondsDefault 270)

// ================================================================
// Duration -- minutes tier (5-59 min)
// ================================================================

// 4.1
[<Fact>]
let ``300 seconds is 5 minutes`` () =
    Assert.Equal(Some "5 minutes", formatDurationSecondsDefault 300)

// 4.2
[<Fact>]
let ``1500 seconds is 25 minutes`` () =
    Assert.Equal(Some "25 minutes", formatDurationSecondsDefault 1500)

// 4.3
[<Fact>]
let ``3540 seconds is 59 minutes`` () =
    Assert.Equal(Some "59 minutes", formatDurationSecondsDefault 3540)

// ================================================================
// Duration -- hours + minutes tier (1-5 hr)
// ================================================================

// 5.1
[<Fact>]
let ``3600 seconds is 1 hour`` () =
    Assert.Equal(Some "1 hour", formatDurationSecondsDefault 3600)

// 5.2
[<Fact>]
let ``5400 seconds is 1.5 hours half marker`` () =
    Assert.Equal(Some "1\u00BD hours", formatDurationSecondsDefault 5400)

// 5.3
[<Fact>]
let ``8100 seconds is 2 hours 15 minutes`` () =
    Assert.Equal(Some "2 hours, 15 minutes", formatDurationSecondsDefault 8100)

// 5.4
[<Fact>]
let ``18000 seconds is 5 hours`` () =
    Assert.Equal(Some "5 hours", formatDurationSecondsDefault 18000)

// ================================================================
// Duration -- hours tier (6-23 hr)
// ================================================================

// 6.1
[<Fact>]
let ``28800 seconds is 8 hours`` () =
    Assert.Equal(Some "8 hours", formatDurationSecondsDefault 28800)

// 6.2
[<Fact>]
let ``82800 seconds is 23 hours`` () =
    Assert.Equal(Some "23 hours", formatDurationSecondsDefault 82800)

// ================================================================
// Duration -- days tier
// ================================================================

// 7.1
[<Fact>]
let ``86400 seconds is 1 day`` () =
    Assert.Equal(Some "1 day", formatDurationSecondsDefault 86400)

// 7.2
[<Fact>]
let ``97200 seconds is 1 day 3 hours`` () =
    Assert.Equal(Some "1 day, 3 hours", formatDurationSecondsDefault 97200)

// 7.3
[<Fact>]
let ``129600 seconds is 1.5 days half marker`` () =
    Assert.Equal(Some "1\u00BD days", formatDurationSecondsDefault 129600)

// 7.4
[<Fact>]
let ``432000 seconds is 5 days`` () =
    Assert.Equal(Some "5 days", formatDurationSecondsDefault 432000)

// 7.5
[<Fact>]
let ``172800 seconds is 2 days`` () =
    Assert.Equal(Some "2 days", formatDurationSecondsDefault 172800)

// ================================================================
// Duration -- weeks tier
// ================================================================

// 8.1
[<Fact>]
let ``604800 seconds is 1 week`` () =
    Assert.Equal(Some "1 week", formatDurationSecondsDefault 604800)

// 8.2
[<Fact>]
let ``1296000 seconds is 2 weeks 1 day`` () =
    Assert.Equal(Some "2 weeks, 1 day", formatDurationSecondsDefault 1296000)

// 8.3
[<Fact>]
let ``2419200 seconds is 4 weeks`` () =
    Assert.Equal(Some "4 weeks", formatDurationSecondsDefault 2419200)

// ================================================================
// Duration -- months and years tier
// ================================================================

// 9.1
[<Fact>]
let ``2678400 seconds is 1 month`` () =
    Assert.Equal(Some "1 month", formatDurationSecondsDefault 2678400)

// 9.2
[<Fact>]
let ``7884000 seconds is 3 months`` () =
    Assert.Equal(Some "3 months", formatDurationSecondsDefault 7884000)

// 9.3
[<Fact>]
let ``31536000 seconds is 1 year`` () =
    Assert.Equal(Some "1 year", formatDurationSecondsDefault 31536000)

// 9.4
[<Fact>]
let ``39420000 seconds is 1 year 3 months`` () =
    Assert.Equal(Some "1 year, 3 months", formatDurationSecondsDefault 39420000)

// ================================================================
// Duration from ISO timestamps
// ================================================================

// 10.1
[<Fact>]
let ``ISO 1.5 hours`` () =
    Assert.Equal(Some "1\u00BD hours", formatDurationIsoDefault "2025-01-15T10:00:00" "2025-01-15T11:30:00")

// 10.2
[<Fact>]
let ``ISO 45 minutes`` () =
    Assert.Equal(Some "45 minutes", formatDurationIsoDefault "2025-01-15T10:00:00" "2025-01-15T10:45:00")

// ================================================================
// Relative time -- since
// ================================================================

// 11.1
[<Fact>]
let ``formatSince same time is just now`` () =
    Assert.Equal(Some "just now", formatSinceDefault (Some "2025-01-15T10:00:00") (Some "2025-01-15T10:00:00"))

// 11.2
[<Fact>]
let ``formatSince 30 seconds ago`` () =
    Assert.Equal(Some "30 seconds ago", formatSinceDefault (Some "2025-01-15T10:00:00") (Some "2025-01-15T10:00:30"))

// 11.3
[<Fact>]
let ``formatSince 45 minutes ago`` () =
    Assert.Equal(Some "45 minutes ago", formatSinceDefault (Some "2025-01-15T10:00:00") (Some "2025-01-15T10:45:00"))

// 11.4
[<Fact>]
let ``formatSince 3 hours ago`` () =
    Assert.Equal(Some "3 hours ago", formatSinceDefault (Some "2025-01-15T10:00:00") (Some "2025-01-15T13:00:00"))

// ================================================================
// Relative time -- until
// ================================================================

// 12.1
[<Fact>]
let ``formatUntil same time is just now`` () =
    Assert.Equal(Some "just now", formatUntilDefault (Some "2025-01-15T10:00:00") (Some "2025-01-15T10:00:00"))

// 12.2
[<Fact>]
let ``formatUntil in 20 minutes`` () =
    Assert.Equal(Some "in 20 minutes", formatUntilDefault (Some "2025-01-15T10:20:00") (Some "2025-01-15T10:00:00"))

// 12.3
[<Fact>]
let ``formatUntil in 3 hours`` () =
    Assert.Equal(Some "in 3 hours", formatUntilDefault (Some "2025-01-15T13:00:00") (Some "2025-01-15T10:00:00"))

// ================================================================
// Locale -- German
// ================================================================

// 13.1
[<Fact>]
let ``German 1 hour`` () =
    let sd = SayableDurationFormatter(DE)
    Assert.Equal(Some "1 Stunde", sd.FormatDurationSeconds(3600))

// 13.2
[<Fact>]
let ``German formatSince 5 minutes ago`` () =
    let sd = SayableDurationFormatter(DE)
    Assert.Equal(Some "vor 5 Minuten", sd.FormatSince(Some "2025-01-15T10:00:00", Some "2025-01-15T10:05:00"))

// ================================================================
// Locale -- French
// ================================================================

// 14.1
[<Fact>]
let ``French 2 hours`` () =
    let sd = SayableDurationFormatter(FR)
    Assert.Equal(Some "2 heures", sd.FormatDurationSeconds(7200))

// ================================================================
// Locale -- Japanese
// ================================================================

// 15.1
[<Fact>]
let ``Japanese 2 minutes`` () =
    let sd = SayableDurationFormatter(JA)
    Assert.Equal(Some "2\u5206", sd.FormatDurationSeconds(120))

// 15.2
[<Fact>]
let ``Japanese formatSince 1 hour ago`` () =
    let sd = SayableDurationFormatter(JA)
    Assert.Equal(Some "1\u6642\u9593\u524D", sd.FormatSince(Some "2025-01-15T10:00:00", Some "2025-01-15T11:00:00"))

// ================================================================
// Short compactness -- duration
// ================================================================

// 16.1
[<Fact>]
let ``short 1 hour`` () =
    let sd = SayableDurationFormatter(EN, Short)
    Assert.Equal(Some "1h", sd.FormatDurationSeconds(3600))

// 16.2
[<Fact>]
let ``short 1m 30s`` () =
    let sd = SayableDurationFormatter(EN, Short)
    Assert.Equal(Some "1m, 30s", sd.FormatDurationSeconds(90))

// ================================================================
// Compact compactness -- duration
// ================================================================

// 17.1
[<Fact>]
let ``compact 1 hour`` () =
    let sd = SayableDurationFormatter(EN, Compact)
    Assert.Equal(Some "1h", sd.FormatDurationSeconds(3600))

// 17.2
[<Fact>]
let ``compact 1m30s`` () =
    let sd = SayableDurationFormatter(EN, Compact)
    Assert.Equal(Some "1m30s", sd.FormatDurationSeconds(90))

// ================================================================
// Short compactness — relative time
// ================================================================

// 18.1
[<Fact>]
let ``days and hours both kept`` () =
    let f = SayableDurationFormatter(MEN, Short)
    Assert.Equal(Some "l\u0254h\u0254nga 2, awa 14 taa gb\u0254y\u0254", f.FormatSince(Some "2025-01-20T01:32:11", Some "2025-01-22T15:39:16"))

// ================================================================
// Range (500-year ceiling)
// ================================================================

// 19.1
[<Fact>]
let ``500 julian years 6000 months the ceiling`` () =
    let f = SayableDurationFormatter(EN)
    Assert.Equal(Some "500 years", f.FormatDurationSeconds(15778800000L))

// 19.2
[<Fact>]
let ``over 6000 months`` () =
    let f = SayableDurationFormatter(EN)
    Assert.Equal(None, f.FormatDurationSeconds(15800000000L))

// 19.3
[<Fact>]
let ``well beyond the ceiling and 32 bit`` () =
    let f = SayableDurationFormatter(EN)
    Assert.Equal(None, f.FormatDurationSeconds(99999999999L))

// 19.4
[<Fact>]
let ``525 years ago`` () =
    let f = SayableDurationFormatter(EN)
    Assert.Equal(None, f.FormatSince(Some "1500-01-01T00:00:00", Some "2025-01-01T00:00:00"))

// 19.5
[<Fact>]
let ``575 years from now`` () =
    let f = SayableDurationFormatter(EN)
    Assert.Equal(None, f.FormatUntil(Some "2600-01-01T00:00:00", Some "2025-01-01T00:00:00"))

// ================================================================
// Timestamp validation
// ================================================================

// 20.1
[<Fact>]
let ``seconds are optional`` () =
    let f = SayableDurationFormatter(EN)
    Assert.Equal(Some "1\u00BD hours", f.FormatDurationIso("2025-01-15T10:00", "2025-01-15T11:30:00"))

// 20.2
[<Fact>]
let ``minutes are required`` () =
    let f = SayableDurationFormatter(EN)
    Assert.Equal(None, f.FormatDurationIso("2025-01-15T10", "2025-01-15T11:30:00"))

// 20.3
[<Fact>]
let ``unpadded date`` () =
    let f = SayableDurationFormatter(EN)
    Assert.Equal(None, f.FormatDurationIso("2025-1-5T10:00:00", "2025-01-15T11:30:00"))

// 20.4
[<Fact>]
let ``impossible date`` () =
    let f = SayableDurationFormatter(EN)
    Assert.Equal(None, f.FormatDurationIso("2025-02-30T10:00:00", "2025-03-15T11:30:00"))

// 20.5
[<Fact>]
let ``hour out of range`` () =
    let f = SayableDurationFormatter(EN)
    Assert.Equal(None, f.FormatSince(Some "2025-01-15T10:00:00", Some "2025-01-15T25:00:00"))
