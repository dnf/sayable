namespace SayableTimeLib

open System
open SayableTimeLib.Types

module Formatter =

    let [<Literal>] Version = "0.5.0"

    let internal parseTime (input: string) : (int * int) option =
        if String.IsNullOrEmpty(input) then
            None
        else
            let mutable t = input
            let tIdx = t.IndexOf('T')

            if tIdx >= 0 then
                t <- t.Substring(tIdx + 1)

            let plusIdx = t.IndexOf('+')

            if plusIdx >= 0 then
                t <- t.Substring(0, plusIdx)

            let zIdx = t.IndexOf('Z')

            if zIdx >= 0 then
                t <- t.Substring(0, zIdx)

            let parts = t.Split(':')

            if parts.Length < 2 then
                None
            else
                match System.Int32.TryParse(parts.[0]), System.Int32.TryParse(parts.[1]) with
                | (true, hour), (true, minute) when hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59 ->
                    Some(hour, minute)
                | _ -> None

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
