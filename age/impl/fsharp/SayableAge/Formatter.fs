namespace SayableAgeLib

open System
open SayableAgeLib.Types

module Formatter =

    let [<Literal>] Version = "0.5.0"

    let [<Literal>] private MaxAgeMonths = 6000

    let mutable internal timeNow: unit -> DateTime = fun () -> DateTime.Today

    type private AgeComponents = { Months: int; DiffDays: int }

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

    // DateTime can't represent year 0000, which the spec accepts (proleptic Gregorian).
    let private daysInMonth (year: int) (month: int) : int =
        match month with
        | 2 -> if (year % 4 = 0 && year % 100 <> 0) || year % 400 = 0 then 29 else 28
        | 4 | 6 | 9 | 11 -> 30
        | _ -> 31

    let private julianDay (year: int) (month: int) (day: int) : int =
        let a = (14 - month) / 12
        let y = year + 4800 - a
        let m = month + 12 * a - 3
        day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045

    /// Parses exactly YYYY-MM-DD naming a real calendar day.
    let private parseDateParts (s: string) : (int * int * int) option =
        if s.Length <> 10 || s.[4] <> '-' || s.[7] <> '-' then
            None
        else
            let y = safeAtoi s 0 4
            let m = safeAtoi s 5 7
            let d = safeAtoi s 8 10
            if y < 0 || m < 1 || m > 12 || d < 1 || d > daysInMonth y m then None
            else Some(y, m, d)

    let private parseAge (dateOfBirth: string option) (asOf: string option) : AgeComponents option =
        match dateOfBirth with
        | None -> None
        | Some dob when String.IsNullOrEmpty(dob) -> None
        | Some dob ->
            match parseDateParts dob with
            | None -> None
            | Some(dobY, dobM, dobD) ->
                let refY, refM, refD =
                    match asOf with
                    | Some asOfStr when not (String.IsNullOrEmpty(asOfStr)) ->
                        match parseDateParts asOfStr with
                        | Some(ry, rm, rd) -> (ry, rm, rd)
                        | None -> (-1, -1, -1)
                    | _ ->
                        let now = timeNow ()
                        (now.Year, now.Month, now.Day)

                if refY < 0 then
                    None
                else
                    let diffDays = julianDay refY refM refD - julianDay dobY dobM dobD
                    if diffDays < 0 then
                        None
                    else
                        let lastDay = daysInMonth refY refM
                        let clampedBirthday = min dobD lastDay
                        let mutable months = (refY - dobY) * 12 + (refM - dobM)
                        if refD < clampedBirthday then months <- months - 1
                        if months > MaxAgeMonths then None
                        else Some { Months = months; DiffDays = diffDays }

    let private stageKey (months: int) : string =
        if months < 2 then "newborn"
        elif months < 12 then "infant"
        elif months < 36 then "toddler"
        elif months < 156 then "child"
        elif months < 216 then "teenager"
        else "adult"

    type SayableAgeFormatter(locale: AgeLocale, ?compactness: Compactness) =
        let compactness = defaultArg compactness Normal

        let day, week, month, year, half, delimiter, justBorn =
            let mutable d = locale.Units.Day
            let mutable w = locale.Units.Week
            let mutable m = locale.Units.Month
            let mutable y = locale.Units.Year
            let mutable h = locale.Half
            let mutable del = locale.Delimiter
            let mutable jb = locale.JustBorn

            let ovr =
                match compactness with
                | Short -> locale.ShortOverride
                | Compact -> locale.CompactOverride
                | Normal -> None

            match ovr with
            | Some o ->
                match o.Day with Some v -> d <- v | None -> ()
                match o.Week with Some v -> w <- v | None -> ()
                match o.Month with Some v -> m <- v | None -> ()
                match o.Year with Some v -> y <- v | None -> ()
                match o.Half with Some v -> h <- v | None -> ()
                match o.Delimiter with Some v -> del <- v | None -> ()
                match o.JustBorn with Some v -> jb <- v | None -> ()
            | None -> ()

            (d, w, m, y, h, del, jb)

        let resolveUnit (count: int) (uf: UnitForms) (halfStr: string) : string =
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
                    let cat = locale.Plural count
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

        member _.FormatAge(dateOfBirth: string option, ?asOf: string option) : string option =
            let asOf = defaultArg asOf None
            match parseAge dateOfBirth asOf with
            | None -> None
            | Some age ->
                let months = age.Months
                let diffDays = age.DiffDays

                if diffDays = 0 then
                    Some justBorn
                elif diffDays < 7 then
                    Some(resolveUnit diffDays day "")
                elif months < 3 then
                    let weeks = diffDays / 7
                    let days = diffDays % 7
                    let result = resolveUnit weeks week ""
                    if days > 0 then
                        Some(result + delimiter + resolveUnit days day "")
                    else
                        Some result
                elif months < 24 then
                    Some(resolveUnit months month "")
                elif months < 36 then
                    let years = months / 12
                    let rem = months % 12
                    if rem = 0 then
                        Some(resolveUnit years year "")
                    else
                        Some(resolveUnit years year "" + delimiter + resolveUnit rem month "")
                elif months < 84 then
                    let years = months / 12
                    let rem = months % 12
                    if rem >= 6 then
                        Some(resolveUnit years year half)
                    else
                        Some(resolveUnit years year "")
                else
                    let years = months / 12
                    Some(resolveUnit years year "")

        member _.FormatStage(dateOfBirth: string option, ?asOf: string option, ?gender: string option) : string option =
            let asOf = defaultArg asOf None
            let gender = defaultArg gender None
            match parseAge dateOfBirth asOf with
            | None -> None
            | Some age ->
                let label =
                    match stageKey age.Months with
                    | "newborn" -> locale.Stages.Newborn
                    | "infant" -> locale.Stages.Infant
                    | "toddler" -> locale.Stages.Toddler
                    | "child" -> locale.Stages.Child
                    | "teenager" -> locale.Stages.Teenager
                    | _ -> locale.Stages.Adult

                Some(resolveStageLabel gender label)

    let private defaultFormatter = SayableAgeFormatter(Locales.EN)

    let formatAgeDefault (dateOfBirth: string option) (asOf: string option) : string option =
        defaultFormatter.FormatAge(dateOfBirth, ?asOf = Some asOf)

    let formatStageDefault (dateOfBirth: string option) (asOf: string option) (gender: string option) : string option =
        defaultFormatter.FormatStage(dateOfBirth, ?asOf = Some asOf, ?gender = Some gender)
