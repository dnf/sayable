module SayableTimeLib.Tests.FormatTimeTests

open Xunit
open SayableTimeLib.Types
open SayableTimeLib.Formatter
open SayableTimeLib.Locales

// ================================================================
// Null / edge cases
// ================================================================

// 1.1
[<Fact>]
let ``null input returns None`` () =
    Assert.Equal(None, formatTimeDefault None)

// 1.2
[<Fact>]
let ``empty string returns None`` () =
    Assert.Equal(None, formatTimeDefault (Some ""))

// 1.3
[<Fact>]
let ``invalid string returns None`` () =
    Assert.Equal(None, formatTimeDefault (Some "invalid"))

// 1.4
[<Fact>]
let ``25:00 returns None`` () =
    Assert.Equal(None, formatTimeDefault (Some "25:00"))

// ================================================================
// Clock time (normal compactness)
// ================================================================

// 2.1
[<Fact>]
let ``midnight`` () =
    Assert.Equal(Some "midnight", formatTimeDefault (Some "00:00"))

// 2.2
[<Fact>]
let ``noon`` () =
    Assert.Equal(Some "noon", formatTimeDefault (Some "12:00"))

// 2.3
[<Fact>]
let ``three o'clock`` () =
    Assert.Equal(Some "three o'clock", formatTimeDefault (Some "15:00"))

// 2.4
[<Fact>]
let ``a quarter past two`` () =
    Assert.Equal(Some "a quarter past two", formatTimeDefault (Some "14:15"))

// 2.5
[<Fact>]
let ``half past nine`` () =
    Assert.Equal(Some "half past nine", formatTimeDefault (Some "09:30"))

// 2.6
[<Fact>]
let ``a quarter to eleven`` () =
    Assert.Equal(Some "a quarter to eleven", formatTimeDefault (Some "10:45"))

// 2.7
[<Fact>]
let ``five past eight`` () =
    Assert.Equal(Some "five past eight", formatTimeDefault (Some "08:05"))

// 2.8
[<Fact>]
let ``five to five`` () =
    Assert.Equal(Some "five to five", formatTimeDefault (Some "16:55"))

// 2.9
[<Fact>]
let ``23:58 rounds to midnight`` () =
    Assert.Equal(Some "midnight", formatTimeDefault (Some "23:58"))

// 2.10
[<Fact>]
let ``07:22 rounds to twenty past seven`` () =
    Assert.Equal(Some "twenty past seven", formatTimeDefault (Some "07:22"))

// 2.11
[<Fact>]
let ``ISO datetime input`` () =
    Assert.Equal(Some "a quarter past two", formatTimeDefault (Some "2025-01-15T14:15:00"))

// ================================================================
// Clock time (short compactness)
// ================================================================

// 3.1
[<Fact>]
let ``short 14:15 is 2:15 PM`` () =
    let st = SayableTimeFormatter(EN, Short)
    Assert.Equal(Some "2:15 PM", st.FormatTime(Some "14:15"))

// 3.2
[<Fact>]
let ``short 09:30 is 9:30 AM`` () =
    let st = SayableTimeFormatter(EN, Short)
    Assert.Equal(Some "9:30 AM", st.FormatTime(Some "09:30"))

// 3.3
[<Fact>]
let ``short 00:00 is 12:00 AM`` () =
    let st = SayableTimeFormatter(EN, Short)
    Assert.Equal(Some "12:00 AM", st.FormatTime(Some "00:00"))

// 3.4
[<Fact>]
let ``short 12:00 is 12:00 PM`` () =
    let st = SayableTimeFormatter(EN, Short)
    Assert.Equal(Some "12:00 PM", st.FormatTime(Some "12:00"))

// ================================================================
// Clock time (compact)
// ================================================================

// 4.1
[<Fact>]
let ``compact 14:15 is 2:15p`` () =
    let st = SayableTimeFormatter(EN, Compact)
    Assert.Equal(Some "2:15p", st.FormatTime(Some "14:15"))

