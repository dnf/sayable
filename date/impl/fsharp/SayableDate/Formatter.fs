namespace SayableDateLib

open System
open System.Globalization
open System.Text.RegularExpressions
open SayableDateLib.Types

module Formatter =

    let [<Literal>] Version = "0.5.0"

    // DateTime can't represent year 0000, which the spec accepts (proleptic Gregorian).
    let private daysInMonth (year: int) (month: int) : int =
        match month with
        | 2 -> if (year % 4 = 0 && year % 100 <> 0) || year % 400 = 0 then 29 else 28
        | 4 | 6 | 9 | 11 -> 30
        | _ -> 31

    /// YYYY-MM-DD, alone or followed by T and anything (an ISO datetime).
    let private datePrefix =
        Regex(@"\A([0-9]{4})-([0-9]{2})-([0-9]{2})(?:T.*)?\z", RegexOptions.Singleline ||| RegexOptions.CultureInvariant)

    let internal parseDate (s: string) : int[] option =
        let m = datePrefix.Match(if isNull s then "" else s)
        if not m.Success then
            None
        else
            let field (i: int) = Int32.Parse(m.Groups.[i].Value, CultureInfo.InvariantCulture)
            let year, month, day = field 1, field 2, field 3
            if month >= 1 && month <= 12 && day >= 1 && day <= daysInMonth year month then
                Some [| year; month; day |]
            else
                None

    let internal toJdn (year: int) (month: int) (day: int) : int =
        let a = (14 - month) / 12
        let y = year + 4800 - a
        let m = month + 12 * a - 3
        day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045

    let internal weekday (year: int) (month: int) (day: int) : int =
        (toJdn year month day + 1) % 7

    type SayableDateFormatter(locale: DateLocale, ?compactness: Compactness) =
        let compactness = defaultArg compactness Normal

        let months, monthsInDate, weekdays, dayFormat, dayFormatExceptions, datePattern, datePatternWithYear, todayStr, tomorrowStr, yesterdayStr =
            let ovr =
                match compactness with
                | Short -> locale.ShortOverride
                | Compact -> locale.CompactOverride
                | Normal -> None

            let mo =
                match ovr with
                | Some o -> o.Months |> Option.defaultValue locale.Months
                | None -> locale.Months

            let mid =
                match ovr with
                | Some o -> o.MonthsInDate |> Option.orElse locale.MonthsInDate
                | None -> locale.MonthsInDate

            let wd =
                match ovr with
                | Some o -> o.Weekdays |> Option.defaultValue locale.Weekdays
                | None -> locale.Weekdays

            let df, dfe =
                match ovr with
                | Some o ->
                    match o.DayFormat, o.DayFormatExceptions with
                    | Some f, None -> (f, Map.empty)
                    | Some f, Some e -> (f, e)
                    | None, _ ->
                        let f = o.DayFormat |> Option.defaultValue locale.DayFormat
                        let e = o.DayFormatExceptions |> Option.defaultValue locale.DayFormatExceptions
                        (f, e)
                | None -> (locale.DayFormat, locale.DayFormatExceptions)

            let dp =
                match ovr with
                | Some o -> o.DatePattern |> Option.defaultValue locale.DatePattern
                | None -> locale.DatePattern

            let dpy =
                match ovr with
                | Some o -> o.DatePatternWithYear |> Option.defaultValue locale.DatePatternWithYear
                | None -> locale.DatePatternWithYear

            let td =
                match ovr with
                | Some o -> o.Today |> Option.defaultValue locale.Today
                | None -> locale.Today

            let tm =
                match ovr with
                | Some o -> o.Tomorrow |> Option.defaultValue locale.Tomorrow
                | None -> locale.Tomorrow

            let ys =
                match ovr with
                | Some o -> o.Yesterday |> Option.defaultValue locale.Yesterday
                | None -> locale.Yesterday

            (mo, mid, wd, df, dfe, dp, dpy, td, tm, ys)

        let formatAbsolute (year: int) (month: int) (day: int) (includeYear: bool) : string =
            let dayStr = day.ToString()

            let fmt =
                match Map.tryFind dayStr dayFormatExceptions with
                | Some f -> f
                | None -> dayFormat

            let formattedDay = fmt.Replace("{n}", dayStr)

            let monthName =
                match monthsInDate with
                | Some arr -> arr.[month - 1]
                | None -> months.[month - 1]

            let pattern = if includeYear then datePatternWithYear else datePattern
            let mutable result = pattern.Replace("{month}", monthName)
            result <- result.Replace("{day}", formattedDay)
            result <- result.Replace("{d}", day.ToString())
            result <- result.Replace("{m}", month.ToString())

            if includeYear then
                result <- result.Replace("{year}", year.ToString())
                let yy = year % 100
                result <- result.Replace("{yy}", yy.ToString().PadLeft(2, '0'))

            result

        member _.FormatDate(date: string option) : string option =
            match date with
            | None -> None
            | Some s when String.IsNullOrEmpty(s) -> None
            | Some s ->
                match parseDate s with
                | None -> None
                | Some parsed -> Some(formatAbsolute parsed.[0] parsed.[1] parsed.[2] false)

        member _.FormatDateWithYear(date: string option) : string option =
            match date with
            | None -> None
            | Some s when String.IsNullOrEmpty(s) -> None
            | Some s ->
                match parseDate s with
                | None -> None
                | Some parsed -> Some(formatAbsolute parsed.[0] parsed.[1] parsed.[2] true)

        member _.FormatRelative(date: string option, asOf: string option) : string option =
            match date, asOf with
            | None, _ | _, None -> None
            | Some d, Some a when String.IsNullOrEmpty(d) || String.IsNullOrEmpty(a) -> None
            | Some d, Some a ->
                match parseDate d, parseDate a with
                | Some pd, Some pa ->
                    let dy, dm, dd = pd.[0], pd.[1], pd.[2]
                    let ay = pa.[0]

                    let dateJdn = toJdn dy dm dd
                    let asofJdn = toJdn pa.[0] pa.[1] pa.[2]
                    let diff = dateJdn - asofJdn

                    if diff = 0 then
                        Some todayStr
                    elif diff = 1 then
                        Some tomorrowStr
                    elif diff = -1 then
                        Some yesterdayStr
                    else
                        let isCompact = compactness = Compact

                        if diff = 2 && locale.DayAfterTomorrow.IsSome && not isCompact then
                            locale.DayAfterTomorrow
                        elif diff = -2 && locale.DayBeforeYesterday.IsSome && not isCompact then
                            locale.DayBeforeYesterday
                        elif isCompact then
                            Some(formatAbsolute dy dm dd (dy <> ay))
                        elif diff >= 2 && diff <= 6 && locale.ThisWeekday.IsSome then
                            let dow = weekday dy dm dd
                            let wdName = weekdays.[dow]
                            Some(locale.ThisWeekday.Value.Replace("{weekday}", wdName))
                        elif diff >= -6 && diff <= -2 && locale.LastWeekday.IsSome then
                            let dow = weekday dy dm dd
                            let wdName = weekdays.[dow]
                            Some(locale.LastWeekday.Value.Replace("{weekday}", wdName))
                        elif diff >= 7 && diff <= 13 && locale.NextWeekday.IsSome then
                            let dow = weekday dy dm dd
                            let wdName = weekdays.[dow]
                            Some(locale.NextWeekday.Value.Replace("{weekday}", wdName))
                        else
                            Some(formatAbsolute dy dm dd (dy <> ay))
                | _ -> None

    let private defaultFormatter = SayableDateFormatter(Locales.EN)

    let formatDateDefault (date: string option) : string option =
        defaultFormatter.FormatDate(date)

    let formatDateWithYearDefault (date: string option) : string option =
        defaultFormatter.FormatDateWithYear(date)

    let formatRelativeDefault (date: string option) (asOf: string option) : string option =
        defaultFormatter.FormatRelative(date, asOf)
