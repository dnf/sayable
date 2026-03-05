namespace SayableDurationLib

open System
open SayableDurationLib.Types

module Formatter =

    let [<Literal>] Version = "0.5.0"

    let private safeAtoi (s: string) (fromIdx: int) (toIdx: int) : int =
        let mutable n = 0
        let mutable ok = true
        let mutable i = fromIdx

        while ok && i < toIdx do
            let c = s.[i]

            if c < '0' || c > '9' then
                ok <- false
            else
                n <- n * 10 + (int c - int '0')
                i <- i + 1

        if ok then n else -1

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

    let internal parseIsoToSeconds (iso: string) : int option =
        if String.IsNullOrEmpty(iso) then
            None
        else
            let tIdx = iso.IndexOf('T')

            if tIdx < 0 then
                None
            else
                let datePart = iso.Substring(0, tIdx)
                let mutable timePart = iso.Substring(tIdx + 1)

                let dp = datePart.Split('-')

                if dp.Length < 3 then
                    None
                else
                    let year = safeAtoi dp.[0] 0 dp.[0].Length
                    let month = safeAtoi dp.[1] 0 dp.[1].Length
                    let day = safeAtoi dp.[2] 0 dp.[2].Length

                    if year < 0 || month < 0 || day < 0 then
                        None
                    else
                        let plusIdx = timePart.IndexOf('+')

                        if plusIdx >= 0 then
                            timePart <- timePart.Substring(0, plusIdx)

                        let zIdx = timePart.IndexOf('Z')

                        if zIdx >= 0 then
                            timePart <- timePart.Substring(0, zIdx)

                        let tp = timePart.Split(':')
                        let hour = safeAtoi tp.[0] 0 tp.[0].Length

                        if hour < 0 then
                            None
                        else
                            let minute =
                                if tp.Length > 1 then safeAtoi tp.[1] 0 tp.[1].Length else 0

                            if minute < 0 then
                                None
                            else
                                let second =
                                    if tp.Length > 2 then
                                        let secStr = tp.[2].Split('.').[0]
                                        safeAtoi secStr 0 secStr.Length
                                    else
                                        0

                                if second < 0 then
                                    None
                                else
                                    let days = daysSinceEpoch year month day
                                    Some(days * 86400 + hour * 3600 + minute * 60 + second)

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

        let formatDurationSecondsInternal (total: int) : string =
            if total = 0 then
                justNow
            elif total < 60 then
                resolveUnit total second locale ""
            else
                let totalMinutes = total / 60
                let remainderSeconds = total % 60

                if totalMinutes < 5 then
                    let mutable result = resolveUnit totalMinutes minute locale ""

                    if remainderSeconds > 0 then
                        result <- result + delimiter + resolveUnit remainderSeconds second locale ""

                    result
                elif totalMinutes < 60 then
                    resolveUnit totalMinutes minute locale ""
                else
                    let totalHours = total / 3600
                    let remainderMinutes = (total % 3600) / 60

                    if totalHours <= 5 then
                        if remainderMinutes = 30 then
                            resolveUnit totalHours hour locale half
                        else
                            let mutable result = resolveUnit totalHours hour locale ""

                            if remainderMinutes > 0 then
                                result <- result + delimiter + resolveUnit remainderMinutes minute locale ""

                            result
                    elif totalHours < 24 then
                        resolveUnit totalHours hour locale ""
                    else
                        let totalDays = total / 86400
                        let remainderHours = (total % 86400) / 3600

                        if totalDays <= 2 then
                            if remainderHours = 12 then
                                resolveUnit totalDays day locale half
                            else
                                let mutable result = resolveUnit totalDays day locale ""

                                if remainderHours > 0 then
                                    result <- result + delimiter + resolveUnit remainderHours hour locale ""

                                result
                        elif totalDays < 7 then
                            resolveUnit totalDays day locale ""
                        elif totalDays < 30 then
                            let totalWeeks = totalDays / 7
                            let remainderDays = totalDays % 7
                            let mutable result = resolveUnit totalWeeks week locale ""

                            if remainderDays > 0 then
                                result <- result + delimiter + resolveUnit remainderDays day locale ""

                            result
                        else
                            let mutable totalMonths =
                                int (System.Math.Round(float totalDays / 30.44))

                            if totalMonths < 12 then
                                if totalMonths = 0 then totalMonths <- 1

                                resolveUnit totalMonths month locale ""
                            else
                                let totalYears = totalMonths / 12
                                let remainderMonths = totalMonths % 12
                                let mutable result = resolveUnit totalYears year locale ""

                                if remainderMonths > 0 then
                                    result <- result + delimiter + resolveUnit remainderMonths month locale ""

                                result

        member _.FormatDurationSeconds(seconds: int) : string option =
            if seconds < 0 then None
            else Some(formatDurationSecondsInternal seconds)

        member _.FormatDurationIso(startIso: string, endIso: string) : string option =
            if String.IsNullOrEmpty(startIso) || String.IsNullOrEmpty(endIso) then
                None
            else
                match parseIsoToSeconds startIso, parseIsoToSeconds endIso with
                | Some s, Some e ->
                    let total = abs (e - s)
                    Some(formatDurationSecondsInternal total)
                | _ -> None

        member _.FormatSince(start: string option, asOf: string option) : string option =
            match start, asOf with
            | None, _ | _, None -> None
            | Some s, Some a when String.IsNullOrEmpty(s) || String.IsNullOrEmpty(a) -> None
            | Some s, Some a ->
                match parseIsoToSeconds s, parseIsoToSeconds a with
                | Some sv, Some av ->
                    let diff = av - sv

                    if diff < 0 then None
                    elif diff = 0 then Some justNow
                    else
                        let dur = formatDurationSecondsInternal diff
                        Some(ago.Replace("{0}", dur))
                | _ -> None

        member _.FormatUntil(target: string option, asOf: string option) : string option =
            match target, asOf with
            | None, _ | _, None -> None
            | Some t, Some a when String.IsNullOrEmpty(t) || String.IsNullOrEmpty(a) -> None
            | Some t, Some a ->
                match parseIsoToSeconds t, parseIsoToSeconds a with
                | Some tv, Some av ->
                    let diff = tv - av

                    if diff < 0 then None
                    elif diff = 0 then Some justNow
                    else
                        let dur = formatDurationSecondsInternal diff
                        Some(inFuture.Replace("{0}", dur))
                | _ -> None

    let private defaultFormatter = SayableDurationFormatter(Locales.EN)

    let formatDurationSecondsDefault (seconds: int) : string option =
        defaultFormatter.FormatDurationSeconds(seconds)

    let formatDurationIsoDefault (startIso: string) (endIso: string) : string option =
        defaultFormatter.FormatDurationIso(startIso, endIso)

    let formatSinceDefault (start: string option) (asOf: string option) : string option =
        defaultFormatter.FormatSince(start, asOf)

    let formatUntilDefault (target: string option) (asOf: string option) : string option =
        defaultFormatter.FormatUntil(target, asOf)
