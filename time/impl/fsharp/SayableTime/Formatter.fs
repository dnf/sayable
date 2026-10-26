namespace SayableTimeLib

open System
open System.Globalization
open System.Text.RegularExpressions
open SayableTimeLib.Types

module Formatter =

    let [<Literal>] Version = "0.5.0"

    /// H:MM or HH:MM, optional :SS and fraction, optional zone suffix (ignored).
    let private clock =
        Regex(
            @"\A([0-9]{1,2}):([0-9]{2})(?::([0-9]{2})(?:\.[0-9]+)?)?(?:Z|[+-][0-9]{2}:[0-9]{2})?\z",
            RegexOptions.CultureInvariant
        )

    let private dateOnly =
        Regex(@"\A([0-9]{4})-([0-9]{2})-([0-9]{2})\z", RegexOptions.CultureInvariant)

    let private field (m: Match) (i: int) : int =
        Int32.Parse(m.Groups.[i].Value, CultureInfo.InvariantCulture)

    // DateTime can't represent year 0000, which the spec accepts (proleptic Gregorian).
    let private daysInMonth (year: int) (month: int) : int =
        match month with
        | 2 -> if (year % 4 = 0 && year % 100 <> 0) || year % 400 = 0 then 29 else 28
        | 4 | 6 | 9 | 11 -> 30
        | _ -> 31

    let private isRealDate (s: string) : bool =
        let m = dateOnly.Match(s)
        m.Success
        && (let month = field m 2
            let day = field m 3
            month >= 1 && month <= 12 && day >= 1 && day <= daysInMonth (field m 1) month)

    let internal parseTime (input: string) : (int * int) option =
        if String.IsNullOrEmpty(input) then
            None
        else
            let tIdx = input.IndexOf('T')
            let datePartIsValid = tIdx < 0 || isRealDate (input.Substring(0, tIdx))
            let m = clock.Match(input.Substring(tIdx + 1))

            if not datePartIsValid || not m.Success then
                None
            else
                let hour, minute = field m 1, field m 2
                let second = if m.Groups.[3].Success then field m 3 else 0

                if hour <= 23 && minute <= 59 && second <= 59 then
                    Some(hour, minute)
                else
                    None

    let internal roundTo5 (minute: int) : int =
        (minute + 2) / 5 * 5

    type SayableTimeFormatter(locale: TimeLocale, ?compactness: Compactness) =
        let compactness = defaultArg compactness Normal

        let shortClock =
            let ovr =
                match compactness with
                | Short -> locale.ShortOverride
                | Compact -> locale.CompactOverride
                | Normal -> None

            match ovr with
            | Some o -> o.Clock
            | None -> None

        let formatNatural (hour: int) (minute: int) : string =
            let clock = locale.Clock
            let mutable rounded = roundTo5 minute
            let mutable h = hour

            if rounded = 60 then
                rounded <- 0
                h <- (h + 1) % 24

            if rounded = 0 then
                if h = 0 then clock.Midnight
                elif h = 12 then clock.Noon
                else
                    let h12 = h % 12
                    let nextH12 = (h + 1) % 12
                    let hName = clock.Hours.[h12]
                    let nextHName = clock.Hours.[nextH12]

                    let pattern =
                        match Map.tryFind rounded clock.Patterns with
                        | Some p -> p
                        | None ->
                            match Map.tryFind 0 clock.Patterns with
                            | Some p -> p
                            | None -> "{h}"

                    pattern.Replace("{h}", hName).Replace("{next_h}", nextHName)
            else
                let h12 = h % 12
                let nextH12 = (h + 1) % 12
                let hName = clock.Hours.[h12]
                let nextHName = clock.Hours.[nextH12]

                let pattern =
                    match Map.tryFind rounded clock.Patterns with
                    | Some p -> p
                    | None ->
                        match Map.tryFind 0 clock.Patterns with
                        | Some p -> p
                        | None -> "{h}"

                pattern.Replace("{h}", hName).Replace("{next_h}", nextHName)

        let formatDigital (hour: int) (minute: int) : string =
            let sc = shortClock.Value
            let fmt = sc.Format

            if sc.Use24h then
                fmt
                    .Replace("{h}", hour.ToString())
                    .Replace("{mm}", minute.ToString().PadLeft(2, '0'))
            else
                let mutable h12 = hour % 12

                if h12 = 0 then
                    h12 <- 12

                let amPm =
                    match sc.AmPm with
                    | Some(a, p) -> (a, p)
                    | None -> ("AM", "PM")

                let ampmStr =
                    if hour < 12 then fst amPm else snd amPm

                fmt
                    .Replace("{h}", h12.ToString())
                    .Replace("{mm}", minute.ToString().PadLeft(2, '0'))
                    .Replace("{ampm}", ampmStr)

        member _.FormatTime(input: string option) : string option =
            match input with
            | None -> None
            | Some s when String.IsNullOrEmpty(s) -> None
            | Some s ->
                match parseTime s with
                | None -> None
                | Some(hour, minute) ->
                    if shortClock.IsSome then
                        Some(formatDigital hour minute)
                    else
                        Some(formatNatural hour minute)

    let private defaultFormatter = SayableTimeFormatter(Locales.EN)

    let formatTimeDefault (input: string option) : string option =
        defaultFormatter.FormatTime(input)