// 4.2
[<Fact>]
let ``compact 09:30 is 9:30a`` () =
    let st = SayableTimeFormatter(EN, Compact)
    Assert.Equal(Some "9:30a", st.FormatTime(Some "09:30"))

// ================================================================
// Locale -- German
// ================================================================

// 5.1
[<Fact>]
let ``German 15:30 is halb vier`` () =
    let st = SayableTimeFormatter(DE)
    Assert.Equal(Some "halb vier", st.FormatTime(Some "15:30"))

// ================================================================
// Locale -- French
// ================================================================

// 6.1
[<Fact>]
let ``French 15:15 is trois heures et quart`` () =
    let st = SayableTimeFormatter(FR)
    Assert.Equal(Some "trois heures et quart", st.FormatTime(Some "15:15"))

// ================================================================
// Locale -- Japanese
// ================================================================

// 7.1
[<Fact>]
let ``Japanese 15:30`` () =
    let st = SayableTimeFormatter(JA)
    Assert.Equal(Some "\u4E09\u6642\u534A", st.FormatTime(Some "15:30"))

// ================================================================
// Locale -- Finnish (dot separator, short)
// ================================================================

// 8.1
[<Fact>]
let ``Finnish 14:15 is 14.15 with dot separator`` () =
    let st = SayableTimeFormatter(FI, Short)
    Assert.Equal(Some "14.15", st.FormatTime(Some "14:15"))

// 8.2
[<Fact>]
let ``Finnish 00:00 is 0.00 midnight dot`` () =
    let st = SayableTimeFormatter(FI, Short)
    Assert.Equal(Some "0.00", st.FormatTime(Some "00:00"))

// ================================================================
// Minutes in short and compact modes
// ================================================================

// 9.1
[<Fact>]
let ``digital modes keep the exact minute en short 18-01`` () =
    let f = SayableTimeFormatter(EN, Short)
    Assert.Equal(Some "6:01 PM", f.FormatTime(Some "18:01"))

// 9.2
[<Fact>]
let ``digital modes keep the exact minute en compact 19-05`` () =
    let f = SayableTimeFormatter(EN, Compact)
    Assert.Equal(Some "7:05p", f.FormatTime(Some "19:05"))

// ================================================================
// Input validation
// ================================================================

// 10.1
[<Fact>]
let ``one digit hour`` () =
    let f = SayableTimeFormatter(EN)
    Assert.Equal(Some "half past nine", f.FormatTime(Some "9:30"))

// 10.2
[<Fact>]
let ``two digit hour`` () =
    let f = SayableTimeFormatter(EN)
    Assert.Equal(Some "half past nine", f.FormatTime(Some "09:30"))

// 10.3
[<Fact>]
let ``leading whitespace`` () =
    let f = SayableTimeFormatter(EN)
    Assert.Equal(None, f.FormatTime(Some " 9:30"))

// 10.4
[<Fact>]
let ``trailing whitespace`` () =
    let f = SayableTimeFormatter(EN)
    Assert.Equal(None, f.FormatTime(Some "9:30 "))

// 10.5
[<Fact>]
let ``minutes need two digits`` () =
    let f = SayableTimeFormatter(EN)
    Assert.Equal(None, f.FormatTime(Some "9:5"))

// 10.6
[<Fact>]
let ``hour out of range`` () =
    let f = SayableTimeFormatter(EN)
    Assert.Equal(None, f.FormatTime(Some "24:00"))

// 10.7
[<Fact>]
let ``seconds are allowed and ignored`` () =
    let f = SayableTimeFormatter(EN)
    Assert.Equal(Some "a quarter past two", f.FormatTime(Some "14:15:30"))

// 10.8
[<Fact>]
let ``iso datetime with zone suffix ignored`` () =
    let f = SayableTimeFormatter(EN)
    Assert.Equal(Some "a quarter past two", f.FormatTime(Some "2025-01-15T14:15:00Z"))

// 10.9
[<Fact>]
let ``iso datetime with an impossible date`` () =
    let f = SayableTimeFormatter(EN)
    Assert.Equal(None, f.FormatTime(Some "2025-02-30T14:15:00"))
