namespace SayableDurationLib

open System
open System.Globalization
open System.Text.RegularExpressions
open SayableDurationLib.Types

module Formatter =

    let [<Literal>] Version = "0.5.0"

    /// 500 years, the same ceiling as sayable-age.
    let private maxDurationMonths = 6000L

    /// YYYY-MM-DDTHH:MM with optional :SS, fraction and zone suffix (ignored).
    let private timestamp =
        Regex(
            @"\A([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{1,2}):([0-9]{2})(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?\z",
            RegexOptions.CultureInvariant
        )

    let private isLeapYear (year: int) : bool =
        (year % 4 = 0 && year % 100 <> 0) || (year % 400 = 0)

    let private daysInMonth (year: int) (month: int) : int =
        match month with
        | 1 | 3 | 5 | 7 | 8 | 10 | 12 -> 31
        | 4 | 6 | 9 | 11 -> 30
        | 2 -> if isLeapYear year then 29 else 28
        | _ -> 30

    let private daysSinceEpoch (year: int) (month: int) (day: int) : int =
        let mutable days = 0

        if year >= 2000 then
            for y in 2000 .. year - 1 do
                days <- days + (if isLeapYear y then 366 else 365)
        else
            for y in year .. 2000 - 1 do
                days <- days - (if isLeapYear y then 366 else 365)

        for m in 1 .. month - 1 do
            days <- days + daysInMonth year m

        days + day - 1

    let internal parseIsoToSeconds (iso: string) : int64 option =
        let m = timestamp.Match(if isNull iso then "" else iso)

        if not m.Success then
            None
        else
            let field (i: int) = Int32.Parse(m.Groups.[i].Value, CultureInfo.InvariantCulture)
            let year, month, day, hour, minute = field 1, field 2, field 3, field 4, field 5
            let second = if m.Groups.[6].Success then field 6 else 0
            let validDate = month >= 1 && month <= 12 && day >= 1 && day <= daysInMonth year month
            let validClock = hour <= 23 && minute <= 59 && second <= 59

            if validDate && validClock then
                let days = int64 (daysSinceEpoch year month day)
                Some(days * 86400L + int64 (hour * 3600 + minute * 60 + second))
            else
                None

    let private resolveUnit (count: int) (uf: UnitForms) (locale: DurationLocale) (halfStr: string) : string =
        let baseN =
            match locale.FormatNumber with
            | Some fn -> fn count
            | None -> string count

        let n =
            if halfStr.Length > 0 && halfStr.Contains("{n}") then
                halfStr.Replace("{n}", baseN)
            else
                baseN

        let template =
            match uf with
            | Simple t -> t
            | Plural forms ->
                let cat =
                    if halfStr.Length > 0 then Other
                    else locale.Plural count

                match Map.tryFind cat forms with
                | Some form -> form
                | None ->
                    match Map.tryFind Other forms with
                    | Some form -> form
                    | None -> "{n}"

        let result = template.Replace("{n}", n)

        let result =
            match locale.FormatUnit with
            | Some fn -> fn count result
            | None -> result

        if halfStr.Length > 0 && halfStr.Contains("{0}") then
            halfStr.Replace("{0}", result)
        else
            result

    type SayableDurationFormatter(locale: DurationLocale, ?compactness: Compactness) =
        let compactness = defaultArg compactness Normal

        let second, minute, hour, day, week, month, year, half, delimiter, justNow, ago, inFuture =
            let mutable s = locale.Units.Second
            let mutable min = locale.Units.Minute
            let mutable h = locale.Units.Hour
            let mutable d = locale.Units.Day
            let mutable w = locale.Units.Week
            let mutable mo = locale.Units.Month
            let mutable y = locale.Units.Year
            let mutable hf = locale.Half
            let mutable del = locale.Delimiter
            let jn = locale.JustNow
            let mutable ag = locale.Ago
            let mutable inf = locale.InFuture

            let ovr =
                match compactness with
                | Short -> locale.ShortOverride
                | Compact -> locale.CompactOverride
                | Normal -> None

            match ovr with
            | Some o ->
                match o.Second with Some v -> s <- v | None -> ()
                match o.Minute with Some v -> min <- v | None -> ()
                match o.Hour with Some v -> h <- v | None -> ()
                match o.Day with Some v -> d <- v | None -> ()
                match o.Week with Some v -> w <- v | None -> ()
                match o.Month with Some v -> mo <- v | None -> ()
                match o.Year with Some v -> y <- v | None -> ()
                match o.Half with Some v -> hf <- v | None -> ()
                match o.Delimiter with Some v -> del <- v | None -> ()
                match o.Ago with Some v -> ag <- v | None -> ()
                match o.InFuture with Some v -> inf <- v | None -> ()
            | None -> ()

            (s, min, h, d, w, mo, y, hf, del, jn, ag, inf)

        /// Counts are bounded by the 500-year ceiling, so they always fit in an int.
        let unit (count: int64) (uf: UnitForms) (halfStr: string) : string =
            resolveUnit (Checked.int count) uf locale halfStr

        let monthsIn (total: int64) : int64 =
            int64 (System.Math.Round(float (total / 86400L) / 30.44))

        let formatTiers (total: int64) : string =
            if total = 0L then
                justNow
            elif total < 60L then
                unit total second ""
            else
                let totalMinutes = total / 60L
                let remainderSeconds = total % 60L

                if totalMinutes < 5L then
                    let mutable result = unit totalMinutes minute ""

                    if remainderSeconds > 0L then
                        result <- result + delimiter + unit remainderSeconds second ""

                    result
                elif totalMinutes < 60L then
                    unit totalMinutes minute ""
                else
                    let totalHours = total / 3600L
                    let remainderMinutes = (total % 3600L) / 60L

                    if totalHours <= 5L then
                        if remainderMinutes = 30L then
                            unit totalHours hour half
                        else
                            let mutable result = unit totalHours hour ""

                            if remainderMinutes > 0L then
                                result <- result + delimiter + unit remainderMinutes minute ""

                            result
                    elif totalHours < 24L then
                        unit totalHours hour ""
                    else
                        let totalDays = total / 86400L
                        let remainderHours = (total % 86400L) / 3600L

                        if totalDays <= 2L then
                            if remainderHours = 12L then
                                unit totalDays day half
                            else
                                let mutable result = unit totalDays day ""

                                if remainderHours > 0L then
                                    result <- result + delimiter + unit remainderHours hour ""

                                result
                        elif totalDays < 7L then
                            unit totalDays day ""
                        elif totalDays < 30L then
                            let totalWeeks = totalDays / 7L
                            let remainderDays = totalDays % 7L
                            let mutable result = unit totalWeeks week ""

                            if remainderDays > 0L then
                                result <- result + delimiter + unit remainderDays day ""

                            result
                        else
                            let mutable totalMonths = monthsIn total

                            if totalMonths < 12L then
                                if totalMonths = 0L then totalMonths <- 1L

                                unit totalMonths month ""
                            else
                                let totalYears = totalMonths / 12L
                                let remainderMonths = totalMonths % 12L
                                let mutable result = unit totalYears year ""

                                if remainderMonths > 0L then
                                    result <- result + delimiter + unit remainderMonths month ""

                                result

        let formatDurationSecondsInternal (total: int64) : string option =
            if monthsIn total > maxDurationMonths then None else Some(formatTiers total)

        member _.FormatDurationSeconds(seconds: int64) : string option =
            if seconds < 0L then None
            else formatDurationSecondsInternal seconds

        member _.FormatDurationIso(startIso: string, endIso: string) : string option =
            if String.IsNullOrEmpty(startIso) || String.IsNullOrEmpty(endIso) then
                None
            else
                match parseIsoToSeconds startIso, parseIsoToSeconds endIso with
                | Some s, Some e ->
                    formatDurationSecondsInternal (abs (e - s))
                | _ -> None

        member _.FormatSince(start: string option, asOf: string option) : string option =
            match start, asOf with
            | None, _ | _, None -> None
            | Some s, Some a when String.IsNullOrEmpty(s) || String.IsNullOrEmpty(a) -> None
            | Some s, Some a ->
                match parseIsoToSeconds s, parseIsoToSeconds a with
                | Some sv, Some av ->
                    let diff = av - sv

                    if diff < 0L then None
                    elif diff = 0L then Some justNow
                    else formatDurationSecondsInternal diff |> Option.map (fun dur -> ago.Replace("{0}", dur))
                | _ -> None

        member _.FormatUntil(target: string option, asOf: string option) : string option =
            match target, asOf with
            | None, _ | _, None -> None
            | Some t, Some a when String.IsNullOrEmpty(t) || String.IsNullOrEmpty(a) -> None
            | Some t, Some a ->
                match parseIsoToSeconds t, parseIsoToSeconds a with
                | Some tv, Some av ->
                    let diff = tv - av

                    if diff < 0L then None
                    elif diff = 0L then Some justNow
                    else formatDurationSecondsInternal diff |> Option.map (fun dur -> inFuture.Replace("{0}", dur))
                | _ -> None

    let private defaultFormatter = SayableDurationFormatter(Locales.EN)

    let formatDurationSecondsDefault (seconds: int64) : string option =
        defaultFormatter.FormatDurationSeconds(seconds)

    let formatDurationIsoDefault (startIso: string) (endIso: string) : string option =
        defaultFormatter.FormatDurationIso(startIso, endIso)

    let formatSinceDefault (start: string option) (asOf: string option) : string option =
        defaultFormatter.FormatSince(start, asOf)

    let formatUntilDefault (target: string option) (asOf: string option) : string option =
        defaultFormatter.FormatUntil(target, asOf)
